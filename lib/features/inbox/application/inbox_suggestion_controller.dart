import 'dart:async';
import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/domain/entities/ai_provider_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/application/inbox_list_controller.dart';
import 'package:Visir/features/inbox/domain/entities/agent_model_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_suggestion_entity.dart';
import 'package:Visir/features/inbox/infrastructure/repositories/inbox_repository.dart';
import 'package:Visir/features/inbox/providers.dart';
import 'package:Visir/features/inbox/utils/mock_data_helper.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inbox_suggestion_controller.g.dart';

@riverpod
class InboxSuggestionController extends _$InboxSuggestionController {
  late InboxSuggestionControllerInternal _controller;
  static String stringKey = '${TabType.home.name}:suggestions';

  @override
  InboxSuggestionFetchListEntity? build() {
    final isSearch = ref.watch(inboxListIsSearchProvider);
    final date = ref.watch(inboxListDateProvider);
    final isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
    final provider = inboxSuggestionControllerInternalProvider(isSearch: isSearch, year: date.year, month: date.month, day: date.day, isSignedIn: isSignedIn);

    _controller = ref.watch(provider.notifier);
    ref.listen(provider, (prev, next) {
      updateState(next.value);
    });

    return ref.read(provider).value;
  }

  Future<void> setInboxSuggestions(List<InboxEntity> inboxes, int sequence, DateTime? date) {
    return _controller.setInboxSuggestions(inboxes, sequence, date, DateTime.now());
  }

  Timer? timer;
  void updateState(InboxSuggestionFetchListEntity? data) {
    if (timer == null) state = data;
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: kControllerDebouncMillisecond), () {
      state = data;
      timer = null;
    });
  }
}

@riverpod
class InboxSuggestionControllerInternal extends _$InboxSuggestionControllerInternal {
  late InboxRepository _inboxRepository;

  List<InboxEntity> _prevInboxes = [];

