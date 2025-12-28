// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(supabaseFeedbackDatasource)
const supabaseFeedbackDatasourceProvider =
    SupabaseFeedbackDatasourceProvider._();

final class SupabaseFeedbackDatasourceProvider
    extends
        $FunctionalProvider<
          SupabseFeedbackDatasource,
          SupabseFeedbackDatasource,
          SupabseFeedbackDatasource
        >
    with $Provider<SupabseFeedbackDatasource> {
  const SupabaseFeedbackDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supabaseFeedbackDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supabaseFeedbackDatasourceHash();

  @$internal
  @override
  $ProviderElement<SupabseFeedbackDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SupabseFeedbackDatasource create(Ref ref) {
    return supabaseFeedbackDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabseFeedbackDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabseFeedbackDatasource>(value),
    );
  }
}

String _$supabaseFeedbackDatasourceHash() =>
    r'adb1698b56fd09430c6291fe3df4b2edfdeaf7a7';

@ProviderFor(feedbackRepository)
const feedbackRepositoryProvider = FeedbackRepositoryProvider._();

final class FeedbackRepositoryProvider
    extends
        $FunctionalProvider<
          FeedbackRepository,
          FeedbackRepository,
          FeedbackRepository
        >
    with $Provider<FeedbackRepository> {
  const FeedbackRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedbackRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedbackRepositoryHash();

  @$internal
  @override
  $ProviderElement<FeedbackRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FeedbackRepository create(Ref ref) {
    return feedbackRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedbackRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedbackRepository>(value),
    );
  }
}

String _$feedbackRepositoryHash() =>
    r'c699d1b6563893872546d56f519756e0d3c2b5d3';
