import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/layout_type.dart';
import '../../services/preferences_service.dart';
import 'layout_event.dart';
import 'layout_state.dart';

class LayoutBloc extends Bloc<LayoutEvent, LayoutState> {
  final PreferencesService preferencesService;

  LayoutBloc({required this.preferencesService})
      : super(const LayoutState(LayoutType.defaultMaterial)) {
    on<LayoutStarted>(_onStarted);
    on<LayoutSelected>(_onSelected);
  }

  Future<void> _onStarted(
    LayoutStarted event,
    Emitter<LayoutState> emit,
  ) async {
    final value = await preferencesService.getLayout();
    emit(LayoutState(LayoutType.fromValue(value)));
  }

  Future<void> _onSelected(
    LayoutSelected event,
    Emitter<LayoutState> emit,
  ) async {
    await preferencesService.setLayout(event.type.value);
    emit(LayoutState(event.type));
  }
}
