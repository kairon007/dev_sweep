import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/engine/models/scan_item.dart';
import 'dashboard_controller.dart';
import 'selective_cleanup_dialog.dart';

@RoutePage()
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardControllerProvider);
    
    // Calculate total freeable space (safe items only for now)
    int totalSafeBytes = 0;
    int totalReviewBytes = 0;
    int totalProjectBytes = 0;

    if (state.hasValue && state.value != null) {
      for (final item in state.value!) {
        if (item.category == ScanCategory.safe) {
          totalSafeBytes += item.sizeBytes;
        } else if (item.category == ScanCategory.review) {
          totalReviewBytes += item.sizeBytes;
        } else if (item.category == ScanCategory.project) {
          totalProjectBytes += item.sizeBytes;
        }
      }
    }
    
    final formattedSafeTotal = _formatBytes(totalSafeBytes);

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
                  : 'You can free: $formattedSafeTotal safely',
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
                    onAction: state.isLoading || totalSafeBytes == 0
                        ? null 
                        : () => _showOverviewDialog(context, ref, state.value!),
                  ),
                  _buildSectionCard(
                    context,
                    title: 'Review Required',
                    subtitle: 'Simulators, SDKs',
                    actionLabel: state.isLoading ? '...' : 'Review',
                    onAction: state.isLoading || totalReviewBytes == 0
                        ? null
                        : () => _showSelectiveDialog(
                              context, 
                              ref, 
                              state.value!.where((i) => i.category == ScanCategory.review).toList(),
                              'Review SDKs & Simulators',
                            ),
                  ),
                  _buildSectionCard(
                    context,
                    title: 'Projects',
                    subtitle: 'Old/Large Projects',
                    actionLabel: state.isLoading ? '...' : 'Prune',
                    onAction: state.isLoading || totalProjectBytes == 0
                        ? null
                        : () => _showSelectiveDialog(
                              context, 
                              ref, 
                              state.value!.where((i) => i.category == ScanCategory.project).toList(),
                              'Prune Projects',
                            ),
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

  Future<void> _showOverviewDialog(BuildContext context, WidgetRef ref, List<ScanItem> items) async {
    final safeItems = items.where((i) => i.category == ScanCategory.safe).toList();
    
    if (safeItems.isEmpty) return;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Review Safe Cleanup'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: safeItems.length,
              itemBuilder: (context, index) {
                final item = safeItems[index];
                return ListTile(
                  leading: const Icon(Icons.folder, color: Colors.blueAccent),
                  title: Text(item.displayName),
                  subtitle: Text(item.path, style: const TextStyle(fontSize: 12)),
                  trailing: Text(item.formattedSize, style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(dashboardControllerProvider.notifier).cleanSafeItems();
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Confirm Cleanup'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSelectiveDialog(BuildContext context, WidgetRef ref, List<ScanItem> items, String title) async {
    return showDialog(
      context: context,
      builder: (context) {
        return SelectiveCleanupDialog(
          title: title,
          items: items,
          onConfirm: (selectedPaths) {
            ref.read(dashboardControllerProvider.notifier).deleteSpecificItems(selectedPaths);
          },
        );
      },
    );
  }
}
