import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/task/domain/entities/task_label_entity.dart';
import 'package:Visir/features/task/domain/repositories/project_repository.dart';
import 'package:Visir/features/task/infrastructure/datasources/supabase_project_datasource.dart';
import 'package:Visir/features/task/infrastructure/datasources/supabase_task_datasource.dart';
import 'package:Visir/features/task/infrastructure/repositories/project_repository_impl.dart';
import 'package:Visir/features/task/infrastructure/repositories/task_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@riverpod
SupabaseTaskDatasource supabaseTaskDatasource(Ref ref) {
  return SupabaseTaskDatasource();
}

@riverpod
SupabaseProjectDatasource supabaseProjectDatasource(Ref ref) {
  return SupabaseProjectDatasource();
}

@riverpod
ProjectRepository projectRepository(Ref ref) {
  return ProjectRepositoryImpl(datasource: ref.watch(supabaseProjectDatasourceProvider));
}

@riverpod
TaskRepository taskRepository(Ref ref) {
  return TaskRepository(datasources: {DatasourceType.supabase: ref.watch(supabaseTaskDatasourceProvider)});
}

@riverpod
class TaskDates extends _$TaskDates {
  @override
  List<DateTime?> build() {
    return [null, DateTime(1000)];
  }

  void updateDates(List<DateTime?> dates) {
    state = dates;
  }
}

@riverpod
class TaskLabel extends _$TaskLabel {
  @override
  TaskLabelEntity build() {
    if (ref.watch(shouldUseMockDataProvider)) {
      return TaskLabelEntity(type: TaskLabelType.all);
    }

    // SharedPreferences에서 읽기
    final sharedPrefAsync = ref.read(sharedPreferencesProvider);
    final sharedPref = sharedPrefAsync.asData?.value;
    if (sharedPref == null) return TaskLabelEntity(type: TaskLabelType.all);

    final labelJson = sharedPref.getString('task_label');
    if (labelJson == null || labelJson.isEmpty) {
      return TaskLabelEntity(type: TaskLabelType.all);
    }

    try {
      return TaskLabelEntity.fromJson(jsonDecode(labelJson) as Map<String, dynamic>);
    } catch (e) {
      return TaskLabelEntity(type: TaskLabelType.all);
    }
  }

  Future<void> updateLabel(TaskLabelEntity label) async {
    // SharedPreferences에 저장
    final sharedPref = await ref.read(sharedPreferencesProvider.future);
    await sharedPref.setString('task_label', jsonEncode(label.toJson()));
    state = label;
  }
}

@riverpod
class TaskListCurrentLoadedMonths extends _$TaskListCurrentLoadedMonths {
  @override
  Set<DateTime> build() {
    final now = DateTime.now();
    return {DateTime(now.year, now.month), DateTime(now.year, now.month + 1)};
  }

  void addMonth(DateTime month) {
    state = {...state, DateTime(month.year, month.month)};
  }
}
