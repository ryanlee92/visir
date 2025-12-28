import 'dart:io';

import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:flutter/foundation.dart';

extension PlatformX on Platform {
  static bool get isDesktop {
    if (kIsWeb) return true;
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  static bool get isPureDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  static bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  static bool get isAppAuthSupported {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid || Platform.isMacOS;
  }

  static bool get isDesktopView {
    return !isMobileView;
  }

  static bool get isMobileView {
    if (kIsWeb) return false;
    if (isDesktop) return false;
    return Utils.windowSize.width <= 1080;
  }

  static bool get isMacOS {
    return !kIsWeb && Platform.isMacOS;
  }

  static bool get isWindows {
    return !kIsWeb && Platform.isWindows;
  }

  static bool get isAndroid {
    return !kIsWeb && Platform.isAndroid;
  }

  static bool get isIOS {
    return !kIsWeb && Platform.isIOS;
  }

  static bool get isApple {
    return isIOS || isMacOS;
  }

  static bool get isWeb {
    return kIsWeb;
  }

  static bool get isLinux {
    return !kIsWeb && Platform.isLinux;
  }

  static bool get isGoogleSignInSupported {
    if (PlatformX.isWeb || PlatformX.isWindows || PlatformX.isLinux) return false;
    return true;
  }

  static String get name {
    if (isWeb) return 'web';
    if (isIOS) return 'ios';
    if (isAndroid) return 'android';
    if (isMacOS) return 'macos';
    if (isWindows) return 'windows';
    if (isLinux) return 'linux';
    return 'temp';
  }

  static String get version {
    if (isWeb) return 'web';
    return Platform.operatingSystemVersion;
  }
}
