abstract class SetupState {}

class SetupCheckingPrefs extends SetupState {}

class SetupNeedsFolder extends SetupState {}

class SetupComplete extends SetupState {
  final String modEngineDir;
  SetupComplete(this.modEngineDir);
}
