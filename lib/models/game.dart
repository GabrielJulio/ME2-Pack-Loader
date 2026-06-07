enum Game {
  darkSouls3('Dark Souls III', 'dark_souls_3', 'ds3'),
  eldenRing('Elden Ring', 'elden_ring', 'er'),
  darkSoulsRemastered(
    'Dark Souls: Remastered',
    'dark_souls_remastered',
    // TODO(modengine2): replace 'dsr-like' with the real -t flag from the
    // DSR-compatible ModEngine2 fork once the URL is supplied.
    'dsr-like',
  );

  final String displayName;
  final String slug;
  final String me2GameFlag;

  const Game(this.displayName, this.slug, this.me2GameFlag);

  static Game? fromSlug(String slug) {
    for (final game in Game.values) {
      if (game.slug == slug) return game;
    }
    return null;
  }
}
