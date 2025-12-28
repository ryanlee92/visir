// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mail_integration_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MailIntegrationListController)
const mailIntegrationListControllerProvider =
    MailIntegrationListControllerProvider._();

final class MailIntegrationListControllerProvider
    extends
        $NotifierProvider<
          MailIntegrationListController,
          AsyncValue<List<OAuthEntity>>
        > {
  const MailIntegrationListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mailIntegrationListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mailIntegrationListControllerHash();

  @$internal
  @override
  MailIntegrationListController create() => MailIntegrationListController();

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

String _$mailIntegrationListControllerHash() =>
    r'b39767feac1cad95d0be7beb8c3d1bfd50e012d9';

abstract class _$MailIntegrationListController
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
