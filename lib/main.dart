import 'package:flutter/material.dart';
import 'package:topon.flutter.demo/features/ads/ads.dart';
import 'package:topon.flutter.demo/app/ads_config.dart';
import 'package:topon.flutter.demo/topsize.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initAds();
  }

  Future<void> _initAds() async {
    try {
      final screenWidth = TopSize().getWidth();
      final screenHeight = TopSize().getHeight();

      await TopOnAdsService.instance.initialize(
        config: appAdsConfig,
        enableDebug: true,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
      );

      TopOnAdsService.instance.preloadAllAds();
    } catch (e, stack) {
      debugPrint('_initAds ERROR: $e\n$stack');
    } finally {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TopOn Flutter Demo v2',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: _initialized 
          ? const TopOnDemoPage() 
          : const _LoadingScreen(),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromRGBO(60, 104, 243, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),
            Text(
              'Initializing Ads...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class TopOnDemoPage extends StatefulWidget {
  const TopOnDemoPage({Key? key}) : super(key: key);

  @override
  State<TopOnDemoPage> createState() => _TopOnDemoPageState();
}

class _TopOnDemoPageState extends State<TopOnDemoPage> {
  late final AdsController _adsController;
  Widget? _nativeAdWidget;

  @override
  void initState() {
    super.initState();
    _adsController = AdsController();
    _adsController.addListener(_onAdsStateChanged);
  }

  void _onAdsStateChanged() {
    final lastEvent = _adsController.lastEvent;
    if (lastEvent == null) return;

    if (lastEvent.adUnit == TopOnAdUnit.native) {
      if (lastEvent.type == TopOnAdEventType.loaded) {
        setState(() {
          _nativeAdWidget = TopOnAdsService.instance.getNativeAdWidget();
        });
      } else if (lastEvent.type == TopOnAdEventType.closed) {
        setState(() {
          _nativeAdWidget = null;
        });
        TopOnAdsService.instance.removeNative();
      }
    }
  }

  @override
  void dispose() {
    _adsController.removeListener(_onAdsStateChanged);
    _adsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: const Color.fromRGBO(60, 104, 243, 1),
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'TopOn Flutter Demo v2',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Using Feature Module',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 30),
                _AdButton(
                  controller: _adsController,
                  adUnit: TopOnAdUnit.interstitial,
                  label: 'Show Interstitial',
                  onPressed: () async {
                    final result = await _adsController.showInterstitial();
                    if (!result.success) {
                      await _adsController.loadInterstitial();
                    }
                  },
                ),
                const SizedBox(height: 16),
                _AdButton(
                  controller: _adsController,
                  adUnit: TopOnAdUnit.rewarded,
                  label: 'Show Rewarded',
                  onPressed: () async {
                    final result = await _adsController.showRewarded();
                    if (!result.success) {
                      await _adsController.loadRewarded();
                    }
                  },
                ),
                const SizedBox(height: 16),
                _AdButton(
                  controller: _adsController,
                  adUnit: TopOnAdUnit.splash,
                  label: 'Show Splash',
                  onPressed: () async {
                    final result = await _adsController.showSplash();
                    if (!result.success) {
                      await _adsController.loadSplash();
                    }
                  },
                ),
                const SizedBox(height: 16),
                _AdButton(
                  controller: _adsController,
                  adUnit: TopOnAdUnit.banner,
                  label: 'Show Banner',
                  onPressed: () async {
                    await _adsController.showBanner(position: BannerPosition.bottom);
                  },
                ),
                const SizedBox(height: 16),
                _AdButton(
                  controller: _adsController,
                  adUnit: TopOnAdUnit.native,
                  label: 'Show Native',
                  onPressed: () async {
                    if (_adsController.isNativeReady) {
                      setState(() {
                        _nativeAdWidget = TopOnAdsService.instance.getNativeAdWidget();
                      });
                    } else {
                      await _adsController.loadNative();
                    }
                  },
                ),
                const SizedBox(height: 16),
                _SimpleButton(
                  label: 'Hide Banner',
                  onPressed: () => _adsController.hideBanner(),
                ),
                const SizedBox(height: 16),
                _SimpleButton(
                  label: 'Mediation Debugger',
                  onPressed: () => TopOnAdsService.instance.showDebugUI(),
                ),
                const SizedBox(height: 16),
                _SimpleButton(
                  label: 'Auto Load Demo',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AutoLoadDemoPage()),
                  ),
                ),
              ],
            ),
          ),
          if (_nativeAdWidget != null)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {}, // Prevent tap through
                child: Container(
                  color: Colors.black54,
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 340,
                      child: _nativeAdWidget,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AdButton extends StatelessWidget {
  final AdsController controller;
  final TopOnAdUnit adUnit;
  final String label;
  final VoidCallback onPressed;

  const _AdButton({
    required this.controller,
    required this.adUnit,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.getState(adUnit);
        final statusText = _getStatusText(state);
        final statusColor = _getStatusColor(state);

        return SizedBox(
          width: 280,
          height: 48,
          child: ElevatedButton(
            onPressed: state == AdState.loading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state == AdState.loading)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                Text(label),
                if (statusText.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _getStatusText(AdState state) {
    switch (state) {
      case AdState.loading:
        return '';
      case AdState.ready:
        return 'Ready';
      case AdState.error:
        return 'Failed';
      case AdState.showing:
        return 'Showing';
      default:
        return '';
    }
  }

  Color _getStatusColor(AdState state) {
    switch (state) {
      case AdState.ready:
        return Colors.green;
      case AdState.error:
        return Colors.red;
      case AdState.showing:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class _SimpleButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _SimpleButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label),
      ),
    );
  }
}

class AutoLoadDemoPage extends StatefulWidget {
  const AutoLoadDemoPage({Key? key}) : super(key: key);

  @override
  State<AutoLoadDemoPage> createState() => _AutoLoadDemoPageState();
}

class _AutoLoadDemoPageState extends State<AutoLoadDemoPage> {
  late final AdsController _adsController;

  @override
  void initState() {
    super.initState();
    _adsController = AdsController();
    _startAutoLoad();
  }

  void _startAutoLoad() async {
    await _adsController.loadRewarded(auto: true);
    await _adsController.loadInterstitial(auto: true);
  }

  @override
  void dispose() {
    _adsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Load Demo'),
        backgroundColor: const Color.fromRGBO(60, 104, 243, 1),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: const Color.fromRGBO(60, 104, 243, 1),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Auto Load Ads Demo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            _AdButton(
              controller: _adsController,
              adUnit: TopOnAdUnit.rewardedAuto,
              label: 'Auto Rewarded',
              onPressed: () => _adsController.showRewarded(auto: true),
            ),
            const SizedBox(height: 16),
            _AdButton(
              controller: _adsController,
              adUnit: TopOnAdUnit.interstitialAuto,
              label: 'Auto Interstitial',
              onPressed: () => _adsController.showInterstitial(auto: true),
            ),
          ],
        ),
      ),
    );
  }
}
