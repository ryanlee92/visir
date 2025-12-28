// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_suggestion_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InboxSuggestionController)
const inboxSuggestionControllerProvider = InboxSuggestionControllerProvider._();

final class InboxSuggestionControllerProvider
    extends
        $NotifierProvider<
          InboxSuggestionController,
          InboxSuggestionFetchListEntity?
        > {
  const InboxSuggestionControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxSuggestionControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxSuggestionControllerHash();

  @$internal
  @override
  InboxSuggestionController create() => InboxSuggestionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InboxSuggestionFetchListEntity? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InboxSuggestionFetchListEntity?>(
        value,
      ),
    );
  }
}

String _$inboxSuggestionControllerHash() =>
    r'265bbc4f5ad28416c42922eb7cc99f72e7bf8cac';

abstract class _$InboxSuggestionController
    extends $Notifier<InboxSuggestionFetchListEntity?> {
  InboxSuggestionFetchListEntity? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              InboxSuggestionFetchListEntity?,
              InboxSuggestionFetchListEntity?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                InboxSuggestionFetchListEntity?,
                InboxSuggestionFetchListEntity?
              >,
              InboxSuggestionFetchListEntity?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(InboxSuggestionControllerInternal)
const inboxSuggestionControllerInternalProvider =
    InboxSuggestionControllerInternalFamily._();

final class InboxSuggestionControllerInternalProvider
    extends
        $AsyncNotifierProvider<
          InboxSuggestionControllerInternal,
          InboxSuggestionFetchListEntity?
        > {
  const InboxSuggestionControllerInternalProvider._({
    required InboxSuggestionControllerInternalFamily super.from,
    required ({bool isSearch, int year, int month, int day, bool isSignedIn})
    super.argument,
  }) : super(
         retry: null,
         name: r'inboxSuggestionControllerInternalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$inboxSuggestionControllerInternalHash();

  @override
  String toString() {
    return r'inboxSuggestionControllerInternalProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  InboxSuggestionControllerInternal create() =>
      InboxSuggestionControllerInternal();

  @override
  bool operator ==(Object other) {
    return other is InboxSuggestionControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$inboxSuggestionControllerInternalHash() =>
    r'cc83a9c11cc1d8b13ec631e03f14f3bce1396b65';

final class InboxSuggestionControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          InboxSuggestionControllerInternal,
          AsyncValue<InboxSuggestionFetchListEntity?>,
          InboxSuggestionFetchListEntity?,
          FutureOr<InboxSuggestionFetchListEntity?>,
          ({bool isSearch, int year, int month, int day, bool isSignedIn})
        > {
  const InboxSuggestionControllerInternalFamily._()
    : super(
        retry: null,
        name: r'inboxSuggestionControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InboxSuggestionControllerInternalProvider call({
    required bool isSearch,
    required int year,
    required int month,
    required int day,
    required bool isSignedIn,
  }) => InboxSuggestionControllerInternalProvider._(
    argument: (
      isSearch: isSearch,
      year: year,
      month: month,
      day: day,
      isSignedIn: isSignedIn,
    ),
    from: this,
  );

  @override
  String toString() => r'inboxSuggestionControllerInternalProvider';
}

abstract class _$InboxSuggestionControllerInternal
    extends $AsyncNotifier<InboxSuggestionFetchListEntity?> {
  late final _$args =
      ref.$arg
          as ({bool isSearch, int year, int month, int day, bool isSignedIn});
  bool get isSearch => _$args.isSearch;
  int get year => _$args.year;
  int get month => _$args.month;
  int get day => _$args.day;
  bool get isSignedIn => _$args.isSignedIn;

  FutureOr<InboxSuggestionFetchListEntity?> build({
    required bool isSearch,
    required int year,
    required int month,
    required int day,
    required bool isSignedIn,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      isSearch: _$args.isSearch,
      year: _$args.year,
      month: _$args.month,
      day: _$args.day,
      isSignedIn: _$args.isSignedIn,
    );
    final ref =
        this.ref
            as $Ref<
              AsyncValue<InboxSuggestionFetchListEntity?>,
              InboxSuggestionFetchListEntity?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<InboxSuggestionFetchListEntity?>,
                InboxSuggestionFetchListEntity?
              >,
              AsyncValue<InboxSuggestionFetchListEntity?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
