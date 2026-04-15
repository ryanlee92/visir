import 'package:flutter/foundation.dart';

import '../foundation/visir_tokens.dart';
import 'visir_component_themes.dart';

@immutable
class VisirThemeData {
  const VisirThemeData({required this.tokens, required this.components});

  final VisirTokens tokens;
  final VisirComponentThemes components;

  factory VisirThemeData.fallback() {
    return VisirThemeData(
      tokens: VisirTokens.fallback(),
      components: const VisirComponentThemes(
        button: VisirButtonThemeData(
          glowBlur: 24,
          pressedScale: 0.96,
          disabledOpacity: 0.45,
        ),
      ),
    );
  }

  VisirThemeData copyWith({
    VisirTokens? tokens,
    VisirComponentThemes? components,
  }) {
    return VisirThemeData(
      tokens: tokens ?? this.tokens,
      components: components ?? this.components,
    );
  }
}
