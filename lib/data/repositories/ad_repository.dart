import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:secmtp_sdk/at_index.dart';
import '../../config/ad_configuration.dart';
import '../../domain/models/ad_event.dart';
import '../../domain/models/ad_state.dart';
import '../../domain/models/ad_type.dart';
import '../services/ad_service.dart';

abstract class AdRepository {
  Future<void> initialize();
  Future<void> loadAd(AdType type);
  Future<void> showAd(AdType type);
  Future<bool> isAdReady(AdType type);
  Stream<AdEvent> get adEventStream;
  AdState getAdState(AdType type);
}

class AdRepositoryImpl extends ChangeNotifier implements AdRepository {
  final AdService _adService;
  
  final Map<AdType, AdState> _adStates = {
    AdType.interstitial: AdState.idle,
    AdType.rewarded: AdState.idle,
    AdType.banner: AdState.idle,
    AdType.native: AdState.idle,
    AdType.splash: AdState.idle,
  };

  final StreamController<AdEvent> _adEventController = StreamController<AdEvent>.broadcast();
  
  bool _isInitialized = false;
  final List<StreamSubscription> _subscriptions = [];

  AdRepositoryImpl({required AdService adService}) : _adService = adService;

  @override
  Stream<AdEvent> get adEventStream => _adEventController.stream;

  @override
  AdState getAdState(AdType type) => _adStates[type] ?? AdState.idle;

  void _updateState(AdType type, AdState state) {
    _adStates[type] = state;
    notifyListeners();
  }

  String _getPlacementId(AdType type) {
    switch (type) {
      case AdType.interstitial:
        return AdConfiguration.interstitialPlacementId;
      case AdType.rewarded:
        return AdConfiguration.rewardedPlacementId;
      case AdType.banner:
        return AdConfiguration.bannerPlacementId;
      case AdType.native:
        return AdConfiguration.nativePlacementId;
      case AdType.splash:
        return AdConfiguration.splashPlacementId;
    }
  }

  String _getSceneId(AdType type) {
    switch (type) {
      case AdType.interstitial:
        return AdConfiguration.interstitialSceneId;
      case AdType.rewarded:
        return AdConfiguration.rewardedSceneId;
      case AdType.banner:
        return AdConfiguration.bannerSceneId;
      case AdType.native:
        return AdConfiguration.nativeSceneId;
      case AdType.splash:
        return AdConfiguration.splashSceneId;
    }
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _adService.setLogEnabled(enabled: true);
    await _adService.setChannel('test_channel');
    await _adService.setSubChannel('test_subchannel');
    
    _setupEventListeners();
    
    await _adService.showGdprConsentDialog();
  }

  void _setupEventListeners() {
    // Init events
    _subscriptions.add(_adService.initEventStream.listen((value) async {
      if (value.consentDismiss != null) {
        await _adService.initSdk();
        _isInitialized = true;
        _preloadAds();
      }
    }));

    // Interstitial events
    _subscriptions.add(_adService.interstitialEventStream.listen((value) {
      _handleInterstitialEvent(value);
    }));

    // Rewarded events
    _subscriptions.add(_adService.rewardedEventStream.listen((value) {
      _handleRewardedEvent(value);
    }));

    // Banner events
    _subscriptions.add(_adService.bannerEventStream.listen((value) {
      _handleBannerEvent(value);
    }));

    // Native events
    _subscriptions.add(_adService.nativeEventStream.listen((value) {
      _handleNativeEvent(value);
    }));

    // Splash events
    _subscriptions.add(_adService.splashEventStream.listen((value) {
      _handleSplashEvent(value);
    }));
  }

  void _handleInterstitialEvent(dynamic value) {
    final placementId = value.placementID;
    log('Interstitial event: ${value.interstatus} for $placementId');

    switch (value.interstatus) {
      case InterstitialStatus.interstitialAdFailToLoadAD:
        _updateState(AdType.interstitial, AdState.failed);
        _emitEvent(AdType.interstitial, AdState.failed, placementId, 
            errorMessage: value.requestMessage);
        break;
      case InterstitialStatus.interstitialAdDidFinishLoading:
        _checkAndUpdateReady(AdType.interstitial, placementId);
        break;
      case InterstitialStatus.interstitialDidShowSucceed:
        _updateState(AdType.interstitial, AdState.showing);
        _emitEvent(AdType.interstitial, AdState.showing, placementId);
        break;
      case InterstitialStatus.interstitialAdDidClose:
        _updateState(AdType.interstitial, AdState.closed);
        _emitEvent(AdType.interstitial, AdState.closed, placementId);
        _checkAndUpdateReady(AdType.interstitial, placementId);
        break;
      default:
        break;
    }
  }

  void _handleRewardedEvent(dynamic value) {
    final placementId = value.placementID;
    log('Rewarded event: ${value.rewardStatus} for $placementId');

    switch (value.rewardStatus) {
      case RewardedStatus.rewardedVideoDidFailToLoad:
        _updateState(AdType.rewarded, AdState.failed);
        _emitEvent(AdType.rewarded, AdState.failed, placementId,
            errorMessage: value.requestMessage);
        break;
      case RewardedStatus.rewardedVideoDidFinishLoading:
        _checkAndUpdateReady(AdType.rewarded, placementId);
        break;
      case RewardedStatus.rewardedVideoDidStartPlaying:
        _updateState(AdType.rewarded, AdState.showing);
        _emitEvent(AdType.rewarded, AdState.showing, placementId);
        break;
      case RewardedStatus.rewardedVideoDidClose:
        _updateState(AdType.rewarded, AdState.closed);
        _emitEvent(AdType.rewarded, AdState.closed, placementId);
        _checkAndUpdateReady(AdType.rewarded, placementId);
        break;
      default:
        break;
    }
  }

