import 'dart:async';
import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/calendar/infrastructure/repositories/calendar_repository.dart';
import 'package:Visir/features/calendar/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/application/inbox_list_controller.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_linked_task_entity.dart';
import 'package:Visir/features/inbox/providers.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/task/infrastructure/repositories/task_repository.dart';
import 'package:Visir/features/task/providers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inbox_linked_task_controller.g.dart';

@riverpod
class InboxLinkedTaskController extends _$InboxLinkedTaskController {
  late InboxLinkedTaskControllerInternal _controller;
  static String stringKey = '${TabType.home.name}:inboxLinkedTasks';

  @override
  InboxLinkedTaskFetchListEntity? build() {
    final isSearch = ref.watch(inboxListIsSearchProvider);
    final date = ref.watch(inboxListDateProvider);
    final isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
    _controller = ref.watch(inboxLinkedTaskControllerInternalProvider(isSearch: isSearch, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn).notifier);

    ref.listen(inboxLinkedTaskControllerInternalProvider(isSearch: isSearch, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn), (prev, next) {
      updateState(next.value);
    });

    return null;
  }

  Timer? timer;
  void updateState(InboxLinkedTaskFetchListEntity? data) {
    if (timer == null) state = data;
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: kControllerDebouncMillisecond), () {
      state = data;
      timer = null;
    });
  }

  Future<void> setInboxLinkedTasks(List<InboxEntity> inboxes, int sequence) async {
    return _controller.setInboxLinkedTasks(inboxes, sequence);
  }

  void upsertLinkedEventForInbox(EventEntity event) {
    return _controller.upsertLinkedEventForInbox(event);
  }

  void deleteLinkedEventForInbox(EventEntity event) {
    return _controller.deleteLinkedEventForInbox(event);
  }

  void upsertLinkedTaskForInbox(TaskEntity task, {EventEntity? event}) {
    return _controller.upsertLinkedTaskForInbox(task, event: event);
  }

  void deleteLinkedTaskForInbox(TaskEntity task) {
    return _controller.deleteLinkedTaskForInbox(task);
  }
}

@riverpod
class InboxLinkedTaskControllerInternal extends _$InboxLinkedTaskControllerInternal {
  late TaskRepository _taskRepository;
  late CalendarRepository _calendarRepository;

  ValueNotifier<bool> isLinkedTaskLoadingListenable = ValueNotifier(false);
  bool get isLinkedTaskLoading => isLinkedTaskLoadingListenable.value;

  int sequence = 0;

  List<InboxEntity> _prevInboxes = [];

  @override
  Future<InboxLinkedTaskFetchListEntity?> build({required bool isSearch, required int year, required int month, required int day, required bool isSignedIn}) async {
    _taskRepository = ref.watch(taskRepositoryProvider);
    _calendarRepository = ref.watch(calendarRepositoryProvider);

    if (isSearch) {
      return null;
    }

    if (ref.watch(shouldUseMockDataProvider)) return null;

    // shouldUseMockDataProvider가 false이므로 isSignedIn은 true입니다
    // 따라서 userId는 안전하게 가져올 수 있습니다
    final userId = ref.watch(authControllerProvider.select((v) => v.requireValue.id));

    final provider = inboxListControllerInternalProvider(isSearch: isSearch, year: year, month: month, day: day, isSignedIn: isSignedIn);

    await persist(
      ref.watch(storageProvider.future),
      key: '${InboxLinkedTaskController.stringKey}:${isSignedIn}:${isSearch ? 'search' : '${year}_${month}_${day}'}',
      encode: (InboxLinkedTaskFetchListEntity? state) => state == null ? '' : jsonEncode(state.toJson()),
      decode: (String encoded) {
        if (isSearch) return null;
        final trimmed = encoded.trim();
        if (trimmed.isEmpty || trimmed == 'null') {
          return InboxLinkedTaskFetchListEntity(linkedTasks: [], sequence: 0);
        }
        return InboxLinkedTaskFetchListEntity.fromJson(jsonDecode(trimmed) as Map<String, dynamic>);
      },
      options: StorageOptions(destroyKey: userId + '1'),
    ).future;

    ref.listen(provider.select((e) => e.value?.sequence ?? 0), (previous, next) {
      sequence = next;
      if (sequence <= (state.value?.sequence ?? -1)) return;
      final inboxes = ref.read(provider).value?.inboxes ?? [];
      _prevInboxes = [..._prevInboxes, ...inboxes].unique((e) => e.id).toList();
      setInboxLinkedTasks(_prevInboxes, sequence);
    });

    return state.value;
  }

