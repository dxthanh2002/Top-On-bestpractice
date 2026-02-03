import 'dart:io';

class AdConfiguration {
  static String get appId => Platform.isIOS ? 'a5b0e8491845b3' : 'a62b013be01931';

  static String get appKey => Platform.isIOS
      ? '7eae0567827cfe2b22874061763f30c9'
      : 'c3d0d2a9a9d451b07e62b509659f7c97';

  static String get debugKey =>
      Platform.isIOS ? '99117a5bf26ca7a1923b3fed8e5371d3ab68c25c' : '';

  // Placement IDs
  static String get rewardedPlacementId =>
      Platform.isIOS ? 'b5b72b21184aa8' : 'b62ecb800e1f84';

  static String get interstitialPlacementId =>
      Platform.isIOS ? 'b5bacad26a752a' : 'b62b028b61c800';

  static String get bannerPlacementId =>
      Platform.isIOS ? 'b5bacaccb61c29' : 'b62b01a36e4572';

  static String get nativePlacementId =>
      Platform.isIOS ? 'b5bacac5f73476' : 'b6305efb12d408';

  static String get splashPlacementId =>
      Platform.isIOS ? 'b5c22f0e5cc7a0' : 'b62b0272f8762f';

  // Scene IDs
  static String get rewardedSceneId => Platform.isIOS ? 'f5e54970dc84e6' : '';
  static String get interstitialSceneId => Platform.isIOS ? 'f5e549727efc49' : '';
  static String get nativeSceneId => Platform.isIOS ? 'f600938967feb5' : '';
  static String get bannerSceneId => Platform.isIOS ? 'f600938d045dd3' : '';
  static String get splashSceneId => Platform.isIOS ? 'f5e549727efc49' : '';

  // Show custom ext
  static const String rewardedShowCustomExt = 'RewardedShowCustomExt';
  static const String interstitialShowCustomExt = 'InterstitialShowCustomExt';
  static const String splashShowCustomExt = 'SplashShowCustomExt';
  static const String bannerShowCustomExt = 'BannerShowCustomExt';
  static const String nativeShowCustomExt = 'NativeShowCustomExt';
}
