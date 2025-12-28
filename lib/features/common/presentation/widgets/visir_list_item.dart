import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/multi_finger_gesture_detector.dart';
import 'package:Visir/features/common/presentation/widgets/visir_badge.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:flutter/material.dart';

class VisirListItem extends StatelessWidget {
  final double widthBreakPoint = 400;

  final bool? addTopMargin;
  final bool? borderRadiusTopDisabled;
  final bool? borderRadiusBottomDisabled;
  final bool? isSelected;
  final bool? hoverDisabled;
  final Border? border;
  final TextSpan Function(double height, TextStyle? baseStyle, double verticalPadding, double horizontalPadding)? sectionBuilder;
  final TextSpan Function(double height, TextStyle? baseStyle, double verticalPadding, double horizontalPadding)? sectionTrailingBuilder;
  final TextSpan Function(double height, TextStyle? baseStyle, double verticalPadding, double horizontalPadding)? titleLeadingBuilder;
  final TextSpan Function(double height, TextStyle? baseStyle, double verticalPadding, double horizontalPadding)? titleBuilder;
  final TextSpan Function(double height, TextStyle? baseStyle, double verticalPadding, double horizontalPadding)? titleTrailingBuilder;
  final Widget? Function(double height, TextStyle? baseStyle, double verticalPadding, double horizontalPadding)? detailsBuilder;
  final Widget? Function(double height, TextStyle? baseStyle, double verticalPadding, double horizontalPadding)? titleWidget;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onTwoFingerDragSelect;
  final VoidCallback? onTwoFingerDragDisselect;
  final void Function(TapDownDetails)? onTapDown;
  final void Function(TapUpDetails)? onTapUp;
  final VoidCallback? onTapCancel;
  final MultiFingerGestureController? multiFingerGestureController;
  final VisirButtonOptions? buttonOptions;
  final bool? titleTrailingOnNextLine;
  final double? verticalMarginOverride;
  final double? verticalPaddingOverride;
  final int? titleMaxLines;

  const VisirListItem({
    super.key,
    this.addTopMargin,
    this.borderRadiusTopDisabled,
    this.borderRadiusBottomDisabled,
    this.isSelected,
    this.hoverDisabled,
    this.onTap,
    this.sectionBuilder,
    this.titleLeadingBuilder,
    this.titleBuilder,
    this.detailsBuilder,
    this.sectionTrailingBuilder,
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
    this.verticalMarginOverride,
    this.border,
    this.titleWidget,
    this.verticalPaddingOverride,
    this.titleMaxLines,
  });

  double textStyleToHeight(TextStyle style) {
    return (style.fontSize! * style.height!);
  }

  final horizontalPadding = 8.0;
  final verticalPadding = 8.0;
  final horizontalSpacing = 6.0;
  final verticalSpacing = 6.0;

