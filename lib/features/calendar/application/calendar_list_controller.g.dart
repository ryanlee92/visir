// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CalendarListController)
const calendarListControllerProvider = CalendarListControllerProvider._();

final class CalendarListControllerProvider
    extends
        $NotifierProvider<
          CalendarListController,
          Map<String, List<CalendarEntity>>
        > {
  const CalendarListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarListControllerHash();

  @$internal
  @override
  CalendarListController create() => CalendarListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, List<CalendarEntity>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, List<CalendarEntity>>>(
        value,
      ),
    );
  }
}

String _$calendarListControllerHash() =>
    r'f628cfd8b43d5c4666a52bbbeff59aa77f75b08d';

abstract class _$CalendarListController
    extends $Notifier<Map<String, List<CalendarEntity>>> {
  Map<String, List<CalendarEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              Map<String, List<CalendarEntity>>,
              Map<String, List<CalendarEntity>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, List<CalendarEntity>>,
                Map<String, List<CalendarEntity>>
              >,
              Map<String, List<CalendarEntity>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(CalendarListControllerInternal)
const calendarListControllerInternalProvider =
    CalendarListControllerInternalFamily._();

final class CalendarListControllerInternalProvider
    extends
        $AsyncNotifierProvider<
          CalendarListControllerInternal,
          Map<String, List<CalendarEntity>>
        > {
  const CalendarListControllerInternalProvider._({
    required CalendarListControllerInternalFamily super.from,
    required ({bool isSignedIn, String oAuthUniqueId}) super.argument,
  }) : super(
         retry: null,
         name: r'calendarListControllerInternalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$calendarListControllerInternalHash();

  @override
  String toString() {
    return r'calendarListControllerInternalProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  CalendarListControllerInternal create() => CalendarListControllerInternal();

  @override
  bool operator ==(Object other) {
    return other is CalendarListControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$calendarListControllerInternalHash() =>
    r'98f421daa81ef7035324693781c8bf2127d36f55';

final class CalendarListControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          CalendarListControllerInternal,
          AsyncValue<Map<String, List<CalendarEntity>>>,
          Map<String, List<CalendarEntity>>,
          FutureOr<Map<String, List<CalendarEntity>>>,
          ({bool isSignedIn, String oAuthUniqueId})
        > {
  const CalendarListControllerInternalFamily._()
    : super(
        retry: null,
        name: r'calendarListControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CalendarListControllerInternalProvider call({
    required bool isSignedIn,
    required String oAuthUniqueId,
  }) => CalendarListControllerInternalProvider._(
    argument: (isSignedIn: isSignedIn, oAuthUniqueId: oAuthUniqueId),
    from: this,
  );

  @override
  String toString() => r'calendarListControllerInternalProvider';
}

abstract class _$CalendarListControllerInternal
    extends $AsyncNotifier<Map<String, List<CalendarEntity>>> {
  late final _$args = ref.$arg as ({bool isSignedIn, String oAuthUniqueId});
  bool get isSignedIn => _$args.isSignedIn;
  String get oAuthUniqueId => _$args.oAuthUniqueId;

  FutureOr<Map<String, List<CalendarEntity>>> build({
    required bool isSignedIn,
    required String oAuthUniqueId,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      isSignedIn: _$args.isSignedIn,
      oAuthUniqueId: _$args.oAuthUniqueId,
    );
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Map<String, List<CalendarEntity>>>,
              Map<String, List<CalendarEntity>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<String, List<CalendarEntity>>>,
                Map<String, List<CalendarEntity>>
              >,
              AsyncValue<Map<String, List<CalendarEntity>>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
