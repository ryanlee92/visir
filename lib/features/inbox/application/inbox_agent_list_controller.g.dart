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
    r'73a9618ac895448b3df063b0d760a7c8f76065c9';

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
