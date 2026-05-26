import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/setup/setup_bloc.dart';
import '../bloc/setup/setup_event.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  'ME2 Pack Loader',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text('Manage your ModEngine2 mod packs.'),
                const SizedBox(height: 8),
                Text(
                  'Select the folder where ModEngine2 is installed.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => _pickFolder(context),
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Choose ModEngine2 folder'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickFolder(BuildContext context) async {
    final path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select your ModEngine2 folder',
    );
    if (path == null) return;
    if (!context.mounted) return;
    context.read<SetupBloc>().add(SetupFolderSelected(path));
  }
}
