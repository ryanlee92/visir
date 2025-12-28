import 'package:Visir/features/inbox/application/agent_action_controller.dart';

class AgentChatHistoryEntity {
  final String id; // session ID
  final String? projectId;
  final List<AgentActionMessage> messages;
  final String? actionType;
  final String? conversationSummary;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEncrypted; // 암호화 여부 플래그

  AgentChatHistoryEntity({
    required this.id,
    this.projectId,
    required this.messages,
    this.actionType,
    this.conversationSummary,
    required this.createdAt,
    required this.updatedAt,
    this.isEncrypted = false, // 기본값은 false (기존 데이터 호환)
  });

  Map<String, dynamic> toJson({bool? local}) {
    return {
      'id': id,
      'project_id': projectId,
      'messages': messages.map((m) => m.toJson(local: local)).toList(),
      'action_type': actionType,
      'conversation_summary': conversationSummary, // 평문 유지 (검색용)
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'is_encrypted': local != true, // 로컬이 아니면 암호화됨
    };
  }

  factory AgentChatHistoryEntity.fromJson(Map<String, dynamic> json, {bool? local}) {
    final isEncrypted = json['is_encrypted'] as bool? ?? false;
    // local이 true면 평문, false면 isEncrypted 플래그에 따라 복호화
    final shouldDecrypt = local != true && isEncrypted;

    return AgentChatHistoryEntity(
      id: json['id'] as String,
      projectId: json['project_id'] as String?,
      messages: (json['messages'] as List<dynamic>?)
              ?.map((e) => AgentActionMessage.fromJson(e as Map<String, dynamic>, local: local, isEncrypted: shouldDecrypt))
              .toList() ??
          [],
      actionType: json['action_type'] as String?,
      conversationSummary: json['conversation_summary'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
      isEncrypted: isEncrypted,
    );
  }

  AgentChatHistoryEntity copyWith({
    String? id,
    String? projectId,
    List<AgentActionMessage>? messages,
    String? actionType,
    String? conversationSummary,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEncrypted,
  }) {
    return AgentChatHistoryEntity(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      messages: messages ?? this.messages,
      actionType: actionType ?? this.actionType,
      conversationSummary: conversationSummary ?? this.conversationSummary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEncrypted: isEncrypted ?? this.isEncrypted,
    );
  }
}

