import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:flutter/widgets.dart';

enum TaskLabelType { all, today, completed, overdue, unscheduled, upcoming }

extension TaskLabelTypeX on TaskLabelType {
  String getTitle(BuildContext context, String? colorString) {
    switch (this) {
      case TaskLabelType.all:
        return context.tr.task_label_all;
      case TaskLabelType.today:
        return context.tr.task_label_today;
      case TaskLabelType.completed:
        return context.tr.task_label_completed;
      case TaskLabelType.overdue:
        return context.tr.task_label_overdue;
      case TaskLabelType.unscheduled:
        return context.tr.task_label_unscheduled;
      case TaskLabelType.upcoming:
        return context.tr.task_label_upcoming;
    }
  }
}

class TaskLabelEntity {
  TaskLabelType type;
  String? colorString;

  TaskLabelEntity({required this.type, this.colorString});

  String get id => type.name + (colorString ?? '');
}
