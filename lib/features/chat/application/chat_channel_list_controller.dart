import 'dart:async';
import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/infrastructure/repositories/auth_repository.dart';
import 'package:Visir/features/auth/providers.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_fetch_result_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_team_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_member_entity.dart';
import 'package:Visir/features/chat/infrastructure/repositories/message_repository.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:emoji_extension/emoji_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_channel_list_controller.g.dart';

@riverpod
class ChatChannelListController extends _$ChatChannelListController {
  late bool isSignedIn;
  late List<OAuthEntity> chatOAuths;
  Map<String, ChatChannelListControllerInternal> _controller = {};
  static final String stringKey = 'global:chat_channel_list';

  @override
  Map<String, MessageChannelFetchResultEntity> build() {
    isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));

    if (ref.watch(shouldUseMockDataProvider)) {
      // Mock 데이터 사용 시 직접 mock 채널 로드
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        final mockController = ref.read(chatChannelListControllerInternalProvider(isSignedIn: isSignedIn, oauthUniqueId: 'mock').notifier);
        final mockData = mockController.getMockChannels();
        updateState(mockData);
      });
      return {};
    }

    ref.watch(
      localPrefControllerProvider.select((v) {
        final uniqueIds = v.value?.messengerOAuths?.map((e) => e.uniqueId).toList() ?? [];
        uniqueIds.sort();
        return uniqueIds.join(',');
      }),
    );

    _controller.clear();

    chatOAuths = ref.read(localPrefControllerProvider.select((v) => v.value?.messengerOAuths ?? []));
    var returnValue = <String, MessageChannelFetchResultEntity>{};

    chatOAuths.forEach((e) {
      _controller[e.uniqueId] = ref.watch(chatChannelListControllerInternalProvider(isSignedIn: isSignedIn, oauthUniqueId: e.uniqueId).notifier);
      ref.listen(chatChannelListControllerInternalProvider(isSignedIn: isSignedIn, oauthUniqueId: e.uniqueId).select((v) => v.value ?? {}), (previous, next) {
        if (!ref.mounted) return;
        returnValue = {...returnValue, ...next};
        updateState(returnValue);
      });
    });

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      load();
    });

    return returnValue;
  }

  Timer? timer;
  void updateState(Map<String, MessageChannelFetchResultEntity> data) {
    if (timer == null) state = data;
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: kControllerDebouncMillisecond), () {
      state = data;
      timer = null;
    });
  }

  Future<Map<String, MessageChannelFetchResultEntity>> load() async {
    Completer<Map<String, MessageChannelFetchResultEntity>> completer = Completer();
    Map<String, MessageChannelFetchResultEntity> result = {};
    int resultCount = 0;
    ref.read(loadingStatusProvider.notifier).update(stringKey, LoadingState.loading);

    // OAuth가 없으면 즉시 success로 완료
    if (_controller.isEmpty) {
      ref.read(loadingStatusProvider.notifier).update(stringKey, LoadingState.success);
      completer.complete(result);
      return completer.future;
    }

    _controller.forEach((key, value) {
      value
          .load()
          .then((value) {
            result = {...result, ...(value ?? {})};
            resultCount++;
            if (resultCount != _controller.length) return;
            ref.read(loadingStatusProvider.notifier).update(stringKey, LoadingState.success);
            completer.complete(result);
          })
          .catchError((e) {
            resultCount++;
            if (resultCount != _controller.length) return;
            ref.read(loadingStatusProvider.notifier).update(stringKey, LoadingState.error);
            completer.complete(result);
          });
    });

    return completer.future;
  }

  Future<void> setReadCursor({required String teamId, required String channelId, required DateTime lastReadAt}) async {
    if (ref.read(shouldUseMockDataProvider)) return;
    final targetOAuth = chatOAuths.firstWhere((e) => e.teamId == teamId);
    return _controller[targetOAuth.uniqueId]?.setReadCursor(channelId: channelId, lastReadAt: lastReadAt);
  }

  Future<void> setChannelUpdated({required String teamId, required String channelId, required DateTime lastUpdatedAt}) async {
    if (ref.read(shouldUseMockDataProvider)) return;
    final targetOAuth = chatOAuths.firstWhere((e) => e.teamId == teamId);
    return _controller[targetOAuth.uniqueId]?.setChannelUpdated(channelId: channelId, lastUpdatedAt: lastUpdatedAt);
  }

  Future<void> setChannelRead({required String teamId, required String channelId, required DateTime lastReadAt}) async {
    if (ref.read(shouldUseMockDataProvider)) return;
    final targetOAuth = chatOAuths.firstWhere((e) => e.teamId == teamId);
    return _controller[targetOAuth.uniqueId]?.setChannelRead(channelId: channelId, lastReadAt: lastReadAt);
  }

  MessageChannelEntity? updateChannelLocally({required String teamId, required MessageChannelEntity? channel}) {
    if (ref.read(shouldUseMockDataProvider)) return null;
    final targetOAuth = chatOAuths.firstWhere((e) => e.teamId == teamId);
    return _controller[targetOAuth.uniqueId]?.updateChannelLocally(channel: channel);
  }

  Future<MessageChannelEntity?> incrementChannelUnread({required String teamId, required MessageChannelEntity channel, required MessageEntity lastMessage}) async {
    if (ref.read(shouldUseMockDataProvider)) return null;
    final targetOAuth = chatOAuths.firstWhere((e) => e.teamId == teamId);
    return _controller[targetOAuth.uniqueId]?.incrementChannelUnread(channel: channel, lastMessage: lastMessage);
  }

  MessageChannelEntity? getChannel({required String teamId, required String? channelId}) {
    if (ref.read(shouldUseMockDataProvider)) return null;
    final targetOAuth = chatOAuths.firstWhere((e) => e.teamId == teamId);
    return _controller[targetOAuth.uniqueId]?.getChannel(channelId: channelId);
  }

  Future<void> attachMessageChangeListener() async {
    if (ref.read(shouldUseMockDataProvider)) return;
    _controller.forEach((key, value) {
      value.attachMessageChangeListener();
    });
  }
}

