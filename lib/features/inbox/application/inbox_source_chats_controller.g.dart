// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_source_chats_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InboxSourceChatsController)
const inboxSourceChatsControllerProvider = InboxSourceChatsControllerFamily._();

final class InboxSourceChatsControllerProvider
    extends
        $AsyncNotifierProvider<
          InboxSourceChatsController,
          ChatFetchResultEntity
        > {
  const InboxSourceChatsControllerProvider._({
    required InboxSourceChatsControllerFamily super.from,
    required ({
      bool isSearch,
      String oauthUniqueId,
      int year,
      int month,
      int day,
      bool isSignedIn,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'inboxSourceChatsControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$inboxSourceChatsControllerHash();

  @override
  String toString() {
    return r'inboxSourceChatsControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  InboxSourceChatsController create() => InboxSourceChatsController();

  @override
  bool operator ==(Object other) {
    return other is InboxSourceChatsControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$inboxSourceChatsControllerHash() =>
    r'4bdffd300e45c50fa95ec04078e2e4f8901c3700';

final class InboxSourceChatsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          InboxSourceChatsController,
          AsyncValue<ChatFetchResultEntity>,
          ChatFetchResultEntity,
          FutureOr<ChatFetchResultEntity>,
          ({
            bool isSearch,
            String oauthUniqueId,
            int year,
            int month,
            int day,
            bool isSignedIn,
          })
        > {
  const InboxSourceChatsControllerFamily._()
    : super(
        retry: null,
        name: r'inboxSourceChatsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InboxSourceChatsControllerProvider call({
    required bool isSearch,
    required String oauthUniqueId,
    required int year,
    required int month,
    required int day,
    required bool isSignedIn,
  }) => InboxSourceChatsControllerProvider._(
    argument: (
      isSearch: isSearch,
      oauthUniqueId: oauthUniqueId,
      year: year,
      month: month,
      day: day,
      isSignedIn: isSignedIn,
    ),
    from: this,
  );

  @override
  String toString() => r'inboxSourceChatsControllerProvider';
}

abstract class _$InboxSourceChatsController
    extends $AsyncNotifier<ChatFetchResultEntity> {
  late final _$args =
      ref.$arg
          as ({
            bool isSearch,
            String oauthUniqueId,
            int year,
            int month,
            int day,
            bool isSignedIn,
          });
  bool get isSearch => _$args.isSearch;
  String get oauthUniqueId => _$args.oauthUniqueId;
  int get year => _$args.year;
  int get month => _$args.month;
  int get day => _$args.day;
  bool get isSignedIn => _$args.isSignedIn;

  FutureOr<ChatFetchResultEntity> build({
    required bool isSearch,
    required String oauthUniqueId,
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
      oauthUniqueId: _$args.oauthUniqueId,
      year: _$args.year,
      month: _$args.month,
      day: _$args.day,
      isSignedIn: _$args.isSignedIn,
    );
    final ref =
        this.ref
            as $Ref<AsyncValue<ChatFetchResultEntity>, ChatFetchResultEntity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ChatFetchResultEntity>,
                ChatFetchResultEntity
              >,
              AsyncValue<ChatFetchResultEntity>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
