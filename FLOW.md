# App Flow

```mermaid
flowchart TD
    A[App start: main() -> runApp(MyApp)] --> B[MyApp.initState]
    B --> C[_setListen -> InitManager.initListen]
    B --> D[_setSDK: log + GDPR dialog + channel/custom data]
    D -->|showGDPRConsentDialog()| E[SDK GDPR/UMP flow]
    E -->|consentDismiss| F[initTopon -> preset config -> preload ads]
    F --> G[Preload: Interstitial/Rewarder/Banner/Splash/Native]
    B --> H[MaterialApp routes + initialRoute "/"]
    H --> I["/" route -> MyHome -> TopOnDemoPage]
    I --> J[UI buttons trigger ad managers]
    J --> K[InterstitialManager.startShowInterstitialAd]
    J --> L[RewarderManager.startShowRewardedVideoAd]
    J --> M[SplashManager.startShowSplashAd]
    J --> N[BannerManager.startShowBannerAd]
    J --> O[NativeManager.startShowNativeAd]
    J --> P[InitManager.showDebugUI]
    J --> Q[Navigate to AutomaticPage]

    K --> K1{hasInterstitialAdReady?}
    K1 -->|yes| K2[entryScenario -> getValidAds -> showWithConfig]
    K1 -->|no| K3[checkLoadStatus -> loadInterstitialAd]

    L --> L1{rewardedVideoReady?}
    L1 -->|yes| L2[entryScenario -> getValidAds -> showWithConfig]
    L1 -->|no| L3[checkLoadStatus -> loadRewardedVideo]

    N --> N1{bannerAdReady?}
    N1 -->|yes| N2[entryBannerScenario -> getValidAds -> showSceneBannerInRectangle]
    N1 -->|no| N3[checkLoadStatus -> loadBannerAd]

    M --> M1{splashReady?}
    M1 -->|yes| M2[entrySplashScenario -> getValidAds -> showWithConfig]
    M1 -->|no| M3[checkLoadStatus -> loadSplashAd]

    O --> O1{nativeAdReady?}
    O1 -->|yes| O2[entryNativeScenario -> getValidAds -> fire NativeAdWidgetEvent(getNativeView)]
    O1 -->|no| O3[checkLoadStatus -> loadNativeAd]

    R[EventBus: AdEvent + NativeAdWidgetEvent] --> S[ButtonWithLabel updates status label]
    R --> T[TopOnDemoPage listens -> show/hide native overlay]

    Q --> U[AutomaticPage.onEnter]
    U --> V[start auto-load reward/interstitial + checkReady]
    Q --> W[AutomaticPage.onLeave -> cancel auto-load]

    subgraph SDK_Listeners
      K4[Interstitial SDK callbacks -> AdEvent]
      L4[Rewarded SDK callbacks -> AdEvent]
      N4[Banner SDK callbacks -> AdEvent]
      M4[Splash SDK callbacks -> AdEvent]
      O4[Native SDK callbacks -> AdEvent close/remove]
    end
    K2 --> K4
    L2 --> L4
    N2 --> N4
    M2 --> M4
    O2 --> O4
```
