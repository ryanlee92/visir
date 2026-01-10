// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_task_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CalendarTaskListController)
const calendarTaskListControllerProvider = CalendarTaskListControllerFamily._();

final class CalendarTaskListControllerProvider
    extends
        $NotifierProvider<
          CalendarTaskListController,
          CalendarTaskResultEntity
        > {
  const CalendarTaskListControllerProvider._({
    required CalendarTaskListControllerFamily super.from,
    required ({TabType tabType, CalendarDisplayType displayType})
    super.argument,
  }) : super(
         retry: null,
         name: r'calendarTaskListControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$calendarTaskListControllerHash();

  @override
  String toString() {
    return r'calendarTaskListControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  CalendarTaskListController create() => CalendarTaskListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalendarTaskResultEntity value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalendarTaskResultEntity>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarTaskListControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$calendarTaskListControllerHash() =>
    r'1118ba71282536c8e847556acbb5fa3e4676fe2c';

final class CalendarTaskListControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          CalendarTaskListController,
          CalendarTaskResultEntity,
          CalendarTaskResultEntity,
          CalendarTaskResultEntity,
          ({TabType tabType, CalendarDisplayType displayType})
        > {
  const CalendarTaskListControllerFamily._()
    : super(
        retry: null,
        name: r'calendarTaskListControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CalendarTaskListControllerProvider call({
    required TabType tabType,
    CalendarDisplayType displayType = CalendarDisplayType.main,
  }) => CalendarTaskListControllerProvider._(
    argument: (tabType: tabType, displayType: displayType),
    from: this,
  );

  @override
  String toString() => r'calendarTaskListControllerProvider';
}

abstract class _$CalendarTaskListController
    extends $Notifier<CalendarTaskResultEntity> {
  late final _$args =
      ref.$arg as ({TabType tabType, CalendarDisplayType displayType});
  TabType get tabType => _$args.tabType;
  CalendarDisplayType get displayType => _$args.displayType;

  CalendarTaskResultEntity build({
    required TabType tabType,
    CalendarDisplayType displayType = CalendarDisplayType.main,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      tabType: _$args.tabType,
      displayType: _$args.displayType,
    );
    final ref =
        this.ref as $Ref<CalendarTaskResultEntity, CalendarTaskResultEntity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CalendarTaskResultEntity, CalendarTaskResultEntity>,
              CalendarTaskResultEntity,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(CalendarTaskListControllerInternal)
const calendarTaskListControllerInternalProvider =
    CalendarTaskListControllerInternalFamily._();

final class CalendarTaskListControllerInternalProvider
    extends
        $AsyncNotifierProvider<
          CalendarTaskListControllerInternal,
          List<TaskEntity>
        > {
  const CalendarTaskListControllerInternalProvider._({
    required CalendarTaskListControllerInternalFamily super.from,
    required ({bool isSignedIn, int targetYear, int targetMonth})
    super.argument,
  }) : super(
         retry: null,
         name: r'calendarTaskListControllerInternalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$calendarTaskListControllerInternalHash();

  @override
  String toString() {
    return r'calendarTaskListControllerInternalProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  CalendarTaskListControllerInternal create() =>
      CalendarTaskListControllerInternal();

  @override
  bool operator ==(Object other) {
    return other is CalendarTaskListControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$calendarTaskListControllerInternalHash() =>
    r'f88b2b85b0f67a4b0abcf9bf0685857607788345';

final class CalendarTaskListControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          CalendarTaskListControllerInternal,
          AsyncValue<List<TaskEntity>>,
          List<TaskEntity>,
          FutureOr<List<TaskEntity>>,
          ({bool isSignedIn, int targetYear, int targetMonth})
        > {
  const CalendarTaskListControllerInternalFamily._()
    : super(
        retry: null,
        name: r'calendarTaskListControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CalendarTaskListControllerInternalProvider call({
    required bool isSignedIn,
    required int targetYear,
    required int targetMonth,
  }) => CalendarTaskListControllerInternalProvider._(
    argument: (
      isSignedIn: isSignedIn,
      targetYear: targetYear,
      targetMonth: targetMonth,
    ),
    from: this,
  );

  @override
  String toString() => r'calendarTaskListControllerInternalProvider';
}

abstract class _$CalendarTaskListControllerInternal
    extends $AsyncNotifier<List<TaskEntity>> {
  late final _$args =
      ref.$arg as ({bool isSignedIn, int targetYear, int targetMonth});
  bool get isSignedIn => _$args.isSignedIn;
  int get targetYear => _$args.targetYear;
  int get targetMonth => _$args.targetMonth;

  FutureOr<List<TaskEntity>> build({
    required bool isSignedIn,
    required int targetYear,
    required int targetMonth,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      isSignedIn: _$args.isSignedIn,
      targetYear: _$args.targetYear,
      targetMonth: _$args.targetMonth,
    );
    final ref =
        this.ref as $Ref<AsyncValue<List<TaskEntity>>, List<TaskEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<TaskEntity>>, List<TaskEntity>>,
              AsyncValue<List<TaskEntity>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
