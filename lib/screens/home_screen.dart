import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/config/config_bloc.dart';
import '../bloc/config/config_event.dart';
import '../bloc/config/config_state.dart';
import '../bloc/layout/layout_bloc.dart';
import '../bloc/layout/layout_event.dart';
import '../bloc/layout/layout_state.dart';
import '../l10n/app_localizations.dart';
import '../models/layout_type.dart';
import '../services/config_service.dart';
import '../services/mod_service.dart';
import '../services/preferences_service.dart';
import '../widgets/external_dll_list.dart';
import '../widgets/gnome_layout.dart';
import '../widgets/language_selector.dart';
import '../widgets/mod_list.dart';
import '../widgets/settings_panel.dart';
import 'steam_setup_screen.dart';

class HomeScreen extends StatelessWidget {
  final String modEngineDir;

  const HomeScreen({super.key, required this.modEngineDir});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ConfigBloc(configService: ConfigService())
            ..add(ConfigLoadRequested(Directory(modEngineDir))),
        ),
        BlocProvider(
          create: (_) => LayoutBloc(preferencesService: PreferencesService())
            ..add(LayoutStarted()),
        ),
      ],
      child: _HomeShell(modEngineDir: modEngineDir),
    );
  }
}

class _HomeShell extends StatelessWidget {
  final String modEngineDir;

  const _HomeShell({required this.modEngineDir});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          _LayoutSwitcher(),
          _LaunchGameButton(
            onSetupTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SteamSetupScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<ConfigBloc, ConfigState>(
        builder: (context, configState) {
          if (configState is ConfigInitial || configState is ConfigLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (configState is ConfigError) {
            return _ErrorView(
              message: configState.message,
              onRetry: () => context
                  .read<ConfigBloc>()
                  .add(ConfigLoadRequested(Directory(modEngineDir))),
            );
          }
          if (configState is ConfigLoaded) {
            return BlocBuilder<LayoutBloc, LayoutState>(
              builder: (context, layoutState) {
                return _buildLayout(context, layoutState.type, configState);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLayout(
    BuildContext context,
    LayoutType type,
    ConfigLoaded configState,
  ) {
    final modService = ModService();
    return switch (type) {
      LayoutType.defaultMaterial => _DefaultLayout(
          baseDir: configState.baseDir,
          modService: modService,
        ),
      LayoutType.gnome => GnomeLayout(
          baseDir: configState.baseDir,
          modService: modService,
        ),
    };
  }
}

class _DefaultLayout extends StatelessWidget {
  final Directory baseDir;
  final ModService modService;

  const _DefaultLayout({required this.baseDir, required this.modService});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 280,
          child: Material(
            elevation: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GameSelector(),
                  const Divider(),
                  const SettingsPanel(),
                  const Divider(),
                  ExternalDllList(baseDir: baseDir),
                  const Divider(),
                  const LanguageSelector(),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ModList(baseDir: baseDir, modService: modService),
        ),
      ],
    );
  }
}

class _LayoutSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<LayoutBloc, LayoutState>(
      builder: (context, state) {
        return PopupMenuButton<LayoutType>(
          icon: const Icon(Icons.dashboard_customize_outlined),
          tooltip: l10n.switchLayoutTooltip,
          onSelected: (type) =>
              context.read<LayoutBloc>().add(LayoutSelected(type)),
          itemBuilder: (_) => [
            _layoutMenuItem(
              type: LayoutType.defaultMaterial,
              current: state.type,
              icon: Icons.view_sidebar_outlined,
              label: l10n.layoutDefaultName,
            ),
            _layoutMenuItem(
              type: LayoutType.gnome,
              current: state.type,
              icon: Icons.view_list_outlined,
              label: l10n.layoutGnomeName,
            ),
          ],
        );
      },
    );
  }

  PopupMenuItem<LayoutType> _layoutMenuItem({
    required LayoutType type,
    required LayoutType current,
    required IconData icon,
    required String label,
  }) {
    return PopupMenuItem(
      value: type,
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: current == type ? const Icon(Icons.check, size: 18) : null,
        dense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: Text(l10n.buttonRetry)),
        ],
      ),
    );
  }
}

class _GameSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final games = [l10n.darkSouls3];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        initialValue: games.first,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.sports_esports, size: 20),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(),
          isDense: true,
        ),
        items: [
          ...games.map(
            (g) => DropdownMenuItem(value: g, child: Text(g)),
          ),
          DropdownMenuItem(
            enabled: false,
            value: null,
            child: Tooltip(
              message: l10n.gameComingSoonTooltip,
              child: const Text('Elden Ring', style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
        onChanged: (_) {},
      ),
    );
  }
}

class _LaunchGameButton extends StatelessWidget {
  final VoidCallback onSetupTap;

  const _LaunchGameButton({required this.onSetupTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: l10n.launchGameDisabledTooltip,
          child: FilledButton.tonalIcon(
            onPressed: null,
            icon: const Icon(Icons.rocket_launch),
            label: Text(l10n.launchGameButton),
          ),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: onSetupTap,
          child: Text(l10n.setUpSteamButton),
        ),
      ],
    );
  }
}
