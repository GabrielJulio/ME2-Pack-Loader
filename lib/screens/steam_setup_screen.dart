import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';

class SteamSetupScreen extends StatelessWidget {
  const SteamSetupScreen({super.key});

  static const _placeholderCommand = '# Launch command — coming in a future update';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          _placeholderCommand,
                          style: const TextStyle(fontFamily: 'monospace'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: l10n.copyToClipboardTooltip,
                        onPressed: () {
                          Clipboard.setData(
                            const ClipboardData(text: _placeholderCommand),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.copiedToClipboard)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
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
