// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_action_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AgentActionController)
const agentActionControllerProvider = AgentActionControllerProvider._();

final class AgentActionControllerProvider
    extends $NotifierProvider<AgentActionController, AgentActionState> {
  const AgentActionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'agentActionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$agentActionControllerHash();

  @$internal
  @override
  AgentActionController create() => AgentActionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AgentActionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AgentActionState>(value),
    );
  }
}

String _$agentActionControllerHash() =>
    r'46fbc49b5c57560a65ebd685af63da654c77037f';

abstract class _$AgentActionController extends $Notifier<AgentActionState> {
  AgentActionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AgentActionState, AgentActionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AgentActionState, AgentActionState>,
              AgentActionState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
