import 'dart:async';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/inbox/providers.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:collection/collection.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/application/inbox_config_controller.dart';
import 'package:Visir/features/inbox/application/inbox_linked_task_controller.dart';
import 'package:Visir/features/inbox/application/inbox_list_controller.dart';
import 'package:Visir/features/inbox/application/inbox_suggestion_controller.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_config_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_fetch_list_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_linked_task_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_suggestion_entity.dart';
import 'package:Visir/features/preference/application/last_app_open_close_date_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inbox_agent_list_controller.g.dart';

@riverpod
class InboxAgentListController extends _$InboxAgentListController {
  List<InboxListControllerInternalProvider> _dateControllers = [];
  List<InboxSuggestionControllerInternalProvider> _suggestionControllers = [];
  DateTime? _lastAppOpenCloseDate;

  static String stringKey = '${TabType.home.name}:inboxes:agent';

  InboxFetchListEntity? inboxes;
  InboxConfigFetchListEntity? configs;
  InboxSuggestionFetchListEntity? suggestions;
  InboxLinkedTaskFetchListEntity? linkedTasks;
  List<MessageChannelEntity> channels = [];
  List<MessageMemberEntity> members = [];
  List<MessageGroupEntity> groups = [];

  /// 실제로 fetch한 기간을 Duration으로 반환
  Duration get fetchDuration {
    final now = DateTime.now();

    DateTime startTime;
    if (_lastAppOpenCloseDate != null) {
      final hoursDiff = now.difference(_lastAppOpenCloseDate!).inHours;

      // 24시간 미만이면 24시간치 데이터 제공
      if (hoursDiff < 24) {
        startTime = now.subtract(const Duration(hours: 24));
      } else {
        // lastDate 이후로 필터링
        startTime = _lastAppOpenCloseDate!;
      }
    } else {
      // 저장된 날짜가 없으면 24시간 전부터 시작
      startTime = now.subtract(const Duration(hours: 24));
    }

    return now.difference(startTime);
  }

  /// fetch 기간을 Duration으로 반환 (외부에서 문자열 변환 시 사용)
  Duration get fetchDurationForDisplay {
    return fetchDuration;
  }

