import 'package:Visir/features/inbox/domain/datasources/agent_chat_history_datasource.dart';
import 'package:Visir/features/inbox/domain/entities/agent_chat_history_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAgentChatHistoryDatasource extends AgentChatHistoryDatasource {
  SupabaseClient get client => Supabase.instance.client;

  final agentChatHistoryDatabaseTable = 'agent_chat_history';

  @override
  Future<void> saveChatHistory({required String userId, required AgentChatHistoryEntity history}) async {
    try {
      final json = history.toJson(local: false); // Supabase 저장 시 암호화
      json['user_id'] = userId;
      await client.from(agentChatHistoryDatabaseTable).upsert(json, onConflict: 'id');
    } catch (e) {
      // If save fails, log but don't throw (non-critical operation)
      rethrow; // 디버깅을 위해 에러를 다시 던짐
    }
  }

  @override
  Future<AgentChatHistoryEntity?> getChatHistoryById({required String userId, required String sessionId}) async {
    try {
      final result = await client.from(agentChatHistoryDatabaseTable).select().eq('user_id', userId).eq('id', sessionId).single();

      return AgentChatHistoryEntity.fromJson(Map<String, dynamic>.from(result), local: false); // Supabase에서 읽을 때 복호화
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<AgentChatHistoryEntity>> getChatHistoryListByProject({required String userId, String? projectId, int? offset, int? limit, String? sortBy, bool? ascending}) async {
    try {
      var query = client.from(agentChatHistoryDatabaseTable).select().eq('user_id', userId);

      // projectId가 null이면 필터 없이 모든 히스토리 가져오기
      // projectId가 있으면 해당 프로젝트의 히스토리만 가져오기
      if (projectId != null) {
        query = query.eq('project_id', projectId);
      }

      // 소팅 적용 (sortBy가 null이면 기본값으로 updated_at desc 사용)
      dynamic orderedQuery;
      if (sortBy != null) {
        orderedQuery = query.order(sortBy, ascending: ascending ?? false);
      } else {
        // 기본값: updated_at descending
        orderedQuery = query.order('updated_at', ascending: false);
      }

      // offset과 limit 적용
      dynamic finalQuery;
      if (offset != null) {
        finalQuery = orderedQuery.range(offset, offset + (limit ?? 20) - 1);
      } else if (limit != null) {
        finalQuery = orderedQuery.limit(limit);
      } else {
        finalQuery = orderedQuery;
      }

      final result = await finalQuery;

      return (result as List<dynamic>)
          .map((e) => AgentChatHistoryEntity.fromJson(e as Map<String, dynamic>, local: false)) // Supabase에서 읽을 때 복호화
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> deleteChatHistory({required String userId, required String sessionId}) async {
    try {
      await client.from(agentChatHistoryDatabaseTable).delete().eq('user_id', userId).eq('id', sessionId);
    } catch (e) {
      // If delete fails, log but don't throw
    }
  }
}
