import 'dart:async';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/application/chat_group_list_controller.dart';
import 'package:Visir/features/chat/application/chat_member_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_member_entity.dart';
import 'package:Visir/features/chat/domain/entities/state/chat_fetch_members_result_entity.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/application/inbox_config_controller.dart';
import 'package:Visir/features/inbox/application/inbox_linked_task_controller.dart';
import 'package:Visir/features/inbox/application/inbox_source_chats_controller.dart';
import 'package:Visir/features/inbox/application/inbox_source_mails_controller.dart';
import 'package:Visir/features/inbox/application/inbox_suggestion_controller.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_config_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/utils/mock_data_helper.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_fetch_list_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_linked_task_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_suggestion_entity.dart';
import 'package:Visir/features/inbox/providers.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inbox_list_controller.g.dart';

@riverpod
class InboxListController extends _$InboxListController {
  late InboxListControllerInternalProvider _controller;

  static String stringKey = '${TabType.home.name}:inboxes';

  InboxFetchListEntity? inboxes;
  InboxConfigFetchListEntity? configs;
  InboxSuggestionFetchListEntity? suggestions;
  InboxLinkedTaskFetchListEntity? linkedTasks;
  List<MessageChannelEntity> channels = [];
  List<MessageMemberEntity> members = [];
  List<MessageGroupEntity> groups = [];

