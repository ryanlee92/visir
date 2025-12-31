// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatListController)
const chatListControllerProvider = ChatListControllerFamily._();

final class ChatListControllerProvider
    extends $NotifierProvider<ChatListController, ChatFetchResultEntity?> {
  const ChatListControllerProvider._({
    required ChatListControllerFamily super.from,
    required TabType super.argument,
  }) : super(
         retry: null,
         name: r'chatListControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatListControllerHash();

  @override
  String toString() {
    return r'chatListControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatListController create() => ChatListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatFetchResultEntity? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatFetchResultEntity?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatListControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatListControllerHash() =>
    r'21243114c8f126248c3390fd295cb15bee02aa1f';

final class ChatListControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatListController,
          ChatFetchResultEntity?,
          ChatFetchResultEntity?,
          ChatFetchResultEntity?,
          TabType
        > {
  const ChatListControllerFamily._()
    : super(
        retry: null,
        name: r'chatListControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatListControllerProvider call({required TabType tabType}) =>
      ChatListControllerProvider._(argument: tabType, from: this);

  @override
  String toString() => r'chatListControllerProvider';
}

abstract class _$ChatListController extends $Notifier<ChatFetchResultEntity?> {
  late final _$args = ref.$arg as TabType;
  TabType get tabType => _$args;

  ChatFetchResultEntity? build({required TabType tabType});
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(tabType: _$args);
    final ref =
        this.ref as $Ref<ChatFetchResultEntity?, ChatFetchResultEntity?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatFetchResultEntity?, ChatFetchResultEntity?>,
              ChatFetchResultEntity?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ChatListControllerInternal)
const chatListControllerInternalProvider = ChatListControllerInternalFamily._();

final class ChatListControllerInternalProvider
    extends
        $AsyncNotifierProvider<
          ChatListControllerInternal,
          ChatFetchResultEntity?
        > {
  const ChatListControllerInternalProvider._({
    required ChatListControllerInternalFamily super.from,
    required ({
      bool isSignedIn,
      String channelId,
      String? targetMessageId,
      String oauthUniqueId,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'chatListControllerInternalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatListControllerInternalHash();

  @override
  String toString() {
    return r'chatListControllerInternalProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ChatListControllerInternal create() => ChatListControllerInternal();

  @override
  bool operator ==(Object other) {
    return other is ChatListControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatListControllerInternalHash() =>
    r'710061325902b5548c47766c81ca86ae6e82c21a';

final class ChatListControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatListControllerInternal,
          AsyncValue<ChatFetchResultEntity?>,
          ChatFetchResultEntity?,
          FutureOr<ChatFetchResultEntity?>,
          ({
            bool isSignedIn,
            String channelId,
            String? targetMessageId,
            String oauthUniqueId,
          })
        > {
  const ChatListControllerInternalFamily._()
    : super(
        retry: null,
        name: r'chatListControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatListControllerInternalProvider call({
    required bool isSignedIn,
    required String channelId,
    required String? targetMessageId,
    required String oauthUniqueId,
  }) => ChatListControllerInternalProvider._(
    argument: (
      isSignedIn: isSignedIn,
      channelId: channelId,
      targetMessageId: targetMessageId,
      oauthUniqueId: oauthUniqueId,
    ),
    from: this,
  );

  @override
  String toString() => r'chatListControllerInternalProvider';
}

abstract class _$ChatListControllerInternal
    extends $AsyncNotifier<ChatFetchResultEntity?> {
  late final _$args =
      ref.$arg
          as ({
            bool isSignedIn,
            String channelId,
            String? targetMessageId,
            String oauthUniqueId,
          });
  bool get isSignedIn => _$args.isSignedIn;
  String get channelId => _$args.channelId;
  String? get targetMessageId => _$args.targetMessageId;
  String get oauthUniqueId => _$args.oauthUniqueId;

  FutureOr<ChatFetchResultEntity?> build({
    required bool isSignedIn,
    required String channelId,
    required String? targetMessageId,
    required String oauthUniqueId,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      isSignedIn: _$args.isSignedIn,
      channelId: _$args.channelId,
      targetMessageId: _$args.targetMessageId,
      oauthUniqueId: _$args.oauthUniqueId,
    );
    final ref =
        this.ref
            as $Ref<AsyncValue<ChatFetchResultEntity?>, ChatFetchResultEntity?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ChatFetchResultEntity?>,
                ChatFetchResultEntity?
              >,
              AsyncValue<ChatFetchResultEntity?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
