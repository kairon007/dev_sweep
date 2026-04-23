import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/engine/models/scan_item.dart';
import 'dashboard_controller.dart';
import 'selective_cleanup_dialog.dart';

@RoutePage()
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardControllerProvider);

    int totalSafeBytes = 0;
    int totalReviewBytes = 0;
    int totalProjectBytes = 0;
    
    final safeItems = <ScanItem>[];
    final reviewItems = <ScanItem>[];
    final projectItems = <ScanItem>[];

    if (state.hasValue && state.value != null) {
      for (final item in state.value!) {
        if (item.category == ScanCategory.safe) {
          totalSafeBytes += item.sizeBytes;
          safeItems.add(item);
        } else if (item.category == ScanCategory.review) {
          totalReviewBytes += item.sizeBytes;
          reviewItems.add(item);
        } else if (item.category == ScanCategory.project) {
          totalProjectBytes += item.sizeBytes;
          projectItems.add(item);
        }
      }
    }

    final totalFreeable = totalSafeBytes + totalReviewBytes + totalProjectBytes;

    return Scaffold(
      body: Column(
        children: [
          _buildTopNavBar(),
          Expanded(
            child: Row(
              children: [
                _buildSideNavBar(),
                Expanded(
                  child: Container(
                    color: AppTheme.background,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHero(context, totalFreeable, ref),
                          _buildCacheClusters(context, safeItems, totalSafeBytes, ref, state.isLoading),
                          _buildEnvironmentBloat(context, reviewItems, ref, state.isLoading),
                          _buildProjectPruning(context, projectItems, ref, state.isLoading),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildTopNavBar() {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: AppTheme.navBackground,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text('DEV_UTIL', style: AppTheme.monoMd.copyWith(color: AppTheme.primaryDim, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Text('/root', style: AppTheme.monoXs),
              const SizedBox(width: 12),
              Text('/src', style: AppTheme.monoXs),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppTheme.primaryDim, width: 2)),
                ),
                child: Text('main.rs', style: AppTheme.monoXs.copyWith(color: AppTheme.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Row(
            children: [
              Icon(Icons.settings, size: 16, color: AppTheme.textMuted),
              SizedBox(width: 16),
              Icon(Icons.terminal, size: 16, color: AppTheme.textMuted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSideNavBar() {
    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF171717), // neutral-900
        border: Border(right: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        children: [
          Text('CLI', style: AppTheme.monoXs.copyWith(color: AppTheme.primaryDim, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppTheme.border,
              border: Border(left: BorderSide(color: AppTheme.primaryDim, width: 2)),
            ),
            child: const Icon(Icons.folder_outlined, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(height: 24),
          const Icon(Icons.search, color: AppTheme.textMuted, size: 20),
          const SizedBox(height: 24),
          const Icon(Icons.account_tree_outlined, color: AppTheme.textMuted, size: 20),
          const SizedBox(height: 24),
          const Icon(Icons.bug_report_outlined, color: AppTheme.textMuted, size: 20),
          const Spacer(),
          const Icon(Icons.check_circle_outline, color: AppTheme.primaryDim, size: 20),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, int totalBytes, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('STORAGE_MATRIX_V4.0', style: AppTheme.monoMd.copyWith(color: AppTheme.primary, letterSpacing: 1.2)),
                  const SizedBox(height: 4),
                  Text('BLOCK_ADDRESS: 0x7FF0012E -> 0x8AA9921B', style: AppTheme.monoXs),
                ],
              ),
              InkWell(
                onTap: () => ref.read(dashboardControllerProvider.notifier).rescan(),
                child: Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: AppTheme.primaryDim,
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      const Icon(Icons.terminal, size: 14, color: AppTheme.background),
                      const SizedBox(width: 8),
                      Text('SCAN & OPTIMIZE', style: AppTheme.monoSm.copyWith(color: AppTheme.background, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Placeholder for the matrix blocks
          Container(
            height: 96,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              border: Border.all(color: AppTheme.border),
            ),
            child: Wrap(
              spacing: 2,
              runSpacing: 2,
              children: List.generate(144, (index) {
                final isFilled = index % 3 == 0;
                final isHeavy = index % 5 == 0;
                Color c = AppTheme.border;
                if (isFilled) c = isHeavy ? AppTheme.primaryDim : AppTheme.primary;
                return Container(width: 14, height: 20, color: c.withValues(alpha: 0.6));
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('INDEX_START [0x0000]', style: AppTheme.monoXs.copyWith(color: AppTheme.textMuted)),
              Row(
                children: [
                  _legendDot(AppTheme.primaryDim, 'USED'),
                  const SizedBox(width: 16),
                  _legendDot(AppTheme.primary, 'RECLAIMABLE'),
                  const SizedBox(width: 16),
                  _legendDot(AppTheme.border, 'VACANT'),
                ],
              ),
              Text('INDEX_END [0xFFFF]', style: AppTheme.monoXs.copyWith(color: AppTheme.textMuted)),
            ],
          )
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, color: color),
        const SizedBox(width: 4),
        Text(label, style: AppTheme.monoXs.copyWith(color: AppTheme.textMuted)),
      ],
    );
  }

  Widget _buildCacheClusters(BuildContext context, List<ScanItem> safeItems, int totalBytes, WidgetRef ref, bool isLoading) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0E0E0E), // surface-container-lowest
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.dns_outlined, color: AppTheme.secondary, size: 16),
              const SizedBox(width: 8),
              Text('CACHE_CLUSTERS', style: AppTheme.monoMd.copyWith(color: Colors.white, letterSpacing: 2)),
              const Spacer(),
              Text('TOTAL_SIZE: ${_formatBytes(totalBytes)}', style: AppTheme.monoXs),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Text('Scanning...', style: TextStyle(color: AppTheme.textMuted))
          else if (safeItems.isEmpty)
            const Text('No caches found.', style: TextStyle(color: AppTheme.textMuted))
          else
            Wrap(
              spacing: 24,
              runSpacing: 16,
              children: safeItems.map((item) => _buildClusterCard(context, item, ref)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildClusterCard(BuildContext context, ScanItem item, WidgetRef ref) {
    return Container(
      width: 250,
      padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: AppTheme.primaryDim, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(item.displayName.toLowerCase().replaceAll(' ', '_'), style: AppTheme.monoSm, overflow: TextOverflow.ellipsis)),
              Text(item.formattedSize, style: AppTheme.monoSm.copyWith(color: AppTheme.secondary)),
            ],
          ),
          const SizedBox(height: 4),
          Text(item.path, style: AppTheme.monoXs, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              // Quick purge just for this item
              ref.read(dashboardControllerProvider.notifier).deleteSpecificItems([item.path]);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Text('PURGE', style: AppTheme.monoXs.copyWith(color: AppTheme.textMain)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentBloat(BuildContext context, List<ScanItem> reviewItems, WidgetRef ref, bool isLoading) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.developer_board, color: AppTheme.secondary, size: 16),
              const SizedBox(width: 8),
              Text('ENVIRONMENT_BLOAT', style: AppTheme.monoMd.copyWith(color: Colors.white, letterSpacing: 2)),
              const Spacer(),
              if (reviewItems.isNotEmpty)
                InkWell(
                  onTap: () {
                    _showSelectiveDialog(context, ref, reviewItems, 'Review SDKs & Simulators');
                  },
                  child: Text('REVIEW ALL', style: AppTheme.monoSm.copyWith(color: AppTheme.primaryDim, decoration: TextDecoration.underline)),
                )
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Text('Scanning...', style: TextStyle(color: AppTheme.textMuted))
          else if (reviewItems.isEmpty)
            const Text('No bloat found.', style: TextStyle(color: AppTheme.textMuted))
          else
            _buildReviewTable(context, reviewItems, ref),
        ],
      ),
    );
  }

  Widget _buildReviewTable(BuildContext context, List<ScanItem> items, WidgetRef ref) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: IntrinsicColumnWidth(),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.border))),
          children: [
            Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('ENTITY_IDENTIFIER', style: AppTheme.monoSm.copyWith(color: AppTheme.textMuted))),
            Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('ALLOCATION', style: AppTheme.monoSm.copyWith(color: AppTheme.textMuted))),
            Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('LAST_ACCESS', style: AppTheme.monoSm.copyWith(color: AppTheme.textMuted))),
            Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('ACTION', textAlign: TextAlign.right, style: AppTheme.monoSm.copyWith(color: AppTheme.textMuted))),
          ],
        ),
        for (final item in items.take(5)) // Show only top 5, rest in "REVIEW ALL"
          TableRow(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.border))),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.displayName, style: AppTheme.monoSm),
                    Text(item.path, style: AppTheme.monoXs, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(item.formattedSize, style: AppTheme.monoSm.copyWith(color: AppTheme.secondary)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('UNKNOWN', style: AppTheme.monoSm.copyWith(color: AppTheme.textMuted)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () => ref.read(dashboardControllerProvider.notifier).deleteSpecificItems([item.path]),
                    child: const Icon(Icons.delete_outline, color: AppTheme.primaryDim, size: 20),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildProjectPruning(BuildContext context, List<ScanItem> projectItems, WidgetRef ref, bool isLoading) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_tree_outlined, color: AppTheme.secondary, size: 16),
              const SizedBox(width: 8),
              Text('PROJECT_PRUNING', style: AppTheme.monoMd.copyWith(color: Colors.white, letterSpacing: 2)),
              const Spacer(),
              Text('DETECTED_DORMANT: ${projectItems.length} REPOS', style: AppTheme.monoXs),
              const SizedBox(width: 16),
              if (projectItems.isNotEmpty)
                InkWell(
                  onTap: () {
                    _showSelectiveDialog(context, ref, projectItems, 'Prune Projects');
                  },
                  child: Text('PRUNE ALL', style: AppTheme.monoSm.copyWith(color: AppTheme.primaryDim, decoration: TextDecoration.underline)),
                )
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Text('Scanning...', style: TextStyle(color: AppTheme.textMuted))
          else if (projectItems.isEmpty)
            const Text('No projects found.', style: TextStyle(color: AppTheme.textMuted))
          else
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: projectItems.map((p) => _buildProjectCard(p)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(ScanItem item) {
    final daysOld = item.lastModified != null 
        ? DateTime.now().difference(item.lastModified!).inDays 
        : 0;
    final isDormant = daysOld > 90;

    return Container(
      width: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(item.displayName, style: AppTheme.monoSm.copyWith(color: Colors.white), overflow: TextOverflow.ellipsis)),
              if (isDormant)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.navBackground,
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                  ),
                  child: Text('DORMANT', style: AppTheme.monoXs.copyWith(color: Colors.amber)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LAST_MODIFIED: ${daysOld}d ago', style: AppTheme.monoXs),
                  Text('SIZE: ${item.formattedSize}', style: AppTheme.monoXs.copyWith(color: AppTheme.primaryDim)),
                ],
              ),
              const Icon(Icons.archive_outlined, color: AppTheme.textMuted, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppTheme.navBackground,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text('SYSTEM_STABLE_0x2F', style: AppTheme.monoXs.copyWith(color: AppTheme.primaryDim)),
              const SizedBox(width: 16),
              Text('Toggle Log', style: AppTheme.monoXs.copyWith(color: AppTheme.textMuted)),
              const SizedBox(width: 16),
              Text('Clear', style: AppTheme.monoXs.copyWith(color: AppTheme.textMuted)),
            ],
          ),
          Row(
            children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.secondary, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text('AGENT_ACTIVE', style: AppTheme.monoXs.copyWith(color: AppTheme.secondary)),
              const SizedBox(width: 16),
              Text('Kill Process', style: AppTheme.monoXs.copyWith(color: const Color(0xFFFFB4AB))),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showSelectiveDialog(BuildContext context, WidgetRef ref, List<ScanItem> items, String title) async {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
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

  String _formatBytes(int sizeBytes) {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    if (sizeBytes < 1024 * 1024 * 1024) return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