  @override
  Future<InboxSuggestionFetchListEntity?> build({required bool isSearch, required int year, required int month, required int day, required bool isSignedIn}) async {
    _inboxRepository = ref.watch(inboxRepositoryProvider);

    if (isSearch) return null;

    final provider = inboxListControllerInternalProvider(isSearch: isSearch, year: year, month: month, day: day, isSignedIn: isSignedIn);

    // Mock data 모드에서는 inboxes가 로드된 후 mock suggestion 반환
    final shouldUseMockData = ref.watch(shouldUseMockDataProvider);
    if (shouldUseMockData) {
      // Project list가 로드될 때마다 suggestion 재생성
      ref.listen(projectListControllerInternalProvider(isSignedIn: isSignedIn), (prev, next) {
        final projects = next.value ?? [];
        final currentInboxes = ref.read(provider).value?.inboxes ?? [];
        if (currentInboxes.isNotEmpty && projects.isNotEmpty) {
          final mockSuggestions = MockDataHelper.getMockSuggestions(currentInboxes, projects: projects);
          state = AsyncData(InboxSuggestionFetchListEntity(suggestions: mockSuggestions, sequence: ref.read(provider).value?.sequence ?? 0));
        }
      });

      ref.listen(provider, (prev, next) {
        if (next.value?.inboxes != null && next.value!.inboxes.isNotEmpty == true) {
          final projects = ref.read(projectListControllerInternalProvider(isSignedIn: isSignedIn)).value ?? [];
          if (projects.isNotEmpty) {
            final mockSuggestions = MockDataHelper.getMockSuggestions(next.value!.inboxes, projects: projects);
            state = AsyncData(InboxSuggestionFetchListEntity(suggestions: mockSuggestions, sequence: next.value!.sequence));
          }
        }
      });
      // 초기값이 있으면 바로 반환
      final initialInboxes = ref.read(provider).value?.inboxes ?? [];
      final initialProjects = ref.read(projectListControllerInternalProvider(isSignedIn: isSignedIn)).value ?? [];
      if (initialInboxes.isNotEmpty && initialProjects.isNotEmpty) {
        final mockSuggestions = MockDataHelper.getMockSuggestions(initialInboxes, projects: initialProjects);
        return InboxSuggestionFetchListEntity(suggestions: mockSuggestions, sequence: ref.read(provider).value?.sequence ?? 0);
      }
      return InboxSuggestionFetchListEntity(suggestions: [], sequence: 0);
    }

    await persist(
      ref.watch(storageProvider.future),
      key: '${InboxSuggestionController.stringKey}:${isSignedIn}:${isSearch ? 'search' : '${year}_${month}_${day}'}',
      encode: (InboxSuggestionFetchListEntity? state) => state == null ? '' : jsonEncode(state.toJson(local: true)),
      decode: (String encoded) {
        if (isSearch) return null;
        final trimmed = encoded.trim();
        if (trimmed.isEmpty || trimmed == 'null') {
          return InboxSuggestionFetchListEntity(suggestions: [], sequence: 0);
        }
        return InboxSuggestionFetchListEntity.fromJson(jsonDecode(trimmed) as Map<String, dynamic>, local: true); // 로컬 저장소는 평문
      },
      options: Utils.storageOptions,
    ).future;

    ref.listen(provider.select((e) => e.value?.sequence ?? 0), (previous, next) {
      final inboxes = ref.read(provider).value?.inboxes ?? [];
      _prevInboxes = [..._prevInboxes, ...inboxes].unique((e) => e.id).toList();
    });

    ref.listen(provider, (prev, next) {
      if (next.value?.inboxes != null && next.value!.inboxes.isNotEmpty) {
        final inboxes = next.value!.inboxes;
        _prevInboxes = [..._prevInboxes, ...inboxes].unique((e) => e.id).toList();
        final projects = ref.read(projectListControllerInternalProvider(isSignedIn: isSignedIn)).value ?? [];
        if (projects.isNotEmpty) {
          setInboxSuggestions(_prevInboxes, next.value!.sequence ?? 0, DateTime(year, month, day), DateTime.now());
        }
      }
    });

    ref.listen(projectListControllerInternalProvider(isSignedIn: isSignedIn), (prev, next) {
      final projects = next.value ?? [];
      if (projects.isNotEmpty && _prevInboxes.isNotEmpty) {
        setInboxSuggestions(_prevInboxes, state.value?.sequence ?? 0, DateTime(year, month, day), DateTime.now());
      }
    });

    SchedulerBinding.instance.addPostFrameCallback((_) {
      final inboxes = ref.read(provider).value?.inboxes ?? [];
      if (inboxes.isNotEmpty) {
        _prevInboxes = [..._prevInboxes, ...inboxes].unique((e) => e.id).toList();
        final projects = ref.read(projectListControllerInternalProvider(isSignedIn: isSignedIn)).value ?? [];
        if (projects.isNotEmpty) {
          setInboxSuggestions(_prevInboxes, -1, DateTime(year, month, day), DateTime.now());
        }
      }
    });

    return state.value ?? InboxSuggestionFetchListEntity(suggestions: [], sequence: 0);
  }

  DateTime? _triggeredAt;
  Future<void> _processing = Future.value();

