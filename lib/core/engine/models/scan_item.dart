enum ScanCategory {
  safe,
  review,
  project,
}

class ScanItem {
  final String id;
  final String path;
  final String displayName;
  final int sizeBytes;
  final ScanCategory category;

  ScanItem({
    required this.id,
    required this.path,
    required this.displayName,
    required this.sizeBytes,
    required this.category,
  });

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    if (sizeBytes < 1024 * 1024 * 1024) return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
