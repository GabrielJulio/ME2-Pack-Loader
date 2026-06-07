import 'dart:io';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.deleteModDialogTitle),
      content: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(text: l10n.deleteModDialogBodyBefore),
            TextSpan(
              text: mod.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: l10n.deleteModDialogBodyAfter),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.buttonCancel),
        ),
        TextButton(
          onPressed: () => _delete(context),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(l10n.buttonDelete),
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
