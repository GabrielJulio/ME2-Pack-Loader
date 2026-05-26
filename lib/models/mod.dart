import 'package:flutter/foundation.dart';

@immutable
class Mod {
  final bool enabled;
  final String name;
  final String path;

  const Mod({
    required this.enabled,
    required this.name,
    required this.path,
  });

  Mod copyWith({bool? enabled, String? name, String? path}) => Mod(
        enabled: enabled ?? this.enabled,
        name: name ?? this.name,
        path: path ?? this.path,
      );

  factory Mod.fromMap(Map<String, dynamic> map) => Mod(
        enabled: map['enabled'] as bool? ?? true,
        name: map['name'] as String,
        path: map['path'] as String,
      );

  @override
  bool operator ==(Object other) =>
      other is Mod &&
      other.enabled == enabled &&
      other.name == name &&
      other.path == path;

  @override
  int get hashCode => Object.hash(enabled, name, path);
}
