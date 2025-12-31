// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_emoji_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatEmojiListController)
const chatEmojiListControllerProvider = ChatEmojiListControllerFamily._();

final class ChatEmojiListControllerProvider
    extends
        $NotifierProvider<
          ChatEmojiListController,
          ChatFetchEmojisResultEntity
        > {
  const ChatEmojiListControllerProvider._({
    required ChatEmojiListControllerFamily super.from,
    required TabType super.argument,
  }) : super(
         retry: null,
         name: r'chatEmojiListControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatEmojiListControllerHash();

  @override
  String toString() {
    return r'chatEmojiListControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatEmojiListController create() => ChatEmojiListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatFetchEmojisResultEntity value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatFetchEmojisResultEntity>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatEmojiListControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatEmojiListControllerHash() =>
    r'569652910cbdc150e53e7e0b03ca5bdc361706af';

final class ChatEmojiListControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatEmojiListController,
          ChatFetchEmojisResultEntity,
          ChatFetchEmojisResultEntity,
          ChatFetchEmojisResultEntity,
          TabType
        > {
  const ChatEmojiListControllerFamily._()
    : super(
        retry: null,
        name: r'chatEmojiListControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatEmojiListControllerProvider call({required TabType tabType}) =>
      ChatEmojiListControllerProvider._(argument: tabType, from: this);

  @override
  String toString() => r'chatEmojiListControllerProvider';
}

abstract class _$ChatEmojiListController
    extends $Notifier<ChatFetchEmojisResultEntity> {
  late final _$args = ref.$arg as TabType;
  TabType get tabType => _$args;

  ChatFetchEmojisResultEntity build({required TabType tabType});
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(tabType: _$args);
    final ref =
        this.ref
            as $Ref<ChatFetchEmojisResultEntity, ChatFetchEmojisResultEntity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ChatFetchEmojisResultEntity,
                ChatFetchEmojisResultEntity
              >,
              ChatFetchEmojisResultEntity,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ChatEmojiListControllerInternal)
const chatEmojiListControllerInternalProvider =
    ChatEmojiListControllerInternalFamily._();

final class ChatEmojiListControllerInternalProvider
    extends
        $AsyncNotifierProvider<
          ChatEmojiListControllerInternal,
          ChatFetchEmojisResultEntity
        > {
  const ChatEmojiListControllerInternalProvider._({
    required ChatEmojiListControllerInternalFamily super.from,
    required ({
      bool isSignedIn,
      MessageChannelEntityType type,
      String oauthUniqueId,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'chatEmojiListControllerInternalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatEmojiListControllerInternalHash();

  @override
  String toString() {
    return r'chatEmojiListControllerInternalProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ChatEmojiListControllerInternal create() => ChatEmojiListControllerInternal();

  @override
  bool operator ==(Object other) {
    return other is ChatEmojiListControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatEmojiListControllerInternalHash() =>
    r'32b50092cc8137db8b78530cd93508a56b58639c';

final class ChatEmojiListControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatEmojiListControllerInternal,
          AsyncValue<ChatFetchEmojisResultEntity>,
          ChatFetchEmojisResultEntity,
          FutureOr<ChatFetchEmojisResultEntity>,
          ({
            bool isSignedIn,
            MessageChannelEntityType type,
            String oauthUniqueId,
          })
        > {
  const ChatEmojiListControllerInternalFamily._()
    : super(
        retry: null,
        name: r'chatEmojiListControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatEmojiListControllerInternalProvider call({
    required bool isSignedIn,
    required MessageChannelEntityType type,
    required String oauthUniqueId,
  }) => ChatEmojiListControllerInternalProvider._(
    argument: (
      isSignedIn: isSignedIn,
      type: type,
      oauthUniqueId: oauthUniqueId,
    ),
    from: this,
  );

  @override
  String toString() => r'chatEmojiListControllerInternalProvider';
}

abstract class _$ChatEmojiListControllerInternal
    extends $AsyncNotifier<ChatFetchEmojisResultEntity> {
  late final _$args =
      ref.$arg
          as ({
            bool isSignedIn,
            MessageChannelEntityType type,
            String oauthUniqueId,
          });
  bool get isSignedIn => _$args.isSignedIn;
  MessageChannelEntityType get type => _$args.type;
  String get oauthUniqueId => _$args.oauthUniqueId;

  FutureOr<ChatFetchEmojisResultEntity> build({
    required bool isSignedIn,
    required MessageChannelEntityType type,
    required String oauthUniqueId,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      isSignedIn: _$args.isSignedIn,
      type: _$args.type,
      oauthUniqueId: _$args.oauthUniqueId,
    );
    final ref =
        this.ref
            as $Ref<
              AsyncValue<ChatFetchEmojisResultEntity>,
              ChatFetchEmojisResultEntity
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ChatFetchEmojisResultEntity>,
                ChatFetchEmojisResultEntity
              >,
              AsyncValue<ChatFetchEmojisResultEntity>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
