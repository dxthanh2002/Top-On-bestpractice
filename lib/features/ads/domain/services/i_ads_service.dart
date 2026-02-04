import 'package:flutter/widgets.dart';
import '../models/models.dart';

abstract class IAdsService {
  // Lifecycle
  Future<void> initialize({required TopOnAdsConfig config, bool enableDebug});
  Future<void> dispose();
  bool get isInitialized;

  // Events stream (replaces event_bus)
  Stream<TopOnAdEvent> get events;

  // GDPR
  Future<void> showGDPRConsentDialog();
  Future<int> getGDPRLevel();

  // Rewarded Video
  Future<void> loadRewarded({bool auto = false});
  Future<TopOnShowResult> showRewarded({bool auto = false, String? sceneId});
  bool isRewardedReady({bool auto = false});

  // Interstitial
  Future<void> loadInterstitial({bool auto = false});
  Future<TopOnShowResult> showInterstitial({bool auto = false, String? sceneId});
  bool isInterstitialReady({bool auto = false});

  // Banner
  Future<void> loadBanner();
  Future<void> showBanner({BannerPosition position, BannerSize size});
  Future<void> hideBanner();
  Future<void> removeBanner();
  bool isBannerReady();

  // Native
  Future<void> loadNative();
  Widget? getNativeAdWidget();
  Future<void> removeNative();
  bool isNativeReady();

  // Splash
  Future<void> loadSplash();
  Future<TopOnShowResult> showSplash({String? sceneId});
  bool isSplashReady();
}
