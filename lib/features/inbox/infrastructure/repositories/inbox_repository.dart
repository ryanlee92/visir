import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/common/domain/entities/ai_provider_entity.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/common/domain/failures/failure.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/inbox/domain/datasources/inbox_datasource.dart';
import 'package:Visir/features/inbox/domain/entities/agent_model_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_config_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_suggestion_entity.dart';
import 'package:Visir/features/inbox/infrastructure/datasources/anthropic_ai_inbox_datasource.dart';
import 'package:Visir/features/inbox/infrastructure/datasources/google_ai_inbox_datasource.dart';
import 'package:Visir/features/inbox/infrastructure/datasources/openai_inbox_datasource.dart';
import 'package:Visir/features/inbox/infrastructure/services/ai_credits_service.dart';
import 'package:Visir/features/inbox/infrastructure/utils/token_usage_extractor.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:fpdart/fpdart.dart';

class InboxRepository {
  InboxRepository({required this.datasources, AiCreditsService? creditsService}) : _creditsService = creditsService;

  final Map<DatasourceType, InboxDatasource> datasources;
  final AiCreditsService? _creditsService;

  List<DatasourceType> get remoteDatasourceTypes => DatasourceType.values;

  /// AI 호출 전 크레딧 사전 체크 헬퍼 메서드
  Future<void> _checkCreditsBeforeCall({
    required String? userId,
    required String model,
    required int estimatedPromptTokens,
    int estimatedCompletionTokens = 500,
    required bool usedUserApiKey,
  }) async {
    if (usedUserApiKey || userId == null || _creditsService == null) {
      return;
    }

    // Model name을 AgentModel enum으로 변환
    AgentModel? agentModel;
    try {
      agentModel = AgentModel.values.firstWhere((m) => m.modelName == model, orElse: () => AgentModel.gpt4oMini);
    } catch (e) {
      agentModel = AgentModel.gpt4oMini;
    }

    try {
      await _creditsService.checkCreditsBeforeCall(
        userId: userId,
        model: agentModel,
        estimatedPromptTokens: estimatedPromptTokens,
        estimatedCompletionTokens: estimatedCompletionTokens,
        usedUserApiKey: usedUserApiKey,
      );
    } catch (e) {
      // 크레딧 부족 예외인 경우 rethrow
      if (e is Failure) {
        rethrow;
      }
    }
  }

  /// 크레딧 체크 및 차감 헬퍼 메서드
  Future<void> _checkAndDeductCreditsIfNeeded({
    required Map<String, dynamic>? result,
    required String? userId,
    required String model,
    required String functionName,
    required bool usedUserApiKey,
  }) async {
    if (result == null || _creditsService == null || userId == null || usedUserApiKey) {
      return;
    }

    try {
      // 토큰 정보 추출
      final tokenUsageMap = result['_token_usage'] as Map<String, dynamic>?;
      if (tokenUsageMap != null) {
        final tokenUsage = TokenUsage(
          promptTokens: tokenUsageMap['prompt_tokens'] as int? ?? 0,
          completionTokens: tokenUsageMap['completion_tokens'] as int? ?? 0,
          totalTokens: tokenUsageMap['total_tokens'] as int? ?? 0,
        );

        // Model name을 AgentModel enum으로 변환
        AgentModel? agentModel;
        try {
          agentModel = AgentModel.values.firstWhere((m) => m.modelName == model, orElse: () => AgentModel.gpt4oMini);
        } catch (e) {
          agentModel = AgentModel.gpt4oMini;
        }

        // 크레딧 체크 및 차감
        await _creditsService.checkAndDeductCredits(userId: userId, model: agentModel, functionName: functionName, tokenUsage: tokenUsage, usedUserApiKey: usedUserApiKey);
      }
    } catch (e) {
      // 크레딧 부족 예외인 경우 rethrow하여 상위에서 처리
      if (e is Failure) {
        final failure = e;
        failure.whenOrNull(
          insufficientCredits: (_, required, available) {
            // 크레딧 부족 예외는 rethrow
            throw failure;
          },
        );
      }
      // 기타 에러는 조용히 처리 (결과는 반환)
      // TODO: 에러 로깅 추가
    }
  }

