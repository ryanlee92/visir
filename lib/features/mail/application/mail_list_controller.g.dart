// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mail_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MailListController)
const mailListControllerProvider = MailListControllerProvider._();

final class MailListControllerProvider
    extends $NotifierProvider<MailListController, MailListResultEntity> {
  const MailListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mailListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mailListControllerHash();

  @$internal
  @override
  MailListController create() => MailListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MailListResultEntity value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MailListResultEntity>(value),
    );
  }
}

String _$mailListControllerHash() =>
    r'0e6f820f9aef08e70a01edeb04db5fe24f04121a';

abstract class _$MailListController extends $Notifier<MailListResultEntity> {
  MailListResultEntity build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<MailListResultEntity, MailListResultEntity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MailListResultEntity, MailListResultEntity>,
              MailListResultEntity,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(MailListControllerInternal)
const mailListControllerInternalProvider = MailListControllerInternalFamily._();

final class MailListControllerInternalProvider
    extends
        $AsyncNotifierProvider<
          MailListControllerInternal,
          MailListResultEntity
        > {
  const MailListControllerInternalProvider._({
    required MailListControllerInternalFamily super.from,
    required ({
      bool isSignedIn,
      String label,
      String email,
      String? query,
      String oAuthUniqueId,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'mailListControllerInternalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mailListControllerInternalHash();

  @override
  String toString() {
    return r'mailListControllerInternalProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  MailListControllerInternal create() => MailListControllerInternal();

  @override
  bool operator ==(Object other) {
    return other is MailListControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mailListControllerInternalHash() =>
    r'e3b11b8a90c6393bf41c763e33864a263e3fa19c';

final class MailListControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          MailListControllerInternal,
          AsyncValue<MailListResultEntity>,
          MailListResultEntity,
          FutureOr<MailListResultEntity>,
          ({
            bool isSignedIn,
            String label,
            String email,
            String? query,
            String oAuthUniqueId,
          })
        > {
  const MailListControllerInternalFamily._()
    : super(
        retry: null,
        name: r'mailListControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MailListControllerInternalProvider call({
    required bool isSignedIn,
    required String label,
    required String email,
    required String? query,
    required String oAuthUniqueId,
  }) => MailListControllerInternalProvider._(
    argument: (
      isSignedIn: isSignedIn,
      label: label,
      email: email,
      query: query,
      oAuthUniqueId: oAuthUniqueId,
    ),
    from: this,
  );

  @override
  String toString() => r'mailListControllerInternalProvider';
}

abstract class _$MailListControllerInternal
    extends $AsyncNotifier<MailListResultEntity> {
  late final _$args =
      ref.$arg
          as ({
            bool isSignedIn,
            String label,
            String email,
            String? query,
            String oAuthUniqueId,
          });
  bool get isSignedIn => _$args.isSignedIn;
  String get label => _$args.label;
  String get email => _$args.email;
  String? get query => _$args.query;
  String get oAuthUniqueId => _$args.oAuthUniqueId;

  FutureOr<MailListResultEntity> build({
    required bool isSignedIn,
    required String label,
    required String email,
    required String? query,
    required String oAuthUniqueId,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      isSignedIn: _$args.isSignedIn,
      label: _$args.label,
      email: _$args.email,
      query: _$args.query,
      oAuthUniqueId: _$args.oAuthUniqueId,
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
