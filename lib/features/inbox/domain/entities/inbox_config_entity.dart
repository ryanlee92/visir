class InboxConfigEntity {
  final String id;
  final String userId;
  final DateTime dateTime;
  final DateTime? updatedAt;
  final bool? isRead;
  final bool? isDeleted;
  final bool? isTask;
  final String? inboxUniqueId;

  InboxConfigEntity({required this.userId, required this.dateTime, this.isRead, this.isDeleted, this.isTask, this.updatedAt, required this.inboxUniqueId})
    : id = '${userId}-${inboxUniqueId}';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date_time': dateTime.toUtc().toIso8601String(),
      'is_read': isRead,
      'is_deleted': isDeleted,
      'is_task': isTask,
      'updated_at': updatedAt?.toUtc().toIso8601String(),
      'inbox_unique_id': inboxUniqueId,
    };
  }

  factory InboxConfigEntity.fromJson(Map<String, dynamic> json) {
    return InboxConfigEntity(
      userId: json['user_id'],
      inboxUniqueId: json['inbox_unique_id'],
      dateTime: DateTime.parse(json['date_time']).toLocal(),
      isRead: json['is_read'],
      isDeleted: json['is_deleted'],
      isTask: json['is_task'],
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']).toLocal() : null,
    );
  }

  InboxConfigEntity copyWith({DateTime? dateTime, bool? isRead, bool? isPinned, bool? isDeleted, bool? isTask, DateTime? updatedAt, String? inboxUniqueId}) {
    return InboxConfigEntity(
      userId: userId,
      dateTime: dateTime ?? this.dateTime,
      isRead: isRead ?? this.isRead,
      isDeleted: isDeleted ?? this.isDeleted,
      isTask: isTask ?? this.isTask,
      updatedAt: updatedAt ?? this.updatedAt,
      inboxUniqueId: inboxUniqueId ?? this.inboxUniqueId,
    );
  }

  operator ==(Object other) {
    return other is InboxConfigEntity &&
        other.id == id &&
        other.userId == userId &&
        other.dateTime == dateTime &&
        other.isRead == isRead &&
        other.isDeleted == isDeleted &&
        other.isTask == isTask &&
        other.updatedAt == updatedAt &&
        other.inboxUniqueId == inboxUniqueId;
  }
}

class InboxConfigFetchListEntity {
  List<InboxConfigEntity> configs;
  int? sequence;

  InboxConfigFetchListEntity({required this.configs, this.sequence});

  factory InboxConfigFetchListEntity.fromJson(Map<String, dynamic> json) {
    return InboxConfigFetchListEntity(
      configs: (json['configs'] as List?)?.map((e) => InboxConfigEntity.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      sequence: json['sequence'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'configs': configs.map((e) => e.toJson()).toList(), 'sequence': sequence};
  }
}
