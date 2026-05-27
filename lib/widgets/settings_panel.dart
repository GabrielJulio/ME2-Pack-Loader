import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/config/config_bloc.dart';
import '../bloc/config/config_event.dart';
import '../bloc/config/config_state.dart';

class SettingsPanel extends StatelessWidget {
  final bool hideDebug;
  final bool debugOnly;

  const SettingsPanel({
    super.key,
    this.hideDebug = false,
    this.debugOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigBloc, ConfigState>(
      builder: (context, state) {
        if (state is! ConfigLoaded) return const SizedBox.shrink();

        final cfg = state.config;
        final bloc = context.read<ConfigBloc>();

        if (debugOnly) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Debug Mode'),
                subtitle: cfg.debug
                    ? Text(
                        'Developer option — disable for normal play',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      )
                    : null,
                value: cfg.debug,
                onChanged: (_) => bloc.add(DebugToggled()),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('Settings', style: Theme.of(context).textTheme.labelLarge),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Mod Loader'),
              value: cfg.modLoaderEnabled,
              onChanged: (_) => bloc.add(ModLoaderEnabledToggled()),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Loose Params'),
              value: cfg.looseParams,
              onChanged: (_) => bloc.add(LooseParamsToggled()),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Scylla Hide'),
              value: cfg.scyllaHideEnabled,
              onChanged: (_) => bloc.add(ScyllaHideToggled()),
            ),
            if (!hideDebug)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Debug Mode'),
                subtitle: cfg.debug
                    ? Text(
                        'Developer option — disable for normal play',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      )
                    : null,
                value: cfg.debug,
                onChanged: (_) => bloc.add(DebugToggled()),
              ),
          ],
        );
      },
    );
  }
}
