import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/application/chat_group_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_entity.dart';
import 'package:Visir/features/chat/domain/entities/state/chat_fetch_result_entity.dart';
import 'package:Visir/features/chat/infrastructure/repositories/message_repository.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inbox_source_chats_controller.g.dart';

@riverpod
class InboxSourceChatsController extends _$InboxSourceChatsController {
  static String stringKey = '${TabType.home.name}:inbox_source_chat';
  late ChatRepository _chatRepository;

  DateTime get date => DateTime(year, month, day);

  OAuthEntity? get oauth => ref.read(localPrefControllerProvider.select((value) => value.value?.messengerOAuths?.firstWhereOrNull((e) => e.uniqueId == oauthUniqueId)));

  ChatInboxFilterType get channelInboxFilterTypes =>
      ref.read(authControllerProvider.select((v) => v.requireValue.messageChannelInboxFilterTypes?['${oauth?.teamId}${oauth?.email}'] ?? ChatInboxFilterType.mentions));

  ChatInboxFilterType get dmInboxFilterTypes =>
      ref.read(authControllerProvider.select((v) => v.requireValue.messageDmInboxFilterTypes?['${oauth?.teamId}${oauth?.email}'] ?? ChatInboxFilterType.all));

  @override
  Future<ChatFetchResultEntity> build({
    required bool isSearch,
    required String oauthUniqueId,
    required int year,
    required int month,
    required int day,
    required bool isSignedIn,
  }) async {
    _chatRepository = ref.watch(chatRepositoryProvider);

    if (ref.watch(shouldUseMockDataProvider)) return getMockChats(date: date, query: '');

    ref.listen(
      chatChannelListControllerProvider.select((v) {
        final channelIds = v.values.expand((e) => e.channels).toList().map((e) => e.id).toList();
        channelIds.sort((a, b) => b.compareTo(a));
        return channelIds.join(',');
      }),
      (prev, next) {
        // _channels = ref.read(chatChannelListControllerProvider).values.expand((e) => e.channels).toList();
        if (isSearch) return;
        load(refresh: true);
      },
    );

    await persist(
      ref.watch(storageProvider.future),
      key: '${stringKey}:${isSignedIn}:${oauthUniqueId}:${this.isSearch ? 'search' : '${year}_${month}_${day}'}',
      encode: (ChatFetchResultEntity state) => jsonEncode(state.toJson()),
      decode: (String encoded) {
        final trimmed = encoded.trim();
        if (trimmed.isEmpty || trimmed == 'null') {
          return ChatFetchResultEntity(messages: [], nextCursor: null, hasMore: false);
        }
        return ChatFetchResultEntity.fromJson(jsonDecode(trimmed) as Map<String, dynamic>);
      },
    ).future;

    return state.value ?? ChatFetchResultEntity(messages: [], nextCursor: null, hasMore: false);
  }

  Future<Map<String, List<MessageChannelEntity>>> getMockChannels() async {
    final channelsMap = Map.fromEntries(
      fakeChannelJson.entries.map(
        (c) => MapEntry(
          c.key,
          c.value.map((e) {
            return MessageChannelEntity.fromSlack(
              channel: SlackMessageChannelEntity.fromJson(e),
              teamId: c.key,
              meId: fakeMeJson[c.key]!['id'] as String,
              customName:
                  e['name'] as String? ??
                  (e['members'] as List<String>?)?.map((i) => (fakeMembersJson[c.key]?.firstWhereOrNull((m) => m['id'] == i)?['real_name'] as String?)).join(', ') ??
                  (fakeMembersJson[c.key]?.firstWhereOrNull((m) => m['id'] == e['user'])?['real_name'] as String?),
            );
          }).toList(),
        ),
      ),
    );

    return channelsMap;
  }

  Future<ChatFetchResultEntity> getMockChats({DateTime? date, String? query}) async {
    await Future.delayed(Duration(seconds: 1));
    final channelMap = await getMockChannels();
    ChatFetchResultEntity resultMessages = ChatFetchResultEntity(messages: [], nextCursor: null, hasMore: false);

    for (final key in channelMap.keys) {
      final channelsIds = channelMap[key]!.map((e) => e.id).toList();

      final results = await Future.wait(channelsIds.map((e) => rootBundle.loadString('assets/mock/chat/${key}/${e}.json')));

      // Mock 데이터 사용 시 날짜 필터링 완화 (최근 7일 이내 데이터 포함)
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      results.forEach((value) {
        final index = results.indexOf(value);
        final channelId = channelsIds[index];
        final messages = (jsonDecode(value)['messages'] as List<dynamic>)
            .map((e) => MessageEntity.fromSlack(message: SlackMessageEntity.fromJson({...e, 'channel': channelId, 'team': key})))
            .toList()
            .where(
              (e) =>
                  // Mock 데이터 사용 시 멘션 필터링 제거 (모든 메시지 포함)
                  (date != null
                  ? (e.createdAt != null &&
                        (DateUtils.isSameDay(e.createdAt!, date) || (e.createdAt!.isAfter(sevenDaysAgo) && e.createdAt!.isBefore(now.add(const Duration(days: 1))))))
                  : query != null
                  ? e.text?.contains(query) == true
                  : e.createdAt != null && e.createdAt!.isAfter(sevenDaysAgo)),
            )
            .toList();
        resultMessages = resultMessages.copyWith(messages: [...resultMessages.messages, ...messages]);
      });
    }

    return resultMessages;
  }

