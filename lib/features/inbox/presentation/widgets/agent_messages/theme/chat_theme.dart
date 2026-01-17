import 'package:flutter/material.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';

/// Modern chat theme with spacing, colors, and shadows
class ChatTheme {
  final BuildContext context;

  ChatTheme(this.context);

  // Spacing system
  static const double spacingXS = 4;
  static const double spacingSM = 8;
  static const double spacingMD = 12;
  static const double spacingLG = 16;
  static const double spacingXL = 24;
  static const double spacingXXL = 32;

  // Border radius
  static const double radiusSM = 8;
  static const double radiusMD = 12;
  static const double radiusLG = 18;

  // Message bubble colors
  Color get userMessageBg => context.primary.withOpacity(0.9);
  Color get userMessageText => Colors.white;
  Color get userMessageShadow => context.primary.withOpacity(0.3);

  Color get assistantMessageBg => context.surface.withOpacity(0.6);
  Color get assistantMessageText => context.onSurface;
  Color get assistantMessageBorder => context.outline.withOpacity(0.1);

  // Entity card colors
  Color get entityCardBg => context.surfaceVariant.withOpacity(0.4);
  Color get entityCardBorder => context.outline.withOpacity(0.15);
  Color get entityAccent => context.primary;

  // Loading colors
  Color get loadingPrimary => context.primary.withOpacity(0.6);
  Color get loadingSecondary => context.primary.withOpacity(0.3);
  Color get shimmerBase => context.surfaceVariant;
  Color get shimmerHighlight => context.surface;

  // Confirmation colors
  Color get confirmBg => context.primaryContainer.withOpacity(0.15);
  Color get confirmBorder => context.primary.withOpacity(0.3);
  Color get confirmAccent => context.primary;

  // Avatar gradient
  LinearGradient get avatarGradient => const LinearGradient(
        colors: [Color(0xFF7C5DFF), Color(0xFF5d85ff)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Shadow system
  List<BoxShadow> get elevation1 => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  List<BoxShadow> get elevation2 => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  List<BoxShadow> get elevation3 => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  // Gradient for user message
  LinearGradient get userMessageGradient => LinearGradient(
        colors: [
          context.primary.withOpacity(0.9),
          context.primary.withOpacity(0.7),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Gradient for entity cards
  LinearGradient entityCardGradient(Color accentColor) => LinearGradient(
        colors: [
          accentColor.withOpacity(0.1),
          accentColor.withOpacity(0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // User message shadow list
  List<BoxShadow> get userMessageShadowList => [
        BoxShadow(
          color: userMessageShadow,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
}
