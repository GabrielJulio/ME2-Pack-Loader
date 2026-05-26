import 'package:flutter/material.dart';

import '../models/mod.dart';

class ModListTile extends StatelessWidget {
  final int index;
  final Mod mod;
  final bool isFolderEmpty;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ModListTile({
    super.key,
    required this.index,
    required this.mod,
    required this.isFolderEmpty,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ReorderableDragStartListener(
        index: index,
        child: const Icon(Icons.drag_handle),
      ),
      title: Row(
        children: [
          Text(mod.name),
          if (isFolderEmpty) ...[
            const SizedBox(width: 8),
            Tooltip(
              message: 'Folder is empty — add files before enabling',
              child: Icon(
                Icons.warning_amber_rounded,
                size: 18,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(mod.path, style: const TextStyle(fontSize: 12)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: mod.enabled,

            onChanged: isFolderEmpty ? null : (_) => onToggle(),
          ),
          IconButton(
            icon: const Icon(Icons.upload_file_outlined, size: 20),
            tooltip: 'Import files',
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            tooltip: 'Delete mod',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
