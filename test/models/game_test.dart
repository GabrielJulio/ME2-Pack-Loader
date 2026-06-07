import 'package:flutter_test/flutter_test.dart';
import 'package:me2_pack_loader/models/game.dart';

void main() {
  group('Game enum', () {
    test('has Dark Souls III, Elden Ring, Dark Souls: Remastered', () {
      expect(Game.values, hasLength(3));
      expect(Game.darkSouls3.displayName, equals('Dark Souls III'));
      expect(Game.eldenRing.displayName, equals('Elden Ring'));
      expect(
        Game.darkSoulsRemastered.displayName,
        equals('Dark Souls: Remastered'),
      );
    });

    test('slug uses snake_case folder names', () {
      expect(Game.darkSouls3.slug, equals('dark_souls_3'));
      expect(Game.eldenRing.slug, equals('elden_ring'));
      expect(Game.darkSoulsRemastered.slug, equals('dark_souls_remastered'));
    });

    test('Game.fromSlug returns the matching value or null', () {
      expect(Game.fromSlug('elden_ring'), equals(Game.eldenRing));
      expect(Game.fromSlug('unknown'), isNull);
    });
  });
}
