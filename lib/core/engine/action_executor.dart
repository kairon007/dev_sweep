import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'action_executor.g.dart';

@riverpod
ActionExecutor actionExecutor(Ref ref) {
  return ActionExecutor();
}

class ActionExecutor {
  /// Moves the specified path to the macOS Trash using AppleScript.
  /// This ensures "Put Back" works and handles filename conflicts in the Trash.
  Future<bool> moveToTrash(String path) async {
    if (!Platform.isMacOS) {
      // Fallback for non-macOS (though app is targeted for macOS)
      final dir = Directory(path);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        return true;
      }
      return false;
    }

    try {
      final result = await Process.run('osascript', [
        '-e',
        'tell application "Finder" to delete POSIX file "$path"',
      ]);
      
      if (result.exitCode == 0) {
        return true;
      } else {
        print('Error moving to trash: ${result.stderr}');
        return false;
      }
    } catch (e) {
      print('Exception moving to trash: $e');
      return false;
    }
  }
}
