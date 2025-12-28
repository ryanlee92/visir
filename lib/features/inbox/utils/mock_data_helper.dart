import 'dart:convert';
import 'dart:math';

import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_entity.dart';
import 'package:Visir/features/chat/domain/entities/state/chat_fetch_result_entity.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_suggestion_entity.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_fetch_result_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/mail/infrastructure/models/outlook_mail_message.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/gmail/v1.dart';

class MockDataHelper {
  static Future<Map<String, MailFetchResultEntity>> getMockMails({DateTime? date, String? query, Duration? offset}) async {
    // offset이 제공되지 않으면 constants의 mailDateOffset 사용
    final finalOffset = offset ?? mailDateOffset;
    await Future.delayed(Duration(seconds: 1));
    final _label = CommonMailLabels.inbox.id;
    return Future.wait([rootBundle.loadString('assets/mock/mail/gmail/index.json'), rootBundle.loadString('assets/mock/mail/outlook/index.json')]).then((values) async {
      final gmailIds = (jsonDecode(values[0]) as List<dynamic>).map((e) => e['id'] as String).toList();
      final outlookIds = (jsonDecode(values[1]) as List<dynamic>).map((e) => e['messageIds'] as List<dynamic>).expand((e) => e).toList();
      final gmailValues = await Future.wait(gmailIds.map((e) => rootBundle.loadString('assets/mock/mail/gmail/threads/$e.json')));
      final outlookValues = await Future.wait(outlookIds.map((e) => rootBundle.loadString('assets/mock/mail/outlook/threads/$e.json')));

      // Gmail JSON timestamp 보정
      final adjustedGmailValues = gmailValues.map((gmailJson) {
        final decoded = jsonDecode(gmailJson);
        final messages = (decoded['messages'] as List<dynamic>).map((msg) {
          final adjustedMsg = Map<String, dynamic>.from(msg);
          final headers = ((adjustedMsg['payload']?['headers'] as List<dynamic>?) ?? []).map((header) {
            final adjustedHeader = Map<String, dynamic>.from(header);
            final name = (adjustedHeader['name'] as String?)?.toLowerCase();
            if (name == 'date' || name == 'received') {
              final dateStr = adjustedHeader['value'] as String?;
              if (dateStr != null) {
                DateTime? parsedDate;
                try {
                  parsedDate = DateCodec.decodeDate(dateStr);
                  if (parsedDate == null) {
                    parsedDate = DateTime.parse(dateStr);
                  }
                } catch (e) {
                  // 파싱 실패 시 원본 유지
                }
                if (parsedDate != null) {
                  final adjustedDate = parsedDate.add(finalOffset);
                  adjustedHeader['value'] = adjustedDate.toUtc().toIso8601String();
                }
              }
            }
            return adjustedHeader;
          }).toList();
          if (adjustedMsg['payload'] != null) {
            adjustedMsg['payload'] = {...adjustedMsg['payload'], 'headers': headers};
          }
          return adjustedMsg;
        }).toList();
        return jsonEncode({...decoded, 'messages': messages});
      }).toList();

      // Outlook JSON timestamp 보정
      final adjustedOutlookValues = outlookValues.map((outlookJson) {
        final decoded = jsonDecode(outlookJson);
        final receivedDateTimeStr = decoded['receivedDateTime'] as String?;
        if (receivedDateTimeStr != null) {
          try {
            final parsedDate = DateTime.parse(receivedDateTimeStr);
            final adjustedDate = parsedDate.add(finalOffset);
            decoded['receivedDateTime'] = adjustedDate.toUtc().toIso8601String();
          } catch (e) {
            // 파싱 실패 무시
          }
        }
        return jsonEncode(decoded);
      }).toList();

      final gmailThreads = adjustedGmailValues
          .map((e) => jsonDecode(e)['messages'] as List<dynamic>)
          .map((e) => e.map((e) => MailEntity.fromGmail(message: Message.fromJson(e), hostEmail: fakeUserEmail)).toList())
          .map((e) {
            // Thread의 모든 메시지 중에서 inbox label이 있는 첫 번째 메시지를 선택
            final inboxMessage = e.firstWhereOrNull((msg) => msg.labelIds?.contains(_label) == true);
            if (inboxMessage != null) {
              return inboxMessage.copyWith(threads: e);
            }
            return null;
          })
          .whereType<MailEntity>()
          .toList();
      final outlookThreadsData = adjustedOutlookValues
          .map((e) {
            final outlook = OutlookMailMessage.fromJson(jsonDecode(e));
            final labelIds = <String>[];
            if (outlook.parentFolderId == 'drafts') {
              labelIds.add(CommonMailLabels.draft.id);
            } else if (outlook.parentFolderId == 'sentitems') {
              labelIds.add(CommonMailLabels.sent.id);
            } else if (outlook.parentFolderId == 'junkemail') {
              labelIds.add(CommonMailLabels.spam.id);
            } else if (outlook.parentFolderId == 'deleteditems') {
              labelIds.add(CommonMailLabels.trash.id);
            } else if (outlook.isRead == false) {
              labelIds.add(CommonMailLabels.inbox.id);
              labelIds.add(CommonMailLabels.unread.id);
            } else if (outlook.followupFlag?.flagStatus == 'flagged') {
              labelIds.add(CommonMailLabels.inbox.id);
              labelIds.add(CommonMailLabels.pinned.id);
            } else {
              labelIds.add(CommonMailLabels.inbox.id);
            }

            return MailEntity.fromOutlook(
              message: outlook.copyWith(labelIds: labelIds),
              hostEmail: companyEmail,
            );
          })
          .whereType<MailEntity>()
          .toList();

      final threads = groupBy(outlookThreadsData, (e) => e.threadId);
      final outlookThreads = threads
          .map((key, value) => MapEntry(key, value.lastWhereOrNull((e) => e.labelIds?.contains(_label) == true)?.copyWith(threads: value)))
          .values
          .whereType<MailEntity>()
          .toList();

      // Mock 데이터 사용 시 날짜 필터링 완화 (모든 데이터 포함)
      return {
        fakeUserEmail: MailFetchResultEntity(
          messages: gmailThreads
              .where(
                (e) =>
                    e.labelIds?.contains(_label) == true &&
                    (date != null
                        ? e.date != null && DateUtils.isSameDay(e.date!, date)
                        : query != null
                        ? e.subject?.contains(query) == true || e.snippet?.contains(query) == true || e.from?.name?.contains(query) == true || e.from?.email.contains(query) == true
                        : true),
              )
              .toList(),
          nextPageToken: null,
          hasMore: false,
        ),
        companyEmail: MailFetchResultEntity(
          messages: outlookThreads
              .where(
                (e) =>
                    e.labelIds?.contains(_label) == true &&
                    (date != null
                        ? e.date != null && DateUtils.isSameDay(e.date!, date)
                        : query != null
                        ? e.subject?.contains(query) == true || e.snippet?.contains(query) == true || e.from?.name?.contains(query) == true || e.from?.email.contains(query) == true
                        : true),
              )
              .toList(),
          nextPageToken: null,
          hasMore: false,
        ),
      };
    });
  }

