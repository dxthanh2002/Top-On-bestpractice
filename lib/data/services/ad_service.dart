import 'dart:async';
import 'package:secmtp_sdk/at_index.dart';
import '../../config/ad_configuration.dart';

class AdService {
  // SDK Initialization
  Future<void> setLogEnabled({bool enabled = true}) async {
    await ATInitManger.setLogEnabled(logEnabled: enabled);
  }

  Future<void> initSdk() async {
    await ATInitManger.initAnyThinkSDK(
      appidStr: AdConfiguration.appId,
      appidkeyStr: AdConfiguration.appKey,
    );
  }

  Future<void> showGdprConsentDialog() async {
    await ATInitManger.showGDPRConsentDialog();
  }

  Future<dynamic> getGdprLevel() async {
    return await ATInitManger.getGDPRLevel();
  }

  Future<void> showDebuggerUi() async {
    await ATInitManger.showDebuggerUI(debugKey: AdConfiguration.debugKey);
  }

  Future<void> setChannel(String channel) async {
    await ATInitManger.setChannelStr(channelStr: channel);
  }

  Future<void> setSubChannel(String subChannel) async {
    await ATInitManger.setSubChannelStr(subchannelStr: subChannel);
  }

  Future<void> setCustomData(Map<String, String> data) async {
    await ATInitManger.setCustomDataMap(customDataMap: data);
  }

  // Interstitial Ad
  Future<void> loadInterstitial(String placementId) async {
    await ATInterstitialManager.loadInterstitialAd(
      placementID: placementId,
      extraMap: {},
    );
  }

  Future<bool> isInterstitialReady(String placementId) async {
    return await ATInterstitialManager.hasInterstitialAdReady(
      placementID: placementId,
    );
  }

  Future<void> showInterstitial(String placementId, {String? sceneId, String? customExt}) async {
    await ATInterstitialManager.showInterstitialAdWithShowConfig(
      placementID: placementId,
      sceneID: sceneId ?? '',
      showCustomExt: customExt ?? '',
    );
  }

  Future<dynamic> checkInterstitialLoadStatus(String placementId) async {
    return await ATInterstitialManager.checkInterstitialLoadStatus(
      placementID: placementId,
    );
  }

  // Rewarded Ad
  Future<void> loadRewarded(String placementId, {Map<String, String>? extraMap}) async {
    await ATRewardedManager.loadRewardedVideo(
      placementID: placementId,
      extraMap: extraMap ?? {},
    );
  }

  Future<bool> isRewardedReady(String placementId) async {
    return await ATRewardedManager.rewardedVideoReady(
      placementID: placementId,
    );
  }

  Future<void> showRewarded(String placementId, {String? sceneId, String? customExt}) async {
    await ATRewardedManager.showRewardedVideoWithShowConfig(
      placementID: placementId,
      sceneID: sceneId ?? '',
      showCustomExt: customExt ?? '',
    );
  }

  Future<dynamic> checkRewardedLoadStatus(String placementId) async {
    return await ATRewardedManager.checkRewardedVideoLoadStatus(
      placementID: placementId,
    );
  }

  // Banner Ad
  Future<void> loadBanner(String placementId, {Map<String, dynamic>? extraMap}) async {
    await ATBannerManager.loadBannerAd(
      placementID: placementId,
      extraMap: extraMap ?? {},
    );
  }

  Future<bool> isBannerReady(String placementId) async {
    return await ATBannerManager.bannerAdReady(
      placementID: placementId,
    );
  }

  // Native Ad
  Future<void> loadNative(String placementId, {Map<String, dynamic>? extraMap}) async {
    await ATNativeManager.loadNativeAd(
      placementID: placementId,
      extraMap: extraMap ?? {},
    );
  }

  Future<bool> isNativeReady(String placementId) async {
    return await ATNativeManager.nativeAdReady(
      placementID: placementId,
    );
  }

  // Splash Ad
  Future<void> loadSplash(String placementId, {Map<String, dynamic>? extraMap}) async {
    await ATSplashManager.loadSplash(
      placementID: placementId,
      extraMap: extraMap ?? {},
    );
  }

  Future<bool> isSplashReady(String placementId) async {
    return await ATSplashManager.splashReady(
      placementID: placementId,
    );
  }

  Future<void> showSplash(String placementId, {String? sceneId, String? customExt}) async {
    await ATSplashManager.showSplashAdWithShowConfig(
      placementID: placementId,
      sceneID: sceneId ?? '',
      showCustomExt: customExt ?? '',
    );
  }

  // Event Streams
  Stream<dynamic> get initEventStream => ATListenerManager.initEventHandler;
  Stream<dynamic> get interstitialEventStream => ATListenerManager.interstitialEventHandler;
  Stream<dynamic> get rewardedEventStream => ATListenerManager.rewardedVideoEventHandler;
  Stream<dynamic> get bannerEventStream => ATListenerManager.bannerEventHandler;
  Stream<dynamic> get nativeEventStream => ATListenerManager.nativeEventHandler;
  Stream<dynamic> get splashEventStream => ATListenerManager.splashEventHandler;
}
