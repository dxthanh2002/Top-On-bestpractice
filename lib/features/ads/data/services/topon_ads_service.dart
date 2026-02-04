import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:secmtp_sdk/at_init.dart';
import 'package:secmtp_sdk/at_listener.dart';
import '../../domain/models/models.dart';
import '../../domain/services/i_ads_service.dart';
import 'rewarded_service.dart';
import 'interstitial_service.dart';
import 'banner_service.dart';
import 'native_service.dart';
import 'splash_service.dart';

class TopOnAdsService implements IAdsService {
  static TopOnAdsService? _instance;
  static TopOnAdsService get instance => _instance ??= TopOnAdsService._();

  TopOnAdsService._();

  final _eventController = StreamController<TopOnAdEvent>.broadcast();
  
  late final RewardedService _rewardedService;
  late final InterstitialService _interstitialService;
  late final BannerService _bannerService;
  late final NativeService _nativeService;
  late final SplashService _splashService;

  TopOnAdsConfig? _config;
  bool _initialized = false;
  StreamSubscription? _gdprSubscription;

  @override
  bool get isInitialized => _initialized;

  @override
  Stream<TopOnAdEvent> get events => _eventController.stream;

  @override
  Future<void> initialize({
    required TopOnAdsConfig config,
    bool enableDebug = false,
    double screenWidth = 320,
    double screenHeight = 640,
  }) async {
    if (_initialized) return;

    _config = config;
    final platformConfig = config.current;

    // Initialize sub-services
    _rewardedService = RewardedService(_eventController);
    _interstitialService = InterstitialService(_eventController);
    _bannerService = BannerService(_eventController);
    _nativeService = NativeService(_eventController);
    _splashService = SplashService(_eventController);

    _rewardedService.initialize(config);
    _interstitialService.initialize(config);
    _bannerService.initialize(config, screenWidth: screenWidth);
    _nativeService.initialize(config, screenWidth: screenWidth, screenHeight: screenHeight);
    _splashService.initialize(config);

    // SDK settings
    if (enableDebug) {
      await ATInitManger.setLogEnabled(logEnabled: true);
    }

    if (config.channel != null) {
      await ATInitManger.setChannelStr(channelStr: config.channel!);
    }

    if (config.subChannel != null) {
      await ATInitManger.setSubChannelStr(subchannelStr: config.subChannel!);
    }

    if (config.customData != null) {
      await ATInitManger.setCustomDataMap(customDataMap: Map<String, Object>.from(config.customData!));
    }

    // Initialize SDK
    await ATInitManger.initAnyThinkSDK(
      appidStr: platformConfig.appId,
      appidkeyStr: platformConfig.appKey,
    );

    _initialized = true;
  }

  Future<void> initializeWithGDPR({
    required TopOnAdsConfig config,
    bool enableDebug = false,
    double screenWidth = 320,
    double screenHeight = 640,
    bool preloadAds = true,
  }) async {
    _config = config;
    final platformConfig = config.current;

    // Initialize sub-services first
    _rewardedService = RewardedService(_eventController);
    _interstitialService = InterstitialService(_eventController);
    _bannerService = BannerService(_eventController);
    _nativeService = NativeService(_eventController);
    _splashService = SplashService(_eventController);

    _rewardedService.initialize(config);
    _interstitialService.initialize(config);
    _bannerService.initialize(config, screenWidth: screenWidth);
    _nativeService.initialize(config, screenWidth: screenWidth, screenHeight: screenHeight);
    _splashService.initialize(config);

    if (enableDebug) {
      await ATInitManger.setLogEnabled(logEnabled: true);
    }

    // Setup GDPR listener
    final completer = Completer<void>();
    _gdprSubscription = ATListenerManager.initEventHandler.listen((value) async {
      if (value.consentDismiss != null) {
        await ATInitManger.initAnyThinkSDK(
          appidStr: platformConfig.appId,
          appidkeyStr: platformConfig.appKey,
        );
        _initialized = true;

        if (preloadAds) {
          preloadAllAds();
        }

        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });

    // Show GDPR dialog
    await ATInitManger.showGDPRConsentDialog();
    
    return completer.future;
  }

  void preloadAllAds() {
    loadRewarded();
    loadInterstitial();
    loadBanner();
    loadNative();
    loadSplash();
  }

  @override
  Future<void> showGDPRConsentDialog() async {
    await ATInitManger.showGDPRConsentDialog();
  }

  @override
  Future<int> getGDPRLevel() async {
    final dynamic level = await ATInitManger.getGDPRLevel();
    if (level is int) return level;
    if (level is String) return int.tryParse(level) ?? 0;
    return 0;
  }

  Future<void> showDebugUI() async {
    final debugKey = _config?.current.debugKey;
    if (debugKey != null && debugKey.isNotEmpty) {
      await ATInitManger.showDebuggerUI(debugKey: debugKey);
    }
  }

  // Rewarded
  @override
  Future<void> loadRewarded({bool auto = false}) => _rewardedService.load(auto: auto);

  @override
  Future<TopOnShowResult> showRewarded({bool auto = false, String? sceneId}) => 
      _rewardedService.show(auto: auto, sceneId: sceneId);

  @override
  bool isRewardedReady({bool auto = false}) {
    // Sync check - for async use isRewardedReadyAsync
    return false; // Will be updated via events
  }

  Future<bool> isRewardedReadyAsync({bool auto = false}) => _rewardedService.isReady(auto: auto);

  // Interstitial
  @override
  Future<void> loadInterstitial({bool auto = false}) => _interstitialService.load(auto: auto);

  @override
  Future<TopOnShowResult> showInterstitial({bool auto = false, String? sceneId}) => 
      _interstitialService.show(auto: auto, sceneId: sceneId);

  @override
  bool isInterstitialReady({bool auto = false}) => false;

  Future<bool> isInterstitialReadyAsync({bool auto = false}) => _interstitialService.isReady(auto: auto);

  // Banner
  @override
  Future<void> loadBanner() => _bannerService.load();

  @override
  Future<void> showBanner({BannerPosition position = BannerPosition.bottom, BannerSize size = BannerSize.standard}) => 
      _bannerService.show(position: position, size: size);

  Future<void> showBannerInRectangle({double x = 0, double y = 200, double width = 400, double height = 500}) =>
      _bannerService.showInRectangle(x: x, y: y, width: width, height: height);

  @override
  Future<void> hideBanner() => _bannerService.hide();

  @override
  Future<void> removeBanner() => _bannerService.remove();

  @override
  bool isBannerReady() => false;

  Future<bool> isBannerReadyAsync() => _bannerService.isReady();

  // Native
  @override
  Future<void> loadNative() => _nativeService.load();

  @override
  Widget? getNativeAdWidget() => _nativeService.getWidget();

  @override
  Future<void> removeNative() => _nativeService.remove();

  @override
  bool isNativeReady() => false;

  Future<bool> isNativeReadyAsync() => _nativeService.isReady();

  // Splash
  @override
  Future<void> loadSplash() => _splashService.load();

  @override
  Future<TopOnShowResult> showSplash({String? sceneId}) => _splashService.show(sceneId: sceneId);

  @override
  bool isSplashReady() => false;

  Future<bool> isSplashReadyAsync() => _splashService.isReady();

  @override
  Future<void> dispose() async {
    await _gdprSubscription?.cancel();
    await _eventController.close();
    _initialized = false;
    _instance = null;
  }
}
