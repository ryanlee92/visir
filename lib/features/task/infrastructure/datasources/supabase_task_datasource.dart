import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart';
import 'package:Visir/features/task/domain/datasources/task_datasource.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/task/domain/entities/task_search_result_entity.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseTaskDatasource extends TaskDatasource {
  SupabaseClient get client => Supabase.instance.client;
  final taskDatabaseTable = 'tasks';
  final taskeyTaskKey = 'taskey';

  @override
  Future<List<TaskEntity>> fetchTasksBetweenDates({required DateTime startDateTime, required DateTime endDateTime, required LocalPrefEntity pref, required String userId}) async {
    final nonRecurring = await fetchNonRecurringTasks(startAtBefore: endDateTime, startAtAfter: startDateTime, pref: pref, userId: userId);
    final recurring = await fetchRecurringTasks(pref: pref, userId: userId);
    final tasks = [...nonRecurring, ...recurring].unique((e) => e.id).toList();
    return tasks;
  }

  Future<List<TaskEntity>> fetchTasksByProject({required String projectId, required String userId}) async {
    final result = await client.from(taskDatabaseTable).select().eq('owner_id', userId).eq('project_id', projectId);
    return result.map((e) => TaskEntity.fromJson(e)).toList();
  }

  Future<Map<String, List<TaskEntity>>> fetchLinkedTasksForInboxes({required String userId, required List<String> mailKeys, required List<String> messageKeys}) async {
    if (mailKeys.isEmpty && messageKeys.isEmpty) return {};
    final result = await client.rpc('get_tasks_for_inboxes', params: {'uid': userId, 'mail_keys': mailKeys, 'message_keys': messageKeys});
    final map = <String, List<TaskEntity>>{};
    for (final row in (result as List)) {
      final r = (row as Map).cast<String, dynamic>();
      final inboxId = r['inbox_id'] as String;
      final taskJson = (r['task'] as Map).cast<String, dynamic>();
      (map[inboxId] ??= []).add(TaskEntity.fromJson(taskJson));
    }
    return map;
  }

  @override
  Future<List<TaskEntity>> fetchTasks({required LocalPrefEntity pref, required String userId}) async {
    throw UnimplementedError();
  }

  @override
  Future<List<TaskEntity>> fetchNonRecurringTasks({required DateTime startAtBefore, required DateTime? startAtAfter, required LocalPrefEntity pref, required String userId}) async {
    final result = startAtAfter == null
        ? await client.from(taskDatabaseTable).select().eq('owner_id', userId).lte('start_at', startAtBefore).filter('rrule', 'is', null).not('recurrence_end_at', 'is', null)
        : await client
              .from(taskDatabaseTable)
              .select()
              .eq('owner_id', userId)
              .gte('start_at', startAtAfter)
              .lte('start_at', startAtBefore)
              .filter('rrule', 'is', null)
              .not('recurrence_end_at', 'is', null);
    return result.map((e) => TaskEntity.fromJson(e)).toList();
  }

  @override
  Future<List<TaskEntity>> fetchRecurringTasks({required LocalPrefEntity pref, required String userId}) async {
    final result = await client.from(taskDatabaseTable).select().eq('owner_id', userId).isFilter('linked_event', null).not('rrule', 'is', null);
    return result.map((e) => TaskEntity.fromJson(e)).toList();
  }

  @override
  Future<List<TaskEntity>> fetchUnscheduledTasks({required LocalPrefEntity pref, required String userId}) async {
    final result = await client.from(taskDatabaseTable).select().eq('owner_id', userId).isFilter('linked_event', null).filter('start_at', 'is', null).filter('end_at', 'is', null);
    return result.map((e) => TaskEntity.fromJson(e)).toList();
  }

  @override
  Future<List<TaskEntity>> fetchTasksByStatus({
    required TaskStatus status,
    required LocalPrefEntity pref,
    required String userId,
    int? limit,
    int? offset,
  }) async {
    // updated_at 기준으로 정렬하여 offset 기반 레이지로딩 지원 (최신부터: descending)
    // linkedEvent == null인 것만 가져오기 (isCancelled는 클라이언트에서 체크)
    var query = client
        .from(taskDatabaseTable)
        .select()
        .eq('owner_id', userId)
        .eq('status', status.name)
        .isFilter('linked_event', null)
        .order('updated_at', ascending: false, nullsFirst: false);
    
    if (offset != null) {
      final endOffset = limit != null ? offset + limit - 1 : offset + 100 - 1;
      query = query.range(offset, endOffset);
    } else if (limit != null) {
      query = query.limit(limit);
    }
    
    final result = await query;
    return result.map((e) => TaskEntity.fromJson(e)).toList();
  }

  @override
  Future<TaskSearchResultEntity> searchTasks({
    required String query,
    required Map<String, String?>? nextPageTokens,
    required LocalPrefEntity pref,
    required String userId,
    bool? isDone,
    int? count,
  }) async {
    final totalCount =
        count ??
        (isDone == null
            ? (await client.from(taskDatabaseTable).select().eq('owner_id', userId).neq('status', TaskStatus.cancelled.name).count()).count
            : (await client.from(taskDatabaseTable).select().eq('owner_id', userId).eq('status', isDone ? TaskStatus.done.name : TaskStatus.none.name).count()).count);

    final offset = nextPageTokens?[taskeyTaskKey]?.isNotEmpty != true ? 0 : int.parse(nextPageTokens![taskeyTaskKey]!);
    final result = isDone == null
        ? await client
              .from(taskDatabaseTable)
              .select()
              .eq('owner_id', userId)
              .neq('status', TaskStatus.cancelled.name)
              .order('created_at', ascending: false)
              .order('status', ascending: true)
              .range(offset, offset + 100)
        : await client
              .from(taskDatabaseTable)
              .select()
              .eq('owner_id', userId)
              .eq('status', isDone ? TaskStatus.done.name : TaskStatus.none.name)
              .order('created_at', ascending: false)
              .order('status', ascending: true)
              .range(offset, offset + 100);
    final tasks = result.map((e) => TaskEntity.fromJson(e)).toList();

    String? pageToken = totalCount > offset + 100 ? (offset + 100).toString() : null;
    final filteredTasks = tasks.where((e) => e.title?.toLowerCase().contains(query.toLowerCase()) == true).toList();
    if (pageToken != null && filteredTasks.length < 10) {
      final nextTasks = await searchTasks(query: query, nextPageTokens: {taskeyTaskKey: pageToken}, pref: pref, userId: userId, isDone: isDone, count: totalCount);
      tasks.addAll(nextTasks.tasks[taskeyTaskKey] ?? []);
      pageToken = nextTasks.nextPageTokens[taskeyTaskKey];
    }

    return TaskSearchResultEntity(
      tasks: {taskeyTaskKey: tasks.where((e) => e.title?.toLowerCase().contains(query.toLowerCase()) == true).toList()},
      nextPageTokens: {taskeyTaskKey: pageToken},
    );
  }

  @override
  Future<void> saveTask({required TaskEntity task}) async {
    debugPrint('[SupabaseTaskDatasource] saveTask 시작: task.id=${task.id}, task.title=${task.title}');
    try {
      final json = task.toJson();
      debugPrint('[SupabaseTaskDatasource] saveTask: DB upsert 호출 전, task.id=${task.id}');
      await client.from(taskDatabaseTable).upsert(json);
      debugPrint('[SupabaseTaskDatasource] saveTask: DB upsert 호출 완료, task.id=${task.id}');
    } catch (e) {
      debugPrint('[SupabaseTaskDatasource] saveTask: DB upsert 실패, 에러=$e');
      rethrow;
    }
  }

  @override
  Future<void> deleteTask({required TaskEntity task}) async {
    if (task.id == null) return;
    await client.from(taskDatabaseTable).delete().eq('id', task.id!);
  }

  @override
  Future<void> cacheTasks({required DateTime startDateTime, required DateTime endDateTime, required List<TaskEntity> tasks}) {
    // TODO: implement cacheTasks
    throw UnimplementedError();
  }

  @override
  Future<void> cacheTasksBetweenDates({required DateTime startDateTime, required DateTime endDateTime, required List<TaskEntity> tasks}) {
    // TODO: implement cacheTasksBetweenDates
    throw UnimplementedError();
  }
}
