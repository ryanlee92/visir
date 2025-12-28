// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(supabaseTaskDatasource)
const supabaseTaskDatasourceProvider = SupabaseTaskDatasourceProvider._();

final class SupabaseTaskDatasourceProvider
    extends
        $FunctionalProvider<
          SupabaseTaskDatasource,
          SupabaseTaskDatasource,
          SupabaseTaskDatasource
        >
    with $Provider<SupabaseTaskDatasource> {
  const SupabaseTaskDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supabaseTaskDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supabaseTaskDatasourceHash();

  @$internal
  @override
  $ProviderElement<SupabaseTaskDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SupabaseTaskDatasource create(Ref ref) {
    return supabaseTaskDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseTaskDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabaseTaskDatasource>(value),
    );
  }
}

String _$supabaseTaskDatasourceHash() =>
    r'39c13de87df9d2bc6b542283354bed4daa9db605';

@ProviderFor(supabaseProjectDatasource)
const supabaseProjectDatasourceProvider = SupabaseProjectDatasourceProvider._();

final class SupabaseProjectDatasourceProvider
    extends
        $FunctionalProvider<
          SupabaseProjectDatasource,
          SupabaseProjectDatasource,
          SupabaseProjectDatasource
        >
    with $Provider<SupabaseProjectDatasource> {
  const SupabaseProjectDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supabaseProjectDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supabaseProjectDatasourceHash();

  @$internal
  @override
  $ProviderElement<SupabaseProjectDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SupabaseProjectDatasource create(Ref ref) {
    return supabaseProjectDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseProjectDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabaseProjectDatasource>(value),
    );
  }
}

String _$supabaseProjectDatasourceHash() =>
    r'868a412483484e26278c81627f5a96140d86d0cd';

@ProviderFor(projectRepository)
const projectRepositoryProvider = ProjectRepositoryProvider._();

final class ProjectRepositoryProvider
    extends
        $FunctionalProvider<
          ProjectRepository,
          ProjectRepository,
          ProjectRepository
        >
    with $Provider<ProjectRepository> {
  const ProjectRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'projectRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$projectRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProjectRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProjectRepository create(Ref ref) {
    return projectRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProjectRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProjectRepository>(value),
    );
  }
}

String _$projectRepositoryHash() => r'4c87c022a2fd3aec61a58e215f4ca69b45b2f1cf';

@ProviderFor(taskRepository)
const taskRepositoryProvider = TaskRepositoryProvider._();

final class TaskRepositoryProvider
    extends $FunctionalProvider<TaskRepository, TaskRepository, TaskRepository>
    with $Provider<TaskRepository> {
  const TaskRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskRepositoryHash();

  @$internal
  @override
  $ProviderElement<TaskRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TaskRepository create(Ref ref) {
    return taskRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskRepository>(value),
    );
  }
}

String _$taskRepositoryHash() => r'7cc9e50b79770b6231454180783a686abd19bb27';

@ProviderFor(TaskDates)
const taskDatesProvider = TaskDatesProvider._();

final class TaskDatesProvider
    extends $NotifierProvider<TaskDates, List<DateTime?>> {
  const TaskDatesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskDatesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskDatesHash();

  @$internal
  @override
  TaskDates create() => TaskDates();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<DateTime?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<DateTime?>>(value),
    );
  }
}

String _$taskDatesHash() => r'7a56b0c1b1b18be8db721fbd2d0f1b93480fbf04';

abstract class _$TaskDates extends $Notifier<List<DateTime?>> {
  List<DateTime?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<DateTime?>, List<DateTime?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<DateTime?>, List<DateTime?>>,
              List<DateTime?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(TaskLabel)
const taskLabelProvider = TaskLabelProvider._();

final class TaskLabelProvider
    extends $NotifierProvider<TaskLabel, TaskLabelEntity> {
  const TaskLabelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskLabelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskLabelHash();

  @$internal
  @override
  TaskLabel create() => TaskLabel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskLabelEntity value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskLabelEntity>(value),
    );
  }
}

String _$taskLabelHash() => r'3a8e135c355a6c4ab914ec47c93a147425261724';

abstract class _$TaskLabel extends $Notifier<TaskLabelEntity> {
  TaskLabelEntity build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TaskLabelEntity, TaskLabelEntity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TaskLabelEntity, TaskLabelEntity>,
              TaskLabelEntity,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(TaskListCurrentLoadedMonths)
const taskListCurrentLoadedMonthsProvider =
    TaskListCurrentLoadedMonthsProvider._();

final class TaskListCurrentLoadedMonthsProvider
    extends $NotifierProvider<TaskListCurrentLoadedMonths, Set<DateTime>> {
  const TaskListCurrentLoadedMonthsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskListCurrentLoadedMonthsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskListCurrentLoadedMonthsHash();

  @$internal
  @override
  TaskListCurrentLoadedMonths create() => TaskListCurrentLoadedMonths();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<DateTime> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<DateTime>>(value),
    );
  }
}

String _$taskListCurrentLoadedMonthsHash() =>
    r'f004a66b584efe6b52c6437891b8a6f2ee5481a8';

abstract class _$TaskListCurrentLoadedMonths extends $Notifier<Set<DateTime>> {
  Set<DateTime> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Set<DateTime>, Set<DateTime>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<DateTime>, Set<DateTime>>,
              Set<DateTime>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