  Future<void> setInboxSuggestions(List<InboxEntity> inboxes, int sequence, DateTime? date, DateTime triggeredAt) async {
    final previous = _processing;
    final completer = Completer<void>();
    _processing = completer.future;

    try {
      await previous;
    } catch (_) {}

    try {
      final r = state.value;
      final _suggestions = r?.suggestions ?? <InboxSuggestionEntity>[];
      final restInboxes = inboxes.where((e) => !_suggestions.any((s) => s.id == e.id)).toList();
      if (restInboxes.isEmpty) return;

      final projects = ref.read(projectListControllerInternalProvider(isSignedIn: isSignedIn)).value ?? [];
      if (projects.isEmpty) return;

      _triggeredAt = triggeredAt;
      ref.read(loadingStatusProvider.notifier).update(InboxSuggestionController.stringKey, LoadingState.loading);

      // Merge duplicate messages or multiple inbox items for the same chat
      final mergeResult = _mergeDuplicateInboxes(restInboxes);
      final mergedInboxes = mergeResult['inboxes'] as List<InboxEntity>;
      final mergedIdsMap = mergeResult['mergedIds'] as Map<String, List<String>>;

      // Use mergedInboxes instead of restInboxes to avoid duplicate requests for the same message
      // Check DefaultAgentAiProvider and AiApiKeys to determine which model and API key to use
      final defaultProvider = ref.read(defaultAgentAiProviderProvider);
      final apiKeys = ref.read(aiApiKeysProvider);

      String? model;
      String? apiKey;

      // 기본적으로 OpenAI의 gpt-4.1-mini 사용
      if (defaultProvider == null) {
        model = AgentModel.gpt41Mini.modelName;
        apiKey = null; // 환경 변수 API 키 사용
      } else {
        // DefaultAgentAiProvider가 설정되어 있고 API 키가 있으면 해당 provider의 기본 모델 사용
        final providerApiKey = apiKeys[defaultProvider.key];
        if (providerApiKey != null && providerApiKey.isNotEmpty) {
          switch (defaultProvider) {
            case AiProvider.openai:
              model = AgentModel.gpt41Mini.modelName;
              break;
            case AiProvider.google:
              model = AgentModel.gemini25Flash.modelName;
              break;
            case AiProvider.anthropic:
              model = AgentModel.claudeHaiku45.modelName;
              break;
          }
          apiKey = providerApiKey;
        } else {
          // API 키가 없으면 기본 OpenAI 사용
          model = AgentModel.gpt41Mini.modelName;
          apiKey = null;
        }
      }

      final userId = ref.read(authControllerProvider.select((v) => v.requireValue.id));

      await _inboxRepository
          .fetchInboxSuggestions(inboxes: mergedInboxes, projects: projects, model: model, apiKey: apiKey, userId: userId)
          .then((restSuggestions) {
            if (_triggeredAt == triggeredAt) ref.read(loadingStatusProvider.notifier).update(InboxSuggestionController.stringKey, LoadingState.success);
            return restSuggestions.fold((l) {}, (r2) {
              // Merge suggestions for inboxes that were merged
              final mergedSuggestions = <InboxSuggestionEntity>[];
              final processedIds = <String>{};

              // First pass: merge suggestions based on mergedIdsMap
              for (final suggestion in r2) {
                if (processedIds.contains(suggestion.id)) continue;

                final mergedIds = mergedIdsMap[suggestion.id];
                if (mergedIds != null && mergedIds.length > 1) {
                  // Create a merged suggestion with all merged inbox ids
                  final mergedSuggestion = suggestion.copyWith(
                    id: mergedIds.join(','), // Store all merged ids comma-separated
                  );
                  mergedSuggestions.add(mergedSuggestion);
                  processedIds.addAll(mergedIds);
                } else {
                  mergedSuggestions.add(suggestion);
                  processedIds.add(suggestion.id);
                }
              }

              // Second pass: merge suggestions that have overlapping IDs
              // This handles cases where merged inbox IDs are split across batches
              // Combine existing suggestions and new suggestions, then merge overlapping ones
              final allSuggestions = <InboxSuggestionEntity>[..._suggestions, ...mergedSuggestions];
              final finalSuggestions = <InboxSuggestionEntity>[];
              final processedSuggestions = <InboxSuggestionEntity>{};

              // Group suggestions by overlapping IDs
              while (allSuggestions.isNotEmpty) {
                final currentSuggestion = allSuggestions.removeAt(0);
                if (processedSuggestions.contains(currentSuggestion)) continue;

                final currentIds = currentSuggestion.id.split(',').toSet();
                final group = <InboxSuggestionEntity>[currentSuggestion];
                processedSuggestions.add(currentSuggestion);

                // Find all suggestions that overlap with this group
                bool foundOverlap;
                do {
                  foundOverlap = false;
                  for (int i = allSuggestions.length - 1; i >= 0; i--) {
                    final otherSuggestion = allSuggestions[i];
                    final otherIds = otherSuggestion.id.split(',').toSet();

                    // Check if this suggestion overlaps with any in the group
                    if (currentIds.intersection(otherIds).isNotEmpty) {
                      group.add(otherSuggestion);
                      currentIds.addAll(otherIds);
                      processedSuggestions.add(otherSuggestion);
                      allSuggestions.removeAt(i);
                      foundOverlap = true;
                    }
                  }
                } while (foundOverlap);

                // Merge all suggestions in the group
                if (group.length > 1) {
                  final baseSuggestion = group.first;
                  final allMergedIdsList = currentIds.toList()..sort();
                  final mergedSuggestion = baseSuggestion.copyWith(id: allMergedIdsList.join(','));
                  finalSuggestions.add(mergedSuggestion);
                } else {
                  finalSuggestions.add(currentSuggestion);
                }
              }

              state = AsyncData(InboxSuggestionFetchListEntity(suggestions: finalSuggestions, sequence: sequence));
            });
          })
          .catchError((e) {
            if (_triggeredAt == triggeredAt) ref.read(loadingStatusProvider.notifier).update(InboxSuggestionController.stringKey, LoadingState.error);
          })
          .whenComplete(() {
            completer.complete();
          });
    } catch (e) {
      if (_triggeredAt == triggeredAt) ref.read(loadingStatusProvider.notifier).update(InboxSuggestionController.stringKey, LoadingState.error);
      completer.complete();
    }
  }

