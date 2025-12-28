import 'package:Visir/features/task/domain/entities/task_entity.dart';

class TaskSearchResultEntity {
  Map<String, List<TaskEntity>> tasks;
  Map<String, String?> nextPageTokens;

  TaskSearchResultEntity({required this.tasks, this.nextPageTokens = const {}});
}
