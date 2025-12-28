// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_source_mails_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InboxSourceMailsController)
const inboxSourceMailsControllerProvider = InboxSourceMailsControllerFamily._();

final class InboxSourceMailsControllerProvider
    extends
        $AsyncNotifierProvider<
          InboxSourceMailsController,
          MailListResultEntity
        > {
  const InboxSourceMailsControllerProvider._({
    required InboxSourceMailsControllerFamily super.from,
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
         name: r'inboxSourceMailsControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$inboxSourceMailsControllerHash();

  @override
  String toString() {
    return r'inboxSourceMailsControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  InboxSourceMailsController create() => InboxSourceMailsController();

  @override
  bool operator ==(Object other) {
    return other is InboxSourceMailsControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$inboxSourceMailsControllerHash() =>
    r'342e79fb0d82a5b91064d4187bf90731ffaa296d';

final class InboxSourceMailsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          InboxSourceMailsController,
          AsyncValue<MailListResultEntity>,
          MailListResultEntity,
          FutureOr<MailListResultEntity>,
          ({
            bool isSearch,
            String oauthUniqueId,
            int year,
            int month,
            int day,
            bool isSignedIn,
          })
        > {
  const InboxSourceMailsControllerFamily._()
    : super(
        retry: null,
        name: r'inboxSourceMailsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  InboxSourceMailsControllerProvider call({
    required bool isSearch,
    required String oauthUniqueId,
    required int year,
    required int month,
    required int day,
    required bool isSignedIn,
  }) => InboxSourceMailsControllerProvider._(
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
  String toString() => r'inboxSourceMailsControllerProvider';
}

abstract class _$InboxSourceMailsController
    extends $AsyncNotifier<MailListResultEntity> {
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

  FutureOr<MailListResultEntity> build({
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
            as $Ref<AsyncValue<MailListResultEntity>, MailListResultEntity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<MailListResultEntity>,
                MailListResultEntity
              >,
              AsyncValue<MailListResultEntity>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
