import 'package:Visir/config/app_colors.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:flutter/material.dart';

/// Default [ThemeData] for Example
class AppTheme {
  /// Default constructor for Example [ThemeData]
  AppTheme(this._brightness);

  final Brightness _brightness;

  /// Exposes theme data to MaterialApp
  ThemeData getThemeData(BuildContext context) {
    const double letterSpacingValue = -0.3;
    double textHeight = 1.25;

    final baseTheme = ThemeData(brightness: _brightness, useMaterial3: true, colorSchemeSeed: AppColors.primaryColor);
    final textTheme = TextTheme(
      displayLarge: const TextStyle(fontSize: 44, height: 56 / 44, fontWeight: FontWeight.w700, letterSpacing: letterSpacingValue).appFont(context),
      displayMedium: const TextStyle(fontSize: 36, height: 46 / 36, fontWeight: FontWeight.w700, letterSpacing: letterSpacingValue).appFont(context),
      displaySmall: const TextStyle(fontSize: 30, height: 38 / 30, fontWeight: FontWeight.w700, letterSpacing: letterSpacingValue).appFont(context),
      headlineLarge: const TextStyle(fontSize: 28, height: 36 / 28, fontWeight: FontWeight.w700, letterSpacing: letterSpacingValue).appFont(context),
      headlineMedium: const TextStyle(fontSize: 24, height: 30 / 24, fontWeight: FontWeight.w700, letterSpacing: letterSpacingValue).appFont(context),
      headlineSmall: const TextStyle(fontSize: 22, height: 28 / 22, fontWeight: FontWeight.w700, letterSpacing: letterSpacingValue).appFont(context),
      titleLarge: TextStyle(
        fontSize: 20,
        height: textHeight,
        fontWeight: FontWeight.w700,
        letterSpacing: letterSpacingValue,
        leadingDistribution: TextLeadingDistribution.even,
      ).appFont(context),
      titleMedium: TextStyle(
        fontSize: 15,
        height: textHeight,
        letterSpacing: letterSpacingValue,
        leadingDistribution: TextLeadingDistribution.even,
      ).copyWith(fontWeight: PlatformX.isWindows ? FontWeight.w500 : FontWeight.w400),
      titleSmall: TextStyle(
        fontSize: 14,
        height: textHeight,
        letterSpacing: letterSpacingValue,
        leadingDistribution: TextLeadingDistribution.even,
      ).copyWith(fontWeight: PlatformX.isWindows ? FontWeight.w500 : FontWeight.w400),
      labelLarge: TextStyle(
        fontSize: 13,
        height: textHeight,
        letterSpacing: letterSpacingValue,
        leadingDistribution: TextLeadingDistribution.even,
      ).copyWith(fontWeight: PlatformX.isWindows ? FontWeight.w500 : FontWeight.w400),
      labelMedium: TextStyle(
        fontSize: 11,
        height: textHeight,
        letterSpacing: letterSpacingValue,
        leadingDistribution: TextLeadingDistribution.even,
      ).copyWith(fontWeight: PlatformX.isWindows ? FontWeight.w500 : FontWeight.w400),
      labelSmall: TextStyle(
        fontSize: 10,
        height: textHeight,
        letterSpacing: letterSpacingValue,
        leadingDistribution: TextLeadingDistribution.even,
      ).copyWith(fontWeight: PlatformX.isWindows ? FontWeight.w500 : FontWeight.w400),
      bodyLarge: TextStyle(
        fontSize: 12,
        height: textHeight,
        letterSpacing: letterSpacingValue,
        leadingDistribution: TextLeadingDistribution.even,
      ).copyWith(fontWeight: PlatformX.isWindows ? FontWeight.w500 : FontWeight.w400),
      bodyMedium: TextStyle(
        fontSize: 11,
        height: textHeight,
        letterSpacing: letterSpacingValue,
        leadingDistribution: TextLeadingDistribution.even,
      ).copyWith(fontWeight: PlatformX.isWindows ? FontWeight.w500 : FontWeight.w400),
      bodySmall: TextStyle(
        fontSize: 10,
        height: textHeight,
        letterSpacing: letterSpacingValue,
        leadingDistribution: TextLeadingDistribution.even,
      ).copyWith(fontWeight: PlatformX.isWindows ? FontWeight.w500 : FontWeight.w400),
    );

    final contentPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 12);
    final colorScheme = _brightness == Brightness.dark
        ? ColorScheme(
            brightness: _brightness,
            primary: Color(0xff7C5DFF),
            onPrimary: Color(0xffffffff),
            secondary: Color(0xff5d85ff),
            onSecondary: Color(0xffffffff),
            tertiary: Color(0xff7b86c4),
            onTertiary: Color(0xffffffff),
            error: Color(0xffff5d5d),
            onError: Color(0xffffffff),
            primaryContainer: Color(0xffff9956),
            onPrimaryContainer: Color(0xffffffff),
            secondaryContainer: Color(0xffffeb56),
            onSecondaryContainer: Color(0xff000000),
            tertiaryContainer: Color(0xffFFF4DF),
            onTertiaryContainer: Color(0xff332813),
            errorContainer: Color(0xff7eff56),
            onErrorContainer: Color(0xffffffff),
            background: Color(0xff1C1C1B),
            onBackground: Color(0xffFFFFFF),
            surface: Color(0xff2F2F2F),
            onSurface: Color(0xffECECEC),
            surfaceVariant: Color(0xff4B4B4A),
            onSurfaceVariant: Color(0xffD9D9D8),
            outlineVariant: Color(0xffECECEC), // gray 100
            shadow: Color(0xffD9D9D8), // gray 200
            onInverseSurface: Color(0xffBDBDBD), // gray 300
            inverseSurface: Color(0xffAAAAA9), // gray 400
            surfaceTint: Color(0xff8E8E8E), // gray 500
            inversePrimary: Color(0xff7B7B7A), // gray 600
            scrim: Color(0xff5E5E5E), // gray 700
            outline: Color(0xff4B4B4A), // gray 800
          )
        : ColorScheme(
            brightness: _brightness,
            primary: Color(0xff7C5DFF),
            onPrimary: Color(0xffffffff),
            secondary: Color(0xff5d85ff),
            onSecondary: Color(0xffffffff),
            tertiary: Color(0xff7b86c4),
            onTertiary: Color(0xffffffff),
            error: Color(0xffff5d5d),
            onError: Color(0xffffffff),
            primaryContainer: Color(0xffff9956),
            onPrimaryContainer: Color(0xffffffff),
            secondaryContainer: Color(0xffffeb56),
            onSecondaryContainer: Color(0xff000000),
            tertiaryContainer: Color(0xffFFF4DF),
            onTertiaryContainer: Color(0xff332813),
            errorContainer: Color(0xff7eff56),
            onErrorContainer: Color(0xffffffff),
            background: Color(0xffECECEC),
            onBackground: Color(0xff000000),
            surface: Color(0xffD9D9D8),
            onSurface: Color(0xff1C1C1B),
            surfaceVariant: Color(0xffBDBDBD),
            onSurfaceVariant: Color(0xff2F2F2F),
            outlineVariant: Color(0xff1C1C1B), // gray 100
            shadow: Color(0xff2F2F2F), // gray 200
            onInverseSurface: Color(0xff4B4B4A), // gray 300
            inverseSurface: Color(0xff5E5E5E), // gray 400
            surfaceTint: Color(0xff7B7B7A), // gray 500
            inversePrimary: Color(0xff8E8E8E), // gray 600
            scrim: Color(0xffAAAAA9), // gray 700
            outline: Color(0xffBDBDBD), // gray 800
          );

