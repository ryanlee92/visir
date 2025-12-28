// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_summary_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 프로젝트 조회를 위한 Map 캐시 (성능 최적화)

@ProviderFor(_projectMap)
const _projectMapProvider = _ProjectMapProvider._();

/// 프로젝트 조회를 위한 Map 캐시 (성능 최적화)

final class _ProjectMapProvider
    extends
        $FunctionalProvider<
          Map<String, ProjectEntity>,
          Map<String, ProjectEntity>,
          Map<String, ProjectEntity>
        >
    with $Provider<Map<String, ProjectEntity>> {
  /// 프로젝트 조회를 위한 Map 캐시 (성능 최적화)
  const _ProjectMapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_projectMapProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_projectMapHash();

  @$internal
  @override
  $ProviderElement<Map<String, ProjectEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, ProjectEntity> create(Ref ref) {
    return _projectMap(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, ProjectEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, ProjectEntity>>(value),
    );
  }
}

String _$_projectMapHash() => r'6e384dca7a27e1a3f46da4576f9d4d70cfab652c';

/// 선택된 프로젝트의 관련 프로젝트 ID 목록 계산

@ProviderFor(relevantProjectIds)
const relevantProjectIdsProvider = RelevantProjectIdsFamily._();

/// 선택된 프로젝트의 관련 프로젝트 ID 목록 계산

