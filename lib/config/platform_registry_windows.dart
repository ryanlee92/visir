import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:ui';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:ffi/ffi.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:win32/win32.dart' as win32;
import 'package:win32_registry/win32_registry.dart';

void setupRegistry() {
  register('com.wavetogether.fillin');
  register('com.wavetogether.fillin.slack');
}

Future<void> register(String scheme) async {
  String appPath = Platform.resolvedExecutable;

  String protocolRegKey = 'Software\\Classes\\$scheme';
  RegistryValue protocolRegValue = RegistryValue.string('URL Protocol', '');

  String protocolCmdRegKey = 'shell\\open\\command';
  RegistryValue protocolCmdRegValue = RegistryValue.string('', '"$appPath" "%1"');

  final regKey = Registry.currentUser.createKey(protocolRegKey);
  regKey.createValue(protocolRegValue);
  regKey.createKey(protocolCmdRegKey).createValue(protocolCmdRegValue);

  const keyPath = r'Software\Microsoft\Windows\CurrentVersion\Run';
  final key = Registry.openPath(RegistryHive.currentUser, path: keyPath);

  final versionKey = key.getStringValue('Visir');
  if (versionKey != null) launchAtStartup.enable();
}

Future<({Offset offset, Size size})> getWindowsWindowFrame() async {
  ffi.Pointer<win32.RECT>? rectPtr;
  try {
    final hwnd = appWindow.handle!;
    rectPtr = calloc.allocate<win32.RECT>(ffi.sizeOf<win32.RECT>());
    if (win32.GetWindowRect(hwnd, rectPtr) == 0) {
      throw Exception('GetWindowRect failed');
    }
    final r = rectPtr.ref;
    final scale = appWindow.scaleFactor;
    Offset now = Offset(r.left / scale, r.top / scale);
    Size size = Size((r.right - r.left) / scale, (r.bottom - r.top) / scale);
    return (offset: now, size: size);
  } finally {
    if (rectPtr != null) calloc.free(rectPtr);
  }
}
