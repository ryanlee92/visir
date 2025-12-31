// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TaskListController)
const taskListControllerProvider = TaskListControllerProvider._();

final class TaskListControllerProvider
    extends $NotifierProvider<TaskListController, TaskListResultEntity> {
  const TaskListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskListControllerHash();

  @$internal
  @override
  TaskListController create() => TaskListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskListResultEntity value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskListResultEntity>(value),
    );
  }
}

String _$taskListControllerHash() =>
    r'1711bd05a9d3466e74b7eaf5aec118cb2b1a01bb';

abstract class _$TaskListController extends $Notifier<TaskListResultEntity> {
  TaskListResultEntity build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TaskListResultEntity, TaskListResultEntity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TaskListResultEntity, TaskListResultEntity>,
              TaskListResultEntity,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(TaskListDateControllerInternal)
const taskListDateControllerInternalProvider =
    TaskListDateControllerInternalFamily._();

final class TaskListDateControllerInternalProvider
    extends
        $NotifierProvider<TaskListDateControllerInternal, List<TaskEntity>> {
  const TaskListDateControllerInternalProvider._({
    required TaskListDateControllerInternalFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'taskListDateControllerInternalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskListDateControllerInternalHash();

  @override
  String toString() {
    return r'taskListDateControllerInternalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TaskListDateControllerInternal create() => TaskListDateControllerInternal();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TaskEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TaskEntity>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TaskListDateControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskListDateControllerInternalHash() =>
    r'eeeeffad88087e2d9ce0c7c08acf13c1425c057e';

final class TaskListDateControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          TaskListDateControllerInternal,
          List<TaskEntity>,
          List<TaskEntity>,
          List<TaskEntity>,
          bool
        > {
  const TaskListDateControllerInternalFamily._()
    : super(
        retry: null,
        name: r'taskListDateControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TaskListDateControllerInternalProvider call({required bool isSignedIn}) =>
      TaskListDateControllerInternalProvider._(
        argument: isSignedIn,
        from: this,
      );

  @override
  String toString() => r'taskListDateControllerInternalProvider';
}

abstract class _$TaskListDateControllerInternal
    extends $Notifier<List<TaskEntity>> {
  late final _$args = ref.$arg as bool;
  bool get isSignedIn => _$args;

  List<TaskEntity> build({required bool isSignedIn});
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(isSignedIn: _$args);
    final ref = this.ref as $Ref<List<TaskEntity>, List<TaskEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<TaskEntity>, List<TaskEntity>>,
              List<TaskEntity>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(TaskListControllerInternal)
const taskListControllerInternalProvider = TaskListControllerInternalFamily._();

final class TaskListControllerInternalProvider
    extends
        $AsyncNotifierProvider<
          TaskListControllerInternal,
          TaskListResultEntity
        > {
  const TaskListControllerInternalProvider._({
    required TaskListControllerInternalFamily super.from,
    required ({bool isSignedIn, String labelId}) super.argument,
  }) : super(
         retry: null,
         name: r'taskListControllerInternalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskListControllerInternalHash();

  @override
  String toString() {
    return r'taskListControllerInternalProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  TaskListControllerInternal create() => TaskListControllerInternal();

  @override
  bool operator ==(Object other) {
    return other is TaskListControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskListControllerInternalHash() =>
    r'6849fa57662816d6be8680cdafc7cf898dad7a46';

final class TaskListControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          TaskListControllerInternal,
          AsyncValue<TaskListResultEntity>,
          TaskListResultEntity,
          FutureOr<TaskListResultEntity>,
          ({bool isSignedIn, String labelId})
        > {
  const TaskListControllerInternalFamily._()
    : super(
        retry: null,
        name: r'taskListControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TaskListControllerInternalProvider call({
    required bool isSignedIn,
    required String labelId,
  }) => TaskListControllerInternalProvider._(
    argument: (isSignedIn: isSignedIn, labelId: labelId),
    from: this,
  );

  @override
  String toString() => r'taskListControllerInternalProvider';
}

abstract class _$TaskListControllerInternal
    extends $AsyncNotifier<TaskListResultEntity> {
  late final _$args = ref.$arg as ({bool isSignedIn, String labelId});
  bool get isSignedIn => _$args.isSignedIn;
  String get labelId => _$args.labelId;

  FutureOr<TaskListResultEntity> build({
    required bool isSignedIn,
    required String labelId,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      isSignedIn: _$args.isSignedIn,
      labelId: _$args.labelId,
    );
    final ref =
        this.ref
            as $Ref<AsyncValue<TaskListResultEntity>, TaskListResultEntity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<TaskListResultEntity>,
                TaskListResultEntity
              >,
              AsyncValue<TaskListResultEntity>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
