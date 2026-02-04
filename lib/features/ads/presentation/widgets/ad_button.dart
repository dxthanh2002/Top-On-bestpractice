import 'package:flutter/material.dart';
import '../../domain/models/models.dart';
import '../controllers/ads_controller.dart';

class AdButton extends StatelessWidget {
  final AdsController controller;
  final TopOnAdUnit adUnit;
  final String label;
  final VoidCallback onPressed;
  final bool showStatus;

  const AdButton({
    Key? key,
    required this.controller,
    required this.adUnit,
    required this.label,
    required this.onPressed,
    this.showStatus = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.getState(adUnit);
        final isLoading = state == AdState.loading;
        final isReady = state == AdState.ready;

        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isReady ? Colors.green : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              Text(label),
              if (showStatus) ...[
                const SizedBox(width: 8),
                _StatusIndicator(state: state),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final AdState state;

  const _StatusIndicator({required this.state});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (state) {
      case AdState.idle:
        color = Colors.grey;
        break;
      case AdState.loading:
        color = Colors.orange;
        break;
      case AdState.ready:
        color = Colors.green;
        break;
      case AdState.showing:
        color = Colors.blue;
        break;
      case AdState.error:
        color = Colors.red;
        break;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
