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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarSideBar extends SideBar {
  CalendarSideBar({super.key, super.onSelected, super.width, super.drawerCallback, required super.tabType, super.items = const []})
    : super(selectedRoute: '', activeBackgroundColor: Colors.transparent, hoverBackgroundColor: Colors.transparent);

  @override
  _CalendarSideBarState createState() => _CalendarSideBarState();
}

class _CalendarSideBarState extends SideBarState {
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
  void didUpdateWidget(CalendarSideBar oldWidget) {
    if (oldWidget.selectedRoute != widget.selectedRoute) {
      setState(() {});
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final calendars = ref.watch(calendarListControllerProvider);
    final calendarOAuths = ref.watch(localPrefControllerProvider.select((e) => e.value?.calendarOAuths));
    final calendarOAuthsMap = calendarOAuths?.fold<Map<String, OAuthEntity>>({}, (map, e) => map..[e.email] = e) ?? {};
    final calendarColors = ref.watch(authControllerProvider.select((e) => e.requireValue.userCalendarColors));
    final calendarHide = ref.watch(calendarHideProvider(widget.tabType));
    final calendarType = ref.watch(calendarTypeChangerProvider(widget.tabType));
    ref.watch(themeSwitchProvider);

    final projects = ref.watch(projectListControllerProvider);
    final projectHide = ref.watch(projectHideProvider(widget.tabType));

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
          route: 'projects',
          title: context.tr.project_pref_title,
          isSelected: false,
          isSection: true,
          children: buildProjectMenuItem(null, projects, projectHide),
        ),
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
        AdminMenuItem(
          route: 'viewtype',
          title: context.tr.viewtype_section,
          isSection: true,
          children: CalendarType.values
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

        if (item.route.startsWith('project_hide')) {
          final projectId = item.route.substring('project_hide_'.length);
          final project = projects.firstWhere((e) => e.uniqueId == projectId);
          ref.read(projectHideProvider(widget.tabType).notifier).toggle(project);
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
