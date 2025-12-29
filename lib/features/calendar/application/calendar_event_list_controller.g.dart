// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_event_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CalendarEventListController)
const calendarEventListControllerProvider =
    CalendarEventListControllerFamily._();

final class CalendarEventListControllerProvider
    extends
        $NotifierProvider<
          CalendarEventListController,
          CalendarEventResultEntity
        > {
  const CalendarEventListControllerProvider._({
    required CalendarEventListControllerFamily super.from,
    required ({TabType tabType, CalendarDisplayType displayType})
    super.argument,
  }) : super(
         retry: null,
         name: r'calendarEventListControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$calendarEventListControllerHash();

  @override
  String toString() {
    return r'calendarEventListControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  CalendarEventListController create() => CalendarEventListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalendarEventResultEntity value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalendarEventResultEntity>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarEventListControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$calendarEventListControllerHash() =>
    r'7e7ddac7e4f1481077b2b8d400ff8a72e44cc993';

final class CalendarEventListControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          CalendarEventListController,
          CalendarEventResultEntity,
          CalendarEventResultEntity,
          CalendarEventResultEntity,
          ({TabType tabType, CalendarDisplayType displayType})
        > {
  const CalendarEventListControllerFamily._()
    : super(
        retry: null,
        name: r'calendarEventListControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CalendarEventListControllerProvider call({
    required TabType tabType,
    CalendarDisplayType displayType = CalendarDisplayType.main,
  }) => CalendarEventListControllerProvider._(
    argument: (tabType: tabType, displayType: displayType),
    from: this,
  );

  @override
  String toString() => r'calendarEventListControllerProvider';
}

abstract class _$CalendarEventListController
    extends $Notifier<CalendarEventResultEntity> {
  late final _$args =
      ref.$arg as ({TabType tabType, CalendarDisplayType displayType});
  TabType get tabType => _$args.tabType;
  CalendarDisplayType get displayType => _$args.displayType;

  CalendarEventResultEntity build({
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
        this.ref as $Ref<CalendarEventResultEntity, CalendarEventResultEntity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CalendarEventResultEntity, CalendarEventResultEntity>,
              CalendarEventResultEntity,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(CalendarEventListControllerInternal)
const calendarEventListControllerInternalProvider =
    CalendarEventListControllerInternalFamily._();

final class CalendarEventListControllerInternalProvider
    extends
        $AsyncNotifierProvider<
          CalendarEventListControllerInternal,
          List<EventEntity>
        > {
  const CalendarEventListControllerInternalProvider._({
    required CalendarEventListControllerInternalFamily super.from,
    required ({
      bool isSignedIn,
      String oAuthUniqueId,
      int targetYear,
      int targetMonth,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'calendarEventListControllerInternalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$calendarEventListControllerInternalHash();

  @override
  String toString() {
    return r'calendarEventListControllerInternalProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  CalendarEventListControllerInternal create() =>
      CalendarEventListControllerInternal();

  @override
  bool operator ==(Object other) {
    return other is CalendarEventListControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$calendarEventListControllerInternalHash() =>
    r'e99f28c584e06088f37c26d0b23011ee44e58646';

final class CalendarEventListControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          CalendarEventListControllerInternal,
          AsyncValue<List<EventEntity>>,
          List<EventEntity>,
          FutureOr<List<EventEntity>>,
          ({
            bool isSignedIn,
            String oAuthUniqueId,
            int targetYear,
            int targetMonth,
          })
        > {
  const CalendarEventListControllerInternalFamily._()
    : super(
        retry: null,
        name: r'calendarEventListControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CalendarEventListControllerInternalProvider call({
    required bool isSignedIn,
    required String oAuthUniqueId,
    required int targetYear,
    required int targetMonth,
  }) => CalendarEventListControllerInternalProvider._(
    argument: (
      isSignedIn: isSignedIn,
      oAuthUniqueId: oAuthUniqueId,
      targetYear: targetYear,
      targetMonth: targetMonth,
    ),
    from: this,
  );

  @override
  String toString() => r'calendarEventListControllerInternalProvider';
}

abstract class _$CalendarEventListControllerInternal
    extends $AsyncNotifier<List<EventEntity>> {
  late final _$args =
      ref.$arg
          as ({
            bool isSignedIn,
            String oAuthUniqueId,
            int targetYear,
            int targetMonth,
          });
  bool get isSignedIn => _$args.isSignedIn;
  String get oAuthUniqueId => _$args.oAuthUniqueId;
  int get targetYear => _$args.targetYear;
  int get targetMonth => _$args.targetMonth;

  FutureOr<List<EventEntity>> build({
    required bool isSignedIn,
    required String oAuthUniqueId,
    required int targetYear,
    required int targetMonth,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      isSignedIn: _$args.isSignedIn,
      oAuthUniqueId: _$args.oAuthUniqueId,
      targetYear: _$args.targetYear,
      targetMonth: _$args.targetMonth,
    );
    final ref =
        this.ref as $Ref<AsyncValue<List<EventEntity>>, List<EventEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<EventEntity>>, List<EventEntity>>,
              AsyncValue<List<EventEntity>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
