import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../data/repositories/ad_repository.dart';
import '../ui/home/home_screen.dart';
import '../ui/home/home_viewmodel.dart';

class Routes {
  static const String home = '/';
  static const String automatic = '/automatic';
}

GoRouter createRouter() {
  return GoRouter(
    initialLocation: Routes.home,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: Routes.home,
        builder: (context, state) {
          final adRepository = context.read<AdRepository>();
          return HomeScreen(
            viewModel: HomeViewModel(adRepository: adRepository),
          );
        },
      ),
    ],
  );
}
