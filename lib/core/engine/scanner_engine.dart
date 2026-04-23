import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'models/scan_item.dart';

part 'scanner_engine.g.dart';

@riverpod
ScannerEngine scannerEngine(Ref ref) {
  return ScannerEngine();
}

class ScannerEngine {
  Future<List<ScanItem>> scanSafeItems() async {
    final home = Platform.environment['HOME'] ?? '';
    if (home.isEmpty) return [];

    final safeDirs = [
      {'path': '$home/.gradle/caches', 'name': 'Gradle Caches'},
      {'path': '$home/Library/Developer/Xcode/DerivedData', 'name': 'Xcode DerivedData'},
    ];

    final items = <ScanItem>[];
    
    for (final dirInfo in safeDirs) {
      final dir = Directory(dirInfo['path']!);
      if (await dir.exists()) {
        final size = await _calculateDirSize(dir);
        if (size > 0) {
          items.add(ScanItem(
            id: dir.path,
            path: dir.path,
            displayName: dirInfo['name']!,
            sizeBytes: size,
            category: ScanCategory.safe,
          ));
        }
      }
    }
    
    return items;
  }

  Future<int> _calculateDirSize(Directory dir) async {
    int totalSize = 0;
    try {
      if (await dir.exists()) {
        await for (var entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            try {
              totalSize += await entity.length();
            } catch (e) {
              // Ignore access errors on individual files
            }
          }
        }
      }
    } catch (e) {
      // Ignore directory access errors
    }
    return totalSize;
  }
}
