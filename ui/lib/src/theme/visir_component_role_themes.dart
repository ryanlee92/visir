import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../foundation/visir_enums.dart';

@immutable
class VisirBorderState {
  const VisirBorderState({
    required this.color,
    required this.width,
  });

  final Color color;
  final double width;

  VisirBorderState copyWith({Color? color, double? width}) {
    return VisirBorderState(
      color: color ?? this.color,
      width: width ?? this.width,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VisirBorderState &&
            color == other.color &&
            width == other.width;
  }

  @override
  int get hashCode => Object.hash(color, width);
}

@immutable
class VisirBorderStates {
  const VisirBorderStates({
    required this.base,
    required this.hover,
    required this.focus,
    required this.disabled,
  });

  final VisirBorderState base;
  final VisirBorderState hover;
  final VisirBorderState focus;
  final VisirBorderState disabled;

  VisirBorderStates copyWith({
    VisirBorderState? base,
    VisirBorderState? hover,
    VisirBorderState? focus,
    VisirBorderState? disabled,
  }) {
    return VisirBorderStates(
      base: base ?? this.base,
      hover: hover ?? this.hover,
      focus: focus ?? this.focus,
      disabled: disabled ?? this.disabled,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VisirBorderStates &&
            base == other.base &&
            hover == other.hover &&
            focus == other.focus &&
            disabled == other.disabled;
  }

  @override
  int get hashCode => Object.hash(base, hover, focus, disabled);
}

@immutable
class VisirControlSizeScale {
  const VisirControlSizeScale({
    required this.sm,
    required this.md,
    required this.lg,
  });

  final double sm;
  final double md;
  final double lg;

  double resolve(VisirButtonSize size) {
    return switch (size) {
      VisirButtonSize.sm => sm,
      VisirButtonSize.md => md,
      VisirButtonSize.lg => lg,
    };
  }

  VisirControlSizeScale copyWith({
    double? sm,
    double? md,
    double? lg,
  }) {
    return VisirControlSizeScale(
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VisirControlSizeScale &&
            sm == other.sm &&
            md == other.md &&
            lg == other.lg;
  }

  @override
  int get hashCode => Object.hash(sm, md, lg);
}

@immutable
class VisirControlSizing {
  const VisirControlSizing({
    required this.height,
    required this.horizontalPadding,
    required this.iconSpacing,
    required this.compactSpacing,
  });

  final VisirControlSizeScale height;
  final VisirControlSizeScale horizontalPadding;
  final double iconSpacing;
  final double compactSpacing;

  double heightFor(VisirButtonSize size) => height.resolve(size);
  double horizontalPaddingFor(VisirButtonSize size) =>
      horizontalPadding.resolve(size);

  VisirControlSizing copyWith({
    VisirControlSizeScale? height,
    VisirControlSizeScale? horizontalPadding,
    double? iconSpacing,
    double? compactSpacing,
  }) {
    return VisirControlSizing(
      height: height ?? this.height,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      iconSpacing: iconSpacing ?? this.iconSpacing,
      compactSpacing: compactSpacing ?? this.compactSpacing,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VisirControlSizing &&
            height == other.height &&
            horizontalPadding == other.horizontalPadding &&
            iconSpacing == other.iconSpacing &&
            compactSpacing == other.compactSpacing;
  }

  @override
  int get hashCode =>
      Object.hash(height, horizontalPadding, iconSpacing, compactSpacing);
}

@immutable
class VisirControlInteractionThemeData {
  const VisirControlInteractionThemeData({
    required this.pressedScale,
    required this.disabledOpacity,
  });

  final double pressedScale;
  final double disabledOpacity;

  VisirControlInteractionThemeData copyWith({
    double? pressedScale,
    double? disabledOpacity,
  }) {
    return VisirControlInteractionThemeData(
      pressedScale: pressedScale ?? this.pressedScale,
      disabledOpacity: disabledOpacity ?? this.disabledOpacity,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VisirControlInteractionThemeData &&
            pressedScale == other.pressedScale &&
            disabledOpacity == other.disabledOpacity;
  }

  @override
  int get hashCode => Object.hash(pressedScale, disabledOpacity);
}

@immutable
class VisirControlThemeData {
  const VisirControlThemeData({
    required this.sizing,
    required this.borders,
    required this.radius,
    required this.interaction,
  });

