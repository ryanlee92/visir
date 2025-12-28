// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_pref_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LocalPrefControllerInternal)
const localPrefControllerInternalProvider =
    LocalPrefControllerInternalFamily._();

final class LocalPrefControllerInternalProvider
    extends
        $AsyncNotifierProvider<LocalPrefControllerInternal, LocalPrefEntity> {
  const LocalPrefControllerInternalProvider._({
    required LocalPrefControllerInternalFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'localPrefControllerInternalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$localPrefControllerInternalHash();

  @override
  String toString() {
    return r'localPrefControllerInternalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  LocalPrefControllerInternal create() => LocalPrefControllerInternal();

  @override
  bool operator ==(Object other) {
    return other is LocalPrefControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$localPrefControllerInternalHash() =>
    r'67b48d5d8a4d9b685601da5385bd7ad31c09773b';

final class LocalPrefControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          LocalPrefControllerInternal,
          AsyncValue<LocalPrefEntity>,
          LocalPrefEntity,
          FutureOr<LocalPrefEntity>,
          bool
        > {
  const LocalPrefControllerInternalFamily._()
    : super(
        retry: null,
        name: r'localPrefControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LocalPrefControllerInternalProvider call({required bool isSignedIn}) =>
      LocalPrefControllerInternalProvider._(argument: isSignedIn, from: this);

  @override
  String toString() => r'localPrefControllerInternalProvider';
}

abstract class _$LocalPrefControllerInternal
    extends $AsyncNotifier<LocalPrefEntity> {
  late final _$args = ref.$arg as bool;
  bool get isSignedIn => _$args;

  FutureOr<LocalPrefEntity> build({required bool isSignedIn});
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(isSignedIn: _$args);
    final ref = this.ref as $Ref<AsyncValue<LocalPrefEntity>, LocalPrefEntity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LocalPrefEntity>, LocalPrefEntity>,
              AsyncValue<LocalPrefEntity>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
