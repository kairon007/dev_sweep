import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/engine/action_executor.dart';
import '../../../core/engine/models/scan_item.dart';
import '../../../core/engine/scanner_engine.dart';

part 'dashboard_controller.g.dart';

@riverpod
class DashboardController extends _$DashboardController {
  @override
  FutureOr<List<ScanItem>> build() async {
    return _scanSafeItems();
  }

  Future<List<ScanItem>> _scanSafeItems() async {
    final scanner = ref.read(scannerEngineProvider);
    final results = await Future.wait([
      scanner.scanSafeItems(),
      scanner.scanReviewItems(),
      scanner.scanProjects(),
    ]);
    return results.expand((list) => list).toList();
  }

  Future<void> rescan() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _scanSafeItems());
  }

  Future<void> cleanSafeItems() async {
    final items = state.valueOrNull;
    if (items == null || items.isEmpty) return;

    final executor = ref.read(actionExecutorProvider);
    
    // Set to loading to disable the button during cleanup
    state = const AsyncValue.loading();

    for (final item in items) {
      if (item.category == ScanCategory.safe) {
        await executor.moveToTrash(item.path);
      }
    }

    // Refresh the list after cleanup
    await rescan();
  }

  Future<void> deleteSpecificItems(List<String> pathsToDelete) async {
    final executor = ref.read(actionExecutorProvider);
    state = const AsyncValue.loading();

    for (final path in pathsToDelete) {
      await executor.moveToTrash(path);
    }

    await rescan();
  }
}