@riverpod
class ChatChannelListControllerInternal extends _$ChatChannelListControllerInternal {
  late ChatRepository _repository;
  late AuthRepository _authRepository;

  ValueNotifier<Map<String, List<String>>> presenceNotifier = ValueNotifier({});

  List<MessageChannelEntity> _availableChannels = [];
  List<MessageChannelEntity> get availableChannels => _availableChannels;

  late String userId;
  late OAuthEntity oAuth;

  @override
  Future<Map<String, MessageChannelFetchResultEntity>> build({required bool isSignedIn, required String oauthUniqueId}) async {
    _repository = ref.watch(chatRepositoryProvider);
    _authRepository = ref.watch(authRepositoryProvider);

    if (ref.watch(shouldUseMockDataProvider)) return getMockChannels();

    userId = _authRepository.currentUserId!;
    oAuth = ref.read(localPrefControllerProvider.select((v) => v.value?.messengerOAuths ?? [])).firstWhere((e) => e.uniqueId == oauthUniqueId);

    await persist(
      ref.watch(storageProvider.future),
      key: '${ChatChannelListController.stringKey}:${isSignedIn}:${oauthUniqueId}',
      encode: (Map<String, MessageChannelFetchResultEntity> state) => jsonEncode(Map.fromEntries(state.entries.map((e) => MapEntry(e.key, e.value.toJson())).toList())),
      decode: (String encoded) {
        if (!isSignedIn) return {};
        final trimmed = encoded.trim();
        if (trimmed.isEmpty || trimmed == 'null') {
          return {};
        }
        return Map.fromEntries(
          (jsonDecode(trimmed) as Map<String, dynamic>).entries.map((e) => MapEntry(e.key, MessageChannelFetchResultEntity.fromJson(e.value as Map<String, dynamic>))).toList(),
        );
      },
      options: Utils.storageOptions,
    ).future;

    return state.value ?? <String, MessageChannelFetchResultEntity>{};
  }

