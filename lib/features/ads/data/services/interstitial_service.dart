import 'dart:async';
import 'dart:developer';
import 'package:secmtp_sdk/at_index.dart';
import '../../domain/models/models.dart';

class InterstitialService {
  final StreamController<TopOnAdEvent> _eventController;
  TopOnAdsConfig? _config;
  bool _isListenerInitialized = false;

  InterstitialService(this._eventController);

  void initialize(TopOnAdsConfig config) {
    _config = config;
    if (!_isListenerInitialized) {
      _setupListener();
      _isListenerInitialized = true;
    }
  }

  String get _placementId => _config!.current.getPlacement(TopOnAdUnit.interstitial) ?? '';
  String get _autoPlacementId => _config!.current.getPlacement(TopOnAdUnit.interstitialAuto) ?? '';
  String get _sceneId => _config!.current.getSceneId(TopOnAdUnit.interstitial) ?? '';
  String get _autoSceneId => _config!.current.getSceneId(TopOnAdUnit.interstitialAuto) ?? '';
  String get _showCustomExt => _config!.current.getShowCustomExt(TopOnAdUnit.interstitial) ?? '';

  Future<void> load({bool auto = false}) async {
    final placementId = auto ? _autoPlacementId : _placementId;
    _emitEvent(TopOnAdEventType.loading, placementId, auto ? TopOnAdUnit.interstitialAuto : TopOnAdUnit.interstitial);

    if (auto) {
      await ATInterstitialManager.autoLoadInterstitialAD(placementIDs: placementId);
    } else {
      await ATInterstitialManager.loadInterstitialAd(placementID: placementId, extraMap: {});
    }
  }

  Future<TopOnShowResult> show({bool auto = false, String? sceneId}) async {
    final placementId = auto ? _autoPlacementId : _placementId;
    final scene = sceneId ?? (auto ? _autoSceneId : _sceneId);

    final isReady = await ATInterstitialManager.hasInterstitialAdReady(placementID: placementId);
    if (isReady != true) {
      return TopOnShowResult.failure('Ad not ready');
    }

    await ATInterstitialManager.entryInterstitialScenario(placementID: placementId, sceneID: scene);

    if (auto) {
      await ATInterstitialManager.showAutoLoadInterstitialAD(placementID: placementId, sceneID: scene);
    } else {
      await ATInterstitialManager.showInterstitialAdWithShowConfig(
        placementID: placementId,
        sceneID: scene,
        showCustomExt: _showCustomExt,
      );
    }

    return TopOnShowResult.success();
  }

  Future<bool> isReady({bool auto = false}) async {
    final placementId = auto ? _autoPlacementId : _placementId;
    return await ATInterstitialManager.hasInterstitialAdReady(placementID: placementId) == true;
  }

  Future<void> cancelAutoLoad() async {
    await ATInterstitialManager.cancelAutoLoadInterstitialAD(placementIDs: _autoPlacementId);
  }

  void _setupListener() {
    ATListenerManager.interstitialEventHandler.listen((value) {
      final adUnit = value.placementID == _autoPlacementId 
          ? TopOnAdUnit.interstitialAuto 
          : TopOnAdUnit.interstitial;

      switch (value.interstatus) {
        case InterstitialStatus.interstitialAdFailToLoadAD:
          log("InterstitialService: loadFailed - ${value.placementID}");
          _emitEvent(TopOnAdEventType.loadFailed, value.placementID, adUnit, errorMessage: value.requestMessage);
          break;
        case InterstitialStatus.interstitialAdDidFinishLoading:
          log("InterstitialService: loaded - ${value.placementID}");
          _emitEvent(TopOnAdEventType.loaded, value.placementID, adUnit);
          break;
        case InterstitialStatus.interstitialAdDidStartPlaying:
          _emitEvent(TopOnAdEventType.videoStarted, value.placementID, adUnit, extra: _castExtra(value.extraMap));
          break;
          case InterstitialStatus.interstitialAdDidEndPlaying:
          _emitEvent(TopOnAdEventType.videoEnded, value.placementID, adUnit, extra: _castExtra(value.extraMap));
          break;
          case InterstitialStatus.interstitialDidFailToPlayVideo:
          _emitEvent(TopOnAdEventType.showFailed, value.placementID, adUnit, errorMessage: value.requestMessage);
          break;
          case InterstitialStatus.interstitialDidShowSucceed:
          _emitEvent(TopOnAdEventType.showed, value.placementID, adUnit, extra: _castExtra(value.extraMap));
          break;
          case InterstitialStatus.interstitialFailedToShow:
          _emitEvent(TopOnAdEventType.showFailed, value.placementID, adUnit, errorMessage: value.requestMessage);
          break;
          case InterstitialStatus.interstitialAdDidClick:
          _emitEvent(TopOnAdEventType.clicked, value.placementID, adUnit, extra: _castExtra(value.extraMap));
          break;
          case InterstitialStatus.interstitialAdDidDeepLink:
          _emitEvent(TopOnAdEventType.deepLink, value.placementID, adUnit, extra: _castExtra(value.extraMap));
          break;
          case InterstitialStatus.interstitialAdDidClose:
          log("InterstitialService: closed - ${value.placementID}");
          _emitEvent(TopOnAdEventType.closed, value.placementID, adUnit, extra: _castExtra(value.extraMap));
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
