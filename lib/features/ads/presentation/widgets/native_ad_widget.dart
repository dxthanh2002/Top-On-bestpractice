import 'package:flutter/material.dart';
import '../../data/services/topon_ads_service.dart';
import '../../domain/models/models.dart';
import '../controllers/ads_controller.dart';

class NativeAdWidget extends StatefulWidget {
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  final AdsController? controller;

  const NativeAdWidget({
    Key? key,
    this.height = 340,
    this.placeholder,
    this.errorWidget,
    this.controller,
  }) : super(key: key);

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  late final AdsController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? AdsController();
    _controller.addListener(_onStateChanged);
    _loadAd();
  }

  void _loadAd() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    await _controller.loadNative();
  }

  void _onStateChanged() {
    if (!mounted) return;

    final state = _controller.getState(TopOnAdUnit.native);
    setState(() {
      _isLoading = state == AdState.loading;
      _hasError = state == AdState.error;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.placeholder ?? SizedBox(
        height: widget.height,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError) {
      return widget.errorWidget ?? SizedBox(
        height: widget.height,
        child: Center(
          child: TextButton(
            onPressed: _loadAd,
            child: const Text('Retry'),
          ),
        ),
      );
    }

    final adWidget = TopOnAdsService.instance.getNativeAdWidget();
    if (adWidget == null) {
      return widget.placeholder ?? SizedBox(height: widget.height);
    }

    return SizedBox(
      height: widget.height,
      child: adWidget,
    );
  }
}
