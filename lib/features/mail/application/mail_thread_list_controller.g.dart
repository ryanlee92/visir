// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mail_thread_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MailThreadListController)
const mailThreadListControllerProvider = MailThreadListControllerFamily._();

final class MailThreadListControllerProvider
    extends $NotifierProvider<MailThreadListController, List<MailEntity>> {
  const MailThreadListControllerProvider._({
    required MailThreadListControllerFamily super.from,
    required TabType super.argument,
  }) : super(
         retry: null,
         name: r'mailThreadListControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mailThreadListControllerHash();

  @override
  String toString() {
    return r'mailThreadListControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MailThreadListController create() => MailThreadListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<MailEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<MailEntity>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MailThreadListControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mailThreadListControllerHash() =>
    r'10dbedc60d4d7833b3cce52b6109d40704883620';

final class MailThreadListControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          MailThreadListController,
          List<MailEntity>,
          List<MailEntity>,
          List<MailEntity>,
          TabType
        > {
  const MailThreadListControllerFamily._()
    : super(
        retry: null,
        name: r'mailThreadListControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MailThreadListControllerProvider call({required TabType tabType}) =>
      MailThreadListControllerProvider._(argument: tabType, from: this);

  @override
  String toString() => r'mailThreadListControllerProvider';
}

abstract class _$MailThreadListController extends $Notifier<List<MailEntity>> {
  late final _$args = ref.$arg as TabType;
  TabType get tabType => _$args;

  List<MailEntity> build({required TabType tabType});
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(tabType: _$args);
    final ref = this.ref as $Ref<List<MailEntity>, List<MailEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<MailEntity>, List<MailEntity>>,
              List<MailEntity>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(MailThreadListControllerInternal)
const mailThreadListControllerInternalProvider =
    MailThreadListControllerInternalFamily._();

final class MailThreadListControllerInternalProvider
    extends
        $AsyncNotifierProvider<
          MailThreadListControllerInternal,
          List<MailEntity>
        > {
  const MailThreadListControllerInternalProvider._({
    required MailThreadListControllerInternalFamily super.from,
    required ({
      bool isSignedIn,
      MailEntityType type,
      String label,
      String email,
      String threadId,
      List<MailEntity>? threads,
      String oAuthUniqueId,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'mailThreadListControllerInternalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mailThreadListControllerInternalHash();

  @override
  String toString() {
    return r'mailThreadListControllerInternalProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  MailThreadListControllerInternal create() =>
      MailThreadListControllerInternal();

  @override
  bool operator ==(Object other) {
    return other is MailThreadListControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mailThreadListControllerInternalHash() =>
    r'c3f11609f20fb1a14765958bb1f26744d0b4c807';

final class MailThreadListControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          MailThreadListControllerInternal,
          AsyncValue<List<MailEntity>>,
          List<MailEntity>,
          FutureOr<List<MailEntity>>,
          ({
            bool isSignedIn,
            MailEntityType type,
            String label,
            String email,
            String threadId,
            List<MailEntity>? threads,
            String oAuthUniqueId,
          })
        > {
  const MailThreadListControllerInternalFamily._()
    : super(
        retry: null,
        name: r'mailThreadListControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MailThreadListControllerInternalProvider call({
    required bool isSignedIn,
    required MailEntityType type,
    required String label,
    required String email,
    required String threadId,
    List<MailEntity>? threads,
    required String oAuthUniqueId,
  }) => MailThreadListControllerInternalProvider._(
    argument: (
      isSignedIn: isSignedIn,
      type: type,
      label: label,
      email: email,
      threadId: threadId,
      threads: threads,
      oAuthUniqueId: oAuthUniqueId,
    ),
    from: this,
  );

  @override
  String toString() => r'mailThreadListControllerInternalProvider';
}

abstract class _$MailThreadListControllerInternal
    extends $AsyncNotifier<List<MailEntity>> {
  late final _$args =
      ref.$arg
          as ({
            bool isSignedIn,
            MailEntityType type,
            String label,
            String email,
            String threadId,
            List<MailEntity>? threads,
            String oAuthUniqueId,
          });
  bool get isSignedIn => _$args.isSignedIn;
  MailEntityType get type => _$args.type;
  String get label => _$args.label;
  String get email => _$args.email;
  String get threadId => _$args.threadId;
  List<MailEntity>? get threads => _$args.threads;
  String get oAuthUniqueId => _$args.oAuthUniqueId;

  FutureOr<List<MailEntity>> build({
    required bool isSignedIn,
    required MailEntityType type,
    required String label,
    required String email,
    required String threadId,
    List<MailEntity>? threads,
    required String oAuthUniqueId,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      isSignedIn: _$args.isSignedIn,
      type: _$args.type,
      label: _$args.label,
      email: _$args.email,
      threadId: _$args.threadId,
      threads: _$args.threads,
      oAuthUniqueId: _$args.oAuthUniqueId,
    );
    final ref =
        this.ref as $Ref<AsyncValue<List<MailEntity>>, List<MailEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<MailEntity>>, List<MailEntity>>,
              AsyncValue<List<MailEntity>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
