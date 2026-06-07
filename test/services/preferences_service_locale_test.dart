import 'package:flutter_test/flutter_test.dart';
import 'package:me2_pack_loader/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PreferencesService — locale', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('getLocale returns null when no locale has been stored', () async {
      final prefs = PreferencesService();

      expect(await prefs.getLocale(), isNull);
    });

    test('setLocale persists the value retrievable by getLocale', () async {
      final prefs = PreferencesService();

      await prefs.setLocale('pt');

      expect(await prefs.getLocale(), equals('pt'));
    });
  });
}
