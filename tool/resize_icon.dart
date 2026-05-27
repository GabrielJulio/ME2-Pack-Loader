import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final src = img.decodePng(File('me2_pack_loader.png').readAsBytesSync())!;
  final resized = img.copyResize(src, width: 256, height: 256, interpolation: img.Interpolation.cubic);
  File('packaging/me2_pack_loader.png').writeAsBytesSync(img.encodePng(resized));
  File('assets/icon.png').writeAsBytesSync(img.encodePng(
    img.copyResize(src, width: 512, height: 512, interpolation: img.Interpolation.cubic),
  ));
}
