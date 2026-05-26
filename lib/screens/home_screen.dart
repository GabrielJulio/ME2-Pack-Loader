import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/config/config_bloc.dart';
import '../bloc/config/config_event.dart';
import '../bloc/config/config_state.dart';
import '../bloc/layout/layout_bloc.dart';
import '../bloc/layout/layout_event.dart';
import '../bloc/layout/layout_state.dart';
import '../models/layout_type.dart';
import '../services/config_service.dart';
import '../services/mod_service.dart';
import '../services/preferences_service.dart';
import '../widgets/external_dll_list.dart';
import '../widgets/gnome_layout.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('ME2 Pack Loader'),
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.sports_esports, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Dark Souls III',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  const SettingsPanel(),
                  const Divider(),
                  ExternalDllList(baseDir: baseDir),
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
    return BlocBuilder<LayoutBloc, LayoutState>(
      builder: (context, state) {
        return PopupMenuButton<LayoutType>(
          icon: const Icon(Icons.view_quilt_outlined),
          tooltip: 'Switch layout',
          onSelected: (type) =>
              context.read<LayoutBloc>().add(LayoutSelected(type)),
          itemBuilder: (_) => [
            _layoutMenuItem(
              type: LayoutType.defaultMaterial,
              current: state.type,
              icon: Icons.view_sidebar_outlined,
              label: 'Default',
            ),
            _layoutMenuItem(
              type: LayoutType.gnome,
              current: state.type,
              icon: Icons.view_list_outlined,
              label: 'GNOME',
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _LaunchGameButton extends StatelessWidget {
  final VoidCallback onSetupTap;

  const _LaunchGameButton({required this.onSetupTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Configure Steam launch options first',
          child: FilledButton.tonalIcon(
            onPressed: null,
            icon: const Icon(Icons.rocket_launch),
            label: const Text('Launch Game'),
          ),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: onSetupTap,
          child: const Text('Set up Steam'),
        ),
      ],
    );
  }
}
