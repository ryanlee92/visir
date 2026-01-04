import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:html_unescape/html_unescape.dart';
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
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_channel_entity.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/common/domain/entities/connection_entity.dart';
import 'package:Visir/features/common/domain/failures/failure.dart';
import 'package:Visir/features/chat/domain/entities/message_file_entity.dart';
import 'package:Visir/features/common/utils/ai_pricing_calculator.dart';
import 'package:Visir/features/auth/presentation/screens/ai_credits_screen.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/mail/providers.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'agent_action_controller.g.dart';

class AgentActionMessage {
  final String role; // 'user' or 'assistant'
  final String content;
  final bool excludeFromHistory; // conversation history에서 제외할지 여부 (함수 실행 결과 메시지용)
  final List<PlatformFile>? files; // 첨부된 파일 목록

  AgentActionMessage({required this.role, required this.content, this.excludeFromHistory = false, this.files});

  Map<String, dynamic> toJson({bool? local}) {
    return {
      'role': role,
      'content': content.isNotEmpty
          ? local == true
                ? content
                : Utils.encryptAESCryptoJS(content, aesKey)
          : '',
      'exclude_from_history': excludeFromHistory,
      'files': files?.map((f) => {'name': f.name, 'size': f.size, 'path': f.path, 'bytes': f.bytes != null ? base64Encode(f.bytes!) : null}).toList(),
    };
  }

