// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_channel_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatChannelListController)
const chatChannelListControllerProvider = ChatChannelListControllerProvider._();

final class ChatChannelListControllerProvider
    extends
        $NotifierProvider<
          ChatChannelListController,
          Map<String, MessageChannelFetchResultEntity>
        > {
  const ChatChannelListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatChannelListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatChannelListControllerHash();

  @$internal
  @override
  ChatChannelListController create() => ChatChannelListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    Map<String, MessageChannelFetchResultEntity> value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<Map<String, MessageChannelFetchResultEntity>>(
            value,
          ),
    );
  }
}

String _$chatChannelListControllerHash() =>
    r'0f9b9c0adf0bc806bff96f058bb2b9d3daa9223b';

abstract class _$ChatChannelListController
    extends $Notifier<Map<String, MessageChannelFetchResultEntity>> {
  Map<String, MessageChannelFetchResultEntity> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              Map<String, MessageChannelFetchResultEntity>,
              Map<String, MessageChannelFetchResultEntity>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, MessageChannelFetchResultEntity>,
                Map<String, MessageChannelFetchResultEntity>
              >,
              Map<String, MessageChannelFetchResultEntity>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ChatChannelListControllerInternal)
const chatChannelListControllerInternalProvider =
    ChatChannelListControllerInternalFamily._();

final class ChatChannelListControllerInternalProvider
    extends
        $AsyncNotifierProvider<
          ChatChannelListControllerInternal,
          Map<String, MessageChannelFetchResultEntity>
        > {
  const ChatChannelListControllerInternalProvider._({
    required ChatChannelListControllerInternalFamily super.from,
    required ({bool isSignedIn, String oauthUniqueId}) super.argument,
  }) : super(
         retry: null,
         name: r'chatChannelListControllerInternalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$chatChannelListControllerInternalHash();

  @override
  String toString() {
    return r'chatChannelListControllerInternalProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ChatChannelListControllerInternal create() =>
      ChatChannelListControllerInternal();

  @override
  bool operator ==(Object other) {
    return other is ChatChannelListControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatChannelListControllerInternalHash() =>
    r'00612c3ab14785794546ae7dd7096f449cc06e51';

final class ChatChannelListControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatChannelListControllerInternal,
          AsyncValue<Map<String, MessageChannelFetchResultEntity>>,
          Map<String, MessageChannelFetchResultEntity>,
          FutureOr<Map<String, MessageChannelFetchResultEntity>>,
          ({bool isSignedIn, String oauthUniqueId})
        > {
  const ChatChannelListControllerInternalFamily._()
    : super(
        retry: null,
        name: r'chatChannelListControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatChannelListControllerInternalProvider call({
    required bool isSignedIn,
    required String oauthUniqueId,
  }) => ChatChannelListControllerInternalProvider._(
    argument: (isSignedIn: isSignedIn, oauthUniqueId: oauthUniqueId),
    from: this,
  );

  @override
  String toString() => r'chatChannelListControllerInternalProvider';
}

abstract class _$ChatChannelListControllerInternal
    extends $AsyncNotifier<Map<String, MessageChannelFetchResultEntity>> {
  late final _$args = ref.$arg as ({bool isSignedIn, String oauthUniqueId});
  bool get isSignedIn => _$args.isSignedIn;
  String get oauthUniqueId => _$args.oauthUniqueId;

  FutureOr<Map<String, MessageChannelFetchResultEntity>> build({
    required bool isSignedIn,
    required String oauthUniqueId,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      isSignedIn: _$args.isSignedIn,
      oauthUniqueId: _$args.oauthUniqueId,
    );
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Map<String, MessageChannelFetchResultEntity>>,
              Map<String, MessageChannelFetchResultEntity>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<String, MessageChannelFetchResultEntity>>,
                Map<String, MessageChannelFetchResultEntity>
              >,
              AsyncValue<Map<String, MessageChannelFetchResultEntity>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