  @override
  InboxFetchListEntity? build() {
    final isSearch = ref.watch(inboxListIsSearchProvider);
    final date = ref.watch(inboxListDateProvider);
    final isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));

    _controller = inboxListControllerInternalProvider(isSignedIn: isSignedIn, isSearch: isSearch, year: date.year, month: date.month, day: date.day);

    ref.watch(_controller.notifier);
    ref.listen(_controller, (prev, next) {
      inboxes = next.value;
      updateData();
    });
    ref.listen(inboxConfigListControllerProvider(isSearch: isSearch, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn), (prev, next) {
      configs = next;
      updateData();
    });
    ref.listen(inboxSuggestionControllerProvider(isSearch: isSearch, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn), (prev, next) {
      suggestions = next;
      updateData();
    });
    ref.listen(inboxLinkedTaskControllerProvider(isSearch: isSearch, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn), (prev, next) {
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

    inboxes = ref.read(_controller).value;
    suggestions = ref.read(inboxSuggestionControllerProvider(isSearch: isSearch, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn));
    configs = ref.read(inboxConfigListControllerProvider(isSearch: isSearch, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn));
    linkedTasks = ref.read(inboxLinkedTaskControllerProvider(isSearch: isSearch, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn));
    channels = ref.read(chatChannelListControllerProvider).values.expand((e) => e.channels).toList();
    members = ref.read(chatChannelListControllerProvider.select((v) => v.values.expand((e) => e.members).toList()));
    groups = ref.read(chatChannelListControllerProvider.select((v) => v.values.expand((e) => e.groups).toList()));

    SchedulerBinding.instance.addPostFrameCallback((_) {
      updateData();
      if (!isSearch) refresh();
    });

    return null;
  }

  List<InboxEntity> get availableInboxes => ref.read(_controller.notifier).availableInboxes;
  ValueNotifier<bool> get isSearchDoneListenable => ref.read(_controller.notifier).isSearchDoneListenable;

  bool isAbleToLoadMore() {
    return ref.read(_controller.notifier).isAbleToLoadMore();
  }

  void updateData() {
    final processedInboxes =
        inboxes?.inboxes.map((e) {
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
        }).toList() ??
        [];

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
    return ref.read(_controller.notifier).clear();
  }

  Future<void> search({required String query}) async {
    Completer<void> completer = Completer<void>();
    Utils.ref.read(loadingStatusProvider.notifier).update(InboxListController.stringKey, LoadingState.loading);
    ref
        .read(_controller.notifier)
        .search(query: query)
        .then((e) {
          if (Utils.ref.read(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.manual))) {
            Utils.ref.read(loadingStatusProvider.notifier).update(InboxListController.stringKey, LoadingState.success);
          } else {
            Utils.ref.read(loadingStatusProvider.notifier).update(InboxListController.stringKey, LoadingState.idle);
          }
          completer.complete();
        })
        .catchError((e) {
          if (Utils.ref.read(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.manual))) {
            Utils.ref.read(loadingStatusProvider.notifier).update(InboxListController.stringKey, LoadingState.error);
          } else {
            Utils.ref.read(loadingStatusProvider.notifier).update(InboxListController.stringKey, LoadingState.idle);
          }
          completer.complete();
        });
    return completer.future;
  }

  Future<void> refresh() async {
    Completer<void> completer = Completer<void>();
    Utils.ref.read(loadingStatusProvider.notifier).update(InboxListController.stringKey, LoadingState.loading);
    ref
        .read(_controller.notifier)
        .refresh()
        .then((e) {
          if (Utils.ref.read(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.manual))) {
            Utils.ref.read(loadingStatusProvider.notifier).update(InboxListController.stringKey, LoadingState.success);
          } else {
            Utils.ref.read(loadingStatusProvider.notifier).update(InboxListController.stringKey, LoadingState.idle);
          }
          completer.complete();
        })
        .catchError((e) {
          if (Utils.ref.read(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.manual))) {
            Utils.ref.read(loadingStatusProvider.notifier).update(InboxListController.stringKey, LoadingState.error);
          } else {
            Utils.ref.read(loadingStatusProvider.notifier).update(InboxListController.stringKey, LoadingState.idle);
          }
          completer.complete();
        });
    return completer.future;
  }

  Future<void> loadMore() async {
    Completer<void> completer = Completer<void>();
    Utils.ref.read(loadingStatusProvider.notifier).update(InboxListController.stringKey, LoadingState.loading);
    ref
        .read(_controller.notifier)
        .loadMore()
        .then((e) {
          if (Utils.ref.read(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.manual))) {
            Utils.ref.read(loadingStatusProvider.notifier).update(InboxListController.stringKey, LoadingState.success);
          } else {
            Utils.ref.read(loadingStatusProvider.notifier).update(InboxListController.stringKey, LoadingState.success);
          }
          completer.complete();
        })
        .catchError((e) {
          if (Utils.ref.read(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.manual))) {
            Utils.ref.read(loadingStatusProvider.notifier).update(InboxListController.stringKey, LoadingState.error);
          } else {
            Utils.ref.read(loadingStatusProvider.notifier).update(InboxListController.stringKey, LoadingState.idle);
          }
          completer.complete();
        });
    return completer.future;
  }

  Future<void> loadRecent() async {
    Completer<void> completer = Completer<void>();
    Utils.ref.read(loadingStatusProvider.notifier).update(InboxListController.stringKey, LoadingState.loading);
    ref
        .read(_controller.notifier)
        .loadRecent()
        .then((e) {
          if (Utils.ref.read(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.manual))) {
            Utils.ref.read(loadingStatusProvider.notifier).update(InboxListController.stringKey, LoadingState.success);
          } else {
            Utils.ref.read(loadingStatusProvider.notifier).update(InboxListController.stringKey, LoadingState.idle);
          }
          completer.complete();
        })
        .catchError((e) {
          if (Utils.ref.read(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.manual))) {
            Utils.ref.read(loadingStatusProvider.notifier).update(InboxListController.stringKey, LoadingState.error);
          } else {
            Utils.ref.read(loadingStatusProvider.notifier).update(InboxListController.stringKey, LoadingState.idle);
          }
          completer.complete();
        });
    return completer.future;
  }

  void upsertMailInboxLocally(List<MailEntity> mails) async {
    return ref.read(_controller.notifier).upsertMailInboxLocally(mails);
  }

  void removeMailInboxLocally(String mailId) {
    return ref.read(_controller.notifier).removeMailInboxLocally(mailId);
  }

  void readMailLocally(List<String> threadIds) {
    return ref.read(_controller.notifier).readMailLocally(threadIds);
  }

  void removeMailLocally(List<String> threadIds) {
    return ref.read(_controller.notifier).removeMailLocally(threadIds);
  }

  void unreadMailLocally(List<String> threadIds) {
    return ref.read(_controller.notifier).unreadMailLocally(threadIds);
  }

  void pinMailLocally(List<String> threadIds) {
    return ref.read(_controller.notifier).pinMailLocally(threadIds);
  }

  void unpinMailLocally(List<String> threadIds) {
    return ref.read(_controller.notifier).unpinMailLocally(threadIds);
  }

  void upsertMessageInboxLocally(MessageEntity m, MessageChannelEntity channel) async {
    return ref.read(_controller.notifier).upsertMessageInboxLocally(m, channel);
  }

  void removeMessageInboxLocally(String messageId) {
    return ref.read(_controller.notifier).removeMessageInboxLocally(messageId);
  }

  void updateIsSearchDone(bool isSearchDone) {
    ref.read(_controller.notifier).updateIsSearchDone(isSearchDone);
  }
}