  final VisirControlSizing sizing;
  final VisirBorderStates borders;
  final double radius;
  final VisirControlInteractionThemeData interaction;

  VisirControlThemeData copyWith({
    VisirControlSizing? sizing,
    VisirBorderStates? borders,
    double? radius,
    VisirControlInteractionThemeData? interaction,
  }) {
    return VisirControlThemeData(
      sizing: sizing ?? this.sizing,
      borders: borders ?? this.borders,
      radius: radius ?? this.radius,
      interaction: interaction ?? this.interaction,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VisirControlThemeData &&
            sizing == other.sizing &&
            borders == other.borders &&
            radius == other.radius &&
            interaction == other.interaction;
  }

  @override
  int get hashCode => Object.hash(sizing, borders, radius, interaction);
}

@immutable
class VisirSurfaceDensityScale {
  const VisirSurfaceDensityScale({
    required this.compact,
    required this.comfortable,
    required this.spacious,
  });

  final double compact;
  final double comfortable;
  final double spacious;

  double paddingFor(VisirCardDensity density) {
    return switch (density) {
      VisirCardDensity.compact => compact,
      VisirCardDensity.comfortable => comfortable,
      VisirCardDensity.spacious => spacious,
    };
  }

  VisirSurfaceDensityScale copyWith({
    double? compact,
    double? comfortable,
    double? spacious,
  }) {
    return VisirSurfaceDensityScale(
      compact: compact ?? this.compact,
      comfortable: comfortable ?? this.comfortable,
      spacious: spacious ?? this.spacious,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VisirSurfaceDensityScale &&
            compact == other.compact &&
            comfortable == other.comfortable &&
            spacious == other.spacious;
  }

  @override
  int get hashCode => Object.hash(compact, comfortable, spacious);
}

@immutable
class VisirSurfaceElevation {
  const VisirSurfaceElevation({
    required this.baseBlur,
    required this.baseOffsetY,
    required this.baseOpacity,
    required this.focusBlur,
    required this.focusSpread,
    required this.focusOpacity,
  });

  final double baseBlur;
  final double baseOffsetY;
  final double baseOpacity;
  final double focusBlur;
  final double focusSpread;
  final double focusOpacity;

  VisirSurfaceElevation copyWith({
    double? baseBlur,
    double? baseOffsetY,
    double? baseOpacity,
    double? focusBlur,
    double? focusSpread,
    double? focusOpacity,
  }) {
    return VisirSurfaceElevation(
      baseBlur: baseBlur ?? this.baseBlur,
      baseOffsetY: baseOffsetY ?? this.baseOffsetY,
      baseOpacity: baseOpacity ?? this.baseOpacity,
      focusBlur: focusBlur ?? this.focusBlur,
      focusSpread: focusSpread ?? this.focusSpread,
      focusOpacity: focusOpacity ?? this.focusOpacity,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VisirSurfaceElevation &&
            baseBlur == other.baseBlur &&
            baseOffsetY == other.baseOffsetY &&
            baseOpacity == other.baseOpacity &&
            focusBlur == other.focusBlur &&
            focusSpread == other.focusSpread &&
            focusOpacity == other.focusOpacity;
  }

  @override
  int get hashCode => Object.hash(
        baseBlur,
        baseOffsetY,
        baseOpacity,
        focusBlur,
        focusSpread,
        focusOpacity,
      );
}

@immutable
class VisirSurfaceThemeData {
  const VisirSurfaceThemeData({
    required this.padding,
    required this.radius,
    required this.borders,
    required this.elevation,
  });

  final VisirSurfaceDensityScale padding;
  final double radius;
  final VisirBorderStates borders;
  final VisirSurfaceElevation elevation;

