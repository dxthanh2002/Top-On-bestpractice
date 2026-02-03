import 'package:flutter/material.dart';
import '../../domain/models/ad_type.dart';
import '../core/widgets/ad_button.dart';
import 'home_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomeScreen({
    required this.viewModel,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Text(
                viewModel.errorMessage!,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          return Container(
            color: const Color.fromRGBO(60, 104, 243, 1),
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'TopOn Flutter Demo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                AdButton(
                  text: 'Show Interstitial',
                  state: viewModel.getAdState(AdType.interstitial),
                  onPressed: viewModel.showInterstitial,
                ),
                const SizedBox(height: 20),
                AdButton(
                  text: 'Show Reward',
                  state: viewModel.getAdState(AdType.rewarded),
                  onPressed: viewModel.showRewarded,
                ),
                const SizedBox(height: 20),
                AdButton(
                  text: 'Show Splash',
                  state: viewModel.getAdState(AdType.splash),
                  onPressed: viewModel.showSplash,
                ),
                const SizedBox(height: 20),
                AdButton(
                  text: 'Show Banner',
                  state: viewModel.getAdState(AdType.banner),
                  onPressed: viewModel.showBanner,
                ),
                const SizedBox(height: 20),
                AdButton(
                  text: 'Show Native',
                  state: viewModel.getAdState(AdType.native),
                  onPressed: viewModel.showNative,
                ),
                const SizedBox(height: 20),
                AdButton(
                  text: 'Mediation Debugger',
                  state: viewModel.getAdState(AdType.interstitial),
                  onPressed: viewModel.showDebugger,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
