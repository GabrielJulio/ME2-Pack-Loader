import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/setup/setup_bloc.dart';
import '../bloc/setup/setup_event.dart';
import '../l10n/app_localizations.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.videogame_asset, size: 64),
                const SizedBox(height: 24),
                Text(
                  l10n.appTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(l10n.appTagline),
                const SizedBox(height: 8),
                Text(
                  l10n.onboardingSelectFolder,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => _pickFolder(context),
                  icon: const Icon(Icons.folder_open),
                  label: Text(l10n.onboardingChooseFolderButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickFolder(BuildContext context) async {
    final dialogTitle = AppLocalizations.of(context).onboardingPickerDialog;
    final path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: dialogTitle,
    );
    if (path == null) return;
    if (!context.mounted) return;
    context.read<SetupBloc>().add(SetupFolderSelected(path));
  }
}
