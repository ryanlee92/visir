import 'dart:math';

import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// A set of useful [BuildContext] extensions
extension BuildContextX on BuildContext {
  /// Extensions for quickly accessing generated localization getters
  BuildContext get context => Utils.mainContext.mounted ? Utils.mainContext : this;

  AppLocalizations get tr {
    final localizations = AppLocalizations.of(this);
    if (localizations != null) return localizations;

    if (Utils.mainContext.mounted) {
      final mainLocalizations = AppLocalizations.of(Utils.mainContext);
      if (mainLocalizations != null) return mainLocalizations;
    }

    throw Exception('AppLocalizations not found');
  }

  ThemeData get theme => isDarkMode ? Utils.darkTheme : Utils.lightTheme;

  /// Extension for quickly accessing app [ColorScheme]
  ColorScheme get colorScheme => theme.colorScheme;

  /// Extension for quickly accessing app [TextTheme]
  TextTheme get textTheme => theme.textTheme;

  AppBarThemeData get appBarTheme => theme.appBarTheme;

  MediaQueryData get mediaQuery => MediaQuery.of(context);

  double get appBarHeight => 47;

  /// Extension for quickly accessing screen size
  Size get screenSize => MediaQueryData.fromView(View.of(context)).size;

  EdgeInsets get padding => MediaQueryData.fromView(View.of(context)).padding;

  EdgeInsets get viewInset => MediaQueryData.fromView(View.of(context)).viewInsets;

  /// Extensions for quickly accessing to brightness;
  Brightness get brightness => isDarkMode ? Brightness.dark : Brightness.light;

  bool get isDarkMode => Utils.themeMode == ThemeMode.dark
      ? true
      : Utils.themeMode == ThemeMode.light
      ? false
      : WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;

  /// Extensions for quickly accessing to colors;
  Color get primary => theme.colorScheme.primary;

  Color get onPrimary => theme.colorScheme.onPrimary;

  Color get primaryContainer => theme.colorScheme.primaryContainer;

  Color get onPrimaryContainer => theme.colorScheme.onPrimaryContainer;

  Color get secondary => theme.colorScheme.secondary;

  Color get onSecondary => theme.colorScheme.onSecondary;

  Color get secondaryContainer => theme.colorScheme.secondaryContainer;

  Color get onSecondaryContainer => theme.colorScheme.onSecondaryContainer;

  Color get tertiary => theme.colorScheme.tertiary;

  Color get onTertiary => theme.colorScheme.onTertiary;

  Color get tertiaryContainer => theme.colorScheme.tertiaryContainer;

  Color get onTertiaryContainer => theme.colorScheme.onTertiaryContainer;

  Color get error => theme.colorScheme.error;

  Color get onError => theme.colorScheme.onError;

  Color get errorContainer => theme.colorScheme.errorContainer;

  Color get onErrorContainer => theme.colorScheme.onErrorContainer;

  Color get background => theme.colorScheme.background;

  Color get onBackground => theme.colorScheme.onBackground;

  Color get surface => theme.colorScheme.surface;

  Color get onSurface => theme.colorScheme.onSurface;

  Color get surfaceVariant => theme.colorScheme.surfaceVariant;

  Color get onSurfaceVariant => theme.colorScheme.onSurfaceVariant;

  Color get outline => theme.colorScheme.outline;

  Color get outlineVariant => theme.colorScheme.outlineVariant;

  Color get shadow => theme.colorScheme.shadow;

  Color get scrim => theme.colorScheme.scrim;

  Color get inverseSurface => theme.colorScheme.inverseSurface;

  Color get onInverseSurface => theme.colorScheme.onInverseSurface;

  Color get inversePrimary => theme.colorScheme.inversePrimary;

  Color get surfaceTint => theme.colorScheme.surfaceTint;

  TextStyle? get labelSmall => theme.textTheme.labelSmall;

  TextStyle? get labelMedium => theme.textTheme.labelMedium;

  TextStyle? get labelLarge => theme.textTheme.labelLarge;

  TextStyle? get bodySmall => theme.textTheme.bodySmall;

  TextStyle? get bodyMedium => theme.textTheme.bodyMedium;

  TextStyle? get bodyLarge => theme.textTheme.bodyLarge;

  TextStyle? get titleSmall => theme.textTheme.titleSmall;

  TextStyle? get titleMedium => theme.textTheme.titleMedium;

  TextStyle? get titleLarge => theme.textTheme.titleLarge;

  TextStyle? get headlineSmall => theme.textTheme.headlineSmall;

  TextStyle? get headlineMedium => theme.textTheme.headlineMedium;

  TextStyle? get headlineLarge => theme.textTheme.headlineLarge;

  TextStyle? get displayLarge => theme.textTheme.displayLarge;

  TextStyle? get displayMedium => theme.textTheme.displayMedium;

  TextStyle? get displaySmall => theme.textTheme.displaySmall;

  TextScaler get textScaler => mediaQuery.textScaler;

  double get devicePixelRatio => mediaQuery.devicePixelRatio;

  double get width => mediaQuery.size.width;

  double get height => mediaQuery.size.height;

  double get mobileCardHeight => height - max(context.padding.top - 8, 20);

  double textFieldPadding(double original) => original - (original - textScaler.scale(original)) / 2;

  bool get isNarrowScaffold => PlatformX.isWeb ? false : width <= 900;
}

extension TextStyleX on TextStyle {
  TextStyle textColor(Color? color) {
    return this.copyWith(color: color);
  }

  TextStyle fontSize(double? fontSize) {
    return this.copyWith(fontSize: fontSize);
  }

  TextStyle height(double? height) {
    return this.copyWith(fontSize: height);
  }

  TextStyle fontWeight(FontWeight? fontWeight) {
    return this.copyWith(fontWeight: fontWeight);
  }

  TextStyle appFont(BuildContext context) {
    if (this.fontWeight == FontWeight.w500) {
      return this.copyWith(fontFamily: 'Suit', fontWeight: FontWeight.w600, letterSpacing: 0);
    }

    return this.copyWith(fontFamily: 'Suit', letterSpacing: 0);
  }

  TextStyle get textBold {
    if (fontFamily == 'Suit') return this.copyWith(fontWeight: FontWeight.w900);
    return this.copyWith(fontWeight: FontWeight.w700);
  }

  TextStyle get textItalic {
    return this.copyWith(fontStyle: FontStyle.italic);
  }

  TextStyle get textStrike {
    return this.copyWith(decoration: TextDecoration.lineThrough);
  }

  TextStyle get textUnderline {
    return this.copyWith(decoration: TextDecoration.underline);
  }
}
