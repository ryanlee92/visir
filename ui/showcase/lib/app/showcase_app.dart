import 'package:flutter/material.dart';
import 'package:visir_ui/visir_ui.dart';

import 'showcase_page.dart';
import 'showcase_theme.dart';

class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({super.key, this.visirThemeData});

  final VisirThemeData? visirThemeData;

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleThemeMode(ThemeMode mode) {
    if (_themeMode == mode) {
      return;
    }

    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    final resolvedThemeData = _resolveVisirThemeData();

    return VisirTheme(
      data: resolvedThemeData,
      child: MaterialApp(
        title: 'Visir UI Showcase',
        debugShowCheckedModeBanner: false,
        theme: ShowcaseTheme.build(resolvedThemeData, Brightness.light),
        darkTheme: ShowcaseTheme.build(resolvedThemeData, Brightness.dark),
        themeMode: _themeMode,
        home: ShowcasePage(
          themeMode: _themeMode,
          onThemeModeChanged: _toggleThemeMode,
        ),
      ),
    );
  }

  VisirThemeData _resolveVisirThemeData() {
    final base = widget.visirThemeData ?? VisirThemeData.fallback();

    return switch (_themeMode) {
      ThemeMode.dark => _buildDarkVisirTheme(base),
      ThemeMode.light || ThemeMode.system => _buildLightVisirTheme(base),
    };
  }

  VisirThemeData _buildLightVisirTheme(VisirThemeData base) {
    final colors = base.tokens.colors.copyWith(
      surface: const Color(0xFFF9F4EE),
      surfaceMuted: const Color(0xFFF0E7DC),
      surfaceOutline: const Color(0x331D1A1F),
      text: const Color(0xFF1D1A1F),
      textMuted: const Color(0xFF5C564F),
      textInverse: Colors.white,
      accent: const Color(0xFF0E6B5D),
      accentStrong: const Color(0xFF085347),
      danger: const Color(0xFFC83E61),
      success: const Color(0xFF16794B),
      warning: const Color(0xFFB16A1A),
    );
    final borders = VisirBorderStates(
      base: VisirBorderState(color: colors.surfaceOutline, width: 1),
      hover: VisirBorderState(color: colors.surfaceOutline, width: 1),
      focus: VisirBorderState(color: colors.accent, width: 2),
      disabled: VisirBorderState(
        color: colors.surfaceOutline.withValues(alpha: 0.4),
        width: 1,
      ),
    );

    return base.copyWith(
      tokens: base.tokens.copyWith(colors: colors),
      components: base.components.copyWith(
        control: base.components.control.copyWith(borders: borders),
        surface: base.components.surface.copyWith(borders: borders),
      ),
    );
  }

  VisirThemeData _buildDarkVisirTheme(VisirThemeData base) {
    final colors = base.tokens.colors.copyWith(
      surface: const Color(0xCC1F1B33),
      surfaceMuted: const Color(0x9927253F),
      surfaceOutline: const Color(0x33FFFFFF),
      text: const Color(0xFFF8F7FF),
      textMuted: const Color(0xCCDBD7F3),
      textInverse: Colors.white,
      accent: const Color(0xFF7C5DFF),
      accentStrong: const Color(0xFF5A3FD7),
      danger: const Color(0xFFE13A5F),
      success: const Color(0xFF3BB273),
      warning: const Color(0xFFF2A93B),
    );
    final borders = VisirBorderStates(
      base: VisirBorderState(color: colors.surfaceOutline, width: 1),
      hover: VisirBorderState(color: colors.surfaceOutline, width: 1),
      focus: VisirBorderState(color: colors.accent, width: 2),
      disabled: VisirBorderState(
        color: colors.surfaceOutline.withValues(alpha: 0.4),
        width: 1,
      ),
    );

    return base.copyWith(
      tokens: base.tokens.copyWith(colors: colors),
      components: base.components.copyWith(
        control: base.components.control.copyWith(borders: borders),
        surface: base.components.surface.copyWith(borders: borders),
      ),
    );
  }
}
