import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _keyModEngineDir = 'mod_engine_dir';
  static const _keySteamCommandShown = 'steam_command_shown';
  static const _keyLayout = 'layout';

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
}
