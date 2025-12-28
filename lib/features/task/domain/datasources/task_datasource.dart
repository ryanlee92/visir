import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/task/domain/entities/task_search_result_entity.dart';

abstract class TaskDatasource {
  Future<List<TaskEntity>> fetchTasks({required LocalPrefEntity pref, required String userId});

  Future<List<TaskEntity>> fetchTasksByProject({required String projectId, required String userId});

  Future<List<TaskEntity>> fetchRecurringTasks({required LocalPrefEntity pref, required String userId});

  Future<List<TaskEntity>> fetchUnscheduledTasks({required LocalPrefEntity pref, required String userId});

  Future<List<TaskEntity>> fetchNonRecurringTasks({
    required DateTime startAtBefore,
    required DateTime? startAtAfter,
    required LocalPrefEntity pref,
    required String userId,
  });

  Future<List<TaskEntity>> fetchTasksBetweenDates({
    required DateTime startDateTime,
    required DateTime endDateTime,
    required LocalPrefEntity pref,
    required String userId,
  });

  Future<List<TaskEntity>> fetchTasksByStatus({
    required TaskStatus status,
    required LocalPrefEntity pref,
    required String userId,
    int? limit,
    int? offset,
  });

  Future<TaskSearchResultEntity> searchTasks({
    required String query,
    required Map<String, String?>? nextPageTokens,
    required LocalPrefEntity pref,
    required String userId,
    bool? isDone,
  });

  Future<void> saveTask({required TaskEntity task});

  Future<void> deleteTask({required TaskEntity task});

  Future<void> cacheTasks({required DateTime startDateTime, required DateTime endDateTime, required List<TaskEntity> tasks});

  Future<void> cacheTasksBetweenDates({required DateTime startDateTime, required DateTime endDateTime, required List<TaskEntity> tasks});
}