  @override
  InboxFetchListEntity? build() {
    final isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
    final lastAppOpenCloseDate = ref.watch(lastAppOpenCloseDateProvider);

    // Get last app open/close date
    _lastAppOpenCloseDate = lastAppOpenCloseDate;

    // Calculate date range: from last app open/close date to today
    // lastDate의 날짜부터 오늘까지 listen해야 함
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime startDate;
    if (_lastAppOpenCloseDate != null) {
      // lastDate의 날짜(00:00:00)부터 시작
      final lastDate = DateTime(_lastAppOpenCloseDate!.year, _lastAppOpenCloseDate!.month, _lastAppOpenCloseDate!.day);
      final daysDiff = today.difference(lastDate).inDays;

      // 최대 7일, 최소 1일로 제한
      if (daysDiff > 7) {
        startDate = today.subtract(const Duration(days: 7));
      } else if (daysDiff < 1) {
        // 오늘 접속한 경우 어제부터 시작
        startDate = today.subtract(const Duration(days: 1));
      } else {
        // 저장된 날짜의 00:00:00부터 시작
        startDate = lastDate;
      }
    } else {
      // 저장된 날짜가 없으면 어제부터 시작
      startDate = today.subtract(const Duration(days: 1));
    }

    // Generate list of dates from startDate to today (inclusive)
    // lastDate의 날짜부터 오늘까지 모든 날짜의 컨트롤러 생성
    _dateControllers = [];
    _suggestionControllers = [];
    DateTime currentDate = startDate;

    while (!currentDate.isAfter(today)) {
      final dateController = inboxListControllerInternalProvider(isSignedIn: isSignedIn, isSearch: false, year: currentDate.year, month: currentDate.month, day: currentDate.day);

      final suggestionController = inboxSuggestionControllerInternalProvider(
        isSearch: false,
        year: currentDate.year,
        month: currentDate.month,
        day: currentDate.day,
        isSignedIn: isSignedIn,
      );

      _dateControllers.add(dateController);
      _suggestionControllers.add(suggestionController);

      ref.watch(dateController.notifier);
      ref.watch(suggestionController.notifier);

      ref.listen(dateController, (prev, next) {
        if (next.value != null) {
          _updateInboxesFromControllers();
        }
      });

      ref.listen(suggestionController, (prev, next) {
        _updateSuggestionsFromControllers();
      });

      currentDate = currentDate.add(const Duration(days: 1));
    }

    ref.listen(inboxConfigListControllerProvider, (prev, next) {
      configs = next;
      updateData();
    });
    ref.listen(inboxLinkedTaskControllerProvider, (prev, next) {
      linkedTasks = next;
      updateData();
    });
    ref.listen(chatChannelListControllerProvider, (prev, next) {
      channels = ref.read(chatChannelListControllerProvider).values.expand((e) => e.channels).toList();
      updateData();
    });
    ref.listen(chatChannelListControllerProvider.select((v) => v.values.expand((e) => e.members).toList()), (prev, next) {
      members = next;
      updateData();
    });
    ref.listen(chatChannelListControllerProvider.select((v) => v.values.expand((e) => e.groups).toList()), (prev, next) {
      groups = next;
      updateData();
    });

    configs = ref.read(inboxConfigListControllerProvider);
    linkedTasks = ref.read(inboxLinkedTaskControllerProvider);
    channels = ref.read(chatChannelListControllerProvider).values.expand((e) => e.channels).toList();
    members = ref.read(chatChannelListControllerProvider.select((v) => v.values.expand((e) => e.members).toList()));
    groups = ref.read(chatChannelListControllerProvider.select((v) => v.values.expand((e) => e.groups).toList()));

    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Initial update if data is already available (from cache)
      _updateInboxesFromControllers();
      _updateSuggestionsFromControllers();
      // Then refresh to load new data
      refresh();
    });

    return null;
  }

  void _updateInboxesFromControllers() {
    final now = DateTime.now();

    // Calculate filter start time: lastDate 이후로 필터링
    // 24시간 미만이면 24시간치 데이터 제공
    DateTime filterStartTime;
    if (_lastAppOpenCloseDate != null) {
      final hoursDiff = now.difference(_lastAppOpenCloseDate!).inHours;

      // 24시간 미만이면 24시간치 데이터 제공
      if (hoursDiff < 24) {
        filterStartTime = now.subtract(const Duration(hours: 24));
      } else {
        // lastDate 이후로 필터링
        filterStartTime = _lastAppOpenCloseDate!;
      }
    } else {
      // 저장된 날짜가 없으면 24시간 전부터 시작
      filterStartTime = now.subtract(const Duration(hours: 24));
    }

    // Combine inboxes from all date controllers
    final allInboxes = <InboxEntity>[];
    for (final controller in _dateControllers) {
      final controllerInboxes = ref.read(controller).value?.inboxes ?? [];
      allInboxes.addAll(controllerInboxes);
    }

    // Filter by last app open/close date (filterStartTime 이후로 필터링)
    final filteredInboxes = allInboxes.where((e) {
      final inboxDate = e.inboxDatetime;
      return inboxDate.isAfter(filterStartTime.subtract(const Duration(seconds: 1))) && !inboxDate.isAfter(now);
    }).toList();

    // Create InboxFetchListEntity with filtered inboxes
    final firstController = _dateControllers.isNotEmpty ? _dateControllers.first : null;
    inboxes = InboxFetchListEntity(
      inboxes: filteredInboxes,
      separator: firstController != null ? ref.read(firstController).value?.separator ?? [] : [],
      sequence: firstController != null ? ref.read(firstController).value?.sequence ?? 0 : 0,
    );

    updateData();
  }

  void _updateSuggestionsFromControllers() {
    // Combine suggestions from all date controllers
    final allSuggestions = <InboxSuggestionEntity>[];
    for (final controller in _suggestionControllers) {
      final controllerSuggestions = ref.read(controller).value?.suggestions ?? [];
      allSuggestions.addAll(controllerSuggestions);
    }

    // Create InboxSuggestionFetchListEntity with combined suggestions
    final firstController = _suggestionControllers.isNotEmpty ? _suggestionControllers.first : null;
    suggestions = InboxSuggestionFetchListEntity(suggestions: allSuggestions, sequence: firstController != null ? ref.read(firstController).value?.sequence ?? 0 : 0);

    updateData();
  }

  List<InboxEntity> get availableInboxes {
    final now = DateTime.now();

    // Calculate filter start time: lastDate 이후로 필터링
    // 24시간 미만이면 24시간치 데이터 제공
    DateTime filterStartTime;
    if (_lastAppOpenCloseDate != null) {
      final hoursDiff = now.difference(_lastAppOpenCloseDate!).inHours;

      // 24시간 미만이면 24시간치 데이터 제공
      if (hoursDiff < 24) {
        filterStartTime = now.subtract(const Duration(hours: 24));
      } else {
        // lastDate 이후로 필터링
        filterStartTime = _lastAppOpenCloseDate!;
      }
    } else {
      // 저장된 날짜가 없으면 24시간 전부터 시작
      filterStartTime = now.subtract(const Duration(hours: 24));
    }

    final allInboxes = inboxes?.inboxes ?? [];
    // Filter by last app open/close date (filterStartTime 이후로 필터링)
    return allInboxes.where((e) {
      final inboxDate = e.inboxDatetime;
      return inboxDate.isAfter(filterStartTime.subtract(const Duration(seconds: 1))) && !inboxDate.isAfter(now);
    }).toList();
  }

  ValueNotifier<bool> get isSearchDoneListenable {
    final firstController = _dateControllers.isNotEmpty ? _dateControllers.first : null;
    if (firstController == null) return ValueNotifier(false);
    return ref.read(firstController.notifier).isSearchDoneListenable;
  }

  bool isAbleToLoadMore() {
    for (final controller in _dateControllers) {
      if (ref.read(controller.notifier).isAbleToLoadMore()) {
        return true;
      }
    }
    return false;
  }

  void updateData() {
    final now = DateTime.now();

    // Calculate filter start time: lastDate 이후로 필터링
    // 24시간 미만이면 24시간치 데이터 제공
    DateTime filterStartTime;
    if (_lastAppOpenCloseDate != null) {
      final hoursDiff = now.difference(_lastAppOpenCloseDate!).inHours;

      // 24시간 미만이면 24시간치 데이터 제공
      if (hoursDiff < 24) {
        filterStartTime = now.subtract(const Duration(hours: 24));
      } else {
        // lastDate 이후로 필터링
        filterStartTime = _lastAppOpenCloseDate!;
      }
    } else {
      // 저장된 날짜가 없으면 24시간 전부터 시작
      filterStartTime = now.subtract(const Duration(hours: 24));
    }

    // Filter inboxes by last app open/close date (filterStartTime 이후로 필터링)
    final filteredInboxes = (inboxes?.inboxes ?? []).where((e) {
      final inboxDate = e.inboxDatetime;
      return inboxDate.isAfter(filterStartTime.subtract(const Duration(seconds: 1))) && !inboxDate.isAfter(now);
    }).toList();

    final processedInboxes = filteredInboxes.map((e) {
      final suggestion = suggestions?.suggestions.firstWhereOrNull((s) => s.id == e.id || (s.id.contains(',') && s.id.split(',').contains(e.id)));
      final linkedTask = linkedTasks?.linkedTasks.firstWhereOrNull((s) => s.inboxId == e.id);
      final config = configs?.configs.firstWhereOrNull((s) => s.inboxUniqueId == e.uniqueId);

      // Extract merged inbox IDs from suggestion if it exists
      // AI suggestion controller stores merged IDs as comma-separated string in suggestion.id
      List<String>? mergedInboxIds;
      if (suggestion != null && suggestion.id.contains(',')) {
        final allMergedIds = suggestion.id.split(',');
        // Remove the current inbox's id from the list
        mergedInboxIds = allMergedIds.where((id) => id != e.id).toList();
        if (mergedInboxIds.isEmpty) mergedInboxIds = null;
      }

      return e.copyWith(suggestion: suggestion, linkedTask: linkedTask, config: config, mergedInboxIds: mergedInboxIds);
    }).toList();

    // Group inboxes by their merged suggestion ID to show only one per merged group
    final Map<String, InboxEntity> mergedInboxesMap = {};
    final Set<String> processedIds = {};

    for (final inbox in processedInboxes) {
      // Skip if this inbox was already processed as part of a merged group
      if (processedIds.contains(inbox.id)) continue;

      final suggestion = inbox.suggestion;
      if (suggestion != null && suggestion.id.contains(',')) {
        // This is a merged suggestion - show only the first inbox from the merged group
        final mergedIds = suggestion.id.split(',');
        final primaryId = mergedIds.first;

        // Find the primary inbox (the one with the primary ID)
        final primaryInbox = processedInboxes.firstWhereOrNull((i) => i.id == primaryId) ?? inbox;

        // Mark all merged inboxes as processed
        processedIds.addAll(mergedIds);

        // Store the primary inbox with merged IDs
        mergedInboxesMap[primaryId] = primaryInbox.copyWith(mergedInboxIds: mergedIds.where((id) => id != primaryId).toList());
      } else {
        // Not merged, show as is
        processedIds.add(inbox.id);
        mergedInboxesMap[inbox.id] = inbox;
      }
    }

    final finalInboxes = mergedInboxesMap.values.toList();

    final result = InboxFetchListEntity(
      inboxes: finalInboxes,
      separator: inboxes?.separator ?? [],
      sequence: inboxes?.sequence ?? 0,
      channels: channels,
      members: members,
      groups: groups,
    );
    updateState(result);
  }

  Timer? timer;
  void updateState(InboxFetchListEntity data) {
    if (timer == null) state = data;
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: kControllerDebouncMillisecond), () {
      state = data;
      timer = null;
    });
  }

  void clear() {
    for (final controller in _dateControllers) {
      ref.read(controller.notifier).clear();
    }
  }

  Future<void> refresh() async {
    Completer<void> completer = Completer<void>();
    Utils.ref.read(loadingStatusProvider.notifier).update(InboxAgentListController.stringKey, LoadingState.loading);

    // Refresh all controllers and load all pages automatically
    final refreshFutures = _dateControllers.map((controller) => ref.read(controller.notifier).refresh()).toList();

    Future.wait(refreshFutures)
        .then((_) {
          // Load all pages for all controllers
          final loadMoreFutures = _dateControllers.map((controller) => _loadMoreUntilComplete(ref.read(controller.notifier))).toList();
          return Future.wait(loadMoreFutures);
        })
        .then((_) {
          if (Utils.ref.read(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.agent))) {
            Utils.ref.read(loadingStatusProvider.notifier).update(InboxAgentListController.stringKey, LoadingState.success);
          } else {
            Utils.ref.read(loadingStatusProvider.notifier).update(InboxAgentListController.stringKey, LoadingState.idle);
          }
          completer.complete();
        })
        .catchError((e) {
          if (Utils.ref.read(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.agent))) {
            Utils.ref.read(loadingStatusProvider.notifier).update(InboxAgentListController.stringKey, LoadingState.error);
          } else {
            Utils.ref.read(loadingStatusProvider.notifier).update(InboxAgentListController.stringKey, LoadingState.idle);
          }

          completer.complete();
        });

    return completer.future;
  }

  Future<void> _loadMoreUntilComplete(InboxListControllerInternal notifier) async {
    int iterations = 0;
    const maxIterations = 100; // Safety limit

    while (iterations < maxIterations) {
      iterations++;

      if (!notifier.isAbleToLoadMore()) break;

      await notifier.loadMore();

      // Small delay to avoid overwhelming the API
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void upsertMailInboxLocally(List<MailEntity> mails) async {
    for (final controller in _dateControllers) {
      ref.read(controller.notifier).upsertMailInboxLocally(mails);
    }
    // Update UI after local inbox update
    _updateInboxesFromControllers();
    updateData();
  }

  void removeMailInboxLocally(String mailId) {
    for (final controller in _dateControllers) {
      ref.read(controller.notifier).removeMailInboxLocally(mailId);
    }
  }

  void readMailLocally(List<String> threadIds) {
    for (final controller in _dateControllers) {
      ref.read(controller.notifier).readMailLocally(threadIds);
    }
  }

  void removeMailLocally(List<String> threadIds) {
    for (final controller in _dateControllers) {
      ref.read(controller.notifier).removeMailLocally(threadIds);
    }
  }

  void unreadMailLocally(List<String> threadIds) {
    for (final controller in _dateControllers) {
      ref.read(controller.notifier).unreadMailLocally(threadIds);
    }
  }

  void pinMailLocally(List<String> threadIds) {
    for (final controller in _dateControllers) {
      ref.read(controller.notifier).pinMailLocally(threadIds);
    }
  }

  void unpinMailLocally(List<String> threadIds) {
    for (final controller in _dateControllers) {
      ref.read(controller.notifier).unpinMailLocally(threadIds);
    }
  }

  void upsertMessageInboxLocally(MessageEntity m, MessageChannelEntity channel) async {
    for (final controller in _dateControllers) {
      ref.read(controller.notifier).upsertMessageInboxLocally(m, channel);
    }
    // Update UI after local inbox update
    _updateInboxesFromControllers();
    updateData();
  }

  void removeMessageInboxLocally(String messageId) {
    for (final controller in _dateControllers) {
      ref.read(controller.notifier).removeMessageInboxLocally(messageId);
    }
  }

  void updateIsSearchDone(bool isSearchDone) {
    for (final controller in _dateControllers) {
      ref.read(controller.notifier).updateIsSearchDone(isSearchDone);
    }
  }
}
