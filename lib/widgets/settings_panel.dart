import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/config/config_bloc.dart';
import '../bloc/config/config_event.dart';
import '../bloc/config/config_state.dart';
import '../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<ConfigBloc, ConfigState>(
      builder: (context, state) {
        if (state is! ConfigLoaded) return const SizedBox.shrink();

        final cfg = state.config;
        final bloc = context.read<ConfigBloc>();

        Widget buildDebugTile() => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingDebugMode),
              subtitle: cfg.debug
                  ? Text(
                      l10n.settingDebugModeSubtitle,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    )
                  : null,
              value: cfg.debug,
              onChanged: (_) => bloc.add(DebugToggled()),
            );

        if (debugOnly) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [buildDebugTile()],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(l10n.headerSettings,
                  style: Theme.of(context).textTheme.labelLarge),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingModLoader),
              value: cfg.modLoaderEnabled,
              onChanged: (_) => bloc.add(ModLoaderEnabledToggled()),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingLooseParams),
              value: cfg.looseParams,
              onChanged: (_) => bloc.add(LooseParamsToggled()),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingScyllaHide),
              value: cfg.scyllaHideEnabled,
              onChanged: (_) => bloc.add(ScyllaHideToggled()),
            ),
            if (!hideDebug) buildDebugTile(),
          ],
        );
      },
    );
  }
}
