import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_sidebar_more_quick_links.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_tab_item.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/proxy_network_image.dart';
import 'package:Visir/features/common/presentation/widgets/quick_link_add_widget.dart';
import 'package:Visir/features/common/presentation/widgets/scaffold_avatar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart';
import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// OAuth 상태 체크를 위한 최적화된 provider
final _desktopOAuthNotWorkExistsProvider = Provider<bool>((ref) {
  final messengerOAuthsNeedReAuth = ref.watch(localPrefControllerProvider.select((value) => value.value?.messengerOAuths?.any((e) => e.needReAuth == true) ?? false));
  final mailOAuthsNeedReAuth = ref.watch(localPrefControllerProvider.select((value) => value.value?.mailOAuths?.any((e) => e.needReAuth == true) ?? false));
  final calendarOAuthsNeedReAuth = ref.watch(localPrefControllerProvider.select((value) => value.value?.calendarOAuths?.any((e) => e.needReAuth == true) ?? false));

  return messengerOAuthsNeedReAuth || mailOAuthsNeedReAuth || calendarOAuthsNeedReAuth;
});

// Quick links 계산을 위한 최적화된 provider
final _desktopQuickLinksProvider = Provider<List<Map<String, String?>>>((ref) {
  return ref.watch(authControllerProvider.select((value) => value.requireValue.quickLinks)) ??
      ref.watch(localPrefControllerProvider.select((value) => value.value?.quickLinks)) ??
      [];
});

class DesktopSidebar extends ConsumerStatefulWidget {
  final List<TabType> desktopTabValues;

  DesktopSidebar({super.key, required this.desktopTabValues});

  @override
  _DesktopSidebarState createState() => _DesktopSidebarState();
}

class _DesktopSidebarState extends ConsumerState<DesktopSidebar> {
  double quickLinkButtonSize = 36.0;

  int? pressedIndex;

  bool get isSignedIn => ref.read(isSignedInProvider);

