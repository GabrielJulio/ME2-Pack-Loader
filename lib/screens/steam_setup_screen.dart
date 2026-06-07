import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../models/game.dart';
import '../services/steam_command_service.dart';

class SteamSetupScreen extends StatelessWidget {
  final Game game;
  final String gameBaseDir;
  final String me2LauncherPath;

  const SteamSetupScreen({
    super.key,
    required this.game,
    required this.gameBaseDir,
    required this.me2LauncherPath,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final command = SteamCommandService.buildCommand(
      game: game,
      gameBaseDir: gameBaseDir,
      me2LauncherPath: me2LauncherPath,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.steamSetupTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.steamSetupHeading,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(l10n.steamSetupInstructions),
                const SizedBox(height: 24),
                _CopyableCommand(command: command),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.buttonDone),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CopyableCommand extends StatelessWidget {
  final String command;

  const _CopyableCommand({required this.command});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: SelectableText(
              command,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: l10n.copyToClipboardTooltip,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: command));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.copiedToClipboard)),
              );
            },
          ),
        ],
      ),
    );
  }
}