  static Future<ChatFetchResultEntity> getMockChats({
    DateTime? date,
    String? query,
    Duration? offset,
    required Future<Map<String, List<MessageChannelEntity>>> Function() getMockChannels,
  }) async {
    await Future.delayed(Duration(seconds: 1));
    final channelMap = await getMockChannels();
    ChatFetchResultEntity resultMessages = ChatFetchResultEntity(messages: [], nextCursor: null, hasMore: false);

    for (final key in channelMap.keys) {
      final channelsIds = channelMap[key]!.map((e) => e.id).toList();

      final results = await Future.wait(channelsIds.map((e) => rootBundle.loadString('assets/mock/chat/${key}/${e}.json')));

      // Chat JSON timestamp 보정 - offset은 MessageEntity.createdAt에서 적용하므로 여기서는 원본 유지
      // offset이 적용된 것처럼 보이도록 하기 위해 가장 최근 메시지의 timestamp를 조정
      final adjustedResults = results.map((chatJson) {
        final decoded = jsonDecode(chatJson);
        final messages = ((decoded['messages'] as List<dynamic>?) ?? []).map((msg) {
          final adjustedMsg = Map<String, dynamic>.from(msg);
          final tsStr = adjustedMsg['ts'] as String?;
          if (tsStr != null) {
            // 원본 timestamp를 그대로 유지 (offset은 MessageEntity.createdAt에서 적용)
            // tsStr은 이미 String이므로 그대로 사용
          }
          return adjustedMsg;
        }).toList();
        return jsonEncode({...decoded, 'messages': messages});
      }).toList();

      // Mock 데이터 사용 시 날짜 필터링 완화 (모든 데이터 포함)
      // 채널별로 메시지를 수집하고, 채널 메시지를 우선적으로 포함
      final List<MessageEntity> channelMessages = [];
      final List<MessageEntity> dmMessages = [];

      adjustedResults.forEach((value) {
        final index = adjustedResults.indexOf(value);
        final channelId = channelsIds[index];
        final channel = channelMap[key]!.firstWhere((c) => c.id == channelId);
        final allMessages = (jsonDecode(value)['messages'] as List<dynamic>)
            .map((e) => MessageEntity.fromSlack(message: SlackMessageEntity.fromJson({...e, 'channel': channelId, 'team': key})))
            .toList();

        final messages = allMessages.where((e) {
          final shouldInclude = (date != null
              ? e.createdAt != null && DateUtils.isSameDay(e.createdAt!, date)
              : query != null
              ? e.text?.contains(query) == true
              : true);
          return shouldInclude;
        }).toList();

        // 채널 타입에 따라 분류
        if (channel.isChannel) {
          channelMessages.addAll(messages);
        } else {
          dmMessages.addAll(messages);
        }
      });

      // 채널 메시지를 우선적으로 포함하고, DM 메시지는 최근 것만 제한
      // 채널 메시지: 최근 20개
      // DM 메시지: 최근 5개
      channelMessages.sort((a, b) => (b.createdAt ?? DateTime(1970)).compareTo(a.createdAt ?? DateTime(1970)));
      dmMessages.sort((a, b) => (b.createdAt ?? DateTime(1970)).compareTo(a.createdAt ?? DateTime(1970)));

      final limitedChannelMessages = channelMessages.take(20).toList();
      final limitedDmMessages = dmMessages.take(5).toList();

      resultMessages = resultMessages.copyWith(messages: [...limitedChannelMessages, ...limitedDmMessages]);
    }

    return resultMessages;
  }

