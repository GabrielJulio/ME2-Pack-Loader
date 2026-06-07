sealed class DataDirStatus {
  const DataDirStatus();
}

class DefaultDataDir extends DataDirStatus {
  const DefaultDataDir();
}

class CustomDataDir extends DataDirStatus {
  final String path;
  const CustomDataDir(this.path);
}

class MissingDataDir extends DataDirStatus {
  final String path;
  const MissingDataDir(this.path);
}
