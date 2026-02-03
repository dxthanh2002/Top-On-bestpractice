import 'package:flutter/material.dart';
import '../../../domain/models/ad_state.dart';

class AdButton extends StatelessWidget {
  final String text;
  final AdState state;
  final VoidCallback onPressed;

  const AdButton({
    required this.text,
    required this.state,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  String get _stateLabel {
    switch (state) {
      case AdState.idle:
        return '';
      case AdState.loading:
        return 'loading';
      case AdState.ready:
        return 'ready';
      case AdState.showing:
        return 'showing';
      case AdState.failed:
        return 'failed';
      case AdState.closed:
        return 'closed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(text),
              ),
            ),
          ),
          Positioned(
            left: MediaQuery.of(context).size.width / 2 + 100 + 10,
            top: 15,
            height: 20,
            child: Text(
              _stateLabel,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
