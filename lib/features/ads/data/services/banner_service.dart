import 'dart:async';
import 'dart:developer';
import 'package:secmtp_sdk/at_index.dart';
import '../../domain/models/models.dart';

class BannerService {
  final StreamController<TopOnAdEvent> _eventController;
  TopOnAdsConfig? _config;
  bool _isListenerInitialized = false;
  double _screenWidth = 320;

  BannerService(this._eventController);

  void initialize(TopOnAdsConfig config, {double screenWidth = 320}) {
    _config = config;
    _screenWidth = screenWidth;
    if (!_isListenerInitialized) {
      _setupListener();
      _isListenerInitialized = true;
    }
  }

  String get _placementId => _config!.current.getPlacement(TopOnAdUnit.banner) ?? '';
  String get _sceneId => _config!.current.getSceneId(TopOnAdUnit.banner) ?? '';
  String get _showCustomExt => _config!.current.getShowCustomExt(TopOnAdUnit.banner) ?? '';

  Future<void> load() async {
    _emitEvent(TopOnAdEventType.loading, _placementId);

    await ATBannerManager.loadBannerAd(
      placementID: _placementId,
      extraMap: {
        ATCommon.isNativeShow(): true,
        ATCommon.getAdSizeKey(): ATBannerManager.createLoadBannerAdSize(_screenWidth, _screenWidth * (50 / 320)),
        ATBannerManager.getAdaptiveWidthKey(): _screenWidth,
        ATBannerManager.getAdaptiveOrientationKey(): ATBannerManager.adaptiveOrientationCurrent(),
      },
    );
  }

  Future<void> show({BannerPosition position = BannerPosition.bottom, BannerSize size = BannerSize.standard}) async {
    final isReady = await ATBannerManager.bannerAdReady(placementID: _placementId);
    if (isReady != true) {
      await load();
      return;
    }

    await ATBannerManager.entryBannerScenario(placementID: _placementId, sceneID: _sceneId);

    final bannerPosition = position == BannerPosition.top 
        ? ATCommon.getAdATBannerAdShowingPositionTop()
        : ATCommon.getAdATBannerAdShowingPositionBottom();

    await ATBannerManager.showSceneBannerAdInPosition(
      placementID: _placementId,
      sceneID: _sceneId,
      position: bannerPosition,
      showCustomExt: _showCustomExt,
    );
  }

  Future<void> showInRectangle({double x = 0, double y = 200, double width = 400, double height = 500}) async {
    final isReady = await ATBannerManager.bannerAdReady(placementID: _placementId);
    if (isReady != true) {
      await load();
      return;
    }

    await ATBannerManager.entryBannerScenario(placementID: _placementId, sceneID: _sceneId);

    await ATBannerManager.showSceneBannerInRectangle(
      placementID: _placementId,
      sceneID: _sceneId,
      extraMap: {
        ATCommon.getAdSizeKey(): ATBannerManager.createLoadBannerAdSize(width, height, x: x, y: y),
        ATCommon.getShowCustomExtKey(): _showCustomExt,
      },
    );
  }

  Future<void> hide() async {
    await ATBannerManager.hideBannerAd(placementID: _placementId);
  }

  Future<void> remove() async {
    await ATBannerManager.removeBannerAd(placementID: _placementId);
  }

  Future<void> refresh() async {
    await ATBannerManager.afreshShowBannerAd(placementID: _placementId);
  }

  Future<bool> isReady() async {
    return await ATBannerManager.bannerAdReady(placementID: _placementId) == true;
  }

  void _setupListener() {
    ATListenerManager.bannerEventHandler.listen((value) {
      switch (value.bannerStatus) {
        case BannerStatus.bannerAdFailToLoadAD:
          log("BannerService: loadFailed - ${value.placementID}");
          _emitEvent(TopOnAdEventType.loadFailed, value.placementID, errorMessage: value.requestMessage);
          break;
        case BannerStatus.bannerAdDidFinishLoading:
          log("BannerService: loaded - ${value.placementID}");
          _emitEvent(TopOnAdEventType.loaded, value.placementID);
          break;
        case BannerStatus.bannerAdAutoRefreshSucceed:
          _emitEvent(TopOnAdEventType.loaded, value.placementID, extra: _castExtra(value.extraMap));
          break;
        case BannerStatus.bannerAdDidClick:
          _emitEvent(TopOnAdEventType.clicked, value.placementID, extra: _castExtra(value.extraMap));
          break;
        case BannerStatus.bannerAdDidDeepLink:
          _emitEvent(TopOnAdEventType.deepLink, value.placementID, extra: _castExtra(value.extraMap));
          break;
        case BannerStatus.bannerAdDidShowSucceed:
          _emitEvent(TopOnAdEventType.showed, value.placementID, extra: _castExtra(value.extraMap));
          break;
        case BannerStatus.bannerAdTapCloseButton:
          log("BannerService: closed - ${value.placementID}");
          _emitEvent(TopOnAdEventType.closed, value.placementID, extra: _castExtra(value.extraMap));
          break;
        case BannerStatus.bannerAdAutoRefreshFail:
          _emitEvent(TopOnAdEventType.loadFailed, value.placementID, errorMessage: value.requestMessage);
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

  void _emitEvent(TopOnAdEventType type, String placementId, {String? errorMessage, Map<String, dynamic>? extra}) {
    _eventController.add(TopOnAdEvent(
      adUnit: TopOnAdUnit.banner,
      placementId: placementId,
      type: type,
      errorMessage: errorMessage,
      extra: extra,
    ));
  }
}