  void _handleBannerEvent(dynamic value) {
    final placementId = value.placementID;
    log('Banner event: ${value.bannerStatus} for $placementId');

    switch (value.bannerStatus) {
      case BannerStatus.bannerAdFailToLoadAD:
        _updateState(AdType.banner, AdState.failed);
        _emitEvent(AdType.banner, AdState.failed, placementId);
        break;
      case BannerStatus.bannerAdDidFinishLoading:
        _updateState(AdType.banner, AdState.ready);
        _emitEvent(AdType.banner, AdState.ready, placementId);
        break;
      case BannerStatus.bannerAdTapCloseButton:
        _updateState(AdType.banner, AdState.closed);
        _emitEvent(AdType.banner, AdState.closed, placementId);
        break;
      default:
        break;
    }
  }

  void _handleNativeEvent(dynamic value) {
    final placementId = value.placementID;
    log('Native event: ${value.nativeStatus} for $placementId');

    switch (value.nativeStatus) {
      case NativeStatus.nativeAdFailToLoadAD:
        _updateState(AdType.native, AdState.failed);
        _emitEvent(AdType.native, AdState.failed, placementId);
        break;
      case NativeStatus.nativeAdDidFinishLoading:
        _updateState(AdType.native, AdState.ready);
        _emitEvent(AdType.native, AdState.ready, placementId);
        break;
      case NativeStatus.nativeAdDidTapCloseButton:
        _updateState(AdType.native, AdState.closed);
        _emitEvent(AdType.native, AdState.closed, placementId);
        break;
      default:
        break;
    }
  }

  void _handleSplashEvent(dynamic value) {
    final placementId = value.placementID;
    log('Splash event: ${value.splashStatus} for $placementId');

    switch (value.splashStatus) {
      case SplashStatus.splashDidFailToLoad:
        _updateState(AdType.splash, AdState.failed);
        _emitEvent(AdType.splash, AdState.failed, placementId);
        break;
      case SplashStatus.splashDidFinishLoading:
        _checkAndUpdateReady(AdType.splash, placementId);
        break;
      case SplashStatus.splashDidShowSuccess:
        _updateState(AdType.splash, AdState.showing);
        _emitEvent(AdType.splash, AdState.showing, placementId);
        break;
      case SplashStatus.splashDidClose:
        _updateState(AdType.splash, AdState.closed);
        _emitEvent(AdType.splash, AdState.closed, placementId);
        break;
      default:
        break;
    }
  }

  Future<void> _checkAndUpdateReady(AdType type, String placementId) async {
    final isReady = await isAdReady(type);
    if (isReady) {
      _updateState(type, AdState.ready);
      _emitEvent(type, AdState.ready, placementId);
    }
  }

  void _emitEvent(AdType type, AdState state, String placementId, {String? errorMessage}) {
    _adEventController.add(AdEvent(
      placementId: placementId,
      state: state,
      type: type,
      errorMessage: errorMessage,
    ));
  }

  void _preloadAds() {
    loadAd(AdType.interstitial);
    loadAd(AdType.rewarded);
    loadAd(AdType.banner);
    loadAd(AdType.splash);
    loadAd(AdType.native);
  }

  @override
  Future<void> loadAd(AdType type) async {
    final placementId = _getPlacementId(type);
    _updateState(type, AdState.loading);
    _emitEvent(type, AdState.loading, placementId);

    switch (type) {
      case AdType.interstitial:
        await _adService.loadInterstitial(placementId);
        break;
      case AdType.rewarded:
        await _adService.loadRewarded(placementId);
        break;
      case AdType.banner:
        await _adService.loadBanner(placementId);
        break;
      case AdType.native:
        await _adService.loadNative(placementId);
        break;
      case AdType.splash:
        await _adService.loadSplash(placementId);
        break;
    }
  }

  @override
  Future<void> showAd(AdType type) async {
    final placementId = _getPlacementId(type);
    final sceneId = _getSceneId(type);
    final isReady = await isAdReady(type);

    if (!isReady) {
      await loadAd(type);
      return;
    }

    switch (type) {
      case AdType.interstitial:
        await _adService.showInterstitial(placementId, 
            sceneId: sceneId, customExt: AdConfiguration.interstitialShowCustomExt);
        break;
      case AdType.rewarded:
        await _adService.showRewarded(placementId, 
            sceneId: sceneId, customExt: AdConfiguration.rewardedShowCustomExt);
        break;
      case AdType.splash:
        await _adService.showSplash(placementId, 
            sceneId: sceneId, customExt: AdConfiguration.splashShowCustomExt);
        break;
      case AdType.banner:
      case AdType.native:
        break;
    }
  }

  @override
  Future<bool> isAdReady(AdType type) async {
    final placementId = _getPlacementId(type);

    switch (type) {
      case AdType.interstitial:
        return await _adService.isInterstitialReady(placementId);
      case AdType.rewarded:
        return await _adService.isRewardedReady(placementId);
      case AdType.banner:
        return await _adService.isBannerReady(placementId);
      case AdType.native:
        return await _adService.isNativeReady(placementId);
      case AdType.splash:
        return await _adService.isSplashReady(placementId);
    }
  }

  Future<void> showDebugger() async {
    await _adService.showDebuggerUi();
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _adEventController.close();
    super.dispose();
  }
}