    return baseTheme.copyWith(
      textTheme: textTheme,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        toolbarHeight: 53,
        titleTextStyle: textTheme.titleLarge?.appFont(context),
        titleSpacing: 20,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.background,
        shape: Border(bottom: BorderSide(color: colorScheme.onBackground.withValues(alpha: 0.25), width: 0.5)),
      ),
      listTileTheme: ListTileThemeData(
        style: ListTileStyle.list,
        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
        selectedColor: colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        visualDensity: const VisualDensity(vertical: -4),
        minVerticalPadding: 0,
        dense: true,
        titleTextStyle: textTheme.bodyLarge,
        enableFeedback: true,
        minLeadingWidth: 0,
        horizontalTitleGap: 8,
        mouseCursor: WidgetStateMouseCursor.clickable,
      ),
      iconTheme: IconThemeData(color: colorScheme.onBackground, size: 24),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          splashFactory: InkSplash.splashFactory,
          overlayColor: WidgetStateProperty.all(colorScheme.scrim),
          foregroundColor: WidgetStateProperty.all(colorScheme.onBackground),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.comfortable,
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide.none,
          visualDensity: VisualDensity.compact,
          fixedSize: const Size.fromHeight(kMinInteractiveDimension),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: contentPadding,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
          minimumSize: const Size(0, 32),
          padding: contentPadding,
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onBackground,
          fixedSize: const Size.fromHeight(kMinInteractiveDimension),
          textStyle: textTheme.bodyMedium,
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shadowColor: Colors.transparent,
        ),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        color: colorScheme.primaryContainer,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: textTheme.bodyMedium,
        menuStyle: MenuStyle(backgroundColor: WidgetStateProperty.all(colorScheme.surfaceVariant)),
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          isCollapsed: true,
          labelStyle: textTheme.bodyMedium,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          contentPadding: contentPadding,
          filled: true,
          fillColor: colorScheme.primaryContainer,
        ),
      ),
      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: contentPadding,
        buttonColor: colorScheme.primary,
        textTheme: ButtonTextTheme.primary,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        layoutBehavior: ButtonBarLayoutBehavior.constrained,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: textTheme.bodySmall,
        border: UnderlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: contentPadding,
        filled: true,
        fillColor: colorScheme.surface,
      ),
      tabBarTheme: TabBarThemeData(
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: colorScheme.onSurface,
        indicatorColor: colorScheme.primary,
        dividerColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        labelStyle: baseTheme.textTheme.bodyMedium,
        unselectedLabelStyle: baseTheme.textTheme.bodyMedium,
        tabAlignment: TabAlignment.center,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surface,
        disabledColor: colorScheme.surface,
        selectedColor: colorScheme.primary,
        secondarySelectedColor: colorScheme.primary,
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 0),
        labelPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: textTheme.bodyMedium,
        secondaryLabelStyle: textTheme.bodyMedium,
        elevation: 0,
        pressElevation: 0,
        selectedShadowColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        iconSize: 24,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          const Set<WidgetState> interactiveStates = <WidgetState>{WidgetState.pressed, WidgetState.selected};
          if (!states.any(interactiveStates.contains)) {
            return colorScheme.surfaceTint;
          }
          return colorScheme.onPrimary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          const Set<WidgetState> interactiveStates = <WidgetState>{WidgetState.pressed, WidgetState.selected};
          if (!states.any(interactiveStates.contains)) {
            return colorScheme.inversePrimary;
          }
          return colorScheme.primary;
        }),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      radioTheme: RadioThemeData(visualDensity: VisualDensity.compact, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: colorScheme.surfaceVariant,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleMedium,
        contentTextStyle: textTheme.bodyMedium,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: textTheme.bodyMedium, tapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact),
      ),
      checkboxTheme: CheckboxThemeData(visualDensity: VisualDensity.compact, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
      tooltipTheme: TooltipThemeData(
        textStyle: textTheme.labelMedium?.textColor(colorScheme.onSurface),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        verticalOffset: 16,
        decoration: BoxDecoration(color: colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(4)),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          visualDensity: VisualDensity.compact,
          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
          shadowColor: WidgetStateProperty.all(Colors.black),
          backgroundColor: WidgetStateProperty.all(colorScheme.scrim),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
        ),
      ),
      menuButtonTheme: MenuButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(const Size(200, 0)),
          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16)),
          overlayColor: WidgetStateProperty.all(colorScheme.outlineVariant.withValues(alpha: 0.1)),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colorScheme.primary,
        selectionColor: colorScheme.primary.withValues(alpha: 0.4),
        selectionHandleColor: colorScheme.primary,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        year2023: false,
        borderRadius: const BorderRadius.all(Radius.circular(1)),
        strokeWidth: 2,
        circularTrackPadding: const EdgeInsets.all(2),
      ),
      sliderTheme: const SliderThemeData(year2023: false),
    );
  }
}
