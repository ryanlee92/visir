// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_agent_weather_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InboxAgentWeatherController)
const inboxAgentWeatherControllerProvider =
    InboxAgentWeatherControllerProvider._();

final class InboxAgentWeatherControllerProvider
    extends $NotifierProvider<InboxAgentWeatherController, Weather?> {
  const InboxAgentWeatherControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxAgentWeatherControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxAgentWeatherControllerHash();

  @$internal
  @override
  InboxAgentWeatherController create() => InboxAgentWeatherController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Weather? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Weather?>(value),
    );
  }
}

String _$inboxAgentWeatherControllerHash() =>
    r'56e4c4c09065f57d0d20dea8887c8251edeb24ac';

abstract class _$InboxAgentWeatherController extends $Notifier<Weather?> {
  Weather? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Weather?, Weather?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Weather?, Weather?>,
              Weather?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
