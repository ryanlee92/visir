import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/multi_finger_gesture_detector.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:flutter/material.dart';

class VisirListSection extends StatelessWidget {
  final double widthBreakPoint = 400;

  final bool? removeTopMargin;
  final bool? borderRadiusTopDisabled;
  final bool? borderRadiusBottomDisabled;
  final bool? isSelected;
  final bool? hoverDisabled;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onTwoFingerDragSelect;
  final VoidCallback? onTwoFingerDragDisselect;
  final void Function(TapDownDetails)? onTapDown;
  final void Function(TapUpDetails)? onTapUp;
  final VoidCallback? onTapCancel;
  final TextSpan Function(double height, TextStyle? baseStyle, TextStyle? subStyle, double horizontalSpacing)? titleBuilder;
  final TextSpan Function(double height, TextStyle? baseStyle, TextStyle? subStyle, double horizontalSpacing)? titleTrailingBuilder;

  final MultiFingerGestureController? multiFingerGestureController;

  final VisirButtonOptions? buttonOptions;
  final bool? titleTrailingOnNextLine;

  final double? bottomMarginOverride;

  const VisirListSection({
    super.key,
    this.removeTopMargin,
    this.borderRadiusTopDisabled,
    this.borderRadiusBottomDisabled,
    this.isSelected,
    this.hoverDisabled,
    this.onTap,
    this.titleBuilder,
    this.titleTrailingBuilder,
    this.onLongPress,
    this.onTwoFingerDragSelect,
    this.onTwoFingerDragDisselect,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.multiFingerGestureController,
    this.buttonOptions,
    this.titleTrailingOnNextLine,
    this.bottomMarginOverride,
  });

  double textStyleToHeight(TextStyle style) {
    return (style.fontSize! * style.height!);
  }

  final horizontalPadding = 8.0;
  final verticalPadding = 3.0;
  final horizontalSpacing = 6.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        VisirButton(
          type: VisirButtonAnimationType.scale,
          style: VisirButtonStyle(
            borderRadius: BorderRadius.vertical(
              bottom: borderRadiusBottomDisabled == true ? Radius.zero : Radius.circular(6),
              top: borderRadiusTopDisabled == true ? Radius.zero : Radius.circular(6),
            ),
            selectedBorderRadius: BorderRadius.circular(6),
            margin: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              bottom: bottomMarginOverride ?? 8,
              top: removeTopMargin == true ? 8 : 26,
            ),
            padding: EdgeInsets.only(top: verticalPadding, bottom: verticalPadding, left: horizontalPadding, right: horizontalPadding),
            hoverColor: hoverDisabled == true ? Colors.transparent : null,
          ),
          options: buttonOptions,
          behavior: HitTestBehavior.translucent,
          isSelected: isSelected,
          multiFingerGestureController: multiFingerGestureController,
          onTap: onTap,
          onLongPress: onLongPress,
          onTwoFingerDragSelect: onTwoFingerDragSelect,
          onTwoFingerDragDisselect: onTwoFingerDragDisselect,
          onTapDown: onTapDown,
          onTapUp: onTapUp,
          onTapCancel: onTapCancel,
          child: titleTrailingOnNextLine == true
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (titleBuilder != null)
                      SizedBox(
                        width: double.infinity,
                        child: Text.rich(
                          titleBuilder!.call(
                            textStyleToHeight(context.titleLarge!),
                            context.titleLarge?.textColor(context.outlineVariant),
                            context.titleSmall?.textColor(context.inverseSurface),
                            horizontalSpacing,
                          ),
                          style: context.titleLarge?.textColor(context.outlineVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    if (titleTrailingBuilder != null)
                      Padding(
                        padding: EdgeInsets.only(top: verticalPadding),
                        child: Text.rich(
                          titleTrailingBuilder!.call(
                            textStyleToHeight(context.titleSmall!),
                            context.titleSmall?.textColor(context.inverseSurface),
                            context.titleSmall?.textColor(context.inverseSurface),
                            horizontalSpacing,
                          ),
                          style: context.titleSmall?.textColor(context.inverseSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                )
              : Row(
                  children: [
                    if (titleBuilder != null)
                      Expanded(
                        child: Text.rich(
                          titleBuilder!.call(
                            textStyleToHeight(context.titleLarge!),
                            context.titleLarge?.textColor(context.outlineVariant),
                            context.titleSmall?.textColor(context.inverseSurface),
                            horizontalSpacing,
                          ),
                          style: context.titleLarge?.textColor(context.outlineVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (titleTrailingBuilder != null)
                      Padding(
                        padding: EdgeInsets.only(left: horizontalSpacing),
                        child: Text.rich(
                          titleTrailingBuilder!.call(
                            textStyleToHeight(context.titleSmall!),
                            context.titleSmall?.textColor(context.inverseSurface),
                            context.titleSmall?.textColor(context.inverseSurface),
                            horizontalSpacing,
                          ),
                          style: context.titleSmall?.textColor(context.inverseSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
