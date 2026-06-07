import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:me2_pack_loader/services/locale_resolver.dart';

void main() {
  group('LocaleResolver.resolve', () {
    test('returns pt when any system locale has pt as language code', () {
      final code = LocaleResolver.resolve(const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ]);

      expect(code, equals('pt'));
    });

    test('returns en when no system locale matches a supported language', () {
      final code = LocaleResolver.resolve(const [
        Locale('fr', 'FR'),
        Locale('de', 'DE'),
      ]);

      expect(code, equals('en'));
    });

    test('returns en when the system list is empty', () {
      final code = LocaleResolver.resolve(const []);

      expect(code, equals('en'));
    });

    test('honours preference order — earlier locale wins', () {
      final code = LocaleResolver.resolve(const [
        Locale('en', 'US'),
        Locale('pt', 'BR'),
      ]);

      expect(code, equals('en'));
    });
  });
}
