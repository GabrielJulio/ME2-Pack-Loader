import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/mod_service.dart';
import 'external_dll_list.dart';
import 'mod_list.dart';
import 'settings_panel.dart';

const _gnomeAccent = Color(0xFF8AB4F8);
const _background  = Color(0xFF070607);
const _surface1    = Color(0xFF100E10);
const _surface3    = Color(0xFF1D191D);
const _border      = Color(0xFF2C272B);
const _textPrimary = Color(0xFFF1E9E5);
const _textMuted   = Color(0xFFB9AAA5);
const _error       = Color(0xFFCF6679);

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

  ThemeData _buildGnomeTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary:     _gnomeAccent,
        onPrimary:   _background,
        secondary:   _gnomeAccent,
        onSecondary: _background,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor:    _textPrimary,
        displayColor: _textPrimary,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: _surface1,
        indicatorColor: _gnomeAccent.withValues(alpha: 0.15),
        unselectedIconTheme: const IconThemeData(color: _textMuted),
        selectedIconTheme: const IconThemeData(color: _gnomeAccent),
        selectedLabelTextStyle: const TextStyle(
          color: _gnomeAccent,
          fontWeight: FontWeight.w600,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? _gnomeAccent : _textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? _gnomeAccent.withValues(alpha: 0.4)
              : _surface3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _buildGnomeTheme(context),
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
                label: Text('External DLLs'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bug_report_outlined),
                selectedIcon: Icon(Icons.bug_report),
                label: Text('Debug'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.info_outlined),
                selectedIcon: Icon(Icons.info),
                label: Text('About'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1, color: _border),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                ModList(baseDir: widget.baseDir, modService: widget.modService),
                _SettingsPage(),
                _DllsPage(baseDir: widget.baseDir),
                _DebugPage(),
                const _AboutPage(),
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
              Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              const SettingsPanel(hideDebug: true),
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
              Text('External DLLs', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              ExternalDllList(baseDir: baseDir),
            ],
          ),
        ),
      ),
    );
  }
}

class _DebugPage extends StatelessWidget {
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
              Text('Debug', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Developer options. Disable before playing online.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: _textMuted),
              ),
              const SizedBox(height: 16),
              const SettingsPanel(debugOnly: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutPage extends StatelessWidget {
  const _AboutPage();

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
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset('assets/icon.png', width: 64, height: 64),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ME2 Pack Loader',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        'v1.0.0',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: _textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'A GUI for managing ModEngine2 mod packs for FromSoftware games.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              const Divider(color: _border),
              const SizedBox(height: 16),
              Text(
                'Unofficial community tool. Not affiliated with FromSoftware, '
                'Bandai Namco, or the ModEngine2 team.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: _textMuted),
              ),
              const SizedBox(height: 8),
              Text(
                '⚠ Always play offline when using mods to avoid Easy Anti-Cheat bans.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: _error),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
