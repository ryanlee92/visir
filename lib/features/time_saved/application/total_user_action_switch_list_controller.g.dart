// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'total_user_action_switch_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TotalUserActionSwitchListControllerInternal)
const totalUserActionSwitchListControllerInternalProvider =
    TotalUserActionSwitchListControllerInternalFamily._();

final class TotalUserActionSwitchListControllerInternalProvider
    extends
        $AsyncNotifierProvider<
          TotalUserActionSwitchListControllerInternal,
          TotalUserActionEntity
        > {
  const TotalUserActionSwitchListControllerInternalProvider._({
    required TotalUserActionSwitchListControllerInternalFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'totalUserActionSwitchListControllerInternalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$totalUserActionSwitchListControllerInternalHash();

  @override
  String toString() {
    return r'totalUserActionSwitchListControllerInternalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TotalUserActionSwitchListControllerInternal create() =>
      TotalUserActionSwitchListControllerInternal();

  @override
  bool operator ==(Object other) {
    return other is TotalUserActionSwitchListControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$totalUserActionSwitchListControllerInternalHash() =>
    r'a2b0fd7536ab5076fc1d78e8fcba76e056277d6a';

final class TotalUserActionSwitchListControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          TotalUserActionSwitchListControllerInternal,
          AsyncValue<TotalUserActionEntity>,
          TotalUserActionEntity,
          FutureOr<TotalUserActionEntity>,
          bool
        > {
  const TotalUserActionSwitchListControllerInternalFamily._()
    : super(
        retry: null,
        name: r'totalUserActionSwitchListControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TotalUserActionSwitchListControllerInternalProvider call({
    required bool isSignedIn,
  }) => TotalUserActionSwitchListControllerInternalProvider._(
    argument: isSignedIn,
    from: this,
  );

  @override
  String toString() => r'totalUserActionSwitchListControllerInternalProvider';
}

abstract class _$TotalUserActionSwitchListControllerInternal
    extends $AsyncNotifier<TotalUserActionEntity> {
  late final _$args = ref.$arg as bool;
  bool get isSignedIn => _$args;

  FutureOr<TotalUserActionEntity> build({required bool isSignedIn});
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(isSignedIn: _$args);
    final ref =
        this.ref
            as $Ref<AsyncValue<TotalUserActionEntity>, TotalUserActionEntity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<TotalUserActionEntity>,
                TotalUserActionEntity
              >,
              AsyncValue<TotalUserActionEntity>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
