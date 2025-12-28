import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/inbox/domain/entities/agent_chat_history_entity.dart';
import 'package:Visir/features/inbox/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Visir/features/common/provider.dart';

part 'agent_chat_history_controller.g.dart';

class AgentChatHistoryState {
  final List<AgentChatHistoryEntity> histories;
  final bool isLoading;
  final bool hasMore;
  final int currentOffset;

  AgentChatHistoryState({
    required this.histories,
    this.isLoading = false,
    this.hasMore = true,
    this.currentOffset = 0,
  });

  AgentChatHistoryState copyWith({
    List<AgentChatHistoryEntity>? histories,
    bool? isLoading,
    bool? hasMore,
    int? currentOffset,
  }) {
    return AgentChatHistoryState(
      histories: histories ?? this.histories,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentOffset: currentOffset ?? this.currentOffset,
    );
  }
}

@riverpod
class AgentChatHistoryController extends _$AgentChatHistoryController {
  static const int _pageSize = 20;
  final Map<String, AgentChatHistoryState> _cache = {}; // 필터/검색/정렬 조합별 캐시

  @override
  Future<List<AgentChatHistoryEntity>> build() async {
    final me = ref.watch(authControllerProvider).value;
    if (me == null) return [];

    if (ref.watch(shouldUseMockDataProvider)) return [];

    // 필터/검색/정렬 상태 watch
    final filterProjectId = ref.watch(agentChatHistoryFilterProvider);
    final searchQuery = ref.watch(agentChatHistorySearchQueryProvider);
    final sortType = ref.watch(agentChatHistorySortProvider);

    // 캐시 키 생성
    final cacheKey = '${filterProjectId ?? 'all'}_${searchQuery}_${sortType.name}';
    
    // 캐시에서 초기 상태 가져오기
    final cachedState = _cache[cacheKey];
    if (cachedState != null && cachedState.histories.isNotEmpty) {
      return cachedState.histories;
    }

    // 초기 로드 (첫 페이지만)
    final repository = ref.watch(agentChatHistoryRepositoryProvider);
    
    // 소팅 타입에 따라 서버에서 소팅할지 결정
    String? sortBy;
    bool? ascending;
    bool needsClientSort = false;
    
    switch (sortType) {
      case AgentChatHistorySortType.updatedAtDesc:
        sortBy = 'updated_at';
        ascending = false;
        break;
      case AgentChatHistorySortType.updatedAtAsc:
        sortBy = 'updated_at';
        ascending = true;
        break;
      case AgentChatHistorySortType.messageCountDesc:
      case AgentChatHistorySortType.messageCountAsc:
        // 메시지 수로 소팅하는 것은 서버에서 할 수 없으므로 클라이언트에서 처리
        needsClientSort = true;
        // 기본값으로 updated_at desc 사용
        sortBy = 'updated_at';
        ascending = false;
        break;
    }
    
    final supabaseHistories = await repository.getChatHistoryListByProject(
      userId: me.id,
      projectId: filterProjectId,
      offset: 0,
      limit: _pageSize,
      sortBy: sortBy,
      ascending: ascending,
    );

    // 검색 필터링
    List<AgentChatHistoryEntity> filteredHistories = supabaseHistories;
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filteredHistories = supabaseHistories.where((history) {
        if (history.conversationSummary != null && history.conversationSummary!.toLowerCase().contains(query)) {
          return true;
        }
        for (final message in history.messages) {
          if (message.content.toLowerCase().contains(query)) {
            return true;
          }
        }
        return false;
      }).toList();
    }

    // 메시지 수로 소팅하는 경우 클라이언트에서 정렬
    if (needsClientSort) {
      switch (sortType) {
        case AgentChatHistorySortType.messageCountDesc:
          filteredHistories.sort((a, b) => b.messages.length.compareTo(a.messages.length));
          break;
        case AgentChatHistorySortType.messageCountAsc:
          filteredHistories.sort((a, b) => a.messages.length.compareTo(b.messages.length));
          break;
        default:
          break;
      }
    }

