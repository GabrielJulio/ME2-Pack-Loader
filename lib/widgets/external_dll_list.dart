import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;

import '../bloc/config/config_bloc.dart';
import '../bloc/config/config_event.dart';
import '../bloc/config/config_state.dart';

class ExternalDllList extends StatelessWidget {
  final Directory baseDir;

  const ExternalDllList({super.key, required this.baseDir});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigBloc, ConfigState>(
      builder: (context, state) {
        if (state is! ConfigLoaded) return const SizedBox.shrink();

        final dlls = state.config.externalDlls;
        final bloc = context.read<ConfigBloc>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'External DLLs',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  tooltip: 'Add DLL',
                  onPressed: () => _addDll(context, bloc),
                ),
              ],
            ),
            if (dlls.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No DLLs added',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              )
            else
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: (oldIndex, newIndex) =>
                    bloc.add(DllReordered(oldIndex, newIndex)),
                children: [
                  for (int i = 0; i < dlls.length; i++)
                    ListTile(
                      key: ValueKey(dlls[i]),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: ReorderableDragStartListener(
                        index: i,
                        child: const Icon(Icons.drag_handle, size: 18),
                      ),
                      title: Text(
                        dlls[i],
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        tooltip: 'Remove',
                        onPressed: () => bloc.add(DllRemoved(i)),
                      ),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }

  Future<void> _addDll(BuildContext context, ConfigBloc bloc) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select a DLL inside your ModEngine2 folder',
      type: FileType.custom,
      allowedExtensions: ['dll'],
    );
    if (result == null || result.files.isEmpty) return;

    final absolutePath = result.files.first.path;
    if (absolutePath == null) return;

    final rel = p.relative(absolutePath, from: baseDir.path);
    if (rel.startsWith('..')) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('DLL must be inside the ModEngine2 folder.'),
          ),
        );
      }
      return;
    }

    if (context.mounted) bloc.add(DllAdded(rel));
  }
}
