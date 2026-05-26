import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/preferences_service.dart';
import 'setup_event.dart';
import 'setup_state.dart';

class SetupBloc extends Bloc<SetupEvent, SetupState> {
  final PreferencesService preferencesService;

  SetupBloc({required this.preferencesService}) : super(SetupCheckingPrefs()) {
    on<SetupStarted>(_onStarted);
    on<SetupFolderSelected>(_onFolderSelected);
  }

  Future<void> _onStarted(
    SetupStarted event,
    Emitter<SetupState> emit,
  ) async {
    emit(SetupCheckingPrefs());

    final envDir = Platform.environment['MODENGINE_DIR'];
    if (envDir != null && envDir.isNotEmpty) {
      emit(SetupComplete(envDir));
      return;
    }

    final dir = await preferencesService.getModEngineDir();
    if (dir != null && dir.isNotEmpty) {
      emit(SetupComplete(dir));
    } else {
      emit(SetupNeedsFolder());
    }
  }

  Future<void> _onFolderSelected(
    SetupFolderSelected event,
    Emitter<SetupState> emit,
  ) async {
    await preferencesService.setModEngineDir(event.path);
    emit(SetupComplete(event.path));
  }
}
