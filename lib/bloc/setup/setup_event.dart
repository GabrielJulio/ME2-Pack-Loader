abstract class SetupEvent {}

class SetupStarted extends SetupEvent {}

class SetupFolderSelected extends SetupEvent {
  final String path;
  SetupFolderSelected(this.path);
}
