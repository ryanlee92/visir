// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mail_draft_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MailDraftListController)
const mailDraftListControllerProvider = MailDraftListControllerProvider._();

final class MailDraftListControllerProvider
    extends
        $NotifierProvider<
          MailDraftListController,
          AsyncValue<List<MailEntity>>
        > {
  const MailDraftListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mailDraftListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mailDraftListControllerHash();

  @$internal
  @override
  MailDraftListController create() => MailDraftListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<MailEntity>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<MailEntity>>>(value),
    );
  }
}

String _$mailDraftListControllerHash() =>
    r'8d43da96bc2fc18f28a50816394d850810eb5aa7';

abstract class _$MailDraftListController
    extends $Notifier<AsyncValue<List<MailEntity>>> {
  AsyncValue<List<MailEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<List<MailEntity>>, AsyncValue<List<MailEntity>>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<MailEntity>>,
                AsyncValue<List<MailEntity>>
              >,
              AsyncValue<List<MailEntity>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
