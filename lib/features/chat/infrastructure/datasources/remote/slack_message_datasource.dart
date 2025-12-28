import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/chat/domain/datasources/chat_datasource.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_fetch_result_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_last_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_emoji_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_file_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_reaction_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_team_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_unread_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_emoji_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_file_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_member_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_reaction_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_team_entity.dart';
import 'package:Visir/features/chat/domain/entities/state/chat_fetch_result_entity.dart';
import 'package:Visir/features/chat/domain/entities/state/message_thread_fetch_result_entity.dart';
import 'package:Visir/features/chat/domain/entities/state/message_uploading_temp_file_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/slack_api_handler.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SlackMessageDatasource implements MessageDatasource {
  SlackMessageDatasource();

  List<RealtimeChannel> slackEventSubscriptionChannels = [];

  final lazyLoadingCount = 40;

  static String teamInfoUrl = "https://slack.com/api/team.info";
  static String usersListUrl = "https://slack.com/api/users.list";
  static String usersConversationsUrl = "https://slack.com/api/users.conversations";
  static String conversationsInfoUrl = "https://slack.com/api/conversations.info";
  static String emojiListUrl = "https://slack.com/api/emoji.list";
  static String usergroupsListUrl = "https://slack.com/api/usergroups.list";
  static String conversationHistoryUrl = "https://slack.com/api/conversations.history";
  static String chatPostMessageUrl = "https://slack.com/api/chat.postMessage";
  static String chatDeleteMessageUrl = "https://slack.com/api/chat.delete";
  static String chatUpdateUrl = "https://slack.com/api/chat.update";
  static String conversationsRepliesUrl = "https://slack.com/api/conversations.replies";
  static String reactionsAddUrl = "https://slack.com/api/reactions.add";
  static String reactionsGetUrl = "https://slack.com/api/reactions.get";
  static String filesGetUploadUrlExternalUrl = "https://slack.com/api/files.getUploadURLExternal";
  static String reactionsRemoveUrl = "https://slack.com/api/reactions.remove";
  static String filesCompleteUploadExternalUrl = "https://slack.com/api/files.completeUploadExternal";
  static String conversationsMembersUrl = "https://slack.com/api/conversations.members";
  static String conversationsMarkUrl = "https://slack.com/api/conversations.mark";
  static String usersInfoUrl = "https://slack.com/api/users.info";
  static String botsInfoUrl = "https://slack.com/api/bots.info";
  static String searchMessagesUrl = "https://slack.com/api/search.messages";
  static String messagePermalinkUrl = "https://slack.com/api/chat.getPermalink";
  static String userProfileUrl = "https://slack.com/api/users.profile.get";
  static String authTestUrl = "https://slack.com/api/auth.test";

  static String rtmConnectUrl = "https://slack-rtm-server.fly.dev/connect";
  static String setPresenceUrl = "https://slack-rtm-server.fly.dev/presence/update";
  static String Function(String teamId) getPresenceUrl = (String teamId) => "https://slack-rtm-server.fly.dev/presence/$teamId";

  final scopes = [
    'channels:history',
    'channels:read',
    'chat:write',
    'emoji:read',
    'files:read',
    'files:write',
    'groups:history',
    'groups:read',
    'im:history',
    'im:read',
    'mpim:history',
    'mpim:read',
    'reactions:read',
    'reactions:write',
    'team:read',
    'usergroups:read',
    'users.profile:read',
    'users:read',
    'users:read.email',
    'channels:write',
    'groups:write',
    'im:write',
    'mpim:write',
    'search:read',
  ];

  static Map<String, String> urlEncodedHeader = {'Content-Type': 'application/x-www-form-urlencoded'};

  static Map<String, String> jsonHeader = {'Content-Type': 'application/json'};

  static Map<String, String> multipartFormDataHeader = {"Content-type": "multipart/form-data"};

  final String rateLimitErrorString = 'rateLimited';

  Duration _computeSlackBackoffDelay(int attempt) {
    final int baseMs = 400;
    final int maxMs = 8000;
    final int ms = (baseMs * pow(2, attempt)).toInt();
    return Duration(milliseconds: ms > maxMs ? maxMs : ms);
  }

  Future<dynamic> _callWithSlackBackoff(Future<dynamic> Function() call) async {
    int attempt = 0;
    const int maxAttempts = 6;
    bool showedToast = false;

    while (true) {
      final dynamic result = await call();
      try {
        final dynamic data = jsonDecode(result);
        if (data is Map && data['error']?.toString() == rateLimitErrorString) {
          if (!showedToast) {
            Utils.showRateLimitedToast(type: RateLimitType.slack);
            showedToast = true;
          }
          if (attempt >= maxAttempts - 1) {
            return result;
          }
          await Future.delayed(_computeSlackBackoffDelay(attempt));
          attempt++;
          continue;
        }
      } catch (_) {
        // ignore JSON parse error; return result as-is
      }
      return result;
    }
  }

  @override
  Future<OAuthEntity?> integrate() async {
    final Completer<OAuthEntity?> completer = Completer();
    SlackApiHandler.integrate(onResult: (oauth) => completer.complete(oauth)).catchError((error) {
      completer.completeError(error);
    });
    return completer.future;
  }

  @override
  Future<Map<String, MessageChannelFetchResultEntity>> fetchChannels({required String userId, required OAuthEntity oAuth, List<MessageChannelEntity>? channels}) async {
    Map<String, MessageChannelFetchResultEntity> messageChannels = {};

    final urls = [teamInfoUrl, userProfileUrl, authTestUrl];

    final result = await Future.wait([
      ...urls.map((url) {
        try {
          return proxyCall(
            oauth: oAuth,
            method: url == teamInfoUrl || url == authTestUrl ? 'POST' : 'GET',
            url: url,
            headers: {
              if (url == teamInfoUrl || url == authTestUrl) ...jsonHeader,
              if (url != teamInfoUrl && url != authTestUrl) ...urlEncodedHeader,
              ...oAuth.authorizationHeaders!,
            },
            files: null,
            body: url == usergroupsListUrl
                ? {'include_users': 'true'}
                : url == usersListUrl
                ? {'team_id': oAuth.teamId!, 'limit': '200'}
                : null,
          );
        } catch (e) {
          return Future.value(null);
        }
      }),
      _fetchChannelData(oAuth: oAuth, prevCursor: null),
    ]);

    final slackTeam = jsonDecode(result[urls.indexOf(teamInfoUrl)] as dynamic)['team'] == null
        ? null
        : SlackMessageTeamEntity.fromJson(jsonDecode(result[urls.indexOf(teamInfoUrl)] as dynamic)['team']);

    final authTestResult = (jsonDecode(result[urls.indexOf(authTestUrl)] as dynamic));
    final userProfileResult = (jsonDecode(result[urls.indexOf(userProfileUrl)] as dynamic));

    final meId = authTestResult['user_id'];
    final meName = authTestResult['user'];
    final meProfile = userProfileResult['profile'];

    final slackMe = SlackMessageMemberEntity.fromJson({'id': meId, 'name': meName, 'profile': meProfile});
    List<SlackMessageChannelEntity> fetchedChannels = result.last as List<SlackMessageChannelEntity>;

    final channelUnreadResult = await Future.wait([
      Supabase.instance.client.from('message_unread').select().eq('user_id', userId).inFilter('channel_id', fetchedChannels.map((c) => c.id).toList()).eq('team_id', oAuth.teamId!),
      Supabase.instance.client.from('message_channel_last').select().inFilter('channel_id', fetchedChannels.map((c) => c.id).toList()).eq('team_id', oAuth.teamId!),
    ]);

    final _unreads = channelUnreadResult[0].map((e) => MessageUnreadEntity.fromJson(e)).toList();
    final _lasts = channelUnreadResult[1].map((e) => MessageChannelLastEntity.fromJson(e)).toList();

    fetchedChannels = fetchedChannels.where((e) {
      if (e.isIm == true) {
        return e.isUserDeleted != true;
      } else if (e.isMpim == true) {
        return e.isOpen == true && e.isArchived != true;
      }
      return e.isArchived != true;
    }).toList();

    final groupDmIds = fetchedChannels.where((e) => e.isMpim == true).map((e) => e.id!).toList();
    final groupMemberIds = await fetchMemberIdsFromMpimIds(oauth: oAuth, mpimIds: groupDmIds);
    final userIds = fetchedChannels.where((e) => e.isIm == true).map((e) => e.user!).toList() + groupMemberIds;
    final members = await fetchMembers(oauth: oAuth, userIds: userIds);

    messageChannels[oAuth.teamId!] = MessageChannelFetchResultEntity(
      channels: fetchedChannels
          .map((e) {
            final prevChannel = channels?.firstWhereOrNull((c) => c.id == e.id);
            if (prevChannel?.teamId == null && slackTeam == null) return null;

            MessageUnreadEntity? unread = _unreads.firstWhereOrNull((u) => u.channelId == e.id);
            MessageChannelLastEntity? last = _lasts.firstWhereOrNull((l) => l.channelId == e.id);

            final lastMessageCreatedAt = last?.lastMessageCreatedAt ?? DateTime(1970);
            final lastMessageReadAt = unread?.lastMessageUserReadAt ?? lastMessageCreatedAt;

            bool hasUnread = lastMessageReadAt.isBefore(lastMessageCreatedAt);

            String customName = e.name ?? '';

            if (e.isIm ?? false) {
              customName = members.getMemberFromUserId(userId: e.user)?.displayName ?? '';
            } else if (e.isMpim ?? false) {
              final name = e.name?.substring('mpdm-'.length, e.name!.length - 2) ?? '';
              List<String>? membersString = name.split('--');
              membersString.removeWhere((e) => e.isEmpty);
              List<String> memberNames = [];
              for (String memberName in membersString) {
                final member = members.firstWhereOrNull((m) => m.username == memberName);
                memberNames.add(member?.displayName ?? '@${memberName}');
              }
              customName = memberNames.join(', ');
            }

            final channel = MessageChannelEntity.fromSlack(
              channel: e.copyWith(
                lastUpdated: lastMessageCreatedAt,
                lastRead: (lastMessageReadAt.millisecondsSinceEpoch / 1000000).toString(),
                unreadCount: hasUnread ? 1 : 0,
                unreadCountDisplay: hasUnread ? 1 : 0,
              ),
              teamId: slackTeam == null ? prevChannel!.teamId : slackTeam.id,
              meId: slackMe.id!,
              customName: customName,
            );

            if (channel.isDmWithDeletedUser) return null;
            if (channel.isArchived) return null;
            if (channel.displayName.isEmpty) return null;
            return channel;
          })
          .whereType<MessageChannelEntity>()
          .toList(),
      members: members,
      groups: [],
      emojis: [],
      me: MessageMemberEntity.fromSlack(member: slackMe),
      team: MessageTeamEntity.fromSlack(team: slackTeam!),
    );

    return messageChannels;
  }

  Future<List<SlackMessageChannelEntity>> _fetchChannelData({required OAuthEntity oAuth, required String? prevCursor}) async {
    List<SlackMessageChannelEntity> channels = [];

    final response = await proxyCall(
      oauth: oAuth,
      method: 'GET',
      url: usersConversationsUrl,
      headers: {...urlEncodedHeader, ...oAuth.authorizationHeaders!},
      files: null,
      body: {'cursor': prevCursor, 'types': 'public_channel,private_channel,mpim,im', 'limit': '999', 'exclude_archived': 'true'}..removeWhere((key, value) => value == null),
    );

    channels.addAll((jsonDecode(response)['channels'] as List<dynamic>).map((d) => SlackMessageChannelEntity.fromJson(d)).toList());
    String? cursor = jsonDecode(response)['response_metadata']?['next_cursor'];

    if (cursor != null && cursor.isNotEmpty) {
      final additionalChannel = await _fetchChannelData(oAuth: oAuth, prevCursor: cursor);
      channels.addAll(additionalChannel);
    }

    return channels;
  }

  @override
  Future<ChatFetchResultEntity?> fetchMessageForInbox({
    required OAuthEntity oauth,
    required UserEntity user,
    required List<MessageChannelEntity> channels,
    Map<String, String?>? pageToken,
    String? oldestId,
    required String q,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    bool isRateLimited = false;

    String? nextCursor;
    List<MessageEntity> list = [];

    String dateFilter = '';
    if (startDate != null) dateFilter = '${dateFilter} after:${DateFormat('yyyy-MM-dd').format(startDate.subtract(Duration(days: 1)))}';
    if (endDate != null) dateFilter = '${dateFilter} before:${DateFormat('yyyy-MM-dd').format(endDate)}';

    final dmFilter = user.userMessageDmInboxFilterTypes['${oauth.teamId}${oauth.email}'];
    final channelFilter = user.userMessageChannelInboxFilterTypes['${oauth.teamId}${oauth.email}'];
    final me = channels.where((e) => e.teamId == oauth.teamId).firstOrNull?.meId;

    if (me == null) return null;
    final displayName = '<@${me}>';

    final channelList = channels.where((e) => e.isChannel).toList();
    // final dmList = channels.where((e) => e.isDm || e.isGroupDm).toList();
    String channelInFilterString = channelList.map((e) => 'in:<#${e.id}>').join(' ');
    String dmInFilterString = ''; //dmList.map((e) => e.isGroupDm ? 'in:${e.displayName}' : 'in:@${e.displayName}').join(' ');

    String channelQuery = q.isNotEmpty
        ? '${q}${dateFilter} ${channelInFilterString} -is:dm'
        : channelFilter == ChatInboxFilterType.none
        ? ''
        : '${displayName} ${q}${dateFilter} ${channelInFilterString} -from:me -is:dm';
    String dmQuery = q.isNotEmpty
        ? '${q}${dateFilter} ${dmInFilterString} is:dm'
        : dmFilter == ChatInboxFilterType.none
        ? ''
        : dmFilter == ChatInboxFilterType.mentions
        ? '${displayName} ${q}${dateFilter} ${dmInFilterString} -from:me is:dm'
        : '${q}${dateFilter} ${dmInFilterString}  -from:me is:dm';
    final channelToken = pageToken?['cm${oauth.teamId}'];
    final dmToken = pageToken?['dm${oauth.teamId}'];

    List<Future<dynamic>> futures = [];

    if (channelQuery.isNotEmpty && !(pageToken != null && channelToken == null)) {
      futures.add(
        proxyCall(
          oauth: oauth,
          method: 'GET',
          url: searchMessagesUrl,
          headers: {...urlEncodedHeader, ...oauth.authorizationHeaders!},
          files: null,
          body: {'query': channelQuery, 'count': lazyLoadingCount.toString(), if (channelToken != null) 'page': channelToken, 'sort': 'timestamp'},
        ),
      );
    }

    if (dmQuery.isNotEmpty && !(pageToken != null && dmToken == null)) {
      futures.add(
        proxyCall(
          oauth: oauth,
          method: 'GET',
          url: searchMessagesUrl,
          headers: {...urlEncodedHeader, ...oauth.authorizationHeaders!},
          files: null,
          body: {'query': dmQuery, 'count': lazyLoadingCount.toString(), if (dmToken != null) 'page': dmToken, 'sort': 'timestamp'},
        ),
      );
    }

    final responses = await Future.wait(futures);

    for (final response in responses) {
      final decodedResponse = jsonDecode(response);
      final messages = decodedResponse['messages'];
      if (messages != null && messages.isNotEmpty) {
        final slackMessages = (messages['matches'] as List<dynamic>? ?? [])
            .map((e) {
              try {
                final message = SlackMessageEntity.fromJson({
                  ...e,
                  'channel': e['channel']['id'],
                  'thread_ts': e['permalink']?.contains('thread_ts=') == true ? e['permalink']?.split('thread_ts=').last : null,
                  'link': e['permalink'],
                  'team': oauth.teamId,
                });
                return message;
              } catch (e) {
                return null;
              }
            })
            .whereType<SlackMessageEntity>()
            .toList();
        final pagination = messages['pagination'];
        if (pagination != null) {
          final int page = pagination['page'];
          final int pageCount = pagination['page_count'];
          if (decodedResponse?['error'] == rateLimitErrorString) {
            isRateLimited = true;
          }

          final cursor = page >= pageCount ? null : (page + 1).toString();
          if (cursor != null) nextCursor = cursor;

          for (SlackMessageEntity e in slackMessages) {
            list.add(MessageEntity.fromSlack(message: e, pageToken: page >= pageCount ? null : (page + 1).toString()));
          }
        }
      }
    }

    return ChatFetchResultEntity(messages: list, hasMore: false, nextCursor: nextCursor, channel: null, isRateLimited: isRateLimited);
  }

  @override
  Future<ChatFetchResultEntity?> searchMessage({
    required OAuthEntity oauth,
    required UserEntity user,
    Map<String, String?>? pageToken,
    List<MessageChannelEntity>? channels,
    required String q,
    SearchSortType sortType = SearchSortType.relevant,
  }) async {
    bool isRateLimited = false;

    Map<String, String?> nextPageTokens = {};
    List<MessageEntity> list = [];
    String query = '${q}';
    final token = pageToken?[oauth.teamId];

    List<Future<dynamic>> futures = [];

    if (query.isNotEmpty && !(pageToken != null && token == null)) {
      futures.add(
        proxyCall(
          oauth: oauth,
          method: 'GET',
          url: searchMessagesUrl,
          headers: {...urlEncodedHeader, ...oauth.authorizationHeaders!},
          files: null,
          body: {'query': query, 'count': lazyLoadingCount.toString(), if (token != null) 'page': token, 'sort': sortType.slackValue},
        ),
      );
    }

    final responses = await Future.wait(futures);

    for (final response in responses) {
      final decodedResponse = jsonDecode(response);
      final messages = decodedResponse['messages'];
      if (messages != null && messages.isNotEmpty) {
        final slackMessages = (messages['matches'] as List<dynamic>? ?? [])
            .map((e) {
              try {
                final message = SlackMessageEntity.fromJson({
                  ...e,
                  'channel': e['channel']['id'],
                  'thread_ts': e['permalink']?.contains('thread_ts=') == true ? e['permalink']?.split('thread_ts=').last : null,
                  'link': e['permalink'],
                  'team': oauth.teamId,
                });
                return message;
              } catch (e) {
                return null;
              }
            })
            .whereType<SlackMessageEntity>()
            .toList();
        final pagination = messages['pagination'];
        if (pagination != null) {
          final int page = pagination['page'];
          final int pageCount = pagination['page_count'];
          if (decodedResponse?['error'] == rateLimitErrorString) {
            isRateLimited = true;
          }

          final cursor = page >= pageCount ? null : (page + 1).toString();
          if (cursor != null) nextPageTokens[oauth.teamId!] = cursor;

          for (SlackMessageEntity e in slackMessages) {
            list.add(MessageEntity.fromSlack(message: e, pageToken: page >= pageCount ? null : (page + 1).toString()));
          }
        }
      }
    }

    final availableList = list.where((e) => (channels?.any((c) => c.id == e.channelId && c.teamId == e.teamId) ?? false)).toList();

    if (nextPageTokens.values.whereType<String>().isNotEmpty) {
      return searchMessage(oauth: oauth, user: user, pageToken: nextPageTokens, channels: channels, q: q);
    }

    return ChatFetchResultEntity(messages: availableList, hasMore: nextPageTokens.isNotEmpty, nextPageTokens: nextPageTokens, isRateLimited: isRateLimited);
  }

  @override
  Future<ChatFetchResultEntity?> fetchMessages({required OAuthEntity oauth, required MessageChannelEntity channel, String? nextCursor, String? oldestId, String? targetId}) async {
    List<dynamic> data = [];

    bool hasMore = false;
    bool hasRecent = false;
    bool isRateLimited = false;

    Utils.reportAutoFeedback(errorMessage: 'slackMessageDatasource fetchMessages : ${channel.id} ${channel.name}');

    if (targetId == null) {
      Map<String, dynamic> body = {'channel': channel.id, 'limit': lazyLoadingCount.toString(), 'include_all_metadata': true};
      if (oldestId != null) body['oldest'] = oldestId;
      if (nextCursor != null) body['cursor'] = nextCursor;
      final response = await proxyCall(
        oauth: oauth,
        method: 'POST',
        url: conversationHistoryUrl,
        headers: {...jsonHeader, ...oauth.authorizationHeaders!},
        files: null,
        body: body,
      );

      Utils.reportAutoFeedback(errorMessage: 'slackMessageDatasource fetchMessages response : ${response}');

      data = jsonDecode(response)['messages'] as List<dynamic>? ?? [];
      hasMore = jsonDecode(response)['has_more'] ?? false;
      nextCursor = jsonDecode(response)['response_metadata']?['next_cursor'];
      isRateLimited = jsonDecode(response)?['error'] == rateLimitErrorString;
    } else {
      Map<String, dynamic> body = {'channel': channel.id, 'limit': lazyLoadingCount.toString(), 'include_all_metadata': true};

      final response = await Future.wait([
        proxyCall(
          oauth: oauth,
          method: 'POST',
          url: conversationHistoryUrl,
          headers: {...jsonHeader, ...oauth.authorizationHeaders!},
          files: null,
          body: {...body, 'oldest': targetId, 'inclusive': 'true'},
        ),
        proxyCall(
          oauth: oauth,
          method: 'POST',
          url: conversationHistoryUrl,
          headers: {...jsonHeader, ...oauth.authorizationHeaders!},
          files: null,
          body: {...body, 'latest': targetId},
        ),
      ]);

      data.addAll(jsonDecode(response[0])['messages'] as List<dynamic>? ?? []);
      data.addAll(jsonDecode(response[1])['messages'] as List<dynamic>? ?? []);

      hasRecent = jsonDecode(response[0])['has_more'] ?? false;
      hasMore = jsonDecode(response[1])['has_more'] ?? false;
      nextCursor = jsonDecode(response[1])['response_metadata']?['next_cursor'];
      isRateLimited = jsonDecode(response[0])?['error'] == rateLimitErrorString || jsonDecode(response[0])?['error'] == rateLimitErrorString;
    }

    final messages = data
        .map((e) {
          try {
            final SlackMessageEntity slackMessage = SlackMessageEntity.fromJson(e);
            return MessageEntity.fromSlack(message: slackMessage);
          } catch (e) {
            return null;
          }
        })
        .whereType<MessageEntity>()
        .toList()
        .unique((e) => e.id);

    return ChatFetchResultEntity(messages: messages, hasMore: hasMore, hasRecent: hasRecent, nextCursor: nextCursor, channel: channel, isRateLimited: isRateLimited);
  }

  Map recursiveRemoveNull(Map map) {
    return (map..removeWhere((key, value) => value == null)).map((key, value) {
      if (value is List)
        return MapEntry(
          key,
          ([...value]..removeWhere((e) => e == null)).map((e) {
            if (e is Map) return recursiveRemoveNull(e);
            return e;
          }).toList(),
        );
      if (value is Map) return MapEntry(key, recursiveRemoveNull(value));
      return MapEntry(key, value);
    });
  }

  @override
  Future<MessageEntity?> postMessage({bool? isEdit, required OAuthEntity oauth, required MessageChannelEntity channel, required MessageEntity message, String? threadId}) async {
    final body = {
      'channel': channel.id,
      if (message.blocks.isNotEmpty)
        'blocks': jsonEncode(
          message.blocks.map((e) {
            return recursiveRemoveNull(e.slackMessageBlock!.toJson());
          }).toList(),
        ),
      if (message.text != null) 'text': message.text,
      if (message.attachments.isNotEmpty) 'attachments': jsonEncode(message.attachments.map((e) => e.toJson()).toList()),
      if (isEdit == true) 'ts': message.id,
    };

    if (threadId != null) body['thread_ts'] = threadId;

    final response = await proxyCall(
      oauth: oauth,
      method: 'POST',
      url: isEdit == true ? chatUpdateUrl : chatPostMessageUrl,
      headers: {...jsonHeader, ...oauth.authorizationHeaders!},
      files: null,
      body: body,
    );

    final SlackMessageEntity slackMessage = SlackMessageEntity.fromJson(jsonDecode(response)['message']);
    return MessageEntity.fromSlack(message: slackMessage);
  }

  @override
  Future<bool> deleteMessage({required OAuthEntity oauth, required String channelId, required String messageId}) async {
    final body = {'channel': channelId, 'ts': messageId};

    final response = await proxyCall(oauth: oauth, method: 'POST', url: chatDeleteMessageUrl, headers: {...jsonHeader, ...oauth.authorizationHeaders!}, files: null, body: body);

    return jsonDecode(response)['ok'];
  }

  @override
  Future<MessageThreadFetchResultEntity?> fetchReplies({
    required OAuthEntity oauth,
    required MessageChannelEntity channel,
    required String parentMessageId,
    String? oldestId,
    String? nextCursor,
  }) async {
    Map<String, dynamic> body = {'channel': channel.id, 'ts': parentMessageId, 'limit': lazyLoadingCount.toString()};
    if (nextCursor != null) body['cursor'] = nextCursor;
    if (oldestId != null) body['oldest'] = oldestId;

    final response = await proxyCall(
      oauth: oauth,
      method: 'GET',
      url: conversationsRepliesUrl,
      headers: {...urlEncodedHeader, ...oauth.authorizationHeaders!},
      files: null,
      body: body,
    );

    final data = jsonDecode(response)['messages'] as List<dynamic>? ?? [];

    final messages = data
        .map((e) {
          try {
            final SlackMessageEntity slackMessage = SlackMessageEntity.fromJson(e);
            return MessageEntity.fromSlack(message: slackMessage);
          } catch (e) {
            return null;
          }
        })
        .whereType<MessageEntity>()
        .toList();

    return MessageThreadFetchResultEntity(
      messages: messages,
      hasMore: jsonDecode(response)['has_more'] ?? false,
      nextCursor: jsonDecode(response)['response_metadata']?['next_cursor'],
      channel: channel,
      isRateLimited: jsonDecode(response)?['error'] == rateLimitErrorString,
    );
  }

  @override
  Future<bool> addReaction({required OAuthEntity oauth, required String channelId, required String messageId, required String emoji}) async {
    final response = await proxyCall(
      oauth: oauth,
      method: 'POST',
      url: reactionsAddUrl,
      headers: {...jsonHeader, ...oauth.authorizationHeaders!},
      files: null,
      body: {'channel': channelId, 'name': emoji, 'timestamp': messageId},
    );

    bool isOk = jsonDecode(response)['ok'];
    if (!isOk) return false;
    return true;
  }

  @override
  Future<bool> removeReaction({required OAuthEntity oauth, required String channelId, required String messageId, required String emoji}) async {
    final response = await proxyCall(
      oauth: oauth,
      method: 'POST',
      url: reactionsRemoveUrl,
      headers: {...jsonHeader, ...oauth.authorizationHeaders!},
      files: null,
      body: {'channel': channelId, 'name': emoji, 'timestamp': messageId},
    );

    return jsonDecode(response)['ok'];
  }

  @override
  Future<List<MessageReactionEntity>> fetchReactions({required OAuthEntity oauth, required String channelId, required String messageId}) async {
    final response = await proxyCall(
      oauth: oauth,
      method: 'GET',
      url: reactionsGetUrl,
      headers: {...urlEncodedHeader, ...oauth.authorizationHeaders!},
      files: null,
      body: {'channel': channelId, 'timestamp': messageId},
    );

    final data = jsonDecode(response)['message']['reactions'] as List<dynamic>?;
    if (data == null) return [];
    return data
        .map((e) {
          try {
            return MessageReactionEntity.fromSlack(reaction: SlackMessageReactionEntity.fromJson(e));
          } catch (e) {
            return null;
          }
        })
        .whereType<MessageReactionEntity>()
        .toList();
  }

  @override
  Future<MessageUploadingTempFileEntity?> uploadFileToServer({required OAuthEntity oauth, required PlatformFile file}) async {
    final getUploadUrlResponse = await proxyCall(
      oauth: oauth,
      method: 'GET',
      url: filesGetUploadUrlExternalUrl,
      headers: {...urlEncodedHeader, ...oauth.authorizationHeaders!},
      files: null,
      body: {'filename': file.name, 'length': file.size.toString()},
    );

    String uploadUrl = jsonDecode(getUploadUrlResponse)['upload_url'] as String;
    String fileId = jsonDecode(getUploadUrlResponse)['file_id'] as String;

    String mimeTypeString = lookupMimeType(file.name, headerBytes: file.bytes!) ?? 'image/png';

    final mFile = http.MultipartFile('file', http.ByteStream.fromBytes(file.bytes!), file.size, filename: file.name, contentType: MediaType.parse(mimeTypeString));

    final uploadFileResponse = await proxyCall(
      oauth: oauth,
      method: 'POST',
      url: uploadUrl,
      headers: {...multipartFormDataHeader, ...oauth.authorizationHeaders!},
      files: [mFile],
      body: null,
    );

    if (uploadFileResponse == null) return null;
    return MessageUploadingTempFileEntity(file: file, onProcess: false, uploadUrl: uploadUrl, fileId: fileId, ok: true);
  }

  @override
  Future<List<MessageFileEntity>> postFilesToChannel({
    required OAuthEntity oauth,

    required String channelId,
    required List<MessageUploadingTempFileEntity> fileDataList,
    required MessageEntity message,
    String? threadId,
  }) async {
    List<String> filesString = [];
    fileDataList.forEach((e) {
      if (e.ok ?? false) filesString.add('{"id":"${e.fileId}", "title":"${e.file.name}"}');
    });

    final body = {
      'channel_id': channelId,
      if (message.blocks.isNotEmpty)
        'blocks': jsonEncode(
          message.blocks.map((e) {
            return recursiveRemoveNull(e.slackMessageBlock!.toJson());
          }).toList(),
        ),
      if (threadId != null) 'thread_ts': threadId,
      if (message.blocks.isEmpty && message.text?.isNotEmpty == true) 'initial_comment': message.text,
      'files': filesString.toString(),
    };

    final response = await proxyCall(
      oauth: oauth,
      method: 'POST',
      url: filesCompleteUploadExternalUrl,
      headers: {...jsonHeader, ...oauth.authorizationHeaders!},
      files: null,
      body: body,
    );

    final filesData = jsonDecode(response)['files'] as List<dynamic>?;
    final files = filesData
        ?.map((e) {
          try {
            return MessageFileEntity.fromSlack(file: SlackMessageFileEntity.fromJson(e));
          } catch (E) {
            return null;
          }
        })
        .whereType<MessageFileEntity>()
        .toList();
    return files ?? [];
  }

  StreamSubscription? unreadSubscription;
  StreamSubscription? lastSubscription;

  bool get isUnreadListenerConnected => Supabase.instance.client.realtime.isConnected && unreadSubscription != null;

  bool get isLastListenerConnected => Supabase.instance.client.realtime.isConnected && lastSubscription != null;

  @override
  Future<void> setReadCursor({
    required OAuthEntity oauth,
    required String userId,
    required String channelId,
    required DateTime lastReadAt,
    required DateTime? lastUpdatedAt,
  }) async {
    await Supabase.instance.client.from('message_unread').upsert({
      'id': '${userId}${oauth.teamId}${channelId}',
      'user_id': userId,
      'channel_id': channelId,
      'team_id': oauth.teamId,
      'last_message_user_read_at':
          (lastUpdatedAt == null
                  ? lastReadAt
                  : lastUpdatedAt.isAfter(lastReadAt)
                  ? lastUpdatedAt
                  : lastReadAt)
              .toUtc()
              .toIso8601String(),
    });

    await proxyCall(
      oauth: oauth,
      method: 'POST',
      url: conversationsMarkUrl,
      headers: {...jsonHeader, ...oauth.authorizationHeaders!},
      files: null,
      body: {'channel': channelId, 'ts': (lastReadAt.microsecondsSinceEpoch / 1000000).toStringAsFixed(6)},
    );
  }

  Future<List<String>> fetchMemberIdsFromMpimIds({required OAuthEntity oauth, required List<String> mpimIds, bool? fetchLocal}) async {
    final response = await Future.wait(
      mpimIds.map(
        (mpimId) => proxyCall(
          oauth: oauth,
          method: 'GET',
          url: conversationsMembersUrl,
          headers: {...urlEncodedHeader, ...oauth.authorizationHeaders!},
          files: null,
          body: {'channel': mpimId, 'limit': 15},
        ),
      ),
    );

    return response
        .map((e) {
          if (jsonDecode(e)['members'] == null) return null;
          return jsonDecode(e)['members'];
        })
        .whereType<List<String>>()
        .expand((e) => e)
        .toSet()
        .toList();
  }

  @override
  Future<List<MessageMemberEntity>> fetchMembers({required OAuthEntity oauth, required List<String> userIds}) async {
    // Limit concurrent requests and apply backoff on Slack rate limits
    const int concurrency = 4;
    List<dynamic> responses = [];
    List<Future<dynamic>> inFlight = [];

    for (final String userId in userIds) {
      inFlight.add(
        _callWithSlackBackoff(
          () => proxyCall(
            oauth: oauth,
            method: 'GET',
            url: userId.startsWith('B') ? botsInfoUrl : usersInfoUrl,
            headers: {...urlEncodedHeader, ...oauth.authorizationHeaders!},
            files: null,
            body: userId.startsWith('B') ? {'bot': userId} : {'user': userId},
          ),
        ),
      );

      if (inFlight.length >= concurrency) {
        final batch = await Future.wait(inFlight);
        responses.addAll(batch);
        inFlight.clear();
      }
    }

    if (inFlight.isNotEmpty) {
      final batch = await Future.wait(inFlight);
      responses.addAll(batch);
    }

    return responses
        .map((e) {
          if (jsonDecode(e)['user'] == null && jsonDecode(e)['bot'] == null) return null;
          if (jsonDecode(e)['user'] != null) return MessageMemberEntity.fromSlack(member: SlackMessageMemberEntity.fromJson(jsonDecode(e)['user']));
          if (jsonDecode(e)['bot'] != null) {
            return MessageMemberEntity.fromSlack(member: SlackMessageMemberEntity.fromJson({...jsonDecode(e)['bot'], 'profile': jsonDecode(e)['bot']['icon']}));
          }
          return null;
        })
        .whereType<MessageMemberEntity>()
        .toList();
  }

  @override
  Future<List<MessageGroupEntity>> fetchGroups({required OAuthEntity oauth, required List<String> groupIds}) async {
    final response = await _callWithSlackBackoff(
      () => proxyCall(
        oauth: oauth,
        method: 'GET',
        url: usergroupsListUrl,
        headers: {...urlEncodedHeader, ...oauth.authorizationHeaders!},
        body: {'include_users': 'true'},
        files: null,
      ),
    );

    final data = jsonDecode(response)['usergroups'] as List<dynamic>?;
    if (data == null) return [];
    return data
        .map((e) {
          try {
            return MessageGroupEntity.fromSlack(group: SlackMessageGroupEntity.fromJson(e));
          } catch (e) {
            return null;
          }
        })
        .whereType<MessageGroupEntity>()
        .toList();
  }

  @override
  Future<List<MessageEmojiEntity>> fetchEmojis({required OAuthEntity oauth, required List<String> emojiIds}) async {
    final response = await _callWithSlackBackoff(
      () => proxyCall(oauth: oauth, method: 'GET', url: emojiListUrl, headers: {...urlEncodedHeader, ...oauth.authorizationHeaders!}, files: null, body: null),
    );

    final data = jsonDecode(response)['emoji'];
    if (data == null) return [];
    return data.entries
        .map((e) {
          try {
            return MessageEmojiEntity.fromSlack(emoji: SlackMessagEmojiEntity.fromJson({'name': e.key, 'value': e.value}));
          } catch (e) {
            return null;
          }
        })
        .whereType<MessageEmojiEntity>()
        .toList();
  }

  @override
  Future<MessageMemberEntity?> fetchBotInfo({required OAuthEntity oauth, required String botId}) async {
    final response = await proxyCall(
      oauth: oauth,
      method: 'GET',
      url: botsInfoUrl,
      headers: {...urlEncodedHeader, ...oauth.authorizationHeaders!},
      files: null,
      body: {'bot': botId},
    );
    if (jsonDecode(response)['bot'] == null) return null;
    dynamic data = jsonDecode(response)['bot'];
    data['is_bot'] = true;
    data['profile'] = {
      'display_name': jsonDecode(response)['bot']['name'],
      'image_32': jsonDecode(response)['bot']['icons']['image_36'],
      'image_48': jsonDecode(response)['bot']['icons']['image_48'],
      'image_72': jsonDecode(response)['bot']['icons']['image_72'],
    };

    return MessageMemberEntity.fromSlack(member: SlackMessageMemberEntity.fromJson(data));
  }

  @override
  Future<String?> getMessagePermalink({required OAuthEntity oauth, required String channelId, required MessageEntity message}) async {
    final response = await proxyCall(
      oauth: oauth,
      method: 'GET',
      url: messagePermalinkUrl,
      headers: {...urlEncodedHeader, ...oauth.authorizationHeaders!},
      files: null,
      body: {'channel': channelId, 'message_ts': message.slackMessage?.ts ?? ''},
    );
    return jsonDecode(response)['permalink'];
  }

  @override
  Future<void> attachMessageChangeListener({required OAuthEntity oauth, required UserEntity user}) async {
    await detachMessageChangeListener(oauth: oauth);
    final response = await http.post(
      Uri.parse(rtmConnectUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': user.id, 'workspaceId': oauth.teamId, 'authorizationHeaders': oauth.authorizationHeaders}),
    );

    if (response.statusCode == 200) {
      // Success
    } else if (response.statusCode != 409) {
      throw Exception('Failed to request Slack RTM connection');
    } else {
      // Already connected
    }
  }

  @override
  Future<void> detachMessageChangeListener({required OAuthEntity oauth}) async {
    // await unwatchMails(pref: pref);
  }

  @override
  Future<Map<String, List<String>>> fetchPresence({required OAuthEntity oauth}) async {
    final response = await http.get(Uri.parse(getPresenceUrl(oauth.teamId!)), headers: {'Content-Type': 'application/json'});
    return jsonDecode(response.body) as Map<String, List<String>>;
  }

  @override
  Future<List<MessageGroupEntity>?> searchGroups({required OAuthEntity oauth, required String query}) {
    // TODO: implement searchGroups
    throw UnimplementedError();
  }

  @override
  Future<List<MessageMemberEntity>?> searchMembers({required OAuthEntity oauth, required String query}) {
    // TODO: implement searchMembers
    throw UnimplementedError();
  }

  @override
  Future<List<MessageEmojiEntity>> fetchAllEmojisFromTeam({required OAuthEntity oauth}) {
    // TODO: implement fetchAllEmojisFromTeam
    throw UnimplementedError();
  }
}
