import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SteamSetupScreen extends StatelessWidget {
  const SteamSetupScreen({super.key});

  static const _placeholderCommand = '# Launch command — coming in a future update';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set up Steam')),
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
                  'Add ME2 Pack Loader to Steam',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                const Text(
                  '1. Open Steam\n'
                  '2. Right-click Dark Souls III in your library\n'
                  '3. Choose Properties → Launch Options\n'
                  '4. Paste the command below and click OK',
                ),
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
                        tooltip: 'Copy to clipboard',
                        onPressed: () {
                          Clipboard.setData(
                            const ClipboardData(text: _placeholderCommand),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied to clipboard')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
