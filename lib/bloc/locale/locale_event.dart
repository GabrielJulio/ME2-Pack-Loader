abstract class LocaleEvent {}

class LocaleStarted extends LocaleEvent {}

class LocaleChanged extends LocaleEvent {
  final String code;
  LocaleChanged(this.code);
}
