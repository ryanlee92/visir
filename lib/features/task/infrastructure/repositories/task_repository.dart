import 'package:Visir/config/providers.dart';
import 'package:Visir/features/common/domain/failures/failure.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/task/domain/datasources/task_datasource.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/task/domain/entities/task_search_result_entity.dart';
import 'package:collection/collection.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskRepository {
  final Map<DatasourceType, TaskDatasource> datasources;

  List<DatasourceType> get remoteDatasourceTypes => DatasourceType.values;

  TaskRepository({required this.datasources});

  Future<void> sendTaskOrEventChangeFcm({required TaskEntity task, required String action}) async {
    await proxyCall(
      oauth: null,
      headers: {},
      files: null,
      method: 'POST',
      url: sendTaskOrEventChangeFcmFunctionUrl,
      body: {'userId': Supabase.instance.client.auth.currentUser?.id, 'data': task.toJson(), 'type': 'task', 'action': action},
    );
  }

  Future<Either<Failure, List<TaskEntity>>> fetchTasks({
    required DateTime startAtBefore,
    required DateTime? startAtAfter,
    required LocalPrefEntity pref,
    required String userId,
  }) async {
    final list = startAtAfter == null
        ? [
            ...remoteDatasourceTypes
                .map((d) => datasources[d]?.fetchNonRecurringTasks(pref: pref, startAtBefore: startAtBefore, startAtAfter: null, userId: userId))
                .whereType<Future<List<TaskEntity>>>(),
            ...remoteDatasourceTypes.map((d) => datasources[d]?.fetchRecurringTasks(pref: pref, userId: userId)).whereType<Future<List<TaskEntity>>>(),
            ...remoteDatasourceTypes.map((d) => datasources[d]?.fetchUnscheduledTasks(pref: pref, userId: userId)).whereType<Future<List<TaskEntity>>>(),
          ]
        : [
            ...remoteDatasourceTypes
                .map((d) => datasources[d]?.fetchNonRecurringTasks(pref: pref, startAtBefore: startAtBefore, startAtAfter: startAtAfter, userId: userId))
                .whereType<Future<List<TaskEntity>>>(),
          ];
    try {
      final result = await Future.wait(list);
      final allTasks = <TaskEntity>[];
      for (final taskList in result) {
        allTasks.addAll(taskList);
      }
      
      // 특정 task ID 로그
      final targetTaskId = '1b348c67-1832-46f1-b2b2-91ec9c0928ab';
      final foundTask = allTasks.firstWhereOrNull((t) => t.id == targetTaskId);
      if (foundTask != null) {
        print('[TaskRepository] fetchTasks: targetTaskId=$targetTaskId 발견! startAtBefore=$startAtBefore, startAtAfter=$startAtAfter, 총 ${allTasks.length}개 task');
      } else {
        print('[TaskRepository] fetchTasks: targetTaskId=$targetTaskId 없음, startAtBefore=$startAtBefore, startAtAfter=$startAtAfter, 총 ${allTasks.length}개 task');
      }

      return right(allTasks);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, TaskSearchResultEntity>> searchTasks({
    required String query,
    required LocalPrefEntity pref,
    required String userId,
    bool? isDone,
    Map<String, String?>? nextPageTokens,
  }) async {
    try {
      final result = await Future.wait(
        remoteDatasourceTypes
            .map((d) => datasources[d]?.searchTasks(query: query, pref: pref, userId: userId, nextPageTokens: nextPageTokens, isDone: isDone))
            .whereType<Future<TaskSearchResultEntity>>(),
      );

      return right(
        result.fold<TaskSearchResultEntity>(
          TaskSearchResultEntity(tasks: {}, nextPageTokens: {}),
          (map1, map2) => TaskSearchResultEntity(tasks: {...map1.tasks, ...map2.tasks}, nextPageTokens: {...map1.nextPageTokens, ...map2.nextPageTokens}),
        ),
      );
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, Map<String, List<TaskEntity>>>> fetchLinkedTasksForInboxes({
    required String userId,
    required List<String> mailKeys,
    required List<String> messageKeys,
  }) async {
    try {
      final map =
          await (datasources[DatasourceType.supabase] as dynamic).fetchLinkedTasksForInboxes(userId: userId, mailKeys: mailKeys, messageKeys: messageKeys)
              as Map<String, List<TaskEntity>>;
      return right(map);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, List<TaskEntity>>> fetchTasksBetweenDates({
    required DateTime startDateTime,
    required DateTime endDateTime,
    required LocalPrefEntity pref,
    required String userId,
  }) async {
    try {
      final list = remoteDatasourceTypes
          .map((d) => datasources[d]?.fetchTasksBetweenDates(pref: pref, startDateTime: startDateTime, endDateTime: endDateTime, userId: userId))
          .whereType<Future<List<TaskEntity>>>();
      final result = await Future.wait(list);
      final allTasks = <TaskEntity>[];
      for (final taskList in result) {
        allTasks.addAll(taskList);
      }
      
      // 특정 task ID 로그
      final targetTaskId = '1b348c67-1832-46f1-b2b2-91ec9c0928ab';
      final foundTask = allTasks.firstWhereOrNull((t) => t.id == targetTaskId);
      if (foundTask != null) {
        print('[TaskRepository] fetchTasksBetweenDates: targetTaskId=$targetTaskId 발견! startDateTime=$startDateTime, endDateTime=$endDateTime, 총 ${allTasks.length}개 task');
      } else {
        print('[TaskRepository] fetchTasksBetweenDates: targetTaskId=$targetTaskId 없음, startDateTime=$startDateTime, endDateTime=$endDateTime, 총 ${allTasks.length}개 task');
      }

      return right(allTasks);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, List<TaskEntity>>> fetchTasksByStatus({required TaskStatus status, required LocalPrefEntity pref, required String userId, int? limit, int? offset}) async {
    try {
      final list = remoteDatasourceTypes
          .map((d) => datasources[d]?.fetchTasksByStatus(status: status, pref: pref, userId: userId, limit: limit, offset: offset))
          .whereType<Future<List<TaskEntity>>>();
      final result = await Future.wait(list);

      return right(result.fold([], (map1, map2) => [...map1, ...map2]));
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, List<TaskEntity>>> fetchUnscheduledTasks({required LocalPrefEntity pref, required String userId}) async {
    try {
      final list = remoteDatasourceTypes.map((d) => datasources[d]?.fetchUnscheduledTasks(pref: pref, userId: userId)).whereType<Future<List<TaskEntity>>>();
      final result = await Future.wait(list);

      return right(result.fold([], (map1, map2) => [...map1, ...map2]));
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, TaskEntity>> saveTask({required TaskEntity task}) async {
    debugPrint('[TaskRepository] saveTask 시작: task.id=${task.id}, task.title=${task.title}');
    try {
      final list = remoteDatasourceTypes.map((d) => datasources[d]?.saveTask(task: task)).whereType<Future<TaskEntity>>();
      debugPrint('[TaskRepository] saveTask: datasource 호출 전, datasourceCount=${list.length}');
      await Future.wait(list);
      debugPrint('[TaskRepository] saveTask: datasource 호출 완료');
      sendTaskOrEventChangeFcm(task: task, action: 'save');
      debugPrint('[TaskRepository] saveTask: 성공, task.id=${task.id}');
      return right(task);
    } catch (e) {
      debugPrint('[TaskRepository] saveTask: 실패, 에러=$e');
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, bool>> deleteTask({required TaskEntity task}) async {
    print('[TaskRepository] deleteTask 시작: task.id=${task.id}, task.title=${task.title}');
    try {
      final list = remoteDatasourceTypes.map((d) => datasources[d]?.deleteTask(task: task)).whereType<Future<bool>>();
      print('[TaskRepository] deleteTask: datasource 개수=${list.length}');
      await Future.wait(list);
      print('[TaskRepository] deleteTask: datasource 호출 완료');
      sendTaskOrEventChangeFcm(task: task, action: 'delete');
      print('[TaskRepository] deleteTask: FCM 전송 완료');
      return right(true);
    } catch (e) {
      print('[TaskRepository] deleteTask: 에러 발생, 에러=$e');
      return Utils.debugLeft(e);
    }
  }
}