@riverpod
class InboxListControllerInternal extends _$InboxListControllerInternal {
  ValueNotifier<bool> isSearchDoneListenable = ValueNotifier(false);

  bool get isSearchDone => isSearchDoneListenable.value;

  List<DateTime> _separator = [];

  List<InboxEntity> get inboxes => [...(state.value?.inboxes ?? [])];

  List<DateTime> get separators => [...(state.value?.separator ?? [])];

  List<InboxSuggestionEntity> suggestions = [];

  String? query;

  List<InboxEntity> _availableInboxes = [];
  List<InboxEntity> get availableInboxes => _availableInboxes;

  bool _showDeletedFilter = false;
  bool get showDeletedFilter => _showDeletedFilter;

  List<MessageEntity> _fetchedMessages = [];
  List<MailEntity> _fetchedMails = [];
  List<dynamic> _fetchedConfigs = [];

  List<MessageMemberEntity> _members = [];
  List<MessageGroupEntity> _groups = [];
  Map<String, List<MessageChannelEntity>> _mockChannels = {};
  bool _isRefresh = false;

  DateTime get date => DateTime(year, month, day);

  final Map<String, InboxSourceMailsControllerProvider> _sourceMailControllers = {};
  final Map<String, InboxSourceChatsControllerProvider> _sourceChatControllers = {};