final class RelevantProjectIdsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  /// 선택된 프로젝트의 관련 프로젝트 ID 목록 계산
  const RelevantProjectIdsProvider._({
    required RelevantProjectIdsFamily super.from,
    required (ProjectEntity?, List<ProjectEntityWithDepth>) super.argument,
  }) : super(
         retry: null,
         name: r'relevantProjectIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$relevantProjectIdsHash();

  @override
  String toString() {
    return r'relevantProjectIdsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    final argument =
        this.argument as (ProjectEntity?, List<ProjectEntityWithDepth>);
    return relevantProjectIds(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RelevantProjectIdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$relevantProjectIdsHash() =>
    r'22549e410c6414093f3ef4da0735c2be9c57197b';

/// 선택된 프로젝트의 관련 프로젝트 ID 목록 계산

final class RelevantProjectIdsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          List<String>,
          (ProjectEntity?, List<ProjectEntityWithDepth>)
        > {
  const RelevantProjectIdsFamily._()
    : super(
        retry: null,
        name: r'relevantProjectIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 선택된 프로젝트의 관련 프로젝트 ID 목록 계산

  RelevantProjectIdsProvider call(
    ProjectEntity? selectedProject,
    List<ProjectEntityWithDepth> projects,
  ) => RelevantProjectIdsProvider._(
    argument: (selectedProject, projects),
    from: this,
  );

  @override
  String toString() => r'relevantProjectIdsProvider';
}

/// 필터링된 태스크 계산 (캐싱)

@ProviderFor(filteredTasks)
const filteredTasksProvider = FilteredTasksFamily._();

/// 필터링된 태스크 계산 (캐싱)

final class FilteredTasksProvider
    extends
        $FunctionalProvider<
          List<TaskEntity>,
          List<TaskEntity>,
          List<TaskEntity>
        >
    with $Provider<List<TaskEntity>> {
  /// 필터링된 태스크 계산 (캐싱)
  const FilteredTasksProvider._({
    required FilteredTasksFamily super.from,
    required (List<TaskEntity>, ProjectEntity?, List<String>) super.argument,
  }) : super(
         retry: null,
         name: r'filteredTasksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredTasksHash();

  @override
  String toString() {
    return r'filteredTasksProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<List<TaskEntity>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<TaskEntity> create(Ref ref) {
    final argument =
        this.argument as (List<TaskEntity>, ProjectEntity?, List<String>);
    return filteredTasks(ref, argument.$1, argument.$2, argument.$3);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TaskEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TaskEntity>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredTasksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredTasksHash() => r'93a9a177783473ffa1da5c29b113a7c5676111f1';

/// 필터링된 태스크 계산 (캐싱)

final class FilteredTasksFamily extends $Family
    with
        $FunctionalFamilyOverride<
          List<TaskEntity>,
          (List<TaskEntity>, ProjectEntity?, List<String>)
        > {
  const FilteredTasksFamily._()
    : super(
        retry: null,
        name: r'filteredTasksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 필터링된 태스크 계산 (캐싱)

  FilteredTasksProvider call(
    List<TaskEntity> tasks,
    ProjectEntity? selectedProject,
    List<String> relevantIds,
  ) => FilteredTasksProvider._(
    argument: (tasks, selectedProject, relevantIds),
    from: this,
  );

  @override
  String toString() => r'filteredTasksProvider';
}

/// 필터링된 인박스 계산 (캐싱)

@ProviderFor(filteredInboxes)
const filteredInboxesProvider = FilteredInboxesFamily._();

/// 필터링된 인박스 계산 (캐싱)

final class FilteredInboxesProvider
    extends
        $FunctionalProvider<
          List<InboxEntity>,
          List<InboxEntity>,
          List<InboxEntity>
        >
    with $Provider<List<InboxEntity>> {
  /// 필터링된 인박스 계산 (캐싱)
  const FilteredInboxesProvider._({
    required FilteredInboxesFamily super.from,
    required (List<InboxEntity>, ProjectEntity?, List<String>) super.argument,
  }) : super(
         retry: null,
         name: r'filteredInboxesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredInboxesHash();

  @override
  String toString() {
    return r'filteredInboxesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<List<InboxEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<InboxEntity> create(Ref ref) {
    final argument =
        this.argument as (List<InboxEntity>, ProjectEntity?, List<String>);
    return filteredInboxes(ref, argument.$1, argument.$2, argument.$3);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<InboxEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<InboxEntity>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredInboxesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredInboxesHash() => r'4b1ff03bb6b77b6fda8180a6c089201b84d58106';

/// 필터링된 인박스 계산 (캐싱)

final class FilteredInboxesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          List<InboxEntity>,
          (List<InboxEntity>, ProjectEntity?, List<String>)
        > {
  const FilteredInboxesFamily._()
    : super(
        retry: null,
        name: r'filteredInboxesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 필터링된 인박스 계산 (캐싱)

  FilteredInboxesProvider call(
    List<InboxEntity> inboxes,
    ProjectEntity? selectedProject,
    List<String> relevantIds,
  ) => FilteredInboxesProvider._(
    argument: (inboxes, selectedProject, relevantIds),
    from: this,
  );

  @override
  String toString() => r'filteredInboxesProvider';
}

/// 오늘의 태스크 계산 (캐싱)

@ProviderFor(todayTasks)
const todayTasksProvider = TodayTasksFamily._();

/// 오늘의 태스크 계산 (캐싱)

final class TodayTasksProvider
    extends
        $FunctionalProvider<
          List<TaskEntity>,
          List<TaskEntity>,
          List<TaskEntity>
        >
    with $Provider<List<TaskEntity>> {
  /// 오늘의 태스크 계산 (캐싱)
  const TodayTasksProvider._({
    required TodayTasksFamily super.from,
    required List<TaskEntity> super.argument,
  }) : super(
         retry: null,
         name: r'todayTasksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$todayTasksHash();

  @override
  String toString() {
    return r'todayTasksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<TaskEntity>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<TaskEntity> create(Ref ref) {
    final argument = this.argument as List<TaskEntity>;
    return todayTasks(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TaskEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TaskEntity>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TodayTasksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$todayTasksHash() => r'77462d367a0167592ec76526a6babeb122ef08d6';

/// 오늘의 태스크 계산 (캐싱)

final class TodayTasksFamily extends $Family
    with $FunctionalFamilyOverride<List<TaskEntity>, List<TaskEntity>> {
  const TodayTasksFamily._()
    : super(
        retry: null,
        name: r'todayTasksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 오늘의 태스크 계산 (캐싱)

  TodayTasksProvider call(List<TaskEntity> filteredTasks) =>
      TodayTasksProvider._(argument: filteredTasks, from: this);

  @override
  String toString() => r'todayTasksProvider';
}

/// 오늘의 이벤트 계산 (캐싱)

@ProviderFor(todayEvents)
const todayEventsProvider = TodayEventsFamily._();

/// 오늘의 이벤트 계산 (캐싱)

final class TodayEventsProvider
    extends
        $FunctionalProvider<
          List<EventEntity>,
          List<EventEntity>,
          List<EventEntity>
        >
    with $Provider<List<EventEntity>> {
  /// 오늘의 이벤트 계산 (캐싱)
  const TodayEventsProvider._({
    required TodayEventsFamily super.from,
    required List<EventEntity> super.argument,
  }) : super(
         retry: null,
         name: r'todayEventsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$todayEventsHash();

  @override
  String toString() {
    return r'todayEventsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<EventEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<EventEntity> create(Ref ref) {
    final argument = this.argument as List<EventEntity>;
    return todayEvents(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<EventEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<EventEntity>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TodayEventsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$todayEventsHash() => r'ae91d24acbe60755f672d9212afb006470a4a193';

/// 오늘의 이벤트 계산 (캐싱)

final class TodayEventsFamily extends $Family
    with $FunctionalFamilyOverride<List<EventEntity>, List<EventEntity>> {
  const TodayEventsFamily._()
    : super(
        retry: null,
        name: r'todayEventsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 오늘의 이벤트 계산 (캐싱)

  TodayEventsProvider call(List<EventEntity> events) =>
      TodayEventsProvider._(argument: events, from: this);

  @override
  String toString() => r'todayEventsProvider';
}

/// 지연된 태스크 계산 (캐싱)

@ProviderFor(overdueTasks)
const overdueTasksProvider = OverdueTasksFamily._();

/// 지연된 태스크 계산 (캐싱)

final class OverdueTasksProvider
    extends
        $FunctionalProvider<
          List<TaskEntity>,
          List<TaskEntity>,
          List<TaskEntity>
        >
    with $Provider<List<TaskEntity>> {
  /// 지연된 태스크 계산 (캐싱)
  const OverdueTasksProvider._({
    required OverdueTasksFamily super.from,
    required List<TaskEntity> super.argument,
  }) : super(
         retry: null,
         name: r'overdueTasksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$overdueTasksHash();

  @override
  String toString() {
    return r'overdueTasksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<TaskEntity>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<TaskEntity> create(Ref ref) {
    final argument = this.argument as List<TaskEntity>;
    return overdueTasks(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<TaskEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<TaskEntity>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OverdueTasksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$overdueTasksHash() => r'ebfcb3d54aaaf73d0dca004d3592054a6c8afbfa';

/// 지연된 태스크 계산 (캐싱)

final class OverdueTasksFamily extends $Family
    with $FunctionalFamilyOverride<List<TaskEntity>, List<TaskEntity>> {
  const OverdueTasksFamily._()
    : super(
        retry: null,
        name: r'overdueTasksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 지연된 태스크 계산 (캐싱)

  OverdueTasksProvider call(List<TaskEntity> filteredTasks) =>
      OverdueTasksProvider._(argument: filteredTasks, from: this);

  @override
  String toString() => r'overdueTasksProvider';
}

/// 이벤트-태스크 매핑 (캐싱)

@ProviderFor(eventToTaskMap)
const eventToTaskMapProvider = EventToTaskMapFamily._();

/// 이벤트-태스크 매핑 (캐싱)

final class EventToTaskMapProvider
    extends
        $FunctionalProvider<
          Map<String, TaskEntity>,
          Map<String, TaskEntity>,
          Map<String, TaskEntity>
        >
    with $Provider<Map<String, TaskEntity>> {
  /// 이벤트-태스크 매핑 (캐싱)
  const EventToTaskMapProvider._({
    required EventToTaskMapFamily super.from,
    required List<TaskEntity> super.argument,
  }) : super(
         retry: null,
         name: r'eventToTaskMapProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventToTaskMapHash();

  @override
  String toString() {
    return r'eventToTaskMapProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Map<String, TaskEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, TaskEntity> create(Ref ref) {
    final argument = this.argument as List<TaskEntity>;
    return eventToTaskMap(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, TaskEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, TaskEntity>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventToTaskMapProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventToTaskMapHash() => r'fe63c2c91dd0af0174006933eeda4994eedc2945';

/// 이벤트-태스크 매핑 (캐싱)

final class EventToTaskMapFamily extends $Family
    with $FunctionalFamilyOverride<Map<String, TaskEntity>, List<TaskEntity>> {
  const EventToTaskMapFamily._()
    : super(
        retry: null,
        name: r'eventToTaskMapProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 이벤트-태스크 매핑 (캐싱)

  EventToTaskMapProvider call(List<TaskEntity> tasks) =>
      EventToTaskMapProvider._(argument: tasks, from: this);

  @override
  String toString() => r'eventToTaskMapProvider';
}

/// 오늘의 다음 일정 아이템 계산 (캐싱) - Color는 위젯에서 설정

@ProviderFor(todayUpcomingItems)
const todayUpcomingItemsProvider = TodayUpcomingItemsFamily._();

/// 오늘의 다음 일정 아이템 계산 (캐싱) - Color는 위젯에서 설정

final class TodayUpcomingItemsProvider
    extends
        $FunctionalProvider<
          List<UpcomingItem>,
          List<UpcomingItem>,
          List<UpcomingItem>
        >
    with $Provider<List<UpcomingItem>> {
  /// 오늘의 다음 일정 아이템 계산 (캐싱) - Color는 위젯에서 설정
  const TodayUpcomingItemsProvider._({
    required TodayUpcomingItemsFamily super.from,
    required (
      List<EventEntity>,
      List<TaskEntity>,
      Map<String, TaskEntity>,
      List<ProjectEntityWithDepth>,
    )
    super.argument,
  }) : super(
         retry: null,
         name: r'todayUpcomingItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$todayUpcomingItemsHash();

  @override
  String toString() {
    return r'todayUpcomingItemsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<List<UpcomingItem>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<UpcomingItem> create(Ref ref) {
    final argument =
        this.argument
            as (
              List<EventEntity>,
              List<TaskEntity>,
              Map<String, TaskEntity>,
              List<ProjectEntityWithDepth>,
            );
    return todayUpcomingItems(
      ref,
      argument.$1,
      argument.$2,
      argument.$3,
      argument.$4,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<UpcomingItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<UpcomingItem>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TodayUpcomingItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$todayUpcomingItemsHash() =>
    r'4e1edc98f451c5606d6aabbbbbb77178b927f64c';

/// 오늘의 다음 일정 아이템 계산 (캐싱) - Color는 위젯에서 설정

final class TodayUpcomingItemsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          List<UpcomingItem>,
          (
            List<EventEntity>,
            List<TaskEntity>,
            Map<String, TaskEntity>,
            List<ProjectEntityWithDepth>,
          )
        > {
  const TodayUpcomingItemsFamily._()
    : super(
        retry: null,
        name: r'todayUpcomingItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 오늘의 다음 일정 아이템 계산 (캐싱) - Color는 위젯에서 설정

  TodayUpcomingItemsProvider call(
    List<EventEntity> todayEvents,
    List<TaskEntity> todayTasks,
    Map<String, TaskEntity> eventToTaskMap,
    List<ProjectEntityWithDepth> projects,
  ) => TodayUpcomingItemsProvider._(
    argument: (todayEvents, todayTasks, eventToTaskMap, projects),
    from: this,
  );

  @override
  String toString() => r'todayUpcomingItemsProvider';
}

/// 미래 일정 아이템 계산 (캐싱) - Color는 위젯에서 설정

@ProviderFor(futureUpcomingItems)
const futureUpcomingItemsProvider = FutureUpcomingItemsFamily._();

/// 미래 일정 아이템 계산 (캐싱) - Color는 위젯에서 설정

final class FutureUpcomingItemsProvider
    extends
        $FunctionalProvider<
          List<UpcomingItem>,
          List<UpcomingItem>,
          List<UpcomingItem>
        >
    with $Provider<List<UpcomingItem>> {
  /// 미래 일정 아이템 계산 (캐싱) - Color는 위젯에서 설정
  const FutureUpcomingItemsProvider._({
    required FutureUpcomingItemsFamily super.from,
    required (
      List<EventEntity>,
      List<TaskEntity>,
      Map<String, TaskEntity>,
      List<ProjectEntityWithDepth>,
    )
    super.argument,
  }) : super(
         retry: null,
         name: r'futureUpcomingItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$futureUpcomingItemsHash();

  @override
  String toString() {
    return r'futureUpcomingItemsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<List<UpcomingItem>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<UpcomingItem> create(Ref ref) {
    final argument =
        this.argument
            as (
              List<EventEntity>,
              List<TaskEntity>,
              Map<String, TaskEntity>,
              List<ProjectEntityWithDepth>,
            );
    return futureUpcomingItems(
      ref,
      argument.$1,
      argument.$2,
      argument.$3,
      argument.$4,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<UpcomingItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<UpcomingItem>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FutureUpcomingItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$futureUpcomingItemsHash() =>
    r'58f5095bd1b7b03a045faa28c0fa8b7e08497a08';

/// 미래 일정 아이템 계산 (캐싱) - Color는 위젯에서 설정

final class FutureUpcomingItemsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          List<UpcomingItem>,
          (
            List<EventEntity>,
            List<TaskEntity>,
            Map<String, TaskEntity>,
            List<ProjectEntityWithDepth>,
          )
        > {
  const FutureUpcomingItemsFamily._()
    : super(
        retry: null,
        name: r'futureUpcomingItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 미래 일정 아이템 계산 (캐싱) - Color는 위젯에서 설정

  FutureUpcomingItemsProvider call(
    List<EventEntity> events,
    List<TaskEntity> tasks,
    Map<String, TaskEntity> eventToTaskMap,
    List<ProjectEntityWithDepth> projects,
  ) => FutureUpcomingItemsProvider._(
    argument: (events, tasks, eventToTaskMap, projects),
    from: this,
  );

  @override
  String toString() => r'futureUpcomingItemsProvider';
}

/// 다음 일정 아이템 (오늘 우선, 없으면 미래 일정)

@ProviderFor(nextItem)
const nextItemProvider = NextItemFamily._();

/// 다음 일정 아이템 (오늘 우선, 없으면 미래 일정)

final class NextItemProvider
    extends $FunctionalProvider<UpcomingItem?, UpcomingItem?, UpcomingItem?>
    with $Provider<UpcomingItem?> {
  /// 다음 일정 아이템 (오늘 우선, 없으면 미래 일정)
  const NextItemProvider._({
    required NextItemFamily super.from,
    required (List<UpcomingItem>, List<UpcomingItem>) super.argument,
  }) : super(
         retry: null,
         name: r'nextItemProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nextItemHash();

  @override
  String toString() {
    return r'nextItemProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<UpcomingItem?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpcomingItem? create(Ref ref) {
    final argument = this.argument as (List<UpcomingItem>, List<UpcomingItem>);
    return nextItem(ref, argument.$1, argument.$2);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpcomingItem? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpcomingItem?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NextItemProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nextItemHash() => r'546cefa92184a4104ae08d942b407933f9aae084';

/// 다음 일정 아이템 (오늘 우선, 없으면 미래 일정)

final class NextItemFamily extends $Family
    with
        $FunctionalFamilyOverride<
          UpcomingItem?,
          (List<UpcomingItem>, List<UpcomingItem>)
        > {
  const NextItemFamily._()
    : super(
        retry: null,
        name: r'nextItemProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 다음 일정 아이템 (오늘 우선, 없으면 미래 일정)

  NextItemProvider call(
    List<UpcomingItem> todayUpcomingItems,
    List<UpcomingItem> futureUpcomingItems,
  ) => NextItemProvider._(
    argument: (todayUpcomingItems, futureUpcomingItems),
    from: this,
  );

  @override
  String toString() => r'nextItemProvider';
}

/// 지연된 태스크를 대시보드 아이템으로 변환 (캐싱)

@ProviderFor(overdueDashboardItems)
const overdueDashboardItemsProvider = OverdueDashboardItemsFamily._();

/// 지연된 태스크를 대시보드 아이템으로 변환 (캐싱)

final class OverdueDashboardItemsProvider
    extends
        $FunctionalProvider<
          List<DashboardItem>,
          List<DashboardItem>,
          List<DashboardItem>
        >
    with $Provider<List<DashboardItem>> {
  /// 지연된 태스크를 대시보드 아이템으로 변환 (캐싱)
  const OverdueDashboardItemsProvider._({
    required OverdueDashboardItemsFamily super.from,
    required (List<TaskEntity>, List<ProjectEntityWithDepth>, String)
    super.argument,
  }) : super(
         retry: null,
         name: r'overdueDashboardItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$overdueDashboardItemsHash();

  @override
  String toString() {
    return r'overdueDashboardItemsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<List<DashboardItem>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<DashboardItem> create(Ref ref) {
    final argument =
        this.argument
            as (List<TaskEntity>, List<ProjectEntityWithDepth>, String);
    return overdueDashboardItems(ref, argument.$1, argument.$2, argument.$3);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<DashboardItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<DashboardItem>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OverdueDashboardItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$overdueDashboardItemsHash() =>
    r'3852604e5c73f04c1b853925ca9371a569d5417f';

/// 지연된 태스크를 대시보드 아이템으로 변환 (캐싱)

final class OverdueDashboardItemsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          List<DashboardItem>,
          (List<TaskEntity>, List<ProjectEntityWithDepth>, String)
        > {
  const OverdueDashboardItemsFamily._()
    : super(
        retry: null,
        name: r'overdueDashboardItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 지연된 태스크를 대시보드 아이템으로 변환 (캐싱)

  OverdueDashboardItemsProvider call(
    List<TaskEntity> overdueTasks,
    List<ProjectEntityWithDepth> projects,
    String overdueTaskSubtitle,
  ) => OverdueDashboardItemsProvider._(
    argument: (overdueTasks, projects, overdueTaskSubtitle),
    from: this,
  );

  @override
  String toString() => r'overdueDashboardItemsProvider';
}

/// 인박스를 이유별로 그룹화 (캐싱)

@ProviderFor(inboxesByReason)
const inboxesByReasonProvider = InboxesByReasonFamily._();

/// 인박스를 이유별로 그룹화 (캐싱)

final class InboxesByReasonProvider
    extends
        $FunctionalProvider<
          Map<InboxSuggestionReason, List<InboxEntity>>,
          Map<InboxSuggestionReason, List<InboxEntity>>,
          Map<InboxSuggestionReason, List<InboxEntity>>
        >
    with $Provider<Map<InboxSuggestionReason, List<InboxEntity>>> {
  /// 인박스를 이유별로 그룹화 (캐싱)
  const InboxesByReasonProvider._({
    required InboxesByReasonFamily super.from,
    required List<InboxEntity> super.argument,
  }) : super(
         retry: null,
         name: r'inboxesByReasonProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$inboxesByReasonHash();

  @override
  String toString() {
    return r'inboxesByReasonProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Map<InboxSuggestionReason, List<InboxEntity>>>
  $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  Map<InboxSuggestionReason, List<InboxEntity>> create(Ref ref) {
    final argument = this.argument as List<InboxEntity>;
    return inboxesByReason(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    Map<InboxSuggestionReason, List<InboxEntity>> value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<Map<InboxSuggestionReason, List<InboxEntity>>>(
            value,
          ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is InboxesByReasonProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$inboxesByReasonHash() => r'5cebbbcb591b19c6d555b283a9b5e8bb5f15268f';

/// 인박스를 이유별로 그룹화 (캐싱)

final class InboxesByReasonFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Map<InboxSuggestionReason, List<InboxEntity>>,
          List<InboxEntity>
        > {
  const InboxesByReasonFamily._()
    : super(
        retry: null,
        name: r'inboxesByReasonProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 인박스를 이유별로 그룹화 (캐싱)

  InboxesByReasonProvider call(List<InboxEntity> filteredInboxes) =>
      InboxesByReasonProvider._(argument: filteredInboxes, from: this);

  @override
  String toString() => r'inboxesByReasonProvider';
}

/// 정렬된 이유 목록 (캐싱)

@ProviderFor(sortedReasons)
const sortedReasonsProvider = SortedReasonsFamily._();

/// 정렬된 이유 목록 (캐싱)

final class SortedReasonsProvider
    extends
        $FunctionalProvider<
          List<InboxSuggestionReason>,
          List<InboxSuggestionReason>,
          List<InboxSuggestionReason>
        >
    with $Provider<List<InboxSuggestionReason>> {
  /// 정렬된 이유 목록 (캐싱)
  const SortedReasonsProvider._({
    required SortedReasonsFamily super.from,
    required Map<InboxSuggestionReason, List<InboxEntity>> super.argument,
  }) : super(
         retry: null,
         name: r'sortedReasonsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sortedReasonsHash();

  @override
  String toString() {
    return r'sortedReasonsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<List<InboxSuggestionReason>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<InboxSuggestionReason> create(Ref ref) {
    final argument =
        this.argument as Map<InboxSuggestionReason, List<InboxEntity>>;
    return sortedReasons(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<InboxSuggestionReason> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<InboxSuggestionReason>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SortedReasonsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sortedReasonsHash() => r'fb6efbf4b5772c2acdbd8f4e7d6d1890bbc3f054';

/// 정렬된 이유 목록 (캐싱)

final class SortedReasonsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          List<InboxSuggestionReason>,
          Map<InboxSuggestionReason, List<InboxEntity>>
        > {
  const SortedReasonsFamily._()
    : super(
        retry: null,
        name: r'sortedReasonsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 정렬된 이유 목록 (캐싱)

  SortedReasonsProvider call(
    Map<InboxSuggestionReason, List<InboxEntity>> inboxesByReason,
  ) => SortedReasonsProvider._(argument: inboxesByReason, from: this);

  @override
  String toString() => r'sortedReasonsProvider';
}
