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
    return scanner.scanSafeItems();
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
}
