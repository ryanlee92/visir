import 'package:Visir/dependency/admin_scaffold/admin_scaffold.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/application/calendar_list_controller.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/calendar/presentation/screens/main_calendar_widget.dart';
import 'package:Visir/features/calendar/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/auth_image_view.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/providers.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/preference/presentation/screens/preference_screen.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:change_case/change_case.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InboxSideBar extends SideBar {
  InboxSideBar({super.key, super.onSelected, super.width, super.drawerCallback, required super.tabType, super.items = const []})
    : super(selectedRoute: '', activeBackgroundColor: Colors.transparent, hoverBackgroundColor: Colors.transparent);

  @override
  _InboxSideBarState createState() => _InboxSideBarState();
}

class _InboxSideBarState extends SideBarState {
  bool get isDarkMode => context.isDarkMode;

  @override
  void initState() {
    super.initState();
    if (widget.drawerCallback != null) {
      widget.drawerCallback!(true);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.drawerCallback != null) {
      widget.drawerCallback!(false);
    }
  }

  @override
  void didUpdateWidget(InboxSideBar oldWidget) {
    if (oldWidget.selectedRoute != widget.selectedRoute) {
      setState(() {});
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeSwitchProvider);
    final inboxFilter = ref.watch(inboxFilterProvider(widget.tabType));
    final inboxSuggestionFilter = ref.watch(inboxSuggestionFilterProvider(widget.tabType));
    final inboxSuggestionSort = ref.watch(inboxSuggestionSortProvider(widget.tabType));
    final calendars = ref.watch(calendarListControllerProvider);
    final calendarOAuths = ref.watch(localPrefControllerProvider.select((e) => e.value?.calendarOAuths));
    final calendarOAuthsMap = calendarOAuths?.fold<Map<String, OAuthEntity>>({}, (map, e) => map..[e.email] = e) ?? {};
    final calendarColors = ref.watch(authControllerProvider.select((e) => e.requireValue.userCalendarColors));
    final calendarHide = ref.watch(calendarHideProvider(widget.tabType));
    final calendarType = ref.watch(calendarTypeChangerProvider(widget.tabType));
    final projects = ref.watch(projectListControllerProvider);
    final projectHide = ref.watch(projectHideProvider(widget.tabType));

    final currentInboxScreenType = ref.watch(currentInboxScreenTypeProvider);
    final isAgenticUi = currentInboxScreenType == InboxScreenType.agent;

    return SideBar(
      backgroundColor: context.background,
      hoverBackgroundColor: context.outlineVariant.withValues(alpha: 0.05),
      borderColor: context.surface,
      activeIconColor: context.onPrimary,
      iconColor: context.onSurface,
      activeBackgroundColor: context.outlineVariant.withValues(alpha: context.isDarkMode ? 0.12 : 0.06),
      textStyle: PlatformX.isMobileView
          ? context.titleMedium!.copyWith(color: context.onBackground).appFont(context).textBold
          : context.labelLarge!.copyWith(color: context.onBackground).appFont(context),
      activeTextStyle: PlatformX.isMobileView
          ? context.titleMedium!.copyWith(color: context.onBackground).appFont(context).textBold
          : context.labelLarge!.copyWith(color: context.onBackground).appFont(context),
      subtextStyle: PlatformX.isMobileView
          ? context.labelLarge!.copyWith(color: context.outlineVariant).appFont(context).textBold
          : context.labelMedium!.copyWith(color: context.outlineVariant).appFont(context),
      activeSubtextStyle: PlatformX.isMobileView
          ? context.labelLarge!.copyWith(color: context.outlineVariant).appFont(context).textBold
          : context.labelMedium!.copyWith(color: context.outlineVariant).appFont(context),

      items: [
        AdminMenuItem(
          route: 'inbox_screen_type',
          title: context.tr.inbox_home_type,
          isSection: true,
          children: [
            AdminMenuItem(
              route: 'inbox_screen_type_agent',
              title: context.tr.inbox_agent_type,
              isSelected: currentInboxScreenType == InboxScreenType.agent,
              icon: (size) => VisirIcon(type: VisirIconType.agent, size: size, isSelected: currentInboxScreenType == InboxScreenType.agent),
            ),
            AdminMenuItem(
              route: 'inbox_screen_type_manual',
              title: context.tr.inbox_manual_type,
              isSelected: currentInboxScreenType == InboxScreenType.manual,
              icon: (size) => VisirIcon(type: VisirIconType.manual, size: size, isSelected: currentInboxScreenType == InboxScreenType.manual),
            ),
          ],
        ),
        if (!isAgenticUi)
          AdminMenuItem(
            route: 'inbox',
            title: context.tr.tab_inbox,
            isSection: true,
            children: InboxFilterType.values
                .map((e) => AdminMenuItem(route: 'inbox_${e.name}', title: e.getName(context), isSelected: inboxFilter == e))
                .toList(),
          ),
        if (!isAgenticUi)
          AdminMenuItem(
            route: 'suggestion',
            title: context.tr.ai_suggestion_section,
            isSection: true,
            children: [
              AdminMenuItem(
                route: 'suggestion_filter',
                title: context.tr.inbox_filter_section,
                children: InboxSuggestionFilterType.values
                    .map(
                      (e) => AdminMenuItem(
                        route: 'suggestions_filter_${e.name}',
                        title: e.name.toSentenceCase(),
                        color: e.color,
                        subtext: true,
                        isSelected: inboxSuggestionFilter.value == e,
                      ),
                    )
                    .toList(),
              ),
              AdminMenuItem(
                route: 'suggestions_sort',
                title: context.tr.inbox_sort_section,
                children: InboxSuggestionSortType.values
                    .map(
                      (e) => AdminMenuItem(
                        route: 'suggestions_sort_${e.name}',
                        title: e.name.toSentenceCase(),
                        subtext: true,
                        isSelected: inboxSuggestionSort.value == e,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),

        if (PlatformX.isDesktopView || isAgenticUi)
          AdminMenuItem(
            route: 'projects',
            title: context.tr.project_pref_title,
            isSelected: false,
            isSection: true,
            children: buildProjectMenuItem(null, projects, projectHide),
          ),

        if (PlatformX.isDesktopView)
          AdminMenuItem(
            route: 'calendar',
            title: context.tr.tab_calendar,
            isSection: true,
            children: calendars.entries.isEmpty
                ? [
                    AdminMenuItem(
                      route: 'need_to_integrate',
                      title: context.tr.need_to_integrate_calendar,
                      isSelected: false,
                      icon: (size) => VisirIcon(type: VisirIconType.integration, size: size),
                    ),
                  ]
                : calendars.entries
                      .map(
                        (e) => AdminMenuItem(
                          route: 'calendar_${e.key}',
                          icon: (size) {
                            final oauth = calendarOAuthsMap[e.key];
                            if (oauth == null) return SizedBox.shrink();
                            return AuthImageView(oauth: oauth, size: size);
                          },
                          title: e.key,
                          isSelected: false,
                          children: e.value
                              .map(
                                (e) => AdminMenuItem(
                                  route: 'calendar_id_${e.uniqueId}',
                                  title: e.name,
                                  isSelected: false,
                                  subtext: true,
                                  isToggle: !calendarHide.contains(e.uniqueId),
                                  color: ColorX.fromHex(calendarColors[e.uniqueId] ?? e.backgroundColor),
                                ),
                              )
                              .toList(),
                        ),
                      )
                      .toList(),
          ),

        if (PlatformX.isDesktopView)
          AdminMenuItem(
            route: 'viewtype',
            title: context.tr.viewtype_section,
            isSection: true,
            children:
                [
                      CalendarType.day,
                      CalendarType.twoDays,
                      CalendarType.threeDays,
                      CalendarType.fourDays,
                      CalendarType.fiveDays,
                      CalendarType.sixDays,
                      CalendarType.week,
                    ]
                    .map(
                      (e) => AdminMenuItem(
                        route: 'viewtype_${e.name}',
                        icon: (size) => VisirIcon(
                          type: e.getVisirIcon(size: size).type,
                          size: size,
                          isSelected: calendarType == e,
                        ),
                        options: VisirButtonOptions(
                          tabType: widget.tabType,
                          doNotConvertCase: true,
                          tooltipLocation: VisirButtonTooltipLocation.none,
                          message: context.tr.tooltip_view_range,
                          customShortcutTooltip: context.tr.tooltip_view_range_shortcut_to_week,
                          shortcuts: [
                            VisirButtonKeyboardShortcut(
                              message: '',
                              keys: [e.shortcut],
                              subkeys: e.subshortcut == null
                                  ? null
                                  : [
                                      [e.subshortcut!],
                                    ],
                              itemTitle: e.getTitle(context),
                              onTrigger: () {
                                ref.read(calendarTypeChangerProvider(widget.tabType).notifier).updateType(e);
                                return true;
                              },
                            ),
                          ],
                        ),
                        title: e.getTitle(context),
                        isSelected: calendarType == e,
                      ),
                    )
                    .toList(),
          ),
      ],
      selectedRoute: InboxFilterType.all.name,
      tabType: widget.tabType,
      onSelected: (item) {
        if (item.route == 'need_to_integrate') {
          Utils.showPopupDialog(
            child: PreferenceScreen(key: Utils.preferenceScreenKey, initialPreferenceScreenType: PreferenceScreenType.integration),
            size: PlatformX.isMobileView ? null : Size(640, 560),
          );
          return;
        }

        final inboxFilter = InboxFilterType.values.firstWhereOrNull((e) => 'inbox_${e.name}' == item.route);
        if (inboxFilter != null) {
          ref.read(inboxFilterProvider(widget.tabType).notifier).setInboxFilter(inboxFilter);
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            Navigator.maybePop(context);
          });
          return;
        }
        final inboxSuggestionFilter = InboxSuggestionFilterType.values.firstWhereOrNull((e) => 'suggestions_filter_${e.name}' == item.route);
        if (inboxSuggestionFilter != null) {
          ref.read(inboxSuggestionFilterProvider(widget.tabType).notifier).setInboxSuggestionFilter(inboxSuggestionFilter);
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            Navigator.maybePop(context);
          });
          return;
        }
        final inboxSuggestionSort = InboxSuggestionSortType.values.firstWhereOrNull((e) => 'suggestions_sort_${e.name}' == item.route);
        if (inboxSuggestionSort != null) {
          ref.read(inboxSuggestionSortProvider(widget.tabType).notifier).setInboxSuggestionSort(inboxSuggestionSort);
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            Navigator.maybePop(context);
          });
          return;
        }
        if (item.route.startsWith('calendar_id_')) {
          final calendarId = item.route.substring('calendar_id_'.length);
          ref.read(calendarHideProvider(widget.tabType).notifier).toggle(calendarId);
          return;
        }

        if (item.route.startsWith('viewtype_')) {
          final viewtype = item.route.substring('viewtype_'.length);
          ref.read(calendarTypeChangerProvider(widget.tabType).notifier).updateType(CalendarType.values.firstWhere((e) => e.name == viewtype));
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            Navigator.maybePop(context);
          });
          return;
        }

        if (item.route.startsWith('project_hide')) {
          final projectId = item.route.substring('project_hide_'.length);
          final project = projects.firstWhere((e) => e.uniqueId == projectId);
          ref.read(projectHideProvider(widget.tabType).notifier).toggle(project);
          return;
        }

        if (item.route == 'inbox_screen_type_agent') {
          ref.read(currentInboxScreenTypeProvider.notifier).update(InboxScreenType.agent);
          return;
        }

        if (item.route == 'inbox_screen_type_manual') {
          ref.read(currentInboxScreenTypeProvider.notifier).update(InboxScreenType.manual);
          return;
        }
      },
    );
  }

  List<AdminMenuItem> buildProjectMenuItem(ProjectEntity? parent, List<ProjectEntity> projects, List<String> projectHide) {
    final childProjects = projects.where((e) => parent?.isParent(e.parentId) ?? e.parentId == null).toList()
      ..sort(
        (a, b) => projects.any((e) => a.isParent(e.parentId))
            ? -1
            : projects.any((e) => b.isParent(e.parentId))
            ? 1
            : 0,
      );
    final currentProjects = projects.where((e) => e.isParent(parent?.uniqueId ?? ''));
    if (childProjects.isEmpty) return [];
    final items = [
      ...currentProjects.map((e) {
        return AdminMenuItem(
          route: 'project_hide_${e.uniqueId}',
          title: e.name,
          isSelected: false,
          subtext: false,
          options: VisirButtonOptions(tooltipLocation: VisirButtonTooltipLocation.right, message: e.description),
          icon: (size) => Container(
            width: size,
            height: size,
            decoration: BoxDecoration(color: e.color, borderRadius: BorderRadius.circular(size / 3)),
            alignment: Alignment.center,
            child: e.icon == null ? null : VisirIcon(type: e.icon!, size: size * 2 / 3, isSelected: true),
          ),
          isToggle: !projectHide.contains(e.uniqueId),
        );
      }),
      ...childProjects.map((e) {
        final children = buildProjectMenuItem(e, projects, projectHide);
        return AdminMenuItem(
          route: 'project_hide_${e.uniqueId}',
          title: e.name,
          isSelected: false,
          subtext: children.isEmpty,
          options: children.isEmpty && e.description?.isNotEmpty == true
              ? VisirButtonOptions(tooltipLocation: VisirButtonTooltipLocation.right, message: e.description)
              : null,
          icon: children.isNotEmpty
              ? null
              : (size) => Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(color: e.color, borderRadius: BorderRadius.circular(size / 3)),
                  alignment: Alignment.center,
                  child: e.icon == null ? null : VisirIcon(type: e.icon!, size: size * 2 / 3, isSelected: true),
                ),
          isToggle: !projectHide.contains(e.uniqueId),
          children: children,
        );
      }).toList(),
    ];

    return items..sort(
      (a, b) => a.children.isNotEmpty
          ? -1
          : b.children.isNotEmpty
          ? 1
          : 0,
    );
  }
}
