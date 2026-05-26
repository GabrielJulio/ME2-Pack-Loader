enum LayoutType {
  defaultMaterial('default'),
  gnome('gnome');

  final String value;
  const LayoutType(this.value);

  static LayoutType fromValue(String value) => LayoutType.values.firstWhere(
        (t) => t.value == value,
        orElse: () => LayoutType.defaultMaterial,
      );
}