  Future<void> setInboxLinkedTasks(List<InboxEntity> inboxes, int sequence) async {
    if (!ref.mounted) return;

    ref.read(loadingStatusProvider.notifier).update(InboxLinkedTaskController.stringKey, LoadingState.loading);
    _fetchLinkedTasks(inboxes)
        .then((e) {
          ref.read(loadingStatusProvider.notifier).update(InboxLinkedTaskController.stringKey, LoadingState.success);
        })
        .catchError((e) {
          ref.read(loadingStatusProvider.notifier).update(InboxLinkedTaskController.stringKey, LoadingState.error);
        });
  }

  Future<void> _processing = Future.value();

  Future<void> _fetchLinkedTasks(List<InboxEntity> inboxes) async {
    final previous = _processing;
    final completer = Completer<void>();
    _processing = completer.future;

    try {
      await previous;
    } catch (_) {}

    try {
      final userId = ref.read(authControllerProvider).requireValue.id;
      final mailKeys = inboxes.where((e) => e.linkedMail != null).map((e) => '${e.linkedMail!.hostMail}:${e.linkedMail!.messageId}').toSet().toList();
      final messageKeys = inboxes
          .where((e) => e.linkedMessage != null)
          .map((e) => '${e.linkedMessage!.teamId}:${e.linkedMessage!.channelId}:${e.linkedMessage!.messageId}')
          .toSet()
          .toList();
      if (mailKeys.isEmpty && messageKeys.isEmpty) return;

      final parsedMapEither = await _taskRepository.fetchLinkedTasksForInboxes(userId: userId, mailKeys: mailKeys, messageKeys: messageKeys);
      final parsedMap = parsedMapEither.getOrElse((l) => {});

      // Remote-only enrichment: batch fetch ALL linked events by calendar and patch
      final pref = ref.read(localPrefControllerProvider).value;

      // Build calendar -> set of eventIds
      final calToIds = <String, Set<String>>{};
      final calByKey = <String, CalendarEntity>{};
      parsedMap.forEach((_, tasks) {
        for (final t in tasks) {
          final le = t.linkedEvent;
          if (le == null) continue;
          final key = le.calendar.uniqueId;
          (calToIds[key] ??= <String>{}).add(le.eventId);
          calByKey[key] = le.calendar;
        }
      });

      // Fetch per calendar (remote) and build lookup
      final fetchedByCal = <String, Map<String, dynamic>>{}; // eventId -> EventEntity
      if (pref != null) {
        for (final entry in calToIds.entries) {
          final cal = calByKey[entry.key]!;
          final oauth = ref.read(localPrefControllerProvider.select((v) => v.value?.calendarOAuths?.firstWhereOrNull((e) => e.email == cal.email)));
          if (oauth != null) {
            final either = await _calendarRepository.fetchEventsByIds(oauth: oauth, calendar: cal, eventIds: entry.value.toList());
            final list = either.getOrElse((l) => []);
            fetchedByCal[entry.key] = {for (final e in list) e.eventId: e};
          }
        }
      }

      // Patch tasks with fetched events
      final enrichedMap = <InboxLinkedTaskEntity>[];
      for (final entry in parsedMap.entries) {
        final out = <TaskEntity>[];
        for (final t in entry.value) {
          if (!t.isEvent) {
            out.add(t);
          } else {
            final le = t.linkedEvent;
            final fresh = fetchedByCal[le!.calendar.uniqueId]?[le.eventId] as EventEntity?;
            if (fresh != null && !fresh.isCancelled) out.add(t.copyWith(linkedEvent: fresh));
          }
        }
        enrichedMap.add(InboxLinkedTaskEntity(inboxId: entry.key, tasks: out));
      }

      state = AsyncData(InboxLinkedTaskFetchListEntity(linkedTasks: enrichedMap, sequence: sequence));
    } finally {
      completer.complete();
    }
  }

