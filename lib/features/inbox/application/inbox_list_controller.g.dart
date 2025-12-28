// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InboxListController)
const inboxListControllerProvider = InboxListControllerProvider._();

final class InboxListControllerProvider
    extends $NotifierProvider<InboxListController, InboxFetchListEntity?> {
  const InboxListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxListControllerHash();

  @$internal
  @override
  InboxListController create() => InboxListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InboxFetchListEntity? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InboxFetchListEntity?>(value),
    );
  }
}

String _$inboxListControllerHash() =>
    r'f048cb6666fda01d7cd2f8e72c8877d58b74e1c5';

abstract class _$InboxListController extends $Notifier<InboxFetchListEntity?> {
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

@ProviderFor(InboxListControllerInternal)
const inboxListControllerInternalProvider =
    InboxListControllerInternalFamily._();

final class InboxListControllerInternalProvider
    extends
        $AsyncNotifierProvider<
          InboxListControllerInternal,
          InboxFetchListEntity?
        > {
  const InboxListControllerInternalProvider._({
    required InboxListControllerInternalFamily super.from,
    required ({bool isSearch, int year, int month, int day, bool isSignedIn})
    super.argument,
  }) : super(
         retry: null,
         name: r'inboxListControllerInternalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$inboxListControllerInternalHash();

  @override
  String toString() {
    return r'inboxListControllerInternalProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  InboxListControllerInternal create() => InboxListControllerInternal();

  @override
  bool operator ==(Object other) {
    return other is InboxListControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$inboxListControllerInternalHash() =>
    r'2293d8d79714fa19d02cc4ccf091b8212c68f01d';

final class InboxListControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          InboxListControllerInternal,
          AsyncValue<InboxFetchListEntity?>,
          InboxFetchListEntity?,
          FutureOr<InboxFetchListEntity?>,
          ({bool isSearch, int year, int month, int day, bool isSignedIn})
        > {
  const InboxListControllerInternalFamily._()
    : super(
        retry: null,
        name: r'inboxListControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InboxListControllerInternalProvider call({
    required bool isSearch,
    required int year,
    required int month,
    required int day,
    required bool isSignedIn,
  }) => InboxListControllerInternalProvider._(
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
  String toString() => r'inboxListControllerInternalProvider';
}

abstract class _$InboxListControllerInternal
    extends $AsyncNotifier<InboxFetchListEntity?> {
  late final _$args =
      ref.$arg
          as ({bool isSearch, int year, int month, int day, bool isSignedIn});
  bool get isSearch => _$args.isSearch;
  int get year => _$args.year;
  int get month => _$args.month;
  int get day => _$args.day;
  bool get isSignedIn => _$args.isSignedIn;

  FutureOr<InboxFetchListEntity?> build({
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
            as $Ref<AsyncValue<InboxFetchListEntity?>, InboxFetchListEntity?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<InboxFetchListEntity?>,
                InboxFetchListEntity?
              >,
              AsyncValue<InboxFetchListEntity?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
