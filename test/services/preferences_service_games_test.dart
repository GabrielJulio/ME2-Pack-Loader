import 'package:flutter_test/flutter_test.dart';
import 'package:me2_pack_loader/models/game.dart';
import 'package:me2_pack_loader/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PreferencesService — games', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('getActivatedGames returns empty when nothing stored', () async {
      expect(await PreferencesService().getActivatedGames(), isEmpty);
    });

    test('setActivatedGames round-trips a set', () async {
      final prefs = PreferencesService();

      await prefs.setActivatedGames({Game.darkSouls3, Game.eldenRing});

      expect(
        await prefs.getActivatedGames(),
        equals({Game.darkSouls3, Game.eldenRing}),
      );
    });

    test('getCurrentGame returns null until set', () async {
      expect(await PreferencesService().getCurrentGame(), isNull);
    });

    test('setCurrentGame round-trips', () async {
      final prefs = PreferencesService();

      await prefs.setCurrentGame(Game.eldenRing);

      expect(await prefs.getCurrentGame(), equals(Game.eldenRing));
    });
  });
}