  void upsertLinkedEventForInbox(EventEntity event) {
    final taskFromEvents = state.value?.linkedTasks.where((e) => e.tasks.any((t) => t.linkedEvent?.eventId == event.eventId)).toList();
    if (taskFromEvents != null && taskFromEvents.isNotEmpty) {
      taskFromEvents.forEach((e) {
        e.tasks.forEach((t) {
          upsertLinkedTaskForInbox(t, event: event);
        });
      });
    }
  }

  void deleteLinkedEventForInbox(EventEntity event) {
    final taskFromEvents = state.value?.linkedTasks.where((e) => e.tasks.any((t) => t.linkedEvent?.eventId == event.eventId)).toList();
    if (taskFromEvents != null && taskFromEvents.isNotEmpty) {
      taskFromEvents.forEach((e) {
        e.tasks.forEach((t) {
          deleteLinkedTaskForInbox(t);
        });
      });
    }
  }

  void upsertLinkedTaskForInbox(TaskEntity task, {EventEntity? event}) {
    // Determine the inbox id key based on linked mail/message

    String? inboxId;
    if (task.linkedMails.isNotEmpty) {
      final lm = task.linkedMails.first;
      inboxId = InboxEntity.getInboxIdFromLinkedMail(lm);
    } else if (task.linkedMessages.isNotEmpty) {
      final msg = task.linkedMessages.first;
      inboxId = InboxEntity.getInboxIdFromLinkedChat(msg);
    }
    if (inboxId == null) return;

    final current = state.value?.linkedTasks.firstWhereOrNull((e) => e.inboxId == inboxId);
    final list = <TaskEntity>[...(current?.tasks ?? [])];
    final idx = list.indexWhere((t) => t.id == task.id);
    if (idx >= 0) {
      list[idx] = task.copyWith(linkedEvent: event);
    } else {
      list.add(task.copyWith(linkedEvent: event));
    }

    if (current != null) {
      final newState = state.value?.linkedTasks.map((e) => e.inboxId == current.inboxId ? current.copyWith(tasks: list) : e).toList();
      state = AsyncData(InboxLinkedTaskFetchListEntity(linkedTasks: newState ?? <InboxLinkedTaskEntity>[], sequence: sequence));
    } else {
      final newState = [...(state.value?.linkedTasks ?? <InboxLinkedTaskEntity>[]), InboxLinkedTaskEntity(inboxId: inboxId, tasks: list)];
      state = AsyncData(InboxLinkedTaskFetchListEntity(linkedTasks: newState, sequence: sequence));
    }
  }

  void deleteLinkedTaskForInbox(TaskEntity task) {
    String? inboxId;
    if (task.linkedMails.isNotEmpty) {
      final lm = task.linkedMails.first;
      inboxId = InboxEntity.getInboxIdFromLinkedMail(lm);
    } else if (task.linkedMessages.isNotEmpty) {
      final msg = task.linkedMessages.first;
      inboxId = InboxEntity.getInboxIdFromLinkedChat(msg);
    }
    if (inboxId == null) return;
    final current = state.value?.linkedTasks.firstWhereOrNull((e) => e.inboxId == inboxId);
    final list = <TaskEntity>[...(current?.tasks ?? [])];
    final idx = list.indexWhere((t) => t.id == task.id);
    if (idx >= 0) {
      list.removeAt(idx);
    }

    if (current != null) {
      final newState = state.value?.linkedTasks.map((e) => e.inboxId == current.inboxId ? current.copyWith(tasks: list) : e).toList();
      state = AsyncData(InboxLinkedTaskFetchListEntity(linkedTasks: newState ?? <InboxLinkedTaskEntity>[], sequence: sequence));
    }
  }
}
