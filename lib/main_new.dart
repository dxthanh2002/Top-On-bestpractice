import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/repositories/ad_repository.dart';
import 'data/services/ad_service.dart';
import 'routing/app_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        Provider<AdService>(
          create: (_) => AdService(),
        ),
        // Repositories - use ChangeNotifierProvider for concrete type
        ChangeNotifierProvider<AdRepositoryImpl>(
          create: (context) => AdRepositoryImpl(
            adService: context.read<AdService>(),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          final router = createRouter();
          return MaterialApp.router(
            title: 'TopOn Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              useMaterial3: true,
            ),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
