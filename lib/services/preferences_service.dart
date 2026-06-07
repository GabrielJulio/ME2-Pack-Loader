import 'package:shared_preferences/shared_preferences.dart';

import '../models/game.dart';

class PreferencesService {
  static const _keyModEngineDir = 'mod_engine_dir';
  static const _keySteamCommandShown = 'steam_command_shown';
  static const _keyLayout = 'layout';
  static const _keyLocale = 'locale';
  static const _keyActivatedGames = 'activated_games';
  static const _keyCurrentGame = 'current_game';

  Future<String?> getModEngineDir() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyModEngineDir);
  }

  Future<void> setModEngineDir(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyModEngineDir, path);
  }

  Future<bool> getSteamCommandShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySteamCommandShown) ?? false;
  }

  Future<void> setSteamCommandShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySteamCommandShown, true);
  }

  Future<String> getLayout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLayout) ?? 'default';
  }

  Future<void> setLayout(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLayout, value);
  }

  Future<String?> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLocale);
  }

  Future<void> setLocale(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, code);
  }

  Future<Set<Game>> getActivatedGames() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_keyActivatedGames) ?? const [];
    return raw.map(Game.fromSlug).whereType<Game>().toSet();
  }

  Future<void> setActivatedGames(Set<Game> games) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _keyActivatedGames,
      games.map((g) => g.slug).toList(),
    );
  }

  Future<Game?> getCurrentGame() async {
    final prefs = await SharedPreferences.getInstance();
    final slug = prefs.getString(_keyCurrentGame);
    return slug == null ? null : Game.fromSlug(slug);
  }

  Future<void> setCurrentGame(Game game) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCurrentGame, game.slug);
  }
}
