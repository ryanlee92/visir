// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_action_switch_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TimeSavedViewTypeNotifier)
const timeSavedViewTypeProvider = TimeSavedViewTypeNotifierProvider._();

final class TimeSavedViewTypeNotifierProvider
    extends $NotifierProvider<TimeSavedViewTypeNotifier, TimeSavedViewType> {
  const TimeSavedViewTypeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timeSavedViewTypeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timeSavedViewTypeNotifierHash();

  @$internal
  @override
  TimeSavedViewTypeNotifier create() => TimeSavedViewTypeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TimeSavedViewType value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimeSavedViewType>(value),
    );
  }
}

String _$timeSavedViewTypeNotifierHash() =>
    r'3657b08a6ef62fbed20cf08de862f4786268e3ee';

abstract class _$TimeSavedViewTypeNotifier
    extends $Notifier<TimeSavedViewType> {
  TimeSavedViewType build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TimeSavedViewType, TimeSavedViewType>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TimeSavedViewType, TimeSavedViewType>,
              TimeSavedViewType,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(UserActionSwitchListControllerInternal)
const userActionSwitchListControllerInternalProvider =
    UserActionSwitchListControllerInternalFamily._();

final class UserActionSwitchListControllerInternalProvider
    extends
        $AsyncNotifierProvider<
          UserActionSwitchListControllerInternal,
          List<UserActionSwitchCountEntity>
        > {
  const UserActionSwitchListControllerInternalProvider._({
    required UserActionSwitchListControllerInternalFamily super.from,
    required ({TimeSavedViewType viewType, bool isSignedIn}) super.argument,
  }) : super(
         retry: null,
         name: r'userActionSwitchListControllerInternalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$userActionSwitchListControllerInternalHash();

  @override
  String toString() {
    return r'userActionSwitchListControllerInternalProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  UserActionSwitchListControllerInternal create() =>
      UserActionSwitchListControllerInternal();

  @override
  bool operator ==(Object other) {
    return other is UserActionSwitchListControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userActionSwitchListControllerInternalHash() =>
    r'b58ba1cf339d5d73f44da7a60d012a82af40b382';

final class UserActionSwitchListControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          UserActionSwitchListControllerInternal,
          AsyncValue<List<UserActionSwitchCountEntity>>,
          List<UserActionSwitchCountEntity>,
          FutureOr<List<UserActionSwitchCountEntity>>,
          ({TimeSavedViewType viewType, bool isSignedIn})
        > {
  const UserActionSwitchListControllerInternalFamily._()
    : super(
        retry: null,
        name: r'userActionSwitchListControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UserActionSwitchListControllerInternalProvider call({
    required TimeSavedViewType viewType,
    required bool isSignedIn,
  }) => UserActionSwitchListControllerInternalProvider._(
    argument: (viewType: viewType, isSignedIn: isSignedIn),
    from: this,
  );

  @override
  String toString() => r'userActionSwitchListControllerInternalProvider';
}

abstract class _$UserActionSwitchListControllerInternal
    extends $AsyncNotifier<List<UserActionSwitchCountEntity>> {
  late final _$args =
      ref.$arg as ({TimeSavedViewType viewType, bool isSignedIn});
  TimeSavedViewType get viewType => _$args.viewType;
  bool get isSignedIn => _$args.isSignedIn;

  FutureOr<List<UserActionSwitchCountEntity>> build({
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
              AsyncValue<List<UserActionSwitchCountEntity>>,
              List<UserActionSwitchCountEntity>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<UserActionSwitchCountEntity>>,
                List<UserActionSwitchCountEntity>
              >,
              AsyncValue<List<UserActionSwitchCountEntity>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
