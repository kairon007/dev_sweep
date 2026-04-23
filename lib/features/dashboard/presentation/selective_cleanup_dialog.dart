import 'package:flutter/material.dart';
import '../../../core/engine/models/scan_item.dart';

class SelectiveCleanupDialog extends StatefulWidget {
  final String title;
  final List<ScanItem> items;
  final Function(List<String> selectedPaths) onConfirm;

  const SelectiveCleanupDialog({
    super.key,
    required this.title,
    required this.items,
    required this.onConfirm,
  });

  @override
  State<SelectiveCleanupDialog> createState() => _SelectiveCleanupDialogState();
}

class _SelectiveCleanupDialogState extends State<SelectiveCleanupDialog> {
  final Set<String> _selectedPaths = {};

  @override
  Widget build(BuildContext context) {
    int totalSelectedBytes = 0;
    for (final item in widget.items) {
      if (_selectedPaths.contains(item.path)) {
        totalSelectedBytes += item.sizeBytes;
      }
    }
    
    final formattedTotal = _formatBytes(totalSelectedBytes);

    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        height: 400, // Fixed max height for the list
        child: widget.items.isEmpty 
          ? const Center(child: Text('No items found.'))
          : ListView.builder(
            shrinkWrap: true,
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              final isSelected = _selectedPaths.contains(item.path);
              
              String subtitle = item.path;
              if (item.lastModified != null) {
                subtitle += '\nLast modified: ${item.lastModified.toString().split(' ').first}';
              }

              return CheckboxListTile(
                value: isSelected,
                onChanged: (bool? checked) {
                  setState(() {
                    if (checked == true) {
                      _selectedPaths.add(item.path);
                    } else {
                      _selectedPaths.remove(item.path);
                    }
                  });
                },
                title: Text(item.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
                secondary: Text(item.formattedSize),
                isThreeLine: item.lastModified != null,
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
          onPressed: _selectedPaths.isEmpty
              ? null
              : () {
                  Navigator.of(context).pop();
                  widget.onConfirm(_selectedPaths.toList());
                },
          icon: const Icon(Icons.delete_outline),
          label: Text('Delete Selected ($formattedTotal)'),
        ),
      ],
    );
  }

  String _formatBytes(int sizeBytes) {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    if (sizeBytes < 1024 * 1024 * 1024) return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
