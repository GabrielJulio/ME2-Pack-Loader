import '../models/game.dart';
import 'pack_service.dart';

/// Builds the Steam launch-options command for a given game.
///
/// Per ADR-0002, the command always points at `config.toml` (the active-pack
/// mirror). Switching packs in-app rewrites `config.toml`, so the user pastes
/// this string into Steam once and never has to revisit it after changing
/// packs.
class SteamCommandService {
  static String buildCommand({
    required Game game,
    required String gameBaseDir,
    required String me2LauncherPath,
  }) {
    return 'bash -c \'cd "$gameBaseDir" '
        r'&& exec "${@:1:$(($#-1))}" '
        '"$me2LauncherPath" '
        '-t ${game.me2GameFlag} '
        '-c ${PackService.activeFileName}\' -- %command%';
  }
}
