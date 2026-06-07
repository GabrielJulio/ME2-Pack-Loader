import 'package:flutter/material.dart';

import '../../models/layout_type.dart';

class LayoutState {
  final LayoutType type;
  final Color? accentColor;
  const LayoutState(this.type, {this.accentColor});
}
