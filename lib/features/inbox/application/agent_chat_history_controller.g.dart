// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_chat_history_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AgentChatHistoryController)
const agentChatHistoryControllerProvider =
    AgentChatHistoryControllerProvider._();

final class AgentChatHistoryControllerProvider
    extends
        $AsyncNotifierProvider<
          AgentChatHistoryController,
          List<AgentChatHistoryEntity>
        > {
  const AgentChatHistoryControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'agentChatHistoryControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$agentChatHistoryControllerHash();

  @$internal
  @override
  AgentChatHistoryController create() => AgentChatHistoryController();
}

String _$agentChatHistoryControllerHash() =>
    r'887b4006719bdce81f62db22acbeb6c176d701cf';

abstract class _$AgentChatHistoryController
    extends $AsyncNotifier<List<AgentChatHistoryEntity>> {
  FutureOr<List<AgentChatHistoryEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<AgentChatHistoryEntity>>,
              List<AgentChatHistoryEntity>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<AgentChatHistoryEntity>>,
                List<AgentChatHistoryEntity>
              >,
              AsyncValue<List<AgentChatHistoryEntity>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
