import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dashboard_controller.dart';

@RoutePage()
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardControllerProvider);
    
    // Calculate total freeable space (safe items only for now)
    int totalBytes = 0;
    if (state.hasValue && state.value != null) {
      for (final item in state.value!) {
        totalBytes += item.sizeBytes;
      }
    }
    
    final formattedTotal = _formatBytes(totalBytes);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DevSweep'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(dashboardControllerProvider.notifier).rescan(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.isLoading 
                  ? 'Scanning...' 
                  : 'You can free: $formattedTotal',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (state.hasError) 
              Text('Error: ${state.error}', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _buildSectionCard(
                    context,
                    title: 'Safe Cleanup',
                    subtitle: 'DerivedData, Gradle Caches',
                    actionLabel: state.isLoading ? '...' : 'Clean Safe Items',
                    onAction: state.isLoading || totalBytes == 0
                        ? null 
                        : () => ref.read(dashboardControllerProvider.notifier).cleanSafeItems(),
                  ),
                  _buildSectionCard(
                    context,
                    title: 'Review Required',
                    subtitle: 'Simulators, SDKs (Coming soon)',
                    actionLabel: 'Review',
                    onAction: null,
                  ),
                  _buildSectionCard(
                    context,
                    title: 'Projects',
                    subtitle: 'Old/Large Projects (Coming soon)',
                    actionLabel: 'Prune',
                    onAction: null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int sizeBytes) {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    if (sizeBytes < 1024 * 1024 * 1024) return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Widget _buildSectionCard(BuildContext context,
      {required String title,
      required String subtitle,
      required String actionLabel,
      required VoidCallback? onAction}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: FilledButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
