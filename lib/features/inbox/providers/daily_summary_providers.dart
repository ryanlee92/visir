import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_suggestion_entity.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daily_summary_providers.g.dart';

/// 프로젝트 조회를 위한 Map 캐시 (성능 최적화)
@riverpod
Map<String, ProjectEntity> _projectMap(Ref ref) {
  final projects = ref.watch(projectListControllerProvider);
  return {for (var p in projects) p.uniqueId: p};
}

/// 선택된 프로젝트의 관련 프로젝트 ID 목록 계산
@riverpod
List<String> relevantProjectIds(
  Ref ref,
  ProjectEntity? selectedProject,
  List<ProjectEntityWithDepth> projects,
) {
  if (selectedProject == null) return [];
  final project = projects.firstWhereOrNull((p) => p.project.uniqueId == selectedProject.uniqueId);
  if (project == null) return [selectedProject.uniqueId];

  final allIds = {selectedProject.uniqueId};

  Set<String> findDescendants(String targetParentId) {
    final parentNode = projects.firstWhereOrNull((p) => p.project.uniqueId == targetParentId);
    Iterable<String> childrenIds;

    if (parentNode != null) {
      childrenIds = projects.where((p) => parentNode.project.isParent(p.project.parentId)).map((p) => p.project.uniqueId);
    } else {
      childrenIds = projects.where((p) => p.project.parentId == targetParentId).map((p) => p.project.uniqueId);
    }

    if (childrenIds.isEmpty) return {};

    final descendants = <String>{...childrenIds};
    for (final childId in childrenIds) {
      descendants.addAll(findDescendants(childId));
    }
    return descendants;
  }

  allIds.addAll(findDescendants(selectedProject.uniqueId));
  return allIds.toList();
}

/// 필터링된 태스크 계산 (캐싱)
@riverpod
List<TaskEntity> filteredTasks(
  Ref ref,
  List<TaskEntity> tasks,
  ProjectEntity? selectedProject,
  List<String> relevantIds,
) {
  final baseFilteredTasks = tasks.where((t) => !t.isCancelled && !t.isEventDummyTask).toList();

  if (selectedProject == null) {
    return baseFilteredTasks;
  }

  return baseFilteredTasks.where((t) => relevantIds.contains(t.projectId)).toList();
}

/// 필터링된 인박스 계산 (캐싱)
@riverpod
List<InboxEntity> filteredInboxes(
  Ref ref,
  List<InboxEntity> inboxes,
  ProjectEntity? selectedProject,
  List<String> relevantIds,
) {
  if (selectedProject == null) return inboxes;
  return inboxes.where((i) => i.suggestion?.project_id != null && relevantIds.contains(i.suggestion!.project_id)).toList();
}

/// 오늘의 태스크 계산 (캐싱)
@riverpod
List<TaskEntity> todayTasks(
  Ref ref,
  List<TaskEntity> filteredTasks,
) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));

  return filteredTasks.where((t) => !t.startDate.isBefore(today) && t.startDate.isBefore(tomorrow) && t.isDone != true).toList();
}

/// 오늘의 이벤트 계산 (캐싱)
@riverpod
List<EventEntity> todayEvents(
  Ref ref,
  List<EventEntity> events,
) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));

  return events.where((e) => e.startDate.isAfter(today) && e.startDate.isBefore(tomorrow)).toList();
}

/// 지연된 태스크 계산 (캐싱)
@riverpod
List<TaskEntity> overdueTasks(
  Ref ref,
  List<TaskEntity> filteredTasks,
) {
  return filteredTasks.where((t) => !t.isUnscheduled && t.isOverdue && t.status == TaskStatus.none).toList();
}

/// 이벤트-태스크 매핑 (캐싱)
@riverpod
Map<String, TaskEntity> eventToTaskMap(
  Ref ref,
  List<TaskEntity> tasks,
) {
  final eventToTaskMap = <String, TaskEntity>{};
  for (final task in tasks) {
    if (task.linkedEvent != null) {
      eventToTaskMap[task.linkedEvent!.eventId] = task;
    }
  }
  return eventToTaskMap;
}

/// 다음 일정 아이템 데이터 클래스
class UpcomingItem {
  final DateTime time;
  final String title;
  final bool isEvent;
  final EventEntity? event;
  final TaskEntity? task;
  final Color color;
  final ProjectEntity? project;
  final CalendarEntity? calendar;
  final String? description;

  UpcomingItem({
    required this.time,
    required this.title,
    required this.isEvent,
    this.event,
    this.task,
    required this.color,
    this.project,
    this.calendar,
    this.description,
  });
}

/// 오늘의 다음 일정 아이템 계산 (캐싱) - Color는 위젯에서 설정
@riverpod
List<UpcomingItem> todayUpcomingItems(
  Ref ref,
  List<EventEntity> todayEvents,
  List<TaskEntity> todayTasks,
  Map<String, TaskEntity> eventToTaskMap,
  List<ProjectEntityWithDepth> projects,
) {
  final now = DateTime.now();

  final allUpcomingItems = <UpcomingItem>[
    ...todayEvents.where((e) => !e.isAllDay).map((e) {
      final linkedTask = eventToTaskMap[e.eventId];
      return UpcomingItem(
        time: e.editedStartTime ?? e.startDate,
        title: e.title ?? 'Untitled',
        isEvent: true,
        event: e,
        task: linkedTask,
        color: e.backgroundColor,
        calendar: e.calendar,
        description: e.description,
      );
    }),
    ...todayTasks
        .where((t) => !t.isAllDay && !t.isEventDummyTask && !t.isDone && !t.isCancelled)
        .map(
          (t) {
            final projectWithDepth = projects.firstWhereOrNull((p) => p.project.isPointedProject(t));
            return UpcomingItem(
              time: t.startAt ?? t.startDate,
              title: t.title ?? 'Untitled',
              isEvent: false,
              task: t,
              color: projectWithDepth?.project.color ?? Colors.transparent, // 위젯에서 실제 색상 설정
              project: projectWithDepth?.project,
              calendar: t.linkedEvent?.calendar,
              description: t.description,
            );
          },
        ),
  ].where((item) => item.time.isAfter(now)).toList()
    ..sort((a, b) => a.time.compareTo(b.time));

  return allUpcomingItems;
}

