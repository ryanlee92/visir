class MessageChannelLastEntity {
  final String id;
  final String channelId;
  final String teamId;
  final DateTime lastMessageCreatedAt;

  MessageChannelLastEntity({
    required this.id,
    required this.channelId,
    required this.teamId,
    required this.lastMessageCreatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channel_id': channelId,
      'team_id': teamId,
      'last_message_created_at': lastMessageCreatedAt.toUtc().toIso8601String(),
    };
  }

  factory MessageChannelLastEntity.fromJson(Map<String, dynamic> json) {
    return MessageChannelLastEntity(
      id: json['id'],
      channelId: json['channel_id'],
      teamId: json['team_id'],
      lastMessageCreatedAt: DateTime.parse(json['last_message_created_at']).toLocal(),
    );
  }
}
