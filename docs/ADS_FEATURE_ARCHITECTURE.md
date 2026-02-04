# TopOn Ads Feature Module - FFCA Architecture

## Overview

Refactor TopOn/AnyThink SDK integration thành **Feature-First Clean Architecture (FFCA)** module có thể tái sử dụng.

## Target Structure

```
lib/
├── features/
│   └── ads/
│       ├── domain/                    # Business Logic Layer
│       │   ├── models/
│       │   │   ├── ads_config.dart         # TopOnAdsConfig, TopOnPlatformConfig
│       │   │   ├── ad_event.dart           # TopOnAdEvent (thay thế event_bus)
│       │   │   ├── ad_result.dart          # TopOnAdResult, TopOnShowResult
│       │   │   └── ad_unit.dart            # TopOnAdUnit enum
│       │   └── services/
│       │       └── i_ads_service.dart      # IAdsService interface
│       │
│       ├── data/                      # Data/SDK Layer
│       │   ├── data_sources/
│       │   │   └── topon_sdk_source.dart   # Direct SDK wrapper
│       │   ├── services/
│       │   │   ├── rewarded_service.dart
│       │   │   ├── interstitial_service.dart
│       │   │   ├── banner_service.dart
│       │   │   ├── native_service.dart
│       │   │   ├── splash_service.dart
│       │   │   └── topon_ads_service.dart  # Facade implementation
│       │   └── mappers/
│       │       └── event_mapper.dart       # SDK event -> TopOnAdEvent
│       │
│       └── presentation/              # UI Layer
│           ├── controllers/
│           │   └── ads_controller.dart     # ChangeNotifier for state
│           └── widgets/
│               ├── banner_ad_widget.dart
│               └── native_ad_widget.dart
│
├── app/                               # App-specific (demo)
│   ├── ads_config.dart                # App's config (THAY ĐỔI FILE NÀY)
│   └── ...
└── main.dart
```

## Key Design Decisions

### 1. Config Injection (Không hardcode keys)

**Before (hiện tại):**
```dart
// configuration_sdk.dart - HARDCODED
class Configuration {
  static String appidStr = Platform.isIOS ? 'a5b0e8491845b3' : 'a62b013be01931';
  // ...
}
```

**After (FFCA):**
```dart
// features/ads/domain/models/ads_config.dart
class TopOnAdsConfig {
  final TopOnPlatformConfig ios;
  final TopOnPlatformConfig android;
  
  TopOnPlatformConfig get current => Platform.isIOS ? ios : android;
}

// app/ads_config.dart - CHỈ THAY ĐỔI FILE NÀY
const appAdsConfig = TopOnAdsConfig(
  ios: TopOnPlatformConfig(appId: '...', appKey: '...', placements: {...}),
  android: TopOnPlatformConfig(appId: '...', appKey: '...', placements: {...}),
);
```

### 2. Stream Events (Thay thế event_bus)

**Before:**
```dart
EventBusUtil.eventBus.fire(AdEvent(...));
```

**After:**
```dart
class TopOnAdsService {
  final _eventController = StreamController<TopOnAdEvent>.broadcast();
  Stream<TopOnAdEvent> get events => _eventController.stream;
}
```

### 3. Facade Pattern (Một API duy nhất)

**Before:**
```dart
InterstitialManager.startLoadInterstitialAd();
RewarderManager.startShowRewardedVideoAd();
BannerManager.startShowBannerAd();
```

**After:**
```dart
final ads = TopOnAdsService.instance;
await ads.initialize(config: appAdsConfig);
await ads.loadRewarded();
await ads.showRewarded();
```

## API Design

```dart
abstract class IAdsService {
  // Lifecycle
  Future<void> initialize({required TopOnAdsConfig config});
  Future<void> dispose();
  
  // Events
  Stream<TopOnAdEvent> get events;
  
  // Rewarded
  Future<void> loadRewarded({bool auto = false});
  Future<TopOnShowResult> showRewarded({bool auto = false});
  bool isRewardedReady({bool auto = false});
  
  // Interstitial
  Future<void> loadInterstitial({bool auto = false});
  Future<TopOnShowResult> showInterstitial({bool auto = false});
  bool isInterstitialReady({bool auto = false});
  
  // Banner
  Future<void> loadBanner();
  Future<void> showBanner({BannerPosition position});
  Future<void> hideBanner();
  Future<void> removeBanner();
  
  // Native
  Future<void> loadNative();
  Widget getNativeWidget({required NativeAdTemplate template});
  
  // Splash
  Future<void> loadSplash();
  Future<TopOnShowResult> showSplash();
}
```

## Copy to New App - Workflow

1. **Copy folder `features/ads/`** vào project mới
2. **Thêm dependencies** vào `pubspec.yaml`:
   ```yaml
   dependencies:
     secmtp_sdk: ^1.0.8
     provider: ^6.1.2  # optional, for state management
   ```
3. **Tạo config file** `lib/app/ads_config.dart`:
   ```dart
   const appAdsConfig = TopOnAdsConfig(
     ios: TopOnPlatformConfig(
       appId: 'YOUR_IOS_APP_ID',
       appKey: 'YOUR_IOS_APP_KEY',
       placements: {
         TopOnAdUnit.rewarded: 'YOUR_REWARDED_PLACEMENT_ID',
         // ...
       },
     ),
     android: TopOnPlatformConfig(/* ... */),
   );
   ```
4. **Initialize trong main.dart**:
   ```dart
   await TopOnAdsService.instance.initialize(config: appAdsConfig);
   ```

## Dependencies

### Giữ lại:
- `secmtp_sdk: ^1.0.8` - TopOn SDK
- `provider: ^6.1.2` - State management (optional)

### Xóa/Migrate:
- `event_bus: ^2.0.1` → Thay bằng Stream internal

## Migration Notes

| Old Code | New Code |
|----------|----------|
| `Configuration.appidStr` | `config.current.appId` |
| `InterstitialManager.startLoadInterstitialAd()` | `ads.loadInterstitial()` |
| `EventBusUtil.eventBus.fire(AdEvent(...))` | `_eventController.add(TopOnAdEvent(...))` |
| `EventBusUtil.eventBus.listen(...)` | `ads.events.listen(...)` |

## Task Breakdown

| Task | Description | Effort |
|------|-------------|--------|
| bcy.1 | Folder structure | 15m |
| bcy.2 | Domain models & interfaces | 30m |
| bcy.3 | Data services implementation | 1h |
| bcy.4 | TopOnAdsService facade | 45m |
| bcy.5 | Presentation controllers | 30m |
| bcy.6 | Widget wrappers | 30m |
| bcy.7 | Migrate demo app | 1h |
| bcy.8 | Documentation | 30m |

**Total: ~5h**