/// 미래 일정 아이템 계산 (캐싱) - Color는 위젯에서 설정
@riverpod
List<UpcomingItem> futureUpcomingItems(
  Ref ref,
  List<EventEntity> events,
  List<TaskEntity> tasks,
  Map<String, TaskEntity> eventToTaskMap,
  List<ProjectEntityWithDepth> projects,
) {
  final now = DateTime.now();

  final futureEvents = events.where((e) => e.startDate.isAfter(now) && !e.isAllDay).toList();
  final futureTasks = tasks.where((t) => !t.isAllDay && !t.isEventDummyTask && !t.isDone && !t.isCancelled && t.startDate.isAfter(now)).toList();

  final futureItems = <UpcomingItem>[
    ...futureEvents.map((e) {
      final linkedTask = eventToTaskMap[e.eventId];
      return UpcomingItem(
        time: e.editedStartTime ?? e.startDate,
        title: e.title ?? 'Untitled',
        isEvent: true,
        event: e,
        task: linkedTask,
        color: e.backgroundColor,
        calendar: e.calendar,
        description: e.description,
      );
    }),
    ...futureTasks.map(
      (t) {
        final projectWithDepth = projects.firstWhereOrNull((p) => p.project.isPointedProject(t));
        return UpcomingItem(
          time: t.startAt ?? t.startDate,
          title: t.title ?? 'Untitled',
          isEvent: false,
          task: t,
          color: projectWithDepth?.project.color ?? Colors.transparent, // 위젯에서 실제 색상 설정
          project: projectWithDepth?.project,
          calendar: t.linkedEvent?.calendar,
          description: t.description,
        );
      },
    ),
  ]..sort((a, b) => a.time.compareTo(b.time));

  return futureItems;
}

/// 다음 일정 아이템 (오늘 우선, 없으면 미래 일정)
@riverpod
UpcomingItem? nextItem(
  Ref ref,
  List<UpcomingItem> todayUpcomingItems,
  List<UpcomingItem> futureUpcomingItems,
) {
  if (todayUpcomingItems.isNotEmpty) {
    return todayUpcomingItems.first;
  }
  return futureUpcomingItems.isNotEmpty ? futureUpcomingItems.first : null;
}

/// 대시보드 아이템 데이터 클래스
class DashboardItem {
  final String title;
  final String? subtitle;
  final InboxSuggestionUrgency urgency;
  final VisirIconType icon;
  final String? projectId;
  final TaskEntity? task;
  final InboxEntity? inbox;

  DashboardItem({
    required this.title,
    this.subtitle,
    required this.urgency,
    required this.icon,
    this.projectId,
    this.task,
    this.inbox,
  });
}

/// 지연된 태스크를 대시보드 아이템으로 변환 (캐싱)
@riverpod
List<DashboardItem> overdueDashboardItems(
  Ref ref,
  List<TaskEntity> overdueTasks,
  List<ProjectEntityWithDepth> projects,
  String overdueTaskSubtitle,
) {
  return overdueTasks.map((t) {
    final projectWithDepth = projects.firstWhereOrNull((p) => p.project.uniqueId == t.projectId) ?? projects.firstWhereOrNull((p) => p.project.isDefault);
    return DashboardItem(
      title: t.title ?? 'Untitled',
      subtitle: overdueTaskSubtitle,
      urgency: InboxSuggestionUrgency.none,
      icon: projectWithDepth?.project.icon ?? VisirIconType.task,
      projectId: t.projectId,
      task: t,
    );
  }).toList();
}

/// 인박스를 이유별로 그룹화 (캐싱)
@riverpod
Map<InboxSuggestionReason, List<InboxEntity>> inboxesByReason(
  Ref ref,
  List<InboxEntity> filteredInboxes,
) {
  final inboxesByReason = <InboxSuggestionReason, List<InboxEntity>>{};
  for (final inbox in filteredInboxes) {
    if (inbox.suggestion?.reason != null) {
      inboxesByReason.putIfAbsent(inbox.suggestion!.reason, () => []).add(inbox);
    }
  }
  return inboxesByReason;
}

/// 정렬된 이유 목록 (캐싱)
@riverpod
List<InboxSuggestionReason> sortedReasons(
  Ref ref,
  Map<InboxSuggestionReason, List<InboxEntity>> inboxesByReason,
) {
  return inboxesByReason.keys.toList()
    ..sort((a, b) {
      final aHasUrgent = inboxesByReason[a]!.any((i) => i.suggestion?.urgency == InboxSuggestionUrgency.urgent);
      final bHasUrgent = inboxesByReason[b]!.any((i) => i.suggestion?.urgency == InboxSuggestionUrgency.urgent);

      // Urgent reasons first
      if (aHasUrgent && !bHasUrgent) return -1;
      if (!aHasUrgent && bHasUrgent) return 1;

      // Then by weight (lower weight = higher priority)
      return a.weight.compareTo(b.weight);
    });
}

