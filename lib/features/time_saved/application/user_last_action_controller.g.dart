// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_last_action_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserLastActionController)
const userLastActionControllerProvider = UserLastActionControllerProvider._();

final class UserLastActionControllerProvider
    extends
        $NotifierProvider<
          UserLastActionController,
          AsyncValue<UserActionEntity?>
        > {
  const UserLastActionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userLastActionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userLastActionControllerHash();

  @$internal
  @override
  UserLastActionController create() => UserLastActionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<UserActionEntity?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<UserActionEntity?>>(
        value,
      ),
    );
  }
}

String _$userLastActionControllerHash() =>
    r'69384eab6f49860660120ecb7bd48e4e55b71342';

abstract class _$UserLastActionController
    extends $Notifier<AsyncValue<UserActionEntity?>> {
  AsyncValue<UserActionEntity?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<UserActionEntity?>,
              AsyncValue<UserActionEntity?>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<UserActionEntity?>,
                AsyncValue<UserActionEntity?>
              >,
              AsyncValue<UserActionEntity?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