  @override
  Widget build(BuildContext context) {
    final detailsWidget = detailsBuilder?.call(
      textStyleToHeight(context.bodyLarge!),
      context.bodyLarge?.textColor(context.inverseSurface),
      verticalSpacing,
      horizontalSpacing,
    );
    return Column(
      children: [
        VisirButton(
          type: VisirButtonAnimationType.scale,
          style: VisirButtonStyle(
            borderRadius: BorderRadius.vertical(
              bottom: borderRadiusBottomDisabled == true ? Radius.zero : Radius.circular(6),
              top: borderRadiusTopDisabled == true ? Radius.zero : Radius.circular(6),
            ),
            border: border,
            selectedBorderRadius: BorderRadius.circular(6),
            margin: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              bottom: verticalMarginOverride ?? verticalPadding,
              top: verticalMarginOverride ?? (addTopMargin == true ? verticalPadding : 0),
            ),
            padding: EdgeInsets.only(
              top: verticalPaddingOverride ?? verticalPadding - (border != null ? 1 : 0),
              bottom: verticalPaddingOverride ?? verticalPadding - (border != null ? 1 : 0),
              left: horizontalPadding - (border != null ? 1 : 0),
              right: horizontalPadding - (border != null ? 1 : 0),
            ),
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
          child: Column(
            children: [
              if (sectionBuilder != null)
                Padding(
                  padding: EdgeInsets.only(bottom: verticalPadding),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text.rich(
                          sectionBuilder!.call(
                            textStyleToHeight(context.bodyLarge!),
                            context.bodyLarge!.textColor(context.inverseSurface),
                            verticalSpacing,
                            horizontalSpacing,
                          ),
                          style: context.bodyLarge?.textColor(context.inverseSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (sectionTrailingBuilder != null)
                        Padding(
                          padding: EdgeInsets.only(left: horizontalPadding),
                          child: Text.rich(
                            sectionTrailingBuilder!.call(
                              textStyleToHeight(context.bodyLarge!),
                              context.bodyLarge!.textColor(context.inverseSurface),
                              verticalSpacing,
                              horizontalSpacing,
                            ),
                            style: context.bodyLarge?.textColor(context.inverseSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (titleLeadingBuilder != null)
                    Padding(
                      padding: EdgeInsets.only(right: horizontalPadding),
                      child: Text.rich(
                        titleLeadingBuilder!.call(
                          textStyleToHeight(context.titleMedium!),
                          context.titleMedium!.textColor(context.outlineVariant),
                          verticalSpacing,
                          horizontalSpacing,
                        ),
                        style: context.titleMedium?.textColor(context.outlineVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (titleWidget != null)
                          titleWidget!.call(
                            textStyleToHeight(context.titleMedium!),
                            context.titleMedium!.textColor(context.outlineVariant),
                            verticalPadding,
                            horizontalSpacing,
                          )!,
                        if (titleWidget == null && titleBuilder != null)
                          Row(
                            children: [
                              Expanded(
                                child: Text.rich(
                                  titleBuilder!.call(
                                    textStyleToHeight(context.titleMedium!),
                                    context.titleMedium!.textColor(context.outlineVariant),
                                    verticalPadding,
                                    horizontalSpacing,
                                  ),
                                  style: context.titleMedium?.textColor(context.outlineVariant),
                                  maxLines: titleMaxLines ?? 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (titleTrailingOnNextLine != true)
                                if (titleTrailingBuilder != null)
                                  Padding(
                                    padding: EdgeInsets.only(left: horizontalSpacing),
                                    child: Text.rich(
                                      titleTrailingBuilder!.call(
                                        textStyleToHeight(context.bodyLarge!),
                                        context.bodyLarge!.textColor(context.inverseSurface),
                                        verticalPadding,
                                        horizontalSpacing,
                                      ),
                                      style: context.bodyLarge?.textColor(context.inverseSurface),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              if (buttonOptions?.shortcuts != null && PlatformX.isDesktopView)
                                Padding(
                                  padding: EdgeInsets.only(left: horizontalSpacing),
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        ...buttonOptions!.shortcuts!
                                            .map(
                                              (e) => WidgetSpan(
                                                child: VisirBadge(
                                                  text: [
                                                    e.keys.ordered.map((e) => e.title).join(' '),
                                                    ...(e.subkeys?.map((e) => e.ordered.map((k) => k.title).join(' ')) ?? List<String>.from([])),
                                                  ].join(' / '),
                                                  style: context.bodyLarge!,
                                                  horizontalPadding: 0,
                                                  isShortcutBadge: true,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ],
                                    ),
                                    style: context.bodyLarge?.textColor(context.inverseSurface),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),

                        if (titleTrailingOnNextLine == true)
                          if (titleTrailingBuilder != null)
                            Padding(
                              padding: EdgeInsets.only(top: verticalPadding),
                              child: Text.rich(
                                titleTrailingBuilder!.call(
                                  textStyleToHeight(context.bodyLarge!),
                                  context.bodyLarge!.textColor(context.inverseSurface),
                                  verticalPadding,
                                  horizontalSpacing,
                                ),
                                style: context.bodyLarge?.textColor(context.inverseSurface),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        if (detailsWidget != null)
                          Container(
                            width: double.maxFinite,
                            padding: EdgeInsets.only(top: verticalPaddingOverride ?? verticalPadding),
                            child: detailsWidget,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
