import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/locale/locale_bloc.dart';
import '../bloc/locale/locale_event.dart';
import '../bloc/locale/locale_state.dart';
import '../l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleBloc, LocaleState>(
      builder: (context, state) {
        final current = state is LocaleLoaded ? state.code : 'en';
        return DropdownButtonFormField<String>(
          initialValue: current,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.language, size: 20),
            labelText: AppLocalizations.of(context).languageLabel,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            border: const OutlineInputBorder(),
            isDense: true,
          ),
          items: const [
            DropdownMenuItem(value: 'en', child: Text('English')),
            DropdownMenuItem(value: 'pt', child: Text('Português (Brasil)')),
          ],
          onChanged: (code) {
            if (code == null || code == current) return;
            context.read<LocaleBloc>().add(LocaleChanged(code));
          },
        );
      },
    );
  }
}
