import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/repositories/ad_repository.dart';
import '../../domain/models/ad_event.dart';
import '../../domain/models/ad_state.dart';
import '../../domain/models/ad_type.dart';

class HomeViewModel extends ChangeNotifier {
  final AdRepository _adRepository;
  StreamSubscription<AdEvent>? _adEventSubscription;

  HomeViewModel({required AdRepository adRepository}) 
      : _adRepository = adRepository {
    _init();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _init() {
    _adEventSubscription = _adRepository.adEventStream.listen(_onAdEvent);
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _adRepository.initialize();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void _onAdEvent(AdEvent event) {
    notifyListeners();
  }

  // Ad States
  AdState getAdState(AdType type) => _adRepository.getAdState(type);

  bool isAdReady(AdType type) => getAdState(type) == AdState.ready;
  bool isAdLoading(AdType type) => getAdState(type) == AdState.loading;

  // Actions
  Future<void> showInterstitial() async {
    await _adRepository.showAd(AdType.interstitial);
  }

  Future<void> showRewarded() async {
    await _adRepository.showAd(AdType.rewarded);
  }

  Future<void> showBanner() async {
    await _adRepository.showAd(AdType.banner);
  }

  Future<void> showNative() async {
    await _adRepository.loadAd(AdType.native);
  }

  Future<void> showSplash() async {
    await _adRepository.showAd(AdType.splash);
  }

  Future<void> showDebugger() async {
    if (_adRepository is AdRepositoryImpl) {
      await (_adRepository as AdRepositoryImpl).showDebugger();
    }
  }

  @override
  void dispose() {
    _adEventSubscription?.cancel();
    super.dispose();
  }
}
