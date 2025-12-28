// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'last_app_open_close_date_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(lastAppOpenCloseDate)
const lastAppOpenCloseDateProvider = LastAppOpenCloseDateProvider._();

final class LastAppOpenCloseDateProvider
    extends $FunctionalProvider<DateTime?, DateTime?, DateTime?>
    with $Provider<DateTime?> {
  const LastAppOpenCloseDateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lastAppOpenCloseDateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lastAppOpenCloseDateHash();

  @$internal
  @override
  $ProviderElement<DateTime?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime? create(Ref ref) {
    return lastAppOpenCloseDate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }
}

String _$lastAppOpenCloseDateHash() =>
    r'6b9505d308ff5451c4ce201bbe4d4b1ece4d4eef';

@ProviderFor(LastAppOpenCloseDateControllerInternal)
const lastAppOpenCloseDateControllerInternalProvider =
    LastAppOpenCloseDateControllerInternalFamily._();

final class LastAppOpenCloseDateControllerInternalProvider
    extends
        $NotifierProvider<LastAppOpenCloseDateControllerInternal, DateTime?> {
  const LastAppOpenCloseDateControllerInternalProvider._({
    required LastAppOpenCloseDateControllerInternalFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'lastAppOpenCloseDateControllerInternalProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$lastAppOpenCloseDateControllerInternalHash();

  @override
  String toString() {
    return r'lastAppOpenCloseDateControllerInternalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LastAppOpenCloseDateControllerInternal create() =>
      LastAppOpenCloseDateControllerInternal();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LastAppOpenCloseDateControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lastAppOpenCloseDateControllerInternalHash() =>
    r'143377880a9603fa9676d253a014e2f96234a9c3';

final class LastAppOpenCloseDateControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          LastAppOpenCloseDateControllerInternal,
          DateTime?,
          DateTime?,
          DateTime?,
          bool
        > {
  const LastAppOpenCloseDateControllerInternalFamily._()
    : super(
        retry: null,
        name: r'lastAppOpenCloseDateControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  LastAppOpenCloseDateControllerInternalProvider call({
    required bool isSignedIn,
  }) => LastAppOpenCloseDateControllerInternalProvider._(
    argument: isSignedIn,
    from: this,
  );

  @override
  String toString() => r'lastAppOpenCloseDateControllerInternalProvider';
}

abstract class _$LastAppOpenCloseDateControllerInternal
    extends $Notifier<DateTime?> {
  late final _$args = ref.$arg as bool;
  bool get isSignedIn => _$args;

  DateTime? build({required bool isSignedIn});
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(isSignedIn: _$args);
    final ref = this.ref as $Ref<DateTime?, DateTime?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime?, DateTime?>,
              DateTime?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