  static Future<Map<String, List<MessageChannelEntity>>> getMockChannels() async {
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

  /// 최근 24시간 내의 inbox를 기준으로 mock suggestion을 생성합니다.
  static List<InboxSuggestionEntity> getMockSuggestions(List<InboxEntity> inboxes, {List<ProjectEntity>? projects}) {
    final now = DateTime.now();
    final twentyFourHoursAgo = now.subtract(const Duration(hours: 24));

    // 최근 24시간 내의 inbox만 필터링
    final recentInboxes = inboxes.where((inbox) {
      return inbox.inboxDatetime.isAfter(twentyFourHoursAgo) && inbox.inboxDatetime.isBefore(now.add(const Duration(minutes: 1)));
    }).toList();

    final suggestions = <InboxSuggestionEntity>[];
    final random = Random();

    // Urgency와 Reason 조합
    final urgencyReasons = [
      (InboxSuggestionUrgency.urgent, InboxSuggestionReason.meeting_invitation),
      (InboxSuggestionUrgency.urgent, InboxSuggestionReason.task_assignment),
      (InboxSuggestionUrgency.important, InboxSuggestionReason.document_review),
      (InboxSuggestionUrgency.important, InboxSuggestionReason.approval_request),
      (InboxSuggestionUrgency.action_required, InboxSuggestionReason.question),
      (InboxSuggestionUrgency.action_required, InboxSuggestionReason.scheduling_request),
      (InboxSuggestionUrgency.need_review, InboxSuggestionReason.information_sharing),
      (InboxSuggestionUrgency.need_review, InboxSuggestionReason.announcement),
    ];

    for (final inbox in recentInboxes) {
      final (urgency, reason) = urgencyReasons[random.nextInt(urgencyReasons.length)];

      // Summary 생성
      String summary = inbox.title;
      if (summary.length > 50) {
        summary = '${summary.substring(0, 47)}...';
      }

      // Sender name 추출
      String? senderName;
      if (inbox.linkedMail != null) {
        senderName = inbox.linkedMail!.fromName;
      } else if (inbox.linkedMessage != null) {
        senderName = inbox.linkedMessage!.userName;
      }

      // Target date 생성 (0-7일 후 랜덤)
      final daysFromNow = random.nextInt(8);
      DateTime? targetDate;
      bool? isDateOnly;
      if (daysFromNow == 0 && urgency == InboxSuggestionUrgency.urgent) {
        // Urgent는 오늘 또는 내일
        targetDate = DateTime.now().add(Duration(hours: random.nextInt(12) + 1));
        isDateOnly = false;
      } else if (daysFromNow > 0) {
        targetDate = DateTime.now().add(Duration(days: daysFromNow));
        isDateOnly = random.nextBool();
      }

      // Duration 생성 (30분, 1시간, 2시간 중 랜덤)
      int? duration;
      if (reason == InboxSuggestionReason.meeting_invitation || reason == InboxSuggestionReason.scheduling_request) {
        final durations = [30, 60, 120];
        duration = durations[random.nextInt(durations.length)];
      }

      // Priority score 생성 (urgency 기반)
      int priorityScore = switch (urgency) {
        InboxSuggestionUrgency.urgent => 80 + random.nextInt(20),
        InboxSuggestionUrgency.important => 60 + random.nextInt(20),
        InboxSuggestionUrgency.action_required => 40 + random.nextInt(20),
        InboxSuggestionUrgency.need_review => 20 + random.nextInt(20),
        InboxSuggestionUrgency.none => random.nextInt(20),
      };

      // Date type 결정
      InboxSuggestionDateType? dateType;
      if (targetDate != null) {
        if (reason == InboxSuggestionReason.meeting_invitation || reason == InboxSuggestionReason.scheduling_request || reason == InboxSuggestionReason.scheduling_confirmation) {
          dateType = InboxSuggestionDateType.event;
        } else if (reason == InboxSuggestionReason.task_assignment || reason == InboxSuggestionReason.document_review || reason == InboxSuggestionReason.code_review) {
          dateType = InboxSuggestionDateType.task;
        }
      }

      // Project id 할당 (projects가 있고 비어있지 않으면 랜덤하게 할당)
      String? projectId;
      if (projects != null && projects.isNotEmpty) {
        final selectedProject = projects[random.nextInt(projects.length)];
        projectId = selectedProject.uniqueId;
      }

      final suggestion = InboxSuggestionEntity(
        id: inbox.id,
        summary: summary,
        urgency: urgency,
        reason: reason,
        date_type: dateType,
        target_date: targetDate,
        duration: duration,
        is_asap: urgency == InboxSuggestionUrgency.urgent && daysFromNow == 0,
        is_date_only: isDateOnly,
        sender_name: senderName,
        priority_score: priorityScore,
        estimated_effort: duration != null ? duration : (30 + random.nextInt(90)),
        reasoned_body: 'Mock suggestion for ${inbox.title}',
        conversation_summary: inbox.description != null && inbox.description!.length > 200 ? '${inbox.description!.substring(0, 197)}...' : inbox.description,
        project_id: projectId,
      );

      suggestions.add(suggestion);
    }

    return suggestions;
  }
}
