import 'package:Visir/dependency/admin_scaffold/admin_scaffold.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/calendar/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:Visir/features/task/application/task_list_controller.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:Visir/features/task/domain/entities/task_label_entity.dart';
import 'package:Visir/features/task/providers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskSideBar extends SideBar {
  TaskSideBar({super.key, super.onSelected, super.width, super.drawerCallback, required super.tabType, super.items = const []})
    : super(selectedRoute: '', activeBackgroundColor: Colors.transparent, hoverBackgroundColor: Colors.transparent);

  @override
  _TaskSideBarState createState() => _TaskSideBarState();
}

class _TaskSideBarState extends SideBarState {
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
  void didUpdateWidget(TaskSideBar oldWidget) {
    if (oldWidget.selectedRoute != widget.selectedRoute) {
      setState(() {});
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(taskListControllerProvider);
    ref.watch(themeSwitchProvider);
    final completedTaskOptionType = ref.watch(authControllerProvider.select((e) => e.requireValue.userCompletedTaskOptionType));
    final taskLabelList = ref.watch(taskListControllerProvider.select((v) => v.taskLabelList));
    final filteredTaskLabelList = List<TaskLabelEntity>.from(taskLabelList);
    if (completedTaskOptionType == CompletedTaskOptionType.delete) {
      filteredTaskLabelList.removeWhere((l) => l.type == TaskLabelType.completed);
    }

    final projects = ref.watch(projectListControllerProvider);
    final projectHide = ref.watch(projectHideProvider(widget.tabType));

    final label = ref.watch(taskLabelProvider);

    return SideBar(
      tabType: widget.tabType,
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

      selectedRoute: label.id,
      width: widget.width,
      onSelected: (item) {
        if (item.route.startsWith('project_hide')) {
          final projectId = item.route.substring('project_hide_'.length);
          final project = projects.firstWhere((e) => e.uniqueId == projectId);
          ref.read(projectHideProvider(widget.tabType).notifier).toggle(project);
          return;
        }

        final label = filteredTaskLabelList.firstWhereOrNull((l) => l.id == item.route);
        if (label == null) return;
        ref.read(taskLabelProvider.notifier).updateLabel(label);
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Navigator.maybePop(context);
        });
      },
      items: [
        AdminMenuItem(
          route: 'all',
          title: context.tr.tab_task,
          isSelected: false,
          isSection: true,
          children: [
            // 메인에 표시할 label들: all, scheduled
            ...[TaskLabelType.all, TaskLabelType.scheduled, TaskLabelType.overdue, TaskLabelType.unscheduled, TaskLabelType.completed].map((type) {
              final l = filteredTaskLabelList.firstWhere((label) => label.type == type);
              bool isColorLabel = l.colorString != null;
              return AdminMenuItem(
                route: l.id,
                isSelected: label.id == l.id,
                title: l.type.getTitle(context, l.colorString),
                color: l.colorString == null ? null : ColorX.fromHex(l.colorString!),
                subtext: isColorLabel,
                badge: null,
                height: PlatformX.isMobileView
                    ? isColorLabel
                          ? 32
                          : 40
                    : isColorLabel
                    ? 25
                    : 32,
              );
            }).toList(),
            // More 섹션: overdue, unscheduled, completed
            // AdminMenuItem(
            //   route: context.tr.task_label_more,
            //   titleOnExpanded: context.tr.task_label_less,
            //   children: [TaskLabelType.overdue, TaskLabelType.unscheduled, TaskLabelType.completed].where((type) => filteredTaskLabelList.any((label) => label.type == type)).map((
            //     type,
            //   ) {
            //     final l = filteredTaskLabelList.firstWhere((label) => label.type == type);
            //     bool isColorLabel = l.colorString != null;
            //     return AdminMenuItem(
            //       route: l.id,
            //       isSelected: label.id == l.id,
            //       title: l.type.getTitle(context, l.colorString),
            //       color: l.colorString == null ? null : ColorX.fromHex(l.colorString!),
            //       subtext: isColorLabel,
            //       badge: null,
            //       height: PlatformX.isMobileView
            //           ? isColorLabel
            //                 ? 32
            //                 : 40
            //           : isColorLabel
            //           ? 25
            //           : 32,
            //     );
            //   }).toList(),
            // ),
          ],
        ),
        AdminMenuItem(route: 'projects', title: context.tr.project_pref_title, isSelected: false, isSection: true, children: buildProjectMenuItem(null, projects, projectHide)),
      ],
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
          options: children.isEmpty && e.description?.isNotEmpty == true ? VisirButtonOptions(tooltipLocation: VisirButtonTooltipLocation.right, message: e.description) : null,
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
