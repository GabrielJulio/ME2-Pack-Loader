import 'package:flutter_test/flutter_test.dart';
import 'package:me2_pack_loader/models/game.dart';
import 'package:me2_pack_loader/services/steam_command_service.dart';

void main() {
  group('SteamCommandService.buildCommand', () {
    test('embeds game base dir, launcher path, game flag, and config.toml', () {
      final command = SteamCommandService.buildCommand(
        game: Game.darkSouls3,
        gameBaseDir: '/home/me/.local/share/me2_pack_loader/modengine2/dark_souls_3',
        me2LauncherPath:
            '/home/me/.local/share/me2_pack_loader/modengine2/modengine2_launcher.exe',
      );

      expect(command, contains('cd "/home/me/.local/share/me2_pack_loader/modengine2/dark_souls_3"'));
      expect(command, contains(
          '"/home/me/.local/share/me2_pack_loader/modengine2/modengine2_launcher.exe"'));
      expect(command, contains('-t ds3'));
      expect(command, contains('-c config.toml'));
      expect(command, endsWith('-- %command%'));
    });

    test('uses each Game\'s me2GameFlag', () {
      final ds3 = SteamCommandService.buildCommand(
        game: Game.darkSouls3,
        gameBaseDir: '/base',
        me2LauncherPath: '/launcher',
      );
      final er = SteamCommandService.buildCommand(
        game: Game.eldenRing,
        gameBaseDir: '/base',
        me2LauncherPath: '/launcher',
      );
      final dsr = SteamCommandService.buildCommand(
        game: Game.darkSoulsRemastered,
        gameBaseDir: '/base',
        me2LauncherPath: '/launcher',
      );

      expect(ds3, contains('-t ds3'));
      expect(er, contains('-t er'));
      expect(dsr, contains('-t dsr-like'));
    });
  });
}
