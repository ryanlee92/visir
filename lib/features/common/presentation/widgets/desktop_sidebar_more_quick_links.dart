import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/proxy_network_image.dart';
import 'package:Visir/features/common/presentation/widgets/quick_link_add_widget.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DesktopSidebarMoreQuickLinks extends ConsumerStatefulWidget {
  final int maxCount;
  const DesktopSidebarMoreQuickLinks({Key? key, required this.maxCount}) : super(key: key);

  @override
  _DesktopSidebarMoreQuickLinksState createState() => _DesktopSidebarMoreQuickLinksState();
}

class _DesktopSidebarMoreQuickLinksState extends ConsumerState<DesktopSidebarMoreQuickLinks> {
  int? pressedIndex;

  @override
  Widget build(BuildContext context) {
    final quickLinks =
        ref.watch(authControllerProvider.select((value) => value.requireValue.quickLinks)) ??
        ref.watch(localPrefControllerProvider.select((value) => value.value?.quickLinks)) ??
        [];

    final maxCount = widget.maxCount;
    final items = [...quickLinks.sublist(maxCount), '+'];

    if (items.length == 1) {
      Navigator.of(context).maybePop();
    }

    return Container(
      padding: EdgeInsets.all(8),
      child: AnimatedReorderableListView(
        key: ValueKey('quick_link_side_bar_list_view:${items.length}'),
        items: items,
        nonDraggableItems: ['+'],
        lockedItems: ['+'],
        shrinkWrap: true,
        insertDuration: Duration.zero,
        removeDuration: Duration.zero,
        dragStartDelay: Duration(milliseconds: 0),
        physics: NeverScrollableScrollPhysics(),
        reverse: true,
        buildDefaultDragHandles: false,
        itemBuilder: (BuildContext context, int index) {
          if (index == items.length - 1) {
            return PopupMenu(
              key: ValueKey('quick_link_key_add_link_in_popup'),
              type: ContextMenuActionType.tap,
              location: PopupMenuLocation.right,
              backgroundColor: Colors.transparent,
              forceShiftOffset: forceShiftOffsetForMenu,
              style: VisirButtonStyle(height: 34, width: 208, borderRadius: BorderRadius.circular(4), padding: EdgeInsets.only(left: 12, right: 6)),
              popup: QuickLinkAddWidget(),
              hideShadow: true,
              child: Row(
                children: [
                  VisirIcon(type: VisirIconType.add, size: 18, color: context.outlineVariant),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr.quick_link_add,
                      style: context.titleSmall?.textColor(context.outlineVariant),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            );
          }

          final e = items[index] as Map<String, String?>;
          final title = e['title']?.isNotEmpty == true ? e['title'] : Utils.getRootDomainFromUrl(url: e['link']!);
          return PopupMenu(
            key: ValueKey('quick_link_key_${e['link']}_${e['title']}_${e['favicon']}_${index}'),
            type: ContextMenuActionType.secondaryTap,
            location: PopupMenuLocation.right,
            backgroundColor: Colors.transparent,
            forceShiftOffset: forceShiftOffsetForMenu,
            style: VisirButtonStyle(height: 34, width: 208, borderRadius: BorderRadius.circular(4), padding: EdgeInsets.only(left: 12, right: 6)),
            popup: QuickLinkAddWidget(link: e['link'], title: e['title'], favicon: e['favicon'], index: quickLinks.indexOf(e)),
            onTap: () => Utils.launchUrlExternal(url: e['link']!),
            hideShadow: true,
            child: Row(
              children: [
                e['favicon'] == null
                    ? Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: context.isDarkMode ? context.surfaceTint : context.surface),
                        child: Center(child: Text(title![0], style: context.titleSmall?.textColor(context.outlineVariant).textBold.appFont(context))),
                      )
                    : ProxyNetworkImage(
                        imageUrl: e['favicon']!,
                        width: 18,
                        height: 18,
                        errorWidget: (context, _, __) {
                          return Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: context.surfaceTint),
                            child: Center(
                              child: Text(
                                Utils.getRootDomainFromUrl(url: e['link']!)[0],
                                style: context.titleSmall?.textColor(context.outlineVariant).textBold.appFont(context),
                              ),
                            ),
                          );
                        },
                      ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(title!, style: context.titleSmall?.textColor(context.outlineVariant), overflow: TextOverflow.ellipsis, maxLines: 1),
                ),
              ],
            ),
          );
        },
        enterTransition: [SlideInDown(duration: Duration.zero)],
        exitTransition: [SlideInUp(duration: Duration.zero)],
        onReorder: (int oldIndex, int newIndex) {
          final list = [...quickLinks];
          final quicklink = list.removeAt(oldIndex + maxCount);
          list.insert(newIndex + maxCount, quicklink);
          ref.read(localPrefControllerProvider.notifier).set(quickLinks: list);
          setState(() {});
        },
        onReorderStart: (index) {
          pressedIndex = index;
        },
        onReorderEnd: (index) {
          if (pressedIndex == index && items[index] is Map) {
            final e = items[index] as Map;
            Utils.launchUrlExternal(url: e['link']!);
          }
          pressedIndex = null;
        },
        isSameItem: (a, b) => a is Map && b is Map ? a['link'] == b['link'] && a['title'] == b['title'] && a['favicon'] == b['favicon'] : a == b,
      ),
    );
  }
}