  Future<bool> load({bool? refresh, String? query}) async {
    if (oauth == null) return false;

    final messages = state.value?.messages.toList() ?? <MessageEntity>[];
    final user = ref.read(authControllerProvider.select((v) => v.requireValue));

    final _channels = ref.read(chatChannelListControllerProvider).values.expand((e) => e.channels).toList();

    final groupedMessages = groupBy(
      messages,
      (e) => '${_channels.firstWhereOrNull((c) => c.id == e.channelId && c.teamId == e.teamId)?.isChannel != true ? 'dm' : 'cm'}${e.teamId}',
    );
    final messagePageTokens = groupedMessages.keys.isEmpty
        ? null
        : groupedMessages.map((key, value) {
            if (value.where((e) => e.pageToken == null).isNotEmpty) return MapEntry(key, null);
            final tokenList = [...value]..sort((a, b) => (a.pageToken ?? '0').compareTo((b.pageToken ?? '0')));
            return MapEntry(key, tokenList.last.pageToken);
          });

    final _date = query != null ? null : date;
    final result = await _chatRepository.fetchMessageForInbox(
      user: user,
      channels: _channels,
      pageToken: messagePageTokens,
      q: query ?? '',
      startDate: _date,
      endDate: _date?.add(Duration(days: 1)),
      oauth: oauth!,
    );

    if (!ref.mounted) return false;

    return result.fold((l) => false, (r) {
      state = AsyncValue.data(r);
      return true;
    });
  }

  Future<void> loadRecent() async {
    if (oauth == null) return;
    final messages = state.value?.messages.toList() ?? <MessageEntity>[];
    final user = ref.read(authControllerProvider.select((v) => v.requireValue));
    final _channels = ref.read(chatChannelListControllerProvider).values.expand((e) => e.channels).toList();

    final groupedMessages = groupBy(
      messages,
      (e) => '${_channels.firstWhereOrNull((c) => c.id == e.channelId && c.teamId == e.teamId)?.isChannel != true ? 'dm' : 'cm'}${e.teamId}',
    );
    final messagePageTokens = groupedMessages.keys.isEmpty
        ? null
        : groupedMessages.map((key, value) {
            if (value.where((e) => e.pageToken == null).isNotEmpty) return MapEntry(key, null);
            final tokenList = [...value]..sort((a, b) => (a.pageToken ?? '0').compareTo((b.pageToken ?? '0')));
            return MapEntry(key, tokenList.last.pageToken);
          });

    final result = await _chatRepository.fetchMessageForInbox(
      user: user,
      channels: _channels,
      pageToken: messagePageTokens,
      q: '',
      startDate: date,
      endDate: date.add(Duration(days: 1)),
      oauth: oauth!,
    );

    result.fold((l) => null, (r) {
      state = AsyncValue.data(
        ChatFetchResultEntity(messages: [...r.messages, ...state.value?.messages ?? <MessageEntity>[]].unique((e) => e.id).toList(), nextCursor: r.nextCursor, hasMore: r.hasMore),
      );
    });
  }

  void upsertMessageInboxLocally(MessageEntity m, MessageChannelEntity channel) async {
    final user = ref.read(authControllerProvider).requireValue;
    final messageDmInboxFilter = user.userMessageDmInboxFilterTypes;
    final messageChannelInboxFilter = user.userMessageChannelInboxFilterTypes;
    final oauths = ref.read(localPrefControllerProvider.select((value) => value.value?.messengerOAuths)) ?? [];
    final oauth = oauths.where((o) => o.team?.id == channel.teamId).firstOrNull;
    if (oauth == null || oauth.team?.id == null) return;
    final inboxFilter = channel.isChannel
        ? (messageChannelInboxFilter['${oauth.team!.id}${oauth.email}'] ?? ChatInboxFilterType.mentions)
        : (messageDmInboxFilter['${oauth.team!.id}${oauth.email}'] ?? ChatInboxFilterType.all);

    final _groups = ref.read(chatGroupListControllerProvider(tabType: TabType.home).select((v) => v.groups));
    if (inboxFilter == ChatInboxFilterType.none) return;
    if (inboxFilter == ChatInboxFilterType.mentions && !m.isUserTagged(userId: channel.meId, groups: _groups)) return;

    state = AsyncData(ChatFetchResultEntity(messages: [...state.value?.messages ?? [], m], nextCursor: state.value?.nextCursor, hasMore: state.value?.hasMore ?? false));
  }

  void removeMessageInboxLocally(String messageId) {
    state = AsyncData(
      ChatFetchResultEntity(
        messages: state.value?.messages.where((e) => e.id != messageId).toList() ?? [],
        nextCursor: state.value?.nextCursor,
        hasMore: state.value?.hasMore ?? false,
      ),
    );
  }
}
