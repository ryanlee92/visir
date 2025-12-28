// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messenger_integration_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MessengerIntegrationListController)
const messengerIntegrationListControllerProvider =
    MessengerIntegrationListControllerProvider._();

final class MessengerIntegrationListControllerProvider
    extends
        $NotifierProvider<
          MessengerIntegrationListController,
          AsyncValue<List<OAuthEntity>>
        > {
  const MessengerIntegrationListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'messengerIntegrationListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$messengerIntegrationListControllerHash();

  @$internal
  @override
  MessengerIntegrationListController create() =>
      MessengerIntegrationListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<OAuthEntity>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<OAuthEntity>>>(
        value,
      ),
    );
  }
}

String _$messengerIntegrationListControllerHash() =>
    r'6e3b72902fa86750c6aface39ab1f850aff8e319';

abstract class _$MessengerIntegrationListController
    extends $Notifier<AsyncValue<List<OAuthEntity>>> {
  AsyncValue<List<OAuthEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<OAuthEntity>>,
              AsyncValue<List<OAuthEntity>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<OAuthEntity>>,
                AsyncValue<List<OAuthEntity>>
              >,
              AsyncValue<List<OAuthEntity>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
