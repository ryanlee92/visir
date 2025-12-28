// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ConnectionListController)
const connectionListControllerProvider = ConnectionListControllerProvider._();

final class ConnectionListControllerProvider
    extends
        $AsyncNotifierProvider<
          ConnectionListController,
          Map<String, List<ConnectionEntity>>
        > {
  const ConnectionListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionListControllerHash();

  @$internal
  @override
  ConnectionListController create() => ConnectionListController();
}

String _$connectionListControllerHash() =>
    r'7c763b27003eb431e0ee1d84de59e3e3e84a3b23';

abstract class _$ConnectionListController
    extends $AsyncNotifier<Map<String, List<ConnectionEntity>>> {
  FutureOr<Map<String, List<ConnectionEntity>>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Map<String, List<ConnectionEntity>>>,
              Map<String, List<ConnectionEntity>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<String, List<ConnectionEntity>>>,
                Map<String, List<ConnectionEntity>>
              >,
              AsyncValue<Map<String, List<ConnectionEntity>>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
