// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(NotificationControllerInternal)
const notificationControllerInternalProvider =
    NotificationControllerInternalFamily._();

final class NotificationControllerInternalProvider
    extends
        $AsyncNotifierProvider<
          NotificationControllerInternal,
          NotificationEntity?
        > {
  const NotificationControllerInternalProvider._({
    required NotificationControllerInternalFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'notificationControllerInternalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$notificationControllerInternalHash();

  @override
  String toString() {
    return r'notificationControllerInternalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  NotificationControllerInternal create() => NotificationControllerInternal();

  @override
  bool operator ==(Object other) {
    return other is NotificationControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$notificationControllerInternalHash() =>
    r'0181f81691e545de4e23e7fedf444a6050319018';

final class NotificationControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          NotificationControllerInternal,
          AsyncValue<NotificationEntity?>,
          NotificationEntity?,
          FutureOr<NotificationEntity?>,
          bool
        > {
  const NotificationControllerInternalFamily._()
    : super(
        retry: null,
        name: r'notificationControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NotificationControllerInternalProvider call({required bool isSignedIn}) =>
      NotificationControllerInternalProvider._(
        argument: isSignedIn,
        from: this,
      );

  @override
  String toString() => r'notificationControllerInternalProvider';
}

abstract class _$NotificationControllerInternal
    extends $AsyncNotifier<NotificationEntity?> {
  late final _$args = ref.$arg as bool;
  bool get isSignedIn => _$args;

  FutureOr<NotificationEntity?> build({required bool isSignedIn});
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(isSignedIn: _$args);
    final ref =
        this.ref as $Ref<AsyncValue<NotificationEntity?>, NotificationEntity?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<NotificationEntity?>, NotificationEntity?>,
              AsyncValue<NotificationEntity?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
