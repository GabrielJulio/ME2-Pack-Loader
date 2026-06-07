abstract class LocaleState {}

class LocaleInitial extends LocaleState {}

class LocaleLoaded extends LocaleState {
  final String code;
  LocaleLoaded(this.code);
}