  /// Model name으로부터 provider를 추론하고 적절한 datasource를 반환합니다.
  InboxDatasource? _getDatasourceForModel(String? model) {
    // Model name을 AgentModel enum으로 변환
    AgentModel? agentModel = AgentModel.gpt4oMini;
    try {
      agentModel = AgentModel.values.firstWhere(
        (m) => m.modelName == model,
        orElse: () => AgentModel.gpt4oMini, // 기본값
      );
    } catch (e) {
      // Model name이 매칭되지 않으면 기본값 사용
      agentModel = AgentModel.gpt4oMini;
    }

    // Provider에 따라 적절한 datasource 선택
    final provider = agentModel.provider;
    switch (provider) {
      case AiProvider.openai:
        return datasources[DatasourceType.openai];
      // fixme(Ryan): Google AI, Anthrophic commented
      // case AiProvider.google:
      //   return datasources[DatasourceType.google];
      // case AiProvider.anthropic:
      //   return datasources[DatasourceType.microsoft]; // Anthropic은 microsoft 타입으로 매핑
    }
  }

  Future<Either<Failure, List<InboxSuggestionEntity>>> fetchInboxSuggestions({
    required List<InboxEntity> inboxes,
    required List<ProjectEntity> projects,
    String? model,
    String? apiKey,
    String? userId,
  }) async {
    try {
      final allSuggestions = <InboxSuggestionEntity>[];
      final supabaseDatasource = datasources[DatasourceType.supabase];

      // Step 1: Try to fetch from Supabase cache if userId is provided
      if (userId != null && supabaseDatasource != null && inboxes.isNotEmpty) {
        try {
          final inboxIds = inboxes.map((e) => e.id).toList();
          final cachedSuggestions = await supabaseDatasource.fetchInboxSuggestionsFromCache(userId: userId, inboxIds: inboxIds);

          // Add cached suggestions to result
          allSuggestions.addAll(cachedSuggestions);

          // Filter out inboxes that already have cached suggestions
          final cachedInboxIds = cachedSuggestions.map((s) => s.id).toSet();
          final remainingInboxes = inboxes.where((inbox) => !cachedInboxIds.contains(inbox.id)).toList();

          // If all inboxes have cached suggestions, return early
          if (remainingInboxes.isEmpty) {
            return right(allSuggestions);
          }

          // Step 2: Fetch from AI for remaining inboxes
          final finalModel = model ?? AgentModel.gpt41Mini.modelName;
          final aiDatasource = _getDatasourceForModel(finalModel);

          if (aiDatasource != null && remainingInboxes.isNotEmpty) {
            final aiSuggestions = await aiDatasource.fetchInboxSuggestions(inboxes: remainingInboxes, projects: projects, model: finalModel, apiKey: apiKey);

            // Add AI suggestions to result
            allSuggestions.addAll(aiSuggestions);

            // Step 3: Save AI suggestions to Supabase cache
            if (aiSuggestions.isNotEmpty && supabaseDatasource != null) {
              try {
                await supabaseDatasource.saveInboxSuggestions(userId: userId, suggestions: aiSuggestions);
              } catch (e) {
                // If save fails, log but don't fail the request
              }
            }
          }

          return right(allSuggestions);
        } catch (e) {
          // If cache fetch fails, fallback to AI
        }
      }

      // Fallback: Fetch directly from AI if no userId or cache fetch failed
      final finalModel = model ?? AgentModel.gpt41Mini.modelName;
      final datasource = _getDatasourceForModel(finalModel);

      if (datasource != null) {
        final result = await datasource.fetchInboxSuggestions(inboxes: inboxes, projects: projects, model: finalModel, apiKey: apiKey);

        // Save to cache if userId is provided
        if (userId != null && result.isNotEmpty && supabaseDatasource != null) {
          try {
            await supabaseDatasource.saveInboxSuggestions(userId: userId, suggestions: result);
          } catch (e) {
            // If save fails, log but don't fail the request
          }
        }

        return right(result);
      }

      return right([]);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, List<InboxConfigEntity>>> fetchInboxConfig({required String userId, List<String>? configIds}) async {
    try {
      final list = [DatasourceType.supabase].map((d) => datasources[d]?.fetchInboxConfig(userId: userId, configIds: configIds)).whereType<Future<List<InboxConfigEntity>>>();
      final result = await Future.wait(list);

      return right(result.fold([], (map1, map2) => [...map1, ...map2]));
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, List<InboxConfigEntity>>> saveInboxConfig({required List<InboxConfigEntity> configs}) async {
    try {
      final list = [DatasourceType.supabase].map((d) => datasources[d]?.saveInboxConfig(inboxConfigs: configs)).whereType<Future<List<InboxConfigEntity>>>();
      await Future.wait(list);
      return right(configs);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, bool>> deleteInboxConfig({required List<String> configIds}) async {
    try {
      final list = [DatasourceType.supabase].map((d) => datasources[d]?.deleteInboxConfig(configIds: configIds)).whereType<Future<bool>>();
      await Future.wait(list);
      return right(true);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, String?>> fetchConversationSummary({
    required InboxEntity inbox,
    required List<InboxEntity> allInboxes,
    List<EventEntity>? eventEntities,
    List<TaskEntity>? taskEntities,
    String? model,
    String? apiKey,
    String? userId,
    String? taskId,
    String? eventId,
  }) async {
    try {
      // Step 2: Fetch from AI
      final datasource = _getDatasourceForModel(model);
      if (datasource == null) return right(null);

      String? summary;
      if (datasource is OpenAiInboxDatasource) {
        summary = await datasource.fetchConversationSummary(
          inbox: inbox,
          allInboxes: allInboxes,
          eventEntities: eventEntities,
          taskEntities: taskEntities,
          model: model,
          apiKey: apiKey,
        );
      } else if (datasource is GoogleAiInboxDatasource) {
        summary = await datasource.fetchConversationSummary(
          inbox: inbox,
          allInboxes: allInboxes,
          eventEntities: eventEntities,
          taskEntities: taskEntities,
          model: model,
          apiKey: apiKey,
        );
      } else if (datasource is AnthropicAiInboxDatasource) {
        summary = await datasource.fetchConversationSummary(
          inbox: inbox,
          allInboxes: allInboxes,
          eventEntities: eventEntities,
          taskEntities: taskEntities,
          model: model,
          apiKey: apiKey,
        );
      }

      // Step 3: Save AI summary to Supabase cache
      final supabaseDatasource = datasources[DatasourceType.supabase];
      if (summary != null && summary.isNotEmpty && userId != null && supabaseDatasource != null && (taskId != null || eventId != null)) {
        try {
          await supabaseDatasource.saveConversationSummary(userId: userId, taskId: taskId, eventId: eventId, summary: summary);
        } catch (e) {
          // If save fails, log but don't fail the request
        }
      }

      return right(summary);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, List<String>?>> extractSearchKeywords({
    required String taskTitle,
    String? taskDescription,
    String? taskProjectName,
    String? calendarName,
    String? apiKey,
    String? model,
  }) async {
    try {
      final datasource = _getDatasourceForModel(model);
      if (datasource == null) return right(null);

      if (datasource is OpenAiInboxDatasource) {
        final result = await datasource.extractSearchKeywords(
          taskTitle: taskTitle,
          taskDescription: taskDescription,
          taskProjectName: taskProjectName,
          calendarName: calendarName,
          apiKey: apiKey,
        );
        return right(result);
      } else if (datasource is GoogleAiInboxDatasource) {
        final result = await datasource.extractSearchKeywords(
          taskTitle: taskTitle,
          taskDescription: taskDescription,
          taskProjectName: taskProjectName,
          calendarName: calendarName,
          apiKey: apiKey,
        );
        return right(result);
      } else if (datasource is AnthropicAiInboxDatasource) {
        final result = await datasource.extractSearchKeywords(
          taskTitle: taskTitle,
          taskDescription: taskDescription,
          taskProjectName: taskProjectName,
          calendarName: calendarName,
          apiKey: apiKey,
        );
        return right(result);
      }
      return right(null);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, String?>> generateMailContentFromLinked({
    required LinkedMailEntity linkedMail,
    required String snippet,
    required String userRequest,
    required List<Map<String, dynamic>> conversationHistory,
    required String model,
    String? apiKey,
    String? userId, // 크레딧 체크용
  }) async {
    try {
      final datasource = _getDatasourceForModel(model);
      if (datasource == null) return right(null);

      String? result;

      if (datasource is OpenAiInboxDatasource) {
        result = await datasource.generateMailContentFromLinked(
          linkedMail: linkedMail,
          snippet: snippet,
          userRequest: userRequest,
          conversationHistory: conversationHistory,
          model: model,
          apiKey: apiKey,
        );
      } else if (datasource is GoogleAiInboxDatasource) {
        result = await datasource.generateMailContentFromLinked(
          linkedMail: linkedMail,
          snippet: snippet,
          userRequest: userRequest,
          conversationHistory: conversationHistory,
          model: model,
          apiKey: apiKey,
        );
      } else if (datasource is AnthropicAiInboxDatasource) {
        result = await datasource.generateMailContentFromLinked(
          linkedMail: linkedMail,
          snippet: snippet,
          userRequest: userRequest,
          conversationHistory: conversationHistory,
          model: model,
          apiKey: apiKey,
        );
      }

      // 크레딧 체크 및 차감 (String 반환 타입이므로 토큰 정보가 없으면 스킵)
      // TODO: String 반환 타입의 경우 토큰 정보를 별도로 받아야 함

      return right(result);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, Map<String, dynamic>?>> generateSuggestedReply({
    required LinkedMailEntity linkedMail,
    required String snippet,
    required String model,
    List<Map<String, dynamic>>? threadMessages,
    String? previousReply,
    String? userModificationRequest,
    List<Map<String, String>>? originalTo,
    List<Map<String, String>>? originalCc,
    List<Map<String, String>>? originalBcc,
    String? senderEmail,
    String? senderName,
    String? currentUserEmail,
    String? originalMailBody,
    String? actionType,
    String? apiKey,
    String? userId, // 크레딧 체크용
  }) async {
    try {
      final datasource = _getDatasourceForModel(model);
      if (datasource == null) return right(null);

      final usedUserApiKey = apiKey != null && apiKey.isNotEmpty;

      // AI 호출 전 크레딧 사전 체크
      if (!usedUserApiKey && userId != null) {
        int estimatedPromptTokens = snippet.length ~/ 3;
        if (originalMailBody != null) estimatedPromptTokens += originalMailBody.length ~/ 3;
        if (previousReply != null) estimatedPromptTokens += previousReply.length ~/ 3;
        if (threadMessages != null) {
          for (final msg in threadMessages) {
            final content = msg['content']?.toString() ?? '';
            estimatedPromptTokens += content.length ~/ 3;
          }
        }
        estimatedPromptTokens = estimatedPromptTokens < 100 ? 100 : estimatedPromptTokens;

        try {
          await _checkCreditsBeforeCall(userId: userId, model: model, estimatedPromptTokens: estimatedPromptTokens, estimatedCompletionTokens: 300, usedUserApiKey: usedUserApiKey);
        } catch (e) {
          if (e is Failure) {
            return left(e);
          }
        }
      }

      if (datasource is OpenAiInboxDatasource) {
        final result = await datasource.generateSuggestedReply(
          linkedMail: linkedMail,
          snippet: snippet,
          model: model,
          threadMessages: threadMessages,
          previousReply: previousReply,
          userModificationRequest: userModificationRequest,
          originalTo: originalTo,
          originalCc: originalCc,
          originalBcc: originalBcc,
          senderEmail: senderEmail,
          senderName: senderName,
          currentUserEmail: currentUserEmail,
          originalMailBody: originalMailBody,
          actionType: actionType,
          apiKey: apiKey,
        );
        return right(result);
      } else if (datasource is GoogleAiInboxDatasource) {
        final result = await datasource.generateSuggestedReply(
          linkedMail: linkedMail,
          snippet: snippet,
          model: model,
          threadMessages: threadMessages,
          previousReply: previousReply,
          userModificationRequest: userModificationRequest,
          originalTo: originalTo,
          originalCc: originalCc,
          originalBcc: originalBcc,
          senderEmail: senderEmail,
          senderName: senderName,
          currentUserEmail: currentUserEmail,
          originalMailBody: originalMailBody,
          actionType: actionType,
          apiKey: apiKey,
        );
        return right(result);
      } else if (datasource is AnthropicAiInboxDatasource) {
        final result = await datasource.generateSuggestedReply(
          linkedMail: linkedMail,
          snippet: snippet,
          model: model,
          threadMessages: threadMessages,
          previousReply: previousReply,
          userModificationRequest: userModificationRequest,
          originalTo: originalTo,
          originalCc: originalCc,
          originalBcc: originalBcc,
          senderEmail: senderEmail,
          senderName: senderName,
          currentUserEmail: currentUserEmail,
          originalMailBody: originalMailBody,
          actionType: actionType,
          apiKey: apiKey,
        );

        // 크레딧 체크 및 차감
        await _checkAndDeductCreditsIfNeeded(result: result, userId: userId, model: model, functionName: 'generateSuggestedReply', usedUserApiKey: usedUserApiKey);

        return right(result);
      }
      return right(null);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, Map<String, dynamic>?>> generateTaskFromInbox({
    required InboxEntity inbox,
    required String userRequest,
    required List<Map<String, dynamic>> conversationHistory,
    required List<Map<String, dynamic>> projects,
    required String model,
    TaskEntity? previousTaskEntity,
    EventEntity? previousEventEntity,
    String? apiKey,
    String? userId, // 크레딧 체크용
  }) async {
    try {
      final datasource = _getDatasourceForModel(model);
      if (datasource == null) return right(null);

      Map<String, dynamic>? result;
      final usedUserApiKey = apiKey != null && apiKey.isNotEmpty;

      // AI 호출 전 크레딧 사전 체크
      if (!usedUserApiKey && userId != null) {
        int estimatedPromptTokens = userRequest.length ~/ 3;
        estimatedPromptTokens += (inbox.description?.length ?? 0) ~/ 3;
        estimatedPromptTokens += (inbox.title.length) ~/ 3;
        for (final msg in conversationHistory) {
          final content = msg['content']?.toString() ?? '';
          estimatedPromptTokens += content.length ~/ 3;
        }
        estimatedPromptTokens = estimatedPromptTokens < 100 ? 100 : estimatedPromptTokens;

        try {
          await _checkCreditsBeforeCall(userId: userId, model: model, estimatedPromptTokens: estimatedPromptTokens, estimatedCompletionTokens: 400, usedUserApiKey: usedUserApiKey);
        } catch (e) {
          if (e is Failure) {
            return left(e);
          }
        }
      }

      if (datasource is OpenAiInboxDatasource) {
        result = await datasource.generateTaskFromInbox(
          inbox: inbox,
          userRequest: userRequest,
          conversationHistory: conversationHistory,
          projects: projects,
          model: model,
          previousTaskEntity: previousTaskEntity,
          previousEventEntity: previousEventEntity,
          apiKey: apiKey,
        );
      } else if (datasource is GoogleAiInboxDatasource) {
        result = await datasource.generateTaskFromInbox(
          inbox: inbox,
          userRequest: userRequest,
          conversationHistory: conversationHistory,
          projects: projects,
          model: model,
          previousTaskEntity: previousTaskEntity,
          previousEventEntity: previousEventEntity,
          apiKey: apiKey,
        );
      } else if (datasource is AnthropicAiInboxDatasource) {
        result = await datasource.generateTaskFromInbox(
          inbox: inbox,
          userRequest: userRequest,
          conversationHistory: conversationHistory,
          projects: projects,
          model: model,
          previousTaskEntity: previousTaskEntity,
          previousEventEntity: previousEventEntity,
          apiKey: apiKey,
        );
      }

      // 크레딧 체크 및 차감
      await _checkAndDeductCreditsIfNeeded(result: result, userId: userId, model: model, functionName: 'generateTaskFromInbox', usedUserApiKey: usedUserApiKey);

      return right(result);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, Map<String, dynamic>?>> generateSuggestedTask({
    required InboxEntity inbox,
    required List<Map<String, dynamic>> projects,
    required String model,
    String? apiKey,
    String? userId, // 크레딧 체크용
  }) async {
    try {
      final datasource = _getDatasourceForModel(model);
      if (datasource == null) return right(null);

      Map<String, dynamic>? result;
      final usedUserApiKey = apiKey != null && apiKey.isNotEmpty;

      // AI 호출 전 크레딧 사전 체크
      if (!usedUserApiKey && userId != null) {
        int estimatedPromptTokens = (inbox.description?.length ?? 0) ~/ 3;
        estimatedPromptTokens += inbox.title.length ~/ 3;
        estimatedPromptTokens = estimatedPromptTokens < 100 ? 100 : estimatedPromptTokens;

        try {
          await _checkCreditsBeforeCall(userId: userId, model: model, estimatedPromptTokens: estimatedPromptTokens, estimatedCompletionTokens: 300, usedUserApiKey: usedUserApiKey);
        } catch (e) {
          if (e is Failure) {
            return left(e);
          }
        }
      }

      if (datasource is OpenAiInboxDatasource) {
        result = await datasource.generateSuggestedTask(inbox: inbox, projects: projects, model: model, apiKey: apiKey);
      } else if (datasource is GoogleAiInboxDatasource) {
        result = await datasource.generateSuggestedTask(inbox: inbox, projects: projects, model: model, apiKey: apiKey);
      } else if (datasource is AnthropicAiInboxDatasource) {
        result = await datasource.generateSuggestedTask(inbox: inbox, projects: projects, model: model, apiKey: apiKey);
      }

      // 크레딧 체크 및 차감
      await _checkAndDeductCreditsIfNeeded(result: result, userId: userId, model: model, functionName: 'generateSuggestedTask', usedUserApiKey: usedUserApiKey);

      return right(result);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, Map<String, dynamic>?>> generateSuggestedEvent({
    required InboxEntity inbox,
    required List<Map<String, dynamic>> calendars,
    required String model,
    String? apiKey,
    String? userId, // 크레딧 체크용
  }) async {
    try {
      final datasource = _getDatasourceForModel(model);
      if (datasource == null) return right(null);

      // Filter to only editable calendars
      final editableCalendars = calendars.where((c) => c['modifiable'] == true).toList();

      Map<String, dynamic>? result;
      final usedUserApiKey = apiKey != null && apiKey.isNotEmpty;

      // AI 호출 전 크레딧 사전 체크
      if (!usedUserApiKey && userId != null) {
        int estimatedPromptTokens = (inbox.description?.length ?? 0) ~/ 3;
        estimatedPromptTokens += inbox.title.length ~/ 3;
        estimatedPromptTokens = estimatedPromptTokens < 100 ? 100 : estimatedPromptTokens;

        try {
          await _checkCreditsBeforeCall(userId: userId, model: model, estimatedPromptTokens: estimatedPromptTokens, estimatedCompletionTokens: 300, usedUserApiKey: usedUserApiKey);
        } catch (e) {
          if (e is Failure) {
            return left(e);
          }
        }
      }

      if (datasource is OpenAiInboxDatasource) {
        result = await datasource.generateSuggestedEvent(inbox: inbox, calendars: editableCalendars, model: model, apiKey: apiKey);
      } else if (datasource is GoogleAiInboxDatasource) {
        result = await datasource.generateSuggestedEvent(inbox: inbox, calendars: editableCalendars, model: model, apiKey: apiKey);
      } else if (datasource is AnthropicAiInboxDatasource) {
        result = await datasource.generateSuggestedEvent(inbox: inbox, calendars: editableCalendars, model: model, apiKey: apiKey);
      }

      // 크레딧 체크 및 차감
      await _checkAndDeductCreditsIfNeeded(result: result, userId: userId, model: model, functionName: 'generateSuggestedEvent', usedUserApiKey: usedUserApiKey);

      return right(result);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, Map<String, dynamic>?>> generateEventFromInbox({
    required InboxEntity inbox,
    required String userRequest,
    required List<Map<String, dynamic>> conversationHistory,
    required List<Map<String, dynamic>> calendars,
    required String model,
    EventEntity? previousEventEntity,
    TaskEntity? previousTaskEntity,
    String? apiKey,
    String? userId, // 크레딧 체크용
  }) async {
    try {
      final datasource = _getDatasourceForModel(model);
      if (datasource == null) return right(null);

      // Filter to only editable calendars
      final editableCalendars = calendars.where((c) => c['modifiable'] == true).toList();

      Map<String, dynamic>? result;
      final usedUserApiKey = apiKey != null && apiKey.isNotEmpty;

      // AI 호출 전 크레딧 사전 체크
      if (!usedUserApiKey && userId != null) {
        int estimatedPromptTokens = userRequest.length ~/ 3;
        estimatedPromptTokens += (inbox.description?.length ?? 0) ~/ 3;
        estimatedPromptTokens += inbox.title.length ~/ 3;
        for (final msg in conversationHistory) {
          final content = msg['content']?.toString() ?? '';
          estimatedPromptTokens += content.length ~/ 3;
        }
        estimatedPromptTokens = estimatedPromptTokens < 100 ? 100 : estimatedPromptTokens;

        try {
          await _checkCreditsBeforeCall(userId: userId, model: model, estimatedPromptTokens: estimatedPromptTokens, estimatedCompletionTokens: 400, usedUserApiKey: usedUserApiKey);
        } catch (e) {
          if (e is Failure) {
            return left(e);
          }
        }
      }

      if (datasource is OpenAiInboxDatasource) {
        result = await datasource.generateEventFromInbox(
          inbox: inbox,
          userRequest: userRequest,
          conversationHistory: conversationHistory,
          calendars: editableCalendars,
          model: model,
          previousEventEntity: previousEventEntity,
          previousTaskEntity: previousTaskEntity,
          apiKey: apiKey,
        );
      } else if (datasource is GoogleAiInboxDatasource) {
        result = await datasource.generateEventFromInbox(
          inbox: inbox,
          userRequest: userRequest,
          conversationHistory: conversationHistory,
          calendars: editableCalendars,
          model: model,
          previousEventEntity: previousEventEntity,
          previousTaskEntity: previousTaskEntity,
          apiKey: apiKey,
        );
      } else if (datasource is AnthropicAiInboxDatasource) {
        result = await datasource.generateEventFromInbox(
          inbox: inbox,
          userRequest: userRequest,
          conversationHistory: conversationHistory,
          calendars: editableCalendars,
          model: model,
          previousEventEntity: previousEventEntity,
          previousTaskEntity: previousTaskEntity,
          apiKey: apiKey,
        );
      }

      // 크레딧 체크 및 차감
      await _checkAndDeductCreditsIfNeeded(result: result, userId: userId, model: model, functionName: 'generateEventFromInbox', usedUserApiKey: usedUserApiKey);

      return right(result);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, Map<String, dynamic>?>> generateGeneralChat({
    required String userMessage,
    required List<Map<String, dynamic>> conversationHistory,
    String? projectContext,
    List<Map<String, dynamic>>? projects,
    String? taggedContext,
    String? channelContext,
    String? inboxContext,
    required String model,
    String? apiKey,
    String? userId, // 크레딧 체크용
    String? systemPrompt,
    bool includeTools = true, // OpenAI에서 tools 포함 여부 (기본값: true)
  }) async {
    try {
      final datasource = _getDatasourceForModel(model);
      if (datasource == null) return right(null);

      final usedUserApiKey = apiKey != null && apiKey.isNotEmpty;

      // AI 호출 전 크레딧 사전 체크
      if (!usedUserApiKey && userId != null) {
        // 예상 토큰 수 계산 (대략적으로 문자 수 / 3)
        final estimatedPromptTokens = _estimatePromptTokens(
          userMessage: userMessage,
          conversationHistory: conversationHistory,
          projectContext: projectContext,
          taggedContext: taggedContext,
          channelContext: channelContext,
          inboxContext: inboxContext,
        );

        try {
          await _checkCreditsBeforeCall(userId: userId, model: model, estimatedPromptTokens: estimatedPromptTokens, estimatedCompletionTokens: 500, usedUserApiKey: usedUserApiKey);
        } catch (e) {
          // 크레딧 부족 예외인 경우 그대로 전달
          if (e is Failure) {
            return left(e);
          }
        }
      }

      Map<String, dynamic>? result;
      if (datasource is OpenAiInboxDatasource) {
        result = await datasource.generateGeneralChat(
          userMessage: userMessage,
          conversationHistory: conversationHistory,
          projectContext: projectContext,
          projects: projects,
          taggedContext: taggedContext,
          channelContext: channelContext,
          inboxContext: inboxContext,
          model: model,
          apiKey: apiKey,
          systemPrompt: systemPrompt,
          includeTools: includeTools,
        );
      } else if (datasource is GoogleAiInboxDatasource) {
        result = await datasource.generateGeneralChat(
          userMessage: userMessage,
          conversationHistory: conversationHistory,
          projectContext: projectContext,
          projects: projects,
          taggedContext: taggedContext,
          channelContext: channelContext,
          inboxContext: inboxContext,
          model: model,
          apiKey: apiKey,
          systemPrompt: systemPrompt,
          includeTools: includeTools,
        );
      } else if (datasource is AnthropicAiInboxDatasource) {
        result = await datasource.generateGeneralChat(
          userMessage: userMessage,
          conversationHistory: conversationHistory,
          projectContext: projectContext,
          projects: projects,
          taggedContext: taggedContext,
          channelContext: channelContext,
          inboxContext: inboxContext,
          model: model,
          apiKey: apiKey,
          systemPrompt: systemPrompt,
          includeTools: includeTools,
        );
      }

      // 크레딧 체크 및 차감 (사용자 API 키 사용 시 스킵)
      await _checkAndDeductCreditsIfNeeded(result: result, userId: userId, model: model, functionName: 'generateGeneralChat', usedUserApiKey: usedUserApiKey);

      return right(result);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, Map<String, dynamic>?>> generateSuggestedSendContent({
    required String userRequest,
    required List<Map<String, dynamic>> conversationHistory,
    required List<Map<String, String>> toRecipients,
    required List<Map<String, String>> ccRecipients,
    required List<Map<String, String>> bccRecipients,
    String? previousSubject,
    String? previousBody,
    required String model,
    String? apiKey,
    String? userId, // 크레딧 체크용
  }) async {
    try {
      final datasource = _getDatasourceForModel(model);
      if (datasource == null) return right(null);

      Map<String, dynamic>? result;
      final usedUserApiKey = apiKey != null && apiKey.isNotEmpty;

      // AI 호출 전 크레딧 사전 체크
      if (!usedUserApiKey && userId != null) {
        int estimatedPromptTokens = userRequest.length ~/ 3;
        if (previousSubject != null) estimatedPromptTokens += previousSubject.length ~/ 3;
        if (previousBody != null) estimatedPromptTokens += previousBody.length ~/ 3;
        for (final msg in conversationHistory) {
          final content = msg['content']?.toString() ?? '';
          estimatedPromptTokens += content.length ~/ 3;
        }
        estimatedPromptTokens = estimatedPromptTokens < 100 ? 100 : estimatedPromptTokens;

        try {
          await _checkCreditsBeforeCall(userId: userId, model: model, estimatedPromptTokens: estimatedPromptTokens, estimatedCompletionTokens: 300, usedUserApiKey: usedUserApiKey);
        } catch (e) {
          if (e is Failure) {
            return left(e);
          }
        }
      }

      if (datasource is OpenAiInboxDatasource) {
        result = await datasource.generateSuggestedSendContent(
          userRequest: userRequest,
          conversationHistory: conversationHistory,
          toRecipients: toRecipients,
          ccRecipients: ccRecipients,
          bccRecipients: bccRecipients,
          previousSubject: previousSubject,
          previousBody: previousBody,
          model: model,
          apiKey: apiKey,
        );
      } else if (datasource is GoogleAiInboxDatasource) {
        result = await datasource.generateSuggestedSendContent(
          userRequest: userRequest,
          conversationHistory: conversationHistory,
          toRecipients: toRecipients,
          ccRecipients: ccRecipients,
          bccRecipients: bccRecipients,
          previousSubject: previousSubject,
          previousBody: previousBody,
          model: model,
          apiKey: apiKey,
        );
      } else if (datasource is AnthropicAiInboxDatasource) {
        result = await datasource.generateSuggestedSendContent(
          userRequest: userRequest,
          conversationHistory: conversationHistory,
          toRecipients: toRecipients,
          ccRecipients: ccRecipients,
          bccRecipients: bccRecipients,
          previousSubject: previousSubject,
          previousBody: previousBody,
          model: model,
          apiKey: apiKey,
        );
      }

      // 크레딧 체크 및 차감
      await _checkAndDeductCreditsIfNeeded(result: result, userId: userId, model: model, functionName: 'generateSuggestedSendContent', usedUserApiKey: usedUserApiKey);

      return right(result);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  /// 예상 입력 토큰 수 계산
  ///
  /// 대략적으로 문자 수를 4로 나눈 값 (영어 기준)
  /// 한국어/중국어 등은 더 많은 토큰이 필요하지만 보수적으로 계산
  int _estimatePromptTokens({
    required String userMessage,
    required List<Map<String, dynamic>> conversationHistory,
    String? projectContext,
    String? taggedContext,
    String? channelContext,
    String? inboxContext,
  }) {
    int totalChars = userMessage.length;

    // 대화 기록 길이 추가
    for (final message in conversationHistory) {
      final content = message['content']?.toString() ?? '';
      totalChars += content.length;
    }

    // 컨텍스트 추가
    if (projectContext != null) totalChars += projectContext.length;
    if (taggedContext != null) totalChars += taggedContext.length;
    if (channelContext != null) totalChars += channelContext.length;
    if (inboxContext != null) totalChars += inboxContext.length;

    // 대략적으로 문자 수 / 4 (영어 기준)
    // 한국어/중국어 등은 더 많은 토큰이 필요하므로 여유있게 계산
    final estimatedTokens = (totalChars / 3).ceil(); // 3으로 나누어 더 보수적으로 계산

    // 최소 토큰 수 보장
    return estimatedTokens < 100 ? 100 : estimatedTokens;
  }
}