  // Merge duplicate inbox items (same messageId or same chat message)
  // Returns a map with 'inboxes' and 'mergedIds'
  Map<String, dynamic> _mergeDuplicateInboxes(List<InboxEntity> inboxes) {
    final mergedMap = <String, InboxEntity>{};
    final mergedIdsMap = <String, List<String>>{}; // Map from merged inbox id to list of original inbox ids

    for (final inbox in inboxes) {
      // For mail: group by messageId first (same message = duplicate), then by threadId
      if (inbox.linkedMail != null) {
        // First check if same messageId exists (duplicate)
        final messageKey = 'mail:${inbox.linkedMail!.hostMail}:${inbox.linkedMail!.messageId}';

        if (!mergedMap.containsKey(messageKey)) {
          mergedMap[messageKey] = inbox;
          mergedIdsMap[inbox.id] = [inbox.id];
        } else {
          // Merge: keep the one with the latest datetime
          final existing = mergedMap[messageKey]!;
          if (inbox.inboxDatetime.isAfter(existing.inboxDatetime)) {
            mergedIdsMap[existing.id] = [...mergedIdsMap[existing.id]!, inbox.id];
            mergedMap[messageKey] = inbox.copyWith(
              id: existing.id, // Keep the original id for suggestion matching
            );
          } else {
            mergedIdsMap[existing.id] = [...mergedIdsMap[existing.id]!, inbox.id];
          }
        }
      }
      // For chat: group by messageId (same message) - multiple inbox items for same message should be merged
      else if (inbox.linkedMessage != null) {
        final linkedMsg = inbox.linkedMessage!;

        // Group by messageId if it's the same message
        final messageKey = 'chat:${linkedMsg.teamId}:${linkedMsg.channelId}:${linkedMsg.messageId}';

        if (!mergedMap.containsKey(messageKey)) {
          mergedMap[messageKey] = inbox;
          mergedIdsMap[inbox.id] = [inbox.id];
        } else {
          // Merge: keep the one with the latest datetime
          final existing = mergedMap[messageKey]!;
          if (inbox.inboxDatetime.isAfter(existing.inboxDatetime)) {
            mergedIdsMap[existing.id] = [...mergedIdsMap[existing.id]!, inbox.id];
            mergedMap[messageKey] = inbox.copyWith(
              id: existing.id, // Keep the original id for suggestion matching
            );
          } else {
            mergedIdsMap[existing.id] = [...mergedIdsMap[existing.id]!, inbox.id];
          }
        }
      } else {
        // No linked mail or message, keep as is
        mergedMap[inbox.id] = inbox;
        mergedIdsMap[inbox.id] = [inbox.id];
      }
    }

    return {'inboxes': mergedMap.values.toList(), 'mergedIds': mergedIdsMap};
  }
}
