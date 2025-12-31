// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_saved_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TimeSavedListControllerInternal)
const timeSavedListControllerInternalProvider =
    TimeSavedListControllerInternalFamily._();

final class TimeSavedListControllerInternalProvider
    extends
        $AsyncNotifierProvider<
          TimeSavedListControllerInternal,
          Map<DateTime, List<UserActionSwitchCountEntity>>
        > {
  const TimeSavedListControllerInternalProvider._({
    required TimeSavedListControllerInternalFamily super.from,
    required ({TimeSavedViewType viewType, bool isSignedIn}) super.argument,
  }) : super(
         retry: null,
         name: r'timeSavedListControllerInternalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$timeSavedListControllerInternalHash();

  @override
  String toString() {
    return r'timeSavedListControllerInternalProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  TimeSavedListControllerInternal create() => TimeSavedListControllerInternal();

  @override
  bool operator ==(Object other) {
    return other is TimeSavedListControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$timeSavedListControllerInternalHash() =>
    r'3f12c4dc177fe2c9483d4ff12fb70ab994752fcf';

final class TimeSavedListControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          TimeSavedListControllerInternal,
          AsyncValue<Map<DateTime, List<UserActionSwitchCountEntity>>>,
          Map<DateTime, List<UserActionSwitchCountEntity>>,
          FutureOr<Map<DateTime, List<UserActionSwitchCountEntity>>>,
          ({TimeSavedViewType viewType, bool isSignedIn})
        > {
  const TimeSavedListControllerInternalFamily._()
    : super(
        retry: null,
        name: r'timeSavedListControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TimeSavedListControllerInternalProvider call({
    required TimeSavedViewType viewType,
    required bool isSignedIn,
  }) => TimeSavedListControllerInternalProvider._(
    argument: (viewType: viewType, isSignedIn: isSignedIn),
    from: this,
  );

  @override
  String toString() => r'timeSavedListControllerInternalProvider';
}

abstract class _$TimeSavedListControllerInternal
    extends $AsyncNotifier<Map<DateTime, List<UserActionSwitchCountEntity>>> {
  late final _$args =
      ref.$arg as ({TimeSavedViewType viewType, bool isSignedIn});
  TimeSavedViewType get viewType => _$args.viewType;
  bool get isSignedIn => _$args.isSignedIn;

  FutureOr<Map<DateTime, List<UserActionSwitchCountEntity>>> build({
    required TimeSavedViewType viewType,
    required bool isSignedIn,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      viewType: _$args.viewType,
      isSignedIn: _$args.isSignedIn,
    );
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Map<DateTime, List<UserActionSwitchCountEntity>>>,
              Map<DateTime, List<UserActionSwitchCountEntity>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<DateTime, List<UserActionSwitchCountEntity>>>,
                Map<DateTime, List<UserActionSwitchCountEntity>>
              >,
              AsyncValue<Map<DateTime, List<UserActionSwitchCountEntity>>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