  VisirSurfaceThemeData copyWith({
    VisirSurfaceDensityScale? padding,
    double? radius,
    VisirBorderStates? borders,
    VisirSurfaceElevation? elevation,
  }) {
    return VisirSurfaceThemeData(
      padding: padding ?? this.padding,
      radius: radius ?? this.radius,
      borders: borders ?? this.borders,
      elevation: elevation ?? this.elevation,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VisirSurfaceThemeData &&
            padding == other.padding &&
            radius == other.radius &&
            borders == other.borders &&
            elevation == other.elevation;
  }

  @override
  int get hashCode => Object.hash(padding, radius, borders, elevation);
}

@immutable
class VisirContentThemeData {
  const VisirContentThemeData({
    required this.paddingHorizontal,
    required this.paddingVertical,
    required this.radius,
    required this.inlineSpacing,
    required this.compactSpacing,
  });

  final double paddingHorizontal;
  final double paddingVertical;
  final double radius;
  final double inlineSpacing;
  final double compactSpacing;

  VisirContentThemeData copyWith({
    double? paddingHorizontal,
    double? paddingVertical,
    double? radius,
    double? inlineSpacing,
    double? compactSpacing,
  }) {
    return VisirContentThemeData(
      paddingHorizontal: paddingHorizontal ?? this.paddingHorizontal,
      paddingVertical: paddingVertical ?? this.paddingVertical,
      radius: radius ?? this.radius,
      inlineSpacing: inlineSpacing ?? this.inlineSpacing,
      compactSpacing: compactSpacing ?? this.compactSpacing,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VisirContentThemeData &&
            paddingHorizontal == other.paddingHorizontal &&
            paddingVertical == other.paddingVertical &&
            radius == other.radius &&
            inlineSpacing == other.inlineSpacing &&
            compactSpacing == other.compactSpacing;
  }

  @override
  int get hashCode => Object.hash(
        paddingHorizontal,
        paddingVertical,
        radius,
        inlineSpacing,
        compactSpacing,
      );
}

@immutable
class VisirFeedbackSizeScale {
  const VisirFeedbackSizeScale({
    required this.sm,
    required this.md,
    required this.lg,
  });

  final double sm;
  final double md;
  final double lg;

  double resolve(VisirSpinnerSize size) {
    return switch (size) {
      VisirSpinnerSize.sm => sm,
      VisirSpinnerSize.md => md,
      VisirSpinnerSize.lg => lg,
    };
  }

  VisirFeedbackSizeScale copyWith({
    double? sm,
    double? md,
    double? lg,
  }) {
    return VisirFeedbackSizeScale(
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VisirFeedbackSizeScale &&
            sm == other.sm &&
            md == other.md &&
            lg == other.lg;
  }

  @override
  int get hashCode => Object.hash(sm, md, lg);
}

@immutable
class VisirFeedbackThemeData {
  const VisirFeedbackThemeData({
    required this.size,
    required this.strokeWidth,
    required this.emphasisMuted,
    required this.emphasisStrong,
  });

  final VisirFeedbackSizeScale size;
  final double strokeWidth;
  final double emphasisMuted;
  final double emphasisStrong;

  double sizeFor(VisirSpinnerSize size) => this.size.resolve(size);

  VisirFeedbackThemeData copyWith({
    VisirFeedbackSizeScale? size,
    double? strokeWidth,
    double? emphasisMuted,
    double? emphasisStrong,
  }) {
    return VisirFeedbackThemeData(
      size: size ?? this.size,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      emphasisMuted: emphasisMuted ?? this.emphasisMuted,
      emphasisStrong: emphasisStrong ?? this.emphasisStrong,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is VisirFeedbackThemeData &&
            size == other.size &&
            strokeWidth == other.strokeWidth &&
            emphasisMuted == other.emphasisMuted &&
            emphasisStrong == other.emphasisStrong;
  }

  @override
  int get hashCode =>
      Object.hash(size, strokeWidth, emphasisMuted, emphasisStrong);
}
