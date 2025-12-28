import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/infrastructure/datasources/supabase_ai_usage_log_datasource.dart';
import 'package:Visir/features/auth/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/inbox/infrastructure/datasources/anthropic_ai_inbox_datasource.dart';
import 'package:Visir/features/inbox/infrastructure/datasources/google_ai_inbox_datasource.dart';
import 'package:Visir/features/inbox/infrastructure/datasources/openai_inbox_datasource.dart';
import 'package:Visir/features/inbox/infrastructure/datasources/supabase_inbox_datasource.dart';
import 'package:Visir/features/inbox/infrastructure/datasources/supabase_agent_chat_history_datasource.dart';
import 'package:Visir/features/inbox/infrastructure/repositories/inbox_repository.dart';
import 'package:Visir/features/inbox/infrastructure/repositories/agent_chat_history_repository.dart';
import 'package:Visir/features/inbox/infrastructure/services/ai_credits_service.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@riverpod
SupabaseInboxDatasource supabaseInboxDatasource(Ref ref) {
  return SupabaseInboxDatasource();
}

@riverpod
OpenAiInboxDatasource openAiInboxDatasource(Ref ref) {
  return OpenAiInboxDatasource();
}

@riverpod
GoogleAiInboxDatasource googleAiInboxDatasource(Ref ref) {
  return GoogleAiInboxDatasource();
}

@riverpod
AnthropicAiInboxDatasource anthropicAiInboxDatasource(Ref ref) {
  return AnthropicAiInboxDatasource();
}

@riverpod
SupabaseAiUsageLogDatasource supabaseAiUsageLogDatasource(Ref ref) {
  return SupabaseAiUsageLogDatasource();
}

@riverpod
AiCreditsService aiCreditsService(Ref ref) {
  return AiCreditsService(authRepository: ref.watch(authRepositoryProvider), usageLogDatasource: ref.watch(supabaseAiUsageLogDatasourceProvider));
}

@riverpod
InboxRepository inboxRepository(Ref ref) {
  return InboxRepository(
    datasources: {
      DatasourceType.supabase: ref.watch(supabaseInboxDatasourceProvider),
      DatasourceType.openai: ref.watch(openAiInboxDatasourceProvider),
      DatasourceType.google: ref.watch(googleAiInboxDatasourceProvider),
      DatasourceType.microsoft: ref.watch(anthropicAiInboxDatasourceProvider),
    },
    creditsService: ref.watch(aiCreditsServiceProvider),
  );
}

@riverpod
SupabaseAgentChatHistoryDatasource supabaseAgentChatHistoryDatasource(Ref ref) {
  return SupabaseAgentChatHistoryDatasource();
}

@riverpod
AgentChatHistoryRepository agentChatHistoryRepository(Ref ref) {
  return AgentChatHistoryRepository(datasource: ref.watch(supabaseAgentChatHistoryDatasourceProvider));
}

enum InboxFilterType { all, unread, chat, mail, deleted }

extension InboxFilterTypeX on InboxFilterType {
  String getName(BuildContext context) {
    switch (this) {
      case InboxFilterType.all:
        return context.tr.inbox_filter_all;
      case InboxFilterType.unread:
        return context.tr.inbox_filter_unread;
      case InboxFilterType.chat:
        return context.tr.inbox_filter_chat;
      case InboxFilterType.mail:
        return context.tr.inbox_filter_mail;
      case InboxFilterType.deleted:
        return context.tr.inbox_filter_deleted;
    }
  }
}

@riverpod
class InboxFilter extends _$InboxFilter {
  @override
  InboxFilterType build(TabType tabType) {
    return InboxFilterType.all;
  }

  void setInboxFilter(InboxFilterType type) {
    state = type;
  }
}

enum InboxSuggestionSortType { date, due, importance }

@riverpod
class InboxSuggestionSort extends _$InboxSuggestionSort {
  @override
  Future<InboxSuggestionSortType> build(TabType tabType) async {
    if (ref.watch(shouldUseMockDataProvider)) return InboxSuggestionSortType.date;

    final localPref = ref.watch(localPrefControllerProvider).value;
    final savedSort = localPref?.prefInboxSuggestionSort[tabType.name];
    if (savedSort != null) {
      try {
        return InboxSuggestionSortType.values.firstWhere((e) => e.name == savedSort);
      } catch (e) {
        return InboxSuggestionSortType.date;
      }
    }

    return InboxSuggestionSortType.date;
  }

