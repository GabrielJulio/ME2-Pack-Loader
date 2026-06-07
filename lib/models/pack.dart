import 'dart:io';

class Pack {
  final String slug;
  final File file;
  final DateTime modifiedAt;

  const Pack({
    required this.slug,
    required this.file,
    required this.modifiedAt,
  });
}
