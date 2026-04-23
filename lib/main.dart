import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

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
      theme: AppTheme.darkTheme,
      routerConfig: _appRouter.config(),
    );
  }
}