  void setInboxSuggestionSort(InboxSuggestionSortType type) {
    state = AsyncValue.data(type);
    final localPref = ref.read(localPrefControllerProvider).value;
    final currentSorts = localPref?.prefInboxSuggestionSort ?? {};
    ref.read(localPrefControllerProvider.notifier).set(inboxSuggestionSort: {...currentSorts, tabType.name: type.name});
  }
}

enum InboxSuggestionFilterType { none, urgent, important, actionRequired, all }

extension InboxSuggestionFilterTypeX on InboxSuggestionFilterType {
  Color get color {
    switch (this) {
      case InboxSuggestionFilterType.all:
        return Utils.mainContext.tertiary;
      case InboxSuggestionFilterType.none:
        return Utils.mainContext.outline;
      case InboxSuggestionFilterType.urgent:
        return Colors.deepOrange;
      case InboxSuggestionFilterType.important:
        return Colors.orange;
      case InboxSuggestionFilterType.actionRequired:
        return Utils.mainContext.secondary;
    }
  }
}

@riverpod
class InboxSuggestionFilter extends _$InboxSuggestionFilter {
  @override
  Future<InboxSuggestionFilterType> build(TabType tabType) async {
    if (ref.watch(shouldUseMockDataProvider)) return InboxSuggestionFilterType.all;

    final localPref = ref.watch(localPrefControllerProvider).value;
    final savedFilter = localPref?.prefInboxSuggestionFilter[tabType.name];
    if (savedFilter != null) {
      try {
        return InboxSuggestionFilterType.values.firstWhere((e) => e.name == savedFilter);
      } catch (e) {
        return InboxSuggestionFilterType.all;
      }
    }

    return InboxSuggestionFilterType.all;
  }

  void setInboxSuggestionFilter(InboxSuggestionFilterType type) {
    state = AsyncValue.data(type);
    final localPref = ref.read(localPrefControllerProvider).value;
    final currentFilters = localPref?.prefInboxSuggestionFilter ?? {};
    ref.read(localPrefControllerProvider.notifier).set(inboxSuggestionFilter: {...currentFilters, tabType.name: type.name});
  }
}

@riverpod
class InboxListDate extends _$InboxListDate {
  @override
  DateTime build() {
    return DateUtils.dateOnly(DateTime.now());
  }

  void updateDate(DateTime date) {
    state = DateUtils.dateOnly(date);
  }
}

@riverpod
class InboxListIsSearch extends _$InboxListIsSearch {
  @override
  bool build() {
    return false;
  }

  void updateIsSearch(bool isSearch) {
    state = isSearch;
  }
}

enum AgentChatHistorySortType {
  updatedAtDesc, // 최신순 (기본)
  updatedAtAsc, // 오래된순
  messageCountDesc, // 메시지 수 많은 순
  messageCountAsc, // 메시지 수 적은 순
}

@riverpod
class AgentChatHistoryFilter extends _$AgentChatHistoryFilter {
  @override
  String? build() {
    return null; // null = 전체 프로젝트
  }

  void setFilter(String? projectId) {
    state = projectId;
  }
}

@riverpod
class AgentChatHistorySearchQuery extends _$AgentChatHistorySearchQuery {
  @override
  String build() {
    return '';
  }

  void setSearchQuery(String query) {
    state = query;
  }
}

@riverpod
class AgentChatHistorySort extends _$AgentChatHistorySort {
  @override
  AgentChatHistorySortType build() {
    return AgentChatHistorySortType.updatedAtDesc;
  }

  void setSortType(AgentChatHistorySortType type) {
    state = type;
  }
}

enum InboxScreenType { agent, manual }

@riverpod
class CurrentInboxScreenType extends _$CurrentInboxScreenType {
  @override
  InboxScreenType build() {
    if (ref.watch(shouldUseMockDataProvider)) return InboxScreenType.agent;

    // SharedPreferences에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return InboxScreenType.agent;

    final savedType = sharedPref.getString('inbox_screen_type');
    if (savedType != null && savedType.isNotEmpty) {
      try {
        return InboxScreenType.values.firstWhere((e) => e.name == savedType);
      } catch (e) {
        return InboxScreenType.agent;
      }
    }

    return InboxScreenType.agent;
  }

  Future<void> update(InboxScreenType type) async {
    // SharedPreferences에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setString('inbox_screen_type', type.name);
    state = type;
  }
}
