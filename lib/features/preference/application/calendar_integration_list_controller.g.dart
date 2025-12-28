// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_integration_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CalendarIntegrationListController)
const calendarIntegrationListControllerProvider =
    CalendarIntegrationListControllerProvider._();

final class CalendarIntegrationListControllerProvider
    extends
        $NotifierProvider<
          CalendarIntegrationListController,
          AsyncValue<List<OAuthEntity>>
        > {
  const CalendarIntegrationListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarIntegrationListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$calendarIntegrationListControllerHash();

  @$internal
  @override
  CalendarIntegrationListController create() =>
      CalendarIntegrationListController();

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

String _$calendarIntegrationListControllerHash() =>
    r'1c13eb19c3a99fdb449593ad8e6e226fa3eb8fc2';

abstract class _$CalendarIntegrationListController
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