  @override
  Widget build(BuildContext context) {
    final tabBarDisplayType = ref.watch(localPrefControllerProvider.select((value) => value.value?.prefTabBarDisplayType));
    final isTabBarCollapsed = context.isNarrowScaffold || (tabBarDisplayType == TabBarDisplayType.alwaysCollapsed);
    final kMainTabBarWidth = isTabBarCollapsed ? 36.0 : 72.0;

    // 최적화된 provider 사용
    final oauthNotWorkExists = ref.watch(_desktopOAuthNotWorkExistsProvider);
    final quickLinks = ref.watch(_desktopQuickLinksProvider);

    final showSidebar = ref.watch(desktopShowSidebarProvider);

    return Container(
      width: kMainTabBarWidth,
      // color: context.background,
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          // Visir Logo
          Padding(
            padding: EdgeInsets.only(
              bottom: isTabBarCollapsed ? 8 : 12,
              left: (kMainTabBarWidth - (isTabBarCollapsed ? 33.6 : 44.8)) / 2,
              right: (kMainTabBarWidth - (isTabBarCollapsed ? 33.6 : 44.8)) / 2,
            ),
            child: Image.asset('assets/app_icon/visir_foreground.png', width: isTabBarCollapsed ? 33.6 : 44.8, height: isTabBarCollapsed ? 33.6 : 44.8),
          ),
          ...widget.desktopTabValues.map<Widget>((e) => DesktopTabItem(tab: e, desktopTabValues: widget.desktopTabValues)).toList(),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(height: 24),
                if (isSignedIn)
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final height = constraints.maxHeight;
                        final maxCount = max(0, height ~/ (quickLinkButtonSize + (isTabBarCollapsed ? 8 : 4)) - 1);
                        final items = [...quickLinks.sublist(0, min(maxCount, quickLinks.length)), '+'];
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: (kMainTabBarWidth - 34) / 2),
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                            child: AnimatedReorderableListView(
                              key: ValueKey('quick_link_side_bar_list_view:${items.length}_${maxCount}'),
                              items: items,
                              dragStartDelay: Duration(milliseconds: 0),
                              nonDraggableItems: ['+'],
                              lockedItems: ['+'],
                              shrinkWrap: true,
                              insertDuration: Duration.zero,
                              removeDuration: Duration.zero,
                              physics: NeverScrollableScrollPhysics(),
                              reverse: true,
                              buildDefaultDragHandles: false,
                              itemBuilder: (BuildContext context, int index) {
                                if (index == items.length - 1) {
                                  if (maxCount < quickLinks.length)
                                    return PopupMenu(
                                      key: ValueKey('quick_link_key_more'),
                                      type: ContextMenuActionType.tap,
                                      location: PopupMenuLocation.right,
                                      popup: DesktopSidebarMoreQuickLinks(maxCount: maxCount),
                                      backgroundColor: context.isDarkMode ? context.surface : context.surface,
                                      borderRadius: 12,
                                      width: 224,
                                      style: VisirButtonStyle(
                                        width: quickLinkButtonSize,
                                        height: quickLinkButtonSize,
                                        borderRadius: BorderRadius.circular(8),
                                        margin: EdgeInsets.only(bottom: isTabBarCollapsed ? 8 : 4),
                                      ),
                                      options: VisirButtonOptions(message: context.tr.quick_link_more, tooltipLocation: VisirButtonTooltipLocation.right),
                                      child: VisirIcon(type: VisirIconType.more, size: 20, color: context.surfaceTint),
                                    );
                                  if (maxCount >= quickLinks.length)
                                    return PopupMenu(
                                      key: ValueKey('quick_link_key_add'),
                                      type: ContextMenuActionType.tap,
                                      location: PopupMenuLocation.right,
                                      forceShiftOffset: Offset(0, -quickLinkButtonSize),
                                      popup: QuickLinkAddWidget(),
                                      backgroundColor: Colors.transparent,
                                      hideShadow: true,
                                      style: VisirButtonStyle(
                                        width: quickLinkButtonSize,
                                        height: quickLinkButtonSize,
                                        borderRadius: BorderRadius.circular(8),
                                        margin: EdgeInsets.only(bottom: isTabBarCollapsed ? 8 : 4),
                                      ),
                                      options: VisirButtonOptions(message: context.tr.quick_link_add, tooltipLocation: VisirButtonTooltipLocation.right),
                                      child: VisirIcon(type: VisirIconType.add, size: 20, color: context.surfaceTint),
                                    );
                                }

                                final e = items[index] as Map<String, String?>;
                                bool isGithubFavicon = e['favicon'] == 'https://github.githubassets.com/favicons/favicon.svg';
                                String title = e['title']?.isNotEmpty == true ? e['title']! : Utils.getRootDomainFromUrl(url: e['link']!);

                                Widget faviconWidget = ProxyNetworkImage(
                                  imageUrl: e['favicon'] ?? '',
                                  width: 20,
                                  height: 20,
                                  errorWidget: (context, _, __) {
                                    return Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: context.isDarkMode ? context.surfaceTint : context.surface),
                                      child: Center(
                                        child: Text(
                                          Utils.getRootDomainFromUrl(url: e['link']!)[0].toUpperCase(),
                                          style: context.titleSmall?.textColor(context.outlineVariant).textBold.appFont(context),
                                        ),
                                      ),
                                    );
                                  },
                                );

                                return PopupMenu(
                                  key: ValueKey('quick_link_key_${e['link']}_${e['title']}_${e['favicon']}_${index}'),
                                  type: ContextMenuActionType.secondaryTap,
                                  location: PopupMenuLocation.right,
                                  backgroundColor: Colors.transparent,
                                  forceShiftOffset: Offset(0, -quickLinkButtonSize),
                                  popup: QuickLinkAddWidget(link: e['link'], title: e['title'], favicon: e['favicon'], index: quickLinks.indexOf(e)),
                                  onTap: () => Utils.launchUrlExternal(url: e['link']!),
                                  hideShadow: true,
                                  style: VisirButtonStyle(
                                    width: quickLinkButtonSize,
                                    height: quickLinkButtonSize,
                                    borderRadius: BorderRadius.circular(8),
                                    margin: EdgeInsets.only(bottom: isTabBarCollapsed ? 8 : 4),
                                  ),
                                  options: VisirButtonOptions(message: title, tooltipLocation: VisirButtonTooltipLocation.right),
                                  child: e['favicon'] == null
                                      ? Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: context.isDarkMode ? context.surfaceTint : context.surface),
                                          child: Center(
                                            child: Text(title[0].toUpperCase(), style: context.titleSmall?.textColor(context.outlineVariant).textBold.appFont(context)),
                                          ),
                                        )
                                      : (isGithubFavicon && context.isDarkMode)
                                      ? ColorFiltered(
                                          colorFilter: const ColorFilter.matrix(<double>[
                                            -1, 0, 0, 0, 255, // Red
                                            0, -1, 0, 0, 255, // Green
                                            0, 0, -1, 0, 255, // Blue
                                            0, 0, 0, 1, 0, // Alpha
                                          ]),
                                          child: faviconWidget,
                                        )
                                      : faviconWidget,
                                );
                              },
                              enterTransition: [SlideInDown(duration: Duration.zero)],
                              exitTransition: [SlideInUp(duration: Duration.zero)],
                              onReorder: (int oldIndex, int newIndex) {
                                final user = ref.read(authControllerProvider).requireValue;

                                final list = [...quickLinks];
                                final quicklink = list.removeAt(oldIndex);
                                list.insert(newIndex, quicklink);

                                ref.read(authControllerProvider.notifier).updateUser(user: user.copyWith(quickLinks: list));

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
                          ),
                        );
                      },
                    ),
                  ),
                Stack(
                  children: [
                    ScaffoldAvatar(),
                    if (oauthNotWorkExists)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 6,
                          height: 6,
                          clipBehavior: Clip.antiAlias,
                          decoration: ShapeDecoration(
                            color: context.error,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          // child: Text(newCountString, style: context.labelSmall?.textBold.appFont(context)),
                        ),
                      ),
                  ],
                ),
                Container(
                  height: 2,
                  width: 16,
                  margin: EdgeInsets.only(bottom: 6, top: 12),
                  decoration: BoxDecoration(color: context.surfaceVariant.withValues(alpha: 1), borderRadius: BorderRadius.circular(1)),
                ),
                VisirAppBarButton(
                  icon: !showSidebar ? VisirIconType.hideSidebar : VisirIconType.showSidebar,
                  onTap: () => ref.read(desktopShowSidebarProvider.notifier).update(!showSidebar),
                ).getButton(context: context),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
