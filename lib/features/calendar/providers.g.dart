// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(supabaseCalendarDatasource)
const supabaseCalendarDatasourceProvider =
    SupabaseCalendarDatasourceProvider._();

final class SupabaseCalendarDatasourceProvider
    extends
        $FunctionalProvider<
          SupabaseCalendarDatasource,
          SupabaseCalendarDatasource,
          SupabaseCalendarDatasource
        >
    with $Provider<SupabaseCalendarDatasource> {
  const SupabaseCalendarDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supabaseCalendarDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supabaseCalendarDatasourceHash();

  @$internal
  @override
  $ProviderElement<SupabaseCalendarDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SupabaseCalendarDatasource create(Ref ref) {
    return supabaseCalendarDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseCalendarDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabaseCalendarDatasource>(value),
    );
  }
}

String _$supabaseCalendarDatasourceHash() =>
    r'a17c7cc008ccda063fe92214af9ffbe048b2230b';

@ProviderFor(googleCalendarDatasource)
const googleCalendarDatasourceProvider = GoogleCalendarDatasourceProvider._();

final class GoogleCalendarDatasourceProvider
    extends
        $FunctionalProvider<
          GoogleCalendarDatasource,
          GoogleCalendarDatasource,
          GoogleCalendarDatasource
        >
    with $Provider<GoogleCalendarDatasource> {
  const GoogleCalendarDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'googleCalendarDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$googleCalendarDatasourceHash();

  @$internal
  @override
  $ProviderElement<GoogleCalendarDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GoogleCalendarDatasource create(Ref ref) {
    return googleCalendarDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoogleCalendarDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoogleCalendarDatasource>(value),
    );
  }
}

String _$googleCalendarDatasourceHash() =>
    r'1bda825429afb13d4e0acc74645a6ad98b19b475';

@ProviderFor(microsoftCalendarDatasource)
const microsoftCalendarDatasourceProvider =
    MicrosoftCalendarDatasourceProvider._();

final class MicrosoftCalendarDatasourceProvider
    extends
        $FunctionalProvider<
          MicrosoftCalendarDatasource,
          MicrosoftCalendarDatasource,
          MicrosoftCalendarDatasource
        >
    with $Provider<MicrosoftCalendarDatasource> {
  const MicrosoftCalendarDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'microsoftCalendarDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$microsoftCalendarDatasourceHash();

  @$internal
  @override
  $ProviderElement<MicrosoftCalendarDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MicrosoftCalendarDatasource create(Ref ref) {
    return microsoftCalendarDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MicrosoftCalendarDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MicrosoftCalendarDatasource>(value),
    );
  }
}

String _$microsoftCalendarDatasourceHash() =>
    r'a22af4f9b827a8226f4df2faff39010eb506363d';

@ProviderFor(calendarRepository)
const calendarRepositoryProvider = CalendarRepositoryProvider._();

final class CalendarRepositoryProvider
    extends
        $FunctionalProvider<
          CalendarRepository,
          CalendarRepository,
          CalendarRepository
        >
    with $Provider<CalendarRepository> {
  const CalendarRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarRepositoryHash();

  @$internal
  @override
  $ProviderElement<CalendarRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CalendarRepository create(Ref ref) {
    return calendarRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalendarRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalendarRepository>(value),
    );
  }
}

String _$calendarRepositoryHash() =>
    r'6b65725aa22f008c7dd98a6290f7c8f575709f3b';

@ProviderFor(CalendarDisplayDate)
const calendarDisplayDateProvider = CalendarDisplayDateFamily._();

