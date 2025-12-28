import 'package:Visir/dependency/board_view/board_item.dart';
import 'package:Visir/dependency/board_view/boardview.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:flutter/material.dart';

typedef OnDropList = void Function(int? listIndex, int? oldListIndex);
typedef OnTapList = void Function(int? listIndex);
typedef OnDoubleTap = void Function();
typedef OnStartDragList = void Function(int? listIndex);

class BoardList extends StatefulWidget {
  final List<Widget>? header;
  final Widget? footer;
  final List<BoardItem>? items;
  final Color? backgroundColor;
  final Color? headerBackgroundColor;
  final BoardViewState? boardView;
  final OnDropList? onDropList;
  final OnTapList? onTapList;
  final OnStartDragList? onStartDragList;
  final void Function(TapDownDetails details)? onDoubleTapList;
  final BoxScrollView Function(NullableIndexedWidgetBuilder itemBuilder)? listBuilder;
  final bool draggable;

  const BoardList({
    Key? key,
    this.header,
    this.items,
    this.footer,
    this.backgroundColor,
    this.headerBackgroundColor,
    this.boardView,
    this.draggable = true,
    this.index,
    this.onDropList,
    this.onTapList,
    this.onStartDragList,
    this.onDoubleTapList,
    this.listBuilder,
  }) : super(key: key);

  final int? index;

  @override
  State<BoardList> createState() {
    return BoardListState();
  }
}

class BoardListState extends State<BoardList> with AutomaticKeepAliveClientMixin {
  List<BoardItemState> itemStates = [];
  ScrollController boardListController = ScrollController();

  void onDropList(int? listIndex) {
    if (widget.onDropList != null) {
      widget.onDropList!(listIndex, widget.boardView!.startListIndex);
    }
    widget.boardView!.draggedListIndex = null;
    if (widget.boardView!.mounted) {
      widget.boardView!.setState(() {});
    }
  }

  void _startDrag(Widget item, BuildContext context) {
    if (widget.boardView != null && widget.draggable) {
      if (widget.onStartDragList != null) {
        widget.onStartDragList!(widget.index);
      }
      widget.boardView!.startListIndex = widget.index;
      widget.boardView!.height = context.size!.height;
      widget.boardView!.draggedListIndex = widget.index!;
      widget.boardView!.draggedItemIndex = null;
      widget.boardView!.draggedItem = item;
      widget.boardView!.onDropList = onDropList;
      widget.boardView!.run();
      if (widget.boardView!.mounted) {
        widget.boardView!.setState(() {});
      }
    }
  }

  @override
  bool get wantKeepAlive => true;

  Widget _itemBuilder(ctx, index) {
    if (widget.items![index].boardList == null ||
        widget.items![index].index != index ||
        widget.items![index].boardList!.widget.index != widget.index ||
        widget.items![index].boardList != this) {
      widget.items![index] = BoardItem(
        boardList: this,
        item: widget.items![index].item,
        draggable: widget.items![index].draggable,
        index: index,
        onDropItem: widget.items![index].onDropItem,
        onTapItem: widget.items![index].onTapItem,
        onDragItem: widget.items![index].onDragItem,
        onStartDragItem: widget.items![index].onStartDragItem,
      );
    }
    if (widget.boardView!.draggedItemIndex == index && widget.boardView!.draggedListIndex == widget.index) {
      return Opacity(opacity: 0.0, child: widget.items![index]);
    } else {
      return widget.items![index];
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    List<Widget> listWidgets = [];
    if (widget.header != null) {
      listWidgets.add(
        Container(
          decoration: BoxDecoration(borderRadius: const BorderRadius.vertical(top: Radius.circular(8))),
          child: Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: widget.header!),
        ),
      );
    }
    if (widget.items != null) {
      if (widget.listBuilder != null) {
        listWidgets.add(Flexible(fit: FlexFit.tight, child: widget.listBuilder!(_itemBuilder)));
      } else {
        listWidgets.add(
          Flexible(
            fit: FlexFit.tight,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              controller: boardListController,
              itemCount: widget.items!.length,
              itemBuilder: _itemBuilder,
            ),
          ),
        );
      }
    }

    if (widget.footer != null) {
      listWidgets.add(widget.footer!);
    }

    Color? backgroundColor = Theme.of(context).colorScheme.onInverseSurface;

    if (widget.backgroundColor != null) {
      backgroundColor = widget.backgroundColor;
    }
    if (widget.boardView!.listStates.length > widget.index!) {
      widget.boardView!.listStates.removeAt(widget.index!);
    }
    widget.boardView!.listStates.insert(widget.index!, this);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onDoubleTapDown: (details) {
        widget.onDoubleTapList?.call(details);
      },
      child: Container(
        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.all(Radius.circular(PlatformX.isMobileView ? 14 : 6))),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(PlatformX.isMobileView ? 14 : 6)),
          child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.end, children: listWidgets),
        ),
      ),
    );
  }
}
