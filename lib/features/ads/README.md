# TopOn Ads Feature Module

Reusable TopOn/AnyThink SDK integration following Feature-First Clean Architecture (FFCA).

## Quick Start

### 1. Copy to Your Project

Copy the entire `features/ads/` folder to your project's `lib/features/` directory.

### 2. Add Dependencies

```yaml
# pubspec.yaml
dependencies:
  secmtp_sdk: ^1.0.8
  provider: ^6.1.2  # Optional, for state management
```

### 3. Create Your Config

Create `lib/app/ads_config.dart`:

```dart
import '../features/ads/ads.dart';

const appAdsConfig = TopOnAdsConfig(
  ios: TopOnPlatformConfig(
    appId: 'YOUR_IOS_APP_ID',
    appKey: 'YOUR_IOS_APP_KEY',
    placements: {
      TopOnAdUnit.rewarded: 'YOUR_REWARDED_PLACEMENT_ID',
      TopOnAdUnit.interstitial: 'YOUR_INTERSTITIAL_PLACEMENT_ID',
      TopOnAdUnit.banner: 'YOUR_BANNER_PLACEMENT_ID',
      TopOnAdUnit.native: 'YOUR_NATIVE_PLACEMENT_ID',
      TopOnAdUnit.splash: 'YOUR_SPLASH_PLACEMENT_ID',
    },
  ),
  android: TopOnPlatformConfig(
    appId: 'YOUR_ANDROID_APP_ID',
    appKey: 'YOUR_ANDROID_APP_KEY',
    placements: {/* ... */},
  ),
);
```

### 4. Initialize

```dart
import 'package:your_app/features/ads/ads.dart';
import 'package:your_app/app/ads_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Option 1: Simple init
  await TopOnAdsService.instance.initialize(config: appAdsConfig);
  
  // Option 2: With GDPR flow
  await TopOnAdsService.instance.initializeWithGDPR(
    config: appAdsConfig,
    preloadAds: true,
  );
  
  runApp(MyApp());
}
```

## Usage Examples

### Show Rewarded Video

```dart
final ads = TopOnAdsService.instance;

// Load
await ads.loadRewarded();

// Listen for ready
ads.events.listen((event) {
  if (event.adUnit == TopOnAdUnit.rewarded && event.type == TopOnAdEventType.loaded) {
    print('Rewarded ad ready!');
  }
  if (event.type == TopOnAdEventType.rewardEarned) {
    print('User earned reward!');
  }
});

// Show
final result = await ads.showRewarded();
if (result.success) {
  // Ad shown successfully
}
```

### Show Interstitial

```dart
await ads.loadInterstitial();
await ads.showInterstitial();
```

### Show Banner

```dart
await ads.loadBanner();
await ads.showBanner(position: BannerPosition.bottom);

// Or in specific rectangle
await ads.showBannerInRectangle(x: 0, y: 100, width: 320, height: 50);

// Hide/Remove
await ads.hideBanner();
await ads.removeBanner();
```

### Native Ad Widget

```dart
// In your widget tree
NativeAdWidget(
  height: 340,
  placeholder: Center(child: CircularProgressIndicator()),
  errorWidget: Center(child: Text('Failed to load ad')),
)
```

### With AdsController (Recommended for UI)

```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final _adsController = AdsController();

  @override
  void initState() {
    super.initState();
    _adsController.loadRewarded();
  }

  @override
  void dispose() {
    _adsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _adsController,
      builder: (context, _) {
        return ElevatedButton(
          onPressed: _adsController.isRewardedReady 
              ? () => _adsController.showRewarded()
              : null,
          child: Text(_adsController.isRewardedReady ? 'Watch Ad' : 'Loading...'),
        );
      },
    );
  }
}
```

## API Reference

### TopOnAdsService

| Method | Description |
|--------|-------------|
| `initialize(config)` | Initialize SDK with config |
| `initializeWithGDPR(config)` | Initialize with GDPR consent flow |
| `events` | Stream of ad events |
| `loadRewarded({auto})` | Load rewarded video |
| `showRewarded({auto})` | Show rewarded video |
| `loadInterstitial({auto})` | Load interstitial |
| `showInterstitial({auto})` | Show interstitial |
| `loadBanner()` | Load banner |
| `showBanner({position})` | Show banner |
| `hideBanner()` | Hide banner |
| `removeBanner()` | Remove banner |
| `loadNative()` | Load native ad |
| `getNativeAdWidget()` | Get native ad widget |
| `loadSplash()` | Load splash |
| `showSplash()` | Show splash |

### TopOnAdEvent

| Property | Type | Description |
|----------|------|-------------|
| `adUnit` | `TopOnAdUnit` | Which ad type |
| `placementId` | `String` | Placement ID |
| `type` | `TopOnAdEventType` | Event type |
| `errorMessage` | `String?` | Error details |
| `extra` | `Map?` | Additional data |

### TopOnAdEventType

- `loading` - Ad is loading
- `loaded` - Ad loaded successfully
- `loadFailed` - Failed to load
- `showed` - Ad displayed
- `showFailed` - Failed to show
- `clicked` - User clicked ad
- `closed` - Ad closed
- `rewardEarned` - User earned reward
- `videoStarted` / `videoEnded` - Video playback

## Folder Structure

```
features/ads/
├── domain/                 # Business logic
│   ├── models/            # Data models
│   └── services/          # Interfaces
├── data/                  # SDK integration
│   └── services/          # Service implementations
├── presentation/          # UI layer
│   ├── controllers/       # State management
│   └── widgets/           # Reusable widgets
├── ads.dart               # Public exports
└── README.md              # This file
```

## Platform Setup

Don't forget to configure native SDKs:

### Android
- Add TopOn SDK to `android/app/build.gradle`
- Configure `AndroidManifest.xml`

### iOS
- Add TopOn SDK via CocoaPods
- Configure `Info.plist`

See [TopOn Documentation](https://docs.toponad.com/) for details.
