import 'dart:io';

import 'package:flutter/material.dart';

import '../models/mod.dart';
import '../services/mod_service.dart';

class DeleteModDialog extends StatelessWidget {
  final Mod mod;
  final Directory baseDir;
  final ModService modService;
  final VoidCallback onConfirm;

  const DeleteModDialog({
    super.key,
    required this.mod,
    required this.baseDir,
    required this.modService,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete mod?'),
      content: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            const TextSpan(
              text: 'This will permanently delete the folder and all its files for ',
            ),
            TextSpan(
              text: mod.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(text: '. This cannot be undone.'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => _delete(context),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  Future<void> _delete(BuildContext context) async {
    await modService.deleteFolder(baseDir, mod.path);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    onConfirm();
  }
}
