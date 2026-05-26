import 'dart:io';

import 'package:flutter/material.dart';

import '../services/mod_service.dart';
import 'external_dll_list.dart';
import 'mod_list.dart';
import 'settings_panel.dart';

class GnomeLayout extends StatefulWidget {
  final Directory baseDir;
  final ModService modService;

  const GnomeLayout({
    super.key,
    required this.baseDir,
    required this.modService,
  });

  @override
  State<GnomeLayout> createState() => _GnomeLayoutState();
}

class _GnomeLayoutState extends State<GnomeLayout> {
  int _selectedIndex = 0;

  static final _gnomeTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _gnomeTheme,
      child: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
            labelType: NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.extension_outlined),
                selectedIcon: Icon(Icons.extension),
                label: Text('Mods'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.code_outlined),
                selectedIcon: Icon(Icons.code),
                label: Text('DLLs'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                ModList(baseDir: widget.baseDir, modService: widget.modService),
                _SettingsPage(),
                _DllsPage(baseDir: widget.baseDir),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              const SettingsPanel(),
            ],
          ),
        ),
      ),
    );
  }
}

class _DllsPage extends StatelessWidget {
  final Directory baseDir;

  const _DllsPage({required this.baseDir});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'External DLLs',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              ExternalDllList(baseDir: baseDir),
            ],
          ),
        ),
      ),
    );
  }
}