  @override
  Future<InboxFetchListEntity?> build({required bool isSearch, required int year, required int month, required int day, required bool isSignedIn}) async {
    final userId = ref.watch(authControllerProvider.select((v) => v.requireValue.id));

    ref.watch(
      localPrefControllerProvider.select((v) {
        final uniqueIds = v.value?.mailOAuths?.map((e) => e.uniqueId).toList() ?? [];
        uniqueIds.sort();
        return uniqueIds.join(',');
      }),
    );

    ref.watch(
      localPrefControllerProvider.select((v) {
        final uniqueIds = v.value?.messengerOAuths?.map((e) => e.uniqueId).toList() ?? [];
        uniqueIds.sort();
        return uniqueIds.join(',');
      }),
    );

    final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.messengerOAuths ?? []));

    ref.listen(
      chatChannelListControllerProvider.select((v) {
        final channelIds = v.values.expand((e) => e.channels).toList().map((e) => e.id).toList();
        channelIds.sort((a, b) => b.compareTo(a));
        return channelIds.join(',');
      }),
      (prev, next) {
        updateState(userId, (state.value?.sequence ?? 0) + 1);
      },
    );

    ref.listen(chatGroupListControllerProvider(tabType: TabType.home), (prev, next) {
      _groups = next.groups;
      updateState(userId, (state.value?.sequence ?? 0) + 1);
    });

    if (ref.watch(shouldUseMockDataProvider)) {
      // Mock 데이터 사용 시 날짜 필터링 제거 (모든 데이터 포함)
      // constants의 mailDateOffset과 chatDateOffset 사용
      _fetchedMails = (await MockDataHelper.getMockMails(date: null)).values.expand((e) => e.messages).toList();
      _mockChannels = await MockDataHelper.getMockChannels();
      final chatResult = await MockDataHelper.getMockChats(date: null, getMockChannels: MockDataHelper.getMockChannels);
      _fetchedMessages = chatResult.messages;
      _members = (await getMockMembers()).members;
      _groups = []; // Mock groups는 빈 리스트로 시작

      // 데이터가 모두 로드된 후에 updateState 호출 (_isRefresh = true로 설정하여 기존 데이터 초기화)
      _isRefresh = true;
      final resultInboxes = _updateFetchedData(userId, (state.value?.sequence ?? 0) + 1);
      _isRefresh = false;

      // _updateState가 이미 state를 업데이트했지만, build 반환값도 명시적으로 설정
      // state가 아직 업데이트되지 않았을 수 있으므로, 직접 생성한 값을 반환
      final sequence = (state.value?.sequence ?? 0) + 1;
      final returnValue = InboxFetchListEntity(inboxes: resultInboxes, separator: _separator, sequence: sequence);
      // state도 명시적으로 업데이트 (무조건 업데이트)
      state = AsyncData(returnValue);
      return returnValue;
    }

    final mailOAuths = ref.read(localPrefControllerProvider.select((v) => v.value?.mailOAuths ?? []));
    final chatOAuths = ref.read(localPrefControllerProvider.select((v) => v.value?.messengerOAuths ?? []));

    // 기존에 등록되지 않은 OAuth만 추가
    final existingMailOAuthIds = _sourceMailControllers.keys.toSet();
    final newMailOAuthIds = mailOAuths.map((e) => e.uniqueId).toSet();

    // 제거된 OAuth의 controller 정리
    existingMailOAuthIds.difference(newMailOAuthIds).forEach((removedId) {
      _sourceMailControllers.remove(removedId);
    });

    mailOAuths.forEach((oauth) {
      // 이미 존재하는 controller는 재사용
      if (!_sourceMailControllers.containsKey(oauth.uniqueId)) {
        _sourceMailControllers[oauth.uniqueId] = inboxSourceMailsControllerProvider(
          isSearch: isSearch,
          year: year,
          month: month,
          day: day,
          isSignedIn: isSignedIn,
          oauthUniqueId: oauth.uniqueId,
        );

        ref.watch(_sourceMailControllers[oauth.uniqueId]!.notifier);
        ref.listen(_sourceMailControllers[oauth.uniqueId]!, (prev, next) {
          _fetchedMails = [...(next.value?.mails.values.expand((e) => e.messages).toList() ?? <MailEntity>[]), ..._fetchedMails].unique((e) => e.uniqueId);
          updateState(userId, (state.value?.sequence ?? 0) + 1);
        });
      }
    });

    // 기존에 등록되지 않은 OAuth만 추가
    final existingChatOAuthIds = _sourceChatControllers.keys.toSet();
    final newChatOAuthIds = chatOAuths.map((e) => e.uniqueId).toSet();

    // 제거된 OAuth의 controller 정리
    existingChatOAuthIds.difference(newChatOAuthIds).forEach((removedId) {
      _sourceChatControllers.remove(removedId);
    });

    chatOAuths.forEach((oauth) {
      // 이미 존재하는 controller는 재사용
      if (!_sourceChatControllers.containsKey(oauth.uniqueId)) {
        _sourceChatControllers[oauth.uniqueId] = inboxSourceChatsControllerProvider(
          isSearch: isSearch,
          year: year,
          month: month,
          day: day,
          isSignedIn: isSignedIn,
          oauthUniqueId: oauth.uniqueId,
        );
        ref.watch(_sourceChatControllers[oauth.uniqueId]!.notifier);
        ref.listen(_sourceChatControllers[oauth.uniqueId]!, (prev, next) {
          _fetchedMessages = [...(next.value?.messages ?? <MessageEntity>[]), ..._fetchedMessages].unique((e) => '${e.id}${e.channelId}${e.teamId}');

          Map<String, String> userData = {};

          _fetchedMessages.forEach((m) {
            final data = m.getUserGroupEmojiIds;
            final _userIds = [...(data['userIds'] ?? []), if (m.userId != null) m.userId!];
            final oauthUniqueId = oauths.firstWhereOrNull((e) => e.teamId == m.teamId)?.uniqueId;
            _userIds.forEach((e) {
              if (!_members.any((m) => m.id == e)) userData[e] = oauthUniqueId ?? '';
            });
          });

          userData.values.toSet().forEach((e) {
            final _oauth = oauths.firstWhereOrNull((o) => o.uniqueId == e);
            final _userIds = userData.entries.where((o) => o.value == e).map((e) => e.key).toList().where((e) => !_members.any((m) => m.id == e)).toList();
            if (_oauth != null) {
              _userIds.forEach((userId) {
                final memberProvider = chatMemberListControllerInternalProvider(isSignedIn: isSignedIn, userId: userId, oauthUniqueId: _oauth.uniqueId);
                ref.listen(memberProvider, (prev, next) {
                  if (next == null) return;
                  _members.removeWhere((m) => m.id == next.id);
                  _members.add(next);
                  updateState(userId, (state.value?.sequence ?? 0) + 1);
                });
              });

              if (_userIds.isNotEmpty) {
                ref.read(chatRepositoryProvider).fetchMembers(type: _oauth.type.chatChannelType!, oauth: _oauth, userIds: _userIds).then((result) {
                  return result.fold((l) {}, (r) {
                    if (r == null) return;
                    if (!ref.mounted) return;
                    r.forEach((e) {
                      ref.read(chatMemberListControllerInternalProvider(isSignedIn: isSignedIn, userId: e.id, oauthUniqueId: _oauth.uniqueId).notifier).updateState(e);
                    });
                  });
                });
              }
            }
          });
        });
      }
    });

    return state.value;
  }

  void updateIsSearchDone(bool isSearchDone) {
    isSearchDoneListenable.value = isSearchDone;
  }

  void _updateState(InboxFetchListEntity? data, {DateTime? date, String? query, bool? forceUpdate}) {
    final prevInboxes = state.value?.inboxes ?? [];
    final inboxes = data?.inboxes ?? [];

    final finalInboxes = forceUpdate == true
        ? inboxes
        : inboxes.map((e) {
            final prevInbox = prevInboxes.firstWhereOrNull((element) => element.id == e.id);
            if (prevInbox == null) return e;
            if (prevInbox.config?.updatedAt == null) return e;
            if (e.config?.updatedAt == null) return e;
            if (e.config!.updatedAt!.isAfter(prevInbox.config!.updatedAt!)) return e;
            return prevInbox.copyWith(linkedMail: e.linkedMail, linkedMessage: e.linkedMessage);
          }).toList();

    finalInboxes.forEach((e) => e.suggestion = suggestions.firstWhereOrNull((s) => s.id == e.id));

    _availableInboxes.clear();
    _availableInboxes.addAll(_getAvailableInboxes(finalInboxes, query?.isNotEmpty == true));
    _showDeletedFilter = _availableInboxes.where((e) => e.config?.isDeleted ?? false).isNotEmpty == true;

    final finalData = InboxFetchListEntity(inboxes: finalInboxes, separator: data?.separator ?? [], sequence: data?.sequence ?? 0);
    state = AsyncData(finalData);
  }

  List<InboxEntity> _getAvailableInboxes(List<InboxEntity> tasks, bool isSearch) {
    // Mock 데이터 사용 시 모든 데이터 포함
    if (ref.read(shouldUseMockDataProvider)) return tasks..sort((a, b) => b.inboxDatetime.compareTo(a.inboxDatetime));

    final groupedInbox = groupBy(tasks, (e) => isSearch ? e.inboxSearchId : e.inboxGroupId);
    final mails = tasks.where((e) => e.linkedMail != null).toList();
    final messages = tasks.where((e) => e.linkedMessage != null).toList();
    final groupedMails = groupBy(mails, (e) => e.linkedMail!.hostMail);
    final groupedMessages = groupBy(messages, (e) => '${e.linkedMessage!.isDm == true ? 'dm' : 'cm'}${e.linkedMessage!.teamId}');

    final list = groupedInbox.values.map((e) => e..sort((a, b) => b.inboxDatetime.compareTo(a.inboxDatetime))).toList()
      ..sort((a, b) => a.first.inboxDatetime.compareTo(b.first.inboxDatetime));
    DateTime? lastUpdatedAt = null;

    if (isSearch) {
      list.forEach((providerList) {
        providerList.sort((a, b) => b.inboxDatetime.compareTo(a.inboxDatetime));
        if (providerList.isNotEmpty && providerList.last.inboxPageToken != null && (lastUpdatedAt == null || providerList.last.inboxDatetime.isAfter(lastUpdatedAt!))) {
          lastUpdatedAt = providerList.last.inboxDatetime;
        }
      });
    } else {
      groupedMails.keys.forEach((key) {
        final list = groupedMails[key]!;
        if (list.firstWhereOrNull((element) => element.inboxPageToken == null) == null) {
          final mails = groupedMails[key]!.where((e) {
            return e.inboxPageToken != null;
          }).toList();
          mails.sort((a, b) => a.inboxDatetime.compareTo(b.inboxDatetime));
          if (mails.firstOrNull?.inboxPageToken != null) {
            if (lastUpdatedAt == null || mails.first.inboxDatetime.isAfter(lastUpdatedAt!)) {
              lastUpdatedAt = mails.first.inboxDatetime;
            }
          }
        }
      });

      groupedMessages.keys.forEach((key) {
        final list = groupedMessages[key]!;
        if (list.firstWhereOrNull((element) => element.inboxPageToken == null) == null) {
          final messages = list.where((e) {
            return e.inboxPageToken != null;
          }).toList();
          messages.sort((a, b) => a.inboxDatetime.compareTo(b.inboxDatetime));
          if (messages.firstOrNull?.inboxPageToken != null) {
            if (lastUpdatedAt == null || messages.first.inboxDatetime.isAfter(lastUpdatedAt!)) {
              lastUpdatedAt = messages.first.inboxDatetime;
            }
          }
        }
      });
    }

    if (lastUpdatedAt == null) return tasks..sort((a, b) => b.inboxDatetime.compareTo(a.inboxDatetime));
    final result = tasks.where((t) => !t.inboxDatetime.isBefore(lastUpdatedAt!)).toList()..sort((a, b) => b.inboxDatetime.compareTo(a.inboxDatetime));
    return result;
  }

  bool isAbleToLoadMore() {
    List<InboxEntity> tasks = _isRefresh == true ? [] : state.value?.inboxes ?? [];

    final groupedInbox = groupBy(tasks, (e) => isSearch ? e.inboxSearchId : e.inboxGroupId);
    final mails = tasks.where((e) => e.linkedMail != null).toList();
    final messages = tasks.where((e) => e.linkedMessage != null).toList();
    final groupedMails = groupBy(mails, (e) => e.linkedMail!.hostMail);
    final groupedMessages = groupBy(messages, (e) => '${e.linkedMessage!.isDm == true ? 'dm' : 'cm'}${e.linkedMessage!.teamId}');

    final list = groupedInbox.values.map((e) => e..sort((a, b) => b.inboxDatetime.compareTo(a.inboxDatetime))).toList()
      ..sort((a, b) => a.first.inboxDatetime.compareTo(b.first.inboxDatetime));

    if (isSearch) {
      return list.map((e) => e.lastOrNull?.inboxPageToken).where((e) => e != null).isNotEmpty;
    } else {
      final mailPageTokens = groupedMails.map((key, value) {
        if (value.where((e) => e.inboxPageToken == null).isNotEmpty) return MapEntry(key, null);
        final list = [...value];
        list.sort((a, b) => a.inboxDatetime.compareTo(b.inboxDatetime));
        return MapEntry(key, list.last.inboxPageToken);
      });
      final messagePageTokens = groupedMessages.map((key, value) {
        if (value.where((e) => e.inboxPageToken == null).isNotEmpty) return MapEntry(key, null);
        final tokenList = [...value]..sort((a, b) => (a.inboxPageToken ?? '0').compareTo((b.inboxPageToken ?? '0')));
        return MapEntry(key, tokenList.last.inboxPageToken);
      });

      return [...(mailPageTokens.values), ...(messagePageTokens.values)].where((e) => e != null).isNotEmpty;
    }
  }

  void clear() {
    _updateState(null);
  }

  Future<void> search({required String query}) async {
    Completer<void> completer = Completer<void>();
    this.query = query;
    int resultCount = 0;
    final totalControllers = _sourceMailControllers.length + _sourceChatControllers.length;

    // OAuth가 없으면 즉시 완료
    if (totalControllers == 0) {
      completer.complete();
      return completer.future;
    }

    _sourceMailControllers.forEach((key, value) {
      ref
          .read(value.notifier)
          .load(refresh: true, query: query)
          .then((e) {
            resultCount++;
            if (resultCount != totalControllers) return;
            completer.complete();
          })
          .catchError((e) {
            resultCount++;
            if (resultCount != totalControllers) return;
            completer.complete();
          });
    });
    _sourceChatControllers.forEach((key, value) {
      ref
          .read(value.notifier)
          .load(refresh: true, query: query)
          .then((e) {
            resultCount++;
            if (resultCount != totalControllers) return;
            completer.complete();
          })
          .catchError((e) {
            resultCount++;
            if (resultCount != totalControllers) return;
            completer.complete();
          });
    });
    return completer.future;
  }

  Future<void> refresh() async {
    if (isSearch) return;
    Completer<void> completer = Completer<void>();
    this.query = null;
    int resultCount = 0;
    final totalControllers = _sourceMailControllers.length + _sourceChatControllers.length;

    // OAuth가 없으면 즉시 완료
    if (totalControllers == 0) {
      completer.complete();
      return completer.future;
    }

    _sourceMailControllers.forEach((key, value) {
      ref
          .read(value.notifier)
          .load(refresh: true)
          .then((e) {
            resultCount++;
            if (resultCount != totalControllers) return;
            completer.complete();
          })
          .catchError((e) {
            resultCount++;
            if (resultCount != totalControllers) return;
            completer.complete();
          });
    });
    _sourceChatControllers.forEach((key, value) {
      ref
          .read(value.notifier)
          .load(refresh: true)
          .then((e) {
            resultCount++;
            if (resultCount != totalControllers) return;
            completer.complete();
          })
          .catchError((e) {
            resultCount++;
            if (resultCount != totalControllers) return;
            completer.complete();
          });
    });
    return completer.future;
  }

  Future<void> loadMore() async {
    Completer<void> completer = Completer<void>();
    int resultCount = 0;
    final totalControllers = _sourceMailControllers.length + _sourceChatControllers.length;

    // OAuth가 없으면 즉시 완료
    if (totalControllers == 0) {
      completer.complete();
      return completer.future;
    }

    _sourceMailControllers.forEach((key, value) {
      ref
          .read(value.notifier)
          .load(query: query)
          .then((e) {
            resultCount++;
            if (resultCount != totalControllers) return;
            completer.complete();
          })
          .catchError((e) {
            resultCount++;
            if (resultCount != totalControllers) return;
            completer.complete();
          });
    });
    _sourceChatControllers.forEach((key, value) {
      ref
          .read(value.notifier)
          .load(query: query)
          .then((e) {
            resultCount++;
            if (resultCount != totalControllers) return;
            completer.complete();
          })
          .catchError((e) {
            resultCount++;
            if (resultCount != totalControllers) return;
            completer.complete();
          });
    });
    return completer.future;
  }

  Timer? timer;
  void updateState(String userId, int sequence) {
    if (timer == null) _updateFetchedData(userId, sequence);
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: kControllerDebouncMillisecond), () {
      _updateFetchedData(userId, sequence);
      timer = null;
    });
  }

  List<InboxEntity> _updateFetchedData(String userId, int sequence) {
    final mailInboxes = _fetchedMails.map((e) {
      final config = _fetchedConfigs.where((c) => c.id == InboxEntity.getInboxIdFromMail(e)).firstOrNull;
      return InboxEntity.fromMail(e, config);
    }).toList();

    final chatInboxes = _fetchedMessages
        .map((m) {
          final _channels = ref.read(shouldUseMockDataProvider)
              ? (_mockChannels[m.teamId!] ?? [])
              : ref.read(chatChannelListControllerProvider.select((v) => v[m.teamId!]?.channels ?? []));
          final channel = _channels.where((e) => e.id == m.channelId).firstOrNull;

          if (channel == null) {
            return null;
          }
          final config = _fetchedConfigs.where((c) => c.id == InboxEntity.getInboxIdFromChat(m)).firstOrNull;
          final member = _members.where((e) => e.id == m.userId).firstOrNull;
          if (member == null) {
            return null;
          }
          if (m.teamId == null) return null;
          if (m.channelId == null) return null;
          if (m.userId == null) return null;

          final inbox = InboxEntity.fromChat(m, config, channel, member, _channels, _members, _groups);
          return inbox;
        })
        .whereType<InboxEntity>()
        .toList();

    final fetchedTasks = [...mailInboxes, ...chatInboxes];

    List<InboxEntity> newInboxes;
    if (_isRefresh == true) {
      newInboxes = fetchedTasks.unique((e) => e.inboxId)
        ..sort((a, b) {
          return b.inboxDatetime.compareTo(a.inboxDatetime);
        });
    } else {
      final prevState = state.value?.inboxes ?? [];
      newInboxes = [...fetchedTasks, ...prevState].unique((e) => e.inboxId)
        ..sort((a, b) {
          return b.inboxDatetime.compareTo(a.inboxDatetime);
        });
    }

    final filteredInboxes = _getAvailableInboxes(newInboxes, query?.isNotEmpty == true);
    final separatorDateTime = filteredInboxes.lastOrNull?.inboxDatetime;

    if (separatorDateTime != null && _separator.contains(separatorDateTime) != true) {
      _separator.add(separatorDateTime);
    }

    _updateState(
      InboxFetchListEntity(inboxes: filteredInboxes, separator: _separator, sequence: sequence),
      date: date,
      query: query,
      forceUpdate: _isRefresh == true ? true : null,
    );

    return filteredInboxes;
  }

  Future<void> loadRecent() async {
    Completer<void> completer = Completer<void>();
    this.query = query;
    int resultCount = 0;
    final totalControllers = _sourceMailControllers.length + _sourceChatControllers.length;

    // OAuth가 없으면 즉시 완료
    if (totalControllers == 0) {
      completer.complete();
      return completer.future;
    }

    _sourceMailControllers.forEach((key, value) {
      ref
          .read(value.notifier)
          .loadRecent()
          .then((e) {
            resultCount++;
            if (resultCount != totalControllers) return;
            completer.complete();
          })
          .catchError((e) {
            resultCount++;
            if (resultCount != totalControllers) return;
            completer.complete();
          });
    });
    _sourceChatControllers.forEach((key, value) {
      ref
          .read(value.notifier)
          .loadRecent()
          .then((e) {
            resultCount++;
            if (resultCount != totalControllers) return;
            completer.complete();
          })
          .catchError((e) {
            resultCount++;
            if (resultCount != totalControllers) return;
            completer.complete();
          });
    });
    return completer.future;
  }

  void upsertMailInboxLocally(List<MailEntity> mails) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    groupedMails.entries.forEach((e) {
      final hostEmail = e.key;
      final oauth = ref.read(localPrefControllerProvider.select((value) => value.value?.mailOAuths ?? [])).firstWhereOrNull((e) => e.email == hostEmail);
      if (oauth != null && _sourceMailControllers[oauth.uniqueId] != null) {
        ref.read(_sourceMailControllers[oauth.uniqueId]!.notifier).upsertMailInboxLocally(e.value);
      }
    });
  }

  void removeMailInboxLocally(String mailId) {
    _sourceMailControllers.forEach((key, value) {
      ref.read(value.notifier).removeMailInboxLocally(mailId);
    });
  }

  void readMailLocally(List<String> threadIds) {
    _sourceMailControllers.forEach((key, value) {
      ref.read(value.notifier).readMailLocally(threadIds);
    });
  }

  void removeMailLocally(List<String> threadIds) {
    _sourceMailControllers.forEach((key, value) {
      ref.read(value.notifier).removeMailLocally(threadIds);
    });
  }

  void unreadMailLocally(List<String> threadIds) {
    _sourceMailControllers.forEach((key, value) {
      ref.read(value.notifier).unreadMailLocally(threadIds);
    });
  }

  void pinMailLocally(List<String> threadIds) {
    _sourceMailControllers.forEach((key, value) {
      ref.read(value.notifier).pinMailLocally(threadIds);
    });
  }

  void unpinMailLocally(List<String> threadIds) {
    _sourceMailControllers.forEach((key, value) {
      ref.read(value.notifier).unpinMailLocally(threadIds);
    });
  }

  void upsertMessageInboxLocally(MessageEntity m, MessageChannelEntity channel) async {
    final oauth = ref.read(localPrefControllerProvider.select((value) => value.value?.messengerOAuths ?? [])).firstWhereOrNull((e) => e.teamId == channel.teamId);
    if (oauth == null) return;
    ref.read(_sourceChatControllers[oauth.uniqueId]!.notifier).upsertMessageInboxLocally(m, channel);
  }

  void removeMessageInboxLocally(String messageId) {
    _sourceChatControllers.forEach((key, value) {
      ref.read(value.notifier).removeMessageInboxLocally(messageId);
    });
  }

  Future<ChatFetchMembersResultEntity> getMockMembers() async {
    final _members = Map.fromEntries(
      fakeMembersJson.entries.map((e) => MapEntry(e.key, e.value.map((e) => MessageMemberEntity.fromSlack(member: SlackMessageMemberEntity.fromJson(e))).toList())),
    );

    return ChatFetchMembersResultEntity(members: _members.values.expand((e) => e).toList(), sequence: 0, loadedMembers: _members.values.expand((e) => e).map((e) => e.id).toList());
  }
}
