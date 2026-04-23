import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: DevSweepApp(),
    ),
  );
}

class DevSweepApp extends ConsumerStatefulWidget {
  const DevSweepApp({super.key});

  @override
  ConsumerState<DevSweepApp> createState() => _DevSweepAppState();
}

class _DevSweepAppState extends ConsumerState<DevSweepApp> {
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DevSweep',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: _appRouter.config(),
    );
  }
}
