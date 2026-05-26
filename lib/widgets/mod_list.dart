import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/config/config_bloc.dart';
import '../bloc/config/config_event.dart';
import '../bloc/config/config_state.dart';
import '../models/mod.dart';
import '../services/mod_service.dart';
import 'create_edit_mod_dialog.dart';
import 'delete_mod_dialog.dart';
import 'mod_list_tile.dart';

class ModList extends StatelessWidget {
  final Directory baseDir;
  final ModService modService;

  const ModList({super.key, required this.baseDir, required this.modService});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigBloc, ConfigState>(
      builder: (context, state) {
        if (state is! ConfigLoaded) return const SizedBox.shrink();

        final mods = state.config.mods;
        final bloc = context.read<ConfigBloc>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
              child: Row(
                children: [
                  Text('Mods', style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Add mod',
                    onPressed: () => _showCreateDialog(context, bloc),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: mods.isEmpty
                  ? Center(
                      child: Text(
                        'No mods yet.\nPress + to add one.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    )
                  : ReorderableListView(
                      onReorder: (oldIndex, newIndex) =>
                          bloc.add(ModReordered(oldIndex, newIndex)),
                      children: [
                        for (int i = 0; i < mods.length; i++)
                          ModListTile(
                            key: ValueKey(mods[i].name),
                            index: i,
                            mod: mods[i],
                            isFolderEmpty: modService.isFolderEmpty(
                              baseDir,
                              mods[i].path,
                            ),
                            onToggle: () => bloc.add(ModToggled(i)),
                            onEdit: () => _showEditDialog(context, bloc, i, mods[i]),
                            onDelete: () => _showDeleteDialog(context, bloc, i, mods[i]),
                          ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showCreateDialog(BuildContext context, ConfigBloc bloc) {
    showDialog<void>(
      context: context,
      builder: (_) => CreateEditModDialog(
        baseDir: baseDir,
        modService: modService,
        onSave: (mod) => bloc.add(ModAdded(mod)),
      ),
    );
  }

  void _showEditDialog(BuildContext context, ConfigBloc bloc, int index, Mod mod) {
    showDialog<void>(
      context: context,
      builder: (_) => CreateEditModDialog(
        baseDir: baseDir,
        modService: modService,
        existingMod: mod,
        onSave: (updated) => bloc.add(ModUpdated(index, updated)),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ConfigBloc bloc, int index, Mod mod) {
    showDialog<void>(
      context: context,
      builder: (_) => DeleteModDialog(
        mod: mod,
        baseDir: baseDir,
        modService: modService,
        onConfirm: () => bloc.add(ModRemoved(index)),
      ),
    );
  }
}