    // 캐시 업데이트
    _cache[cacheKey] = AgentChatHistoryState(
      histories: filteredHistories,
      isLoading: false,
      hasMore: filteredHistories.length >= _pageSize,
      currentOffset: filteredHistories.length,
    );

    return filteredHistories;
  }

  /// 더 많은 히스토리를 로드합니다.
  Future<void> loadMore() async {
    final me = ref.read(authControllerProvider).value;
    if (me == null) return;

    final filterProjectId = ref.read(agentChatHistoryFilterProvider);
    final searchQuery = ref.read(agentChatHistorySearchQueryProvider);
    final sortType = ref.read(agentChatHistorySortProvider);
    final cacheKey = '${filterProjectId ?? 'all'}_${searchQuery}_${sortType.name}';
    
    final cachedState = _cache[cacheKey];
    if (cachedState == null || cachedState.isLoading || !cachedState.hasMore) return;

    _cache[cacheKey] = cachedState.copyWith(isLoading: true);

    try {
      final repository = ref.read(agentChatHistoryRepositoryProvider);
      
      // 소팅 타입에 따라 서버에서 소팅할지 결정
      String? sortBy;
      bool? ascending;
      bool needsClientSort = false;
      
      switch (sortType) {
        case AgentChatHistorySortType.updatedAtDesc:
          sortBy = 'updated_at';
          ascending = false;
          break;
        case AgentChatHistorySortType.updatedAtAsc:
          sortBy = 'updated_at';
          ascending = true;
          break;
        case AgentChatHistorySortType.messageCountDesc:
        case AgentChatHistorySortType.messageCountAsc:
          // 메시지 수로 소팅하는 것은 서버에서 할 수 없으므로 클라이언트에서 처리
          needsClientSort = true;
          // 기본값으로 updated_at desc 사용
          sortBy = 'updated_at';
          ascending = false;
          break;
      }
      
      final supabaseHistories = await repository.getChatHistoryListByProject(
        userId: me.id,
        projectId: filterProjectId,
        offset: cachedState.currentOffset,
        limit: _pageSize,
        sortBy: sortBy,
        ascending: ascending,
      );

      // 검색 필터링
      List<AgentChatHistoryEntity> filteredHistories = supabaseHistories;
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        filteredHistories = supabaseHistories.where((history) {
          if (history.conversationSummary != null && history.conversationSummary!.toLowerCase().contains(query)) {
            return true;
          }
          for (final message in history.messages) {
            if (message.content.toLowerCase().contains(query)) {
              return true;
            }
          }
          return false;
        }).toList();
      }

      // 메시지 수로 소팅하는 경우 클라이언트에서 정렬
      if (needsClientSort) {
        switch (sortType) {
          case AgentChatHistorySortType.messageCountDesc:
            filteredHistories.sort((a, b) => b.messages.length.compareTo(a.messages.length));
            break;
          case AgentChatHistorySortType.messageCountAsc:
            filteredHistories.sort((a, b) => a.messages.length.compareTo(b.messages.length));
            break;
          default:
            break;
        }
      }

      final newHistories = [...cachedState.histories, ...filteredHistories];
      final hasMore = filteredHistories.length >= _pageSize;

      _cache[cacheKey] = AgentChatHistoryState(
        histories: newHistories,
        isLoading: false,
        hasMore: hasMore,
        currentOffset: cachedState.currentOffset + filteredHistories.length,
      );

      // state 업데이트
      state = AsyncValue.data(newHistories);
    } catch (e) {
      _cache[cacheKey] = cachedState.copyWith(isLoading: false);
    }
  }


  /// 특정 세션의 히스토리를 가져옵니다.
  Future<AgentChatHistoryEntity?> getHistoryById(String sessionId) async {
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
      final repository = ref.read(agentChatHistoryRepositoryProvider);
      return await repository.getChatHistoryById(userId: me.id, sessionId: sessionId);
    } catch (e) {
      return null;
    }
  }

  /// 히스토리를 새로고침합니다.
  Future<void> refresh() async {
    _cache.clear();
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}

