import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:me2_pack_loader/bloc/layout/layout_bloc.dart';
import 'package:me2_pack_loader/bloc/layout/layout_event.dart';
import 'package:me2_pack_loader/bloc/layout/layout_state.dart';
import 'package:me2_pack_loader/models/layout_type.dart';
import 'package:me2_pack_loader/services/desktop_environment_service.dart';
import 'package:me2_pack_loader/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LayoutBloc auto-detect', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('on GNOME with readable accent → emits gnome + that color', () async {
      final bloc = LayoutBloc(
        preferencesService: PreferencesService(),
        desktopEnvironmentService: DesktopEnvironmentService(
          environment: const {'XDG_CURRENT_DESKTOP': 'GNOME'},
          isLinux: true,
          gsettingsResult: () async => 'red',
        ),
      );

      bloc.add(LayoutStarted());

      await expectLater(
        bloc.stream,
        emits(predicate<LayoutState>(
          (s) =>
              s.type == LayoutType.gnome &&
              s.accentColor == const Color(0xFFE62D42),
        )),
      );

      await bloc.close();
    });

    test('on GNOME with no accent → falls back to Material', () async {
      final bloc = LayoutBloc(
        preferencesService: PreferencesService(),
        desktopEnvironmentService: DesktopEnvironmentService(
          environment: const {'XDG_CURRENT_DESKTOP': 'GNOME'},
          isLinux: true,
          gsettingsResult: () async => null,
        ),
      );

      bloc.add(LayoutStarted());

      await expectLater(
        bloc.stream,
        emits(predicate<LayoutState>(
          (s) =>
              s.type == LayoutType.defaultMaterial && s.accentColor == null,
        )),
      );

      await bloc.close();
    });

    test('not on GNOME → Material with no accent override', () async {
      final bloc = LayoutBloc(
        preferencesService: PreferencesService(),
        desktopEnvironmentService: DesktopEnvironmentService(
          environment: const {'XDG_CURRENT_DESKTOP': 'KDE'},
          isLinux: true,
          gsettingsResult: () async => null,
        ),
      );

      bloc.add(LayoutStarted());

      await expectLater(
        bloc.stream,
        emits(predicate<LayoutState>(
          (s) =>
              s.type == LayoutType.defaultMaterial && s.accentColor == null,
        )),
      );

      await bloc.close();
    });
  });
}
