import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/inbox/domain/datasources/inbox_datasource.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_config_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_fetch_list_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_suggestion_entity.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseInboxDatasource extends InboxDatasource {
  SupabaseClient get client => Supabase.instance.client;

  final inboxConfigDatabaseTable = 'inbox_config';
  final inboxSuggestionsDatabaseTable = 'inbox_suggestions';
  final inboxConversationSummaryDatabaseTable = 'inbox_conversation_summary';

  @override
  Future<void> deleteInboxConfig({required List<String> configIds}) async {
    await client.from(inboxConfigDatabaseTable).delete().inFilter('id', configIds);
  }

  @override
  Future<List<InboxConfigEntity>> fetchInboxConfig({required String userId, List<String>? configIds}) async {
    List<Map<String, dynamic>> result;
    result = await client.from(inboxConfigDatabaseTable).select().eq('user_id', userId).inFilter('id', configIds ?? []);
    return result.map((e) => InboxConfigEntity.fromJson(e)).toList();
  }

  @override
  Future<void> saveInboxConfig({required List<InboxConfigEntity> inboxConfigs}) async {
    await client.from(inboxConfigDatabaseTable).upsert(inboxConfigs.map((e) => e.toJson()).toList());
  }

  @override
  Future<List<InboxSuggestionEntity>> fetchInboxSuggestions({required List<InboxEntity> inboxes, required List<ProjectEntity> projects, String? model, String? apiKey}) async {
    return [];
  }

  @override
  Future<List<InboxSuggestionEntity>> fetchInboxSuggestionsFromCache({required String userId, required List<String> inboxIds}) async {
    if (inboxIds.isEmpty) return [];

    try {
      final result = await client.from(inboxSuggestionsDatabaseTable).select().eq('user_id', userId).inFilter('inbox_id', inboxIds);

      return (result as List<dynamic>).map((e) {
        final json = Map<String, dynamic>.from(e as Map<String, dynamic>);
        // Map inbox_id to id for InboxSuggestionEntity
        json['id'] = json['inbox_id'];
        // Handle nullable date_type - fromJson's firstWhere will fail if date_type is null
        // So we need to provide a default value if null
        if (json['date_type'] == null) {
          json['date_type'] = 'task'; // Default to 'task' if null
        }
        return InboxSuggestionEntity.fromJson(json, local: false); // Supabase는 암호화됨
      }).toList();
    } catch (e) {
      // If cache fetch fails, return empty list (will fallback to AI)
      return [];
    }
  }

  @override
  Future<void> saveInboxSuggestions({required String userId, required List<InboxSuggestionEntity> suggestions}) async {
    if (suggestions.isEmpty) return;

    try {
      final suggestionsJson = suggestions.map((suggestion) {
        final json = suggestion.toJson(local: false); // Supabase는 암호화됨
        // Add user_id and ensure inbox_id is set
        json['user_id'] = userId;
        json['inbox_id'] = suggestion.id;
        // target_date is already converted to ISO string in toJson(), so no need to convert again
        // Remove 'id' field as it's not part of the table schema (we use inbox_id instead)
        json.remove('id');
        return json;
      }).toList();

      await client.from(inboxSuggestionsDatabaseTable).upsert(suggestionsJson, onConflict: 'user_id,inbox_id');
    } catch (e) {
      // If save fails, log but don't throw (non-critical operation)
    }
  }

  @override
  Future<InboxFetchListEntity> fetchInbox({required DateTime dateTime}) {
    // TODO: implement fetchInbox
    throw UnimplementedError();
  }

  @override
  Future<String?> fetchConversationSummaryFromCache({required String userId, String? taskId, String? eventId}) async {
    if (taskId == null && eventId == null) return null;

    try {
      // Build query with exact match for both task_id and event_id
      // This ensures we get the unique row matching the exact combination
      var query = client.from(inboxConversationSummaryDatabaseTable).select().eq('user_id', userId).gt('expires_at', DateTime.now().toIso8601String());

      // Both task_id and event_id must match exactly (including NULL)
      if (taskId != null) {
        query = query.eq('task_id', taskId);
      } else {
        // Use isFilter to match NULL values exactly in PostgREST
        query = query.isFilter('task_id', null);
      }

      if (eventId != null) {
        query = query.eq('event_id', eventId);
      } else {
        // Use isFilter to match NULL values exactly in PostgREST
        query = query.isFilter('event_id', null);
      }

      // Order by updated_at desc to get the most recent one if duplicates exist
      // Then limit to 1 to ensure we only get one result
      final results = await query.order('updated_at', ascending: false).limit(1).select();

      if (results.isEmpty) {
        return null;
      }

      final result = results.first;
      final json = Map<String, dynamic>.from(result);
      final summary = json['summary'] as String?;
      final isEncrypted = json['is_encrypted'] as bool? ?? false;
      
      // 암호화된 데이터 자동 감지: base64로 디코딩하면 "Salted__"로 시작함
      bool isEncryptedData(String? value) {
        if (value == null || value.isEmpty) return false;
        try {
          final decoded = base64Decode(value);
          return decoded.length >= 8 && String.fromCharCodes(decoded.take(8)) == 'Salted__';
        } catch (e) {
          return false;
        }
      }
      
      // 복호화 처리 (is_encrypted 플래그가 false여도 실제 데이터가 암호화되어 있으면 복호화 시도)
      if (summary != null && summary.isNotEmpty && (isEncrypted || isEncryptedData(summary))) {
        try {
          return Utils.decryptAESCryptoJS(summary, aesKey);
        } catch (e) {
          return summary; // 복호화 실패 시 원본 반환
        }
      }
      return summary;
    } catch (e) {
      // If cache fetch fails, return null (will fallback to AI)
      return null;
    }
  }

  @override
  Future<void> saveConversationSummary({required String userId, String? taskId, String? eventId, required String summary}) async {
    if (taskId == null && eventId == null) return;

    try {
      final expiresAt = DateTime.now().add(const Duration(days: 2));

      // Before upsert, delete any existing duplicates for the same (user_id, task_id, event_id) combination
      // This handles the case where NULL values allow multiple rows
      var deleteQuery = client.from(inboxConversationSummaryDatabaseTable).delete().eq('user_id', userId);

      if (taskId != null) {
        deleteQuery = deleteQuery.eq('task_id', taskId);
      } else {
        deleteQuery = deleteQuery.isFilter('task_id', null);
      }

      if (eventId != null) {
        deleteQuery = deleteQuery.eq('event_id', eventId);
      } else {
        deleteQuery = deleteQuery.isFilter('event_id', null);
      }

      // Delete all existing rows matching the criteria (including duplicates)
      await deleteQuery;

      // Now insert the new row (암호화 처리)
      final encryptedSummary = summary.isNotEmpty ? Utils.encryptAESCryptoJS(summary, aesKey) : summary;
      await client.from(inboxConversationSummaryDatabaseTable).insert({
        'user_id': userId,
        'task_id': taskId,
        'event_id': eventId,
        'summary': encryptedSummary,
        'expires_at': expiresAt.toIso8601String(),
        'is_encrypted': true,
      });
    } catch (e) {
      // If save fails, log but don't throw (non-critical operation)
    }
  }
}