final class CalendarDisplayDateProvider
    extends
        $NotifierProvider<
          CalendarDisplayDate,
          Map<CalendarDisplayType, DateTime>
        > {
  const CalendarDisplayDateProvider._({
    required CalendarDisplayDateFamily super.from,
    required TabType super.argument,
  }) : super(
         retry: null,
         name: r'calendarDisplayDateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$calendarDisplayDateHash();

  @override
  String toString() {
    return r'calendarDisplayDateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CalendarDisplayDate create() => CalendarDisplayDate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<CalendarDisplayType, DateTime> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<CalendarDisplayType, DateTime>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarDisplayDateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$calendarDisplayDateHash() =>
    r'21cbffb742b971c7c589ac233d47fe6e69491935';

final class CalendarDisplayDateFamily extends $Family
    with
        $ClassFamilyOverride<
          CalendarDisplayDate,
          Map<CalendarDisplayType, DateTime>,
          Map<CalendarDisplayType, DateTime>,
          Map<CalendarDisplayType, DateTime>,
          TabType
        > {
  const CalendarDisplayDateFamily._()
    : super(
        retry: null,
        name: r'calendarDisplayDateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CalendarDisplayDateProvider call(TabType tabType) =>
      CalendarDisplayDateProvider._(argument: tabType, from: this);

  @override
  String toString() => r'calendarDisplayDateProvider';
}

abstract class _$CalendarDisplayDate
    extends $Notifier<Map<CalendarDisplayType, DateTime>> {
  late final _$args = ref.$arg as TabType;
  TabType get tabType => _$args;

  Map<CalendarDisplayType, DateTime> build(TabType tabType);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<
              Map<CalendarDisplayType, DateTime>,
              Map<CalendarDisplayType, DateTime>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<CalendarDisplayType, DateTime>,
                Map<CalendarDisplayType, DateTime>
              >,
              Map<CalendarDisplayType, DateTime>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(CalendarTargetMonth)
const calendarTargetMonthProvider = CalendarTargetMonthFamily._();

final class CalendarTargetMonthProvider
    extends
        $NotifierProvider<
          CalendarTargetMonth,
          Map<CalendarAppBarType, DateTime>
        > {
  const CalendarTargetMonthProvider._({
    required CalendarTargetMonthFamily super.from,
    required TabType super.argument,
  }) : super(
         retry: null,
         name: r'calendarTargetMonthProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$calendarTargetMonthHash();

  @override
  String toString() {
    return r'calendarTargetMonthProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CalendarTargetMonth create() => CalendarTargetMonth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<CalendarAppBarType, DateTime> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<CalendarAppBarType, DateTime>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarTargetMonthProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$calendarTargetMonthHash() =>
    r'c9433806b81d69cc8b76cecc8b7e5c2f51478646';

final class CalendarTargetMonthFamily extends $Family
    with
        $ClassFamilyOverride<
          CalendarTargetMonth,
          Map<CalendarAppBarType, DateTime>,
          Map<CalendarAppBarType, DateTime>,
          Map<CalendarAppBarType, DateTime>,
          TabType
        > {
  const CalendarTargetMonthFamily._()
    : super(
        retry: null,
        name: r'calendarTargetMonthProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CalendarTargetMonthProvider call(TabType tabType) =>
      CalendarTargetMonthProvider._(argument: tabType, from: this);

  @override
  String toString() => r'calendarTargetMonthProvider';
}

abstract class _$CalendarTargetMonth
    extends $Notifier<Map<CalendarAppBarType, DateTime>> {
  late final _$args = ref.$arg as TabType;
  TabType get tabType => _$args;

  Map<CalendarAppBarType, DateTime> build(TabType tabType);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<
              Map<CalendarAppBarType, DateTime>,
              Map<CalendarAppBarType, DateTime>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<CalendarAppBarType, DateTime>,
                Map<CalendarAppBarType, DateTime>
              >,
              Map<CalendarAppBarType, DateTime>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(CalendarTypeChanger)
const calendarTypeChangerProvider = CalendarTypeChangerFamily._();

final class CalendarTypeChangerProvider
    extends $NotifierProvider<CalendarTypeChanger, CalendarType> {
  const CalendarTypeChangerProvider._({
    required CalendarTypeChangerFamily super.from,
    required TabType super.argument,
  }) : super(
         retry: null,
         name: r'calendarTypeChangerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$calendarTypeChangerHash();

  @override
  String toString() {
    return r'calendarTypeChangerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CalendarTypeChanger create() => CalendarTypeChanger();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalendarType value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalendarType>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarTypeChangerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$calendarTypeChangerHash() =>
    r'58518d950b1404eff2db3016fbf44ab6edb3aa10';

final class CalendarTypeChangerFamily extends $Family
    with
        $ClassFamilyOverride<
          CalendarTypeChanger,
          CalendarType,
          CalendarType,
          CalendarType,
          TabType
        > {
  const CalendarTypeChangerFamily._()
    : super(
        retry: null,
        name: r'calendarTypeChangerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CalendarTypeChangerProvider call(TabType tabType) =>
      CalendarTypeChangerProvider._(argument: tabType, from: this);

  @override
  String toString() => r'calendarTypeChangerProvider';
}

abstract class _$CalendarTypeChanger extends $Notifier<CalendarType> {
  late final _$args = ref.$arg as TabType;
  TabType get tabType => _$args;

  CalendarType build(TabType tabType);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<CalendarType, CalendarType>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CalendarType, CalendarType>,
              CalendarType,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(CalendarHide)
const calendarHideProvider = CalendarHideFamily._();

final class CalendarHideProvider
    extends $NotifierProvider<CalendarHide, List<String>> {
  const CalendarHideProvider._({
    required CalendarHideFamily super.from,
    required TabType super.argument,
  }) : super(
         retry: null,
         name: r'calendarHideProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$calendarHideHash();

  @override
  String toString() {
    return r'calendarHideProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CalendarHide create() => CalendarHide();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarHideProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$calendarHideHash() => r'f64538424f58af034d5a33c7d840134e3cedd877';

final class CalendarHideFamily extends $Family
    with
        $ClassFamilyOverride<
          CalendarHide,
          List<String>,
          List<String>,
          List<String>,
          TabType
        > {
  const CalendarHideFamily._()
    : super(
        retry: null,
        name: r'calendarHideProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CalendarHideProvider call(TabType tabType) =>
      CalendarHideProvider._(argument: tabType, from: this);

  @override
  String toString() => r'calendarHideProvider';
}

abstract class _$CalendarHide extends $Notifier<List<String>> {
  late final _$args = ref.$arg as TabType;
  TabType get tabType => _$args;

  List<String> build(TabType tabType);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(CalendarIntervalScale)
const calendarIntervalScaleProvider = CalendarIntervalScaleFamily._();

final class CalendarIntervalScaleProvider
    extends $NotifierProvider<CalendarIntervalScale, double> {
  const CalendarIntervalScaleProvider._({
    required CalendarIntervalScaleFamily super.from,
    required TabType super.argument,
  }) : super(
         retry: null,
         name: r'calendarIntervalScaleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$calendarIntervalScaleHash();

  @override
  String toString() {
    return r'calendarIntervalScaleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CalendarIntervalScale create() => CalendarIntervalScale();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarIntervalScaleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$calendarIntervalScaleHash() =>
    r'43d9cfd4491347f67722b8d80ff37344bc79f66e';

final class CalendarIntervalScaleFamily extends $Family
    with
        $ClassFamilyOverride<
          CalendarIntervalScale,
          double,
          double,
          double,
          TabType
        > {
  const CalendarIntervalScaleFamily._()
    : super(
        retry: null,
        name: r'calendarIntervalScaleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CalendarIntervalScaleProvider call(TabType tabType) =>
      CalendarIntervalScaleProvider._(argument: tabType, from: this);

  @override
  String toString() => r'calendarIntervalScaleProvider';
}

abstract class _$CalendarIntervalScale extends $Notifier<double> {
  late final _$args = ref.$arg as TabType;
  TabType get tabType => _$args;

  double build(TabType tabType);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ProjectHide)
const projectHideProvider = ProjectHideFamily._();

final class ProjectHideProvider
    extends $NotifierProvider<ProjectHide, List<String>> {
  const ProjectHideProvider._({
    required ProjectHideFamily super.from,
    required TabType super.argument,
  }) : super(
         retry: null,
         name: r'projectHideProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$projectHideHash();

  @override
  String toString() {
    return r'projectHideProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProjectHide create() => ProjectHide();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectHideProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$projectHideHash() => r'a958f7c4378eaa14fde3a58498d4b5094c3e5a07';

final class ProjectHideFamily extends $Family
    with
        $ClassFamilyOverride<
          ProjectHide,
          List<String>,
          List<String>,
          List<String>,
          TabType
        > {
  const ProjectHideFamily._()
    : super(
        retry: null,
        name: r'projectHideProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProjectHideProvider call(TabType tabType) =>
      ProjectHideProvider._(argument: tabType, from: this);

  @override
  String toString() => r'projectHideProvider';
}

abstract class _$ProjectHide extends $Notifier<List<String>> {
  late final _$args = ref.$arg as TabType;
  TabType get tabType => _$args;

  List<String> build(TabType tabType);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(LastUsedCalendarId)
const lastUsedCalendarIdProvider = LastUsedCalendarIdProvider._();

final class LastUsedCalendarIdProvider
    extends $NotifierProvider<LastUsedCalendarId, List<String>> {
  const LastUsedCalendarIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastUsedCalendarIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastUsedCalendarIdHash();

  @$internal
  @override
  LastUsedCalendarId create() => LastUsedCalendarId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$lastUsedCalendarIdHash() =>
    r'3a5c886c508217c318e27232d6e2b35f61c28540';

abstract class _$LastUsedCalendarId extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(LastUsedProjectId)
const lastUsedProjectIdProvider = LastUsedProjectIdProvider._();

final class LastUsedProjectIdProvider
    extends $NotifierProvider<LastUsedProjectId, List<String>> {
  const LastUsedProjectIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastUsedProjectIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastUsedProjectIdHash();

  @$internal
  @override
  LastUsedProjectId create() => LastUsedProjectId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$lastUsedProjectIdHash() => r'0a89fa63ce57c8b877b2e72217bb6275203881f0';

abstract class _$LastUsedProjectId extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
