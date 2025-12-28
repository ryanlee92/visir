import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/selection_widget.dart';
import 'package:flutter/widgets.dart';

class DesktopRightClickPopup<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T item) getTitle;
  final Color Function(T item) getTitleColor;
  final void Function(T selection) onSelect;
  final Color? backgroundColor;
  final List<T>? dividerAfterItems;

  const DesktopRightClickPopup({
    super.key,
    required this.items,
    required this.getTitle,
    required this.getTitleColor,
    required this.onSelect,
    this.backgroundColor,
    this.dividerAfterItems,
  });

  @override
  State<DesktopRightClickPopup<T>> createState() => _DesktopRightClickPopupState<T>();
}

class _DesktopRightClickPopupState<T> extends State<DesktopRightClickPopup<T>> {
  int? hover;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: (context.context.surfaceVariant)),
      child: SelectionWidget<T>(
        items: widget.items,
        dividers: [2],
        onSelect: (item) {
          widget.onSelect(item);
        },
        getTitle: (item) => widget.getTitle.call(item),
        getTitleColor: (item) => widget.getTitleColor.call(item),
      ),
    );
  }
}
