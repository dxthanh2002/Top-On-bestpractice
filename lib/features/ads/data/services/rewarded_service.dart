import 'dart:async';
import 'dart:developer';
import 'package:secmtp_sdk/at_index.dart';
import '../../domain/models/models.dart';

class RewardedService {
  final StreamController<TopOnAdEvent> _eventController;
  TopOnAdsConfig? _config;
  bool _isListenerInitialized = false;

  RewardedService(this._eventController);

  void initialize(TopOnAdsConfig config) {
    _config = config;
    if (!_isListenerInitialized) {
      _setupListener();
      _isListenerInitialized = true;
    }
  }

  String get _placementId => _config!.current.getPlacement(TopOnAdUnit.rewarded) ?? '';
  String get _autoPlacementId => _config!.current.getPlacement(TopOnAdUnit.rewardedAuto) ?? '';
  String get _sceneId => _config!.current.getSceneId(TopOnAdUnit.rewarded) ?? '';
  String get _autoSceneId => _config!.current.getSceneId(TopOnAdUnit.rewardedAuto) ?? '';
  String get _showCustomExt => _config!.current.getShowCustomExt(TopOnAdUnit.rewarded) ?? '';

  Future<void> load({bool auto = false}) async {
    final placementId = auto ? _autoPlacementId : _placementId;
    _emitEvent(TopOnAdEventType.loading, placementId, auto ? TopOnAdUnit.rewardedAuto : TopOnAdUnit.rewarded);

    if (auto) {
      await ATRewardedManager.autoLoadRewardedVideo(placementIDs: placementId);
    } else {
      await ATRewardedManager.loadRewardedVideo(
        placementID: placementId,
        extraMap: {
          ATRewardedManager.kATAdLoadingExtraUserDataKeywordKey(): '',
          ATRewardedManager.kATAdLoadingExtraUserIDKey(): '',
        },
      );
    }
  }

  Future<TopOnShowResult> show({bool auto = false, String? sceneId}) async {
    final placementId = auto ? _autoPlacementId : _placementId;
    final scene = sceneId ?? (auto ? _autoSceneId : _sceneId);

    final isReady = await ATRewardedManager.rewardedVideoReady(placementID: placementId);
    if (isReady != true) {
      // Check load status before trying to load again
      final loadStatus = await checkLoadStatus(auto: auto);
      if (loadStatus == 1) {
        return TopOnShowResult.failure('Ad is loading...');
      }
      return TopOnShowResult.failure('Ad not ready');
    }

    // Scene tracking (optional)
    ATRewardedManager.entryRewardedVideoScenario(placementID: placementId, sceneID: scene);
    
    // Get valid ads cache (optional - for logging/tracking)
    ATRewardedManager.getRewardedVideoValidAds(placementID: placementId).then((value) {
      log('RewardedService: getValidAds - $value');
    });

    if (auto) {
      ATRewardedManager.showAutoLoadRewardedVideoAD(placementID: placementId, sceneID: scene);
    } else {
      ATRewardedManager.showRewardedVideoWithShowConfig(
        placementID: placementId,
        sceneID: scene,
        showCustomExt: _showCustomExt,
      );
    }

    return TopOnShowResult.success();
  }
  
  Future<int> checkLoadStatus({bool auto = false}) async {
    final placementId = auto ? _autoPlacementId : _placementId;
    try {
      final value = await ATRewardedManager.checkRewardedVideoLoadStatus(placementID: placementId);
      return value['isLoading'] ?? 0;
    } catch (e) {
      return -1;
    }
  }

  Future<bool> isReady({bool auto = false}) async {
    final placementId = auto ? _autoPlacementId : _placementId;
    return await ATRewardedManager.rewardedVideoReady(placementID: placementId) == true;
  }

  Future<void> cancelAutoLoad() async {
    await ATRewardedManager.cancelAutoLoadRewardedVideo(placementIDs: _autoPlacementId);
  }

  void _setupListener() {
    ATListenerManager.rewardedVideoEventHandler.listen((value) {
      final adUnit = value.placementID == _autoPlacementId 
          ? TopOnAdUnit.rewardedAuto 
          : TopOnAdUnit.rewarded;

      switch (value.rewardStatus) {
        case RewardedStatus.rewardedVideoDidFailToLoad:
          log("RewardedService: loadFailed - ${value.placementID}");
          _emitEvent(TopOnAdEventType.loadFailed, value.placementID, adUnit, errorMessage: value.requestMessage);
          break;
        case RewardedStatus.rewardedVideoDidFinishLoading:
          log("RewardedService: loaded - ${value.placementID}");
          _emitEvent(TopOnAdEventType.loaded, value.placementID, adUnit);
          break;
        case RewardedStatus.rewardedVideoDidStartPlaying:
          _emitEvent(TopOnAdEventType.videoStarted, value.placementID, adUnit, extra: _castExtra(value.extraMap));
          break;
          case RewardedStatus.rewardedVideoDidEndPlaying:
          _emitEvent(TopOnAdEventType.videoEnded, value.placementID, adUnit, extra: _castExtra(value.extraMap));
          break;
          case RewardedStatus.rewardedVideoDidFailToPlay:
          _emitEvent(TopOnAdEventType.showFailed, value.placementID, adUnit, extra: _castExtra(value.extraMap));
          break;
          case RewardedStatus.rewardedVideoDidRewardSuccess:
          log("RewardedService: rewardEarned - ${value.placementID}");
          _emitEvent(TopOnAdEventType.rewardEarned, value.placementID, adUnit, extra: _castExtra(value.extraMap));
          break;
          case RewardedStatus.rewardedVideoDidClick:
          _emitEvent(TopOnAdEventType.clicked, value.placementID, adUnit, extra: _castExtra(value.extraMap));
          break;
          case RewardedStatus.rewardedVideoDidDeepLink:
          _emitEvent(TopOnAdEventType.deepLink, value.placementID, adUnit, extra: _castExtra(value.extraMap));
          break;
          case RewardedStatus.rewardedVideoDidClose:
          log("RewardedService: closed - ${value.placementID}");
          _emitEvent(TopOnAdEventType.closed, value.placementID, adUnit, extra: _castExtra(value.extraMap));
          // Auto reload after close (like original code)
          final isAuto = value.placementID == _autoPlacementId;
          load(auto: isAuto);
          break;
          case RewardedStatus.rewardedVideoDidAgainRewardSuccess:
          _emitEvent(TopOnAdEventType.rewardEarned, value.placementID, adUnit, extra: _castExtra(value.extraMap));
          break;
        default:
          break;
      }
    });
  }

  Map<String, dynamic>? _castExtra(Map<dynamic, dynamic>? extra) {
    if (extra == null) return null;
    return extra.map((k, v) => MapEntry(k.toString(), v));
  }

  void _emitEvent(TopOnAdEventType type, String placementId, TopOnAdUnit adUnit, {String? errorMessage, Map<String, dynamic>? extra}) {
    _eventController.add(TopOnAdEvent(
      adUnit: adUnit,
      placementId: placementId,
      type: type,
      errorMessage: errorMessage,
      extra: extra,
    ));
  }
}