  factory AgentActionMessage.fromJson(Map<String, dynamic> json, {bool? local, bool? isEncrypted}) {
    final contentStr = json['content'] as String? ?? '';
    // local이 true면 평문, false면 isEncrypted 플래그에 따라 복호화
    final decryptedContent = contentStr.isNotEmpty && local != true && (isEncrypted == true) ? Utils.decryptAESCryptoJS(contentStr, aesKey) : contentStr;

    // 파일 정보 복원
    List<PlatformFile>? files;
    if (json['files'] != null) {
      final filesList = json['files'] as List<dynamic>?;
      files = filesList?.map((f) {
        final fileMap = f as Map<String, dynamic>;
        Uint8List? bytes;
        if (fileMap['bytes'] != null) {
          bytes = base64Decode(fileMap['bytes'] as String);
        }
        return PlatformFile(name: fileMap['name'] as String? ?? '', size: fileMap['size'] as int? ?? 0, path: fileMap['path'] as String?, bytes: bytes);
      }).toList();
    }

    return AgentActionMessage(role: json['role'] as String, content: decryptedContent, excludeFromHistory: json['exclude_from_history'] as bool? ?? false, files: files);
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
  final List<String> recentTaskIds; // Recently created/updated task IDs (for AI context)
  final List<String> recentEventIds; // Recently created/updated event IDs (for AI context)

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
    List<String>? recentTaskIds,
    List<String>? recentEventIds,
  }) : messages = messages ?? [],
       loadedInboxNumbers = loadedInboxNumbers ?? {},
       selectedActionIds = selectedActionIds ?? {},
       recentTaskIds = recentTaskIds ?? [],
       recentEventIds = recentEventIds ?? [];

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
    List<String>? recentTaskIds,
    List<String>? recentEventIds,
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
      recentTaskIds: recentTaskIds ?? this.recentTaskIds,
      recentEventIds: recentEventIds ?? this.recentEventIds,
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
    List<PlatformFile>? files,
  }) async {
    if (userMessage.trim().isEmpty && (files == null || files.isEmpty)) return;

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
    final updatedMessages = [...state.messages, AgentActionMessage(role: 'user', content: messageWithTags, files: files)];
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
        files: files,
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
    List<PlatformFile>? files,
    bool isRecursiveCall = false, // 재귀 호출 방지 플래그
  }) async {
    // 파일 정보를 메시지에 추가 (인박스 첨부 파일 포함)
    String enhancedUserMessage = userMessage;

    // 사용자가 직접 첨부한 파일만 사용 (인박스 첨부 파일은 AI가 요청할 때만 다운로드)
    final allFiles = files ?? [];

    if (allFiles.isNotEmpty) {
      // 파일 정보를 상세하게 추가 (AI가 파일을 인식할 수 있도록)
      final fileInfoList = allFiles
          .map((f) {
            final sizeKB = (f.size / 1024).toStringAsFixed(1);
            final isImage = f.isImage;
            final isVideo = f.isVideo;
            String typeInfo = '';
            if (isImage) {
              typeInfo = ' (이미지 파일)';
            } else if (isVideo) {
              typeInfo = ' (비디오 파일)';
            } else if (f.name.toLowerCase().endsWith('.pdf')) {
              typeInfo = ' (PDF 문서)';
            } else if (f.name.toLowerCase().endsWith('.txt') || f.name.toLowerCase().endsWith('.md')) {
              typeInfo = ' (텍스트 파일)';
            }
            return '파일명: ${f.name}${typeInfo}, 크기: ${sizeKB} KB';
          })
          .join('\n');
      // 파일 정보만 제공하고, AI가 판단하도록 함 (룰베이스 제거)
      enhancedUserMessage = '$userMessage\n\n[첨부된 파일 정보]\n$fileInfoList';
    }

    // updatedMessages가 제공되지 않으면 새로 생성 (파일 정보 포함)
    final messages = updatedMessages ?? [...state.messages, AgentActionMessage(role: 'user', content: enhancedUserMessage, files: allFiles.isNotEmpty ? allFiles : files)];

    // 디버깅: _generateGeneralChat 시작 시 state 확인

    // 재귀 호출인 경우, conversation history의 마지막 user 메시지를 사용
    // (이미 updatedMessages에 첫 번째 응답이 포함되어 있으므로, 같은 userMessage를 다시 추가하지 않음)
    // 파일 정보가 포함된 enhancedUserMessage를 유지
    if (isRecursiveCall && updatedMessages != null && messages.isNotEmpty) {
      final lastUserMessage = messages.lastWhere(
        (m) => m.role == 'user',
        orElse: () => AgentActionMessage(role: 'user', content: enhancedUserMessage, files: files),
      );
      // 재귀 호출인 경우에도 파일 정보가 포함된 메시지 사용
      enhancedUserMessage = lastUserMessage.content;
    }

    // 룰베이스 제거: 키워드 기반 자동 감지 제거, AI가 판단하도록 함
    // 사용자가 명시적으로 요청하거나 AI가 <need_more_action> 태그를 사용할 때만 처리

    // state.messages를 항상 업데이트하여 _saveChatHistory가 최신 메시지를 사용하도록 함
    state = state.copyWith(messages: messages, isLoading: true);

    try {
      // 첫 메시지인지 확인 (user 메시지 1개만 있는 경우)
      final isFirstMessage = messages.length == 1 && messages.first.role == 'user';

      // Project context 가져오기
      final projectContext = await _buildProjectContext(selectedProject);

      // Projects 리스트 가져오기 (Available Projects 리스트 제공용)
      final projects = ref.read(projectListControllerProvider);
      final projectsList = projects.map((p) => {'id': p.uniqueId, 'name': p.name, 'description': p.description, 'parent_id': p.parentId}).toList();

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
        // 첨부 파일 정보는 항상 포함 (AI가 판단할 수 있도록)
        inboxContext = await _buildInboxContext(
          inboxes,
          summaryOnly: summaryOnly,
          requestedInboxNumbers: requestedNumbers,
          includeAttachmentInfo: true, // 항상 첨부 파일 정보 포함하여 AI가 판단하도록
        );
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

      // 최근 생성/수정된 taskId/eventId를 system prompt에 추가 (AI가 참조할 수 있도록)
      // IMPORTANT: state.recentTaskIds/recentEventIds를 직접 참조하여 최신 상태 사용
      final currentState = state; // 최신 state 참조
      if (currentState.recentTaskIds.isNotEmpty || currentState.recentEventIds.isNotEmpty) {
        String contextInfo = '\n\n## CRITICAL: Recent Task/Event IDs (MUST USE THESE WHEN USER REQUESTS MODIFICATIONS):';
        if (currentState.recentTaskIds.isNotEmpty) {
          // 가장 최근 taskId를 명확히 표시
          final mostRecentTaskId = currentState.recentTaskIds.last;
          contextInfo += '\n- MOST RECENT task ID: $mostRecentTaskId (use this EXACT one!)';
          if (currentState.recentTaskIds.length > 1) {
            contextInfo += '\n- All recent task IDs: ${currentState.recentTaskIds.join(', ')}';
            contextInfo += '\n  The LAST one in the list ($mostRecentTaskId) is the MOST RECENT.';
          }
          contextInfo += '\n  These taskIds were JUST created/updated in this conversation.';
          contextInfo += '\n  When user says "이거 프로젝트로 바꿔줘", "change this to project X", "이거 visir 프로젝트로 변경해줘", etc., you MUST use this EXACT taskId: $mostRecentTaskId';
          contextInfo += '\n  DO NOT say "taskId가 보이지 않아서" or "taskId가 이 대화에 표시되어 있지 않아서" - the taskId is RIGHT HERE: $mostRecentTaskId';
          contextInfo += '\n  DO NOT create a new task - use updateTask with taskId: $mostRecentTaskId';
        }
        if (currentState.recentEventIds.isNotEmpty) {
          // 가장 최근 eventId를 명확히 표시
          final mostRecentEventId = currentState.recentEventIds.last;
          contextInfo += '\n- MOST RECENT event ID: $mostRecentEventId (use this EXACT one!)';
          if (currentState.recentEventIds.length > 1) {
            contextInfo += '\n- All recent event IDs: ${currentState.recentEventIds.join(', ')}';
            contextInfo += '\n  The LAST one in the list ($mostRecentEventId) is the MOST RECENT.';
          }
          contextInfo += '\n  These eventIds were JUST created/updated in this conversation.';
          contextInfo += '\n  When user requests to modify an event, use this EXACT eventId: $mostRecentEventId';
          contextInfo += '\n  DO NOT say "eventId가 보이지 않아서" - the eventId is RIGHT HERE: $mostRecentEventId';
          contextInfo += '\n  DO NOT create a new event - use updateEvent with eventId: $mostRecentEventId';
        }
        contextInfo += '\n\n## CRITICAL RULE: Understanding User Intent for Task/Event Actions';
        contextInfo += '\nWhen recentTaskIds/recentEventIds are provided above, you MUST carefully analyze the user\'s request to determine their intent:';
        contextInfo += '\n1. **MODIFICATION REQUEST** (use updateTask/updateEvent):';
        contextInfo +=
            '\n   - User wants to modify/change an EXISTING task/event (e.g., "이거 프로젝트로 바꿔줘", "change this to project X", "이거 visir 프로젝트로 변경해줘", "음.. 이거 visir 프로젝트로 옮겨줘", "이거 옮겨줘", "이거 바꿔줘", "이거 수정해줘")';
        contextInfo += '\n   - User refers to a task/event that was JUST created (e.g., "방금 만든 거", "지금 만든 거", "이거")';
        contextInfo += '\n   - **ACTION**: Use updateTask/updateEvent with the MOST RECENT taskId/eventId from above';
        contextInfo += '\n   - **DO NOT** call createTask/createEvent - the task/event already exists';
        contextInfo += '\n2. **NEW CREATION REQUEST** (use createTask/createEvent):';
        contextInfo += '\n   - User explicitly asks to create a NEW task/event (e.g., "하나 더 만들어줘", "또 하나 생성해줘", "새로운 테스크 만들어줘", "create another one", "make one more")';
        contextInfo += '\n   - User provides completely new task/event details that are different from the recent one';
        contextInfo += '\n   - **ACTION**: Call createTask/createEvent with the new details';
        contextInfo += '\n3. **KEY PRINCIPLE**: Base your decision on the USER\'S EXPLICIT REQUEST, not on whether recentTaskIds exists.';
        contextInfo += '\n   - If user says "이거 바꿔줘" → use updateTask (modification)';
        contextInfo += '\n   - If user says "하나 더 만들어줘" → use createTask (new creation)';
        contextInfo += '\n   - If user says "이거 visir 프로젝트로 옮겨줘" → use updateTask (modification)';
        contextInfo += '\n   - If user says "새로운 테스크 만들어줘" → use createTask (new creation)';
        contextInfo += '\n4. **WHEN TO USE MOST RECENT ID**: Only when the user\'s request is clearly a MODIFICATION request.';
        contextInfo += '\n5. **WHEN TO CREATE NEW**: Only when the user explicitly asks for a NEW task/event to be created.';
        systemPrompt += contextInfo;
      }

      // 첫 메시지이고 conversationSummary가 없으면 제목 생성 요청 추가
      if (isFirstMessage && state.conversationSummary == null && state.actionType == null) {
        systemPrompt +=
            '\n\n## Important: This is the first message in the conversation. Please include a conversation title at the very beginning of your response in the following format:\n<conversation_title>Title here (max 30 characters)</conversation_title>\nThen provide your normal response.';
      }

      // 일반적인 AI 응답 생성 (MCP 함수 호출 지원)
      // AI에 전달할 때는 평문이어야 하므로 local: true 사용
      // 재귀 호출인 경우 conversation history의 마지막 user 메시지를 사용
      // conversation history에서 함수 실행 결과 메시지 제거 (excludeFromHistory 플래그 사용)
      // 룰베이스 제거: 함수 호출 태그나 JSON 배열 제거하지 않음
      final filteredHistory = messages
          .where((m) => !m.excludeFromHistory) // excludeFromHistory가 true인 메시지는 제외
          .map((m) => m.toJson(local: true))
          .toList();

      // 최근 생성된 taskId/eventId를 user message에 추가하여 AI가 직접 참조할 수 있도록 함
      // IMPORTANT: state.recentTaskIds/recentEventIds를 직접 참조하여 최신 상태 사용
      // 파일 정보가 포함된 enhancedUserMessage를 유지하면서 contextSuffix만 추가
      final latestState = state; // 최신 state 참조
      if (latestState.recentTaskIds.isNotEmpty || latestState.recentEventIds.isNotEmpty) {
        String contextSuffix = '';
        if (latestState.recentTaskIds.isNotEmpty) {
          // 가장 최근 taskId를 명확히 표시 (리스트의 마지막 항목)
          final mostRecentTaskId = latestState.recentTaskIds.last;
          contextSuffix +=
              '\n\n[CRITICAL CONTEXT: The MOST RECENT task ID is: $mostRecentTaskId. This task was JUST created/updated in this conversation. Analyze the user\'s request carefully: 1) If user wants to MODIFY this task (e.g., "이거 visir 프로젝트로 변경해줘", "이거 프로젝트로 바꿔줘", "음.. 이거 visir 프로젝트로 옮겨줘", "이거 옮겨줘", "이거 바꿔줘"), use updateTask with taskId: $mostRecentTaskId. 2) If user explicitly asks to CREATE A NEW task (e.g., "하나 더 만들어줘", "또 하나 생성해줘", "새로운 테스크 만들어줘"), use createTask. Base your decision on the USER\'S EXPLICIT REQUEST, not on whether recentTaskIds exists. The taskId $mostRecentTaskId is available if you need to modify the existing task.]';
          if (latestState.recentTaskIds.length > 1) {
            contextSuffix += '\n[All recent task IDs: ${latestState.recentTaskIds.join(', ')}. The last one ($mostRecentTaskId) is the most recent.]';
          }
        }
        if (latestState.recentEventIds.isNotEmpty) {
          // 가장 최근 eventId를 명확히 표시 (리스트의 마지막 항목)
          final mostRecentEventId = latestState.recentEventIds.last;
          contextSuffix +=
              '\n\n[CRITICAL CONTEXT: The MOST RECENT event ID is: $mostRecentEventId. When user requests to modify an event, you MUST use this EXACT eventId: $mostRecentEventId. DO NOT create a new event - use updateEvent with eventId: $mostRecentEventId. DO NOT say "eventId가 보이지 않아서" - the eventId is RIGHT HERE: $mostRecentEventId.]';
          if (latestState.recentEventIds.length > 1) {
            contextSuffix += '\n[All recent event IDs: ${latestState.recentEventIds.join(', ')}. The last one ($mostRecentEventId) is the most recent.]';
          }
        }
        enhancedUserMessage = enhancedUserMessage + contextSuffix;
      }

      final response = await _repository.generateGeneralChat(
        userMessage: enhancedUserMessage,
        conversationHistory: filteredHistory,
        projectContext: projectContext,
        projects: projectsList,
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

        // HTML 엔티티 unescape 처리
        final unescape = HtmlUnescape();
        aiMessage = unescape.convert(aiMessage);

        // 첫 메시지인 경우 conversation_title 태그에서 제목 추출
        if (isFirstMessage && state.conversationSummary == null && state.actionType == null) {
          // conversation_title 태그에서 제목 추출
          final conversationTitleRegex = RegExp(r'<conversation_title>(.*?)</conversation_title>', dotAll: true);
          final escapedTitleRegex = RegExp(r'&lt;conversation_title&gt;(.*?)&lt;/conversation_title&gt;', dotAll: true);

          String? extractedTitle;
          final titleMatch = conversationTitleRegex.firstMatch(aiMessage);
          if (titleMatch != null) {
            extractedTitle = titleMatch.group(1)?.trim();
          } else {
            final escapedMatch = escapedTitleRegex.firstMatch(aiMessage);
            if (escapedMatch != null) {
              extractedTitle = escapedMatch.group(1)?.trim();
            }
          }

          if (extractedTitle != null && extractedTitle.isNotEmpty) {
            // 최대 50자로 제한
            String finalTitle = extractedTitle.length > 50 ? '${extractedTitle.substring(0, 47)}...' : extractedTitle;
            state = state.copyWith(conversationSummary: finalTitle);
          } else {
            // conversation_title이 없으면 AI 응답의 처음 부분을 제목으로 사용
            final firstLine = aiMessage.split('\n').first.trim();
            if (firstLine.isNotEmpty && !firstLine.contains('conversation_title')) {
              String finalTitle = firstLine.length > 50 ? '${firstLine.substring(0, 47)}...' : firstLine;
              state = state.copyWith(conversationSummary: finalTitle);
            }
          }
        }

        // conversation_title 태그를 제거 (제목 추출 후)
        aiMessage = aiMessage.replaceAll(RegExp(r'<conversation_title>.*?</conversation_title>', dotAll: true), '');
        aiMessage = aiMessage.replaceAll(RegExp(r'&lt;conversation_title&gt;.*?&lt;/conversation_title&gt;', dotAll: true), '');

        // MCP 함수 호출 감지 및 실행
        final executor = McpFunctionExecutor();
        final allFunctionCalls = executor.parseFunctionCalls(aiMessage);

        // 중복 함수 호출 제거 (AI가 스스로 판단하도록 룰베이스 제거)
        final functionCalls = <Map<String, dynamic>>[];
        final seenFunctionSignatures = <String>{};
        for (final call in allFunctionCalls) {
          final functionName = call['function'] as String? ?? '';
          final functionArgs = call['arguments'] as Map<String, dynamic>? ?? {};

          // signature 생성 (중복 확인용)
          String signature = functionName;
          if (functionName == 'createTask' || functionName == 'updateTask' || functionName == 'createEvent' || functionName == 'updateEvent') {
            final title = functionArgs['title'] as String? ?? '';
            final taskId = functionArgs['taskId'] as String? ?? '';
            final eventId = functionArgs['eventId'] as String? ?? '';
            final startAt = functionArgs['startAt'] as String? ?? functionArgs['start_at'] as String? ?? '';
            final endAt = functionArgs['endAt'] as String? ?? functionArgs['end_at'] as String? ?? '';
            signature = '$functionName|$taskId|$eventId|$title|$startAt|$endAt';
          } else {
            // 다른 함수들은 arguments 전체를 signature로 사용
            signature = '$functionName|${jsonEncode(functionArgs)}';
          }

          if (!seenFunctionSignatures.contains(signature)) {
            seenFunctionSignatures.add(signature);
            functionCalls.add(call);
          }
        }

        // 룰베이스 제거: 함수 호출 태그나 JSON 배열 제거하지 않음
        String aiMessageWithoutFunctionCalls = aiMessage;

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
                final taskId = result['taskId'] as String?;
                final eventId = result['eventId'] as String?;

                // createTask 실행 후 새로 생성된 Task를 updatedTaggedTasks에 추가
                if (functionName == 'createTask' && taskId != null && taskId.isNotEmpty) {
                  // Task가 저장될 때까지 약간의 지연 (provider 업데이트 대기)
                  await Future.delayed(const Duration(milliseconds: 100));
                  final allTasks = ref.read(taskListControllerProvider).tasks;
                  final createdTask = allTasks.firstWhereOrNull((task) => task.id == taskId && !task.isEventDummyTask);
                  if (createdTask != null) {
                    final existingIds = updatedTaggedTasks?.map((e) => e.id).toSet() ?? {};
                    if (!existingIds.contains(createdTask.id)) {
                      updatedTaggedTasks = [...(updatedTaggedTasks ?? []), createdTask];
                    }
                  }
                }

                // createEvent 실행 후 새로 생성된 Event를 updatedTaggedEvents에 추가
                if (functionName == 'createEvent' && eventId != null && eventId.isNotEmpty) {
                  // Event가 저장될 때까지 약간의 지연 (provider 업데이트 대기)
                  await Future.delayed(const Duration(milliseconds: 100));
                  final allEvents = ref.read(calendarEventListControllerProvider(tabType: TabType.home)).eventsOnView;
                  final createdEvent = allEvents.firstWhereOrNull((event) => event.eventId == eventId || event.uniqueId == eventId);
                  if (createdEvent != null) {
                    final existingIds = updatedTaggedEvents?.map((e) => e.uniqueId).toSet() ?? {};
                    if (!existingIds.contains(createdEvent.uniqueId)) {
                      updatedTaggedEvents = [...(updatedTaggedEvents ?? []), createdEvent];
                    }
                  }
                }

                var messageWithId = successMessage;
                if (taskId != null && taskId.isNotEmpty) {
                  messageWithId += ' (taskId: $taskId)';
                }
                if (eventId != null && eventId.isNotEmpty) {
                  messageWithId += ' (eventId: $eventId)';
                }
                successMessages.add(messageWithId);
              } else if (result['success'] == true) {
                final successMessage = result['message'] as String? ?? Utils.mainContext.tr.agent_action_task_completed;
                final taskId = result['taskId'] as String?;
                final eventId = result['eventId'] as String?;

                // createTask 실행 후 새로 생성된 Task를 updatedTaggedTasks에 추가
                if (functionName == 'createTask' && taskId != null && taskId.isNotEmpty) {
                  // Task가 저장될 때까지 약간의 지연 (provider 업데이트 대기)
                  await Future.delayed(const Duration(milliseconds: 100));
                  final allTasks = ref.read(taskListControllerProvider).tasks;
                  final createdTask = allTasks.firstWhereOrNull((task) => task.id == taskId && !task.isEventDummyTask);
                  if (createdTask != null) {
                    final existingIds = updatedTaggedTasks?.map((e) => e.id).toSet() ?? {};
                    if (!existingIds.contains(createdTask.id)) {
                      updatedTaggedTasks = [...(updatedTaggedTasks ?? []), createdTask];
                    }
                  }
                }

                // createEvent 실행 후 새로 생성된 Event를 updatedTaggedEvents에 추가
                if (functionName == 'createEvent' && eventId != null && eventId.isNotEmpty) {
                  // Event가 저장될 때까지 약간의 지연 (provider 업데이트 대기)
                  await Future.delayed(const Duration(milliseconds: 100));
                  final allEvents = ref.read(calendarEventListControllerProvider(tabType: TabType.home)).eventsOnView;
                  final createdEvent = allEvents.firstWhereOrNull((event) => event.eventId == eventId || event.uniqueId == eventId);
                  if (createdEvent != null) {
                    final existingIds = updatedTaggedEvents?.map((e) => e.uniqueId).toSet() ?? {};
                    if (!existingIds.contains(createdEvent.uniqueId)) {
                      updatedTaggedEvents = [...(updatedTaggedEvents ?? []), createdEvent];
                    }
                  }
                }

                var messageWithId = successMessage;
                if (taskId != null && taskId.isNotEmpty) {
                  messageWithId += ' (taskId: $taskId)';
                }
                if (eventId != null && eventId.isNotEmpty) {
                  messageWithId += ' (eventId: $eventId)';
                }
                successMessages.add(messageWithId);
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

          // 메시지가 비어있으면 AI에게 메시지 생성 요청
          if (resultMessage.trim().isEmpty) {
            if (hasPendingCalls) {
              // 확인이 필요한 함수가 있는 경우, AI에게 확인 메시지 생성 요청
              final pendingFunctionNames = pendingCallsForMessage.map((call) => call['function_name'] as String? ?? '').where((name) => name.isNotEmpty).toList();
              if (pendingFunctionNames.isNotEmpty) {
                // pendingFunctionCalls 정보를 AI에게 전달하여 확인 메시지 생성
                final pendingCallsInfo = pendingCallsForMessage
                    .map((call) {
                      final functionName = call['function_name'] as String? ?? '';
                      final functionArgs = call['function_args'] as Map<String, dynamic>? ?? {};
                      return '$functionName: ${functionArgs.toString()}';
                    })
                    .join('\n');

                final confirmationPrompt =
                    'The following ${pendingFunctionNames.length} function call(s) are waiting for user confirmation:\n$pendingCallsInfo\n\nPlease provide a natural, user-friendly message informing the user that these actions are prepared and waiting for confirmation. Be concise and clear. Do NOT mention "from the inbox item" unless the action is specifically related to creating a task or event from an inbox item.';

                try {
                  final me = ref.read(authControllerProvider).value;
                  final userId = me?.id;
                  final selectedModel = this.selectedModel;
                  String? apiKey;
                  if (useUserApiKey) {
                    final apiKeys = ref.read(aiApiKeysProvider);
                    apiKey = apiKeys[selectedModel.provider.name];
                  } else {
                    try {
                      final configFile = await rootBundle.loadString('assets/config/${F.envFileName}');
                      final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);
                      apiKey = env.openAiApiKey.isNotEmpty ? env.openAiApiKey : null;
                    } catch (e) {
                      // 환경 변수 읽기 실패
                    }
                  }

                  final projects = ref.read(projectListControllerProvider);
                  final projectsList = projects.map((p) => {'id': p.uniqueId, 'name': p.name, 'description': p.description, 'parent_id': p.parentId}).toList();

                  final confirmationMessages = [...messages, AgentActionMessage(role: 'user', content: confirmationPrompt)];

                  // conversation history에서 함수 실행 결과 메시지 제거 (excludeFromHistory 플래그 사용)
                  // 룰베이스 제거: 함수 호출 태그나 JSON 배열 제거하지 않음
                  final filteredConfirmationHistory = confirmationMessages
                      .where((m) => !m.excludeFromHistory) // excludeFromHistory가 true인 메시지는 제외
                      .map((m) => m.toJson(local: true))
                      .toList();

                  final confirmationResponse = await _repository.generateGeneralChat(
                    userMessage: confirmationPrompt,
                    conversationHistory: filteredConfirmationHistory,
                    projectContext: null,
                    projects: projectsList,
                    taggedContext: null,
                    channelContext: null,
                    inboxContext: null,
                    model: selectedModel.modelName,
                    apiKey: apiKey,
                    userId: userId,
                    systemPrompt:
                        'You are a helpful assistant. Provide a brief, natural message informing the user that actions are prepared and waiting for confirmation. Be concise and clear. Do NOT mention "from the inbox item" unless the action is specifically related to creating a task or event from an inbox item.\n\nABSOLUTE RULE: DO NOT call any functions. Only provide a message describing what actions are waiting for confirmation. DO NOT call createTask, updateTask, or any other functions.',
                  );

                  final confirmationAiResponse = confirmationResponse.fold((failure) => null, (response) => response);
                  if (confirmationAiResponse != null && confirmationAiResponse['message'] != null) {
                    resultMessage = confirmationAiResponse['message'] as String;
                    // HTML 엔티티 unescape 처리
                    final unescape = HtmlUnescape();
                    resultMessage = unescape.convert(resultMessage);
                    // 룰베이스 제거: 함수 호출 태그 제거하지 않음
                  } else {
                    // AI 호출 실패 시 기본 메시지 사용
                    resultMessage = 'An action has been prepared and is waiting for your confirmation. Once you confirm, it will be executed.';
                  }
                } catch (e) {
                  // AI 호출 실패 시 기본 메시지 사용
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

          // 히스토리 저장
          _saveChatHistory(taggedProjects: taggedProjects);
        } else {
          // 일반 응답
          final assistantMessage = AgentActionMessage(role: 'assistant', content: aiMessage);
          final updatedMessagesWithResponse = [...messages, assistantMessage];

          // AI 응답에서 <need_attachment> 태그 파싱하여 첨부 파일 다운로드
          if (!isRecursiveCall && inboxes != null && inboxes.isNotEmpty) {
            final inboxAttachmentFiles = await _fetchInboxAttachmentsFromAiResponse(aiMessage, inboxes);

            if (inboxAttachmentFiles.isNotEmpty) {
              // 첨부 파일이 다운로드되었으면 파일과 함께 재요청
              await _generateGeneralChat(
                userMessage,
                selectedProject: selectedProject,
                updatedMessages: updatedMessagesWithResponse,
                taggedTasks: taggedTasks,
                taggedEvents: taggedEvents,
                taggedConnections: taggedConnections,
                taggedChannels: taggedChannels,
                taggedProjects: taggedProjects,
                inboxes: inboxes,
                files: inboxAttachmentFiles, // 다운로드한 첨부 파일 전달
                isRecursiveCall: true,
              );
              return;
            }
          }

          // need_more_action 태그 파싱 (기존 로직 유지)
          if (!isRecursiveCall) {
            final needMoreActionData = _parseNeedMoreActionTag(aiMessage);

            if (needMoreActionData != null && inboxes != null && inboxes.isNotEmpty) {
              // 태그에서 inbox 번호 추출
              Set<int> allRequestedNumbers = needMoreActionData['inbox_numbers'] as Set<int>? ?? {};

              // 룰베이스 제거: 키워드 기반 자동 감지 제거, AI가 태그로 명시적으로 요청할 때만 처리

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

          // 히스토리 저장
          _saveChatHistory(taggedProjects: taggedProjects);
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
  /// [includeAttachmentInfo]: 첨부 파일 정보를 포함할지 여부 (기본값: false, 사용자 요청이 있을 때만 true)
  Future<String> _buildInboxContext(
    List<InboxEntity> inboxes, {
    bool summaryOnly = true,
    Set<int> requestedInboxNumbers = const {},
    int? maxItems,
    bool includeAttachmentInfo = false,
  }) async {
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

        // 첨부 파일 정보 추가 (includeAttachmentInfo가 true일 때만, 사용자 요청이 있을 때만)
        if (includeAttachmentInfo) {
          try {
            // 메일 첨부 파일 정보
            final mailEntity = await _getMailEntityFromInbox(inbox);
            if (mailEntity != null) {
              final attachments = mailEntity.getAttachments();
              if (attachments.isNotEmpty) {
                buffer.writeln('- Attachments: ${attachments.length} file(s)');
                for (final attachment in attachments) {
                  final fileName = attachment.name;
                  final mimeType = attachment.mimeType;
                  String fileType = '';
                  if (fileName.toLowerCase().endsWith('.pdf')) {
                    fileType = ' (PDF)';
                  } else if (mimeType.startsWith('image/')) {
                    fileType = ' (Image)';
                  } else if (mimeType.startsWith('video/')) {
                    fileType = ' (Video)';
                  } else if (mimeType.startsWith('text/')) {
                    fileType = ' (Text)';
                  }
                  buffer.writeln('  - $fileName$fileType');
                }
              }
            }
          } catch (e) {
            // 첨부 파일 정보를 가져오는 데 실패해도 계속 진행
          }
        }
      } else if (inbox.linkedMessage != null) {
        final message = inbox.linkedMessage!;
        buffer.writeln('- Type: Message');
        buffer.writeln('- From: ${message.userName}');
        buffer.writeln('- Channel: ${message.channelName}');
        buffer.writeln('- Date: ${inbox.inboxDatetime.toIso8601String()}');

        // 첨부 파일 정보 추가 (includeAttachmentInfo가 true일 때만)
        if (includeAttachmentInfo) {
          try {
            // 메시지 첨부 파일 정보
            final messageEntity = await _getMessageEntityFromInbox(inbox);
            if (messageEntity != null) {
              final files = messageEntity.files;
              if (files.isNotEmpty) {
                buffer.writeln('- Attachments: ${files.length} file(s)');
                for (final file in files) {
                  final fileName = file.name ?? 'unknown';
                  final mimeType = file.slackFile?.mimetype ?? '';
                  String fileType = '';
                  if (fileName.toLowerCase().endsWith('.pdf')) {
                    fileType = ' (PDF)';
                  } else if (file.isImage) {
                    fileType = ' (Image)';
                  } else if (file.isVideo) {
                    fileType = ' (Video)';
                  } else if (file.isAudio) {
                    fileType = ' (Audio)';
                  } else if (mimeType.startsWith('text/')) {
                    fileType = ' (Text)';
                  }
                  buffer.writeln('  - $fileName$fileType');
                }
              }
            }
          } catch (e) {
            // 첨부 파일 정보를 가져오는 데 실패해도 계속 진행
          }
        }

        if (shouldIncludeFullContent) {
          // 전체 내용 포함
          if (inbox.description != null && inbox.description!.isNotEmpty) {
            buffer.writeln('- Full Content:');
            buffer.writeln(inbox.description!);
          }
          final mail = inbox.linkedMail!;
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
        buffer.writeln('- From: ${message.userName}');
        buffer.writeln('- Channel: ${message.channelName}');
        buffer.writeln('- Date: ${inbox.inboxDatetime.toIso8601String()}');

        // 첨부 파일 정보 추가 (includeAttachmentInfo가 true일 때만)
        if (includeAttachmentInfo) {
          try {
            // 메시지 첨부 파일 정보
            final messageEntity = await _getMessageEntityFromInbox(inbox);
            if (messageEntity != null) {
              final files = messageEntity.files;
              if (files.isNotEmpty) {
                buffer.writeln('- Attachments: ${files.length} file(s)');
                for (final file in files) {
                  final fileName = file.name ?? 'unknown';
                  final mimeType = file.slackFile?.mimetype ?? '';
                  String fileType = '';
                  if (fileName.toLowerCase().endsWith('.pdf')) {
                    fileType = ' (PDF)';
                  } else if (file.isImage) {
                    fileType = ' (Image)';
                  } else if (file.isVideo) {
                    fileType = ' (Video)';
                  } else if (file.isAudio) {
                    fileType = ' (Audio)';
                  } else if (mimeType.startsWith('text/')) {
                    fileType = ' (Text)';
                  }
                  buffer.writeln('  - $fileName$fileType');
                }
              }
            }
          } catch (e) {
            // 첨부 파일 정보를 가져오는 데 실패해도 계속 진행
          }
        }

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
      } else if (inbox.linkedMessage != null) {
        final message = inbox.linkedMessage!;
        buffer.writeln('- Type: Message');
        buffer.writeln('- From: ${message.userName}');
        buffer.writeln('- Channel: ${message.channelName}');
        buffer.writeln('- Date: ${inbox.inboxDatetime.toIso8601String()}');

        // 첨부 파일 정보 추가 (includeAttachmentInfo가 true일 때만)
        if (includeAttachmentInfo) {
          try {
            // 메시지 첨부 파일 정보
            final messageEntity = await _getMessageEntityFromInbox(inbox);
            if (messageEntity != null) {
              final files = messageEntity.files;
              if (files.isNotEmpty) {
                buffer.writeln('- Attachments: ${files.length} file(s)');
                for (final file in files) {
                  final fileName = file.name ?? 'unknown';
                  final mimeType = file.slackFile?.mimetype ?? '';
                  String fileType = '';
                  if (fileName.toLowerCase().endsWith('.pdf')) {
                    fileType = ' (PDF)';
                  } else if (file.isImage) {
                    fileType = ' (Image)';
                  } else if (file.isVideo) {
                    fileType = ' (Video)';
                  } else if (file.isAudio) {
                    fileType = ' (Audio)';
                  } else if (mimeType.startsWith('text/')) {
                    fileType = ' (Text)';
                  }
                  buffer.writeln('  - $fileName$fileType');
                }
              }
            }
          } catch (e) {
            // 첨부 파일 정보를 가져오는 데 실패해도 계속 진행
          }
        }

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

  /// InboxEntity에서 MailEntity를 가져옵니다.
  Future<MailEntity?> _getMailEntityFromInbox(InboxEntity inbox) async {
    if (inbox.linkedMail == null) return null;

    try {
      final mail = inbox.linkedMail!;
      final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.mailOAuths)) ?? [];
      final oauth = oauths.firstWhereOrNull((o) => o.email == mail.hostMail);
      if (oauth == null) return null;

      final mailRepository = ref.read(mailRepositoryProvider);
      final mailType = MailEntityTypeX.fromOAuthType(oauth.type);

      // 메일을 가져오기 위해 threadId를 사용
      final threadResult = await mailRepository.fetchThreads(
        oauth: oauth,
        type: mailType,
        threadId: mail.threadId,
        email: mail.hostMail,
        labelId: mail.labelIds?.firstOrNull ?? CommonMailLabels.inbox.id,
      );

      return threadResult.fold((failure) => null, (mails) => mails.firstWhereOrNull((m) => m.id == mail.messageId));
    } catch (e) {
      return null;
    }
  }

  /// 인박스에서 메시지 엔티티를 가져옵니다.
  Future<MessageEntity?> _getMessageEntityFromInbox(InboxEntity inbox) async {
    if (inbox.linkedMessage == null) return null;

    try {
      final message = inbox.linkedMessage!;
      final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.messengerOAuths)) ?? [];
      final oauth = oauths.firstWhereOrNull((o) => o.teamId == message.teamId);
      if (oauth == null) return null;

      final chatRepository = ref.read(chatRepositoryProvider);

      // user 정보 가져오기 (_buildChannelContext와 동일한 방식)
      final me = ref.read(authControllerProvider).value;
      if (me == null) return null;

      // MessageChannelEntity 생성에 필요한 정보 가져오기
      // inbox_list_controller.dart와 동일한 방식 사용
      final channelMap = ref.read(chatChannelListControllerProvider);
      final channelList = channelMap[message.teamId]?.channels ?? [];
      final channelData = channelList.firstWhereOrNull((c) => c.id == message.channelId);

      MessageChannelEntity channel;
      if (channelData != null) {
        channel = channelData;
      } else {
        // 채널 정보가 없으면 기본값으로 생성
        final slackChannel = SlackMessageChannelEntity(teamId: message.teamId, id: message.channelId, name: message.channelName, isIm: message.isDm ?? false);
        channel = MessageChannelEntity(type: MessageChannelEntityType.slack, teamId: message.teamId, meId: me.id, slackChannel: slackChannel);
      }

      final result = await chatRepository.fetchMessageForInbox(
        oauth: oauth,
        user: me,
        channels: [channel],
        q: '',
        startDate: message.date.subtract(const Duration(days: 1)),
        endDate: message.date.add(const Duration(days: 1)),
      );

      return result.fold((failure) => null, (fetchResult) => fetchResult.messages.firstWhereOrNull((m) => m.id == message.messageId));
    } catch (e) {
      return null;
    }
  }

  /// AI 응답에서 <need_attachment> 태그를 파싱하여 첨부 파일을 다운로드합니다.
  /// AI가 첨부 파일이 필요하다고 판단하면 이 태그를 사용하여 요청합니다.
  Future<List<PlatformFile>> _fetchInboxAttachmentsFromAiResponse(String aiResponse, List<InboxEntity>? inboxes) async {
    if (inboxes == null || inboxes.isEmpty) return [];

    // <need_attachment> 태그 파싱
    final RegExp attachmentTagRegex = RegExp(r'<need_attachment>\s*\{[^}]*"inbox_numbers"\s*:\s*\[([^\]]+)\][^}]*\}\s*</need_attachment>', caseSensitive: false);
    final match = attachmentTagRegex.firstMatch(aiResponse);
    if (match == null) return [];

    // inbox_numbers 추출
    final numbersStr = match.group(1);
    if (numbersStr == null || numbersStr.isEmpty) return [];

    final requestedNumbers = numbersStr.split(',').map((s) => int.tryParse(s.trim())).whereType<int>().toSet();

    if (requestedNumbers.isEmpty) return [];

    // 인박스에서 첨부 파일이 있는 메일 찾기
    final attachmentFiles = <PlatformFile>[];

    for (final number in requestedNumbers) {
      if (number < 1 || number > inboxes.length) continue;
      final inbox = inboxes[number - 1]; // 1-based index

      // 메일 첨부 파일 처리
      if (inbox.linkedMail != null) {
        try {
          final mailEntity = await _getMailEntityFromInbox(inbox);
          if (mailEntity == null) continue;

          final attachments = mailEntity.getAttachments();
          if (attachments.isEmpty) continue;

          // 첨부 파일 다운로드
          final mail = inbox.linkedMail!;
          final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.mailOAuths)) ?? [];
          final oauth = oauths.firstWhereOrNull((o) => o.email == mail.hostMail);
          if (oauth == null) continue;

          final mailRepository = ref.read(mailRepositoryProvider);
          final attachmentIds = attachments.map((a) => a.id).whereType<String>().toList();

          final fetchResult = await mailRepository.fetchAttachments(email: mail.hostMail, messageId: mail.messageId, oauth: oauth, attachmentIds: attachmentIds);

          fetchResult.fold((failure) => null, (attachmentData) {
            for (final attachment in attachments) {
              final data = attachmentData[attachment.id];
              if (data != null) {
                attachmentFiles.add(PlatformFile(name: attachment.name, size: data.length, bytes: data, path: null, identifier: attachment.id));
              }
            }
            return null;
          });
        } catch (e) {
          // 첨부 파일 다운로드 실패 시 계속 진행
          continue;
        }
      }
      // 메시지 첨부 파일 처리
      else if (inbox.linkedMessage != null) {
        try {
          final messageEntity = await _getMessageEntityFromInbox(inbox);
          if (messageEntity == null) continue;

          final files = messageEntity.files;
          if (files.isEmpty) continue;

          // 메시지 파일 다운로드
          final message = inbox.linkedMessage!;
          final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.messengerOAuths)) ?? [];
          final oauth = oauths.firstWhereOrNull((o) => o.teamId == message.teamId);
          if (oauth == null) continue;

          for (final file in files) {
            final downloadUrl = file.downloadUrl;
            if (downloadUrl == null || downloadUrl.isEmpty) continue;

            try {
              // proxyCall을 사용하여 파일 다운로드
              final fileBytes =
                  await proxyCall(
                        url: downloadUrl,
                        method: 'GET',
                        body: null,
                        oauth: oauth,
                        headers: oauth.authorizationHeaders ?? {},
                        files: null,
                        responseType: ResponseType.bytes,
                      )
                      as Uint8List?;

              if (fileBytes != null) {
                attachmentFiles.add(PlatformFile(name: file.name ?? 'unknown', size: fileBytes.length, bytes: fileBytes, path: null, identifier: file.id));
              }
            } catch (e) {
              // 개별 파일 다운로드 실패 시 계속 진행
              continue;
            }
          }
        } catch (e) {
          // 메시지 첨부 파일 다운로드 실패 시 계속 진행
          continue;
        }
      }
    }

    return attachmentFiles;
  }

  /// AI 응답에서 <need_more_action> 태그를 파싱합니다.
  Map<String, dynamic>? _parseNeedMoreActionTag(String aiResponse) {
    try {
      final RegExp tagRegex = RegExp(r'<need_more_action>\s*(\{[^}]+\})\s*</need_more_action>', caseSensitive: false);
      final match = tagRegex.firstMatch(aiResponse);
      if (match == null) return null;

      final jsonStr = match.group(1);
      if (jsonStr == null) return null;

      final jsonData = jsonDecode(jsonStr) as Map<String, dynamic>;
      return jsonData;
    } catch (e) {
      return null;
    }
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
    List<PlatformFile>? files,
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
    // IMPORTANT: 최신 state를 다시 읽어서 recentTaskIds/recentEventIds가 반영되었는지 확인
    final currentState = state;
    final updatedMessages = [...currentState.messages, AgentActionMessage(role: 'user', content: messageWithTags, files: files)];
    state = state.copyWith(messages: updatedMessages, isLoading: true);

    // 사용자 메시지 추가 후 히스토리 저장
    _saveChatHistory(taggedProjects: taggedProjects);

    // 디버깅: sendMessage에서 state 확인

    try {
      // MCP 함수 호출을 통한 일반적인 AI 챗 진행
      // IMPORTANT: state가 최신 상태인지 확인하기 위해 다시 읽기
      await _generateGeneralChat(
        userMessage,
        updatedMessages: updatedMessages,
        taggedTasks: taggedTasks,
        taggedEvents: taggedEvents,
        taggedConnections: taggedConnections,
        taggedChannels: taggedChannels,
        taggedProjects: taggedProjects,
        inboxes: inboxes,
        files: files,
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

    // 중복 제거: 같은 함수와 인자를 가진 호출은 하나만 실행 (AI가 스스로 판단하도록 룰베이스 제거)
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

    final executor = McpFunctionExecutor();
    // 각 함수 호출의 결과를 직접 추적
    final functionResults = <Map<String, dynamic>>[];

    // 각 액션을 순차적으로 실행 (의존성 고려)
    // updatedTaggedTasks와 updatedTaggedEvents를 동적으로 업데이트하기 위해 변수로 선언
    // 첫 번째 호출의 updated_tagged_tasks를 초기값으로 사용
    List<TaskEntity>? currentTaggedTasks = callsToExecute.isNotEmpty ? (callsToExecute.first['updated_tagged_tasks'] as List<TaskEntity>?) : null;
    List<EventEntity>? currentTaggedEvents = callsToExecute.isNotEmpty ? (callsToExecute.first['updated_tagged_events'] as List<EventEntity>?) : null;

    for (final pendingCall in callsToExecute) {
      // 타입 안전하게 데이터 추출
      final functionName = pendingCall['function_name'] as String?;
      final functionArgs = pendingCall['function_args'] as Map<String, dynamic>?;

      if (functionName == null || functionArgs == null) {
        continue;
      }

      // 타입 안전하게 컨텍스트 데이터 추출 (동적으로 업데이트된 currentTaggedTasks 사용)
      final updatedTaggedTasks = currentTaggedTasks ?? (pendingCall['updated_tagged_tasks'] as List<TaskEntity>?);
      final updatedTaggedEvents = currentTaggedEvents ?? (pendingCall['updated_tagged_events'] as List<EventEntity>?);
      final taggedConnections = pendingCall['tagged_connections'] as List<ConnectionEntity>?;
      final updatedAvailableInboxes = pendingCall['updated_available_inboxes'] as List<InboxEntity>?;
      final remainingCredits = (pendingCall['remaining_credits'] as num?)?.toDouble() ?? 0.0;

      try {
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

        if (result['success'] == true) {
          final message = result['message'] as String? ?? Utils.mainContext.tr.agent_action_task_completed;
          final taskId = result['taskId'] as String?;
          final eventId = result['eventId'] as String?;
          final projectId = result['projectId'] as String?;

          // createTask 실행 후 새로 생성된 Task를 currentTaggedTasks에 추가
          if (functionName == 'createTask' && taskId != null && taskId.isNotEmpty) {
            // Task가 저장될 때까지 약간의 지연 (provider 업데이트 대기)
            await Future.delayed(const Duration(milliseconds: 100));
            final allTasks = ref.read(taskListControllerProvider).tasks;
            final createdTask = allTasks.firstWhereOrNull((task) => task.id == taskId && !task.isEventDummyTask);
            if (createdTask != null) {
              final existingIds = currentTaggedTasks?.map((e) => e.id).toSet() ?? {};
              if (!existingIds.contains(createdTask.id)) {
                currentTaggedTasks = [...(currentTaggedTasks ?? []), createdTask];
              }
            }
          }

          // createEvent 실행 후 새로 생성된 Event를 currentTaggedEvents에 추가
          if (functionName == 'createEvent' && eventId != null && eventId.isNotEmpty) {
            await Future.delayed(const Duration(milliseconds: 100));
            final allEvents = ref.read(calendarEventListControllerProvider(tabType: tabType)).eventsOnView;
            final createdEvent = allEvents.firstWhereOrNull((event) => event.eventId == eventId || event.uniqueId == eventId);
            if (createdEvent != null) {
              final existingIds = currentTaggedEvents?.map((e) => e.uniqueId).toSet() ?? {};
              if (!existingIds.contains(createdEvent.uniqueId)) {
                currentTaggedEvents = [...(currentTaggedEvents ?? []), createdEvent];
              }
            }
          }

          functionResults.add({
            'function_name': functionName,
            'success': true,
            'message': message,
            if (taskId != null) 'taskId': taskId,
            if (eventId != null) 'eventId': eventId,
            if (projectId != null) 'projectId': projectId,
          });
        } else {
          final error = result['error'] as String? ?? Utils.mainContext.tr.agent_action_error_occurred_during_execution;
          functionResults.add({'function_name': functionName, 'success': false, 'error': error});
        }
      } catch (e) {
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
        final taskId = result['taskId'] as String?;
        final eventId = result['eventId'] as String?;
        final projectId = result['projectId'] as String?;

        var summaryMessage = message.isNotEmpty ? message : 'completed successfully';

        // taskId, eventId, projectId가 있으면 메시지에 포함
        if (taskId != null && taskId.isNotEmpty) {
          summaryMessage += ' (taskId: $taskId)';
        }
        if (eventId != null && eventId.isNotEmpty) {
          summaryMessage += ' (eventId: $eventId)';
        }
        if (projectId != null && projectId.isNotEmpty) {
          summaryMessage += ' (projectId: $projectId)';
        }

        functionResultsSummary.add('$functionName: $summaryMessage');
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

      // taskId, eventId가 포함된 결과를 명확히 표시
      final taskIds = functionResults.where((r) => r['taskId'] != null).map((r) => r['taskId'] as String).toList();
      final eventIds = functionResults.where((r) => r['eventId'] != null).map((r) => r['eventId'] as String).toList();

      String additionalInfo = '';
      if (taskIds.isNotEmpty) {
        additionalInfo += '\n\nIMPORTANT: Created task IDs: ${taskIds.join(', ')}. These taskIds can be used in subsequent updateTask or linkToProject function calls.';
      }
      if (eventIds.isNotEmpty) {
        additionalInfo += '\n\nIMPORTANT: Created event IDs: ${eventIds.join(', ')}. These eventIds can be used in subsequent updateEvent function calls.';
      }

      // recentTaskIds/recentEventIds가 있으면 함수 실행 결과 프롬프트에 명시
      final currentStateForPrompt = state;
      String recentIdsWarning = '';
      if (currentStateForPrompt.recentTaskIds.isNotEmpty) {
        final mostRecentTaskId = currentStateForPrompt.recentTaskIds.last;
        recentIdsWarning +=
            '\n\nCRITICAL: There is a RECENT task ID ($mostRecentTaskId) that was JUST created/updated. If the user requests to modify this task, you MUST use updateTask with this taskId. DO NOT call createTask - the task already exists.';
      }
      if (currentStateForPrompt.recentEventIds.isNotEmpty) {
        final mostRecentEventId = currentStateForPrompt.recentEventIds.last;
        recentIdsWarning +=
            '\n\nCRITICAL: There is a RECENT event ID ($mostRecentEventId) that was JUST created/updated. If the user requests to modify this event, you MUST use updateEvent with this eventId. DO NOT call createEvent - the event already exists.';
      }

      final functionResultsPrompt =
          'The following $executedCount function call(s) were executed (${successCount} succeeded, ${errorCount} failed):\n$functionResultsText$additionalInfo$recentIdsWarning\n\nPlease provide a natural, user-friendly message summarizing what was done. Be concise and clear. IMPORTANT: Use the exact number of function calls executed ($executedCount), not any other number.\n\nCRITICAL: If any taskId or eventId is mentioned above (e.g., "taskId: xxx" or "Created task IDs: xxx"), you MUST include it in your response message so it can be referenced in future conversations. Format: "Task created successfully (taskId: xxx)" or "작업 ID: xxx" in Korean.\n\nABSOLUTE RULE: These functions have ALREADY been executed. DO NOT call these functions again. Only provide a summary message, do NOT call any functions.';

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

      // Projects 리스트 가져오기 (Available Projects 리스트 제공용)
      final projects = ref.read(projectListControllerProvider);
      final projectsList = projects.map((p) => {'id': p.uniqueId, 'name': p.name, 'description': p.description, 'parent_id': p.parentId}).toList();

      // conversation history에서 함수 실행 결과 메시지 제거 (excludeFromHistory 플래그 사용)
      // 룰베이스 제거: 함수 호출 태그나 JSON 배열 제거하지 않음
      final filteredFunctionResultsHistory = functionResultsMessages
          .where((m) => !m.excludeFromHistory) // excludeFromHistory가 true인 메시지는 제외
          .map((m) => m.toJson(local: true))
          .toList();

      try {
        final functionResponse = await _repository.generateGeneralChat(
          userMessage: functionResultsPrompt,
          conversationHistory: filteredFunctionResultsHistory,
          projectContext: null,
          projects: projectsList,
          taggedContext: null,
          channelContext: null,
          inboxContext: null,
          model: selectedModel.modelName,
          apiKey: apiKey,
          userId: userId,
          systemPrompt:
              'You are a helpful assistant. Provide a brief, natural summary of the function execution results. CRITICAL: If any taskId or eventId is mentioned in the function results (e.g., "taskId: xxx" or "Created task IDs: xxx"), you MUST include it in your response message so it can be referenced in future conversations. Always include taskId/eventId in the format "(taskId: xxx)" or "(작업 ID: xxx)" in Korean responses.\n\nABSOLUTE RULE: The functions mentioned in the user message have ALREADY been executed. DO NOT call any functions. Only provide a summary message describing what was done. DO NOT call createTask, updateTask, createEvent, updateEvent, or any other functions. If the user message mentions "recentTaskIds" or "recentEventIds" or "RECENT task ID", it means a task/event was JUST created. DO NOT call createTask/createEvent again - only provide a summary message.',
        );

        final functionAiResponse = functionResponse.fold((failure) => null, (response) => response);
        if (functionAiResponse != null && functionAiResponse['message'] != null) {
          resultMessage = functionAiResponse['message'] as String;
          // HTML 엔티티 unescape 처리
          final unescape = HtmlUnescape();
          resultMessage = unescape.convert(resultMessage);
          // 룰베이스 제거: 함수 호출 태그 제거하지 않음
        } else {
          // AI 호출 실패 시 기본 메시지 사용 (taskId 포함)
          final successResults = functionResults.where((r) => r['success'] == true).toList();
          final errorResults = functionResults.where((r) => r['success'] == false).toList();
          if (errorResults.isEmpty) {
            final messages = successResults
                .map((r) {
                  final message = r['message'] as String? ?? '';
                  final taskId = r['taskId'] as String?;
                  final eventId = r['eventId'] as String?;
                  if (message.isEmpty) return '';
                  var msg = message;
                  if (taskId != null && taskId.isNotEmpty) {
                    msg += ' (taskId: $taskId)';
                  }
                  if (eventId != null && eventId.isNotEmpty) {
                    msg += ' (eventId: $eventId)';
                  }
                  return msg;
                })
                .where((m) => m.isNotEmpty)
                .toList();
            resultMessage = messages.isNotEmpty ? messages.join('\n\n') : '';
          } else {
            final errors = errorResults.map((r) => '${r['function_name']}: ${r['error']}').toList();
            resultMessage = errors.join('\n\n');
          }
        }
      } catch (e) {
        // AI 호출 실패 시 기본 메시지 사용 (taskId 포함)
        final successResults = functionResults.where((r) => r['success'] == true).toList();
        final errorResults = functionResults.where((r) => r['success'] == false).toList();
        if (errorResults.isEmpty) {
          final messages = successResults
              .map((r) {
                final message = r['message'] as String? ?? '';
                final taskId = r['taskId'] as String?;
                final eventId = r['eventId'] as String?;
                if (message.isEmpty) return '';
                var msg = message;
                if (taskId != null && taskId.isNotEmpty) {
                  msg += ' (taskId: $taskId)';
                }
                if (eventId != null && eventId.isNotEmpty) {
                  msg += ' (eventId: $eventId)';
                }
                return msg;
              })
              .where((m) => m.isNotEmpty)
              .toList();
          resultMessage = messages.isNotEmpty ? messages.join('\n\n') : '';
        } else {
          final errors = errorResults.map((r) => '${r['function_name']}: ${r['error']}').toList();
          resultMessage = errors.join('\n\n');
        }
      }
    } else {
      // 함수 실행 결과가 없으면 기본 메시지 사용 (taskId 포함)
      final successResults = functionResults.where((r) => r['success'] == true).toList();
      final errorResults = functionResults.where((r) => r['success'] == false).toList();
      if (errorResults.isEmpty) {
        final messages = successResults
            .map((r) {
              final message = r['message'] as String? ?? '';
              final taskId = r['taskId'] as String?;
              final eventId = r['eventId'] as String?;
              if (message.isEmpty) return '';
              var msg = message;
              if (taskId != null && taskId.isNotEmpty) {
                msg += ' (taskId: $taskId)';
              }
              if (eventId != null && eventId.isNotEmpty) {
                msg += ' (eventId: $eventId)';
              }
              return msg;
            })
            .where((m) => m.isNotEmpty)
            .toList();
        resultMessage = messages.isNotEmpty ? messages.join('\n\n') : '';
      } else {
        final errors = errorResults.map((r) => '${r['function_name']}: ${r['error']}').toList();
        resultMessage = errors.join('\n\n');
      }
    }

    // 함수 실행 결과에서 taskId/eventId 추출하여 state에 저장 (다음 요청에서 AI가 참조할 수 있도록)
    final newTaskIds = functionResults.where((r) => r['success'] == true && r['taskId'] != null).map((r) => r['taskId'] as String).toList();
    final newEventIds = functionResults.where((r) => r['success'] == true && r['eventId'] != null).map((r) => r['eventId'] as String).toList();

    // 디버깅: taskId 추출 결과 출력
    if (newTaskIds.isNotEmpty) {}

    // 기존 taskId/eventId에 새로운 것 추가 (최근 10개만 유지)
    // 중복 제거: 같은 ID가 이미 있으면 추가하지 않음
    final existingTaskIds = state.recentTaskIds.toSet();
    final existingEventIds = state.recentEventIds.toSet();
    final updatedTaskIds = [...state.recentTaskIds, ...newTaskIds.where((id) => !existingTaskIds.contains(id))].take(10).toList();
    final updatedEventIds = [...state.recentEventIds, ...newEventIds.where((id) => !existingEventIds.contains(id))].take(10).toList();

    // 함수 실행 결과 메시지는 conversation history에서 제외하도록 플래그 설정
    // 룰베이스로 텍스트를 변경하지 않음 - excludeFromHistory 플래그로 처리
    final assistantMessage = AgentActionMessage(role: 'assistant', content: resultMessage, excludeFromHistory: true);
    final updatedMessages = [...state.messages, assistantMessage];

    // pendingFunctionCalls에서 실행된 항목 제거 (entity block은 유지)
    final updatedPendingCalls = pendingCalls.where((call) {
      final callActionId = call['action_id'] as String?;
      return callActionId == null || !actionIds.contains(callActionId);
    }).toList();

    state = state.copyWith(
      messages: updatedMessages,
      pendingFunctionCalls: updatedPendingCalls.isEmpty ? null : updatedPendingCalls,
      isLoading: false,
      recentTaskIds: updatedTaskIds,
      recentEventIds: updatedEventIds,
    );

    // 히스토리 저장 (함수 실행 결과 메시지는 excludeFromHistory 플래그로 인해 conversation history에서 제외됨)
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
