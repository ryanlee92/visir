import 'package:Visir/features/inbox/domain/datasources/agent_chat_history_datasource.dart';
import 'package:Visir/features/inbox/domain/entities/agent_chat_history_entity.dart';

class AgentChatHistoryRepository {
  AgentChatHistoryRepository({required this.datasource});

  final AgentChatHistoryDatasource datasource;

  Future<void> saveChatHistory({required String userId, required AgentChatHistoryEntity history}) async {
    try {
      await datasource.saveChatHistory(userId: userId, history: history);
    } catch (e) {
      // If save fails, log but don't throw (non-critical operation)
      rethrow; // 디버깅을 위해 에러를 다시 던짐
    }
  }

  Future<AgentChatHistoryEntity?> getChatHistoryById({required String userId, required String sessionId}) async {
    try {
      return await datasource.getChatHistoryById(userId: userId, sessionId: sessionId);
    } catch (e) {
      return null;
    }
  }

  Future<List<AgentChatHistoryEntity>> getChatHistoryListByProject({required String userId, String? projectId, int? offset, int? limit, String? sortBy, bool? ascending}) async {
    try {
      return await datasource.getChatHistoryListByProject(userId: userId, projectId: projectId, offset: offset, limit: limit, sortBy: sortBy, ascending: ascending);
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteChatHistory({required String userId, required String sessionId}) async {
    try {
      await datasource.deleteChatHistory(userId: userId, sessionId: sessionId);
    } catch (e) {
      // If delete fails, log but don't throw
    }
  }
}
