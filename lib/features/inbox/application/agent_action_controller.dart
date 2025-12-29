import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:Visir/config/providers.dart';
import 'package:Visir/features/common/infrastructure/entities/environment.dart';
import 'package:Visir/flavors.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/application/calendar_event_list_controller.dart';
import 'package:Visir/features/calendar/application/calendar_list_controller.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_attendee_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/calendar/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/date_time_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/domain/entities/agent_model_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/application/mcp_function_executor.dart';
import 'package:Visir/features/inbox/infrastructure/repositories/inbox_repository.dart';
import 'package:Visir/features/inbox/infrastructure/repositories/agent_chat_history_repository.dart';
import 'package:Visir/features/inbox/domain/entities/agent_chat_history_entity.dart';
import 'package:Visir/features/inbox/presentation/widgets/inbox_action_suggestions_widget.dart';
import 'package:Visir/features/inbox/providers.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/mail/providers.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:Visir/features/task/application/task_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/common/domain/entities/connection_entity.dart';
import 'package:Visir/features/common/domain/failures/failure.dart';
import 'package:Visir/features/common/utils/ai_pricing_calculator.dart';
import 'package:Visir/features/auth/presentation/screens/ai_credits_screen.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'agent_action_controller.g.dart';

class AgentActionMessage {
  final String role; // 'user' or 'assistant'
  final String content;

  AgentActionMessage({required this.role, required this.content});

  Map<String, dynamic> toJson({bool? local}) {
    return {
      'role': role,
      'content': content.isNotEmpty
          ? local == true
                ? content
                : Utils.encryptAESCryptoJS(content, aesKey)
          : '',
    };
  }

  factory AgentActionMessage.fromJson(Map<String, dynamic> json, {bool? local, bool? isEncrypted}) {
    final contentStr = json['content'] as String? ?? '';
    // local이 true면 평문, false면 isEncrypted 플래그에 따라 복호화
    final decryptedContent = contentStr.isNotEmpty && local != true && (isEncrypted == true) ? Utils.decryptAESCryptoJS(contentStr, aesKey) : contentStr;

    return AgentActionMessage(role: json['role'] as String, content: decryptedContent);
  }
}

class AgentActionState {
  final AgentActionType? actionType;
  final InboxEntity? inbox;
  final TaskEntity? task;
  final EventEntity? event;
  final List<AgentActionMessage> messages;
  final bool isLoading;
  final Map<String, dynamic>? pendingTaskInfo; // Draft task information during conversation (before confirmation)
  final String? conversationSummary; // Summary of the conversation start message
  final String? sessionId; // Session ID for chat history
  final Set<int> loadedInboxNumbers; // Inbox item numbers that have been fully loaded (with full content)
  final List<Map<String, dynamic>>? pendingFunctionCalls; // Function calls waiting for user confirmation
  final Set<String> selectedActionIds; // Action IDs selected for batch confirmation

  AgentActionState({
    this.actionType,
    this.inbox,
    this.task,
    this.event,
    List<AgentActionMessage>? messages,
    this.isLoading = false,
    AgentModel? selectedModel,
    bool? useUserApiKey,
    this.pendingTaskInfo,
    this.conversationSummary,
    this.sessionId,
    Set<int>? loadedInboxNumbers,
    this.pendingFunctionCalls,
    Set<String>? selectedActionIds,
  }) : messages = messages ?? [],
       loadedInboxNumbers = loadedInboxNumbers ?? {},
       selectedActionIds = selectedActionIds ?? {};

  AgentActionState copyWith({
    AgentActionType? actionType,
    InboxEntity? inbox,
    TaskEntity? task,
    EventEntity? event,
    List<AgentActionMessage>? messages,
    bool? isLoading,
    Map<String, dynamic>? pendingTaskInfo,
    String? conversationSummary,
    String? sessionId,
    Set<int>? loadedInboxNumbers,
    List<Map<String, dynamic>>? pendingFunctionCalls,
    Set<String>? selectedActionIds,
  }) {
    return AgentActionState(
      actionType: actionType ?? this.actionType,
      inbox: inbox ?? this.inbox,
      task: task ?? this.task,
      event: event ?? this.event,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      pendingTaskInfo: pendingTaskInfo ?? this.pendingTaskInfo,
      conversationSummary: conversationSummary ?? this.conversationSummary,
      sessionId: sessionId ?? this.sessionId,
      loadedInboxNumbers: loadedInboxNumbers ?? this.loadedInboxNumbers,
      pendingFunctionCalls: pendingFunctionCalls ?? this.pendingFunctionCalls,
      selectedActionIds: selectedActionIds ?? this.selectedActionIds,
    );
  }

  bool get isEmpty {
    // If there are messages, it's not empty
    if (messages.isNotEmpty) return false;
    // Otherwise, check if all other fields are empty/null
    return actionType == null && inbox == null && task == null && event == null && isLoading == false && pendingTaskInfo == null;
  }
}

@riverpod
class AgentActionController extends _$AgentActionController {
  late InboxRepository _repository;
  late AgentChatHistoryRepository _historyRepository;

  bool get useUserApiKey => ref.watch(selectedAgentModelProvider).value?.useUserApiKey ?? false;
  AgentModel get selectedModel => ref.watch(selectedAgentModelProvider).value?.model ?? AgentModel.gpt51;

  @override
  AgentActionState build() {
    _repository = ref.watch(inboxRepositoryProvider);
    _historyRepository = ref.watch(agentChatHistoryRepositoryProvider);

    // 저장된 모델을 가져오거나 기본 모델 사용
    final savedModelDataAsync = ref.read(selectedAgentModelProvider);
    final savedModelData = savedModelDataAsync.value ?? SelectedAgentModelData(model: AgentModel.gpt4oMini, useUserApiKey: false);

    return AgentActionState(selectedModel: savedModelData.model, useUserApiKey: savedModelData.useUserApiKey);
  }

  /// 모델을 변경합니다.
  void setModel(AgentModel model, {bool? useUserApiKey}) {
    final shouldUseUserApiKey = useUserApiKey ?? false;
    ref.read(selectedAgentModelProvider.notifier).setModel(model, shouldUseUserApiKey);
  }

  /// 액션 타입을 시작하고 초기 컨텍스트를 설정합니다.
  Future<void> startAction({required AgentActionType actionType, InboxEntity? inbox, TaskEntity? task, EventEntity? event}) async {
    // 새로운 세션 ID 생성
    final sessionId = const Uuid().v4();

    final contextInfo = _buildContextInfo(actionType, inbox: inbox, task: task, event: event);

    // Reply와 Forward 타입의 경우 AI로부터 suggested response를 받아옵니다
    String initialMessage;

    // Send의 경우 to, cc, bcc, body, title을 모두 물어봐야 함
    if (actionType == AgentActionType.send) {
      state = state.copyWith(actionType: actionType, inbox: inbox, task: task, event: event, isLoading: false, sessionId: sessionId);

      // Send의 경우 모든 정보를 물어봄
      initialMessage = Utils.mainContext.tr.agent_action_send_initial_message;

      final newState = state.copyWith(
        messages: [AgentActionMessage(role: 'assistant', content: initialMessage)],
        isLoading: false,
      );
      state = newState;

      // 히스토리 저장
      _saveChatHistory();
      return;
    }

    // Forward의 경우 먼저 to/cc/bcc를 물어봐야 함
    // TODO: Forward 기능은 나중에 구현 예정
    // if (actionType == AgentActionType.forward && inbox?.linkedMail != null) {
    //   state = state.copyWith(actionType: actionType, inbox: inbox, task: task, event: event, isLoading: false);

    //   // Forward의 경우 먼저 누구에게 보낼지 물어봄
    //   initialMessage =
    //       'Who would you like to forward this email to? Please provide:\n- To recipients\n- CC recipients (optional)\n- BCC recipients (optional)\n\nYou can provide email addresses or names.';

    //   state = state.copyWith(
    //     messages: [AgentActionMessage(role: 'assistant', content: initialMessage)],
    //     isLoading: false,
    //   );
    //   return;
    // }

    if (actionType == AgentActionType.reply && inbox?.linkedMail != null) {
      state = state.copyWith(actionType: actionType, inbox: inbox, task: task, event: event, isLoading: true, sessionId: sessionId);

      final linkedMail = inbox!.linkedMail!;
      final snippet = inbox.description ?? '';

      // Fetch thread messages and original mail
      List<Map<String, dynamic>>? threadMessages;
      MailEntity? originalMail;
      final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.mailOAuths)) ?? [];
      final oauth = oauths.firstWhereOrNull((o) => o.email == linkedMail.hostMail);

      if (oauth != null) {
        final mailRepository = ref.read(mailRepositoryProvider);
        final threadResult = await mailRepository.fetchThreads(
          oauth: oauth,
          type: linkedMail.type,
          threadId: linkedMail.threadId,
          labelId: CommonMailLabels.inbox.id,
          email: linkedMail.hostMail,
        );

        await threadResult.fold(
          (failure) async {
            // Failed to fetch thread, continue with snippet only
          },
          (threadMails) async {
            // Get the original mail (first in thread or the one matching messageId)
            originalMail = threadMails.firstWhereOrNull((m) => m.id == linkedMail.messageId) ?? threadMails.firstOrNull;

            // Convert thread mails to map format for AI
            threadMessages = threadMails.map((mail) {
              final fromUser = mail.from;
              return {'from': fromUser?.name ?? fromUser?.email ?? 'Unknown', 'subject': mail.subject ?? '', 'body': mail.html ?? '', 'date': mail.date?.toIso8601String() ?? ''};
            }).toList();
          },
        );
      }

      // Extract to, cc, bcc from original mail for AI
      List<Map<String, String>> originalToList = [];
      List<Map<String, String>> originalCcList = [];
      List<Map<String, String>> originalBccList = [];
      final mail = originalMail;
      if (mail != null) {
        originalToList = mail.to.map((user) => {'email': user.email, 'name': user.name ?? ''}).toList();
        originalCcList = mail.cc.map((user) => {'email': user.email, 'name': user.name ?? ''}).toList();
        originalBccList = mail.bcc.map((user) => {'email': user.email, 'name': user.name ?? ''}).toList();
      }

      // Get sender email and name from original mail's from field
      String? senderEmail;
      String? senderName;
      if (originalMail?.from != null) {
        senderEmail = originalMail!.from!.email;
        senderName = originalMail!.from!.name;
      } else {
        // Fallback: try to parse from linkedMail.fromName if available
        // Note: linkedMail only has fromName, not email, so we use it as fallback
        senderName = linkedMail.fromName.isNotEmpty ? linkedMail.fromName : null;
      }

      // Get current user email to exclude from recipients
      final me = ref.read(authControllerProvider).value;
      final currentUserEmail = me?.email ?? '';

      // Get original mail body for language detection
      String? originalMailBody;
      if (mail != null) {
        // Use snippet or HTML body for language detection
        originalMailBody = mail.snippet ?? mail.html;
      }

      // API 키 선택: useUserApiKey가 true이면 사용자 API 키, false이면 환경 변수 API 키
      String? apiKey;
      if (useUserApiKey) {
        final apiKeys = ref.read(aiApiKeysProvider);
        apiKey = apiKeys[selectedModel.provider.name];
      }

      // 사용자 ID 가져오기 (크레딧 체크용)
      final userId = me?.id;

      final suggestedResult = await _repository.generateSuggestedReply(
        linkedMail: linkedMail,
        snippet: snippet,
        model: selectedModel.modelName,
        threadMessages: threadMessages,
        originalTo: originalToList,
        originalCc: originalCcList,
        originalBcc: originalBccList,
        senderEmail: senderEmail,
        senderName: senderName,
        currentUserEmail: currentUserEmail,
        originalMailBody: originalMailBody,
        apiKey: apiKey,
        userId: userId,
      );

