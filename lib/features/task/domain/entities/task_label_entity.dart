import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:flutter/widgets.dart';

enum TaskLabelType { all, scheduled, completed, overdue, unscheduled }

extension TaskLabelTypeX on TaskLabelType {
  String getTitle(BuildContext context, String? colorString) {
    switch (this) {
      case TaskLabelType.all:
        return context.tr.task_label_all;
      case TaskLabelType.scheduled:
        return context.tr.task_label_scheduled;
      case TaskLabelType.completed:
        return context.tr.task_label_completed;
      case TaskLabelType.overdue:
        return context.tr.task_label_overdue;
      case TaskLabelType.unscheduled:
        return context.tr.task_label_unscheduled;
    }
  }
}

class TaskLabelEntity {
  TaskLabelType type;
  String? colorString;

  TaskLabelEntity({required this.type, this.colorString});

  String get id => type.name + (colorString ?? '');

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'colorString': colorString,
    };
  }

  factory TaskLabelEntity.fromJson(Map<String, dynamic> json) {
    return TaskLabelEntity(
      type: TaskLabelType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TaskLabelType.all,
      ),
      colorString: json['colorString'] as String?,
    );
  }
}
