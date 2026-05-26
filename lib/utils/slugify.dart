String slugify(String input) => input
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
    .replaceAll(RegExp(r'^_+|_+$'), '');
