// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InboxController)
const inboxControllerProvider = InboxControllerProvider._();

final class InboxControllerProvider
    extends $NotifierProvider<InboxController, InboxFetchListEntity?> {
  const InboxControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxControllerHash();

  @$internal
  @override
  InboxController create() => InboxController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InboxFetchListEntity? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InboxFetchListEntity?>(value),
    );
  }
}

String _$inboxControllerHash() => r'092a9e18179861c1de1c17ee0b2733f778c67d3c';

abstract class _$InboxController extends $Notifier<InboxFetchListEntity?> {
  InboxFetchListEntity? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<InboxFetchListEntity?, InboxFetchListEntity?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<InboxFetchListEntity?, InboxFetchListEntity?>,
              InboxFetchListEntity?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
