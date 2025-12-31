// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mail_label_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MailLabelListController)
const mailLabelListControllerProvider = MailLabelListControllerProvider._();

final class MailLabelListControllerProvider
    extends
        $NotifierProvider<
          MailLabelListController,
          Map<String, List<MailLabelEntity>>
        > {
  const MailLabelListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mailLabelListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mailLabelListControllerHash();

  @$internal
  @override
  MailLabelListController create() => MailLabelListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, List<MailLabelEntity>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, List<MailLabelEntity>>>(
        value,
      ),
    );
  }
}

String _$mailLabelListControllerHash() =>
    r'c36723e06de36bc0837f1aebbdaf2aee7026c6c8';

abstract class _$MailLabelListController
    extends $Notifier<Map<String, List<MailLabelEntity>>> {
  Map<String, List<MailLabelEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              Map<String, List<MailLabelEntity>>,
              Map<String, List<MailLabelEntity>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, List<MailLabelEntity>>,
                Map<String, List<MailLabelEntity>>
              >,
              Map<String, List<MailLabelEntity>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(MailLabelListControllerInternal)
const mailLabelListControllerInternalProvider =
    MailLabelListControllerInternalFamily._();

final class MailLabelListControllerInternalProvider
    extends
        $AsyncNotifierProvider<
          MailLabelListControllerInternal,
          Map<String, List<MailLabelEntity>>
        > {
  const MailLabelListControllerInternalProvider._({
    required MailLabelListControllerInternalFamily super.from,
    required ({bool isSignedIn, String oAuthUniqueId}) super.argument,
  }) : super(
         retry: null,
         name: r'mailLabelListControllerInternalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mailLabelListControllerInternalHash();

  @override
  String toString() {
    return r'mailLabelListControllerInternalProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  MailLabelListControllerInternal create() => MailLabelListControllerInternal();

  @override
  bool operator ==(Object other) {
    return other is MailLabelListControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mailLabelListControllerInternalHash() =>
    r'd06a7ee4ccd4d4d422e52d34193dc00d904d654a';

final class MailLabelListControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          MailLabelListControllerInternal,
          AsyncValue<Map<String, List<MailLabelEntity>>>,
          Map<String, List<MailLabelEntity>>,
          FutureOr<Map<String, List<MailLabelEntity>>>,
          ({bool isSignedIn, String oAuthUniqueId})
        > {
  const MailLabelListControllerInternalFamily._()
    : super(
        retry: null,
        name: r'mailLabelListControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MailLabelListControllerInternalProvider call({
    required bool isSignedIn,
    required String oAuthUniqueId,
  }) => MailLabelListControllerInternalProvider._(
    argument: (isSignedIn: isSignedIn, oAuthUniqueId: oAuthUniqueId),
    from: this,
  );

  @override
  String toString() => r'mailLabelListControllerInternalProvider';
}

abstract class _$MailLabelListControllerInternal
    extends $AsyncNotifier<Map<String, List<MailLabelEntity>>> {
  late final _$args = ref.$arg as ({bool isSignedIn, String oAuthUniqueId});
  bool get isSignedIn => _$args.isSignedIn;
  String get oAuthUniqueId => _$args.oAuthUniqueId;

  FutureOr<Map<String, List<MailLabelEntity>>> build({
    required bool isSignedIn,
    required String oAuthUniqueId,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      isSignedIn: _$args.isSignedIn,
      oAuthUniqueId: _$args.oAuthUniqueId,
    );
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Map<String, List<MailLabelEntity>>>,
              Map<String, List<MailLabelEntity>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<String, List<MailLabelEntity>>>,
                Map<String, List<MailLabelEntity>>
              >,
              AsyncValue<Map<String, List<MailLabelEntity>>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
