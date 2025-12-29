import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:Visir/config/providers.dart';
import 'package:Visir/features/common/infrastructure/entities/environment.dart';
import 'package:Visir/flavors.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/application/calendar_event_list_controller.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
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
  /// 모든 agentAction은 동일한 방식으로 동작: 첫 메시지를 자동으로 generalChat으로 보냄
  Future<void> startAction({required AgentActionType actionType, InboxEntity? inbox, TaskEntity? task, EventEntity? event}) async {
    // 새로운 세션 ID 생성
    final sessionId = const Uuid().v4();

    // Set state with actionType first
    state = state.copyWith(actionType: actionType, inbox: inbox, task: task, event: event, isLoading: false, sessionId: sessionId);

    // 각 actionType에 맞는 첫 메시지 생성
    String autoMessage = '';
    List<InboxEntity>? inboxesForContext;

    switch (actionType) {
      case AgentActionType.send:
        autoMessage = Utils.mainContext.tr.agent_action_send_request_message;
        break;
      case AgentActionType.reply:
        if (inbox != null) {
          autoMessage = Utils.mainContext.tr.agent_action_reply_request_message;
          inboxesForContext = [inbox];
        } else {
          autoMessage = Utils.mainContext.tr.agent_action_reply_request_message_no_inbox;
        }
        break;
      case AgentActionType.forward:
        if (inbox != null) {
          autoMessage = Utils.mainContext.tr.agent_action_forward_request_message;
          inboxesForContext = [inbox];
        } else {
          autoMessage = Utils.mainContext.tr.agent_action_forward_request_message_no_inbox;
        }
        break;
      case AgentActionType.createTask:
        if (inbox != null) {
          autoMessage = Utils.mainContext.tr.agent_action_create_task_request_message;
          inboxesForContext = [inbox];
        } else {
          autoMessage = Utils.mainContext.tr.agent_action_create_task_request_message_no_inbox;
        }
        break;
      case AgentActionType.createEvent:
        if (inbox != null) {
          autoMessage = Utils.mainContext.tr.agent_action_create_event_request_message;
          inboxesForContext = [inbox];
        } else {
          autoMessage = Utils.mainContext.tr.agent_action_create_event_request_message_no_inbox;
        }
        break;
      default:
        // 기타 actionType의 경우 기본 메시지 사용
        autoMessage = Utils.mainContext.tr.agent_action_starting_action;
        if (inbox != null) {
          inboxesForContext = [inbox];
        }
    }

    // 첫 메시지를 자동으로 generalChat으로 보냄
    if (autoMessage.isNotEmpty) {
      await _sendAutoMessage(autoMessage, inboxes: inboxesForContext, actionType: actionType);
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

  /// agentAction 시작 시 첫 메시지를 자동으로 보냅니다.
  Future<void> _sendAutoMessage(String autoMessage, {List<InboxEntity>? inboxes, AgentActionType? actionType}) async {
    if (autoMessage.trim().isEmpty) return;

    // createTask나 createEvent의 경우, 제공된 inbox를 자동으로 로드
    if ((actionType == AgentActionType.createTask || actionType == AgentActionType.createEvent) && inboxes != null && inboxes.isNotEmpty) {
      // 제공된 inbox 번호들을 loadedInboxNumbers에 추가하여 전체 내용이 포함되도록 함
      final inboxNumbers = {for (int i = 0; i < inboxes.length; i++) i + 1};
      state = state.copyWith(loadedInboxNumbers: {...state.loadedInboxNumbers, ...inboxNumbers});
    }

    // 사용자 메시지로 추가 (자동 메시지)
    final updatedMessages = [...state.messages, AgentActionMessage(role: 'user', content: autoMessage)];
    state = state.copyWith(messages: updatedMessages, isLoading: true);

    try {
      // generalChat으로 처리
      await _generateGeneralChat(autoMessage, updatedMessages: updatedMessages, inboxes: inboxes);
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
    bool isRecursiveCall = false, // 재귀 호출 방지 플래그
  }) async {
    // updatedMessages가 제공되지 않으면 새로 생성
    final messages = updatedMessages ?? [...state.messages, AgentActionMessage(role: 'user', content: userMessage)];

    // 재귀 호출인 경우, conversation history의 마지막 user 메시지를 사용
    // (이미 updatedMessages에 첫 번째 응답이 포함되어 있으므로, 같은 userMessage를 다시 추가하지 않음)
    final actualUserMessage = isRecursiveCall && updatedMessages != null && messages.isNotEmpty
        ? (messages
              .lastWhere(
                (m) => m.role == 'user',
                orElse: () => AgentActionMessage(role: 'user', content: userMessage),
              )
              .content)
        : userMessage;

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
      // 재귀 호출인 경우 conversation history의 마지막 user 메시지를 사용
      final response = await _repository.generateGeneralChat(
        userMessage: actualUserMessage,
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

        // 함수 호출 태그를 제거한 메시지 추출 (AI가 생성한 메시지 부분)
        String aiMessageWithoutFunctionCalls = aiMessage;
        // function_call 태그 제거
        aiMessageWithoutFunctionCalls = aiMessageWithoutFunctionCalls.replaceAll(RegExp(r'<function_call.*?</function_call>', dotAll: true), '').trim();
        // JSON 배열 형식의 함수 호출 제거
        final arrayStart = aiMessageWithoutFunctionCalls.indexOf('[');
        final arrayEnd = aiMessageWithoutFunctionCalls.lastIndexOf(']');
        if (arrayStart != -1 && arrayEnd != -1 && arrayEnd > arrayStart) {
          try {
            final arrayStr = aiMessageWithoutFunctionCalls.substring(arrayStart, arrayEnd + 1);
            final parsed = jsonDecode(arrayStr) as List<dynamic>?;
            if (parsed != null && parsed.isNotEmpty) {
              bool isFunctionCallArray = false;
              for (final item in parsed) {
                if (item is Map<String, dynamic> && item.containsKey('function') && item.containsKey('arguments')) {
                  isFunctionCallArray = true;
                  break;
                }
              }
              if (isFunctionCallArray) {
                // 함수 호출 배열 제거
                aiMessageWithoutFunctionCalls = (aiMessageWithoutFunctionCalls.substring(0, arrayStart) + aiMessageWithoutFunctionCalls.substring(arrayEnd + 1)).trim();
              }
            }
          } catch (e) {
            // JSON 파싱 실패 시 무시
          }
        }

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

          // 모든 그룹의 결과를 수집할 리스트
          final allGroupResults = <Map<String, dynamic>?>[];

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
                  // assistant 메시지가 추가될 인덱스 저장 (entity block을 어느 메시지에 표시할지 결정)
                  // messages에는 아직 assistant 메시지가 추가되지 않았으므로, 추가될 인덱스는 messages.length
                  // 하지만 함수 호출이 처리되는 시점에서는 이미 user 메시지가 추가된 상태이므로, assistant 메시지 인덱스는 messages.length
                  final targetMessageIndex = messages.length;
                  pendingCalls.add({
                    'action_id': actionId,
                    'function_name': functionName,
                    'function_args': functionArgs,
                    'index': functionCalls.indexOf(functionCall),
                    'message_index': targetMessageIndex, // 메시지 인덱스 저장
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

                // 함수 이름에 따라 적절한 tabType 결정
                final tabType = _getTabTypeForFunction(functionName);

                // 함수 실행
                final result = await executor.executeFunction(
                  functionName,
                  functionArgs,
                  tabType: tabType,
                  availableTasks: updatedTaggedTasks,
                  availableEvents: updatedTaggedEvents,
                  availableConnections: taggedConnections,
                  availableInboxes: updatedAvailableInboxes,
                  remainingCredits: remainingCredits,
                );

                return {'functionCall': functionCall, 'result': result, 'functionName': functionName};
              }),
            );

            // 그룹 결과를 전체 리스트에 추가
            allGroupResults.addAll(groupResults);

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

                final successMessage = result['message'] as String? ?? Utils.mainContext.tr.agent_action_task_completed;
                successMessages.add(successMessage);
              } else if (result['success'] == true) {
                final successMessage = result['message'] as String? ?? Utils.mainContext.tr.agent_action_task_completed;
                successMessages.add(successMessage);
              } else {
                final errorMessage = result['error'] as String? ?? Utils.mainContext.tr.agent_action_error_occurred_during_execution;
                errorMessages.add('$functionName: $errorMessage');
              }
            }
          }

          // 검색 결과가 있으면 state 업데이트
          if (updatedLoadedInboxNumbers != state.loadedInboxNumbers || updatedTaggedTasks != taggedTasks || updatedTaggedEvents != taggedEvents) {
            state = state.copyWith(loadedInboxNumbers: updatedLoadedInboxNumbers);
          }

          // AI가 처음 생성한 메시지 사용 (함수 호출 태그 제거된 버전)
          String resultMessage = aiMessageWithoutFunctionCalls;

          // 확인이 필요한 함수가 있는지 확인
          final pendingCallsForMessage = state.pendingFunctionCalls ?? [];
          final hasPendingCalls = pendingCallsForMessage.isNotEmpty;

          // 메시지가 비어있으면 기본 메시지 생성
          if (resultMessage.trim().isEmpty) {
            if (hasPendingCalls) {
              // 확인이 필요한 함수가 있는 경우, 기본 확인 메시지 생성
              final pendingFunctionNames = pendingCallsForMessage.map((call) => call['function_name'] as String? ?? '').where((name) => name.isNotEmpty).toList();
              if (pendingFunctionNames.isNotEmpty) {
                // 함수 이름에 따라 적절한 메시지 생성
                if (pendingFunctionNames.contains('createTask')) {
                  resultMessage = 'A new task has been prepared from the inbox item and is waiting for your confirmation. Once you confirm, it will be created in your tasks.';
                } else if (pendingFunctionNames.contains('createEvent')) {
                  resultMessage = 'A new event has been prepared from the inbox item and is waiting for your confirmation. Once you confirm, it will be created in your calendar.';
                } else if (pendingFunctionNames.contains('sendMail') || pendingFunctionNames.contains('replyMail') || pendingFunctionNames.contains('forwardMail')) {
                  resultMessage = 'A new email has been prepared and is waiting for your confirmation. Once you confirm, it will be sent.';
                } else {
                  resultMessage = 'An action has been prepared and is waiting for your confirmation. Once you confirm, it will be executed.';
                }
              } else {
                resultMessage = 'An action has been prepared and is waiting for your confirmation. Once you confirm, it will be executed.';
              }
            } else if (errorMessages.isEmpty) {
              resultMessage = successMessages.isNotEmpty ? successMessages.join('\n\n') : '';
            } else {
              resultMessage = errorMessages.join('\n\n');
            }
          }

          // 확인이 필요한 함수 호출은 pendingFunctionCalls에 저장되어 있으므로 태그 추가 불필요

          final assistantMessage = AgentActionMessage(role: 'assistant', content: resultMessage);
          final updatedMessagesWithResponse = [...messages, assistantMessage];

          // 검색 결과가 있으면 state에 저장 (AI가 다음 응답에서 필요시 사용)
          if (updatedLoadedInboxNumbers != state.loadedInboxNumbers || updatedTaggedTasks != taggedTasks || updatedTaggedEvents != taggedEvents) {
            state = state.copyWith(loadedInboxNumbers: updatedLoadedInboxNumbers);
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

          // AI 응답에서 need_more_action 태그 파싱 (재귀 호출이 아닌 경우에만)
          if (!isRecursiveCall) {
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
                  // 첫 번째 응답 메시지는 아직 state에 저장하지 않음 (재귀 호출에서 최종 메시지로 대체될 예정)
                  state = state.copyWith(loadedInboxNumbers: updatedLoadedNumbers, isLoading: true);

                  // 재요청 (같은 사용자 메시지로, _generateGeneralChat 직접 호출)
                  // 재귀 호출에서는 첫 번째 응답을 포함한 messages를 전달하되,
                  // 재귀 호출 내부에서는 마지막 user 메시지를 사용하여 AI를 호출
                  await _generateGeneralChat(
                    userMessage,
                    selectedProject: selectedProject,
                    updatedMessages: updatedMessagesWithResponse, // 첫 번째 응답 포함하여 재귀 호출에 전달
                    taggedTasks: taggedTasks,
                    taggedEvents: taggedEvents,
                    taggedConnections: taggedConnections,
                    taggedChannels: taggedChannels,
                    taggedProjects: taggedProjects,
                    inboxes: inboxes, // 같은 인박스 목록 사용 (전체 내용 포함)
                    isRecursiveCall: true, // 재귀 호출 플래그 설정
                  );
                  // 재귀 호출 완료 후 첫 번째 호출 종료
                  // 재귀 호출에서 이미 최종 메시지가 state에 저장되었으므로 추가 작업 불필요
                  return;
                }
              }
            }
          }

          // 재귀 호출인 경우 여기서 종료 (재귀 호출은 이미 상태를 업데이트했음)
          if (isRecursiveCall) {
            // 재귀 호출 완료 시 로딩 상태 해제
            // 재귀 호출에서는 첫 번째 응답을 제거하고 새로운 응답만 사용
            // updatedMessagesWithResponse 구조: [user, assistant(첫 번째), assistant(두 번째)]
            // 최종 메시지: [user, assistant(두 번째)]만 남김
            final finalMessages =
                updatedMessagesWithResponse.length >= 3 &&
                    updatedMessagesWithResponse[0].role == 'user' &&
                    updatedMessagesWithResponse[1].role == 'assistant' &&
                    updatedMessagesWithResponse[2].role == 'assistant'
                ? [updatedMessagesWithResponse[0], updatedMessagesWithResponse[2]]
                : updatedMessagesWithResponse;
            state = state.copyWith(messages: finalMessages, isLoading: false);
            return;
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
        buffer.writeln('- From: ${message.userName}');
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
        final userName = message.userName.toLowerCase();

        if (userName.length >= 2 && lowerQuery.contains(userName) && hasActionRequest) {
          detectedNumbers.add(itemNumber);
          continue;
        }

        final channelName = message.channelName.toLowerCase();
        if (channelName.length >= 2 && lowerQuery.contains(channelName) && hasActionRequest) {
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

  /// 함수 이름에 따라 적절한 TabType을 결정합니다.
  /// main_screen.dart의 콜백 함수들(onGmailChanged, onSlackChanged 등)을 참고하여 작성했습니다.
  TabType _getTabTypeForFunction(String functionName) {
    // Task 관련 함수들 - home 사용 (calendarTask는 home으로)
    if (functionName.contains('Task') ||
        functionName.startsWith('createTask') ||
        functionName.startsWith('updateTask') ||
        functionName.startsWith('deleteTask') ||
        functionName.startsWith('toggleTask') ||
        functionName.startsWith('assignProject') ||
        functionName.startsWith('setPriority') ||
        functionName.startsWith('addTags') ||
        functionName.startsWith('removeTags') ||
        functionName.startsWith('setDueDate') ||
        functionName.startsWith('setReminder') ||
        functionName.startsWith('setRecurrence') ||
        functionName.startsWith('duplicateTask') ||
        functionName.startsWith('getTodayTasks') ||
        functionName.startsWith('getUpcomingTasks') ||
        functionName.startsWith('getOverdueTasks') ||
        functionName.startsWith('getUnscheduledTasks') ||
        functionName.startsWith('getCompletedTasks') ||
        functionName.startsWith('removeReminder') ||
        functionName.startsWith('removeRecurrence') ||
        functionName.startsWith('listTasks') ||
        functionName.startsWith('getTask') ||
        functionName.startsWith('moveTask') ||
        functionName.startsWith('getTaskAttachments')) {
      return TabType.home;
    }

    // Calendar/Event 관련 함수들 - home 사용 (calendarEvent는 home으로)
    if (functionName.contains('Event') ||
        functionName.contains('Calendar') ||
        functionName.startsWith('createEvent') ||
        functionName.startsWith('updateEvent') ||
        functionName.startsWith('deleteEvent') ||
        functionName.startsWith('responseCalendarInvitation') ||
        functionName.startsWith('optimizeSchedule') ||
        functionName.startsWith('reschedule') ||
        functionName.startsWith('duplicateEvent') ||
        functionName.startsWith('getTodayEvents') ||
        functionName.startsWith('getUpcomingEvents') ||
        functionName.startsWith('listEvents') ||
        functionName.startsWith('getEvent') ||
        functionName.startsWith('moveEvent') ||
        functionName.startsWith('getEventAttachments') ||
        functionName.startsWith('getCalendarList')) {
      return TabType.home;
    }

    // Mail 관련 함수들 - mail 사용 (onGmailChanged는 모든 tabType을 사용하지만, 실제로는 mail tab이 적절)
    if (functionName.contains('Mail') ||
        functionName.startsWith('sendMail') ||
        functionName.startsWith('replyMail') ||
        functionName.startsWith('replyAllMail') ||
        functionName.startsWith('forwardMail') ||
        functionName.startsWith('markMail') ||
        functionName.startsWith('archiveMail') ||
        functionName.startsWith('unarchiveMail') ||
        functionName.startsWith('pinMail') ||
        functionName.startsWith('unpinMail') ||
        functionName.startsWith('spamMail') ||
        functionName.startsWith('unspamMail') ||
        functionName.startsWith('deleteMail') ||
        functionName.startsWith('getMail') ||
        functionName.startsWith('listMails') ||
        functionName.startsWith('moveMail') ||
        functionName.startsWith('getMailLabels') ||
        functionName.startsWith('getMailAttachments')) {
      return TabType.mail;
    }

    // Message/Chat 관련 함수들 - chat 사용 (onSlackChanged는 모든 tabType을 사용하지만, 실제로는 chat tab이 적절)
    if (functionName.contains('Message') ||
        functionName.startsWith('sendMessage') ||
        functionName.startsWith('replyMessage') ||
        functionName.startsWith('editMessage') ||
        functionName.startsWith('deleteMessage') ||
        functionName.startsWith('addReaction') ||
        functionName.startsWith('removeReaction') ||
        functionName.startsWith('getMessage') ||
        functionName.startsWith('listMessages') ||
        functionName.startsWith('searchMessages') ||
        functionName.startsWith('getMessageAttachments')) {
      return TabType.chat;
    }

    // Inbox 관련 함수들 - home 사용
    if (functionName.contains('Inbox') ||
        functionName.startsWith('getInbox') ||
        functionName.startsWith('listInboxes') ||
        functionName.startsWith('pinInbox') ||
        functionName.startsWith('unpinInbox') ||
        functionName.startsWith('createTaskFromInbox')) {
      return TabType.home;
    }

    // Project 관련 함수들 - home 사용
    if (functionName.contains('Project') ||
        functionName.startsWith('createProject') ||
        functionName.startsWith('updateProject') ||
        functionName.startsWith('deleteProject') ||
        functionName.startsWith('searchProject') ||
        functionName.startsWith('linkToProject') ||
        functionName.startsWith('moveProject') ||
        functionName.startsWith('inviteUserToProject') ||
        functionName.startsWith('removeUserFromProject') ||
        functionName.startsWith('getProject') ||
        functionName.startsWith('listProjects')) {
      return TabType.home;
    }

    // 기본값은 home
    return TabType.home;
  }

  /// 확인이 필요한 함수 호출을 실행합니다.
  Future<void> confirmAction({required String actionId}) async {
    // 유저가 confirm 메시지를 보낸 것처럼 처리 (AI에게는 보내지 않음)
    final confirmMessage = AgentActionMessage(role: 'user', content: Utils.mainContext.tr.confirm);
    final updatedMessages = [...state.messages, confirmMessage];
    state = state.copyWith(messages: updatedMessages);

    // 함수 실행
    await confirmActions(actionIds: [actionId]);
  }

  /// 여러 액션을 일괄 확인하고 실행합니다.
  Future<void> confirmActions({required List<String> actionIds}) async {
    if (actionIds.isEmpty) return;

    final pendingCalls = state.pendingFunctionCalls ?? [];
    // actionIds에 포함된 항목들을 필터링하고 중복 제거
    final filteredCalls = pendingCalls.where((call) {
      final callActionId = call['action_id'] as String?;
      return callActionId != null && actionIds.contains(callActionId);
    }).toList();

    // 중복 제거: 같은 함수와 인자를 가진 호출은 하나만 실행
    final callsToExecute = <Map<String, dynamic>>[];
    final seenActionIds = <String>{};
    final seenFunctionSignatures = <String>{};

    for (final call in filteredCalls) {
      final functionName = call['function_name'] as String? ?? '';
      final actionId = call['action_id'] as String? ?? '';
      final functionArgs = call['function_args'] as Map<String, dynamic>? ?? {};

      // signature 생성 (UI에서 사용하는 것과 동일한 로직)
      String signature = functionName;
      if (functionName == 'createTask' || functionName == 'updateTask' || functionName == 'createEvent' || functionName == 'updateEvent') {
        final title = functionArgs['title'] as String? ?? '';
        final startAt = functionArgs['startAt'] as String? ?? functionArgs['start_at'] as String? ?? '';
        final endAt = functionArgs['endAt'] as String? ?? functionArgs['end_at'] as String? ?? '';
        signature = '$functionName|$title|$startAt|$endAt';
      }

      // action_id와 signature 모두 확인하여 중복 제거
      if (!seenActionIds.contains(actionId) && !seenFunctionSignatures.contains(signature)) {
        seenActionIds.add(actionId);
        seenFunctionSignatures.add(signature);
        callsToExecute.add(call);
      }
    }

    if (callsToExecute.isEmpty) {
      return;
    }

    // 로딩 상태 시작 - entity block은 유지하고 로딩 메시지만 표시
    state = state.copyWith(isLoading: true);

    final executor = McpFunctionExecutor(ref);
    // 각 함수 호출의 결과를 직접 추적
    final functionResults = <Map<String, dynamic>>[];

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
        debugPrint('[AgentAction] confirmActions: 함수 실행 시작, functionName=$functionName, functionArgs=$functionArgs');
        // 함수 이름에 따라 적절한 tabType 결정
        final tabType = _getTabTypeForFunction(functionName);
        debugPrint('[AgentAction] confirmActions: tabType=$tabType');

        // 함수 실행
        debugPrint('[AgentAction] confirmActions: executor.executeFunction 호출 전');
        final result = await executor.executeFunction(
          functionName,
          functionArgs,
          tabType: tabType,
          availableTasks: updatedTaggedTasks,
          availableEvents: updatedTaggedEvents,
          availableConnections: taggedConnections,
          availableInboxes: updatedAvailableInboxes,
          remainingCredits: remainingCredits,
        );
        debugPrint('[AgentAction] confirmActions: executor.executeFunction 호출 완료, result=$result');

        if (result['success'] == true) {
          final message = result['message'] as String? ?? Utils.mainContext.tr.agent_action_task_completed;
          debugPrint('[AgentAction] confirmActions: 성공, functionName=$functionName, message=$message');
          functionResults.add({'function_name': functionName, 'success': true, 'message': message});
        } else {
          final error = result['error'] as String? ?? Utils.mainContext.tr.agent_action_error_occurred_during_execution;
          debugPrint('[AgentAction] confirmActions: 실패, functionName=$functionName, error=$error');
          functionResults.add({'function_name': functionName, 'success': false, 'error': error});
        }
      } catch (e, stackTrace) {
        debugPrint('[AgentAction] confirmActions: 예외 발생, functionName=$functionName, error=$e');
        debugPrint('[AgentAction] confirmActions: StackTrace: $stackTrace');
        functionResults.add({'function_name': functionName, 'success': false, 'error': e.toString()});
      }
    }

    // 함수 실행 결과를 AI에게 전달하여 적절한 메시지 생성
    String resultMessage;

    // 함수 실행 결과 요약 생성 - 실제 실행된 함수 호출 개수와 결과를 정확히 전달
    final functionResultsSummary = <String>[];
    for (final result in functionResults) {
      final functionName = result['function_name'] as String? ?? '';
      final success = result['success'] as bool? ?? false;

      if (success) {
        final message = result['message'] as String? ?? '';
        if (message.isNotEmpty) {
          functionResultsSummary.add('$functionName: $message');
        } else {
          functionResultsSummary.add('$functionName: completed successfully');
        }
      } else {
        final error = result['error'] as String? ?? '';
        functionResultsSummary.add('$functionName: failed - $error');
      }
    }

    // 실제 실행된 함수 호출 개수를 명확히 전달
    final executedCount = functionResults.length;
    final successCount = functionResults.where((r) => r['success'] == true).length;
    final errorCount = functionResults.where((r) => r['success'] == false).length;

    // 함수 실행 결과를 AI에게 전달하여 메시지 생성
    if (functionResultsSummary.isNotEmpty) {
      final functionResultsText = functionResultsSummary.join('\n');
      final functionResultsPrompt =
          'The following $executedCount function call(s) were executed (${successCount} succeeded, ${errorCount} failed):\n$functionResultsText\n\nPlease provide a natural, user-friendly message summarizing what was done. Be concise and clear. IMPORTANT: Use the exact number of function calls executed ($executedCount), not any other number.';

      // 함수 실행 결과를 포함한 메시지로 AI 호출
      final functionResultsMessages = [...state.messages, AgentActionMessage(role: 'user', content: functionResultsPrompt)];

      final me = ref.read(authControllerProvider).value;
      final userId = me?.id;
      final selectedModel = this.selectedModel;
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

      try {
        final functionResponse = await _repository.generateGeneralChat(
          userMessage: functionResultsPrompt,
          conversationHistory: functionResultsMessages.map((m) => m.toJson(local: true)).toList(),
          projectContext: null,
          taggedContext: null,
          channelContext: null,
          inboxContext: null,
          model: selectedModel.modelName,
          apiKey: apiKey,
          userId: userId,
          systemPrompt: 'You are a helpful assistant. Provide a brief, natural summary of the function execution results.',
        );

        final functionAiResponse = functionResponse.fold((failure) => null, (response) => response);
        if (functionAiResponse != null && functionAiResponse['message'] != null) {
          resultMessage = functionAiResponse['message'] as String;
          // 함수 호출 태그 제거
          resultMessage = resultMessage.replaceAll(RegExp(r'<function_call>.*?</function_call>', dotAll: true), '').trim();
        } else {
          // AI 호출 실패 시 기본 메시지 사용
          final successResults = functionResults.where((r) => r['success'] == true).toList();
          final errorResults = functionResults.where((r) => r['success'] == false).toList();
          if (errorResults.isEmpty) {
            final messages = successResults.map((r) => r['message'] as String? ?? '').where((m) => m.isNotEmpty).toList();
            resultMessage = messages.isNotEmpty ? messages.join('\n\n') : '';
          } else {
            final errors = errorResults.map((r) => '${r['function_name']}: ${r['error']}').toList();
            resultMessage = errors.join('\n\n');
          }
        }
      } catch (e) {
        // AI 호출 실패 시 기본 메시지 사용
        final successResults = functionResults.where((r) => r['success'] == true).toList();
        final errorResults = functionResults.where((r) => r['success'] == false).toList();
        if (errorResults.isEmpty) {
          final messages = successResults.map((r) => r['message'] as String? ?? '').where((m) => m.isNotEmpty).toList();
          resultMessage = messages.isNotEmpty ? messages.join('\n\n') : '';
        } else {
          final errors = errorResults.map((r) => '${r['function_name']}: ${r['error']}').toList();
          resultMessage = errors.join('\n\n');
        }
      }
    } else {
      // 함수 실행 결과가 없으면 기본 메시지 사용
      final successResults = functionResults.where((r) => r['success'] == true).toList();
      final errorResults = functionResults.where((r) => r['success'] == false).toList();
      if (errorResults.isEmpty) {
        final messages = successResults.map((r) => r['message'] as String? ?? '').where((m) => m.isNotEmpty).toList();
        resultMessage = messages.isNotEmpty ? messages.join('\n\n') : '';
      } else {
        final errors = errorResults.map((r) => '${r['function_name']}: ${r['error']}').toList();
        resultMessage = errors.join('\n\n');
      }
    }

    final assistantMessage = AgentActionMessage(role: 'assistant', content: resultMessage);
    final updatedMessages = [...state.messages, assistantMessage];

    // pendingFunctionCalls에서 실행된 항목 제거 (entity block은 유지)
    final updatedPendingCalls = pendingCalls.where((call) {
      final callActionId = call['action_id'] as String?;
      return callActionId == null || !actionIds.contains(callActionId);
    }).toList();

    state = state.copyWith(messages: updatedMessages, pendingFunctionCalls: updatedPendingCalls.isEmpty ? null : updatedPendingCalls, isLoading: false);

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
}
