// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_config_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InboxConfigListController)
const inboxConfigListControllerProvider = InboxConfigListControllerFamily._();

final class InboxConfigListControllerProvider
    extends
        $NotifierProvider<
          InboxConfigListController,
          InboxConfigFetchListEntity?
        > {
  const InboxConfigListControllerProvider._({
    required InboxConfigListControllerFamily super.from,
    required ({bool isSearch, int year, int month, int day, bool isSignedIn})
    super.argument,
  }) : super(
         retry: null,
         name: r'inboxConfigListControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$inboxConfigListControllerHash();

  @override
  String toString() {
    return r'inboxConfigListControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  InboxConfigListController create() => InboxConfigListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InboxConfigFetchListEntity? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InboxConfigFetchListEntity?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is InboxConfigListControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$inboxConfigListControllerHash() =>
    r'00dd75f0844319111000bdf112e5ded8af1a6318';

final class InboxConfigListControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          InboxConfigListController,
          InboxConfigFetchListEntity?,
          InboxConfigFetchListEntity?,
          InboxConfigFetchListEntity?,
          ({bool isSearch, int year, int month, int day, bool isSignedIn})
        > {
  const InboxConfigListControllerFamily._()
    : super(
        retry: null,
        name: r'inboxConfigListControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InboxConfigListControllerProvider call({
    required bool isSearch,
    required int year,
    required int month,
    required int day,
    required bool isSignedIn,
  }) => InboxConfigListControllerProvider._(
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
  String toString() => r'inboxConfigListControllerProvider';
}

abstract class _$InboxConfigListController
    extends $Notifier<InboxConfigFetchListEntity?> {
  late final _$args =
      ref.$arg
          as ({bool isSearch, int year, int month, int day, bool isSignedIn});
  bool get isSearch => _$args.isSearch;
  int get year => _$args.year;
  int get month => _$args.month;
  int get day => _$args.day;
  bool get isSignedIn => _$args.isSignedIn;

  InboxConfigFetchListEntity? build({
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
            as $Ref<InboxConfigFetchListEntity?, InboxConfigFetchListEntity?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                InboxConfigFetchListEntity?,
                InboxConfigFetchListEntity?
              >,
              InboxConfigFetchListEntity?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(InboxConfigControllerInternal)
const inboxConfigControllerInternalProvider =
    InboxConfigControllerInternalFamily._();

final class InboxConfigControllerInternalProvider
    extends
        $AsyncNotifierProvider<
          InboxConfigControllerInternal,
          InboxConfigFetchListEntity?
        > {
  const InboxConfigControllerInternalProvider._({
    required InboxConfigControllerInternalFamily super.from,
    required ({bool isSearch, int year, int month, int day, bool isSignedIn})
    super.argument,
  }) : super(
         retry: null,
         name: r'inboxConfigControllerInternalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$inboxConfigControllerInternalHash();

  @override
  String toString() {
    return r'inboxConfigControllerInternalProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  InboxConfigControllerInternal create() => InboxConfigControllerInternal();

  @override
  bool operator ==(Object other) {
    return other is InboxConfigControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$inboxConfigControllerInternalHash() =>
    r'7fc37f0eef82baaec6f729223cd6038aefa7876b';

final class InboxConfigControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          InboxConfigControllerInternal,
          AsyncValue<InboxConfigFetchListEntity?>,
          InboxConfigFetchListEntity?,
          FutureOr<InboxConfigFetchListEntity?>,
          ({bool isSearch, int year, int month, int day, bool isSignedIn})
        > {
  const InboxConfigControllerInternalFamily._()
    : super(
        retry: null,
        name: r'inboxConfigControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InboxConfigControllerInternalProvider call({
    required bool isSearch,
    required int year,
    required int month,
    required int day,
    required bool isSignedIn,
  }) => InboxConfigControllerInternalProvider._(
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
  String toString() => r'inboxConfigControllerInternalProvider';
}

abstract class _$InboxConfigControllerInternal
    extends $AsyncNotifier<InboxConfigFetchListEntity?> {
  late final _$args =
      ref.$arg
          as ({bool isSearch, int year, int month, int day, bool isSignedIn});
  bool get isSearch => _$args.isSearch;
  int get year => _$args.year;
  int get month => _$args.month;
  int get day => _$args.day;
  bool get isSignedIn => _$args.isSignedIn;

  FutureOr<InboxConfigFetchListEntity?> build({
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
              AsyncValue<InboxConfigFetchListEntity?>,
              InboxConfigFetchListEntity?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<InboxConfigFetchListEntity?>,
                InboxConfigFetchListEntity?
              >,
              AsyncValue<InboxConfigFetchListEntity?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
