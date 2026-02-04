import 'dart:async';
import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:secmtp_sdk/at_index.dart';
import '../../domain/models/models.dart';

class NativeService {
  final StreamController<TopOnAdEvent> _eventController;
  TopOnAdsConfig? _config;
  bool _isListenerInitialized = false;
  double _screenWidth = 320;
  double _screenHeight = 640;

  NativeService(this._eventController);

  void initialize(TopOnAdsConfig config, {double screenWidth = 320, double screenHeight = 640}) {
    _config = config;
    _screenWidth = screenWidth;
    _screenHeight = screenHeight;
    if (!_isListenerInitialized) {
      _setupListener();
      _isListenerInitialized = true;
    }
  }

  String get _placementId => _config!.current.getPlacement(TopOnAdUnit.native) ?? '';
  String get _sceneId => _config!.current.getSceneId(TopOnAdUnit.native) ?? '';
  String get _showCustomExt => _config!.current.getShowCustomExt(TopOnAdUnit.native) ?? '';

  Future<void> load() async {
    _emitEvent(TopOnAdEventType.loading, _placementId);

    await ATNativeManager.loadNativeAd(
      placementID: _placementId,
      extraMap: {
        ATCommon.isNativeShow(): false,
        ATCommon.getAdSizeKey(): ATNativeManager.createNativeSubViewAttribute(
          _screenWidth - 100,
          (_screenWidth - 100) / 2,
        ),
        ATNativeManager.isAdaptiveHeight(): false,
      },
    );
  }

  Future<bool> isReady() async {
    return await ATNativeManager.nativeAdReady(placementID: _placementId) == true;
  }

  Widget? getWidget() {
    return PlatformNativeWidget(
      _placementId,
      {
        ATNativeManager.parent(): ATNativeManager.createNativeSubViewAttribute(
          _screenWidth,
          340,
          backgroundColorStr: '#FFFFFF',
        ),
        ATNativeManager.appIcon(): ATNativeManager.createNativeSubViewAttribute(
          50, 50,
          x: 10,
          y: 40,
          backgroundColorStr: 'clearColor',
          cornerRadius: 10,
        ),
        ATNativeManager.mainTitle(): ATNativeManager.createNativeSubViewAttribute(
          _screenWidth - 190, 20,
          x: 70,
          y: 40,
          backgroundColorStr: '#2095F1',
          textSize: 15,
          cornerRadius: 10,
        ),
        ATNativeManager.desc(): ATNativeManager.createNativeSubViewAttribute(
          _screenWidth - 190, 20,
          x: 70,
          y: 70,
          backgroundColorStr: '#2095F1',
          textSize: 15,
          cornerRadius: 10,
        ),
        ATNativeManager.cta(): ATNativeManager.createNativeSubViewAttribute(
          100, 50,
          x: _screenWidth - 110,
          y: 40,
          textSize: 15,
          textColorStr: "#FFFFFF",
          backgroundColorStr: "#2095F1",
          textAlignmentStr: "center",
        ),
        ATNativeManager.mainImage(): ATNativeManager.createNativeSubViewAttribute(
          _screenWidth - 20, _screenWidth * 0.6,
          x: 10,
          y: 100,
          backgroundColorStr: '#00000000',
          cornerRadius: 5,
        ),
        ATNativeManager.dislike(): ATNativeManager.createNativeSubViewAttribute(
          20, 20,
          x: _screenWidth - 30,
          y: 10,
        ),
        ATNativeManager.elementsView(): ATNativeManager.createNativeSubViewAttribute(
          _screenWidth, 25,
          x: 0,
          y: 315,
          textSize: 12,
          textColorStr: "#FFFFFF",
          backgroundColorStr: "#7F000000",
        ),
        "showCustomExt": _showCustomExt,
      },
      sceneID: _sceneId,
    );
  }

  Future<void> remove() async {
    await ATNativeManager.removeNativeAd(placementID: _placementId);
  }

  void _setupListener() {
    ATListenerManager.nativeEventHandler.listen((value) {
      switch (value.nativeStatus) {
        case NativeStatus.nativeAdFailToLoadAD:
          log("NativeService: loadFailed - ${value.placementID}");
          _emitEvent(TopOnAdEventType.loadFailed, value.placementID, errorMessage: value.requestMessage);
          break;
        case NativeStatus.nativeAdDidFinishLoading:
          log("NativeService: loaded - ${value.placementID}");
          _emitEvent(TopOnAdEventType.loaded, value.placementID);
          break;
        case NativeStatus.nativeAdDidClick:
          _emitEvent(TopOnAdEventType.clicked, value.placementID, extra: _castExtra(value.extraMap));
          break;
        case NativeStatus.nativeAdDidDeepLink:
          _emitEvent(TopOnAdEventType.deepLink, value.placementID, extra: _castExtra(value.extraMap));
          break;
        case NativeStatus.nativeAdDidShowNativeAd:
          _emitEvent(TopOnAdEventType.showed, value.placementID, extra: _castExtra(value.extraMap));
          break;
        case NativeStatus.nativeAdDidStartPlayingVideo:
          _emitEvent(TopOnAdEventType.videoStarted, value.placementID, extra: _castExtra(value.extraMap));
          break;
        case NativeStatus.nativeAdDidEndPlayingVideo:
          _emitEvent(TopOnAdEventType.videoEnded, value.placementID, extra: _castExtra(value.extraMap));
          break;
        case NativeStatus.nativeAdDidTapCloseButton:
          log("NativeService: closed - ${value.placementID}");
          _emitEvent(TopOnAdEventType.closed, value.placementID, extra: _castExtra(value.extraMap));
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
      adUnit: TopOnAdUnit.native,
      placementId: placementId,
      type: type,
      errorMessage: errorMessage,
      extra: extra,
    ));
  }
}
