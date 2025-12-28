class MessageUnreadEntity {
  final String id;
  final String channelId;
  final String teamId;
  final String userId;
  final DateTime lastMessageUserReadAt;

  MessageUnreadEntity({
    required this.id,
    required this.userId,
    required this.channelId,
    required this.teamId,
    required this.lastMessageUserReadAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channel_id': channelId,
      'team_id': teamId,
      'user_id': userId,
      'last_message_user_read_at': lastMessageUserReadAt.toUtc().toIso8601String(),
    };
  }

  factory MessageUnreadEntity.fromJson(Map<String, dynamic> json) {
    return MessageUnreadEntity(
      id: json['id'],
      channelId: json['channel_id'],
      teamId: json['team_id'],
      userId: json['user_id'],
      lastMessageUserReadAt: DateTime.parse(json['last_message_user_read_at']).toLocal(),
    );
  }
}
