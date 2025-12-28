import 'dart:ui';

void setupRegistry() {
  // No-op: not supported on this platform
}

Future<({Offset offset, Size size})> getWindowsWindowFrame() async {
  return (offset: Offset(0, 0), size: Size(0, 0));
}
