import 'package:Visir/features/inbox/domain/entities/agent_chat_history_entity.dart';

abstract class AgentChatHistoryDatasource {
  Future<void> saveChatHistory({
    required String userId,
    required AgentChatHistoryEntity history,
  });

  Future<AgentChatHistoryEntity?> getChatHistoryById({
    required String userId,
    required String sessionId,
  });

  Future<List<AgentChatHistoryEntity>> getChatHistoryListByProject({
    required String userId,
    String? projectId,
    int? offset,
    int? limit,
    String? sortBy,
    bool? ascending,
  });

  Future<void> deleteChatHistory({
    required String userId,
    required String sessionId,
  });
}

