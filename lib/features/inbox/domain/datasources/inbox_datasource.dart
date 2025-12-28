import 'package:Visir/features/inbox/domain/entities/inbox_config_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_fetch_list_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_suggestion_entity.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';

abstract class InboxDatasource {
  Future<List<InboxSuggestionEntity>> fetchInboxSuggestions({required List<InboxEntity> inboxes, required List<ProjectEntity> projects, String? model, String? apiKey});

  Future<List<InboxSuggestionEntity>> fetchInboxSuggestionsFromCache({required String userId, required List<String> inboxIds});

  Future<void> saveInboxSuggestions({required String userId, required List<InboxSuggestionEntity> suggestions});

  Future<List<InboxConfigEntity>> fetchInboxConfig({required String userId, List<String>? configIds});

  Future<void> saveInboxConfig({required List<InboxConfigEntity> inboxConfigs});

  Future<void> deleteInboxConfig({required List<String> configIds});

  Future<InboxFetchListEntity> fetchInbox({required DateTime dateTime});

  Future<String?> fetchConversationSummaryFromCache({required String userId, String? taskId, String? eventId});

  Future<void> saveConversationSummary({required String userId, String? taskId, String? eventId, required String summary});
}