  Map<String, MessageChannelFetchResultEntity> getMockChannels() {
    final channels = Map.fromEntries(
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
    final _teams = Map.fromEntries(fakeLocalPref.messengerOAuths?.map((e) => MapEntry(e.teamId!, e.team!)) ?? []);
    final _me = Map.fromEntries(fakeMeJson.entries.map((e) => MapEntry(e.key, MessageMemberEntity.fromSlack(member: SlackMessageMemberEntity.fromJson(e.value)))));
    final _members = Map.fromEntries(
      fakeMembersJson.entries.map((e) => MapEntry(e.key, e.value.map((e) => MessageMemberEntity.fromSlack(member: SlackMessageMemberEntity.fromJson(e))).toList())),
    );

    return _teams.map((key, value) {
      return MapEntry(
        key.toString(),
        MessageChannelFetchResultEntity(channels: channels[key] ?? [], team: value as MessageTeamEntity, me: _me[key]!, members: _members[key] ?? [], emojis: [], groups: []),
      );
    });
  }

  Future<void> _updateState({required Map<String, MessageChannelFetchResultEntity> data, bool? merge}) async {
    if (ref.read(shouldUseMockDataProvider)) return;
    if (!ref.mounted) return;

    final prevChannels = state.value;

    final newState = merge == true
        ? Map.fromEntries(
            data.entries.map((e) {
              final newValue = e.value.mergeWithData(
                emojis: prevChannels?[e.key]?.emojis ?? [],
                groups: prevChannels?[e.key]?.groups ?? [],
                members: prevChannels?[e.key]?.members ?? [],
              );
              return MapEntry(e.key, newValue);
            }).toList(),
          )
        : data;
    if (!ref.mounted) return;
    state = AsyncData(newState);

    if (!ref.mounted) return;
    _availableChannels.clear();
    _availableChannels.addAll(newState.values.expand((e) => e.channels));

    if (!ref.mounted) return;

    if (ref.read(shouldUseMockDataProvider)) return;

    final newChannelData = data.values
        .map((e) {
          return e.channels.map((c) {
            return [
              ...e.members.map(
                (m) => {
                  'id': 'member-${c.teamId}-${c.id}-${m.id}',
                  'team_id': c.teamId,
                  'channel_id': c.id,
                  'member_id': m.id,
                  'member_name': m.displayName,
                  'channel_name': c.displayName,
                  'team_name': e.team.name,
                  'is_channel': c.isChannel,
                  'is_dm': c.isDm,
                  'user_id': userId,
                },
              ),
              ...e.groups.map(
                (g) => {
                  'id': 'group-${c.teamId}-${c.id}-${g.id}',
                  'team_id': c.teamId,
                  'channel_id': c.id,
                  'member_id': g.id,
                  'member_name': g.displayName,
                  'channel_name': c.displayName,
                  'team_name': e.team.name,
                  'is_channel': c.isChannel,
                  'is_dm': c.isDm,
                  'user_id': userId,
                  'member_ids': g.users,
                },
              ),
            ];
          }).toList();
        })
        .expand((e) => e)
        .expand((e) => e)
        .toList();

    final prevChannelData = prevChannels?.values
        .map((e) {
          return e.channels.map((c) {
            return [
              ...e.members.map(
                (m) => {
                  'id': 'member-${c.teamId}-${c.id}-${m.id}',
                  'team_id': c.teamId,
                  'channel_id': c.id,
                  'member_id': m.id,
                  'member_name': m.displayName,
                  'channel_name': c.displayName,
                  'team_name': e.team.name,
                  'is_channel': c.isChannel,
                  'is_dm': c.isDm,
                  'user_id': userId,
                },
              ),
              ...e.groups.map(
                (g) => {
                  'id': 'group-${c.teamId}-${c.id}-${g.id}',
                  'team_id': c.teamId,
                  'channel_id': c.id,
                  'member_id': g.id,
                  'member_name': g.displayName,
                  'channel_name': c.displayName,
                  'team_name': e.team.name,
                  'is_channel': c.isChannel,
                  'is_dm': c.isDm,
                  'user_id': userId,
                  'member_ids': g.users,
                },
              ),
            ];
          }).toList();
        })
        .expand((e) => e)
        .expand((e) => e)
        .toList();

    newChannelData.sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));
    prevChannelData?.sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));

    _authRepository.updateMessageInfos(data: newChannelData.unique((e) => e['id'] as String), userId: userId, teamIds: data.keys.toList());
  }

  Future<Map<String, MessageChannelFetchResultEntity>?> load() async {
    if (ref.read(shouldUseMockDataProvider)) return null;
    if (!ref.mounted) return null;
    LocalPrefEntity? _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return null;

    final channelData = state.value?.values.expand((e) => e.channels).toList();
    final result = await _repository.fetchChannels(oAuth: oAuth, channels: channelData ?? [], userId: userId);

    return result.fold(
      (l) {
        return null;
      },
      (r) async {
        final newState = Map.fromEntries(r.entries.map((e) => MapEntry(e.key, e.value.copyWithMembers(members: []))));
        await _updateState(data: newState, merge: true);
        return r;
      },
    );
  }

  Future<void> setChannelUpdated({required String channelId, required DateTime lastUpdatedAt}) async {
    if (ref.read(shouldUseMockDataProvider)) return;

    LocalPrefEntity? _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return;

    final newState = {...(state.value ?? {})};
    MessageChannelEntity? channel = newState.values.expand((e) => e.channels).firstWhereOrNull((e) => e.id == channelId)?.copyWith();

    if (channel == null) return;
    if (!lastUpdatedAt.isAfter(channel.lastUpdated)) return;

    await _updateState(
      data: newState.map((key, value) => MapEntry(key, value.copyWithChannelUpdated(channelId: channelId, lastUpdatedAt: lastUpdatedAt))),
    );
  }

  Future<void> setChannelRead({required String channelId, required DateTime lastReadAt}) async {
    if (ref.read(shouldUseMockDataProvider)) return;

    LocalPrefEntity? _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return;

    final newState = {...(state.value ?? {})};
    MessageChannelEntity? channel = newState.values.expand((e) => e.channels).firstWhereOrNull((e) => e.id == channelId)?.copyWith();

    if (channel == null) return;
    if (channel.lastReadAt != null && !lastReadAt.isAfter(channel.lastReadAt!)) return;

    await _updateState(
      data: newState.map((key, value) => MapEntry(key, value.copyWithChannelRead(channelId: channelId, lastReadAt: lastReadAt))),
    );
  }

  Future<void> setReadCursor({required String channelId, required DateTime lastReadAt}) async {
    if (ref.read(shouldUseMockDataProvider)) return;

    LocalPrefEntity? _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) return;

    final newState = {...(state.value ?? {})};
    MessageChannelEntity? channel = newState.values.expand((e) => e.channels).firstWhereOrNull((e) => e.id == channelId)?.copyWith();

    if (channel == null) return;
    if (channel.lastReadAt != null && !lastReadAt.isAfter(channel.lastReadAt!)) return;
    await _updateState(
      data: newState.map((key, value) => MapEntry(key, value.copyWithReadCursor(channelId: channelId, lastReadAt: lastReadAt))),
    );

    EasyDebounce.debounce('setReadCursor:${channelId}', Duration(milliseconds: 1000), () async {
      if (!ref.mounted) return;

      await _repository.setReadCursor(type: channel.type, oauth: oAuth, channelId: channel.id, lastReadAt: lastReadAt, lastUpdatedAt: channel.lastUpdated, userId: userId);
    });
  }

  MessageChannelEntity? updateChannelLocally({MessageChannelEntity? channel}) {
    if (ref.read(shouldUseMockDataProvider)) return null;
    final newState = {...(state.value ?? {})};
    MessageChannelEntity? prevChannel = newState.values.expand((e) => e.channels).firstWhereOrNull((e) => e.id == channel?.id);
    if (channel == null || prevChannel == null) return null;
    _updateState(data: newState.map((key, value) => MapEntry(key, value.copyWithChannel(channel: channel))));
    return channel;
  }

  Future<MessageChannelEntity?> incrementChannelUnread({required MessageChannelEntity channel, required MessageEntity lastMessage}) async {
    if (ref.read(shouldUseMockDataProvider)) return null;

    final newState = {...(state.value ?? {})};

    await _updateState(
      data: newState.map((key, value) => MapEntry(key, value.copyWithIncrementUnread(channel: channel, lastMessage: lastMessage))),
    );
    return channel;
  }

  MessageChannelEntity? getChannel({String? channelId}) {
    if (ref.read(shouldUseMockDataProvider)) return null;
    final newState = {...(state.value ?? {})};
    final channel = newState.values.expand((e) => e.channels).firstWhereOrNull((e) => e.id == channelId);
    return channel;
  }

  Future<void> attachMessageChangeListener() async {
    if (ref.read(shouldUseMockDataProvider)) return;
    final user = ref.read(authControllerProvider).requireValue;
    await _repository.attachMessageChangeListener(user: user, oauth: oAuth);
  }
}
