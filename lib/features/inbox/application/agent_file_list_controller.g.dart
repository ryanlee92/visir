// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_file_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AgentFileListController)
const agentFileListControllerProvider = AgentFileListControllerFamily._();

final class AgentFileListControllerProvider
    extends
        $NotifierProvider<
          AgentFileListController,
          List<MessageUploadingTempFileEntity>
        > {
  const AgentFileListControllerProvider._({
    required AgentFileListControllerFamily super.from,
    required TabType super.argument,
  }) : super(
         retry: null,
         name: r'agentFileListControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$agentFileListControllerHash();

  @override
  String toString() {
    return r'agentFileListControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AgentFileListController create() => AgentFileListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<MessageUploadingTempFileEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<List<MessageUploadingTempFileEntity>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AgentFileListControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$agentFileListControllerHash() =>
    r'9bd278dc208fa0011ac9570233b40ca580ee7c8a';

final class AgentFileListControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          AgentFileListController,
          List<MessageUploadingTempFileEntity>,
          List<MessageUploadingTempFileEntity>,
          List<MessageUploadingTempFileEntity>,
          TabType
        > {
  const AgentFileListControllerFamily._()
    : super(
        retry: null,
        name: r'agentFileListControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AgentFileListControllerProvider call({required TabType tabType}) =>
      AgentFileListControllerProvider._(argument: tabType, from: this);

  @override
  String toString() => r'agentFileListControllerProvider';
}

abstract class _$AgentFileListController
    extends $Notifier<List<MessageUploadingTempFileEntity>> {
  late final _$args = ref.$arg as TabType;
  TabType get tabType => _$args;

  List<MessageUploadingTempFileEntity> build({required TabType tabType});
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(tabType: _$args);
    final ref =
        this.ref
            as $Ref<
              List<MessageUploadingTempFileEntity>,
              List<MessageUploadingTempFileEntity>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                List<MessageUploadingTempFileEntity>,
                List<MessageUploadingTempFileEntity>
              >,
              List<MessageUploadingTempFileEntity>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
