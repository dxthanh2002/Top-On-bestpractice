import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/models/models.dart';
import '../../data/services/topon_ads_service.dart';

class AdsController extends ChangeNotifier {
  final TopOnAdsService _adsService;
  StreamSubscription<TopOnAdEvent>? _eventSubscription;

  // State
  final Map<TopOnAdUnit, AdState> _adStates = {};
  TopOnAdEvent? _lastEvent;

  AdsController({TopOnAdsService? adsService}) 
      : _adsService = adsService ?? TopOnAdsService.instance {
    _initStates();
    _subscribeToEvents();
  }

  void _initStates() {
    for (final unit in TopOnAdUnit.values) {
      _adStates[unit] = AdState.idle;
    }
  }

  void _subscribeToEvents() {
    _eventSubscription = _adsService.events.listen(_handleEvent);
  }

  void _handleEvent(TopOnAdEvent event) {
    _lastEvent = event;
    
    switch (event.type) {
      case TopOnAdEventType.loading:
        _adStates[event.adUnit] = AdState.loading;
        break;
      case TopOnAdEventType.loaded:
        _adStates[event.adUnit] = AdState.ready;
        break;
      case TopOnAdEventType.loadFailed:
        _adStates[event.adUnit] = AdState.error;
        break;
      case TopOnAdEventType.showed:
        _adStates[event.adUnit] = AdState.showing;
        break;
      case TopOnAdEventType.closed:
        _adStates[event.adUnit] = AdState.idle;
        break;
      default:
        break;
    }

    notifyListeners();
  }

  // Getters
  AdState getState(TopOnAdUnit unit) => _adStates[unit] ?? AdState.idle;
  bool isLoading(TopOnAdUnit unit) => getState(unit) == AdState.loading;
  bool isReady(TopOnAdUnit unit) => getState(unit) == AdState.ready;
  bool isError(TopOnAdUnit unit) => getState(unit) == AdState.error;
  TopOnAdEvent? get lastEvent => _lastEvent;

  // Convenience getters
  bool get isRewardedReady => isReady(TopOnAdUnit.rewarded);
  bool get isRewardedAutoReady => isReady(TopOnAdUnit.rewardedAuto);
  bool get isInterstitialReady => isReady(TopOnAdUnit.interstitial);
  bool get isInterstitialAutoReady => isReady(TopOnAdUnit.interstitialAuto);
  bool get isBannerReady => isReady(TopOnAdUnit.banner);
  bool get isNativeReady => isReady(TopOnAdUnit.native);
  bool get isSplashReady => isReady(TopOnAdUnit.splash);

  // Actions - Rewarded
  Future<void> loadRewarded({bool auto = false}) async {
    await _adsService.loadRewarded(auto: auto);
  }

  Future<TopOnShowResult> showRewarded({bool auto = false}) async {
    return await _adsService.showRewarded(auto: auto);
  }

  // Actions - Interstitial
  Future<void> loadInterstitial({bool auto = false}) async {
    await _adsService.loadInterstitial(auto: auto);
  }

  Future<TopOnShowResult> showInterstitial({bool auto = false}) async {
    return await _adsService.showInterstitial(auto: auto);
  }

  // Actions - Banner
  Future<void> loadBanner() async {
    await _adsService.loadBanner();
  }

  Future<void> showBanner({BannerPosition position = BannerPosition.bottom}) async {
    await _adsService.showBanner(position: position);
  }

  Future<void> hideBanner() async {
    await _adsService.hideBanner();
  }

  Future<void> removeBanner() async {
    await _adsService.removeBanner();
  }

  // Actions - Native
  Future<void> loadNative() async {
    await _adsService.loadNative();
  }

  // Actions - Splash
  Future<void> loadSplash() async {
    await _adsService.loadSplash();
  }

  Future<TopOnShowResult> showSplash() async {
    return await _adsService.showSplash();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}

enum AdState {
  idle,
  loading,
  ready,
  showing,
  error,
}
