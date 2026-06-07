import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:me2_pack_loader/bloc/locale/locale_bloc.dart';
import 'package:me2_pack_loader/bloc/locale/locale_event.dart';
import 'package:me2_pack_loader/bloc/locale/locale_state.dart';
import 'package:me2_pack_loader/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LocaleBloc', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
        'first launch with pt system locale: detects pt, stores it, '
        'emits LocaleLoaded(pt)', () async {
      final bloc = LocaleBloc(
        preferencesService: PreferencesService(),
        systemLocalesProvider: () => const [Locale('pt', 'BR')],
      );

      bloc.add(LocaleStarted());

      await expectLater(
        bloc.stream,
        emits(isA<LocaleLoaded>().having((s) => s.code, 'code', 'pt')),
      );

      expect(await PreferencesService().getLocale(), equals('pt'));
      await bloc.close();
    });

    test(
        'subsequent launch with stored locale: emits stored without consulting '
        'system locales', () async {
      SharedPreferences.setMockInitialValues({'locale': 'en'});

      var providerCallCount = 0;
      final bloc = LocaleBloc(
        preferencesService: PreferencesService(),
        systemLocalesProvider: () {
          providerCallCount += 1;
          return const [Locale('pt', 'BR')];
        },
      );

      bloc.add(LocaleStarted());

      await expectLater(
        bloc.stream,
        emits(isA<LocaleLoaded>().having((s) => s.code, 'code', 'en')),
      );

      expect(providerCallCount, equals(0),
          reason: 'stored value short-circuits detection');
      await bloc.close();
    });

    test('LocaleChanged persists the new code and emits LocaleLoaded(new)',
        () async {
      SharedPreferences.setMockInitialValues({'locale': 'en'});

      final prefs = PreferencesService();
      final bloc = LocaleBloc(
        preferencesService: prefs,
        systemLocalesProvider: () => const [],
      );

      bloc.add(LocaleStarted());
      await expectLater(
        bloc.stream,
        emits(isA<LocaleLoaded>().having((s) => s.code, 'code', 'en')),
      );

      bloc.add(LocaleChanged('pt'));
      await expectLater(
        bloc.stream,
        emits(isA<LocaleLoaded>().having((s) => s.code, 'code', 'pt')),
      );

      expect(await prefs.getLocale(), equals('pt'));
      await bloc.close();
    });
  });
}