      final suggestedResponse = suggestedResult.fold(
        (failure) {
          // 크레딧 부족 예외 처리
          failure.whenOrNull(
            insufficientCredits: (_, required, available) {
              // 크레딧을 토큰 수로 변환
              final requiredTokens = AiPricingCalculator.calculateTokensFromCredits(required);
              final availableTokens = AiPricingCalculator.calculateTokensFromCredits(available);
              // 크레딧 구매 화면으로 이동
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Utils.showPopupDialog(
                  child: AiCreditsScreen(
                    isSmall: true,
                    isInPrefScreen: false,
                    warning: Utils.mainContext.tr.ai_credits_insufficient_message(
                      Utils.numberFormatter(requiredTokens.toDouble(), fractionDigits: 0),
                      Utils.numberFormatter(availableTokens.toDouble(), fractionDigits: 0),
                    ),
                  ),
                  size: Size(500, 600),
                );
              });
            },
          );
          return null;
        },
        (response) {
          return response;
        },
      );

      if (suggestedResponse == null) {
        // AI response failed, use fallback
        initialMessage = Utils.mainContext.tr.agent_action_reply_initial_message('').replaceAll('{contextInfo}', '');
      } else {
        // Check if we have a valid suggested_reply
        final suggestedReplyRaw = suggestedResponse['suggested_reply'] as String?;
        if (suggestedReplyRaw != null && suggestedReplyRaw.isNotEmpty) {
          final threadSummary = suggestedResponse['thread_summary'] as String? ?? '';
          String suggestedReply = suggestedReplyRaw;

          // Get AI-determined recipients (only for initial generation)
          final aiToList =
              (suggestedResponse['to'] as List?)?.cast<Map<String, dynamic>>().map((r) => {'email': r['email'] as String? ?? '', 'name': r['name'] as String? ?? ''}).toList() ??
              [];
          final aiCcList =
              (suggestedResponse['cc'] as List?)?.cast<Map<String, dynamic>>().map((r) => {'email': r['email'] as String? ?? '', 'name': r['name'] as String? ?? ''}).toList() ??
              [];
          final aiBccList =
              (suggestedResponse['bcc'] as List?)?.cast<Map<String, dynamic>>().map((r) => {'email': r['email'] as String? ?? '', 'name': r['name'] as String? ?? ''}).toList() ??
              [];
          final suggestReplyAll = suggestedResponse['suggest_reply_all'] as bool? ?? false;

          // Get user name for reply (always use the current user's name, not the sender's name)
          final me = ref.read(authControllerProvider).value;
          String? userName;

          if (me != null && me.name != null && me.name!.isNotEmpty) {
            // Always use the current user's first name
            userName = me.name!.split(' ').first;
          }

          // Replace [Your Name] placeholder if userName is available
          if (userName != null) {
            suggestedReply = suggestedReply.replaceAll('[Your Name]', userName);
            suggestedReply = suggestedReply.replaceAll('[your name]', userName);
          }

          // Get from information (current user)
          final fromList = me != null && me.email != null
              ? [
                  {'email': linkedMail.hostMail, 'name': me.name ?? ''},
                ]
              : [];

          // Create message with separate blocks for summary and reply
          String messageText = '';
          if (threadSummary.isNotEmpty) {
            messageText += '${Utils.mainContext.tr.agent_action_email_thread_summary}\n\n<inapp_mail_summary>${jsonEncode({'summary': threadSummary})}</inapp_mail_summary>';
          }
          if (suggestedReply.isNotEmpty) {
            if (messageText.isNotEmpty) {
              messageText +=
                  '\n\n${Utils.mainContext.tr.agent_action_suggested_reply}\n\n<inapp_mail>${jsonEncode({'reply': suggestedReply, 'from': fromList, 'to': aiToList, 'cc': aiCcList, 'bcc': aiBccList, 'suggest_reply_all': suggestReplyAll})}</inapp_mail>';
            } else {
              messageText =
                  '${Utils.mainContext.tr.agent_action_suggested_reply}\n\n<inapp_mail>${jsonEncode({'reply': suggestedReply, 'from': fromList, 'to': aiToList, 'cc': aiCcList, 'bcc': aiBccList, 'suggest_reply_all': suggestReplyAll})}</inapp_mail>';
            }
            messageText += '\n\n${Utils.mainContext.tr.agent_action_send_confirmation}';
            if (suggestReplyAll) {
              messageText += '\n\n${Utils.mainContext.tr.agent_action_reply_all_suggestion}';
            }
          }

          initialMessage = messageText;
        } else {
          // AI response exists but suggested_reply is empty, use fallback
          initialMessage = Utils.mainContext.tr.agent_action_reply_initial_message('').replaceAll('{contextInfo}', '');
        }
      }

      // Update state with initial message and set loading to false
      state = state.copyWith(
        messages: [AgentActionMessage(role: 'assistant', content: initialMessage)],
        isLoading: false,
      );
    } else if (actionType == AgentActionType.createTask && inbox != null) {
      state = state.copyWith(actionType: actionType, inbox: inbox, task: task, event: event, isLoading: false, sessionId: sessionId);

      // Use suggestion entity from inbox if available
      final suggestion = inbox.suggestion;
      if (suggestion != null && suggestion.summary != null && suggestion.summary!.isNotEmpty) {
        // Create TaskEntity from InboxSuggestionEntity
        // No loading needed - suggestion is already available
        final me = ref.read(authControllerProvider).value;
        if (me == null) {
          initialMessage = _buildInitialMessage(actionType, contextInfo, inbox: inbox, task: task, event: event);
        } else {
          DateTime? startAt = suggestion.target_date ?? DateTime.now().dateOnly;
          DateTime? endAt;

          bool? isAllDay = suggestion.target_date == null ? true : suggestion.is_date_only;
          if (suggestion.duration != null && suggestion.duration! > 0) {
            endAt = startAt.add(Duration(minutes: suggestion.duration!));
          } else {
            endAt = startAt.add(isAllDay == true ? const Duration(days: 1) : const Duration(hours: 1));
          }

          final taskEntity = TaskEntity(
            id: const Uuid().v4(),
            ownerId: me.id,
            title: suggestion.summary!,
            description: inbox.description,
            projectId: suggestion.project_id,
            startAt: startAt,
            endAt: endAt,
            isAllDay: isAllDay,
            linkedMails: inbox.linkedMail != null ? [inbox.linkedMail!] : [],
            linkedMessages: inbox.linkedMessage != null ? [inbox.linkedMessage!] : [],
            createdAt: DateTime.now(),
            status: TaskStatus.none,
          );

          final taskJson = jsonEncode(taskEntity.toJson(local: true));
          final suggestedHtml = '<inapp_task>$taskJson</inapp_task>';
          initialMessage = Utils.mainContext.tr.agent_action_create_task_suggested_response(suggestedHtml);

          // Set state with initial message and no loading
          final newState = state.copyWith(
            actionType: actionType,
            inbox: inbox,
            task: task,
            event: event,
            messages: [AgentActionMessage(role: 'assistant', content: initialMessage)],
            isLoading: false,
          );
          state = newState;

          // 히스토리 저장
          _saveChatHistory();
          return;
        }
      } else {
        initialMessage = _buildInitialMessage(actionType, contextInfo, inbox: inbox, task: task, event: event);
      }
    } else if (actionType == AgentActionType.createEvent && inbox != null) {
      // Set loading state first with empty messages to show loading indicator
      state = state.copyWith(actionType: actionType, inbox: inbox, task: task, event: event, messages: [], isLoading: true, sessionId: sessionId);

      // Use suggestion entity from inbox if available
      final suggestion = inbox.suggestion;
      if (suggestion != null && suggestion.summary != null && suggestion.summary!.isNotEmpty) {
        // Use AI to generate suggested event with calendar selection
        final me = ref.read(authControllerProvider).value;
        if (me == null) {
          initialMessage = _buildInitialMessage(actionType, contextInfo, inbox: inbox, task: task, event: event);
        } else {
          final calendarMap = ref.read(calendarListControllerProvider);
          final calendarList = calendarMap.values.expand((e) => e).toList();
          final calendarsList = calendarList.map((c) => {'id': c.uniqueId, 'name': c.name, 'email': c.email, 'modifiable': c.modifiable}).toList();

          // API 키 선택: useUserApiKey가 true이면 사용자 API 키, false이면 환경 변수 API 키
          String? apiKey;
          if (useUserApiKey) {
            final apiKeys = ref.read(aiApiKeysProvider);
            apiKey = apiKeys[selectedModel.provider.name];
          }

          // Call AI to generate suggested event with calendar selection
          final suggestedResult = await _repository.generateSuggestedEvent(inbox: inbox, calendars: calendarsList, model: selectedModel.modelName, apiKey: apiKey, userId: me.id);

          final suggestedEventInfo = suggestedResult.fold((failure) {
            // 크레딧 부족 예외 처리
            failure.whenOrNull(
              insufficientCredits: (_, required, available) {
                // 크레딧 구매 화면으로 이동
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Utils.showPopupDialog(
                    child: AiCreditsScreen(
                      isSmall: true,
                      isInPrefScreen: false,
                      warning: Utils.mainContext.tr.ai_credits_insufficient_message(
                        Utils.numberFormatter(required, fractionDigits: 4),
                        Utils.numberFormatter(available, fractionDigits: 4),
                      ),
                    ),
                    size: Size(500, 600),
                  );
                });
              },
            );
            return null;
          }, (info) => info);

          // Always create suggested event, even if AI didn't return calendar_id
          String? calendarId;
          CalendarEntity? calendar;

          if (suggestedEventInfo != null && suggestedEventInfo['calendar_id'] != null) {
            calendarId = suggestedEventInfo['calendar_id'] as String;
            calendar = calendarList.firstWhereOrNull((c) => c.uniqueId == calendarId);
          }

          // Fallback: use default calendar if AI didn't select one
          if (calendar == null) {
            final lastUsedCalendarId = ref.read(lastUsedCalendarIdProvider).firstOrNull;
            final modifiableCalendars = calendarList.where((c) => c.modifiable == true).toList();
            calendar =
                modifiableCalendars.where((e) => e.uniqueId == (me.defaultCalendarId ?? lastUsedCalendarId)).toList().firstOrNull ??
                modifiableCalendars.firstOrNull ??
                calendarList.firstOrNull;
          }

          if (calendar == null) {
            initialMessage = _buildInitialMessage(actionType, contextInfo, inbox: inbox, task: task, event: event);
          } else {
            DateTime? startAt = suggestion.target_date ?? DateTime.now().dateOnly;
            DateTime? endAt;

            bool isAllDay = suggestion.target_date == null ? true : (suggestion.is_date_only ?? false);
            if (suggestion.duration != null && suggestion.duration! > 0) {
              endAt = startAt.add(Duration(minutes: suggestion.duration!));
            } else {
              endAt = startAt.add(isAllDay ? const Duration(days: 1) : const Duration(hours: 1));
            }

            final timezone = ref.read(timezoneProvider).value;

            // Parse location from AI response
            final location = suggestedEventInfo?['location'] as String?;

            // Parse attendees from AI response
            List<EventAttendeeEntity> attendees = [];
            final attendeesList = suggestedEventInfo?['attendees'] as List<dynamic>?;
            if (attendeesList != null && attendeesList.isNotEmpty) {
              attendees = attendeesList
                  .whereType<String>()
                  .map((email) => EventAttendeeEntity(email: email.trim(), responseStatus: EventAttendeeResponseStatus.needsAction))
                  .toList();
            }

            // Parse conference_link from AI response
            String? conferenceLink;
            final conferenceLinkStr = suggestedEventInfo?['conference_link'] as String?;
            if (conferenceLinkStr != null && conferenceLinkStr.isNotEmpty && conferenceLinkStr != 'null') {
              // If AI returns "added", it means a conference link should be generated
              conferenceLink = conferenceLinkStr == 'added' ? 'added' : conferenceLinkStr;
            }

            final eventEntity = EventEntity(
              calendarType: calendar.type ?? CalendarEntityType.google,
              eventId: Utils.generateBase32HexStringFromTimestamp(),
              title: suggestedEventInfo?['title'] as String? ?? suggestion.summary!,
              description: suggestedEventInfo?['description'] as String? ?? inbox.description, // AI가 summarize한 description
              rrule: null,
              location: location, // AI가 추출한 location
              isAllDay: isAllDay,
              startDate: startAt,
              endDate: isAllDay ? startAt.dateOnly : endAt,
              timezone: timezone,
              attendees: attendees, // AI가 추출한 attendees
              reminders: isAllDay ? [] : (calendar.defaultReminders ?? []),
              attachments: [],
              conferenceLink: conferenceLink, // AI가 초기에 판단한 컨퍼런스 콜
              modifiedEvent: null,
              calendar: calendar,
              sequence: 1,
            );

            final eventJson = jsonEncode({
              'id': eventEntity.eventId,
              'title': eventEntity.title,
              'description': eventEntity.description,
              'calendar_id': eventEntity.calendar.uniqueId,
              'start_at': eventEntity.startDate.toIso8601String(),
              'end_at': eventEntity.endDate.toIso8601String(),
              'location': eventEntity.location,
              'rrule': eventEntity.rrule?.toString(),
              'attendees': eventEntity.attendees.map((a) => a.email).whereType<String>().toList(),
              'conference_link': eventEntity.conferenceLink,
              'isAllDay': eventEntity.isAllDay,
            });
            final suggestedHtml = '<inapp_event>$eventJson</inapp_event>';
            initialMessage = Utils.mainContext.tr.agent_action_create_task_suggested_response(suggestedHtml).replaceAll('task', 'event').replaceAll('Task', 'Event');
          }
        }
      } else {
        initialMessage = _buildInitialMessage(actionType, contextInfo, inbox: inbox, task: task, event: event);
      }

      // Update state with initial message and set loading to false
      final newState = state.copyWith(
        messages: [AgentActionMessage(role: 'assistant', content: initialMessage)],
        isLoading: false,
      );
      state = newState;

      // 히스토리 저장
      _saveChatHistory();
    } else {
      state = state.copyWith(actionType: actionType, inbox: inbox, task: task, event: event, isLoading: false, sessionId: sessionId);

      initialMessage = _buildInitialMessage(actionType, contextInfo, inbox: inbox, task: task, event: event);

      final newState = state.copyWith(
        actionType: actionType,
        inbox: inbox,
        task: task,
        event: event,
        messages: [AgentActionMessage(role: 'assistant', content: initialMessage)],
        isLoading: false,
      );
      state = newState;

      // 히스토리 저장
      _saveChatHistory();
    }
  }

  /// agentAction이 없을 때 메시지를 처리합니다.
  /// 메시지 내용을 분석하여 agent action을 감지하거나 일반적인 AI 챗을 진행합니다.
  Future<void> handleMessageWithoutAction(
    String userMessage, {
    ProjectEntity? selectedProject,
    List<InboxEntity>? inboxes,
    List<TaskEntity>? taggedTasks,
    List<EventEntity>? taggedEvents,
    List<ConnectionEntity>? taggedConnections,
    List<MessageChannelEntity>? taggedChannels,
    List<ProjectEntity>? taggedProjects,
  }) async {
    if (userMessage.trim().isEmpty) return;

    // 태그된 항목들을 HTML 태그로 감싸서 메시지에 포함
    final messageWithTags = _buildMessageWithTaggedItems(
      userMessage: userMessage,
      taggedTasks: taggedTasks,
      taggedEvents: taggedEvents,
      taggedConnections: taggedConnections,
      taggedChannels: taggedChannels,
      taggedProjects: taggedProjects,
    );

    // 사용자 메시지 추가 (기존 대화 흐름 유지)
    final updatedMessages = [...state.messages, AgentActionMessage(role: 'user', content: messageWithTags)];
    state = state.copyWith(messages: updatedMessages, isLoading: true);

    try {
      // MCP 함수 호출을 통한 일반적인 AI 챗 진행
      await _generateGeneralChat(
        userMessage,
        selectedProject: selectedProject,
        updatedMessages: updatedMessages,
        taggedTasks: taggedTasks,
        taggedEvents: taggedEvents,
        taggedConnections: taggedConnections,
        taggedChannels: taggedChannels,
        taggedProjects: taggedProjects,
        inboxes: inboxes,
      );
    } catch (e) {
      state = state.copyWith(messages: updatedMessages, isLoading: false);
    }
  }

  /// 일반적인 AI 챗을 진행합니다.
  Future<void> _generateGeneralChat(
    String userMessage, {
    ProjectEntity? selectedProject,
    List<AgentActionMessage>? updatedMessages,
    List<TaskEntity>? taggedTasks,
    List<EventEntity>? taggedEvents,
    List<ConnectionEntity>? taggedConnections,
    List<MessageChannelEntity>? taggedChannels,
    List<ProjectEntity>? taggedProjects,
    List<InboxEntity>? inboxes,
  }) async {
    // updatedMessages가 제공되지 않으면 새로 생성
    final messages = updatedMessages ?? [...state.messages, AgentActionMessage(role: 'user', content: userMessage)];

    // 사용자 질문에서 특정 sender나 키워드를 언급했는지 확인하여 자동으로 로드할 inbox 찾기
    Set<int> autoDetectedFromUserQuery = {};
    if (inboxes != null && inboxes.isNotEmpty) {
      autoDetectedFromUserQuery = _detectInboxesFromUserQuery(userMessage, inboxes);

      // 자동 감지된 inbox가 있으면 state에 저장
      if (autoDetectedFromUserQuery.isNotEmpty) {
        final updatedLoadedNumbers = {...state.loadedInboxNumbers, ...autoDetectedFromUserQuery};
        state = state.copyWith(loadedInboxNumbers: updatedLoadedNumbers);
      }
    }

    // state.messages를 항상 업데이트하여 _saveChatHistory가 최신 메시지를 사용하도록 함
    state = state.copyWith(messages: messages, isLoading: true);

    try {
      // 첫 메시지인지 확인 (user 메시지 1개만 있는 경우)
      final isFirstMessage = messages.length == 1 && messages.first.role == 'user';

      // Project context 가져오기
      final projectContext = await _buildProjectContext(selectedProject);

      // 태그된 항목들을 컨텍스트로 제공
      final taggedContext = _buildTaggedContext(taggedTasks: taggedTasks, taggedEvents: taggedEvents, taggedConnections: taggedConnections);

      // 태그된 채널의 메시지 가져오기 (최근 3일)
      String? channelContext;
      if (taggedChannels != null && taggedChannels.isNotEmpty) {
        channelContext = await _buildChannelContext(taggedChannels);
      }

      // 인박스 컨텍스트 가져오기
      // 사용자 질문에서 자동 감지된 inbox가 있으면 첫 요청부터 전체 내용 포함
      String? inboxContext;
      if (inboxes != null && inboxes.isNotEmpty) {
        final requestedNumbers = state.loadedInboxNumbers;
        final summaryOnly = requestedNumbers.isEmpty;
        inboxContext = _buildInboxContext(inboxes, summaryOnly: summaryOnly, requestedInboxNumbers: requestedNumbers);
      }

      // API 키 선택: useUserApiKey가 true이면 사용자 API 키, false이면 환경 변수 API 키
      String? apiKey;
      if (useUserApiKey) {
        final apiKeys = ref.read(aiApiKeysProvider);
        apiKey = apiKeys[selectedModel.provider.name];
      } else {
        // 환경 변수에서 가져오기 (datasource와 동일한 방식)
        try {
          final configFile = await rootBundle.loadString('assets/config/${F.envFileName}');
          final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);
          apiKey = env.openAiApiKey.isNotEmpty ? env.openAiApiKey : null;
        } catch (e) {
          // 환경 변수 읽기 실패
        }
      }

      // 사용자 ID 가져오기 (크레딧 체크용)
      final me = ref.read(authControllerProvider).value;
      final userId = me?.id;

      // 사용자 API 키를 사용하지 않는 경우 크레딧 사전 체크
      if (!useUserApiKey && userId != null && me != null) {
        // 예상 토큰 수 계산
        int estimatedPromptTokens = userMessage.length ~/ 3;
        for (final msg in messages) {
          estimatedPromptTokens += msg.content.length ~/ 3;
        }
        if (projectContext.isNotEmpty) estimatedPromptTokens += projectContext.length ~/ 3;
        if (taggedContext.isNotEmpty) estimatedPromptTokens += taggedContext.length ~/ 3;
        if (channelContext != null && channelContext.isNotEmpty) estimatedPromptTokens += channelContext.length ~/ 3;
        if (inboxContext != null && inboxContext.isNotEmpty) estimatedPromptTokens += inboxContext.length ~/ 3;
        estimatedPromptTokens = estimatedPromptTokens < 100 ? 100 : estimatedPromptTokens;

        // 예상 크레딧 비용 계산
        final estimatedCreditsCost = AiPricingCalculator.calculateCreditsCostFromModel(
          promptTokens: estimatedPromptTokens,
          completionTokens: 500, // 기본 예상 출력 토큰
          model: selectedModel,
        );

        // UserEntity의 크레딧과 비교
        final currentCredits = me.userAiCredits;
        if (currentCredits < estimatedCreditsCost) {
          // 크레딧을 토큰 수로 변환
          final requiredTokens = AiPricingCalculator.calculateTokensFromCredits(estimatedCreditsCost);
          final availableTokens = AiPricingCalculator.calculateTokensFromCredits(currentCredits);
          // 크레딧 부족 - 구매 팝업 표시
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Utils.showPopupDialog(
              child: AiCreditsScreen(
                isSmall: true,
                isInPrefScreen: false,
                warning: Utils.mainContext.tr.ai_credits_insufficient_message(
                  Utils.numberFormatter(requiredTokens.toDouble(), fractionDigits: 0),
                  Utils.numberFormatter(availableTokens.toDouble(), fractionDigits: 0),
                ),
              ),
              size: Size(500, 600),
            );
          });
          // 메시지 전송 중단
          state = state.copyWith(isLoading: false);
          return;
        }
      }

      // System prompt 가져오기
      final systemPromptProvider = ref.read(agentSystemPromptProvider);
      String systemPrompt = systemPromptProvider is String ? systemPromptProvider : '';

      // 첫 메시지이고 conversationSummary가 없으면 제목 생성 요청 추가
      if (isFirstMessage && state.conversationSummary == null && state.actionType == null) {
        systemPrompt +=
            '\n\n## Important: This is the first message in the conversation. Please include a conversation title at the very beginning of your response in the following format:\n<conversation_title>Title here (max 30 characters)</conversation_title>\nThen provide your normal response.';
      }

      // 일반적인 AI 응답 생성 (MCP 함수 호출 지원)
      // AI에 전달할 때는 평문이어야 하므로 local: true 사용
      final response = await _repository.generateGeneralChat(
        userMessage: userMessage,
        conversationHistory: messages.map((m) => m.toJson(local: true)).toList(),
        projectContext: projectContext,
        taggedContext: taggedContext.isNotEmpty ? taggedContext : null,
        channelContext: channelContext,
        inboxContext: inboxContext,
        model: selectedModel.modelName,
        apiKey: apiKey,
        userId: userId,
        systemPrompt: systemPrompt,
      );

      final aiResponse = response.fold((failure) {
        // 크레딧 부족 예외 처리
        failure.whenOrNull(
          insufficientCredits: (_, required, available) {
            // 크레딧을 토큰 수로 변환
            final requiredTokens = AiPricingCalculator.calculateTokensFromCredits(required);
            final availableTokens = AiPricingCalculator.calculateTokensFromCredits(available);
            // 크레딧 구매 화면으로 이동
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Utils.showPopupDialog(
                child: AiCreditsScreen(
                  isSmall: true,
                  isInPrefScreen: false,
                  warning: Utils.mainContext.tr.ai_credits_insufficient_message(
                    Utils.numberFormatter(requiredTokens.toDouble(), fractionDigits: 0),
                    Utils.numberFormatter(availableTokens.toDouble(), fractionDigits: 0),
                  ),
                ),
                size: Size(500, 600),
              );
            });
          },
        );
        return null;
      }, (response) => response);

      if (aiResponse != null && aiResponse['message'] != null) {
        var aiMessage = aiResponse['message'] as String;

        // 첫 메시지인 경우 응답에서 제목 추출
        if (isFirstMessage && state.conversationSummary == null && state.actionType == null) {
          final titleMatch = RegExp(r'<conversation_title>(.*?)</conversation_title>', dotAll: true).firstMatch(aiMessage);
          if (titleMatch != null) {
            final extractedTitle = titleMatch.group(1)?.trim() ?? '';
            if (extractedTitle.isNotEmpty) {
              String finalTitle = extractedTitle;
              if (finalTitle.length > 50) {
                finalTitle = '${finalTitle.substring(0, 47)}...';
              }
              state = state.copyWith(conversationSummary: finalTitle);
              // 응답에서 제목 태그 제거
              aiMessage = aiMessage.replaceAll(RegExp(r'<conversation_title>.*?</conversation_title>', dotAll: true), '').trim();
            }
          }
        }

        // MCP 함수 호출 감지 및 실행
        final executor = McpFunctionExecutor(ref);
        final functionCalls = executor.parseFunctionCalls(aiMessage);

        if (functionCalls.isNotEmpty) {
          // 여러 개의 함수 호출이 감지되면 순차적으로 실행
          // availableInboxes는 state.inbox가 있으면 그것을 사용하고, 없으면 전달받은 inboxes 사용
          final availableInboxes = state.inbox != null ? [state.inbox!] : inboxes;
          final me = ref.read(authControllerProvider).value;
          final remainingCredits = me?.userAiCredits ?? 0.0;

          final results = <Map<String, dynamic>>[];
          final successMessages = <String>[];
          final errorMessages = <String>[];

          // 검색 결과를 저장할 변수들
          var updatedTaggedTasks = taggedTasks;
          var updatedTaggedEvents = taggedEvents;
          var updatedAvailableInboxes = availableInboxes;
          var updatedLoadedInboxNumbers = state.loadedInboxNumbers;

          // 확인이 필요한 함수 목록 (DB 쓰기, 전송, 삭제, 수정 등)
          final functionsRequiringConfirmation = {
            // 전송 관련
            'sendMail',
            'replyMail',
            'forwardMail',
            // 삭제 관련
            'deleteTask',
            'deleteEvent',
            'deleteMail',
            // 수정 관련
            'updateTask',
            'updateEvent',
            // 상태 변경
            'markMailAsRead',
            'markMailAsUnread',
            'archiveMail',
            'responseCalendarInvitation',
            // 생성 (DB에 쓰는 작업)
            'createTask',
            'createEvent',
          };

          // 함수 호출을 의존성에 따라 그룹화
          final executionGroups = _groupFunctionCalls(functionCalls);

          // 각 그룹을 순차적으로 실행 (그룹 내부는 병렬 실행)
          for (final group in executionGroups) {
            // 그룹 내부 함수들을 병렬로 실행
            final groupResults = await Future.wait(
              group.map((functionCall) async {
                final functionName = functionCall['function'] as String;
                var functionArgs = functionCall['arguments'] as Map<String, dynamic>;

                // 태그된 항목들을 자동으로 파라미터에 추가
                functionArgs = _enrichFunctionArgsWithTaggedItems(
                  functionName: functionName,
                  args: functionArgs,
                  taggedTasks: updatedTaggedTasks,
                  taggedEvents: updatedTaggedEvents,
                  taggedConnections: taggedConnections,
                  availableInboxes: updatedAvailableInboxes,
                );

                // 크레딧 정보를 함수 인자에 추가하여 크레딧을 넘기는 작업 방지
                functionArgs['_remaining_credits'] = remainingCredits;

                // 확인이 필요한 함수인지 체크
                final requiresConfirmation = functionsRequiringConfirmation.contains(functionName);

                if (requiresConfirmation) {
                  // 확인이 필요한 함수는 실행하지 않고 pendingFunctionCalls에 저장
                  // actionId 생성
                  final actionId = const Uuid().v4();

                  // pendingFunctionCalls에 추가
                  final pendingCalls = state.pendingFunctionCalls ?? [];
                  pendingCalls.add({
                    'action_id': actionId,
                    'function_name': functionName,
                    'function_args': functionArgs,
                    'index': functionCalls.indexOf(functionCall),
                    'updated_tagged_tasks': updatedTaggedTasks,
                    'updated_tagged_events': updatedTaggedEvents,
                    'tagged_connections': taggedConnections,
                    'updated_available_inboxes': updatedAvailableInboxes,
                    'remaining_credits': remainingCredits,
                  });

                  state = state.copyWith(pendingFunctionCalls: pendingCalls);

                  // 확인이 필요한 함수는 null 반환 (나중에 처리)
                  return null;
                }

                // 함수 실행
                final result = await executor.executeFunction(
                  functionName,
                  functionArgs,
                  tabType: TabType.home,
                  availableTasks: updatedTaggedTasks,
                  availableEvents: updatedTaggedEvents,
                  availableConnections: taggedConnections,
                  availableInboxes: updatedAvailableInboxes,
                  remainingCredits: remainingCredits,
                );

                return {'functionCall': functionCall, 'result': result, 'functionName': functionName};
              }),
            );

            // 그룹 결과 처리
            for (final groupResult in groupResults) {
              if (groupResult == null) {
                // 확인이 필요한 함수는 이미 pendingFunctionCalls에 추가됨
                continue;
              }

              final result = groupResult['result'] as Map<String, dynamic>;
              final functionName = groupResult['functionName'] as String;

              results.add(result);

              // 검색 함수 결과 처리
              if (result['success'] == true && result['results'] != null) {
                final searchResults = result['results'] as List<dynamic>?;

                if (functionName == 'searchInbox' && searchResults != null) {
                  // 검색된 inbox 처리
                  final searchResultInboxes = <InboxEntity>[];
                  final searchResultNumbers = <int>{};

                  for (final resultItem in searchResults) {
                    if (resultItem is Map<String, dynamic>) {
                      final inboxId = resultItem['id'] as String?;
                      final inboxNumber = resultItem['number'] as int?;

                      if (inboxId != null) {
                        // 기존 inboxes에서 찾기
                        final foundInbox = updatedAvailableInboxes?.firstWhereOrNull((inbox) => inbox.id == inboxId);

                        if (foundInbox != null) {
                          searchResultInboxes.add(foundInbox);
                          if (inboxNumber != null) {
                            searchResultNumbers.add(inboxNumber);
                          }
                        }
                      }
                    }
                  }

                  // 검색된 inbox를 availableInboxes에 추가 (중복 제거)
                  if (searchResultInboxes.isNotEmpty) {
                    final existingIds = updatedAvailableInboxes?.map((e) => e.id).toSet() ?? {};
                    final newInboxes = searchResultInboxes.where((e) => !existingIds.contains(e.id)).toList();
                    updatedAvailableInboxes = [...(updatedAvailableInboxes ?? []), ...newInboxes];
                    updatedLoadedInboxNumbers = {...updatedLoadedInboxNumbers, ...searchResultNumbers};
                  }
                } else if (functionName == 'searchTask' && searchResults != null) {
                  // 검색된 task 처리
                  final searchResultTasks = <TaskEntity>[];

                  for (final resultItem in searchResults) {
                    if (resultItem is Map<String, dynamic>) {
                      final taskId = resultItem['id'] as String?;

                      if (taskId != null) {
                        // task_list_controller에서 찾기
                        final allTasks = ref.read(taskListControllerProvider).tasks;
                        final foundTask = allTasks.firstWhereOrNull((task) => task.id == taskId);

                        if (foundTask != null && !foundTask.isEventDummyTask) {
                          searchResultTasks.add(foundTask);
                        }
                      }
                    }
                  }

                  // 검색된 task를 taggedTasks에 추가 (중복 제거)
                  if (searchResultTasks.isNotEmpty) {
                    final existingIds = updatedTaggedTasks?.map((e) => e.id).toSet() ?? {};
                    final newTasks = searchResultTasks.where((e) => !existingIds.contains(e.id)).toList();
                    updatedTaggedTasks = [...(updatedTaggedTasks ?? []), ...newTasks];
                  }
                } else if (functionName == 'searchCalendarEvent' && searchResults != null) {
                  // 검색된 event 처리
                  final searchResultEvents = <EventEntity>[];

                  for (final resultItem in searchResults) {
                    if (resultItem is Map<String, dynamic>) {
                      final eventId = resultItem['id'] as String?;
                      final uniqueId = resultItem['uniqueId'] as String?;

                      if (eventId != null || uniqueId != null) {
                        // calendar_event_list_controller에서 찾기
                        final allEvents = ref.read(calendarEventListControllerProvider(tabType: TabType.home)).eventsOnView;
                        final foundEvent = allEvents.firstWhereOrNull((event) => event.eventId == eventId || event.uniqueId == uniqueId);

                        if (foundEvent != null) {
                          searchResultEvents.add(foundEvent);
                        }
                      }
                    }
                  }

                  // 검색된 event를 taggedEvents에 추가 (중복 제거)
                  if (searchResultEvents.isNotEmpty) {
                    final existingIds = updatedTaggedEvents?.map((e) => e.uniqueId).toSet() ?? {};
                    final newEvents = searchResultEvents.where((e) => !existingIds.contains(e.uniqueId)).toList();
                    updatedTaggedEvents = [...(updatedTaggedEvents ?? []), ...newEvents];
                  }
                }

                final successMessage = result['message'] as String? ?? '작업이 완료되었습니다.';
                successMessages.add(successMessage);
              } else if (result['success'] == true) {
                final successMessage = result['message'] as String? ?? '작업이 완료되었습니다.';
                successMessages.add(successMessage);
              } else {
                final errorMessage = result['error'] as String? ?? '작업 실행 중 오류가 발생했습니다.';
                errorMessages.add('$functionName: $errorMessage');
              }
            }
          }

          // 검색 결과가 있으면 state 업데이트
          if (updatedLoadedInboxNumbers != state.loadedInboxNumbers || updatedTaggedTasks != taggedTasks || updatedTaggedEvents != taggedEvents) {
            state = state.copyWith(loadedInboxNumbers: updatedLoadedInboxNumbers);
          }

          // 확인이 필요한 함수 호출이 있는지 확인
          final pendingCalls = state.pendingFunctionCalls ?? [];
          final hasPendingCalls = pendingCalls.isNotEmpty;

          // 결과 메시지 생성
          // chain인 경우 (함수가 2개 이상): 중간 메시지는 간단하게, 마지막 메시지만 전체 포함
          final isChain = functionCalls.length > 1;
          String resultMessage;

          if (errorMessages.isEmpty) {
            // 모든 함수가 성공한 경우
            if (successMessages.length == 1) {
              resultMessage = successMessages.first;
            } else if (isChain) {
              // chain인 경우: 마지막 함수의 메시지만 사용 (사용자 입력 요청이 포함될 수 있음)
              resultMessage = successMessages.last;
            } else {
              // 여러 함수지만 chain이 아닌 경우: 모든 메시지 포함
              resultMessage = '${successMessages.length}개의 작업이 완료되었습니다:\n${successMessages.map((m) => '• $m').join('\n')}';
            }
          } else if (successMessages.isEmpty) {
            // 모든 함수가 실패한 경우
            resultMessage = '작업 실행 중 오류가 발생했습니다:\n${errorMessages.map((m) => '• $m').join('\n')}';
          } else {
            // 일부 성공, 일부 실패
            if (isChain) {
              // chain인 경우: 마지막 함수의 결과만 사용
              // 성공한 함수가 있으면 마지막 성공 메시지 사용, 없으면 에러 메시지
              resultMessage = successMessages.isNotEmpty ? successMessages.last : '작업 실행 중 오류가 발생했습니다:\n${errorMessages.map((m) => '• $m').join('\n')}';
            } else {
              // chain이 아닌 경우: 모든 메시지 포함
              resultMessage = '일부 작업이 완료되었습니다:\n';
              if (successMessages.isNotEmpty) {
                resultMessage += '성공:\n${successMessages.map((m) => '• $m').join('\n')}\n';
              }
              if (errorMessages.isNotEmpty) {
                resultMessage += '실패:\n${errorMessages.map((m) => '• $m').join('\n')}';
              }
            }
          }

          // 확인이 필요한 함수 호출이 있으면 inapp_action_confirm 태그 추가
          if (hasPendingCalls) {
            // 각 pending call에 대해 inapp_action_confirm 태그 추가
            for (final pendingCall in pendingCalls) {
              final actionId = pendingCall['action_id'] as String;
              final functionName = pendingCall['function_name'] as String;
              final functionArgs = pendingCall['function_args'] as Map<String, dynamic>;

              final confirmTag =
                  '<inapp_action_confirm>${jsonEncode({'action_id': actionId, 'function_name': functionName, 'function_args': functionArgs})}</inapp_action_confirm>';

              resultMessage += '\n\n$confirmTag';
            }
          }

          final assistantMessage = AgentActionMessage(role: 'assistant', content: resultMessage);
          final updatedMessagesWithResponse = [...messages, assistantMessage];

          // 검색 결과가 있으면 다음 AI 요청에 포함되도록 재요청
          final hasSearchResults = updatedLoadedInboxNumbers != state.loadedInboxNumbers || updatedTaggedTasks != taggedTasks || updatedTaggedEvents != taggedEvents;

          if (hasSearchResults) {
            // 검색 결과를 포함하여 재요청
            state = state.copyWith(messages: updatedMessagesWithResponse, loadedInboxNumbers: updatedLoadedInboxNumbers, isLoading: false);

            // 재요청 (같은 사용자 메시지로, 검색 결과 포함)
            await _generateGeneralChat(
              userMessage,
              selectedProject: selectedProject,
              updatedMessages: updatedMessagesWithResponse,
              taggedTasks: updatedTaggedTasks,
              taggedEvents: updatedTaggedEvents,
              taggedConnections: taggedConnections,
              taggedChannels: taggedChannels,
              taggedProjects: taggedProjects,
              inboxes: updatedAvailableInboxes,
            );
            return;
          }

          state = state.copyWith(messages: updatedMessagesWithResponse, isLoading: false);

          // 첫 메시지인 경우 (user + assistant만 있는 경우) 제목 생성
          if (state.conversationSummary == null && updatedMessagesWithResponse.length == 2) {
            if (state.actionType != null) {
              // actionType이 있으면 buildActionButtonText의 텍스트를 저장
              await _generateTitleFromActionType();
            } else {
              // actionType이 없으면 AI를 통해 제목 생성
              await _generateConversationTitle(userMessage, resultMessage, apiKey: apiKey);
            }
            // 제목 생성 후 다시 히스토리 저장 (제목이 포함되도록)
            await _saveChatHistory(taggedProjects: taggedProjects);
          } else {
            // 히스토리 저장
            _saveChatHistory(taggedProjects: taggedProjects);
          }
        } else {
          // 일반 응답
          // AI 응답에서 need_more_action 태그 제거 (사용자에게는 표시하지 않음)
          final cleanedAiMessage = aiMessage.replaceAll(RegExp(r'<need_more_action>.*?</need_more_action>', dotAll: true), '').trim();
          final assistantMessage = AgentActionMessage(role: 'assistant', content: cleanedAiMessage);
          final updatedMessagesWithResponse = [...messages, assistantMessage];

          // AI 응답에서 need_more_action 태그 파싱
          final needMoreActionData = _parseNeedMoreActionTag(aiMessage);

          if (needMoreActionData != null && inboxes != null && inboxes.isNotEmpty) {
            // 태그에서 inbox 번호 추출
            Set<int> allRequestedNumbers = needMoreActionData['inbox_numbers'] as Set<int>? ?? {};

            // 번호가 없으면 사용자 메시지에서 자동 감지 시도
            if (allRequestedNumbers.isEmpty) {
              allRequestedNumbers = _detectInboxesFromUserQuery(userMessage, inboxes);
            }

            if (allRequestedNumbers.isNotEmpty) {
              // 요청된 inbox 번호가 유효한지 확인 (1부터 inboxes.length까지)
              final validNumbers = allRequestedNumbers.where((num) => num > 0 && num <= inboxes.length).toSet();

              // 이미 로드한 inbox는 제외
              final newNumbers = validNumbers.difference(state.loadedInboxNumbers);

              if (newNumbers.isNotEmpty) {
                // 요청된 inbox의 전체 내용을 포함하여 재요청
                final updatedLoadedNumbers = {...state.loadedInboxNumbers, ...newNumbers};
                state = state.copyWith(messages: updatedMessagesWithResponse, loadedInboxNumbers: updatedLoadedNumbers, isLoading: false);

                // 재요청 (같은 사용자 메시지로, _generateGeneralChat 직접 호출)
                await _generateGeneralChat(
                  userMessage,
                  selectedProject: selectedProject,
                  updatedMessages: updatedMessagesWithResponse,
                  taggedTasks: taggedTasks,
                  taggedEvents: taggedEvents,
                  taggedConnections: taggedConnections,
                  taggedChannels: taggedChannels,
                  taggedProjects: taggedProjects,
                  inboxes: inboxes, // 같은 인박스 목록 사용 (전체 내용 포함)
                );
                return;
              }
            }
          }

          state = state.copyWith(messages: updatedMessagesWithResponse, isLoading: false);

          // 첫 메시지이고 actionType이 있으면 제목 생성
          if (state.conversationSummary == null && updatedMessagesWithResponse.length == 2 && state.actionType != null) {
            await _generateTitleFromActionType();
            // 제목 생성 후 다시 히스토리 저장 (제목이 포함되도록)
            await _saveChatHistory(taggedProjects: taggedProjects);
          } else {
            // 히스토리 저장 (제목은 이미 응답에서 추출되었거나 actionType에서 생성됨)
            _saveChatHistory(taggedProjects: taggedProjects);
          }
        }
      } else {
        state = state.copyWith(messages: messages, isLoading: false);
        // 히스토리 저장
        _saveChatHistory(taggedProjects: taggedProjects);
      }
    } catch (e) {
      // 크레딧 부족 예외 처리
      if (e is Failure) {
        e.whenOrNull(
          insufficientCredits: (_, required, available) {
            // 크레딧을 토큰 수로 변환
            final requiredTokens = AiPricingCalculator.calculateTokensFromCredits(required);
            final availableTokens = AiPricingCalculator.calculateTokensFromCredits(available);
            // 크레딧 구매 화면으로 이동
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Utils.showPopupDialog(
                child: AiCreditsScreen(
                  isSmall: true,
                  isInPrefScreen: false,
                  warning: Utils.mainContext.tr.ai_credits_insufficient_message(
                    Utils.numberFormatter(requiredTokens.toDouble(), fractionDigits: 0),
                    Utils.numberFormatter(availableTokens.toDouble(), fractionDigits: 0),
                  ),
                ),
                size: Size(500, 600),
              );
            });
          },
        );
      }
      state = state.copyWith(messages: messages, isLoading: false);
    }
  }

  /// 태그된 항목들을 HTML 태그로 감싸서 메시지에 포함합니다.
  String _buildMessageWithTaggedItems({
    required String userMessage,
    List<TaskEntity>? taggedTasks,
    List<EventEntity>? taggedEvents,
    List<ConnectionEntity>? taggedConnections,
    List<MessageChannelEntity>? taggedChannels,
    List<ProjectEntity>? taggedProjects,
  }) {
    final buffer = StringBuffer();
    buffer.write(userMessage);

    // 태그된 항목들을 HTML 태그로 추가
    if (taggedTasks != null && taggedTasks.isNotEmpty) {
      for (final task in taggedTasks) {
        final taskJson = jsonEncode(task.toJson(local: true));
        buffer.write('<tagged_task>$taskJson</tagged_task>');
      }
    }

    if (taggedEvents != null && taggedEvents.isNotEmpty) {
      for (final event in taggedEvents) {
        final eventJson = jsonEncode({
          'id': event.eventId,
          'title': event.title,
          'description': event.description,
          'calendar_id': event.calendar.uniqueId,
          'start_at': event.startDate.toIso8601String(),
          'end_at': event.endDate.toIso8601String(),
          'location': event.location,
          'rrule': event.rrule?.toString(),
          'attendees': event.attendees.map((a) => a.email).whereType<String>().toList(),
          'conference_link': event.conferenceLink,
          'isAllDay': event.isAllDay,
        });
        buffer.write('<tagged_event>$eventJson</tagged_event>');
      }
    }

    if (taggedConnections != null && taggedConnections.isNotEmpty) {
      for (final connection in taggedConnections) {
        final connectionJson = jsonEncode({'name': connection.name, 'email': connection.email});
        buffer.write('<tagged_connection>$connectionJson</tagged_connection>');
      }
    }

    if (taggedChannels != null && taggedChannels.isNotEmpty) {
      for (final channel in taggedChannels) {
        final channelJson = jsonEncode({'id': channel.id, 'name': channel.name, 'teamId': channel.teamId});
        buffer.write('<tagged_channel>$channelJson</tagged_channel>');
      }
    }

    if (taggedProjects != null && taggedProjects.isNotEmpty) {
      for (final project in taggedProjects) {
        final projectJson = jsonEncode({'id': project.uniqueId, 'name': project.name});
        buffer.write('<tagged_project>$projectJson</tagged_project>');
      }
    }

    return buffer.toString();
  }

  /// 태그된 항목들을 컨텍스트 문자열로 변환합니다.
  String _buildTaggedContext({
    List<TaskEntity>? taggedTasks,
    List<EventEntity>? taggedEvents,
    List<ConnectionEntity>? taggedConnections,
    List<MessageChannelEntity>? taggedChannels,
    List<ProjectEntity>? taggedProjects,
  }) {
    final buffer = StringBuffer();

    if (taggedTasks != null && taggedTasks.isNotEmpty) {
      buffer.writeln('## Tagged Tasks');
      for (final task in taggedTasks) {
        buffer.writeln('- Task ID: ${task.id}');
        buffer.writeln('  Title: ${task.title ?? 'Untitled'}');
        if (task.description != null && task.description!.isNotEmpty) {
          buffer.writeln('  Description: ${task.description}');
        }
        if (task.startAt != null) {
          buffer.writeln('  Start: ${task.startAt}');
        }
        if (task.endAt != null) {
          buffer.writeln('  End: ${task.endAt}');
        }
        buffer.writeln('  Status: ${task.status.name}');
        buffer.writeln('');
      }
    }

    if (taggedEvents != null && taggedEvents.isNotEmpty) {
      buffer.writeln('## Tagged Events');
      for (final event in taggedEvents) {
        buffer.writeln('- Event ID: ${event.eventId}');
        buffer.writeln('  Title: ${event.title ?? 'Untitled'}');
        if (event.description != null && event.description!.isNotEmpty) {
          buffer.writeln('  Description: ${event.description}');
        }
        buffer.writeln('  Start: ${event.startDate}');
        buffer.writeln('  End: ${event.endDate}');
        if (event.location != null && event.location!.isNotEmpty) {
          buffer.writeln('  Location: ${event.location}');
        }
        buffer.writeln('');
      }
    }

    if (taggedConnections != null && taggedConnections.isNotEmpty) {
      buffer.writeln('## Tagged Connections');
      for (final connection in taggedConnections) {
        buffer.writeln('- Name: ${connection.name ?? 'No name'}');
        buffer.writeln('  Email: ${connection.email ?? 'No email'}');
        buffer.writeln('');
      }
    }

    if (taggedChannels != null && taggedChannels.isNotEmpty) {
      buffer.writeln('## Tagged Channels');
      for (final channel in taggedChannels) {
        buffer.writeln('- Channel ID: ${channel.id}');
        buffer.writeln('  Name: ${channel.name ?? 'No name'}');
        buffer.writeln('  Team ID: ${channel.teamId}');
        buffer.writeln('');
      }
    }

    if (taggedProjects != null && taggedProjects.isNotEmpty) {
      buffer.writeln('## Tagged Projects');
      for (final project in taggedProjects) {
        buffer.writeln('- Project ID: ${project.uniqueId}');
        buffer.writeln('  Name: ${project.name}');
        if (project.description != null && project.description!.isNotEmpty) {
          buffer.writeln('  Description: ${project.description}');
        }
        buffer.writeln('');
      }
    }

    return buffer.toString();
  }

  /// 함수 실행 전 확인 메시지를 생성합니다.
  String _getFunctionConfirmationMessage(String functionName, Map<String, dynamic> args) {
    switch (functionName) {
      case 'sendMail':
        final to = (args['to'] as List<dynamic>?)?.map((e) => e.toString()).join(', ') ?? '';
        final subject = args['subject'] as String? ?? '';
        return '다음 이메일을 전송하시겠습니까?\n\n받는 사람: $to\n제목: $subject';
      case 'replyMail':
        final subject = args['subject'] as String? ?? '';
        return '이메일에 답장을 보내시겠습니까?\n\n제목: $subject';
      case 'forwardMail':
        final to = (args['to'] as List<dynamic>?)?.map((e) => e.toString()).join(', ') ?? '';
        return '이메일을 다음 주소로 전달하시겠습니까?\n\n받는 사람: $to';
      case 'deleteTask':
        return '작업을 삭제하시겠습니까?';
      case 'deleteEvent':
        return '일정을 삭제하시겠습니까?';
      case 'deleteMail':
        return '이메일을 삭제하시겠습니까?';
      case 'updateTask':
        final title = args['title'] as String? ?? '';
        return '작업을 수정하시겠습니까?\n\n제목: $title';
      case 'updateEvent':
        final title = args['title'] as String? ?? '';
        return '일정을 수정하시겠습니까?\n\n제목: $title';
      case 'markMailAsRead':
        return '이메일을 읽음으로 표시하시겠습니까?';
      case 'markMailAsUnread':
        return '이메일을 읽지 않음으로 표시하시겠습니까?';
      case 'archiveMail':
        return '이메일을 보관하시겠습니까?';
      case 'responseCalendarInvitation':
        final response = args['response'] as String? ?? '';
        return '캘린더 초대에 "$response"로 응답하시겠습니까?';
      case 'createTask':
        final title = args['title'] as String? ?? '';
        return '다음 작업을 생성하시겠습니까?\n\n제목: $title';
      case 'createEvent':
        final title = args['title'] as String? ?? '';
        return '다음 일정을 생성하시겠습니까?\n\n제목: $title';
      default:
        return '이 작업을 실행하시겠습니까?';
    }
  }

  /// 함수 호출 인자를 태그된 항목들로 자동 보강합니다.
  Map<String, dynamic> _enrichFunctionArgsWithTaggedItems({
    required String functionName,
    required Map<String, dynamic> args,
    List<TaskEntity>? taggedTasks,
    List<EventEntity>? taggedEvents,
    List<ConnectionEntity>? taggedConnections,
    List<InboxEntity>? availableInboxes,
  }) {
    final enrichedArgs = Map<String, dynamic>.from(args);

    // toggleTaskStatus, updateTask, deleteTask 등의 경우 태그된 task 사용
    if ((functionName == 'toggleTaskStatus' || functionName == 'updateTask' || functionName == 'deleteTask') && taggedTasks != null && taggedTasks.isNotEmpty) {
      if (!enrichedArgs.containsKey('taskId') || enrichedArgs['taskId'] == null) {
        // 첫 번째 태그된 task 사용
        enrichedArgs['taskId'] = taggedTasks.first.id;
      }
    }

    // createTask의 경우 태그된 task의 정보를 참고할 수 있도록 제공
    if (functionName == 'createTask' && taggedTasks != null && taggedTasks.isNotEmpty) {
      // 태그된 task가 있으면 참고 정보로 사용 (자동으로 덮어쓰지는 않음)
      // AI가 명시적으로 지정한 값이 우선
    }

    // updateEvent, deleteEvent, responseCalendarInvitation의 경우 태그된 event 사용
    if ((functionName == 'updateEvent' || functionName == 'deleteEvent' || functionName == 'responseCalendarInvitation') && taggedEvents != null && taggedEvents.isNotEmpty) {
      if (!enrichedArgs.containsKey('eventId') || enrichedArgs['eventId'] == null) {
        enrichedArgs['eventId'] = taggedEvents.first.eventId;
      }
    }

    // sendMail, replyMail의 경우 태그된 connection 사용
    if ((functionName == 'sendMail' || functionName == 'replyMail') && taggedConnections != null && taggedConnections.isNotEmpty) {
      if (!enrichedArgs.containsKey('to') || enrichedArgs['to'] == null || (enrichedArgs['to'] as List).isEmpty) {
        enrichedArgs['to'] = taggedConnections.map((c) => c.email ?? '').where((e) => e.isNotEmpty).toList();
      }
    }

    // Mail 관련 함수들 (markMailAsRead, markMailAsUnread, archiveMail, deleteMail, replyMail, forwardMail)의 경우
    // availableInboxes에서 threadId 자동 추출
    // 검색 결과가 있으면 검색 결과를 우선적으로 사용
    final mailFunctions = ['markMailAsRead', 'markMailAsUnread', 'archiveMail', 'deleteMail', 'replyMail', 'forwardMail'];

    if (mailFunctions.contains(functionName) && availableInboxes != null && availableInboxes.isNotEmpty) {
      if (!enrichedArgs.containsKey('threadId') || enrichedArgs['threadId'] == null || (enrichedArgs['threadId'] as String).isEmpty) {
        // available inbox에서 threadId 추출
        // 검색 결과가 있으면 검색 결과를 우선적으로 사용 (최근에 추가된 inbox가 앞에 있음)
        InboxEntity? targetInbox;

        // 최근에 추가된 inbox부터 확인 (검색 결과가 뒤에 추가되므로)
        for (var i = availableInboxes.length - 1; i >= 0; i--) {
          final inbox = availableInboxes[i];
          if (inbox.linkedMail != null && inbox.linkedMail!.threadId.isNotEmpty) {
            targetInbox = inbox;
            break;
          } else if (inbox.linkedMessage != null) {
            // Chat message의 경우 threadId 또는 messageId 사용
            final threadId = inbox.linkedMessage!.threadId.isNotEmpty && inbox.linkedMessage!.threadId != inbox.linkedMessage!.messageId
                ? inbox.linkedMessage!.threadId
                : inbox.linkedMessage!.messageId;
            if (threadId.isNotEmpty) {
              // Chat message는 threadId 대신 messageId를 사용할 수도 있음
              // Mail 함수는 threadId를 요구하므로 mail이 있는 inbox를 우선
              if (targetInbox == null) {
                targetInbox = inbox;
              }
            }
          }
        }

        // Mail이 있는 inbox를 우선적으로 사용
        if (targetInbox == null) {
          targetInbox = availableInboxes.firstWhereOrNull((inbox) => inbox.linkedMail != null && inbox.linkedMail!.threadId.isNotEmpty);
        }

        // Mail이 없으면 첫 번째 inbox 사용
        targetInbox ??= availableInboxes.first;

        if (targetInbox.linkedMail != null) {
          final threadId = targetInbox.linkedMail!.threadId;
          if (threadId.isNotEmpty) {
            enrichedArgs['threadId'] = threadId;
          }
        } else if (targetInbox.linkedMessage != null) {
          // Chat message의 경우 threadId 또는 messageId 사용
          final threadId = targetInbox.linkedMessage!.threadId.isNotEmpty && targetInbox.linkedMessage!.threadId != targetInbox.linkedMessage!.messageId
              ? targetInbox.linkedMessage!.threadId
              : targetInbox.linkedMessage!.messageId;
          if (threadId.isNotEmpty) {
            enrichedArgs['threadId'] = threadId;
          }
        }
      }
    }

    return enrichedArgs;
  }

  /// Project와 subproject의 task 정보를 context로 제공합니다.
  /// project가 null인 경우 project filter 없이 모든 task와 event를 포함합니다.
  Future<String> _buildProjectContext(ProjectEntity? project) async {
    final projects = ref.read(projectListControllerProvider);
    final tasks = ref.read(taskListControllerProvider.select((v) => v.tasks.where((t) => t.linkedEvent == null).toList()));
    final events = ref.read(calendarEventListControllerProvider(tabType: TabType.home)).eventsOnView;

    // project가 null인 경우 project filter 없이 모든 task와 event를 포함
    if (project == null) {
      return _buildAllTasksAndEventsContext(tasks: tasks, events: events);
    }

    // Project와 subproject ID 찾기
    final projectWithDepth = projects.sortedProjectWithDepth.firstWhereOrNull((p) => p.project.uniqueId == project.uniqueId);
    if (projectWithDepth == null) {
      return '';
    }

    final allProject = <ProjectEntity>{project};

    // Subproject 찾기 - 기존 로직 사용 (isPointedProjectId)
    final visitedIds = <String>{};
    Set<ProjectEntity> findDescendants(String targetParentId) {
      try {
        // 무한 루프 방지
        if (visitedIds.contains(targetParentId)) {
          return {};
        }
        visitedIds.add(targetParentId);

        // targetParentId에 해당하는 프로젝트 찾기
        final targetProject = projects.firstWhereOrNull((p) => p.isPointedProjectId(targetParentId));

        if (targetProject == null) {
          return {};
        }

        // parentId가 targetProject를 가리키는 프로젝트들을 찾음
        final childrenProjects = projects.where((p) => targetProject.isPointedProjectId(p.parentId)).toList();

        if (childrenProjects.isEmpty) {
          return {};
        }

        final descendants = <ProjectEntity>{...childrenProjects};
        // 재귀적으로 하위 서브프로젝트도 찾음
        for (final child in childrenProjects) {
          descendants.addAll(findDescendants(child.uniqueId));
        }
        return descendants;
      } catch (e) {
        return {};
      }
    }

    try {
      final descendants = findDescendants(project.uniqueId);
      allProject.addAll(descendants);
    } catch (e) {
      // Ignore exceptions
    }

    // 해당 project들의 task 필터링 - 엄격한 필터링
    // projectId가 null이 아니고, allProject에 포함된 프로젝트인지 확인
    final relevantTasks = tasks.where((t) {
      if (t.projectId == null || t.isCancelled) return false;
      return allProject.any((p) => p.isPointedProjectId(t.projectId));
    }).toList();

    // 태스크를 우선순위로 정렬: 진행 중인 태스크 > 최근 태스크 > 완료된 태스크
    final sortedTasks = List<TaskEntity>.from(relevantTasks);
    sortedTasks.sort((a, b) {
      // 진행 중인 태스크 우선
      if (a.status == TaskStatus.none && b.status == TaskStatus.done) return -1;
      if (a.status == TaskStatus.done && b.status == TaskStatus.none) return 1;
      // 최근 날짜 우선
      final aDate = a.startAt ?? a.startDate;
      final bDate = b.startAt ?? b.startDate;
      return bDate.compareTo(aDate);
    });

    // 최대 100개 태스크만 포함 (토큰 제한 고려) - 최근 작업 우선
    final limitedTasks = sortedTasks.take(100).toList();

    // Context 문자열 생성 - 원시 데이터를 JSON 형태로 제공하여 AI가 분석하도록
    final buffer = StringBuffer();

    // 오늘 날짜를 timezone 포함해서 추가
    final timezone = ref.read(timezoneProvider).value;
    final now = DateTime.now();
    final timezoneOffset = now.timeZoneOffset;
    final timezoneOffsetHours = timezoneOffset.inHours;
    final timezoneOffsetMinutes = timezoneOffset.inMinutes.remainder(60).abs();
    final timezoneOffsetString =
        '${timezoneOffsetHours >= 0 ? '+' : '-'}${timezoneOffsetHours.abs().toString().padLeft(2, '0')}:${timezoneOffsetMinutes.toString().padLeft(2, '0')}';
    final todayString =
        '${now.toIso8601String().split('T')[0]}T${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}$timezoneOffsetString';
    buffer.writeln('Current Date and Time: $todayString (Timezone: $timezone)');
    buffer.writeln('');

    buffer.writeln('Current Project: ${project.name}');
    if (project.description != null && project.description!.isNotEmpty) {
      buffer.writeln('Project Description: ${project.description}');
    }

    // 서브프로젝트 정보 추가
    final subprojects = allProject.where((p) => p.uniqueId != project.uniqueId).toList();
    if (subprojects.isNotEmpty) {
      buffer.writeln('\nSubprojects:');
      for (final subproject in subprojects) {
        buffer.writeln('- ${subproject.name}${subproject.description != null && subproject.description!.isNotEmpty ? ': ${subproject.description}' : ''}');
      }
    }

    // 디버깅: 포함된 프로젝트 ID 목록 (개발용)
    buffer.writeln('\n[DEBUG] Included Project IDs: ${allProject.map((p) => p.uniqueId).join(", ")}');
    buffer.writeln('[DEBUG] Current Project ID: ${project.uniqueId}');
    buffer.writeln('[DEBUG] Relevant tasks count: ${relevantTasks.length}');
    buffer.writeln('[DEBUG] Limited tasks count: ${limitedTasks.length}');

    // 태스크 통계 정보 추가 (전체 태스크 기준)
    final doneTasks = relevantTasks.where((t) => t.status == TaskStatus.done).length;
    final totalTasks = relevantTasks.length;
    final limitedDoneTasks = limitedTasks.where((t) => t.status == TaskStatus.done).length;
    final limitedTotalTasks = limitedTasks.length;

    buffer.writeln('\nTask Statistics:');
    buffer.writeln('- Total tasks: $totalTasks (showing ${limitedTotalTasks > 0 ? limitedTotalTasks : 0} most relevant below)');
    buffer.writeln('- Completed: $doneTasks (${limitedDoneTasks > 0 ? limitedDoneTasks : 0} in the list below)');
    buffer.writeln('- In progress: ${totalTasks - doneTasks} (${limitedTotalTasks - limitedDoneTasks} in the list below)');
    if (relevantTasks.length > limitedTasks.length) {
      buffer.writeln('- Note: Showing top ${limitedTasks.length} most relevant tasks below (sorted by priority and recency, out of ${totalTasks} total tasks)');
    }

    // 제한된 태스크를 원시 데이터 형태로 제공 (AI가 필터링, 통계, 분석 수행)
    if (limitedTasks.isNotEmpty) {
      // 추가 검증: allProject에 포함된 작업만 포함
      final validProjectNames = allProject.map((p) => p.name).toSet();

      buffer.writeln('\nTasks in this project and subprojects (raw data for AI analysis):');
      buffer.writeln(
        'CRITICAL: All tasks listed below MUST belong to the Current Project "${project.name}" or its subprojects listed above. Valid project names are: ${validProjectNames.join(", ")}',
      );
      buffer.writeln('Do NOT include tasks from other projects that are not listed in the Subprojects section.');
      buffer.writeln('Analyze these tasks, filter out irrelevant ones (like dummy tasks, original recurrence tasks), calculate statistics, and provide insights.');
      buffer.writeln(
        'IMPORTANT: The task list below contains ${limitedTasks.length} tasks sorted by priority and recency. Use these actual tasks to answer questions about the project. Each task includes a "projectName" field - ONLY use tasks where projectName is "${project.name}" or matches one of the subprojects listed above. If a task has a different projectName, it should be excluded from your response.',
      );

      // JSON 형태로 구조화된 데이터 제공 (간소화된 정보만)
      // 한 번 더 필터링하여 allProject에 포함된 작업만 포함
      final tasksJson = limitedTasks
          .where((task) {
            if (task.projectId == null) return false;
            // allProject에 포함된 프로젝트인지 확인
            return allProject.any((p) => p.isPointedProjectId(task.projectId));
          })
          .map((task) {
            final taskProject = allProject.where((p) => p.isPointedProjectId(task.projectId)).firstOrNull;
            return {
              'title': task.title ?? 'Untitled',
              'status': task.status.name,
              'isDone': task.status == TaskStatus.done,
              'isOriginalRecurrenceTask': task.isOriginalRecurrenceTask,
              'isEventDummyTask': task.isEventDummyTask,
              'startAt': task.startAt?.toIso8601String(),
              'endAt': task.endAt?.toIso8601String(),
              'projectName': taskProject?.name,
              'projectId': task.projectId, // 디버깅용
            };
          })
          .toList();

      buffer.writeln('[DEBUG] Tasks JSON count: ${tasksJson.length}');

      buffer.writeln(jsonEncode(tasksJson));
    } else {
      buffer.writeln('\nNo tasks found in this project and subprojects.');
      buffer.writeln('Note: Even though the statistics above show ${totalTasks} total tasks, no tasks matched the filtering criteria or all tasks were filtered out.');
    }

    final contextString = buffer.toString();
    return contextString;
  }

  /// project filter 없이 모든 task와 event를 context로 제공합니다.
  Future<String> _buildAllTasksAndEventsContext({required List<TaskEntity> tasks, required List<EventEntity> events}) async {
    final projects = ref.read(projectListControllerProvider);

    // 모든 task 필터링 (cancelled 제외)
    final relevantTasks = tasks.where((t) => !t.isCancelled).toList();

    // 태스크를 우선순위로 정렬: 진행 중인 태스크 > 최근 태스크 > 완료된 태스크
    final sortedTasks = List<TaskEntity>.from(relevantTasks);
    sortedTasks.sort((a, b) {
      // 진행 중인 태스크 우선
      if (a.status == TaskStatus.none && b.status == TaskStatus.done) return -1;
      if (a.status == TaskStatus.done && b.status == TaskStatus.none) return 1;
      // 최근 날짜 우선
      final aDate = a.startAt ?? a.startDate;
      final bDate = b.startAt ?? b.startDate;
      return bDate.compareTo(aDate);
    });

    // 최대 100개 태스크만 포함 (토큰 제한 고려) - 최근 작업 우선
    final limitedTasks = sortedTasks.take(100).toList();

    // 이벤트를 날짜순으로 정렬
    final sortedEvents = List<EventEntity>.from(events);
    sortedEvents.sort((a, b) {
      return b.startDate.compareTo(a.startDate);
    });

    // 최대 100개 이벤트만 포함 (토큰 제한 고려) - 최근 이벤트 우선
    final limitedEvents = sortedEvents.take(100).toList();

    // Context 문자열 생성
    final buffer = StringBuffer();

    // 오늘 날짜를 timezone 포함해서 추가
    final timezone = ref.read(timezoneProvider).value;
    final now = DateTime.now();
    final timezoneOffset = now.timeZoneOffset;
    final timezoneOffsetHours = timezoneOffset.inHours;
    final timezoneOffsetMinutes = timezoneOffset.inMinutes.remainder(60).abs();
    final timezoneOffsetString =
        '${timezoneOffsetHours >= 0 ? '+' : '-'}${timezoneOffsetHours.abs().toString().padLeft(2, '0')}:${timezoneOffsetMinutes.toString().padLeft(2, '0')}';
    final todayString =
        '${now.toIso8601String().split('T')[0]}T${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}$timezoneOffsetString';
    buffer.writeln('Current Date and Time: $todayString (Timezone: $timezone)');
    buffer.writeln('');

    buffer.writeln('All Tasks and Events (No Project Filter)');

    // 태스크 통계 정보 추가
    final doneTasks = relevantTasks.where((t) => t.status == TaskStatus.done).length;
    final totalTasks = relevantTasks.length;
    final limitedDoneTasks = limitedTasks.where((t) => t.status == TaskStatus.done).length;
    final limitedTotalTasks = limitedTasks.length;

    buffer.writeln('\nTask Statistics:');
    buffer.writeln('- Total tasks: $totalTasks (showing ${limitedTotalTasks > 0 ? limitedTotalTasks : 0} most relevant below)');
    buffer.writeln('- Completed: $doneTasks (${limitedDoneTasks > 0 ? limitedDoneTasks : 0} in the list below)');
    buffer.writeln('- In progress: ${totalTasks - doneTasks} (${limitedTotalTasks - limitedDoneTasks} in the list below)');
    if (relevantTasks.length > limitedTasks.length) {
      buffer.writeln('- Note: Showing top ${limitedTasks.length} most relevant tasks below (sorted by priority and recency, out of ${totalTasks} total tasks)');
    }

    buffer.writeln('\nEvent Statistics:');
    buffer.writeln('- Total events: ${events.length} (showing ${limitedEvents.length} most recent below)');

    // 제한된 태스크를 원시 데이터 형태로 제공
    if (limitedTasks.isNotEmpty) {
      buffer.writeln('\nAll Tasks (raw data for AI analysis):');
      buffer.writeln('CRITICAL: These are ALL tasks across all projects. No project filtering has been applied.');
      buffer.writeln('Analyze these tasks, filter out irrelevant ones (like dummy tasks, original recurrence tasks), calculate statistics, and provide insights.');

      final tasksJson = limitedTasks.map((task) {
        final taskProject = task.projectId != null ? projects.firstWhereOrNull((p) => p.isPointedProjectId(task.projectId)) : null;
        return {
          'title': task.title ?? 'Untitled',
          'status': task.status.name,
          'isDone': task.status == TaskStatus.done,
          'isOriginalRecurrenceTask': task.isOriginalRecurrenceTask,
          'isEventDummyTask': task.isEventDummyTask,
          'startAt': task.startAt?.toIso8601String(),
          'endAt': task.endAt?.toIso8601String(),
          'projectName': taskProject?.name,
          'projectId': task.projectId,
        };
      }).toList();

      buffer.writeln(jsonEncode(tasksJson));
    } else {
      buffer.writeln('\nNo tasks found.');
    }

    // 제한된 이벤트를 원시 데이터 형태로 제공
    if (limitedEvents.isNotEmpty) {
      buffer.writeln('\nAll Events (raw data for AI analysis):');
      buffer.writeln('CRITICAL: These are ALL events across all calendars. No project filtering has been applied.');
      buffer.writeln('Analyze these events and provide insights.');

      final eventsJson = limitedEvents.map((event) {
        return {
          'id': event.eventId,
          'title': event.title ?? 'Untitled',
          'description': event.description,
          'calendar_id': event.calendar.uniqueId,
          'calendar_name': event.calendar.name,
          'start_at': event.startDate.toIso8601String(),
          'end_at': event.endDate.toIso8601String(),
          'location': event.location,
          'rrule': event.rrule?.toString(),
          'attendees': event.attendees.map((a) => a.email).whereType<String>().toList(),
          'conference_link': event.conferenceLink,
          'isAllDay': event.isAllDay,
        };
      }).toList();

      buffer.writeln(jsonEncode(eventsJson));
    } else {
      buffer.writeln('\nNo events found.');
    }

    final contextString = buffer.toString();
    return contextString;
  }

  /// 태그된 채널의 메시지를 컨텍스트로 제공합니다 (최근 3일).
  Future<String> _buildChannelContext(List<MessageChannelEntity> taggedChannels) async {
    final buffer = StringBuffer();
    final chatRepository = ref.read(chatRepositoryProvider);
    final chatOAuths = ref.read(localPrefControllerProvider.select((v) => v.value?.messengerOAuths ?? []));
    final me = ref.read(authControllerProvider).value;

    if (me == null) {
      return '';
    }

    // 최근 3일 기준 날짜 계산
    final now = DateTime.now();
    final threeDaysAgo = now.subtract(const Duration(days: 3));

    // 각 채널에 대해 메시지 가져오기
    for (final channel in taggedChannels) {
      try {
        // 채널의 teamId에 해당하는 OAuth 찾기
        final oauth = chatOAuths.firstWhereOrNull((o) => o.teamId != null && o.teamId == channel.teamId);
        if (oauth == null) {
          continue;
        }

        // 최근 3일치 메시지 가져오기
        final result = await chatRepository.fetchMessageForInbox(
          oauth: oauth,
          user: me,
          channels: [channel],
          q: '', // 빈 쿼리로 모든 메시지 가져오기
          startDate: threeDaysAgo,
          endDate: now,
        );

        await result.fold(
          (failure) async {
            // Ignore failures
          },
          (fetchResult) async {
            final messages = fetchResult.messages;

            if (messages.isNotEmpty) {
              // 날짜로 정렬 (최신순)
              final sortedMessages = List<MessageEntity>.from(messages);
              sortedMessages.sort((a, b) {
                final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
                return bDate.compareTo(aDate);
              });

              // 채널 정보 추가
              buffer.writeln('\n## Channel: ${channel.name ?? channel.id}');
              buffer.writeln('Team ID: ${channel.teamId}');
              buffer.writeln('Messages from last 3 days (${sortedMessages.length} messages):\n');

              // 메시지 정보 추가 (최대 100개)
              for (final message in sortedMessages.take(100)) {
                final createdAt = message.createdAt;
                final text = message.text ?? '';
                final userId = message.userId ?? 'Unknown';

                if (text.isNotEmpty) {
                  final dateStr = createdAt != null ? createdAt.toIso8601String() : 'Unknown date';
                  buffer.writeln('- [${dateStr}] User ${userId}: ${text.substring(0, text.length > 200 ? 200 : text.length)}${text.length > 200 ? '...' : ''}');
                }
              }

              if (sortedMessages.length > 100) {
                buffer.writeln('\n... and ${sortedMessages.length - 100} more messages');
              }
            } else {
              buffer.writeln('\n## Channel: ${channel.name ?? channel.id}');
              buffer.writeln('No messages found in the last 3 days.');
            }
          },
        );
      } catch (e) {
        // Ignore exceptions
      }
    }

    final contextString = buffer.toString();
    return contextString;
  }

  /// 인박스 목록을 컨텍스트로 제공합니다.
  /// [summaryOnly]: true면 제목, sender, 날짜만 보냄 (메타데이터만), false면 전체 내용 포함
  /// [requestedInboxNumbers]: 전체 내용을 보낼 inbox 번호 목록 (1부터 시작)
  /// [maxItems]: 최대 보낼 인박스 개수 (기본값: summaryOnly일 때 300, 아닐 때 50)
  String _buildInboxContext(List<InboxEntity> inboxes, {bool summaryOnly = true, Set<int> requestedInboxNumbers = const {}, int? maxItems}) {
    // summaryOnly일 때는 메타데이터만 보내므로 더 많이 보낼 수 있음
    final defaultMaxItems = summaryOnly ? 300 : 50;
    final effectiveMaxItems = maxItems ?? defaultMaxItems;
    if (inboxes.isEmpty) return '';

    final buffer = StringBuffer();
    buffer.writeln('## Inbox Items');
    if (summaryOnly && requestedInboxNumbers.isEmpty) {
      buffer.writeln('The following inbox items (emails and messages) are available in the user\'s inbox.');
      buffer.writeln('Each item shows only metadata (title, sender, date). To read the full content of a specific item, request it by its item number.');
    } else {
      buffer.writeln('The following inbox items (emails and messages) are available in the user\'s inbox:');
    }
    buffer.writeln('');

    // 최대 effectiveMaxItems개만 포함
    final limitedInboxes = inboxes.take(effectiveMaxItems).toList();

    for (int i = 0; i < limitedInboxes.length; i++) {
      final inbox = limitedInboxes[i];
      final itemNumber = i + 1;
      final shouldIncludeFullContent = requestedInboxNumbers.contains(itemNumber) || !summaryOnly;

      buffer.writeln('### Inbox Item $itemNumber');

      if (inbox.linkedMail != null) {
        final mail = inbox.linkedMail!;
        buffer.writeln('- Type: Email');
        buffer.writeln('- From: ${mail.fromName}');
        buffer.writeln('- Subject: ${inbox.title}');
        buffer.writeln('- Date: ${inbox.inboxDatetime.toIso8601String()}');

        if (shouldIncludeFullContent) {
          // 전체 내용 포함
          if (inbox.description != null && inbox.description!.isNotEmpty) {
            buffer.writeln('- Full Content:');
            buffer.writeln(inbox.description!);
          }
          if (mail.hostMail.isNotEmpty) {
            buffer.writeln('- Email Account: ${mail.hostMail}');
          }
        } else {
          // 메타데이터만
          if (inbox.description != null && inbox.description!.isNotEmpty) {
            final snippet = inbox.description!.length > 100 ? '${inbox.description!.substring(0, 100)}...' : inbox.description!;
            buffer.writeln('- Preview: $snippet');
          }
        }
      } else if (inbox.linkedMessage != null) {
        final message = inbox.linkedMessage!;
        buffer.writeln('- Type: Message');
        buffer.writeln('- Channel: ${message.channelName}');
        buffer.writeln('- From: ${message.userName ?? 'Unknown'}');
        buffer.writeln('- Date: ${inbox.inboxDatetime.toIso8601String()}');

        if (shouldIncludeFullContent) {
          // 전체 내용 포함
          if (inbox.description != null && inbox.description!.isNotEmpty) {
            buffer.writeln('- Full Content:');
            buffer.writeln(inbox.description!);
          }
        } else {
          // 메타데이터만
          if (inbox.description != null && inbox.description!.isNotEmpty) {
            final snippet = inbox.description!.length > 100 ? '${inbox.description!.substring(0, 100)}...' : inbox.description!;
            buffer.writeln('- Preview: $snippet');
          }
        }
      }
      buffer.writeln('');
    }

    if (inboxes.length > effectiveMaxItems) {
      buffer.writeln('Note: Showing first $effectiveMaxItems items (out of ${inboxes.length} total inbox items).');
    }

    if (summaryOnly && requestedInboxNumbers.isEmpty) {
      buffer.writeln('\nTo read the full content of any inbox item, specify its item number (e.g., "read inbox item 1" or "show me the full content of inbox item 5").');
    }

    return buffer.toString();
  }

  /// AI 응답에서 need_more_action 태그를 파싱합니다.
  /// 태그 형식: <need_more_action>{"inbox_numbers": [1, 2, 3]}</need_more_action>
  Map<String, dynamic>? _parseNeedMoreActionTag(String aiResponse) {
    final tagPattern = RegExp(r'<need_more_action>(.*?)</need_more_action>', dotAll: true);
    final match = tagPattern.firstMatch(aiResponse);

    if (match == null) return null;

    try {
      final jsonStr = match.group(1)?.trim() ?? '{}';
      final jsonData = jsonDecode(jsonStr) as Map<String, dynamic>;

      // inbox_numbers를 Set<int>로 변환
      if (jsonData.containsKey('inbox_numbers')) {
        final numbers = jsonData['inbox_numbers'];
        if (numbers is List) {
          final numberSet = numbers.map((n) => n is int ? n : int.tryParse(n.toString())).whereType<int>().toSet();
          return {'inbox_numbers': numberSet};
        }
      }

      return jsonData;
    } catch (e) {
      // JSON 파싱 실패 시 null 반환
      return null;
    }
  }

  /// AI 응답에서 특정 inbox 번호를 요청하는 것을 감지하고 번호를 추출합니다.
  /// 예: "read inbox item 1", "show me inbox item 5", "인박스 3번 보여줘" 등
  Set<int> _extractRequestedInboxNumbers(String aiResponse) {
    final requestedNumbers = <int>{};
    final lowerResponse = aiResponse.toLowerCase();

    // 다양한 패턴으로 inbox 번호 추출
    // 영어 패턴
    final englishPatterns = [
      RegExp(r'inbox\s*item\s*(\d+)', caseSensitive: false),
      RegExp(r'item\s*(\d+)', caseSensitive: false),
      RegExp(r'inbox\s*(\d+)', caseSensitive: false),
      RegExp(r'email\s*(\d+)', caseSensitive: false),
      RegExp(r'message\s*(\d+)', caseSensitive: false),
      RegExp(r'read\s*(\d+)', caseSensitive: false),
      RegExp(r'show\s*.*?(\d+)', caseSensitive: false),
    ];

    // 한국어 패턴
    final koreanPatterns = [
      RegExp(r'인박스\s*(\d+)', caseSensitive: false),
      RegExp(r'메일\s*(\d+)', caseSensitive: false),
      RegExp(r'메시지\s*(\d+)', caseSensitive: false),
      RegExp(r'(\d+)\s*번', caseSensitive: false),
      RegExp(r'(\d+)\s*번째', caseSensitive: false),
    ];

    // 모든 패턴에서 번호 추출
    for (final pattern in [...englishPatterns, ...koreanPatterns]) {
      final matches = pattern.allMatches(lowerResponse);
      for (final match in matches) {
        final numberStr = match.group(1);
        if (numberStr != null) {
          final number = int.tryParse(numberStr);
          if (number != null && number > 0) {
            requestedNumbers.add(number);
          }
        }
      }
    }

    return requestedNumbers;
  }

  /// AI 응답이 inbox 관련 질문인지 확인합니다.
  bool _isInboxRelatedQuestion(String aiResponse) {
    final lowerResponse = aiResponse.toLowerCase();
    final inboxKeywords = ['inbox', 'email', 'message', 'mail', '인박스', '메일', '메시지', '이메일'];

    return inboxKeywords.any((keyword) => lowerResponse.contains(keyword));
  }

  /// AI 응답에서 inbox를 읽어야 한다는 표현이 있는지 확인합니다.
  /// 예: "읽어야 합니다", "열어볼까요", "읽어볼게요", "전체를 읽어야" 등
  bool _detectNeedsToReadInbox(String aiResponse) {
    final lowerResponse = aiResponse.toLowerCase();
    final readPatterns = ['읽어야', '읽어볼', '열어볼', '전체를', '본문 전체', '내용 전체', 'full content', 'read the', 'open the', 'need to read', 'should read'];

    return readPatterns.any((pattern) => lowerResponse.contains(pattern));
  }

  /// 사용자 질문에서 특정 sender나 키워드를 언급했는지 확인하여 관련 inbox를 자동으로 감지합니다.
  Set<int> _detectInboxesFromUserQuery(String userQuery, List<InboxEntity> inboxes) {
    final detectedNumbers = <int>{};
    final lowerQuery = userQuery.toLowerCase();

    // 요약, 읽기, 분석 등의 액션 키워드 확인
    final actionKeywords = ['요약', 'summarize', 'summary', '읽어', 'read', '분석', 'analyze', 'analysis', '보여', 'show', '보고', '알려', 'tell'];
    final hasActionRequest = actionKeywords.any((keyword) => lowerQuery.contains(keyword));

    // 사용자가 특정 sender나 키워드를 언급했는지 확인
    for (int i = 0; i < inboxes.length; i++) {
      final inbox = inboxes[i];
      final itemNumber = i + 1;

      // 이미 전체 내용을 보낸 inbox는 제외
      if (state.loadedInboxNumbers.contains(itemNumber)) {
        continue;
      }

      // Email인 경우 sender 이름 확인
      if (inbox.linkedMail != null) {
        final mail = inbox.linkedMail!;
        final senderName = mail.fromName.toLowerCase();

        // sender 이름에서 주요 단어 추출 (예: "링글 공동창업자 이승훈" -> "링글", "이승훈")
        final senderWords = senderName.split(' ').where((w) => w.length >= 2).toList();

        // 사용자 질문에 sender 이름이나 주요 단어가 포함되어 있는지 확인
        bool senderMatches = false;
        if (senderName.length >= 2 && lowerQuery.contains(senderName)) {
          senderMatches = true;
        } else {
          // sender의 주요 단어 중 하나라도 매칭되면
          for (final word in senderWords) {
            if (word.length >= 2 && lowerQuery.contains(word)) {
              senderMatches = true;
              break;
            }
          }
        }

        if (senderMatches && hasActionRequest) {
          // 액션 요청이 있고 sender가 매칭되면 자동으로 로드
          detectedNumbers.add(itemNumber);
          continue;
        }

        // 제목에 키워드가 있는지 확인
        final title = inbox.title.toLowerCase();
        final titleWords = title.split(' ').where((w) => w.length >= 2).toList();
        for (final word in titleWords.take(5)) {
          // 최대 5개 단어만 확인
          if (lowerQuery.contains(word) && hasActionRequest) {
            detectedNumbers.add(itemNumber);
            break;
          }
        }
      }

      // Message인 경우 sender 이름 확인
      if (inbox.linkedMessage != null) {
        final message = inbox.linkedMessage!;
        final userName = (message.userName ?? '').toLowerCase();

        if (userName.length >= 2 && lowerQuery.contains(userName) && hasActionRequest) {
          detectedNumbers.add(itemNumber);
          continue;
        }

        final channelName = (message.channelName ?? '').toLowerCase();
        if (channelName.length >= 2 && lowerQuery.contains(channelName) && hasActionRequest) {
          detectedNumbers.add(itemNumber);
          continue;
        }
      }
    }

    return detectedNumbers;
  }

  /// AI 응답에서 언급된 sender나 키워드를 기반으로 관련 inbox를 자동으로 감지합니다.
  Set<int> _autoDetectRelevantInboxes(String aiResponse, List<InboxEntity> inboxes) {
    final detectedNumbers = <int>{};
    final lowerResponse = aiResponse.toLowerCase();

    // AI가 특정 sender를 언급했는지 확인
    for (int i = 0; i < inboxes.length; i++) {
      final inbox = inboxes[i];
      final itemNumber = i + 1;

      // 이미 전체 내용을 보낸 inbox는 제외
      if (state.loadedInboxNumbers.contains(itemNumber)) {
        continue;
      }

      // Email인 경우 sender 이름 확인
      if (inbox.linkedMail != null) {
        final mail = inbox.linkedMail!;
        final senderName = mail.fromName.toLowerCase();

        // AI 응답에 sender 이름이 포함되어 있는지 확인 (최소 3글자 이상)
        if (senderName.length >= 3 && lowerResponse.contains(senderName)) {
          detectedNumbers.add(itemNumber);
          continue;
        }

        // 제목이나 설명에 키워드가 있는지 확인
        final title = inbox.title.toLowerCase();
        if (title.length >= 3 && lowerResponse.contains(title.substring(0, title.length > 20 ? 20 : title.length))) {
          detectedNumbers.add(itemNumber);
          continue;
        }
      }

      // Message인 경우 sender 이름 확인
      if (inbox.linkedMessage != null) {
        final message = inbox.linkedMessage!;
        final userName = (message.userName ?? '').toLowerCase();

        if (userName.length >= 3 && lowerResponse.contains(userName)) {
          detectedNumbers.add(itemNumber);
          continue;
        }

        final channelName = (message.channelName ?? '').toLowerCase();
        if (channelName.length >= 3 && lowerResponse.contains(channelName)) {
          detectedNumbers.add(itemNumber);
          continue;
        }
      }
    }

    return detectedNumbers;
  }

  /// 대화 시작 메시지의 summary를 생성합니다.
  /// 사용자 메시지를 추가하고 AI 응답을 받습니다.
  Future<void> sendMessage(
    String userMessage, {
    List<InboxEntity>? inboxes,
    List<TaskEntity>? taggedTasks,
    List<EventEntity>? taggedEvents,
    List<ConnectionEntity>? taggedConnections,
    List<MessageChannelEntity>? taggedChannels,
    List<ProjectEntity>? taggedProjects,
  }) async {
    // 태그된 항목들을 HTML 태그로 감싸서 메시지에 포함
    final messageWithTags = _buildMessageWithTaggedItems(
      userMessage: userMessage,
      taggedTasks: taggedTasks,
      taggedEvents: taggedEvents,
      taggedConnections: taggedConnections,
      taggedChannels: taggedChannels,
      taggedProjects: taggedProjects,
    );

    // 사용자 메시지 추가
    final updatedMessages = [...state.messages, AgentActionMessage(role: 'user', content: messageWithTags)];
    state = state.copyWith(messages: updatedMessages, isLoading: true);

    // 사용자 메시지 추가 후 히스토리 저장
    _saveChatHistory(taggedProjects: taggedProjects);

    try {
      // MCP 함수 호출을 통한 일반적인 AI 챗 진행
      await _generateGeneralChat(
        userMessage,
        updatedMessages: updatedMessages,
        taggedTasks: taggedTasks,
        taggedEvents: taggedEvents,
        taggedConnections: taggedConnections,
        taggedChannels: taggedChannels,
        taggedProjects: taggedProjects,
        inboxes: inboxes,
      );
    } catch (e) {
      state = state.copyWith(
        messages: [
          ...updatedMessages,
          AgentActionMessage(role: 'assistant', content: Utils.mainContext.tr.agent_action_error_occurred),
        ],
        isLoading: false,
      );
      // 에러 메시지 추가 후 히스토리 저장
      _saveChatHistory(taggedProjects: taggedProjects);
    }
  }

  /// 액션을 취소하고 상태를 초기화합니다.
  void cancelAction() {
    // 현재 선택된 모델과 API 키 설정을 유지하면서 액션만 취소
    final currentModel = selectedModel;
    final currentUseUserApiKey = useUserApiKey;
    state = AgentActionState(selectedModel: currentModel, useUserApiKey: currentUseUserApiKey, sessionId: null);
  }

  /// 확인이 필요한 함수 호출을 실행합니다.
  Future<void> confirmAction({required String actionId}) async {
    await confirmActions(actionIds: [actionId]);
  }

  /// 여러 액션을 일괄 확인하고 실행합니다.
  Future<void> confirmActions({required List<String> actionIds}) async {
    if (actionIds.isEmpty) return;

    final pendingCalls = state.pendingFunctionCalls ?? [];
    final callsToExecute = pendingCalls.where((call) {
      final callActionId = call['action_id'] as String?;
      return callActionId != null && actionIds.contains(callActionId);
    }).toList();

    if (callsToExecute.isEmpty) {
      return;
    }

    // pendingFunctionCalls에서 먼저 제거 (UI 업데이트를 위해)
    final updatedPendingCalls = pendingCalls.where((call) {
      final callActionId = call['action_id'] as String?;
      return callActionId == null || !actionIds.contains(callActionId);
    }).toList();
    state = state.copyWith(
      pendingFunctionCalls: updatedPendingCalls.isEmpty ? null : updatedPendingCalls,
      selectedActionIds: {},
    );

    final executor = McpFunctionExecutor(ref);
    final successMessages = <String>[];
    final errorMessages = <String>[];

    // 각 액션을 순차적으로 실행 (의존성 고려)
    for (final pendingCall in callsToExecute) {
      // 타입 안전하게 데이터 추출
      final functionName = pendingCall['function_name'] as String?;
      final functionArgs = pendingCall['function_args'] as Map<String, dynamic>?;

      if (functionName == null || functionArgs == null) {
        continue;
      }

      // 타입 안전하게 컨텍스트 데이터 추출
      final updatedTaggedTasks = pendingCall['updated_tagged_tasks'] as List<TaskEntity>?;
      final updatedTaggedEvents = pendingCall['updated_tagged_events'] as List<EventEntity>?;
      final taggedConnections = pendingCall['tagged_connections'] as List<ConnectionEntity>?;
      final updatedAvailableInboxes = pendingCall['updated_available_inboxes'] as List<InboxEntity>?;
      final remainingCredits = (pendingCall['remaining_credits'] as num?)?.toDouble() ?? 0.0;

      try {
        // 함수 실행
        final result = await executor.executeFunction(
          functionName,
          functionArgs,
          tabType: TabType.home,
          availableTasks: updatedTaggedTasks,
          availableEvents: updatedTaggedEvents,
          availableConnections: taggedConnections,
          availableInboxes: updatedAvailableInboxes,
          remainingCredits: remainingCredits,
        );

        if (result['success'] == true) {
          final message = result['message'] as String? ?? '작업이 완료되었습니다.';
          successMessages.add(message);
        } else {
          final error = result['error'] as String? ?? '작업 실행 중 오류가 발생했습니다.';
          errorMessages.add('$functionName: $error');
        }
      } catch (e) {
        errorMessages.add('$functionName: 작업 실행 중 오류가 발생했습니다: ${e.toString()}');
      }
    }

    // 결과 메시지 생성
    String resultMessage;
    if (errorMessages.isEmpty) {
      if (successMessages.length == 1) {
        resultMessage = successMessages.first;
      } else {
        resultMessage = '${successMessages.length}개의 작업이 완료되었습니다:\n${successMessages.map((m) => '• $m').join('\n')}';
      }
    } else if (successMessages.isEmpty) {
      resultMessage = '작업 실행 중 오류가 발생했습니다:\n${errorMessages.map((m) => '• $m').join('\n')}';
    } else {
      resultMessage = '일부 작업이 완료되었습니다:\n';
      if (successMessages.isNotEmpty) {
        resultMessage += '성공:\n${successMessages.map((m) => '• $m').join('\n')}\n';
      }
      if (errorMessages.isNotEmpty) {
        resultMessage += '실패:\n${errorMessages.map((m) => '• $m').join('\n')}';
      }
    }

    final assistantMessage = AgentActionMessage(role: 'assistant', content: resultMessage);
    final updatedMessages = [...state.messages, assistantMessage];
    state = state.copyWith(messages: updatedMessages);

    // 히스토리 저장
    _saveChatHistory();
  }

  /// 액션 선택 상태를 토글합니다.
  void toggleActionSelection(String actionId) {
    final selectedIds = Set<String>.from(state.selectedActionIds);
    if (selectedIds.contains(actionId)) {
      selectedIds.remove(actionId);
    } else {
      selectedIds.add(actionId);
    }
    state = state.copyWith(selectedActionIds: selectedIds);
  }

  /// 모든 액션을 선택하거나 선택 해제합니다.
  void toggleAllActionsSelection(bool selectAll) {
    final pendingCalls = state.pendingFunctionCalls ?? [];
    if (selectAll) {
      final allActionIds = pendingCalls.map((call) => call['action_id'] as String?).whereType<String>().toSet();
      state = state.copyWith(selectedActionIds: allActionIds);
    } else {
      state = state.copyWith(selectedActionIds: {});
    }
  }

  /// 함수 호출을 의존성에 따라 그룹화합니다.
  /// 각 그룹은 동시에 실행 가능하며, 그룹 간에는 순차적으로 실행됩니다.
  List<List<Map<String, dynamic>>> _groupFunctionCalls(List<Map<String, dynamic>> functionCalls) {
    final groups = <List<Map<String, dynamic>>>[];
    final processed = <int>{};

    for (int i = 0; i < functionCalls.length; i++) {
      if (processed.contains(i)) continue;

      final functionCall = functionCalls[i];
      final canParallelize = functionCall['can_parallelize'] as bool? ?? false;
      final dependsOn = functionCall['depends_on'] as List<dynamic>?;

      // depends_on이 있거나 can_parallelize가 false면 별도 그룹으로 분리
      if (dependsOn != null && dependsOn.isNotEmpty || !canParallelize) {
        groups.add([functionCall]);
        processed.add(i);
        continue;
      }

      // can_parallelize가 true이고 depends_on이 없으면 같은 그룹에 추가
      final currentGroup = <Map<String, dynamic>>[functionCall];
      processed.add(i);

      // 같은 그룹에 추가할 수 있는 다른 함수들 찾기
      for (int j = i + 1; j < functionCalls.length; j++) {
        if (processed.contains(j)) continue;

        final otherCall = functionCalls[j];
        final otherCanParallelize = otherCall['can_parallelize'] as bool? ?? false;
        final otherDependsOn = otherCall['depends_on'] as List<dynamic>?;

        // 같은 조건을 만족하면 같은 그룹에 추가
        if (otherCanParallelize && (otherDependsOn == null || otherDependsOn.isEmpty)) {
          currentGroup.add(otherCall);
          processed.add(j);
        }
      }

      groups.add(currentGroup);
    }

    return groups;
  }

  /// 프로젝트 ID를 추출합니다.
  String? _extractProjectId({List<ProjectEntity>? taggedProjects}) {
    // taggedProjects의 첫 번째 프로젝트 사용
    if (taggedProjects != null && taggedProjects.isNotEmpty) {
      return taggedProjects.first.uniqueId;
    }
    return null;
  }

  /// 히스토리에서 대화를 불러옵니다.
  Future<AgentChatHistoryEntity?> loadChatHistory(String sessionId) async {
    final me = ref.read(authControllerProvider).value;
    if (me == null) return null;

    // 로컬에서 먼저 확인
    try {
      final storage = await ref.read(storageProvider.future);
      final key = 'agent_chat_history:$sessionId';
      final data = await storage.read(key);
      if (data != null) {
        final json = jsonDecode(data.data) as Map<String, dynamic>;
        json['is_encrypted'] = false; // 로컬 저장소는 항상 평문
        return AgentChatHistoryEntity.fromJson(json, local: true); // 로컬 저장소는 평문
      }
    } catch (e) {
      // 로컬 읽기 실패는 무시
    }

    // Supabase에서 확인
    try {
      return await _historyRepository.getChatHistoryById(userId: me.id, sessionId: sessionId);
    } catch (e) {
      return null;
    }
  }

  /// 히스토리에서 대화를 재개합니다.
  Future<void> resumeChatFromHistory(String sessionId) async {
    final history = await loadChatHistory(sessionId);
    if (history == null) return;

    // AgentActionType 복원
    AgentActionType? actionType;
    if (history.actionType != null) {
      try {
        actionType = AgentActionType.values.firstWhere((e) => e.name == history.actionType);
      } catch (e) {
        // actionType 복원 실패는 무시
      }
    }

    // InboxEntity 복원 (inbox ID가 있는 경우)
    InboxEntity? inbox;
    // TODO: inbox ID를 저장하고 복원하는 로직 추가 필요

    // TaskEntity 복원 (task ID가 있는 경우)
    TaskEntity? task;
    // TODO: task ID를 저장하고 복원하는 로직 추가 필요

    // EventEntity 복원 (event ID가 있는 경우)
    EventEntity? event;
    // TODO: event ID를 저장하고 복원하는 로직 추가 필요

    // State 복원
    state = state.copyWith(
      sessionId: sessionId,
      actionType: actionType,
      inbox: inbox,
      task: task,
      event: event,
      messages: history.messages,
      conversationSummary: history.conversationSummary,
      isLoading: false,
    );
  }

  /// actionType에서 제목을 생성합니다 (buildActionButtonText의 로직과 동일).
  Future<void> _generateTitleFromActionType() async {
    if (state.actionType == null) {
      return;
    }

    try {
      // buildActionButtonText의 로직과 동일하게 텍스트 생성
      // displayText = conversationSummary ?? actionType.getTitle(context)
      String displayText;
      switch (state.actionType!) {
        case AgentActionType.createTask:
          displayText = Utils.mainContext.tr.create_task;
          break;
        case AgentActionType.createEvent:
          displayText = Utils.mainContext.tr.command_create_event('').replaceAll(' {title}', '');
          break;
        case AgentActionType.reply:
          displayText = Utils.mainContext.tr.mail_reply;
          break;
        case AgentActionType.forward:
          displayText = Utils.mainContext.tr.mail_forward;
          break;
        case AgentActionType.send:
          displayText = Utils.mainContext.tr.mail_send;
          break;
        default:
          displayText = state.actionType!.name;
          break;
      }

      String? itemName;

      switch (state.actionType!) {
        case AgentActionType.createTask:
        case AgentActionType.createEvent:
          if (state.inbox != null) {
            final suggestion = state.inbox!.suggestion;
            final summary = suggestion?.summary ?? '';
            itemName = summary.isNotEmpty ? summary : null;
          }
          break;
        case AgentActionType.reply:
          if (state.inbox != null) {
            final suggestion = state.inbox!.suggestion;
            final summary = suggestion?.summary ?? state.inbox!.title;
            final senderName = suggestion?.sender_name;
            if (summary.isNotEmpty) {
              if (senderName != null && senderName.isNotEmpty) {
                itemName = '$summary ($senderName)';
              } else {
                itemName = summary;
              }
            } else if (senderName != null && senderName.isNotEmpty) {
              itemName = senderName;
            }
          }
          break;
        default:
          break;
      }

      String finalTitle;
      if (itemName != null && itemName.isNotEmpty) {
        finalTitle = '$displayText · $itemName';
      } else {
        finalTitle = displayText;
      }

      // 50자로 제한
      if (finalTitle.length > 50) {
        finalTitle = '${finalTitle.substring(0, 47)}...';
      }

      state = state.copyWith(conversationSummary: finalTitle);
    } catch (e) {
      // 제목 생성 실패는 무시
    }
  }

  /// 대화 제목을 생성합니다 (첫 메시지인 경우).
  Future<void> _generateConversationTitle(String userMessage, String assistantMessage, {String? apiKey}) async {
    try {
      // 전달받은 API 키 사용 (AI 메시지 보낼 때 사용한 것과 동일)
      String? finalApiKey = apiKey;

      if (finalApiKey == null || finalApiKey.isEmpty) {
        // API 키가 없어도 사용자 메시지 기반으로 제목 생성
        String fallbackTitle = userMessage.trim();
        fallbackTitle = fallbackTitle.replaceAll(RegExp(r'<[^>]*>'), '');
        fallbackTitle = fallbackTitle.replaceAll(RegExp(r'@\w+'), '');
        fallbackTitle = fallbackTitle.replaceAll(RegExp(r'\s+'), ' ').trim();
        if (fallbackTitle.length > 50) {
          fallbackTitle = '${fallbackTitle.substring(0, 47)}...';
        }
        if (fallbackTitle.isNotEmpty) {
          state = state.copyWith(conversationSummary: fallbackTitle);
        }
        return;
      }

      // 사용자 메시지에서 태그 제거
      String cleanUserMessage = userMessage.trim();
      cleanUserMessage = cleanUserMessage.replaceAll(RegExp(r'<[^>]*>'), '');
      cleanUserMessage = cleanUserMessage.replaceAll(RegExp(r'@\w+'), '');
      cleanUserMessage = cleanUserMessage.replaceAll(RegExp(r'\s+'), ' ').trim();

      // AI 응답에서 태그 제거
      String cleanAssistantMessage = assistantMessage.trim();
      cleanAssistantMessage = cleanAssistantMessage.replaceAll(RegExp(r'<[^>]*>'), '');
      cleanAssistantMessage = cleanAssistantMessage.replaceAll(RegExp(r'\s+'), ' ').trim();

      // AI에게 제목 생성 요청
      final prompt =
          '''다음 대화의 제목을 30자 이내로 간단하게 생성해주세요.

사용자: $cleanUserMessage
AI: $cleanAssistantMessage

제목은 대화의 핵심 내용을 담아야 하며, 간결하고 명확해야 합니다.
제목만 반환하고 다른 설명은 포함하지 마세요.''';

      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $finalApiKey'},
        body: jsonEncode({
          'model': 'gpt-4o-mini', // 제목 생성은 간단한 모델 사용
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.3,
          'max_tokens': 50,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final title = decoded['choices']?[0]?['message']?['content'] as String?;

        if (title != null && title.trim().isNotEmpty) {
          String finalTitle = title.trim();
          // 50자로 제한
          if (finalTitle.length > 50) {
            finalTitle = '${finalTitle.substring(0, 47)}...';
          }
          state = state.copyWith(conversationSummary: finalTitle);
        } else {
          // AI 응답이 없으면 사용자 메시지 기반으로 간단한 제목 생성
          String fallbackTitle = cleanUserMessage;
          if (fallbackTitle.length > 50) {
            fallbackTitle = '${fallbackTitle.substring(0, 47)}...';
          }
          state = state.copyWith(conversationSummary: fallbackTitle);
        }
      } else {
        // API 호출 실패 시 사용자 메시지 기반으로 간단한 제목 생성
        String fallbackTitle = cleanUserMessage;
        if (fallbackTitle.length > 50) {
          fallbackTitle = '${fallbackTitle.substring(0, 47)}...';
        }
        state = state.copyWith(conversationSummary: fallbackTitle);
      }
    } catch (e) {
      // 제목 생성 실패 시 사용자 메시지 기반으로 간단한 제목 생성
      try {
        String fallbackTitle = userMessage.trim();
        fallbackTitle = fallbackTitle.replaceAll(RegExp(r'<[^>]*>'), '');
        fallbackTitle = fallbackTitle.replaceAll(RegExp(r'@\w+'), '');
        fallbackTitle = fallbackTitle.replaceAll(RegExp(r'\s+'), ' ').trim();
        if (fallbackTitle.length > 50) {
          fallbackTitle = '${fallbackTitle.substring(0, 47)}...';
        }
        if (fallbackTitle.isNotEmpty) {
          state = state.copyWith(conversationSummary: fallbackTitle);
        }
      } catch (e2) {
        // 최종 실패는 무시
      }
    }
  }

  /// 챗 히스토리를 저장합니다 (로컬 + Supabase).
  Future<void> _saveChatHistory({List<ProjectEntity>? taggedProjects}) async {
    // 메시지가 비어있으면 저장하지 않음
    if (state.messages.isEmpty) {
      return;
    }

    // 세션 ID 확인 (없으면 생성)
    final sessionId = state.sessionId ?? const Uuid().v4();

    // 프로젝트 ID 추출
    final projectId = _extractProjectId(taggedProjects: taggedProjects);

    final me = ref.read(authControllerProvider).value;
    if (me == null) {
      return;
    }

    final now = DateTime.now();
    final history = AgentChatHistoryEntity(
      id: sessionId,
      projectId: projectId,
      messages: state.messages,
      actionType: state.actionType?.name,
      conversationSummary: state.conversationSummary,
      createdAt: now, // createdAt은 항상 현재 시간 (기존 세션의 경우 업데이트만 수행)
      updatedAt: now,
    );

    // 세션 ID가 없었으면 state에 설정
    if (state.sessionId == null) {
      state = state.copyWith(sessionId: sessionId);
    }

    // 로컬 저장 (Riverpod persist) - 평문으로 저장
    try {
      final storage = await ref.read(storageProvider.future);
      final key = 'agent_chat_history:$sessionId';
      await storage.write(key, jsonEncode(history.toJson(local: true)), StorageOptions(destroyKey: me.id)); // 로컬은 평문
    } catch (e) {
      // 로컬 저장 실패는 무시
    }

    // Supabase 저장 (비동기, 실패해도 계속 진행)
    try {
      await _historyRepository.saveChatHistory(userId: me.id, history: history);
    } catch (e) {
      // Supabase 저장 실패는 무시
    }
  }

  String _buildContextInfo(AgentActionType actionType, {InboxEntity? inbox, TaskEntity? task, EventEntity? event}) {
    switch (actionType) {
      case AgentActionType.reply:
        // case AgentActionType.forward: // TODO: Forward 기능은 나중에 구현 예정
        if (inbox?.linkedMail != null) {
          final linkedMail = inbox!.linkedMail!;
          // LinkedMailEntity에서 사용 가능한 정보 사용
          final snippet = inbox.description ?? '';
          return '''
Original Email:
Subject: ${linkedMail.title}
From: ${linkedMail.fromName}
Body:
$snippet
''';
        }
        return '';
      case AgentActionType.createTask:
        if (inbox != null) {
          final title = inbox.title;
          final description = inbox.description;
          return '''
Inbox Item:
Title: $title
Description:
${description ?? ''}
''';
        }
        return '';
      case AgentActionType.createEvent:
        if (inbox != null) {
          final title = inbox.title;
          final description = inbox.description;
          return '''
Inbox Item:
Title: $title
Description:
${description ?? ''}
''';
        }
        return '';
      default:
        return '';
    }
  }

  String _escapeHtml(String text) {
    return text.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;').replaceAll('"', '&quot;').replaceAll("'", '&#39;');
  }

  String _buildInitialMessage(AgentActionType actionType, String contextInfo, {InboxEntity? inbox, TaskEntity? task, EventEntity? event}) {
    String contextHtml = '';

    if ((actionType == AgentActionType.reply /* || actionType == AgentActionType.forward */ ) && inbox != null) {
      // TODO: Forward 기능은 나중에 구현 예정
      final inboxJson = jsonEncode(inbox.toJson(local: true));
      contextHtml = '<inapp_inbox>$inboxJson</inapp_inbox>';
    } else if (actionType == AgentActionType.createTask) {
      // createTask에서는 inbox item을 표시하지 않음 (suggested task만 표시)
      contextHtml = '';
    } else if (actionType == AgentActionType.createEvent) {
      // createEvent에서는 inbox item을 표시하지 않음 (suggested event만 표시)
      contextHtml = '';
    } else {
      final escapedContextInfo = _escapeHtml(contextInfo).replaceAll('\n', '<br>');
      contextHtml = '<div class="inbox-section"><div class="section-title">Inbox Item</div><div class="field"><span class="value">$escapedContextInfo</span></div></div>';
    }

    switch (actionType) {
      case AgentActionType.reply:
        final baseMessage = Utils.mainContext.tr.agent_action_reply_initial_message('');
        final parts = baseMessage.split('{contextInfo}');
        return '${parts[0]}$contextHtml${parts.length > 1 ? parts[1] : ''}';
      // case AgentActionType.forward: // TODO: Forward 기능은 나중에 구현 예정
      //   // Forward는 reply와 유사하지만 forward 형식으로 초기 메시지 생성
      //   final baseMessage = Utils.mainContext.tr.agent_action_reply_initial_message('').replaceAll('reply', 'forward').replaceAll('Reply', 'Forward');
      //   final parts = baseMessage.split('{contextInfo}');
      //   return '${parts[0]}$contextHtml${parts.length > 1 ? parts[1] : ''}';
      case AgentActionType.createTask:
        // createTask에서는 contextInfo를 표시하지 않음 (suggested task만 표시)
        return Utils.mainContext.tr.agent_action_create_task_initial_message('').replaceAll('{contextInfo}', '').replaceAll('\n\n\n', '\n\n');
      case AgentActionType.createEvent:
        // createEvent에서는 contextInfo를 표시하지 않음 (suggested event만 표시)
        return Utils.mainContext.tr.agent_action_create_task_initial_message('').replaceAll('{contextInfo}', '').replaceAll('\n\n\n', '\n\n').replaceAll('task', 'event');
      default:
        return '<p>${_escapeHtml(Utils.mainContext.tr.agent_action_starting_action)}</p>';
    }
  }

  /// AI를 사용하여 사용자의 확인 상태를 판단합니다.
  /// conversation history와 user request를 기반으로 사용자가 action을 진행할 의사가 있는지 확인합니다.
  Future<bool> checkConfirmationFromAI({
    required LinkedMailEntity linkedMail,
    required String content,
    required String userRequest,
    required List<Map<String, dynamic>> conversationHistory,
    String? previousContent,
    required String model,
  }) async {
    String? apiKey;
    if (useUserApiKey) {
      final apiKeys = ref.read(aiApiKeysProvider);
      // model에서 provider 추출 (model name에서 provider 추론 필요)
      // 일단 현재 선택된 모델의 provider 사용
      apiKey = apiKeys[selectedModel.provider.name];
    }

    final suggestedResult = await _repository.generateSuggestedReply(
      linkedMail: linkedMail,
      snippet: content,
      model: model,
      threadMessages: null,
      previousReply: previousContent,
      userModificationRequest: previousContent != null ? userRequest : userRequest,
      originalTo: [],
      originalCc: [],
      originalBcc: [],
      senderEmail: null,
      senderName: null,
      currentUserEmail: linkedMail.hostMail,
      originalMailBody: null,
      actionType: 'send', // Indicate this is for send action
      apiKey: apiKey,
    );

    final suggestedResponse = suggestedResult.fold((failure) => null, (response) => response);
    return suggestedResponse?['isConfirmed'] as bool? ?? false;
  }

  /// Mail action을 위한 confirmation 체크 (reply, send 등)
  Future<bool> checkMailConfirmation({
    required LinkedMailEntity linkedMail,
    required String content,
    required String userRequest,
    required List<AgentActionMessage> conversationHistory,
    String? previousContent,
    required String model,
  }) async {
    // AI에 전달할 때는 평문이어야 하므로 local: true 사용
    return await checkConfirmationFromAI(
      linkedMail: linkedMail,
      content: content,
      userRequest: userRequest,
      conversationHistory: conversationHistory.map((m) => m.toJson(local: true)).toList(),
      previousContent: previousContent,
      model: model,
    );
  }

  /// Task action을 위한 confirmation 체크
  /// Task는 generateTaskFromInbox에서 이미 isConfirmed를 반환하므로,
  /// 이 함수는 일관성을 위한 wrapper입니다.
  Future<bool> checkTaskConfirmation({required Map<String, dynamic> taskInfo}) async {
    // Task의 경우 AI가 이미 taskInfo에 isConfirmed를 포함하여 반환
    return taskInfo['isConfirmed'] as bool? ?? false;
  }

  /// Event action을 위한 confirmation 체크
  /// Event는 generateEventFromInbox에서 이미 isConfirmed를 반환하므로,
  /// 이 함수는 일관성을 위한 wrapper입니다.
  Future<bool> checkEventConfirmation({required Map<String, dynamic> eventInfo}) async {
    // Event의 경우 AI가 이미 eventInfo에 isConfirmed를 포함하여 반환
    return eventInfo['isConfirmed'] as bool? ?? false;
  }

  /// 모든 action에 공통적으로 적용되는 confirmation 체크
  /// 새로운 action을 추가할 때도 이 함수를 사용하여 일관성을 유지합니다.
  Future<bool> checkActionConfirmation({
    required AgentActionType actionType,
    Map<String, dynamic>? actionInfo,
    LinkedMailEntity? linkedMail,
    String? content,
    String? userRequest,
    List<AgentActionMessage>? conversationHistory,
    String? previousContent,
    required String model,
  }) async {
    switch (actionType) {
      case AgentActionType.reply:
      case AgentActionType.send:
        if (linkedMail != null && content != null && userRequest != null && conversationHistory != null) {
          return await checkMailConfirmation(
            linkedMail: linkedMail,
            content: content,
            userRequest: userRequest,
            conversationHistory: conversationHistory,
            previousContent: previousContent,
            model: model,
          );
        }
        return false;
      case AgentActionType.createTask:
        if (actionInfo != null) {
          return await checkTaskConfirmation(taskInfo: actionInfo);
        }
        return false;
      case AgentActionType.createEvent:
        if (actionInfo != null) {
          return await checkEventConfirmation(eventInfo: actionInfo);
        }
        return false;
      default:
        // 새로운 action이 추가되면 여기에 추가
        // 기본적으로 actionInfo에서 isConfirmed를 확인
        if (actionInfo != null) {
          return actionInfo['isConfirmed'] as bool? ?? false;
        }
        return false;
    }
  }
}
