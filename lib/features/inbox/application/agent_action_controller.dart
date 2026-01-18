import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:Visir/features/inbox/application/inbox_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/application/calendar_event_list_controller.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/domain/entities/agent_model_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/application/mcp_function_executor.dart';
import 'package:Visir/features/inbox/application/agent_context_service.dart';
import 'package:Visir/features/inbox/infrastructure/repositories/inbox_repository.dart';
import 'package:Visir/features/inbox/infrastructure/repositories/agent_chat_history_repository.dart';
import 'package:Visir/features/inbox/domain/entities/agent_chat_history_entity.dart';
import 'package:Visir/features/inbox/infrastructure/utils/token_usage_extractor.dart';
import 'package:Visir/features/auth/infrastructure/datasources/supabase_ai_usage_log_datasource.dart';
import 'package:Visir/features/auth/domain/entities/ai_api_usage_log_entity.dart';
import 'package:Visir/features/common/domain/entities/ai_provider_entity.dart';
import 'package:Visir/features/inbox/presentation/widgets/inbox_action_suggestions_widget.dart';
import 'package:Visir/features/inbox/providers.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:Visir/features/task/application/task_list_controller.dart';
import 'package:Visir/features/task/application/calendar_task_list_controller.dart';
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
  final List<TaskEntity>? deletedTasks; // 삭제된 task 정보 (confirm 후에도 preview 유지용)
  final List<EventEntity>? deletedEvents; // 삭제된 event 정보 (confirm 후에도 preview 유지용)

  // Token optimization: limit conversation history to reduce context size
  static const int maxHistoryMessages = 10;

  AgentActionMessage({required this.role, required this.content, this.excludeFromHistory = false, this.files, this.deletedTasks, this.deletedEvents});

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
      'deleted_tasks': deletedTasks?.map((t) => t.toJson(local: true)).toList(), // deletedTasks 직렬화
      'deleted_events': deletedEvents?.map((e) => e.toJson()).toList(), // deletedEvents 직렬화 (EventEntity.toJson은 local 파라미터 없음)
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

    // deletedTasks 복원
    List<TaskEntity>? deletedTasks;
    if (json['deleted_tasks'] != null) {
      final deletedTasksList = json['deleted_tasks'] as List<dynamic>?;
      deletedTasks = deletedTasksList?.map((t) => TaskEntity.fromJson(t as Map<String, dynamic>)).toList();
    }

    // deletedEvents 복원
    List<EventEntity>? deletedEvents;
    if (json['deleted_events'] != null) {
      final deletedEventsList = json['deleted_events'] as List<dynamic>?;
      deletedEvents = deletedEventsList?.map((e) => EventEntity.fromJson(e as Map<String, dynamic>)).toList();
    }

    return AgentActionMessage(
      role: json['role'] as String,
      content: decryptedContent,
      excludeFromHistory: json['exclude_from_history'] as bool? ?? false,
      files: files,
      deletedTasks: deletedTasks,
      deletedEvents: deletedEvents,
    );
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
  final List<InboxEntity>? availableInboxes; // Available inboxes from search results (for linking tasks/events)
  final List<TaskEntity>? taggedTasks; // Tasks extracted from AI responses (available for next turn)
  final List<EventEntity>? taggedEvents; // Events extracted from AI responses (available for next turn)

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
    this.availableInboxes,
    this.taggedTasks,
    this.taggedEvents,
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
    List<InboxEntity>? availableInboxes,
    List<TaskEntity>? taggedTasks,
    List<EventEntity>? taggedEvents,
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
      availableInboxes: availableInboxes ?? this.availableInboxes,
      taggedTasks: taggedTasks ?? this.taggedTasks,
      taggedEvents: taggedEvents ?? this.taggedEvents,
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
  final _contextService = AgentContextService();

  // deleteTask의 경우 함수 실행 전에 추출한 task 정보를 저장 (confirm 후에도 preview 유지용)
  final Map<String, List<TaskEntity>> _deletedTasksCache = {};
  // deleteEvent의 경우 함수 실행 전에 추출한 event 정보를 저장 (confirm 후에도 preview 유지용)
  final Map<String, List<EventEntity>> _deletedEventsCache = {};

  // 캐시에 접근하기 위한 getter
  Map<String, List<TaskEntity>> get deletedTasksCache => _deletedTasksCache;
  Map<String, List<EventEntity>> get deletedEventsCache => _deletedEventsCache;

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
    await _updateState(actionType: actionType, inbox: inbox, task: task, event: event, isLoading: false, sessionId: sessionId);

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
    List<InboxEntity>? taggedInboxes,
    List<ConnectionEntity>? taggedConnections,
    List<MessageChannelEntity>? taggedChannels,
    List<ProjectEntity>? taggedProjects,
    List<PlatformFile>? files,
  }) async {
    if (userMessage.trim().isEmpty && (files == null || files.isEmpty)) return;

    // 태그된 inboxes만 사용 (사용자가 명시적으로 선택한 경우에만)
    // 초기 context는 제공하지 않으므로, widget.inboxes는 사용하지 않음
    final combinedInboxes = <InboxEntity>[];
    // taggedInboxes만 사용 (사용자가 명시적으로 선택한 경우)
    if (taggedInboxes != null && taggedInboxes.isNotEmpty) {
      combinedInboxes.addAll(taggedInboxes);
    }

    // 태그된 항목들을 HTML 태그로 감싸서 메시지에 포함
    final messageWithTags = _contextService.buildMessageWithTaggedItems(
      userMessage: userMessage,
      taggedTasks: taggedTasks,
      taggedEvents: taggedEvents,
      taggedInboxes: taggedInboxes,
      taggedConnections: taggedConnections,
      taggedChannels: taggedChannels,
      taggedProjects: taggedProjects,
    );

    // 사용자 메시지 추가 (기존 대화 흐름 유지)
    final updatedMessages = [...state.messages, AgentActionMessage(role: 'user', content: messageWithTags, files: files)];
    await _updateState(messages: updatedMessages, isLoading: true, taggedProjects: taggedProjects);

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
        inboxes: combinedInboxes.isNotEmpty ? combinedInboxes : null,
        files: files,
      );
    } catch (e) {
      await _updateState(messages: updatedMessages, isLoading: false, taggedProjects: taggedProjects);
    }
  }

  /// agentAction 시작 시 첫 메시지를 자동으로 보냅니다.
  Future<void> _sendAutoMessage(String autoMessage, {List<InboxEntity>? inboxes, AgentActionType? actionType}) async {
    if (autoMessage.trim().isEmpty) return;

    // createTask나 createEvent의 경우, 제공된 inbox를 자동으로 로드
    if ((actionType == AgentActionType.createTask || actionType == AgentActionType.createEvent) && inboxes != null && inboxes.isNotEmpty) {
      // 제공된 inbox 번호들을 loadedInboxNumbers에 추가하여 전체 내용이 포함되도록 함
      final inboxNumbers = {for (int i = 0; i < inboxes.length; i++) i + 1};
      await _updateState(loadedInboxNumbers: {...state.loadedInboxNumbers, ...inboxNumbers});
    }

    // 사용자 메시지로 추가 (자동 메시지)
    final updatedMessages = [...state.messages, AgentActionMessage(role: 'user', content: autoMessage)];
    await _updateState(messages: updatedMessages, isLoading: true);

    try {
      // generalChat으로 처리
      await _generateGeneralChat(autoMessage, updatedMessages: updatedMessages, inboxes: inboxes);
    } catch (e) {
      await _updateState(messages: updatedMessages, isLoading: false);
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
    String? searchContext, // 검색 결과 context
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
              typeInfo = ' (image file)';
            } else if (isVideo) {
              typeInfo = ' (video file)';
            } else if (f.name.toLowerCase().endsWith('.pdf')) {
              typeInfo = ' (PDF document)';
            } else if (f.name.toLowerCase().endsWith('.txt') || f.name.toLowerCase().endsWith('.md')) {
              typeInfo = ' (text file)';
            }
            return 'Filename: ${f.name}${typeInfo}, Size: ${sizeKB} KB';
          })
          .join('\n');
      // 파일 정보만 제공하고, AI가 판단하도록 함 (룰베이스 제거)
      enhancedUserMessage = '$userMessage\n\n[Attached File Information]\n$fileInfoList';
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
    await _updateState(messages: messages, isLoading: true);

    try {
      // 초기 context는 제공하지 않음 - AI가 필요한 context를 감지하여 검색 함수 호출
      // Project context는 제공하지 않음 (계획에 따라 초기 context 제거)
      String projectContext = '';
      String taggedContext = '';
      String? channelContext;
      String? inboxContext; // 사용자가 명시적으로 선택한 inbox가 있는 경우에만 설정됨

      // Projects 리스트 가져오기 (Available Projects 리스트 제공용)
      final projects = ref.read(projectListControllerProvider);
      final projectsList = projects.map((p) => {'id': p.uniqueId, 'name': p.name, 'description': p.description, 'parent_id': p.parentId}).toList();

      // Merge state tagged items (from AI responses) with parameter tagged items (from user selection)
      final allTaggedTasks = [...?state.taggedTasks, ...?taggedTasks];
      final allTaggedEvents = [...?state.taggedEvents, ...?taggedEvents];

      if (allTaggedTasks.isNotEmpty || allTaggedEvents.isNotEmpty || taggedConnections != null && taggedConnections.isNotEmpty) {
        taggedContext = _contextService.buildTaggedContext(
          taggedTasks: allTaggedTasks.isNotEmpty ? allTaggedTasks : null,
          taggedEvents: allTaggedEvents.isNotEmpty ? allTaggedEvents : null,
          taggedConnections: taggedConnections,
        );
      }

      // 명시적으로 태그된 채널이 있는 경우에만 context 추가
      if (taggedChannels != null && taggedChannels.isNotEmpty) {
        channelContext = await _buildChannelContext(taggedChannels);
      }

      // 명시적으로 제공된 inbox가 있는 경우에만 context 추가 (사용자가 직접 선택한 경우)
      // 초기 context는 제공하지 않음 - AI가 필요한 context를 감지하여 검색 함수 호출
      // 사용자가 명시적으로 선택한 inbox가 있는 경우에만 context 추가
      if (inboxes != null && inboxes.isNotEmpty) {
        final requestedNumbers = state.loadedInboxNumbers;
        final summaryOnly = requestedNumbers.isEmpty;
        inboxContext = _contextService.buildInboxContext(inboxes, summaryOnly: summaryOnly, requestedInboxNumbers: requestedNumbers);
      }

      // 검색 결과 context가 있으면 inboxContext에 병합
      if (searchContext != null && searchContext.isNotEmpty) {
        if (inboxContext != null && inboxContext.isNotEmpty) {
          inboxContext = '$inboxContext\n\n$searchContext';
        } else {
          inboxContext = searchContext;
        }
      }

      // API 키 선택: useUserApiKey가 true이면 사용자 API 키, false이면 환경 변수 API 키
      String? apiKey;
      if (useUserApiKey) {
        final apiKeys = ref.read(aiApiKeysProvider);
        apiKey = apiKeys[selectedModel.provider.name];
      } else {
        // 전역 변수에서 가져오기 (Edge Function에서 업데이트됨)
        apiKey = openAiApiKey.isNotEmpty ? openAiApiKey : null;
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
          await _updateState(isLoading: false);
          return;
        }
      }

      // System prompt 가져오기
      final systemPromptProvider = ref.read(agentSystemPromptProvider);
      String systemPrompt = systemPromptProvider is String ? systemPromptProvider : '';

      // 최근 생성/수정된 taskId/eventId를 system prompt에 추가 (AI가 참조할 수 있도록)
      if (state.recentTaskIds.isNotEmpty || state.recentEventIds.isNotEmpty) {
        systemPrompt += _contextService.buildRecentItemsContext(
          recentTaskIds: state.recentTaskIds,
          recentEventIds: state.recentEventIds,
        );
      }

      // conversationSummary가 없으면 항상 제목 생성 요청 추가
      if (state.conversationSummary == null || state.conversationSummary!.isEmpty) {
        systemPrompt +=
            '\n\n## CRITICAL REQUIREMENT - CONVERSATION TITLE:\nYou MUST ALWAYS start your response with a conversation title in EXACTLY this format:\n<conversation_title>Your title here (max 30 characters)</conversation_title>\n\nThis is MANDATORY. Your response MUST begin with <conversation_title>...</conversation_title> before any other content. Do NOT skip this. Do NOT forget this. This is the FIRST thing you must write in every response when conversationSummary is not set.';
      }

      // 일반적인 AI 응답 생성 (MCP 함수 호출 지원)
      // AI에 전달할 때는 평문이어야 하므로 local: true 사용
      // 재귀 호출인 경우 conversation history의 마지막 user 메시지를 사용
      // conversation history에서 함수 실행 결과 메시지 제거 (excludeFromHistory 플래그 사용)
      // 룰베이스 제거: 함수 호출 태그나 JSON 배열 제거하지 않음
      // Token optimization: limit history to recent messages only
      final filteredMessages = messages.where((m) => !m.excludeFromHistory).toList();
      final limitedMessages = filteredMessages.length > AgentActionMessage.maxHistoryMessages
          ? filteredMessages.sublist(filteredMessages.length - AgentActionMessage.maxHistoryMessages)
          : filteredMessages;
      final filteredHistory = limitedMessages.map((m) => m.toJson(local: true)).toList();

      // conversationSummary가 없으면 user message에도 conversation_title 요청 추가
      if (state.conversationSummary == null || state.conversationSummary!.isEmpty) {
        enhancedUserMessage = '[IMPORTANT: Please start your response with <conversation_title>Title (max 30 chars)</conversation_title>]\n\n$enhancedUserMessage';
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

      final aiResponse = response.fold(
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

      if (aiResponse != null && aiResponse['message'] != null) {
        var aiMessage = aiResponse['message'] as String;

        // Extract and save token usage
        await _saveTokenUsage(aiResponse, selectedModel, useUserApiKey);

        // HTML 엔티티 unescape 처리
        final unescape = HtmlUnescape();
        aiMessage = unescape.convert(aiMessage);

        // conversationSummary가 없으면 항상 conversation_title 태그에서 제목 추출 시도
        if (state.conversationSummary == null || state.conversationSummary!.isEmpty) {
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
            // 태그 제거 및 실제 title 추출
            String cleanedTitle = _cleanTitleFromTags(extractedTitle);
            // 최대 50자로 제한
            String finalTitle = cleanedTitle.length > 50 ? '${cleanedTitle.substring(0, 47)}...' : cleanedTitle;
            await _updateState(conversationSummary: finalTitle);
          } else {
            // conversation_title이 없으면 AI 응답의 처음 부분을 제목으로 사용
            final firstLine = aiMessage.split('\n').first.trim();
            if (firstLine.isNotEmpty && !firstLine.contains('conversation_title')) {
              // 태그 제거 및 실제 title 추출
              String cleanedTitle = _cleanTitleFromTags(firstLine);
              String finalTitle = cleanedTitle.length > 50 ? '${cleanedTitle.substring(0, 47)}...' : cleanedTitle;
              await _updateState(conversationSummary: finalTitle);
            }
          }
        }

        // conversation_title 태그를 제거 (제목 추출 후)
        aiMessage = aiMessage.replaceAll(RegExp(r'<conversation_title>.*?</conversation_title>', dotAll: true), '');
        aiMessage = aiMessage.replaceAll(RegExp(r'&lt;conversation_title&gt;.*?&lt;/conversation_title&gt;', dotAll: true), '');

        // MCP 함수 호출 감지 및 실행
        // 재귀 호출에서는 함수 호출을 파싱하지 않음 (무한 루프 방지)

        // 함수 호출 태그 제거 (재귀 호출에서도 함수 호출 태그만 있는지 확인하기 위해)
        String aiMessageWithoutFunctionCalls = aiMessage;

        // 1. <function_call> 태그 제거
        aiMessageWithoutFunctionCalls = aiMessageWithoutFunctionCalls.replaceAll(RegExp(r'<function_call[^>]*>.*?</function_call>', dotAll: true), '');
        // </function_call> 단독 태그 제거
        aiMessageWithoutFunctionCalls = aiMessageWithoutFunctionCalls.replaceAll(RegExp(r'</function_call>', dotAll: true), '');

        // 2. JSON 배열 형식의 함수 호출 제거: [{"function": "...", "arguments": {...}}, ...]
        try {
          final arrayStart = aiMessageWithoutFunctionCalls.indexOf('[');
          final arrayEnd = aiMessageWithoutFunctionCalls.lastIndexOf(']');
          if (arrayStart != -1 && arrayEnd != -1 && arrayEnd > arrayStart) {
            final arrayStr = aiMessageWithoutFunctionCalls.substring(arrayStart, arrayEnd + 1);
            try {
              final parsed = jsonDecode(arrayStr) as List<dynamic>?;
              if (parsed != null && parsed.isNotEmpty) {
                // 함수 호출 배열인지 확인
                bool isFunctionCallArray = true;
                for (final item in parsed) {
                  if (item is! Map<String, dynamic> || !item.containsKey('function') || !item.containsKey('arguments')) {
                    isFunctionCallArray = false;
                    break;
                  }
                }
                if (isFunctionCallArray) {
                  // 함수 호출 배열이면 제거
                  aiMessageWithoutFunctionCalls = aiMessageWithoutFunctionCalls.replaceAll(arrayStr, '').trim();
                }
              }
            } catch (e) {
              // JSON 파싱 실패는 무시
            }
          }
        } catch (e) {
          // 배열 찾기 실패는 무시
        }

        // 3. JSON 블록 형식의 함수 호출 제거: ```json\n{"function": "...", "arguments": {...}}\n```
        try {
          final jsonBlockRegex = RegExp(r'```json\s*(\{.*?\})\s*```', dotAll: true);
          final jsonBlockMatches = jsonBlockRegex.allMatches(aiMessageWithoutFunctionCalls);
          for (final match in jsonBlockMatches.toList().reversed) {
            final jsonStr = match.group(1);
            if (jsonStr != null) {
              try {
                final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
                if (parsed.containsKey('function') && parsed.containsKey('arguments')) {
                  // 함수 호출 블록이면 제거
                  aiMessageWithoutFunctionCalls = aiMessageWithoutFunctionCalls.replaceRange(match.start, match.end, '').trim();
                }
              } catch (e) {
                // JSON 파싱 실패는 무시
              }
            }
          }
        } catch (e) {
          // JSON 블록 찾기 실패는 무시
        }

        // 4. 단일 JSON 객체 형식의 함수 호출 제거: {"function": "...", "arguments": {...}}
        try {
          final functionCallRegex = RegExp(r'\{[^}]*"function"\s*:\s*"([^"]+)"[^}]*"arguments"\s*:\s*(\{[^}]*\})[^}]*\}', dotAll: true);
          final matches = functionCallRegex.allMatches(aiMessageWithoutFunctionCalls);
          for (final match in matches.toList().reversed) {
            try {
              final jsonStr = aiMessageWithoutFunctionCalls.substring(match.start, match.end);
              final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
              if (parsed.containsKey('function') && parsed.containsKey('arguments')) {
                // 함수 호출 객체이면 제거
                aiMessageWithoutFunctionCalls = aiMessageWithoutFunctionCalls.replaceRange(match.start, match.end, '').trim();
              }
            } catch (e) {
              // JSON 파싱 실패는 무시
            }
          }
        } catch (e) {
          // 함수 호출 객체 찾기 실패는 무시
        }

        // 앞뒤 공백 제거
        aiMessageWithoutFunctionCalls = aiMessageWithoutFunctionCalls.trim();

        final executor = McpFunctionExecutor();
        final allFunctionCalls = isRecursiveCall ? <Map<String, dynamic>>[] : executor.parseFunctionCalls(aiMessage);

        // 중복 함수 호출 제거 (AI가 스스로 판단하도록 룰베이스 제거)
        final functionCalls = <Map<String, dynamic>>[];
        if (!isRecursiveCall) {
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
        }

        if (functionCalls.isNotEmpty) {
          // 여러 개의 함수 호출이 감지되면 순차적으로 실행
          // availableInboxes는 state.availableInboxes를 우선 사용하고, 없으면 state.inbox, 그래도 없으면 전달받은 inboxes 사용
          final availableInboxes = state.availableInboxes?.isNotEmpty == true ? state.availableInboxes : (state.inbox != null ? [state.inbox!] : inboxes);
          final me = ref.read(authControllerProvider).value;
          final remainingCredits = me?.userAiCredits ?? 0.0;

          final results = <Map<String, dynamic>>[];
          final successMessages = <String>[];
          final errorMessages = <String>[];
          List<PlatformFile>? attachmentFilesFromResults;

          // 검색 결과를 저장할 변수들
          var updatedTaggedTasks = taggedTasks;
          var updatedTaggedEvents = taggedEvents;
          var updatedAvailableInboxes = availableInboxes;
          var updatedLoadedInboxNumbers = state.loadedInboxNumbers;

          // MCP 함수 실행기 인스턴스 생성
          final executor = McpFunctionExecutor();

          // 검색 함수와 일반 함수 분리
          // 검색 함수: searchInbox, searchTask, searchCalendarEvent
          // 읽기 전용 함수: getInboxDetails (검색 결과를 가져오는 함수이므로 검색 함수와 함께 처리)
          final searchFunctionCalls = <Map<String, dynamic>>[];
          final otherFunctionCalls = <Map<String, dynamic>>[];

          for (final call in functionCalls) {
            final functionName = call['function'] as String? ?? '';
            if (functionName == 'searchInbox' || functionName == 'searchTask' || functionName == 'searchCalendarEvent' || functionName == 'getInboxDetails') {
              searchFunctionCalls.add(call);
            } else {
              otherFunctionCalls.add(call);
            }
          }

          // 검색 함수를 먼저 처리 (silent 실행)
          if (searchFunctionCalls.isNotEmpty && !isRecursiveCall) {
            String? searchContext;

            for (final searchCall in searchFunctionCalls) {
              final functionName = searchCall['function'] as String;
              var functionArgs = searchCall['arguments'] as Map<String, dynamic>;

              // 태그된 항목들을 자동으로 파라미터에 추가
              functionArgs = _enrichFunctionArgsWithTaggedItems(
                functionName: functionName,
                args: functionArgs,
                taggedTasks: updatedTaggedTasks,
                taggedEvents: updatedTaggedEvents,
                taggedConnections: taggedConnections,
                availableInboxes: updatedAvailableInboxes,
              );

              // 크레딧 정보를 함수 인자에 추가
              functionArgs['_remaining_credits'] = remainingCredits;

              // 검색 함수 실행
              final tabType = _getTabTypeForFunction(functionName);
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

              // 검색 결과 처리
              if (result['success'] == true && result['results'] != null) {
                final searchResults = result['results'] as List<dynamic>? ?? [];

                // 검색 결과가 비어있어도 context를 생성하여 AI에게 전달
                // 검색 결과를 silent 메시지로 추가
                final silentMessage = AgentActionMessage(role: 'assistant', content: '[Search completed: Found ${searchResults.length} results]', excludeFromHistory: true);
                final updatedMessagesWithSearch = [...messages, silentMessage];
                await _updateState(messages: updatedMessagesWithSearch);

                // 검색 결과를 context로 변환 (결과가 비어있어도 context 생성)
                String? currentSearchContext;
                if (functionName == 'searchInbox') {
                  currentSearchContext = _contextService.buildInboxContextFromSearchResults(searchResults);
                  // 검색된 inbox를 availableInboxes에 추가
                  // 검색 결과는 inboxControllerProvider에 반영되어 있으므로, 거기서 찾아서 추가
                  if (searchResults.isNotEmpty) {
                    final searchResultInboxes = <InboxEntity>[];
                    final searchResultNumbers = <int>{};
                    final inboxList = ref.read(inboxControllerProvider);
                    final allInboxes = inboxList?.inboxes ?? [];

                    for (final resultItem in searchResults) {
                      if (resultItem is Map<String, dynamic>) {
                        final inboxId = resultItem['id'] as String?;
                        final inboxNumber = resultItem['number'] as int?;
                        if (inboxId != null) {
                          // 먼저 updatedAvailableInboxes에서 찾기
                          var foundInbox = updatedAvailableInboxes?.firstWhereOrNull((inbox) => inbox.id == inboxId);
                          // 없으면 inboxControllerProvider에서 찾기
                          if (foundInbox == null) {
                            foundInbox = allInboxes.firstWhereOrNull((inbox) => inbox.id == inboxId);
                          }
                          if (foundInbox != null) {
                            searchResultInboxes.add(foundInbox);
                            if (inboxNumber != null) {
                              searchResultNumbers.add(inboxNumber);
                            }
                          }
                        }
                      }
                    }
                    if (searchResultInboxes.isNotEmpty) {
                      final existingIds = updatedAvailableInboxes?.map((e) => e.id).toSet() ?? {};
                      final newInboxes = searchResultInboxes.where((e) => !existingIds.contains(e.id)).toList();
                      updatedAvailableInboxes = [...(updatedAvailableInboxes ?? []), ...newInboxes];
                      updatedLoadedInboxNumbers = {...updatedLoadedInboxNumbers, ...searchResultNumbers};
                    }
                  }
                } else if (functionName == 'searchTask') {
                  currentSearchContext = _contextService.buildTaskContextFromSearchResults(searchResults);
                  // 검색된 task를 taggedTasks에 추가
                  if (searchResults.isNotEmpty) {
                    final searchResultTasks = <TaskEntity>[];
                    for (final resultItem in searchResults) {
                      if (resultItem is Map<String, dynamic>) {
                        final taskId = resultItem['id'] as String?;
                        if (taskId != null) {
                          final allTasks = ref.read(taskListControllerProvider).tasks;
                          final foundTask = allTasks.firstWhereOrNull((task) => task.id == taskId && !task.isEventDummyTask);
                          if (foundTask != null) {
                            searchResultTasks.add(foundTask);
                          }
                        }
                      }
                    }
                    if (searchResultTasks.isNotEmpty) {
                      final existingIds = updatedTaggedTasks?.map((e) => e.id).toSet() ?? {};
                      final newTasks = searchResultTasks.where((e) => !existingIds.contains(e.id)).toList();
                      updatedTaggedTasks = [...(updatedTaggedTasks ?? []), ...newTasks];
                    }
                  }
                } else if (functionName == 'searchCalendarEvent') {
                  currentSearchContext = _contextService.buildEventContextFromSearchResults(searchResults);
                  // 검색된 event를 taggedEvents에 추가
                  if (searchResults.isNotEmpty) {
                    final searchResultEvents = <EventEntity>[];
                    for (final resultItem in searchResults) {
                      if (resultItem is Map<String, dynamic>) {
                        final eventId = resultItem['id'] as String? ?? resultItem['uniqueId'] as String?;
                        if (eventId != null) {
                          final allEvents = ref.read(calendarEventListControllerProvider(tabType: TabType.home)).eventsOnView;
                          final foundEvent = allEvents.firstWhereOrNull((event) => event.eventId == eventId || event.uniqueId == eventId);
                          if (foundEvent != null) {
                            searchResultEvents.add(foundEvent);
                          }
                        }
                      }
                    }
                    if (searchResultEvents.isNotEmpty) {
                      final existingIds = updatedTaggedEvents?.map((e) => e.uniqueId).toSet() ?? {};
                      final newEvents = searchResultEvents.where((e) => !existingIds.contains(e.uniqueId)).toList();
                      updatedTaggedEvents = [...(updatedTaggedEvents ?? []), ...newEvents];
                    }
                  }
                }

                // 검색 결과를 context에 추가 (결과가 비어있어도 context가 생성되므로 항상 추가)
                if (currentSearchContext != null && currentSearchContext.isNotEmpty) {
                  searchContext = searchContext == null ? currentSearchContext : '$searchContext\n\n$currentSearchContext';
                }
              }
            }

            // 검색 결과가 있으면 state 업데이트 (재귀 호출 전에!)
            if (updatedLoadedInboxNumbers != state.loadedInboxNumbers ||
                updatedTaggedTasks != taggedTasks ||
                updatedTaggedEvents != taggedEvents ||
                updatedAvailableInboxes != state.availableInboxes) {
              await _updateState(loadedInboxNumbers: updatedLoadedInboxNumbers, availableInboxes: updatedAvailableInboxes);
            }

            // 검색 결과를 context로 추가하여 AI 재호출
            // searchContext가 비어있어도 재귀 호출하여 일반 응답 생성 (검색 결과가 비어있을 수 있음)
            // 재귀 호출에는 최신 state의 messages를 전달 (silent message 포함)
            final currentStateMessages = state.messages;
            await _generateGeneralChat(
              userMessage,
              selectedProject: selectedProject,
              updatedMessages: currentStateMessages, // 최신 state의 messages 사용 (silent message 포함)
              taggedTasks: updatedTaggedTasks,
              taggedEvents: updatedTaggedEvents,
              taggedConnections: taggedConnections,
              taggedChannels: taggedChannels,
              taggedProjects: taggedProjects,
              inboxes: updatedAvailableInboxes,
              files: files,
              isRecursiveCall: true, // 재귀 호출 플래그 설정
              searchContext: searchContext, // 검색 결과 context 전달 (null이거나 비어있을 수 있음)
            );
            return; // 재귀 호출에서 이미 state를 업데이트했으므로 종료
          }

          // 검색 함수가 없거나 재귀 호출인 경우, 일반 함수 처리
          // 재귀 호출일 때는 검색 함수를 제외 (이미 context에 결과가 있음)
          final functionCallsToProcess = isRecursiveCall
              ? functionCalls.where((call) {
                  final functionName = call['function'] as String? ?? '';
                  return functionName != 'searchInbox' && functionName != 'searchTask' && functionName != 'searchCalendarEvent' && functionName != 'getInboxDetails';
                }).toList()
              : otherFunctionCalls;

          if (functionCallsToProcess.isEmpty) {
            // 재귀 호출 중에 검색 함수만 호출된 경우, 일반 응답을 생성해야 함
            // (이미 searchContext에 결과가 있으므로 그것을 사용하여 응답 생성)
            if (isRecursiveCall) {
              // 일반 응답 처리로 넘어감 (아래 else 블록에서 처리)
              // executionGroups를 건너뛰고 일반 응답 처리로 바로 넘어감
              // results를 비워두어 resultMessage가 비어있게 만들어 일반 응답 처리로 넘어가도록 함
              results.clear();
            } else {
              // 검색 함수만 있었고 이미 처리되었으므로 종료
              return;
            }
          }

          // 함수 호출을 의존성에 따라 그룹화
          final executionGroups = functionCallsToProcess.isEmpty ? <List<Map<String, dynamic>>>[] : _groupFunctionCalls(functionCallsToProcess);

          // 모든 그룹의 결과를 수집할 리스트
          final allGroupResults = <Map<String, dynamic>?>[];

          // 각 그룹을 순차적으로 실행 (그룹 내부는 병렬 실행)
          for (final group in executionGroups) {
            // 그룹 내부 함수들을 병렬로 실행
            final groupResults = await Future.wait(
              group.map((functionCall) async {
                final functionName = functionCall['function'] as String;

                // 재귀 호출에서 검색 함수는 무시 (이미 context에 결과가 있음)
                if (isRecursiveCall) {
                  final isSearchFunction =
                      functionName == 'searchInbox' || functionName == 'searchTask' || functionName == 'searchCalendarEvent' || functionName == 'getInboxDetails';
                  if (isSearchFunction) {
                    return null; // 검색 함수는 무시
                  }
                }

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

                // 확인이 필요한 함수인지 체크 (McpFunctionExecutor의 메서드 사용)
                final requiresConfirmation = executor.requiresConfirmation(functionName);

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
                    'index': functionCallsToProcess.indexOf(functionCall),
                    'message_index': targetMessageIndex, // 메시지 인덱스 저장
                    'updated_tagged_tasks': updatedTaggedTasks,
                    'updated_tagged_events': updatedTaggedEvents,
                    'tagged_connections': taggedConnections,
                    'updated_available_inboxes': updatedAvailableInboxes,
                    'remaining_credits': remainingCredits,
                  });

                  await _updateState(pendingFunctionCalls: pendingCalls);

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

              // summarizeAttachment의 경우 files 추출하지 않음 (요약만 표시)
              // summarizeAttachment는 요약 텍스트만 제공하므로 파일을 메시지에 첨부하지 않음
              if (functionName == 'summarizeAttachment') {
                // summarizeAttachment는 요약만 제공하므로 파일을 메시지에 첨부하지 않음
              }

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
                // summarizeAttachment and getPreviousContext의 경우 result['result']['summary'] 사용
                String successMessage;
                if ((functionName == 'summarizeAttachment' || functionName == 'getPreviousContext') && result['result'] != null) {
                  final resultData = result['result'] as Map<String, dynamic>;
                  final summary = resultData['summary'] as String?;
                  successMessage = summary ?? result['message'] as String? ?? Utils.mainContext.tr.agent_action_task_completed;
                } else {
                  successMessage = result['message'] as String? ?? Utils.mainContext.tr.agent_action_task_completed;
                }
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
          if (updatedLoadedInboxNumbers != state.loadedInboxNumbers ||
              updatedTaggedTasks != taggedTasks ||
              updatedTaggedEvents != taggedEvents ||
              updatedAvailableInboxes != state.availableInboxes) {
            await _updateState(loadedInboxNumbers: updatedLoadedInboxNumbers, availableInboxes: updatedAvailableInboxes);
          }

          // successMessages가 있으면 우선 사용 (summarizeAttachment 등의 함수 결과)
          String resultMessage = '';
          if (successMessages.isNotEmpty) {
            resultMessage = successMessages.join('\n\n');
          } else {
            // AI가 처음 생성한 메시지 사용 (함수 호출 태그 제거된 버전)
            resultMessage = aiMessageWithoutFunctionCalls;
          }

          // 함수 호출 JSON 배열만 있고 자연어 응답이 없는 경우 처리
          // aiMessageWithoutFunctionCalls가 비어있거나 JSON 배열 형식인 경우
          if (resultMessage.trim().isEmpty || (resultMessage.trim().startsWith('[') && resultMessage.trim().endsWith(']'))) {
            // 재귀 호출에서 모든 함수 호출이 무시된 경우 (검색 함수만 호출된 경우)
            // 이미 searchContext에 결과가 있으므로 일반 응답 처리로 넘어가야 함
            if (isRecursiveCall && results.isEmpty && functionCallsToProcess.isEmpty) {
              // 일반 응답 처리로 넘어감 (아래 else 블록에서 처리)
              resultMessage = ''; // 빈 메시지로 설정하여 일반 응답 처리로 넘어가도록 함
            } else if (isRecursiveCall && results.isEmpty) {
              resultMessage = aiMessage;
            } else if (!isRecursiveCall && functionCalls.isNotEmpty) {
              // 함수 실행 후 자연어 응답이 없는 경우, 함수 실행 결과를 사용
              // 검색 함수만 호출된 경우 results가 비어있을 수 있으므로 재귀 호출로 일반 응답 생성
              final hasSearchFunctions = functionCalls.any((call) {
                final functionName = call['function'] as String? ?? '';
                return functionName == 'searchInbox' || functionName == 'searchTask' || functionName == 'searchCalendarEvent' || functionName == 'getInboxDetails';
              });

              // 검색 함수만 호출된 경우 재귀 호출로 일반 응답 생성 (이미 위에서 처리되었을 수 있음)
              if (hasSearchFunctions && results.isEmpty) {
                // 검색 함수만 호출된 경우, 일반 응답 처리로 넘어감 (아래 else 블록에서 처리)
                resultMessage = ''; // 빈 메시지로 설정하여 일반 응답 처리로 넘어가도록 함
              } else if (results.isNotEmpty) {
                final successResults = results.where((r) => r['success'] == true).toList();
                final errorResults = results.where((r) => r['success'] == false).toList();

                final successMessages = successResults.map((r) => r['message'] as String? ?? 'Completed successfully.').where((m) => m.isNotEmpty).toList();
                final errorMessages = errorResults.map((r) => 'Error: ${r['error'] as String? ?? 'Unknown error'}').where((m) => m.isNotEmpty).toList();

                final allMessages = <String>[];
                if (successMessages.isNotEmpty) {
                  allMessages.addAll(successMessages);
                }
                if (errorMessages.isNotEmpty) {
                  allMessages.addAll(errorMessages);
                }

                if (allMessages.isNotEmpty) {
                  resultMessage = allMessages.join('\n\n');
                } else {
                  resultMessage = 'Function executed successfully.';
                }
              } else {
                resultMessage = 'Function executed successfully.';
              }
            } else {
              // 그 외의 경우 기본 메시지 사용
              resultMessage = 'Function executed successfully.';
            }
          }

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
                    // 전역 변수에서 가져오기 (Edge Function에서 업데이트됨)
                    apiKey = openAiApiKey.isNotEmpty ? openAiApiKey : null;
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
                    // Extract and save token usage for confirmation message
                    await _saveTokenUsage(confirmationAiResponse, selectedModel, useUserApiKey);

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
              // successMessages가 이미 resultMessage에 설정되어 있으면 유지, 아니면 설정
              if (resultMessage.isEmpty && successMessages.isNotEmpty) {
                resultMessage = successMessages.join('\n\n');
              }
            } else {
              resultMessage = errorMessages.join('\n\n');
            }
          }

          // 확인이 필요한 함수 호출은 pendingFunctionCalls에 저장되어 있으므로 태그 추가 불필요

          // Check if resultMessage is empty after all processing
          // 재귀 호출에서 검색 함수만 호출된 경우는 일반 응답 처리로 넘어가야 하므로 에러 메시지 설정하지 않음
          // 첫 요청에서도 함수 호출만 있고 일반 응답이 없을 때는 재귀 호출로 일반 응답을 생성하므로 에러 메시지 설정하지 않음
          if (resultMessage.isEmpty || resultMessage.trim().isEmpty) {
            // Check if there are error messages from function calls
            if (errorMessages.isNotEmpty) {
              resultMessage = errorMessages.join('\n\n');
            } else if (!(functionCallsToProcess.isEmpty)) {
              // functionCallsToProcess가 비어있지 않으면 에러 메시지 설정
              // functionCallsToProcess가 비어있으면 재귀 호출로 일반 응답을 생성하므로 에러 메시지 설정하지 않음
              resultMessage = '${Utils.mainContext.tr.agent_action_error_occurred}\n\nError: No response generated';
            }
            // functionCallsToProcess가 비어있으면 resultMessage를 비워두어 일반 응답 처리로 넘어가도록 함
          }

          // 재귀 호출에서 검색 함수만 호출된 경우, assistantMessage를 생성하지 않고 바로 일반 응답 처리로 넘어감
          // 첫 요청에서도 함수 호출만 있고 일반 응답이 없을 때 처리하도록 수정
          List<AgentActionMessage>? updatedMessagesWithResponse;
          if (functionCallsToProcess.isEmpty && resultMessage.trim().isEmpty) {
            // 일반 응답 처리는 아래에서 수행
            updatedMessagesWithResponse = null;
          } else {
            final assistantMessage = AgentActionMessage(
              role: 'assistant',
              content: resultMessage,
              files: attachmentFilesFromResults?.isNotEmpty == true ? attachmentFilesFromResults : null,
            );
            updatedMessagesWithResponse = [...messages, assistantMessage];

            // Extract entities from <inapp_task>, <inapp_event>, <inapp_inbox> tags in assistant's response
            // and add them to tagged context for next conversation turn
            final extractedTasks = _extractTasksFromMessage(resultMessage);
            final extractedEvents = _extractEventsFromMessage(resultMessage);
            final extractedInboxes = _extractInboxesFromMessage(resultMessage);

            // Add extracted entities to tagged context (avoiding duplicates)
            if (extractedTasks.isNotEmpty) {
              final existingTaskIds = updatedTaggedTasks?.map((t) => t.id).toSet() ?? {};
              final newTasks = extractedTasks.where((t) => t.id != null && !existingTaskIds.contains(t.id)).toList();
              if (newTasks.isNotEmpty) {
                updatedTaggedTasks = [...(updatedTaggedTasks ?? []), ...newTasks];
              }
            }

            if (extractedEvents.isNotEmpty) {
              final existingEventIds = updatedTaggedEvents?.map((e) => e.uniqueId).toSet() ?? {};
              final newEvents = extractedEvents.where((e) => !existingEventIds.contains(e.uniqueId)).toList();
              if (newEvents.isNotEmpty) {
                updatedTaggedEvents = [...(updatedTaggedEvents ?? []), ...newEvents];
              }
            }

            if (extractedInboxes.isNotEmpty) {
              final existingInboxIds = updatedAvailableInboxes?.map((i) => i.id).toSet() ?? {};
              final newInboxes = extractedInboxes.where((i) => !existingInboxIds.contains(i.id)).toList();
              if (newInboxes.isNotEmpty) {
                updatedAvailableInboxes = [...(updatedAvailableInboxes ?? []), ...newInboxes];
              }
            }

            // 검색 결과 또는 추출된 엔티티가 있으면 state에 저장 (AI가 다음 응답에서 필요시 사용)
            if (updatedLoadedInboxNumbers != state.loadedInboxNumbers || updatedTaggedTasks != taggedTasks || updatedTaggedEvents != taggedEvents) {
              await _updateState(
                loadedInboxNumbers: updatedLoadedInboxNumbers,
                taggedProjects: taggedProjects,
                taggedTasks: updatedTaggedTasks,
                taggedEvents: updatedTaggedEvents,
                availableInboxes: updatedAvailableInboxes,
              );
            }

            // 재귀 호출인 경우 여기서 종료 (재귀 호출은 이미 상태를 업데이트했음)
            // 단, functionCallsToProcess가 비어있고 resultMessage가 비어있으면 일반 응답 처리로 넘어감
            if (isRecursiveCall && !(functionCallsToProcess.isEmpty && resultMessage.trim().isEmpty)) {
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
              await _updateState(messages: finalMessages, isLoading: false, taggedProjects: taggedProjects);
              return;
            }
          }

          // functionCallsToProcess가 비어있고 resultMessage가 비어있으면 일반 응답 처리로 넘어감
          // 검색 함수만 호출된 경우, searchContext를 가지고 원래 사용자 요청을 다시 처리
          // 첫 요청에서도 함수 호출만 있고 일반 응답이 없을 때 처리하도록 수정
          if (functionCallsToProcess.isEmpty && resultMessage.trim().isEmpty) {
            // searchContext를 가지고 원래 사용자 요청을 다시 처리하여 자연어 응답 생성
            final me = ref.read(authControllerProvider).value;
            final userId = me?.id;
            final selectedModel = this.selectedModel;
            String? apiKey;
            if (useUserApiKey) {
              final apiKeys = ref.read(aiApiKeysProvider);
              apiKey = apiKeys[selectedModel.provider.name];
            } else {
              apiKey = openAiApiKey.isNotEmpty ? openAiApiKey : null;
            }

            final projects = ref.read(projectListControllerProvider);
            final projectsList = projects.map((p) => {'id': p.uniqueId, 'name': p.name, 'description': p.description, 'parent_id': p.parentId}).toList();

            // Token optimization: limit history to recent messages only
            final filteredMessages = messages.where((m) => !m.excludeFromHistory).toList();
            final limitedMessages = filteredMessages.length > AgentActionMessage.maxHistoryMessages
                ? filteredMessages.sublist(filteredMessages.length - AgentActionMessage.maxHistoryMessages)
                : filteredMessages;
            final filteredHistory = limitedMessages.map((m) => m.toJson(local: true)).toList();

            // channelContext를 문자열로 변환
            String? channelContextStr;
            if (taggedChannels != null && taggedChannels.isNotEmpty) {
              channelContextStr = await _buildChannelContext(taggedChannels);
            }

            // searchContext를 가지고 원래 사용자 요청을 다시 처리
            // 재귀 호출에서는 이미 검색 결과가 있으므로 명확히 지시
            final enhancedUserMessage = searchContext != null && searchContext.isNotEmpty
                ? '$userMessage\n\n[CRITICAL: The search has already been completed and the search results are included in the "Searched Tasks" or "Searched Events" section below. Please answer the user\'s question directly. DO NOT use phrases like "I will search", "I will retrieve", "I will look up", "I will check", "I will organize into a list". Just provide the answer based on the search results immediately.]'
                : userMessage;

            // 재귀 호출에서는 검색 결과가 이미 있으므로 systemPrompt 추가
            // 검색 결과가 비어있을 때도 자연스럽게 응답하도록 지시
            final recursiveSystemPrompt = searchContext != null && searchContext.isNotEmpty
                ? 'IMPORTANT: The user has already requested a search, and the search results are provided in the "Searched Tasks" or "Searched Events" section below. You MUST answer the user\'s question directly based on these search results. DO NOT say things like "I will search", "I will retrieve", "I will look up", "I will check", "I will bring", "I will organize into a list" - the search is already done. Just provide the answer based on the search results. If the search results indicate that no items were found (e.g., "Search results: No tasks found for this period"), you MUST still provide a natural, friendly response to the user explaining that no items were found. Never return an empty response.'
                : null;

            final response = await _repository.generateGeneralChat(
              userMessage: enhancedUserMessage,
              conversationHistory: filteredHistory,
              projectContext: '',
              projects: projectsList,
              taggedContext: searchContext, // 검색 결과 context 사용
              channelContext: channelContextStr,
              inboxContext: null,
              model: selectedModel.modelName,
              apiKey: apiKey,
              userId: userId,
              includeTools: false, // 재귀 호출에서는 함수 호출 비활성화
              systemPrompt: recursiveSystemPrompt, // 재귀 호출 시 검색 결과가 이미 있다는 것을 명확히 지시
            );

            final aiResponse = response.fold(
              (failure) {
                // Show actual error message from failure
                String errorContent = Utils.mainContext.tr.agent_action_error_occurred;
                if (failure is Failure) {
                  final errorMsg = failure.toString();
                  if (errorMsg.isNotEmpty) {
                    errorContent = '${Utils.mainContext.tr.agent_action_error_occurred}\n\nError: $errorMsg';
                  }
                }
                final errorMessage = AgentActionMessage(role: 'assistant', content: errorContent);
                return [...messages, errorMessage];
              },
              (response) {
                if (response != null && response['message'] != null) {
                  final generalResponse = response['message'] as String;
                  // Check if response is empty or null
                  if (generalResponse.isEmpty || generalResponse.trim().isEmpty) {
                    // Empty response - show error message
                    final errorMessage = AgentActionMessage(role: 'assistant', content: '${Utils.mainContext.tr.agent_action_error_occurred}\n\nError: Empty response from AI');
                    return [...messages, errorMessage];
                  }
                  final assistantMessage = AgentActionMessage(role: 'assistant', content: generalResponse);
                  return [...messages, assistantMessage];
                } else {
                  // AI response is null or empty - show error message
                  final errorMessage = AgentActionMessage(role: 'assistant', content: '${Utils.mainContext.tr.agent_action_error_occurred}\n\nError: No response from AI');
                  return [...messages, errorMessage];
                }
              },
            );

            // 재귀 호출 완료 시 로딩 상태 해제
            final finalMessages = aiResponse.length >= 3 && aiResponse[0].role == 'user' && aiResponse[1].role == 'assistant' && aiResponse[2].role == 'assistant'
                ? [aiResponse[0], aiResponse[2]]
                : aiResponse;
            await _updateState(messages: finalMessages, isLoading: false, taggedProjects: taggedProjects);
            return;
          }

          // 재귀 호출에서 검색 함수만 호출된 경우는 이미 위에서 처리되었으므로 여기서는 처리하지 않음
          // 첫 요청에서도 함수 호출만 있고 일반 응답이 없을 때 처리하도록 수정
          if (!(functionCallsToProcess.isEmpty && resultMessage.trim().isEmpty)) {
            await _updateState(messages: updatedMessagesWithResponse, isLoading: false, taggedProjects: taggedProjects);
          }
        } else {
          // 일반 응답
          // 재귀 호출에서는 함수 호출을 파싱하지 않으므로, 여기서는 일반 응답만 처리

          // Check if aiMessage is empty after processing
          // 재귀 호출에서는 함수 호출 태그를 제거한 후 확인
          final messageToCheck = isRecursiveCall ? aiMessageWithoutFunctionCalls : aiMessage;
          if (messageToCheck.isEmpty || messageToCheck.trim().isEmpty) {
            // 재귀 호출에서 메시지가 비어있으면 searchContext를 사용하여 일반 응답 생성
            if (isRecursiveCall && searchContext != null) {
              // searchContext를 가지고 원래 사용자 요청을 다시 처리하여 자연어 응답 생성
              final me = ref.read(authControllerProvider).value;
              final userId = me?.id;
              final selectedModel = this.selectedModel;
              String? apiKey;
              if (useUserApiKey) {
                final apiKeys = ref.read(aiApiKeysProvider);
                apiKey = apiKeys[selectedModel.provider.name];
              } else {
                apiKey = openAiApiKey.isNotEmpty ? openAiApiKey : null;
              }

              final projects = ref.read(projectListControllerProvider);
              final projectsList = projects.map((p) => {'id': p.uniqueId, 'name': p.name, 'description': p.description, 'parent_id': p.parentId}).toList();

              // conversation history에서 함수 호출 메시지 제거
              final filteredHistory = messages.where((m) => !m.excludeFromHistory).map((m) => m.toJson(local: true)).toList();

              // channelContext를 문자열로 변환
              String? channelContextStr;
              if (taggedChannels != null && taggedChannels.isNotEmpty) {
                channelContextStr = await _buildChannelContext(taggedChannels);
              }

              // 재귀 호출에서는 이미 검색 결과가 있으므로 명확히 지시
              final enhancedUserMessage = searchContext != null && searchContext.isNotEmpty
                  ? '$userMessage\n\n[CRITICAL: The search has already been completed and the search results are included in the "Searched Tasks" or "Searched Events" section below. Please answer the user\'s question directly. DO NOT use phrases like "I will search", "I will retrieve", "I will look up", "I will check", "I will organize into a list". Just provide the answer based on the search results immediately.]'
                  : userMessage;

              // 재귀 호출에서는 검색 결과가 이미 있으므로 systemPrompt 추가
              // 검색 결과가 비어있을 때도 자연스럽게 응답하도록 지시
              final recursiveSystemPrompt = searchContext != null && searchContext.isNotEmpty
                  ? 'IMPORTANT: The user has already requested a search, and the search results are provided in the "Searched Tasks" or "Searched Events" section below. You MUST answer the user\'s question directly based on these search results. DO NOT say things like "I will search", "I will retrieve", "I will look up", "I will check", "I will bring", "I will organize into a list" - the search is already done. Just provide the answer based on the search results. If the search results indicate that no items were found (e.g., "Search results: No tasks found for this period"), you MUST still provide a natural, friendly response to the user explaining that no items were found. Never return an empty response.'
                  : null;

              final response = await _repository.generateGeneralChat(
                userMessage: enhancedUserMessage,
                conversationHistory: filteredHistory,
                projectContext: '',
                projects: projectsList,
                taggedContext: searchContext, // 검색 결과 context 사용
                channelContext: channelContextStr,
                inboxContext: null,
                model: selectedModel.modelName,
                apiKey: apiKey,
                userId: userId,
                includeTools: false, // 재귀 호출에서는 함수 호출 비활성화
                systemPrompt: recursiveSystemPrompt, // 재귀 호출 시 검색 결과가 이미 있다는 것을 명확히 지시
              );

              final aiResponse = response.fold(
                (failure) {
                  // Show actual error message from failure
                  String errorContent = Utils.mainContext.tr.agent_action_error_occurred;
                  if (failure is Failure) {
                    final errorMsg = failure.toString();
                    if (errorMsg.isNotEmpty) {
                      errorContent = '${Utils.mainContext.tr.agent_action_error_occurred}\n\nError: $errorMsg';
                    }
                  }
                  final errorMessage = AgentActionMessage(role: 'assistant', content: errorContent);
                  return [...messages, errorMessage];
                },
                (response) {
                  if (response != null && response['message'] != null) {
                    final generalResponse = response['message'] as String;
                    // Check if response is empty or null
                    if (generalResponse.isEmpty || generalResponse.trim().isEmpty) {
                      // Empty response - show error message
                      final errorMessage = AgentActionMessage(role: 'assistant', content: '${Utils.mainContext.tr.agent_action_error_occurred}\n\nError: Empty response from AI');
                      return [...messages, errorMessage];
                    }
                    // 함수 호출 태그만 있는 경우도 빈 응답으로 처리
                    String cleanedResponse = generalResponse
                        .replaceAll(RegExp(r'<function_call[^>]*>.*?</function_call>', dotAll: true), '')
                        .replaceAll(RegExp(r'</function_call>', dotAll: true), '')
                        .trim();

                    // JSON 배열 형식의 함수 호출 제거: [{"function": "...", "arguments": {...}}, ...]
                    try {
                      final arrayStart = cleanedResponse.indexOf('[');
                      final arrayEnd = cleanedResponse.lastIndexOf(']');
                      if (arrayStart != -1 && arrayEnd != -1 && arrayEnd > arrayStart) {
                        final arrayStr = cleanedResponse.substring(arrayStart, arrayEnd + 1);
                        try {
                          final parsed = jsonDecode(arrayStr) as List<dynamic>?;
                          if (parsed != null && parsed.isNotEmpty) {
                            // 함수 호출 배열인지 확인
                            bool isFunctionCallArray = true;
                            for (final item in parsed) {
                              if (item is! Map<String, dynamic> || !item.containsKey('function') || !item.containsKey('arguments')) {
                                isFunctionCallArray = false;
                                break;
                              }
                            }
                            if (isFunctionCallArray) {
                              // 함수 호출 배열이면 제거
                              cleanedResponse = cleanedResponse.replaceAll(arrayStr, '').trim();
                            }
                          }
                        } catch (e) {
                          // JSON 파싱 실패는 무시
                        }
                      }
                    } catch (e) {
                      // 배열 찾기 실패는 무시
                    }

                    // JSON 블록 형식의 함수 호출 제거: ```json\n{"function": "...", "arguments": {...}}\n```
                    try {
                      final jsonBlockRegex = RegExp(r'```json\s*(\{.*?\})\s*```', dotAll: true);
                      final jsonBlockMatches = jsonBlockRegex.allMatches(cleanedResponse);
                      for (final match in jsonBlockMatches.toList().reversed) {
                        final jsonStr = match.group(1);
                        if (jsonStr != null) {
                          try {
                            final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
                            if (parsed.containsKey('function') && parsed.containsKey('arguments')) {
                              // 함수 호출 블록이면 제거
                              cleanedResponse = cleanedResponse.replaceRange(match.start, match.end, '').trim();
                            }
                          } catch (e) {
                            // JSON 파싱 실패는 무시
                          }
                        }
                      }
                    } catch (e) {
                      // JSON 블록 찾기 실패는 무시
                    }

                    // 단일 JSON 객체 형식의 함수 호출 제거: {"function": "...", "arguments": {...}}
                    try {
                      final functionCallRegex = RegExp(r'\{[^}]*"function"\s*:\s*"([^"]+)"[^}]*"arguments"\s*:\s*(\{[^}]*\})[^}]*\}', dotAll: true);
                      final matches = functionCallRegex.allMatches(cleanedResponse);
                      for (final match in matches.toList().reversed) {
                        try {
                          final jsonStr = cleanedResponse.substring(match.start, match.end);
                          final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
                          if (parsed.containsKey('function') && parsed.containsKey('arguments')) {
                            // 함수 호출 객체이면 제거
                            cleanedResponse = cleanedResponse.replaceRange(match.start, match.end, '').trim();
                          }
                        } catch (e) {
                          // JSON 파싱 실패는 무시
                        }
                      }
                    } catch (e) {
                      // 함수 호출 객체 찾기 실패는 무시
                    }

                    if (cleanedResponse.isEmpty) {
                      // 함수 호출만 반환된 경우, 사용자에게 더 나은 메시지 표시
                      final errorMessage = AgentActionMessage(role: 'assistant', content: 'Sorry, there was an issue generating a response based on the search results. Please try again.');
                      return [...messages, errorMessage];
                    }
                    final assistantMessage = AgentActionMessage(role: 'assistant', content: cleanedResponse);
                    return [...messages, assistantMessage];
                  } else {
                    // AI response is null or empty - show error message
                    final errorMessage = AgentActionMessage(role: 'assistant', content: '${Utils.mainContext.tr.agent_action_error_occurred}\n\nError: No response from AI');
                    return [...messages, errorMessage];
                  }
                },
              );

              await _updateState(messages: aiResponse, isLoading: false, taggedProjects: taggedProjects);
              return;
            }
            // Empty response - show error message
            final errorMessage = AgentActionMessage(role: 'assistant', content: '${Utils.mainContext.tr.agent_action_error_occurred}\n\nError: Empty message after processing');
            final updatedMessagesWithResponse = [...messages, errorMessage];
            await _updateState(messages: updatedMessagesWithResponse, isLoading: false, taggedProjects: taggedProjects);
            return;
          }

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

          // need_more_action 태그는 더 이상 필요하지 않음
          // AI가 필요한 정보가 있으면 직접 MCP 함수를 호출할 수 있음 (searchInbox, getInboxDetails 등)

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
            await _updateState(messages: finalMessages, isLoading: false, taggedProjects: taggedProjects);
            return;
          }

          await _updateState(messages: updatedMessagesWithResponse, isLoading: false, taggedProjects: taggedProjects);
        }
      } else {
        await _updateState(messages: messages, isLoading: false, taggedProjects: taggedProjects);
      }
    } catch (e) {
      // 크레딧 부족 예외 처리
      String errorContent = Utils.mainContext.tr.agent_action_error_occurred;
      bool handledCreditsError = false;

      if (e is Failure) {
        e.whenOrNull(
          insufficientCredits: (_, required, available) {
            handledCreditsError = true;
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
            errorContent = Utils.mainContext.tr.ai_credits_insufficient_message(
              Utils.numberFormatter(requiredTokens.toDouble(), fractionDigits: 0),
              Utils.numberFormatter(availableTokens.toDouble(), fractionDigits: 0),
            );
          },
        );
      }

      // 크레딧 부족이 아닌 다른 에러의 경우 실제 에러 메시지 표시
      if (!handledCreditsError && e.toString().isNotEmpty) {
        errorContent = '${Utils.mainContext.tr.agent_action_error_occurred}\n\nError: ${e.toString()}';
      }

      await _updateState(
        messages: [
          ...messages,
          AgentActionMessage(role: 'assistant', content: errorContent),
        ],
        isLoading: false,
      );
    }
  }

  /// 태그를 제거하고 실제 title만 추출합니다.
  String _cleanTitleFromTags(String title) {
    String cleaned = title;

    // <tagged_task>, <tagged_event>, <tagged_inbox> 태그 제거 및 title 추출
    final taggedTaskRegex = RegExp(r'<tagged_task>(.*?)</tagged_task>', dotAll: true);
    final taggedEventRegex = RegExp(r'<tagged_event>(.*?)</tagged_event>', dotAll: true);
    final taggedInboxRegex = RegExp(r'<tagged_inbox>(.*?)</tagged_inbox>', dotAll: true);

    // @task:, @event:, @inbox: 형식 제거
    cleaned = cleaned.replaceAll(RegExp(r'@task:[a-zA-Z0-9\-_]+'), '');
    cleaned = cleaned.replaceAll(RegExp(r'@event:[a-zA-Z0-9\-_]+'), '');
    cleaned = cleaned.replaceAll(RegExp(r'@inbox:[a-zA-Z0-9\-_@\.]+'), '');

    // 태그된 항목의 title 추출하여 추가
    final List<String> extractedTitles = [];

    for (final match in taggedTaskRegex.allMatches(cleaned)) {
      try {
        final jsonText = match.group(1)?.trim() ?? '';
        if (jsonText.isNotEmpty) {
          final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
          final taskTitle = jsonData['title'] as String? ?? '';
          if (taskTitle.isNotEmpty) {
            extractedTitles.add(taskTitle);
          }
        }
      } catch (e) {
        // JSON 파싱 실패 시 무시
      }
    }

    for (final match in taggedEventRegex.allMatches(cleaned)) {
      try {
        final jsonText = match.group(1)?.trim() ?? '';
        if (jsonText.isNotEmpty) {
          final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
          final eventTitle = jsonData['title'] as String? ?? '';
          if (eventTitle.isNotEmpty) {
            extractedTitles.add(eventTitle);
          }
        }
      } catch (e) {
        // JSON 파싱 실패 시 무시
      }
    }

    for (final match in taggedInboxRegex.allMatches(cleaned)) {
      try {
        final jsonText = match.group(1)?.trim() ?? '';
        if (jsonText.isNotEmpty) {
          final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
          final inboxTitle = jsonData['suggestion']?['summary'] as String? ?? jsonData['title'] as String? ?? '';
          if (inboxTitle.isNotEmpty) {
            extractedTitles.add(inboxTitle);
          }
        }
      } catch (e) {
        // JSON 파싱 실패 시 무시
      }
    }

    // 태그 제거
    cleaned = cleaned.replaceAll(taggedTaskRegex, '');
    cleaned = cleaned.replaceAll(taggedEventRegex, '');
    cleaned = cleaned.replaceAll(taggedInboxRegex, '');

    // 추출된 title들을 추가
    if (extractedTitles.isNotEmpty) {
      cleaned = cleaned.trim();
      if (cleaned.isNotEmpty) {
        cleaned = '$cleaned ${extractedTitles.join(' ')}';
      } else {
        cleaned = extractedTitles.join(' ');
      }
    }

    return cleaned.trim();
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

    // createTask의 경우 inboxId 처리
    if (functionName == 'createTask' && availableInboxes != null && availableInboxes.isNotEmpty) {
      final currentInboxId = enrichedArgs['inboxId'] as String?;

      // 1. inboxId가 잘못된 형식인 경우 (예: inbox-item-10) 실제 inboxId로 교체
      if (currentInboxId != null && currentInboxId.isNotEmpty) {
        // inbox-item-* 형식인지 확인
        final itemNumberMatch = RegExp(r'inbox-item-(\d+)').firstMatch(currentInboxId);
        if (itemNumberMatch != null) {
          final itemNumber = int.tryParse(itemNumberMatch.group(1) ?? '');
          if (itemNumber != null && itemNumber > 0 && itemNumber <= availableInboxes.length) {
            // 항목 번호로 실제 inboxId 찾기 (1-based index)
            final targetInbox = availableInboxes[itemNumber - 1];
            enrichedArgs['inboxId'] = targetInbox.id;
          }
        }

        // 2. inboxId가 availableInboxes에 없는 경우, 제목이나 다른 정보로 매칭 시도
        final foundInbox = availableInboxes.firstWhereOrNull((inbox) => inbox.id == currentInboxId);
        if (foundInbox == null) {
          // 제목으로 매칭 시도 (AI가 제목을 기반으로 잘못된 inboxId를 생성했을 수 있음)
          final title = enrichedArgs['title'] as String?;
          if (title != null && title.isNotEmpty) {
            final matchedInbox = availableInboxes.firstWhereOrNull(
              (inbox) => inbox.title.toLowerCase().contains(title.toLowerCase()) || title.toLowerCase().contains(inbox.title.toLowerCase()),
            );
            if (matchedInbox != null) {
              enrichedArgs['inboxId'] = matchedInbox.id;
            }
          }
        }
      }

      // 3. inboxId가 없으면 threadId나 messageId로 inboxId 생성 (fallback만)
      if (!enrichedArgs.containsKey('inboxId') || enrichedArgs['inboxId'] == null || (enrichedArgs['inboxId'] as String).isEmpty) {
        final threadId = enrichedArgs['threadId'] as String?;
        final messageId = enrichedArgs['messageId'] as String?;

        String? generatedInboxId;

        // threadId가 있으면 mail로 간주하고 inboxId 생성
        if (threadId != null && threadId.isNotEmpty) {
          final mailInbox = availableInboxes.firstWhereOrNull((inbox) => inbox.linkedMail != null && inbox.linkedMail!.threadId == threadId);
          if (mailInbox != null && mailInbox.linkedMail != null) {
            generatedInboxId = InboxEntity.getInboxIdFromLinkedMail(mailInbox.linkedMail!);
          }
        }

        // messageId가 있으면 chat으로 간주하고 inboxId 생성
        if (generatedInboxId == null && messageId != null && messageId.isNotEmpty) {
          final chatInbox = availableInboxes.firstWhereOrNull((inbox) => inbox.linkedMessage != null && inbox.linkedMessage!.messageId == messageId);
          if (chatInbox != null && chatInbox.linkedMessage != null) {
            generatedInboxId = InboxEntity.getInboxIdFromLinkedChat(chatInbox.linkedMessage!);
          }
        }

        // 생성된 inboxId를 args에 추가
        if (generatedInboxId != null) {
          enrichedArgs['inboxId'] = generatedInboxId;
        }
      }
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
              buffer.writeln('- Channel ID: ${channel.id}');
              buffer.writeln('- Team ID: ${channel.teamId}');
              buffer.writeln('Messages from last 3 days (${sortedMessages.length} messages):\n');

              // 메시지 정보 추가 (최대 100개)
              for (final message in sortedMessages.take(100)) {
                final createdAt = message.createdAt;
                final text = message.text ?? '';
                final userId = message.userId ?? 'Unknown';
                final messageId = message.id ?? 'Unknown';

                if (text.isNotEmpty) {
                  final dateStr = createdAt != null ? createdAt.toIso8601String() : 'Unknown date';
                  buffer.writeln(
                    '- [${dateStr}] Message ID: ${messageId}, User ${userId}: ${text.substring(0, text.length > 200 ? 200 : text.length)}${text.length > 200 ? '...' : ''}',
                  );
                  final threadId = message.threadId;
                  if (threadId != null && threadId.isNotEmpty && threadId != messageId) {
                    buffer.writeln('  Thread ID: $threadId');
                  }
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
    // 사용자 메시지에서 함수 호출 파싱
    final executor = McpFunctionExecutor();
    final userFunctionCalls = executor.parseFunctionCalls(userMessage);

    // 사용자 메시지에서 함수 호출이 있으면 먼저 실행
    if (userFunctionCalls.isNotEmpty) {
      // 함수 호출을 제거한 순수 메시지 추출
      String cleanUserMessage = userMessage;
      for (final call in userFunctionCalls) {
        final callJson = jsonEncode(call);
        cleanUserMessage = cleanUserMessage.replaceAll('<function_call>$callJson</function_call>', '');
        cleanUserMessage = cleanUserMessage.replaceAll(callJson, '');
      }
      cleanUserMessage = cleanUserMessage.trim();

      // 함수 호출이 있으면 함수를 먼저 실행하고 결과를 포함해서 AI에게 전달
      final currentState = state;
      final availableInboxes = currentState.availableInboxes?.isNotEmpty == true ? currentState.availableInboxes : inboxes;
      final me = ref.read(authControllerProvider).value;
      final remainingCredits = me?.userAiCredits ?? 0.0;

      // 함수 실행
      final functionResults = <Map<String, dynamic>>[];
      var updatedTaggedTasks = taggedTasks;
      var updatedTaggedEvents = taggedEvents;
      var updatedAvailableInboxes = availableInboxes;

      for (final call in userFunctionCalls) {
        final functionName = call['function'] as String? ?? '';
        var functionArgs = Map<String, dynamic>.from(call['arguments'] as Map<String, dynamic>? ?? {});

        // 태그된 항목들을 자동으로 파라미터에 추가
        functionArgs = _enrichFunctionArgsWithTaggedItems(
          functionName: functionName,
          args: functionArgs,
          taggedTasks: updatedTaggedTasks,
          taggedEvents: updatedTaggedEvents,
          taggedConnections: taggedConnections,
          availableInboxes: updatedAvailableInboxes,
        );

        // 크레딧 정보를 함수 인자에 추가
        functionArgs['_remaining_credits'] = remainingCredits;

        // 함수 실행
        final tabType = _getTabTypeForFunction(functionName);
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

        functionResults.add(result);

        // 결과에서 생성된 task/event ID 추출
        if (result['success'] == true && result['result'] != null) {
          final resultData = result['result'] as Map<String, dynamic>?;
          if (resultData != null) {
            final taskId = resultData['taskId'] as String?;
            final eventId = resultData['eventId'] as String?;
            if (taskId != null) {
              final recentTaskIds = List<String>.from(currentState.recentTaskIds);
              if (!recentTaskIds.contains(taskId)) {
                recentTaskIds.add(taskId);
                await _updateState(recentTaskIds: recentTaskIds);
              }
            }
            if (eventId != null) {
              final recentEventIds = List<String>.from(currentState.recentEventIds);
              if (!recentEventIds.contains(eventId)) {
                recentEventIds.add(eventId);
                await _updateState(recentEventIds: recentEventIds);
              }
            }
          }
        }
      }

      // 함수 실행 결과를 메시지로 변환
      final functionResultsSummary = <String>[];
      bool onlyGetPreviousContext = functionResults.length == 1 &&
          (functionResults.first['function_name'] == 'getPreviousContext');

      for (final result in functionResults) {
        final success = result['success'] as bool? ?? false;
        if (success) {
          // For getPreviousContext, extract the actual summary content
          var message = result['message'] as String? ?? 'Completed successfully';
          if (result['result'] != null && result['result'] is Map<String, dynamic>) {
            final resultData = result['result'] as Map<String, dynamic>;
            if (resultData.containsKey('summary')) {
              message = resultData['summary'] as String? ?? message;
            }
          }
          if (message == result['message'] && result['result'] != null) {
            // Fallback: if we only have the success message, try to use the full result
            message = result['result'].toString();
          }
          functionResultsSummary.add(message);
        } else {
          final error = result['error'] as String? ?? 'An error occurred';
          functionResultsSummary.add('Error: $error');
        }
      }

      final functionResultsMessage = functionResultsSummary.isNotEmpty ? functionResultsSummary.join('\n') : '';

      // 태그된 항목들을 HTML 태그로 감싸서 메시지에 포함
      final cleanMessage = cleanUserMessage.isNotEmpty ? cleanUserMessage : userMessage.replaceAll(RegExp(r'<function_call>.*?</function_call>', dotAll: true), '').trim();
      final messageWithTags = _contextService.buildMessageWithTaggedItems(
        userMessage: cleanMessage,
        taggedTasks: updatedTaggedTasks,
        taggedEvents: updatedTaggedEvents,
        taggedInboxes: null, // Function call context doesn't include inboxes
        taggedConnections: taggedConnections,
        taggedChannels: taggedChannels,
        taggedProjects: taggedProjects,
      );

      final currentState2 = state;
      final messagesWithFunctionResults = [
        ...currentState2.messages,
        AgentActionMessage(role: 'user', content: messageWithTags, files: files),
        if (functionResultsMessage.isNotEmpty) AgentActionMessage(role: 'assistant', content: functionResultsMessage, excludeFromHistory: false),
      ];

      // If only getPreviousContext was called, directly show the result without asking AI to summarize
      if (onlyGetPreviousContext) {
        await _updateState(
          messages: messagesWithFunctionResults,
          isLoading: false,
        );
        return;
      }

      await _updateState(messages: messagesWithFunctionResults, isLoading: true);

      // 함수 실행 결과를 포함해서 AI에게 전달
      final inboxesToUse = currentState2.availableInboxes?.isNotEmpty == true ? currentState2.availableInboxes : inboxes;
      await _generateGeneralChat(
        cleanMessage.isNotEmpty ? cleanMessage : 'Function execution completed',
        updatedMessages: messagesWithFunctionResults,
        taggedTasks: updatedTaggedTasks,
        taggedEvents: updatedTaggedEvents,
        taggedConnections: taggedConnections,
        taggedChannels: taggedChannels,
        taggedProjects: taggedProjects,
        inboxes: inboxesToUse,
        files: files,
      );
      return;
    }

    // 태그된 항목들을 HTML 태그로 감싸서 메시지에 포함
    final messageWithTags = _contextService.buildMessageWithTaggedItems(
      userMessage: userMessage,
      taggedTasks: taggedTasks,
      taggedEvents: taggedEvents,
      taggedInboxes: null, // This function doesn't receive taggedInboxes
      taggedConnections: taggedConnections,
      taggedChannels: taggedChannels,
      taggedProjects: taggedProjects,
    );

    // 사용자 메시지 추가
    // IMPORTANT: 최신 state를 다시 읽어서 recentTaskIds/recentEventIds가 반영되었는지 확인
    final currentState = state;
    final updatedMessages = [...currentState.messages, AgentActionMessage(role: 'user', content: messageWithTags, files: files)];
    await _updateState(messages: updatedMessages, isLoading: true, taggedProjects: taggedProjects);

    try {
      // MCP 함수 호출을 통한 일반적인 AI 챗 진행
      // IMPORTANT: state가 최신 상태인지 확인하기 위해 다시 읽기
      // state.availableInboxes를 우선 사용 (검색 결과로 찾은 inbox 항목들)
      final currentState = state;
      final inboxesToUse = currentState.availableInboxes?.isNotEmpty == true ? currentState.availableInboxes : inboxes;
      await _generateGeneralChat(
        userMessage,
        updatedMessages: updatedMessages,
        taggedTasks: taggedTasks,
        taggedEvents: taggedEvents,
        taggedConnections: taggedConnections,
        taggedChannels: taggedChannels,
        taggedProjects: taggedProjects,
        inboxes: inboxesToUse,
        files: files,
      );
    } catch (e) {
      // Show actual error message
      String errorContent = Utils.mainContext.tr.agent_action_error_occurred;
      if (e.toString().isNotEmpty) {
        errorContent = '${Utils.mainContext.tr.agent_action_error_occurred}\n\nError: ${e.toString()}';
      }
      await _updateState(
        messages: [
          ...updatedMessages,
          AgentActionMessage(role: 'assistant', content: errorContent),
        ],
        isLoading: false,
        taggedProjects: taggedProjects,
      );
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
    await _updateState(messages: updatedMessages);

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
    // deleteTask의 경우 함수 실행 전에 task 정보를 추출하여 저장 (실행 후에는 삭제되어 찾을 수 없음)
    final deletedTasksBeforeExecution = <TaskEntity>[];
    // deleteEvent의 경우 함수 실행 전에 event 정보를 추출하여 저장 (실행 후에는 삭제되어 찾을 수 없음)
    final deletedEventsBeforeExecution = <EventEntity>[];
    final messageId = const Uuid().v4(); // 이번 confirm에 대한 고유 ID 생성

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

        // deleteTask의 경우 함수 실행 전에 task 정보 추출
        if (functionName == 'deleteTask') {
          final taskId = functionArgs['taskId'] as String?;
          if (taskId != null && taskId.isNotEmpty) {
            TaskEntity? taskToDelete;

            // 1. updated_tagged_tasks에서 task 찾기 (가장 확실한 방법)
            final updatedTaggedTasks = call['updated_tagged_tasks'] as List<dynamic>?;
            if (updatedTaggedTasks != null) {
              for (final taskData in updatedTaggedTasks) {
                if (taskData is TaskEntity && taskData.id == taskId) {
                  taskToDelete = taskData;
                  break;
                } else if (taskData is Map<String, dynamic> && taskData['id'] == taskId) {
                  try {
                    taskToDelete = TaskEntity.fromJson(taskData);
                    break;
                  } catch (_) {}
                }
              }
            }

            // 2. 찾지 못하면 컨트롤러에서 찾기 (삭제 전이므로 아직 있을 수 있음)
            if (taskToDelete == null) {
              try {
                final taskListState = ref.read(taskListControllerProvider);
                taskToDelete = taskListState.tasks.firstWhereOrNull((t) => t.id == taskId && !t.isEventDummyTask);
              } catch (_) {}

              if (taskToDelete == null) {
                try {
                  final calendarState = ref.read(calendarTaskListControllerProvider(tabType: TabType.home));
                  taskToDelete = calendarState.tasks.firstWhereOrNull((t) => t.id == taskId && !t.isEventDummyTask);
                } catch (_) {}
              }
            }

            // 3. task를 찾았으면 deletedTasksBeforeExecution에 추가하고 캐시에도 저장
            // 중요: task가 삭제되기 전에 완전한 복사본을 만들어서 저장 (삭제 후 정보 손실 방지)
            if (taskToDelete != null && !deletedTasksBeforeExecution.any((t) => t.id == taskId)) {
              // task의 완전한 복사본 생성 (모든 필드 보존)
              // copyWith를 사용하되, 모든 필드를 명시적으로 전달하여 완전한 복사본 생성
              final taskCopy = taskToDelete.copyWith(
                id: taskToDelete.id,
                ownerId: taskToDelete.ownerId,
                title: taskToDelete.title,
                description: taskToDelete.description,
                projectId: taskToDelete.projectId,
                startAt: taskToDelete.startAt,
                endAt: taskToDelete.endAt,
                isAllDay: taskToDelete.isAllDay,
                status: taskToDelete.status,
                createdAt: taskToDelete.createdAt,
                updatedAt: taskToDelete.updatedAt,
                linkedEvent: taskToDelete.linkedEvent,
                editedStartTime: taskToDelete.editedStartTime,
                editedEndTime: taskToDelete.editedEndTime,
                rrule: taskToDelete.rrule,
                recurrenceEndAt: taskToDelete.recurrenceEndAt,
                recurringTaskId: taskToDelete.recurringTaskId,
                excludedRecurrenceDate: taskToDelete.excludedRecurrenceDate,
                editedRecurrenceTaskIds: taskToDelete.editedRecurrenceTaskIds,
                reminders: taskToDelete.reminders,
                linkedMails: taskToDelete.linkedMails,
                linkedMessages: taskToDelete.linkedMessages,
              );

              // color는 copyWith 후에 별도로 설정
              if (taskToDelete.color != null) {
                taskCopy.setColor(taskToDelete.color!);
              }

              deletedTasksBeforeExecution.add(taskCopy);
              // 전역 캐시에 저장 (메시지 ID를 키로 사용)
              if (!_deletedTasksCache.containsKey(messageId)) {
                _deletedTasksCache[messageId] = [];
              }
              if (!_deletedTasksCache[messageId]!.any((t) => t.id == taskId)) {
                _deletedTasksCache[messageId]!.add(taskCopy);
              }
            }
          } else if (functionName == 'deleteEvent') {
            // deleteEvent의 경우 함수 실행 전에 event 정보 추출
            final eventId = functionArgs['eventId'] as String?;
            if (eventId != null && eventId.isNotEmpty) {
              EventEntity? eventToDelete;

              // 1. updated_tagged_events에서 event 찾기 (가장 확실한 방법)
              final updatedTaggedEvents = call['updated_tagged_events'] as List<dynamic>?;
              if (updatedTaggedEvents != null) {
                for (final eventData in updatedTaggedEvents) {
                  if (eventData is EventEntity && (eventData.eventId == eventId || eventData.uniqueId == eventId)) {
                    eventToDelete = eventData;
                    break;
                  }
                }
              }

              // 2. 찾지 못하면 컨트롤러에서 찾기 (삭제 전이므로 아직 있을 수 있음)
              if (eventToDelete == null) {
                try {
                  final calendarState = ref.read(calendarEventListControllerProvider(tabType: TabType.home));
                  eventToDelete = calendarState.eventsOnView.firstWhereOrNull((e) => e.eventId == eventId || e.uniqueId == eventId);
                } catch (_) {}
              }

              // 3. event를 찾았으면 deletedEventsBeforeExecution에 추가하고 캐시에도 저장
              // 중요: event가 삭제되기 전에 완전한 복사본을 만들어서 저장 (삭제 후 정보 손실 방지)
              if (eventToDelete != null && !deletedEventsBeforeExecution.any((e) => e.eventId == eventId || e.uniqueId == eventId)) {
                // event의 완전한 복사본 생성 (copyWith 사용)
                final eventCopy = eventToDelete.copyWith(
                  calendar: eventToDelete.calendar,
                  editedStartTime: eventToDelete.editedStartTime,
                  editedEndTime: eventToDelete.editedEndTime,
                );

                deletedEventsBeforeExecution.add(eventCopy);
                // 전역 캐시에 저장 (메시지 ID를 키로 사용)
                if (!_deletedEventsCache.containsKey(messageId)) {
                  _deletedEventsCache[messageId] = [];
                }
                if (!_deletedEventsCache[messageId]!.any((e) => e.eventId == eventId || e.uniqueId == eventId)) {
                  _deletedEventsCache[messageId]!.add(eventCopy);
                }
              }
            }
          }
        }
      }
    }

    if (callsToExecute.isEmpty) {
      return;
    }

    // 로딩 상태 시작 - entity block은 유지하고 로딩 메시지만 표시
    await _updateState(isLoading: true);

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

          final functionResult = {
            'function_name': functionName,
            'success': true,
            'message': message,
            if (taskId != null) 'taskId': taskId,
            if (eventId != null) 'eventId': eventId,
            if (projectId != null) 'projectId': projectId,
            if (result['result'] != null) 'result': result['result'], // summarizeAttachment의 files 데이터 포함
          };
          functionResults.add(functionResult);
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
    List<PlatformFile>? attachmentFiles;

    // 함수 실행 결과 요약 생성 - 실제 실행된 함수 호출 개수와 결과를 정확히 전달
    final functionResultsSummary = <String>[];
    String? getPreviousContextSummary; // Store getPreviousContext summary separately

    for (final result in functionResults) {
      final functionName = result['function_name'] as String? ?? '';
      final success = result['success'] as bool? ?? false;

      if (success) {
        final message = result['message'] as String? ?? '';
        final taskId = result['taskId'] as String?;
        final eventId = result['eventId'] as String?;
        final projectId = result['projectId'] as String?;

        // getPreviousContext: extract summary and store separately (don't ask AI to summarize)
        if (functionName == 'getPreviousContext') {
          final resultData = result['result'] as Map<String, dynamic>?;
          final summary = resultData?['summary'] as String?;
          if (summary != null && summary.isNotEmpty) {
            getPreviousContextSummary = summary;
          }
          continue; // Don't add to functionResultsSummary
        }

        // summarizeAttachment: extract summary from result
        if (functionName == 'summarizeAttachment') {
          final resultData = result['result'] as Map<String, dynamic>?;

          // summary를 메시지에 사용
          final summary = resultData?['summary'] as String?;
          if (summary != null && summary.isNotEmpty) {
            // summary를 메시지로 사용 (기존 message 대신)
            final summaryMessage = summary;
            functionResultsSummary.add('$functionName: $summaryMessage');
          }

          // Already processed, continue
          continue;
        }

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

    // getPreviousContext was called alone - directly use the summary without AI processing
    if (getPreviousContextSummary != null && functionResultsSummary.isEmpty) {
      resultMessage = getPreviousContextSummary;
    }
    // 함수 실행 결과를 AI에게 전달하여 메시지 생성
    else if (functionResultsSummary.isNotEmpty) {
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
          'The following $executedCount function call(s) were executed (${successCount} succeeded, ${errorCount} failed):\n$functionResultsText$additionalInfo$recentIdsWarning\n\nPlease provide a natural, user-friendly message summarizing what was done. Be concise and clear. IMPORTANT: Use the exact number of function calls executed ($executedCount), not any other number.\n\nCRITICAL: If any taskId or eventId is mentioned above (e.g., "taskId: xxx" or "Created task IDs: xxx"), you MUST include it in your response message so it can be referenced in future conversations. Format: "Task created successfully (taskId: xxx)" or "Task ID: xxx".\n\nABSOLUTE RULE: These functions have ALREADY been executed. DO NOT call these functions again. Only provide a summary message, do NOT call any functions.';

      // 함수 실행 결과를 포함한 메시지로 AI 호출 (summarizeAttachment의 경우 files 포함)
      final functionResultsMessages = [...state.messages, AgentActionMessage(role: 'user', content: functionResultsPrompt, files: attachmentFiles)];

      final me = ref.read(authControllerProvider).value;
      final userId = me?.id;
      final selectedModel = this.selectedModel;
      String? apiKey;
      if (useUserApiKey) {
        final apiKeys = ref.read(aiApiKeysProvider);
        apiKey = apiKeys[selectedModel.provider.name];
      } else {
        // 환경 변수에서 가져오기 (datasource와 동일한 방식)
        // 전역 변수에서 가져오기 (Edge Function에서 업데이트됨)
        apiKey = openAiApiKey.isNotEmpty ? openAiApiKey : null;
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
              'You are a helpful assistant. Provide a brief, natural summary of the function execution results. CRITICAL: If any taskId or eventId is mentioned in the function results (e.g., "taskId: xxx" or "Created task IDs: xxx"), you MUST include it in your response message so it can be referenced in future conversations. Always include taskId/eventId in the format "(taskId: xxx)" or "(Task ID: xxx)".\n\nABSOLUTE RULE: The functions mentioned in the user message have ALREADY been executed. DO NOT call any functions. Only provide a summary message describing what was done. DO NOT call createTask, updateTask, createEvent, updateEvent, or any other functions. If the user message mentions "recentTaskIds" or "recentEventIds" or "RECENT task ID", it means a task/event was JUST created. DO NOT call createTask/createEvent again - only provide a summary message.',
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
    // deleteTask의 경우 함수 실행 전에 추출한 task 정보 사용 (deletedTasksBeforeExecution 또는 캐시에서)
    final cachedDeletedTasks = _deletedTasksCache[messageId] ?? deletedTasksBeforeExecution;
    // deleteEvent의 경우 함수 실행 전에 추출한 event 정보 사용 (deletedEventsBeforeExecution 또는 캐시에서)
    final cachedDeletedEvents = _deletedEventsCache[messageId] ?? deletedEventsBeforeExecution;

    final filesToInclude = attachmentFiles?.isNotEmpty == true ? attachmentFiles : null;
    final assistantMessage = AgentActionMessage(
      role: 'assistant',
      content: resultMessage,
      excludeFromHistory: true,
      files: filesToInclude, // summarizeAttachment에서 추출한 파일 포함
      deletedTasks: cachedDeletedTasks.isNotEmpty ? cachedDeletedTasks : null, // 삭제된 task 정보 포함
      deletedEvents: cachedDeletedEvents.isNotEmpty ? cachedDeletedEvents : null, // 삭제된 event 정보 포함
    );
    final updatedMessages = [...state.messages, assistantMessage];

    // pendingFunctionCalls에서 실행된 항목 제거 (entity block은 유지)
    final updatedPendingCalls = pendingCalls.where((call) {
      final callActionId = call['action_id'] as String?;
      return callActionId == null || !actionIds.contains(callActionId);
    }).toList();

    await _updateState(
      messages: updatedMessages,
      pendingFunctionCalls: updatedPendingCalls.isEmpty ? null : updatedPendingCalls,
      isLoading: false,
      recentTaskIds: updatedTaskIds,
      recentEventIds: updatedEventIds,
    );
  }

  /// 액션 선택 상태를 토글합니다.
  Future<void> toggleActionSelection(String actionId) async {
    final selectedIds = Set<String>.from(state.selectedActionIds);
    if (selectedIds.contains(actionId)) {
      selectedIds.remove(actionId);
    } else {
      selectedIds.add(actionId);
    }
    await _updateState(selectedActionIds: selectedIds);
  }

  /// 모든 액션을 선택하거나 선택 해제합니다.
  Future<void> toggleAllActionsSelection(bool selectAll) async {
    final pendingCalls = state.pendingFunctionCalls ?? [];
    if (selectAll) {
      final allActionIds = pendingCalls.map((call) => call['action_id'] as String?).whereType<String>().toSet();
      await _updateState(selectedActionIds: allActionIds);
    } else {
      await _updateState(selectedActionIds: {});
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
    await _updateState(
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

  /// 메시지의 태그를 실제 title로 변환합니다.
  List<AgentActionMessage> _convertTagsToTitles(List<AgentActionMessage> messages) {
    return messages.map((message) {
      String content = message.content;

      // <tagged_task>, <tagged_event>, <tagged_inbox> 태그를 @title 형식으로 변환
      final taggedTaskRegex = RegExp(r'<tagged_task>(.*?)</tagged_task>', dotAll: true);
      final taggedEventRegex = RegExp(r'<tagged_event>(.*?)</tagged_event>', dotAll: true);
      final taggedInboxRegex = RegExp(r'<tagged_inbox>(.*?)</tagged_inbox>', dotAll: true);

      // @task:, @event:, @inbox: 형식을 @title 형식으로 변환
      final atTaskRegex = RegExp(r'@task:([a-f0-9\-]+)', caseSensitive: false);
      final atEventRegex = RegExp(r'@event:([a-f0-9\-]+)', caseSensitive: false);
      final atInboxRegex = RegExp(r'@inbox:([a-z0-9_\-@\.]+)', caseSensitive: false);

      // <tagged_task> 태그 처리
      for (final match in taggedTaskRegex.allMatches(content).toList().reversed) {
        try {
          final jsonText = match.group(1)?.trim() ?? '';
          if (jsonText.isNotEmpty) {
            final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
            String title = jsonData['title'] as String? ?? '';

            // title이 없으면 id로 찾기
            if (title.isEmpty) {
              final id = jsonData['id'] as String?;
              if (id != null) {
                try {
                  final tasks = ref.read(calendarTaskListControllerProvider(tabType: TabType.home)).tasksOnView;
                  final task = tasks.firstWhereOrNull((t) => t.id == id || t.eventId == id);
                  title = task?.title ?? '';
                } catch (e) {
                  // Task를 찾을 수 없으면 빈 문자열 유지
                }
              }
            }

            if (title.isNotEmpty) {
              content = content.substring(0, match.start) + '@$title' + content.substring(match.end);
            } else {
              // title을 찾을 수 없으면 태그 제거
              content = content.substring(0, match.start) + content.substring(match.end);
            }
          }
        } catch (e) {
          // JSON 파싱 실패 시 태그 제거
          content = content.substring(0, match.start) + content.substring(match.end);
        }
      }

      // <tagged_event> 태그 처리
      for (final match in taggedEventRegex.allMatches(content).toList().reversed) {
        try {
          final jsonText = match.group(1)?.trim() ?? '';
          if (jsonText.isNotEmpty) {
            final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
            String title = jsonData['title'] as String? ?? '';

            // title이 없으면 id로 찾기
            if (title.isEmpty) {
              final id = jsonData['id'] as String? ?? jsonData['event_id'] as String?;
              if (id != null) {
                try {
                  final events = ref.read(calendarEventListControllerProvider(tabType: TabType.home)).eventsOnView;
                  final event = events.firstWhereOrNull((e) => e.eventId == id);
                  title = event?.title ?? '';
                } catch (e) {
                  // Event를 찾을 수 없으면 빈 문자열 유지
                }
              }
            }

            if (title.isNotEmpty) {
              content = content.substring(0, match.start) + '@$title' + content.substring(match.end);
            } else {
              // title을 찾을 수 없으면 태그 제거
              content = content.substring(0, match.start) + content.substring(match.end);
            }
          }
        } catch (e) {
          // JSON 파싱 실패 시 태그 제거
          content = content.substring(0, match.start) + content.substring(match.end);
        }
      }

      // <tagged_inbox> 태그 처리
      for (final match in taggedInboxRegex.allMatches(content).toList().reversed) {
        try {
          final jsonText = match.group(1)?.trim() ?? '';
          if (jsonText.isNotEmpty) {
            final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
            String title = jsonData['suggestion']?['summary'] as String? ?? jsonData['title'] as String? ?? '';

            // title이 없으면 id로 찾기
            if (title.isEmpty) {
              final id = jsonData['id'] as String?;
              if (id != null) {
                try {
                  final inboxList = ref.read(inboxControllerProvider);
                  final inbox = inboxList?.inboxes.firstWhereOrNull((i) => i.id == id);
                  title = inbox?.decryptedTitle ?? '';
                } catch (e) {
                  // Inbox를 찾을 수 없으면 빈 문자열 유지
                }
              }
            }

            if (title.isNotEmpty) {
              content = content.substring(0, match.start) + '@$title' + content.substring(match.end);
            } else {
              // title을 찾을 수 없으면 태그 제거
              content = content.substring(0, match.start) + content.substring(match.end);
            }
          }
        } catch (e) {
          // JSON 파싱 실패 시 태그 제거
          content = content.substring(0, match.start) + content.substring(match.end);
        }
      }

      // @task: 형식 처리
      for (final match in atTaskRegex.allMatches(content).toList().reversed) {
        final taskId = match.group(1);
        if (taskId != null) {
          try {
            final tasks = ref.read(calendarTaskListControllerProvider(tabType: TabType.home)).tasksOnView;
            final task = tasks.firstWhereOrNull((t) => t.id == taskId || t.eventId == taskId);
            final title = task?.title ?? '';
            if (title.isNotEmpty) {
              content = content.substring(0, match.start) + '@$title' + content.substring(match.end);
            } else {
              // title을 찾을 수 없으면 태그 제거
              content = content.substring(0, match.start) + content.substring(match.end);
            }
          } catch (e) {
            // Task를 찾을 수 없으면 태그 제거
            content = content.substring(0, match.start) + content.substring(match.end);
          }
        }
      }

      // @event: 형식 처리
      for (final match in atEventRegex.allMatches(content).toList().reversed) {
        final eventId = match.group(1);
        if (eventId != null) {
          try {
            final events = ref.read(calendarEventListControllerProvider(tabType: TabType.home)).eventsOnView;
            final event = events.firstWhereOrNull((e) => e.eventId == eventId);
            final title = event?.title ?? '';
            if (title.isNotEmpty) {
              content = content.substring(0, match.start) + '@$title' + content.substring(match.end);
            } else {
              // title을 찾을 수 없으면 태그 제거
              content = content.substring(0, match.start) + content.substring(match.end);
            }
          } catch (e) {
            // Event를 찾을 수 없으면 태그 제거
            content = content.substring(0, match.start) + content.substring(match.end);
          }
        }
      }

      // @inbox: 형식 처리
      for (final match in atInboxRegex.allMatches(content).toList().reversed) {
        final inboxId = match.group(1);
        if (inboxId != null) {
          try {
            final inboxList = ref.read(inboxControllerProvider);
            final inbox = inboxList?.inboxes.firstWhereOrNull((i) => i.id == inboxId);
            final title = inbox?.decryptedTitle ?? '';
            if (title.isNotEmpty) {
              content = content.substring(0, match.start) + '@$title' + content.substring(match.end);
            } else {
              // title을 찾을 수 없으면 태그 제거
              content = content.substring(0, match.start) + content.substring(match.end);
            }
          } catch (e) {
            // Inbox를 찾을 수 없으면 태그 제거
            content = content.substring(0, match.start) + content.substring(match.end);
          }
        }
      }

      return AgentActionMessage(role: message.role, content: content, files: message.files, excludeFromHistory: message.excludeFromHistory);
    }).toList();
  }

  /// State를 업데이트하고 히스토리를 저장합니다.
  Future<void> _updateState({
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
    List<InboxEntity>? availableInboxes,
    List<TaskEntity>? taggedTasks,
    List<EventEntity>? taggedEvents,
    List<ProjectEntity>? taggedProjects,
  }) async {
    state = state.copyWith(
      actionType: actionType,
      inbox: inbox,
      task: task,
      event: event,
      messages: messages,
      isLoading: isLoading,
      pendingTaskInfo: pendingTaskInfo,
      conversationSummary: conversationSummary,
      sessionId: sessionId,
      loadedInboxNumbers: loadedInboxNumbers,
      pendingFunctionCalls: pendingFunctionCalls,
      selectedActionIds: selectedActionIds,
      recentTaskIds: recentTaskIds,
      recentEventIds: recentEventIds,
      availableInboxes: availableInboxes,
      taggedTasks: taggedTasks,
      taggedEvents: taggedEvents,
    );

    // State 업데이트 후 항상 히스토리 저장 시도
    await _saveChatHistory(taggedProjects: taggedProjects);
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

    // 태그를 실제 title로 변환한 메시지 생성
    final convertedMessages = _convertTagsToTitles(state.messages);

    final now = DateTime.now();
    final history = AgentChatHistoryEntity(
      id: sessionId,
      projectId: projectId,
      messages: convertedMessages,
      actionType: state.actionType?.name,
      conversationSummary: state.conversationSummary,
      createdAt: now, // createdAt은 항상 현재 시간 (기존 세션의 경우 업데이트만 수행)
      updatedAt: now,
    );

    // 세션 ID가 없었으면 state에 설정
    if (state.sessionId == null) {
      state = state.copyWith(sessionId: sessionId);
    }

    try {
      await _historyRepository.saveChatHistory(userId: me.id, history: history);
    } catch (e) {
      // Supabase 저장 실패는 무시
    }
  }

  /// AI 응답에서 토큰 사용량을 추출하고 저장합니다
  Future<void> _saveTokenUsage(Map<String, dynamic> aiResponse, AgentModel model, bool useUserApiKey) async {
    try {
      final me = ref.read(authControllerProvider).value;
      if (me == null) {
        return;
      }

      // Check if datasource already extracted token usage to _token_usage field
      TokenUsage? tokenUsage;
      final customTokenUsage = aiResponse['_token_usage'] as Map<String, dynamic>?;

      if (customTokenUsage != null) {
        // Extract from custom _token_usage field (already processed by datasource)
        final promptTokens = customTokenUsage['prompt_tokens'] as int? ?? 0;
        final completionTokens = customTokenUsage['completion_tokens'] as int? ?? 0;
        final totalTokens = customTokenUsage['total_tokens'] as int? ?? (promptTokens + completionTokens);

        tokenUsage = TokenUsage(
          promptTokens: promptTokens,
          completionTokens: completionTokens,
          totalTokens: totalTokens,
        );
      } else {
        // Fallback to provider-specific extraction
        if (model.provider == AiProvider.anthropic) {
          tokenUsage = TokenUsageExtractor.extractFromAnthropic(aiResponse);
        } else if (model.provider == AiProvider.google) {
          tokenUsage = TokenUsageExtractor.extractFromGoogleAi(aiResponse);
        } else if (model.provider == AiProvider.openai) {
          tokenUsage = TokenUsageExtractor.extractFromOpenAi(aiResponse);
        }
      }

      if (tokenUsage == null) {
        return;
      }

      // Calculate credits used
      final creditsUsed = AiPricingCalculator.calculateCreditsCostFromModel(
        promptTokens: tokenUsage.promptTokens,
        completionTokens: tokenUsage.completionTokens,
        model: model,
      );

      // Create usage log entity
      final usageLog = AiApiUsageLogEntity(
        id: const Uuid().v4(),
        userId: me.id,
        apiProvider: model.provider.key,
        model: model.modelName,
        functionName: 'agent_chat', // Function name for agent chat
        promptTokens: tokenUsage.promptTokens,
        completionTokens: tokenUsage.completionTokens,
        totalTokens: tokenUsage.totalTokens,
        creditsUsed: creditsUsed,
        usedUserApiKey: useUserApiKey,
        createdAt: DateTime.now(),
      );

      // Save usage log to Supabase
      final datasource = SupabaseAiUsageLogDatasource();
      await datasource.saveUsageLog(usageLog);

      // Deduct credits from user if using platform credits (not user API key)
      if (!useUserApiKey) {
        // Refresh user entity to get updated credits from backend
        // The backend should handle credit deduction via Supabase triggers/functions
        ref.invalidate(authControllerProvider);
      }
    } catch (e) {
      // Don't throw - token usage tracking is non-critical
    }
  }

  /// Extract TaskEntity objects from <inapp_task> tags in message
  List<TaskEntity> _extractTasksFromMessage(String message) {
    final tasks = <TaskEntity>[];
    final regex = RegExp(r'<inapp_task>(.*?)</inapp_task>', dotAll: true);

    for (final match in regex.allMatches(message)) {
      try {
        final jsonText = match.group(1)?.trim();
        if (jsonText != null && jsonText.isNotEmpty) {
          final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
          final task = TaskEntity.fromJson(jsonData, local: true);
          if (task.id != null && task.id!.isNotEmpty) {
            tasks.add(task);
          }
        }
      } catch (e) {
        // Skip invalid task JSON
      }
    }

    return tasks;
  }

  /// Extract EventEntity objects from <inapp_event> tags in message
  List<EventEntity> _extractEventsFromMessage(String message) {
    final events = <EventEntity>[];
    final regex = RegExp(r'<inapp_event>(.*?)</inapp_event>', dotAll: true);

    for (final match in regex.allMatches(message)) {
      try {
        final jsonText = match.group(1)?.trim();
        if (jsonText != null && jsonText.isNotEmpty) {
          final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;

          // Try to create EventEntity from full JSON (if it has all required fields)
          try {
            final event = EventEntity.fromJson(jsonData);
            if (event.title != null && event.title!.isNotEmpty) {
              events.add(event);
            }
          } catch (e) {
            // If fromJson fails, skip - EventEntity requires calendar which we may not have
          }
        }
      } catch (e) {
        // Skip invalid event JSON
      }
    }

    return events;
  }

  /// Extract InboxEntity objects from <inapp_inbox> tags in message
  List<InboxEntity> _extractInboxesFromMessage(String message) {
    final inboxes = <InboxEntity>[];
    final regex = RegExp(r'<inapp_inbox>(.*?)</inapp_inbox>', dotAll: true);

    for (final match in regex.allMatches(message)) {
      try {
        final jsonText = match.group(1)?.trim();
        if (jsonText != null && jsonText.isNotEmpty) {
          final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
          final inbox = InboxEntity.fromJson(jsonData, local: true);
          if (inbox.id.isNotEmpty) {
            inboxes.add(inbox);
          }
        }
      } catch (e) {
        // Skip invalid inbox JSON
      }
    }

    return inboxes;
  }
}
