// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_linked_task_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InboxLinkedTaskController)
const inboxLinkedTaskControllerProvider = InboxLinkedTaskControllerProvider._();

final class InboxLinkedTaskControllerProvider
    extends
        $NotifierProvider<
          InboxLinkedTaskController,
          InboxLinkedTaskFetchListEntity?
        > {
  const InboxLinkedTaskControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxLinkedTaskControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxLinkedTaskControllerHash();

  @$internal
  @override
  InboxLinkedTaskController create() => InboxLinkedTaskController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InboxLinkedTaskFetchListEntity? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InboxLinkedTaskFetchListEntity?>(
        value,
      ),
    );
  }
}

String _$inboxLinkedTaskControllerHash() =>
    r'e400976489b45b9f3187de43b497d7f3ead66a86';

abstract class _$InboxLinkedTaskController
    extends $Notifier<InboxLinkedTaskFetchListEntity?> {
  InboxLinkedTaskFetchListEntity? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              InboxLinkedTaskFetchListEntity?,
              InboxLinkedTaskFetchListEntity?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                InboxLinkedTaskFetchListEntity?,
                InboxLinkedTaskFetchListEntity?
              >,
              InboxLinkedTaskFetchListEntity?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(InboxLinkedTaskControllerInternal)
const inboxLinkedTaskControllerInternalProvider =
    InboxLinkedTaskControllerInternalFamily._();

final class InboxLinkedTaskControllerInternalProvider
    extends
        $AsyncNotifierProvider<
          InboxLinkedTaskControllerInternal,
          InboxLinkedTaskFetchListEntity?
        > {
  const InboxLinkedTaskControllerInternalProvider._({
    required InboxLinkedTaskControllerInternalFamily super.from,
    required ({bool isSearch, int year, int month, int day, bool isSignedIn})
    super.argument,
  }) : super(
         retry: null,
         name: r'inboxLinkedTaskControllerInternalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$inboxLinkedTaskControllerInternalHash();

  @override
  String toString() {
    return r'inboxLinkedTaskControllerInternalProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  InboxLinkedTaskControllerInternal create() =>
      InboxLinkedTaskControllerInternal();

  @override
  bool operator ==(Object other) {
    return other is InboxLinkedTaskControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$inboxLinkedTaskControllerInternalHash() =>
    r'0bb84d118ff34de0fe65089f54d0826a27503826';

final class InboxLinkedTaskControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          InboxLinkedTaskControllerInternal,
          AsyncValue<InboxLinkedTaskFetchListEntity?>,
          InboxLinkedTaskFetchListEntity?,
          FutureOr<InboxLinkedTaskFetchListEntity?>,
          ({bool isSearch, int year, int month, int day, bool isSignedIn})
        > {
  const InboxLinkedTaskControllerInternalFamily._()
    : super(
        retry: null,
        name: r'inboxLinkedTaskControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InboxLinkedTaskControllerInternalProvider call({
    required bool isSearch,
    required int year,
    required int month,
    required int day,
    required bool isSignedIn,
  }) => InboxLinkedTaskControllerInternalProvider._(
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
  String toString() => r'inboxLinkedTaskControllerInternalProvider';
}

abstract class _$InboxLinkedTaskControllerInternal
    extends $AsyncNotifier<InboxLinkedTaskFetchListEntity?> {
  late final _$args =
      ref.$arg
          as ({bool isSearch, int year, int month, int day, bool isSignedIn});
  bool get isSearch => _$args.isSearch;
  int get year => _$args.year;
  int get month => _$args.month;
  int get day => _$args.day;
  bool get isSignedIn => _$args.isSignedIn;

  FutureOr<InboxLinkedTaskFetchListEntity?> build({
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
              AsyncValue<InboxLinkedTaskFetchListEntity?>,
              InboxLinkedTaskFetchListEntity?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<InboxLinkedTaskFetchListEntity?>,
                InboxLinkedTaskFetchListEntity?
              >,
              AsyncValue<InboxLinkedTaskFetchListEntity?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
