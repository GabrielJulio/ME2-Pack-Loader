import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/mod.dart';
import '../services/mod_service.dart';
import '../utils/slugify.dart';

class CreateEditModDialog extends StatefulWidget {
  final Directory baseDir;
  final ModService modService;
  final Mod? existingMod;
  final void Function(Mod mod) onSave;

  const CreateEditModDialog({
    super.key,
    required this.baseDir,
    required this.modService,
    required this.onSave,
    this.existingMod,
  });

  @override
  State<CreateEditModDialog> createState() => _CreateEditModDialogState();
}

enum _SlugStatus { empty, checking, available, taken }

class _CreateEditModDialogState extends State<CreateEditModDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  Timer? _debounce;
  _SlugStatus _slugStatus = _SlugStatus.empty;
  String _slug = '';

  bool get _isEditMode => widget.existingMod != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _slug = widget.existingMod!.path;
    }
    _nameController.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    final slug = slugify(_nameController.text);
    setState(() {
      _slug = slug;
      _slugStatus = slug.isEmpty ? _SlugStatus.empty : _SlugStatus.checking;
    });

    _debounce?.cancel();
    if (slug.isEmpty) return;

    _debounce = Timer(const Duration(milliseconds: 300), () {
      final exists = widget.modService.slugExists(widget.baseDir, slug);
      if (mounted) {
        setState(() {
          _slugStatus = exists ? _SlugStatus.taken : _SlugStatus.available;
        });
      }
    });
  }

  Future<void> _importFiles() async {
    final l10n = AppLocalizations.of(context);
    final targetPath = _isEditMode ? widget.existingMod!.path : _slug;
    if (targetPath.isEmpty) return;

    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null || result.paths.isEmpty) return;

    final paths = result.paths.whereType<String>().toList();
    await widget.modService.importFiles(widget.baseDir, targetPath, paths);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.filesImported(paths.length, targetPath)),
        ),
      );
    }
  }

  Future<void> _save() async {
    if (_isEditMode) {
      Navigator.of(context).pop();

      widget.onSave(widget.existingMod!);
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    if (_slugStatus != _SlugStatus.available) return;

    await widget.modService.createFolder(widget.baseDir, _slug);
    if (!mounted) return;

    Navigator.of(context).pop();
    widget.onSave(Mod(enabled: true, name: _slug, path: _slug));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = _isEditMode
        ? l10n.importFilesForMod(widget.existingMod!.name)
        : l10n.addModTitle;
    final folderForTip = _isEditMode
        ? widget.existingMod!.path
        : (_slug.isNotEmpty ? _slug : l10n.slugFolderPlaceholder);

    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isEditMode) ...[
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.modNameLabel,
                    hintText: l10n.modNameHint,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.validationNameRequired;
                    }
                    if (_slug.isEmpty) return l10n.validationEmptyFolderName;
                    if (_slugStatus == _SlugStatus.taken) {
                      return l10n.validationNameTaken;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                _SlugPreview(slug: _slug, status: _slugStatus),
                const SizedBox(height: 24),
              ],
              OutlinedButton.icon(
                onPressed:
                    (_isEditMode || _slug.isNotEmpty) ? _importFiles : null,
                icon: const Icon(Icons.upload_file),
                label: Text(l10n.importFilesButton),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.importFilesTip('${widget.baseDir.path}/$folderForTip/'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.buttonCancel),
        ),
        FilledButton(
          onPressed: (_isEditMode || _slugStatus == _SlugStatus.available)
              ? _save
              : null,
          child: Text(_isEditMode ? l10n.buttonDone : l10n.buttonAdd),
        ),
      ],
    );
  }
}

class _SlugPreview extends StatelessWidget {
  final String slug;
  final _SlugStatus status;

  const _SlugPreview({required this.slug, required this.status});

  @override
  Widget build(BuildContext context) {
    if (slug.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);

    final Widget statusIcon = switch (status) {
      _SlugStatus.checking => const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      _SlugStatus.available => Icon(
          Icons.check_circle_outline,
          size: 16,
          color: Colors.green.shade600,
        ),
      _SlugStatus.taken => Icon(
          Icons.cancel_outlined,
          size: 16,
          color: Theme.of(context).colorScheme.error,
        ),
      _SlugStatus.empty => const SizedBox.shrink(),
    };

    final String statusLabel = switch (status) {
      _SlugStatus.available => l10n.slugAvailable,
      _SlugStatus.taken => l10n.slugTaken,
      _ => '',
    };

    return Row(
      children: [
        Text(l10n.slugFolderPrefix,
            style: Theme.of(context).textTheme.bodySmall),
        Text(
          '$slug/',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 8),
        statusIcon,
        if (statusLabel.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            statusLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: status == _SlugStatus.available
                      ? Colors.green.shade600
                      : Theme.of(context).colorScheme.error,
                ),
          ),
        ],
      ],
    );
  }
}
