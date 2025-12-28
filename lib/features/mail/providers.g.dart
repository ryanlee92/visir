// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(googleMailDatasource)
const googleMailDatasourceProvider = GoogleMailDatasourceProvider._();

final class GoogleMailDatasourceProvider
    extends
        $FunctionalProvider<
          GoogleMailDatasource,
          GoogleMailDatasource,
          GoogleMailDatasource
        >
    with $Provider<GoogleMailDatasource> {
  const GoogleMailDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'googleMailDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$googleMailDatasourceHash();

  @$internal
  @override
  $ProviderElement<GoogleMailDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GoogleMailDatasource create(Ref ref) {
    return googleMailDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoogleMailDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoogleMailDatasource>(value),
    );
  }
}

String _$googleMailDatasourceHash() =>
    r'b76439864b03c33555220e86a0bbf31fb4413580';

@ProviderFor(microsoftMailDatasource)
const microsoftMailDatasourceProvider = MicrosoftMailDatasourceProvider._();

final class MicrosoftMailDatasourceProvider
    extends
        $FunctionalProvider<
          MicrosoftMailDatasource,
          MicrosoftMailDatasource,
          MicrosoftMailDatasource
        >
    with $Provider<MicrosoftMailDatasource> {
  const MicrosoftMailDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'microsoftMailDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$microsoftMailDatasourceHash();

  @$internal
  @override
  $ProviderElement<MicrosoftMailDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MicrosoftMailDatasource create(Ref ref) {
    return microsoftMailDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MicrosoftMailDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MicrosoftMailDatasource>(value),
    );
  }
}

String _$microsoftMailDatasourceHash() =>
    r'1f591d12584d84b81c5c4b9a76ed8844cc76ae41';

@ProviderFor(mailRepository)
const mailRepositoryProvider = MailRepositoryProvider._();

final class MailRepositoryProvider
    extends $FunctionalProvider<MailRepository, MailRepository, MailRepository>
    with $Provider<MailRepository> {
  const MailRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mailRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mailRepositoryHash();

  @$internal
  @override
  $ProviderElement<MailRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MailRepository create(Ref ref) {
    return mailRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MailRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MailRepository>(value),
    );
  }
}

String _$mailRepositoryHash() => r'1cdf680cf32e4d2af6569591cb8d2cfb64a4f2ed';

@ProviderFor(MailCondition)
const mailConditionProvider = MailConditionFamily._();

final class MailConditionProvider
    extends $NotifierProvider<MailCondition, MailListCondition> {
  const MailConditionProvider._({
    required MailConditionFamily super.from,
    required TabType super.argument,
  }) : super(
         retry: null,
         name: r'mailConditionProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$mailConditionHash();

  @override
  String toString() {
    return r'mailConditionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MailCondition create() => MailCondition();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MailListCondition value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MailListCondition>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MailConditionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mailConditionHash() => r'2c61ba0e719dd46ef0f165586e16044dc3a0d805';

final class MailConditionFamily extends $Family
    with
        $ClassFamilyOverride<
          MailCondition,
          MailListCondition,
          MailListCondition,
          MailListCondition,
          TabType
        > {
  const MailConditionFamily._()
    : super(
        retry: null,
        name: r'mailConditionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  MailConditionProvider call(TabType tabType) =>
      MailConditionProvider._(argument: tabType, from: this);

  @override
  String toString() => r'mailConditionProvider';
}

abstract class _$MailCondition extends $Notifier<MailListCondition> {
  late final _$args = ref.$arg as TabType;
  TabType get tabType => _$args;

  MailListCondition build(TabType tabType);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<MailListCondition, MailListCondition>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MailListCondition, MailListCondition>,
              MailListCondition,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
