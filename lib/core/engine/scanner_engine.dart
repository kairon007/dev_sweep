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

  Future<List<ScanItem>> scanReviewItems() async {
    final home = Platform.environment['HOME'] ?? '';
    if (home.isEmpty) return [];

    final items = <ScanItem>[];

    // 1. Android SDKs
    final androidSdkDir = Directory('$home/Library/Android/sdk');
    if (await androidSdkDir.exists()) {
      final targetDirs = ['system-images', 'platforms', 'build-tools'];
      for (final target in targetDirs) {
        final targetDir = Directory('${androidSdkDir.path}/$target');
        if (await targetDir.exists()) {
          await for (final entity in targetDir.list()) {
            if (entity is Directory) {
              final size = await _calculateDirSize(entity);
              if (size > 0) {
                items.add(ScanItem(
                  id: entity.path,
                  path: entity.path,
                  displayName: 'Android $target: ${entity.path.split('/').last}',
                  sizeBytes: size,
                  category: ScanCategory.review,
                ));
              }
            }
          }
        }
      }
    }

    // 2. iOS Simulators
    final iosSimDir = Directory('$home/Library/Developer/CoreSimulator/Devices');
    if (await iosSimDir.exists()) {
      await for (final entity in iosSimDir.list()) {
        if (entity is Directory) {
          final size = await _calculateDirSize(entity);
          // Only show simulators taking more than 50MB (to filter out empty shells)
          if (size > 50 * 1024 * 1024) {
            items.add(ScanItem(
              id: entity.path,
              path: entity.path,
              displayName: 'iOS Simulator (${entity.path.split('/').last})',
              sizeBytes: size,
              category: ScanCategory.review,
            ));
          }
        }
      }
    }

    return items;
  }

  Future<List<ScanItem>> scanProjects() async {
    final home = Platform.environment['HOME'] ?? '';
    if (home.isEmpty) return [];

    final items = <ScanItem>[];
    final projectRoots = [
      '$home/IdeaProjects',
      '$home/StudioProjects',
      '$home/Developer',
      '$home/Workspace'
    ];

    for (final root in projectRoots) {
      final rootDir = Directory(root);
      if (await rootDir.exists()) {
        await for (final entity in rootDir.list(followLinks: false)) {
          if (entity is Directory) {
            final isProject = await _isProjectDirectory(entity);
            if (isProject) {
              final size = await _calculateDirSize(entity);
              final stat = await entity.stat();
              items.add(ScanItem(
                id: entity.path,
                path: entity.path,
                displayName: entity.path.split('/').last,
                sizeBytes: size,
                category: ScanCategory.project,
                lastModified: stat.modified,
              ));
            }
          }
        }
      }
    }
    
    // Sort projects by size (largest first)
    items.sort((a, b) => b.sizeBytes.compareTo(a.sizeBytes));
    return items;
  }

  Future<bool> _isProjectDirectory(Directory dir) async {
    final markers = ['.git', 'pubspec.yaml', 'build.gradle', '.xcodeproj', 'package.json'];
    for (final marker in markers) {
      if (await FileSystemEntity.type('${dir.path}/$marker') != FileSystemEntityType.notFound) {
        return true;
      }
    }
    return false;
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
