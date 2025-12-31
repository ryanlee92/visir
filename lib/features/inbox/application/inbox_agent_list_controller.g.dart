// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_agent_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InboxAgentListController)
const inboxAgentListControllerProvider = InboxAgentListControllerProvider._();

final class InboxAgentListControllerProvider
    extends $NotifierProvider<InboxAgentListController, InboxFetchListEntity?> {
  const InboxAgentListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxAgentListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxAgentListControllerHash();

  @$internal
  @override
  InboxAgentListController create() => InboxAgentListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InboxFetchListEntity? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InboxFetchListEntity?>(value),
    );
  }
}

String _$inboxAgentListControllerHash() =>
    r'64164b8f1a32474a01cd823bff6e44b7927ab67d';

abstract class _$InboxAgentListController
    extends $Notifier<InboxFetchListEntity?> {
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
