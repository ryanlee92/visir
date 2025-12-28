import 'package:Visir/features/task/domain/entities/task_entity.dart';

class InboxLinkedTaskEntity {
  final String inboxId;
  final List<TaskEntity> tasks;

  InboxLinkedTaskEntity({required this.inboxId, required this.tasks});

  factory InboxLinkedTaskEntity.fromJson(Map<String, dynamic> json) {
    return InboxLinkedTaskEntity(inboxId: json['inbox_id'], tasks: (json['tasks'] as List?)?.map((e) => TaskEntity.fromJson(e)).toList() ?? []);
  }

  Map<String, dynamic> toJson() {
    return {'inbox_id': inboxId, 'tasks': tasks.map((e) => e.toJson()).toList()};
  }

  InboxLinkedTaskEntity copyWith({String? inboxId, List<TaskEntity>? tasks}) {
    return InboxLinkedTaskEntity(inboxId: inboxId ?? this.inboxId, tasks: tasks ?? this.tasks);
  }
}

class InboxLinkedTaskFetchListEntity {
  final List<InboxLinkedTaskEntity> linkedTasks;
  final int sequence;

  InboxLinkedTaskFetchListEntity({required this.linkedTasks, required this.sequence});

  factory InboxLinkedTaskFetchListEntity.fromJson(Map<String, dynamic> json) {
    return InboxLinkedTaskFetchListEntity(
      linkedTasks: (json['linked_tasks'] as List?)?.map((e) => InboxLinkedTaskEntity.fromJson(e)).toList() ?? [],
      sequence: json['sequence'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'linked_tasks': linkedTasks.map((e) => e.toJson()).toList(), 'sequence': sequence};
  }
}
