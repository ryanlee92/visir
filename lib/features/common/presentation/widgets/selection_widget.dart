import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:flutter/material.dart';

class SelectionWidget<T> extends StatefulWidget {
  final T? current;
  final List<T> items;
  final List<int>? dividers;
  final String Function(T item)? getTitle;
  final InlineSpan Function(T item)? getTitleSpan;
  final Color Function(T item)? getTitleColor;
  final Widget Function(T item)? getChild;
  final double Function(T item)? getChildHeight;
  final bool Function(T item)? getChildSelectable;
  final void Function(T selection) onSelect;

  final Widget Function(T item)? getChildPopup;
  final bool Function(T item)? getChildIsPopup;

  final double? cellHeight;
  final EdgeInsetsGeometry? edgePadding;
  final String Function(T item)? getDescription;
  final double? cellHorizontalPadding;
  final TextStyle? cellTitleTextStyle;
  final VisirButtonOptions Function(T item)? options;

  const SelectionWidget({
    super.key,
    required this.onSelect,
    this.current,
    this.getTitle,
    this.getTitleSpan,
    this.getTitleColor,
    this.getChild,
    this.getChildHeight,
    this.getChildSelectable,
    required this.items,
    this.cellHeight,
    this.edgePadding,
    this.getDescription,
    this.cellHorizontalPadding,
    this.cellTitleTextStyle,
    this.dividers,
    this.options,
    this.getChildPopup,
    this.getChildIsPopup,
  });

  @override
  State<SelectionWidget<T>> createState() => _SelectionWidgetState<T>();
}

class _SelectionWidgetState<T> extends State<SelectionWidget<T>> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: widget.edgePadding ?? EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            for (T item in widget.items)
              Column(
                children: [
                  if (widget.getChildIsPopup?.call(item) == true)
                    PopupMenu(
                      type: ContextMenuActionType.tap,
                      location: PopupMenuLocation.bottom,
                      width: 280,
                      forcePopup: true,
                      style: VisirButtonStyle(
                        width: double.maxFinite,
                        cursor: (widget.getChildSelectable?.call(item) ?? true) ? SystemMouseCursors.click : SystemMouseCursors.basic,
                        height: widget.cellHeight ?? (widget.getChildHeight?.call(item) ?? 40),
                      ),
                      options: widget.options?.call(item),
                      popup: widget.getChildPopup?.call(item),
                      child:
                          widget.getChild?.call(item) ??
                          Row(
                            children: [
                              SizedBox(width: widget.cellHorizontalPadding ?? 12),
                              Expanded(
                                child: widget.getTitle != null
                                    ? Text(
                                        widget.getTitle?.call(item) ?? '',
                                        style: (widget.cellTitleTextStyle ?? context.bodyLarge)!.textColor(widget.getTitleColor?.call(item) ?? context.outlineVariant),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : widget.getTitleSpan != null
                                    ? Text.rich(widget.getTitleSpan!.call(item))
                                    : Container(),
                              ),
                              if (widget.getDescription != null)
                                Text(
                                  widget.getDescription?.call(item) ?? '',
                                  style: context.labelMedium!.textColor(context.isDarkMode ? context.inverseSurface : context.surfaceTint),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              SizedBox(width: widget.cellHorizontalPadding ?? 12),
                            ],
                          ),
                    ),

                  if (widget.getChildIsPopup?.call(item) != true)
                    VisirButton(
                      type: (widget.getChildSelectable?.call(item) ?? true) ? VisirButtonAnimationType.scaleAndOpacity : VisirButtonAnimationType.none,
                      style: VisirButtonStyle(
                        cursor: (widget.getChildSelectable?.call(item) ?? true) ? SystemMouseCursors.click : SystemMouseCursors.basic,
                        height: widget.cellHeight ?? (widget.getChildHeight?.call(item) ?? 40),
                      ),
                      options: widget.options?.call(item),
                      onTap: (widget.getChildSelectable?.call(item) ?? true)
                          ? () {
                              Navigator.of(context).maybePop();
                              widget.onSelect(item);
                            }
                          : null,
                      isSelected: widget.current == item,
                      child:
                          widget.getChild?.call(item) ??
                          Row(
                            children: [
                              SizedBox(width: widget.cellHorizontalPadding ?? 12),
                              Expanded(
                                child: widget.getTitle != null
                                    ? Text(
                                        widget.getTitle?.call(item) ?? '',
                                        style: (widget.cellTitleTextStyle ?? context.bodyLarge)!.textColor(widget.getTitleColor?.call(item) ?? context.outlineVariant),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : widget.getTitleSpan != null
                                    ? Text.rich(widget.getTitleSpan!.call(item))
                                    : Container(),
                              ),
                              if (widget.getDescription != null)
                                Text(
                                  widget.getDescription?.call(item) ?? '',
                                  style: context.labelMedium!.textColor(context.isDarkMode ? context.inverseSurface : context.surfaceTint),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              SizedBox(width: widget.cellHorizontalPadding ?? 12),
                            ],
                          ),
                    ),

                  if (widget.dividers?.contains(widget.items.indexOf(item)) == true)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 6, horizontal: widget.cellHorizontalPadding ?? 12),
                      child: Container(
                        width: double.maxFinite,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 0.5, strokeAlign: BorderSide.strokeAlignCenter, color: context.outlineVariant.withValues(alpha: 0.2)),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
