import '../../models/layout_type.dart';

abstract class LayoutEvent {}

class LayoutStarted extends LayoutEvent {}

class LayoutSelected extends LayoutEvent {
  final LayoutType type;
  LayoutSelected(this.type);
}
