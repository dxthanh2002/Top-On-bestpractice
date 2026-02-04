import '../features/ads/ads.dart';

/// App-specific TopOn Ads Configuration
/// 
/// ⚠️ THAY ĐỔI FILE NÀY KHI COPY SANG APP MỚI ⚠️
/// 
/// Chỉ cần thay đổi các giá trị dưới đây để config cho app của bạn.
/// Lấy các giá trị này từ TopOn/Taku dashboard.
const appAdsConfig = TopOnAdsConfig(
  ios: TopOnPlatformConfig(
    appId: 'a5b0e8491845b3',
    appKey: '7eae0567827cfe2b22874061763f30c9',
    debugKey: '99117a5bf26ca7a1923b3fed8e5371d3ab68c25c',
    placements: {
      TopOnAdUnit.rewarded: 'b5b72b21184aa8',
      TopOnAdUnit.rewardedAuto: 'b62fe22b92bb41',
      TopOnAdUnit.interstitial: 'b5bacad26a752a',
      TopOnAdUnit.interstitialAuto: 'b62fe22e06dd64',
      TopOnAdUnit.banner: 'b5bacaccb61c29',
      TopOnAdUnit.native: 'b5bacac5f73476',
      TopOnAdUnit.splash: 'b5c22f0e5cc7a0',
    },
    sceneIds: {
      TopOnAdUnit.rewarded: 'f5e54970dc84e6',
      TopOnAdUnit.rewardedAuto: 'f5e54970dc84e6',
      TopOnAdUnit.interstitial: 'f5e549727efc49',
      TopOnAdUnit.interstitialAuto: 'f5e549727efc49',
      TopOnAdUnit.banner: 'f600938d045dd3',
      TopOnAdUnit.native: 'f600938967feb5',
      TopOnAdUnit.splash: 'f5e549727efc49',
    },
    showCustomExts: {
      TopOnAdUnit.rewarded: 'RewardedShowCustomExt',
      TopOnAdUnit.interstitial: 'InterstitialShowCustomExt',
      TopOnAdUnit.banner: 'BannerShowCustomExt',
      TopOnAdUnit.native: 'NativeShowCustomExt',
      TopOnAdUnit.splash: 'SplashShowCustomExt',
    },
  ),
  android: TopOnPlatformConfig(
    appId: 'a62b013be01931',
    appKey: 'c3d0d2a9a9d451b07e62b509659f7c97',
    placements: {
      TopOnAdUnit.rewarded: 'b62ecb800e1f84',
      TopOnAdUnit.rewardedAuto: 'b62ecb800e1f84',
      TopOnAdUnit.interstitial: 'b62b028b61c800',
      TopOnAdUnit.interstitialAuto: 'b62b028b61c800',
      TopOnAdUnit.banner: 'b62b01a36e4572',
      TopOnAdUnit.native: 'b6305efb12d408',
      TopOnAdUnit.splash: 'b62b0272f8762f',
    },
    sceneIds: {},
    showCustomExts: {
      TopOnAdUnit.rewarded: 'RewardedShowCustomExt',
      TopOnAdUnit.interstitial: 'InterstitialShowCustomExt',
      TopOnAdUnit.banner: 'BannerShowCustomExt',
      TopOnAdUnit.native: 'NativeShowCustomExt',
      TopOnAdUnit.splash: 'SplashShowCustomExt',
    },
  ),
  channel: 'default',
);
