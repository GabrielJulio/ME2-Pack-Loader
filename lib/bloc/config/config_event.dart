import 'dart:io';

import '../../models/mod.dart';

abstract class ConfigEvent {}

class ConfigLoadRequested extends ConfigEvent {
  final Directory baseDir;
  ConfigLoadRequested(this.baseDir);
}

class ModToggled extends ConfigEvent {
  final int index;
  ModToggled(this.index);
}

class ModReordered extends ConfigEvent {
  final int oldIndex;
  final int newIndex;
  ModReordered(this.oldIndex, this.newIndex);
}

class ModAdded extends ConfigEvent {
  final Mod mod;
  ModAdded(this.mod);
}

class ModUpdated extends ConfigEvent {
  final int index;
  final Mod mod;
  ModUpdated(this.index, this.mod);
}

class ModRemoved extends ConfigEvent {
  final int index;
  ModRemoved(this.index);
}

class DllAdded extends ConfigEvent {
  final String path;
  DllAdded(this.path);
}

class DllRemoved extends ConfigEvent {
  final int index;
  DllRemoved(this.index);
}

class DllReordered extends ConfigEvent {
  final int oldIndex;
  final int newIndex;
  DllReordered(this.oldIndex, this.newIndex);
}

class DebugToggled extends ConfigEvent {}

class ModLoaderEnabledToggled extends ConfigEvent {}

class LooseParamsToggled extends ConfigEvent {}

class ScyllaHideToggled extends ConfigEvent {}
