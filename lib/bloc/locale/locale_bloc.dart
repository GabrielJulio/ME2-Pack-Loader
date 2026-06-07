import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/locale_resolver.dart';
import '../../services/preferences_service.dart';
import 'locale_event.dart';
import 'locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  final PreferencesService preferencesService;
  final List<Locale> Function() systemLocalesProvider;

  LocaleBloc({
    required this.preferencesService,
    required this.systemLocalesProvider,
  }) : super(LocaleInitial()) {
    on<LocaleStarted>(_onStarted);
    on<LocaleChanged>(_onChanged);
  }

  Future<void> _onChanged(LocaleChanged event, Emitter<LocaleState> emit) async {
    await preferencesService.setLocale(event.code);
    emit(LocaleLoaded(event.code));
  }

  Future<void> _onStarted(LocaleStarted event, Emitter<LocaleState> emit) async {
    final stored = await preferencesService.getLocale();
    if (stored != null) {
      emit(LocaleLoaded(stored));
      return;
    }
    final detected = LocaleResolver.resolve(systemLocalesProvider());
    await preferencesService.setLocale(detected);
    emit(LocaleLoaded(detected));
  }
}
