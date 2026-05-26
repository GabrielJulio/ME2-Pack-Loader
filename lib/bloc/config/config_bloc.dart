import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/game_config.dart';
import '../../services/config_service.dart';
import 'config_event.dart';
import 'config_state.dart';

class ConfigBloc extends Bloc<ConfigEvent, ConfigState> {
  final ConfigService configService;

  ConfigBloc({required this.configService}) : super(ConfigInitial()) {
    on<ConfigLoadRequested>(_onLoadRequested);
    on<ModToggled>(_onModToggled);
    on<ModReordered>(_onModReordered);
    on<ModAdded>(_onModAdded);
    on<ModUpdated>(_onModUpdated);
    on<ModRemoved>(_onModRemoved);
    on<DllAdded>(_onDllAdded);
    on<DllRemoved>(_onDllRemoved);
    on<DllReordered>(_onDllReordered);
    on<DebugToggled>(_onDebugToggled);
    on<ModLoaderEnabledToggled>(_onModLoaderEnabledToggled);
    on<LooseParamsToggled>(_onLooseParamsToggled);
    on<ScyllaHideToggled>(_onScyllaHideToggled);
  }

  Future<void> _onLoadRequested(
    ConfigLoadRequested event,
    Emitter<ConfigState> emit,
  ) async {
    emit(ConfigLoading());
    try {
      final file = await configService.resolveConfig(event.baseDir);
      final config = await configService.read(file);
      await configService.touch(file);
      emit(ConfigLoaded(config: config, configFile: file, baseDir: event.baseDir));
    } catch (e) {
      emit(ConfigError('Failed to load config: $e'));
    }
  }

  Future<void> _onModToggled(ModToggled event, Emitter<ConfigState> emit) =>
      _update(emit, (loaded) {
        final mods = List.of(loaded.config.mods);
        mods[event.index] = mods[event.index].copyWith(
          enabled: !mods[event.index].enabled,
        );
        return loaded.config.copyWith(mods: mods);
      });

  Future<void> _onModReordered(ModReordered event, Emitter<ConfigState> emit) =>
      _update(emit, (loaded) {
        final mods = List.of(loaded.config.mods);

        var newIndex = event.newIndex;
        if (newIndex > event.oldIndex) newIndex -= 1;
        final item = mods.removeAt(event.oldIndex);
        mods.insert(newIndex, item);
        return loaded.config.copyWith(mods: mods);
      });

  Future<void> _onModAdded(ModAdded event, Emitter<ConfigState> emit) =>
      _update(emit, (loaded) => loaded.config.copyWith(
            mods: [...loaded.config.mods, event.mod],
          ));

  Future<void> _onModUpdated(ModUpdated event, Emitter<ConfigState> emit) =>
      _update(emit, (loaded) {
        final mods = List.of(loaded.config.mods);
        mods[event.index] = event.mod;
        return loaded.config.copyWith(mods: mods);
      });

  Future<void> _onModRemoved(ModRemoved event, Emitter<ConfigState> emit) =>
      _update(emit, (loaded) {
        final mods = List.of(loaded.config.mods);
        mods.removeAt(event.index);
        return loaded.config.copyWith(mods: mods);
      });

  Future<void> _onDllAdded(DllAdded event, Emitter<ConfigState> emit) =>
      _update(emit, (loaded) => loaded.config.copyWith(
            externalDlls: [...loaded.config.externalDlls, event.path],
          ));

  Future<void> _onDllRemoved(DllRemoved event, Emitter<ConfigState> emit) =>
      _update(emit, (loaded) {
        final dlls = List.of(loaded.config.externalDlls);
        dlls.removeAt(event.index);
        return loaded.config.copyWith(externalDlls: dlls);
      });

  Future<void> _onDllReordered(DllReordered event, Emitter<ConfigState> emit) =>
      _update(emit, (loaded) {
        final dlls = List.of(loaded.config.externalDlls);
        var newIndex = event.newIndex;
        if (newIndex > event.oldIndex) newIndex -= 1;
        final item = dlls.removeAt(event.oldIndex);
        dlls.insert(newIndex, item);
        return loaded.config.copyWith(externalDlls: dlls);
      });

  Future<void> _onDebugToggled(DebugToggled event, Emitter<ConfigState> emit) =>
      _update(emit, (loaded) => loaded.config.copyWith(debug: !loaded.config.debug));

  Future<void> _onModLoaderEnabledToggled(
    ModLoaderEnabledToggled event,
    Emitter<ConfigState> emit,
  ) =>
      _update(emit, (loaded) => loaded.config.copyWith(
            modLoaderEnabled: !loaded.config.modLoaderEnabled,
          ));

  Future<void> _onLooseParamsToggled(
    LooseParamsToggled event,
    Emitter<ConfigState> emit,
  ) =>
      _update(emit, (loaded) => loaded.config.copyWith(
            looseParams: !loaded.config.looseParams,
          ));

  Future<void> _onScyllaHideToggled(
    ScyllaHideToggled event,
    Emitter<ConfigState> emit,
  ) =>
      _update(emit, (loaded) => loaded.config.copyWith(
            scyllaHideEnabled: !loaded.config.scyllaHideEnabled,
          ));

  Future<void> _update(
    Emitter<ConfigState> emit,
    GameConfig Function(ConfigLoaded loaded) updater,
  ) async {
    final current = state;
    if (current is! ConfigLoaded) return;

    try {
      final newConfig = updater(current);
      await configService.write(current.configFile, newConfig);
      emit(ConfigLoaded(
        config: newConfig,
        configFile: current.configFile,
        baseDir: current.baseDir,
      ));
    } catch (e) {
      emit(ConfigError('Failed to save config: $e'));
    }
  }
}
