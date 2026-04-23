import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
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
  void initState() {
    super.initState();
    // Auto-select all by default
    for (final item in widget.items) {
      _selectedPaths.add(item.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalSelectedBytes = 0;
    for (final item in widget.items) {
      if (_selectedPaths.contains(item.path)) {
        totalSelectedBytes += item.sizeBytes;
      }
    }
    
    final formattedTotal = _formatBytes(totalSelectedBytes);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 900,
        height: 600,
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          border: Border.all(color: AppTheme.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 24,
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            _buildInfoBar(totalSelectedBytes),
            Expanded(
              child: Container(
                color: AppTheme.background,
                child: _buildTable(),
              ),
            ),
            _buildFooter(formattedTotal),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.cleaning_services, color: AppTheme.secondary, size: 16),
              const SizedBox(width: 12),
              Text('SELECTIVE CLEANUP: ${widget.title.toUpperCase()}', style: AppTheme.uiLabelMd.copyWith(letterSpacing: 1.2)),
            ],
          ),
          Row(
            children: [
              Text('ID: 0xFD29A', style: AppTheme.monoXs),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close, color: AppTheme.textMain, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBar(int totalSelectedBytes) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1B1B), // surface-container-low
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          _infoPair('TARGET:', 'Multiple'),
          const SizedBox(width: 24),
          _infoPair('RESOURCES:', '${widget.items.length} detected'),
          const SizedBox(width: 24),
          _infoPair('EST. RECOVERY:', _formatBytes(totalSelectedBytes), valueColor: AppTheme.tertiary),
        ],
      ),
    );
  }

  Widget _infoPair(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Text(label, style: AppTheme.monoXs),
        const SizedBox(width: 8),
        Text(value, style: AppTheme.monoXs.copyWith(color: valueColor ?? AppTheme.textMain)),
      ],
    );
  }

  Widget _buildTable() {
    return Column(
      children: [
        // Table Header
        Container(
          color: const Color(0xFF1A1A1A),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Checkbox(
                  value: _selectedPaths.length == widget.items.length,
                  activeColor: AppTheme.primaryDim,
                  side: const BorderSide(color: AppTheme.borderLight),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedPaths.addAll(widget.items.map((e) => e.path));
                      } else {
                        _selectedPaths.clear();
                      }
                    });
                  },
                ),
              ),
              Expanded(flex: 3, child: Text('RESOURCE NAME', style: AppTheme.monoXs)),
              Expanded(flex: 4, child: Text('ORIGIN PATH', style: AppTheme.monoXs)),
              Expanded(flex: 2, child: Text('LAST MODIFIED', style: AppTheme.monoXs)),
              SizedBox(width: 80, child: Text('SIZE', style: AppTheme.monoXs)),
            ],
          ),
        ),
        const Divider(height: 1),
        // Table Body
        Expanded(
          child: ListView.separated(
            itemCount: widget.items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = widget.items[index];
              final isSelected = _selectedPaths.contains(item.path);
              
              final lastModStr = item.lastModified != null 
                  ? item.lastModified!.toIso8601String().split('T').join(' ').substring(0, 19)
                  : 'Unknown';

              return Container(
                color: isSelected ? AppTheme.secondary.withValues(alpha: 0.05) : Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Checkbox(
                        value: isSelected,
                        activeColor: AppTheme.primaryDim,
                        side: const BorderSide(color: AppTheme.borderLight),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedPaths.add(item.path);
                            } else {
                              _selectedPaths.remove(item.path);
                            }
                          });
                        },
                      ),
                    ),
                    Expanded(flex: 3, child: Text(item.displayName, style: AppTheme.monoSm.copyWith(color: isSelected ? AppTheme.secondary : AppTheme.textMain))),
                    Expanded(flex: 4, child: Text(item.path, style: AppTheme.monoSm.copyWith(color: AppTheme.textMuted), overflow: TextOverflow.ellipsis)),
                    Expanded(flex: 2, child: Text(lastModStr, style: AppTheme.monoSm.copyWith(color: AppTheme.textMuted))),
                    SizedBox(width: 80, child: Text(item.formattedSize, style: AppTheme.monoSm.copyWith(color: AppTheme.tertiary))),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(String formattedTotal) {
    return Container(
      color: const Color(0xFF121212),
      child: Column(
        children: [
          // Log console
          Container(
            height: 96,
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: const Color(0xFF0A0A0A),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _logLine('Awaiting confirmation for ${_selectedPaths.length} items ($formattedTotal total).'),
                  _logLine('Warning: Action is destructive and will move items to Trash.'),
                  _logLine('Target process tree locked for safe deletion.'),
                  Row(
                    children: [
                      Text('[${DateTime.now().toIso8601String().split('T').last.substring(0, 8)}] ', style: AppTheme.monoXs.copyWith(color: AppTheme.primaryDim)),
                      Text('_ system ready...', style: AppTheme.monoXs.copyWith(color: AppTheme.secondary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          // Action Bar
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildOutlineButton('CANCEL OPERATION', () => Navigator.of(context).pop()),
                    const SizedBox(width: 16),
                    _buildOutlineButton('DRY RUN (SIMULATE)', () {}),
                  ],
                ),
                InkWell(
                  onTap: _selectedPaths.isEmpty
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          widget.onConfirm(_selectedPaths.toList());
                        },
                  child: Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    color: _selectedPaths.isEmpty ? AppTheme.borderLight : AppTheme.primaryDim,
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Icon(Icons.delete_forever, size: 16, color: AppTheme.background),
                        const SizedBox(width: 8),
                        Text('EXECUTE DELETION', style: AppTheme.uiLabelMd.copyWith(color: AppTheme.background, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _logLine(String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Text('[${DateTime.now().toIso8601String().split('T').last.substring(0, 8)}] ', style: AppTheme.monoXs.copyWith(color: AppTheme.primaryDim)),
          Text(message, style: AppTheme.monoXs),
        ],
      ),
    );
  }

  Widget _buildOutlineButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.borderLight),
        ),
        alignment: Alignment.center,
        child: Text(label, style: AppTheme.uiLabelMd.copyWith(fontSize: 11)),
      ),
    );
  }

  String _formatBytes(int sizeBytes) {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    if (sizeBytes < 1024 * 1024 * 1024) return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
