import 'dart:async';
import 'dart:developer';
import 'package:secmtp_sdk/at_index.dart';
import '../../domain/models/models.dart';

class SplashService {
  final StreamController<TopOnAdEvent> _eventController;
  TopOnAdsConfig? _config;
  bool _isListenerInitialized = false;

  SplashService(this._eventController);

  void initialize(TopOnAdsConfig config) {
    _config = config;
    if (!_isListenerInitialized) {
      _setupListener();
      _isListenerInitialized = true;
    }
  }

  String get _placementId => _config!.current.getPlacement(TopOnAdUnit.splash) ?? '';
  String get _sceneId => _config!.current.getSceneId(TopOnAdUnit.splash) ?? '';
  String get _showCustomExt => _config!.current.getShowCustomExt(TopOnAdUnit.splash) ?? '';

  Future<void> load({int timeout = 5000}) async {
    _emitEvent(TopOnAdEventType.loading, _placementId);

    await ATSplashManager.loadSplash(
      placementID: _placementId,
      extraMap: {ATSplashManager.tolerateTimeout(): timeout},
    );
  }

  Future<TopOnShowResult> show({String? sceneId}) async {
    final scene = sceneId ?? _sceneId;

    final isReady = await ATSplashManager.splashReady(placementID: _placementId);
    if (isReady != true) {
      return TopOnShowResult.failure('Ad not ready');
    }

    // Don't await - these SDK calls may not complete their Futures
    ATSplashManager.entrySplashScenario(placementID: _placementId, sceneID: scene);

    ATSplashManager.showSplashAdWithShowConfig(
      placementID: _placementId,
      sceneID: scene,
      showCustomExt: _showCustomExt,
    );

    return TopOnShowResult.success();
  }

  Future<bool> isReady() async {
    return await ATSplashManager.splashReady(placementID: _placementId) == true;
  }

  void _setupListener() {
    ATListenerManager.splashEventHandler.listen((value) {
      switch (value.splashStatus) {
        case SplashStatus.splashDidFailToLoad:
          log("SplashService: loadFailed - ${value.placementID}");
          _emitEvent(TopOnAdEventType.loadFailed, value.placementID, errorMessage: value.requestMessage);
          break;
        case SplashStatus.splashDidFinishLoading:
          log("SplashService: loaded - ${value.placementID}");
          _emitEvent(TopOnAdEventType.loaded, value.placementID);
          break;
        case SplashStatus.splashDidTimeout:
          _emitEvent(TopOnAdEventType.loadFailed, value.placementID, errorMessage: 'Timeout');
          break;
        case SplashStatus.splashDidShowSuccess:
          _emitEvent(TopOnAdEventType.showed, value.placementID, extra: _castExtra(value.extraMap));
          break;
        case SplashStatus.splashDidShowFailed:
          _emitEvent(TopOnAdEventType.showFailed, value.placementID, errorMessage: value.requestMessage);
          break;
        case SplashStatus.splashDidClick:
          _emitEvent(TopOnAdEventType.clicked, value.placementID, extra: _castExtra(value.extraMap));
          break;
        case SplashStatus.splashDidDeepLink:
          _emitEvent(TopOnAdEventType.deepLink, value.placementID, extra: _castExtra(value.extraMap));
          break;
        case SplashStatus.splashDidClose:
          log("SplashService: closed - ${value.placementID}");
          _emitEvent(TopOnAdEventType.closed, value.placementID, extra: _castExtra(value.extraMap));
          // Auto reload after close
          load();
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
      adUnit: TopOnAdUnit.splash,
      placementId: placementId,
      type: type,
      errorMessage: errorMessage,
      extra: extra,
    ));
  }
}
