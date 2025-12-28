// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_thread_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatThreadListController)
const chatThreadListControllerProvider = ChatThreadListControllerFamily._();

final class ChatThreadListControllerProvider
    extends
        $NotifierProvider<
          ChatThreadListController,
          MessageThreadFetchResultEntity?
        > {
  const ChatThreadListControllerProvider._({
    required ChatThreadListControllerFamily super.from,
    required TabType super.argument,
  }) : super(
         retry: null,
         name: r'chatThreadListControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatThreadListControllerHash();

  @override
  String toString() {
    return r'chatThreadListControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatThreadListController create() => ChatThreadListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MessageThreadFetchResultEntity? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MessageThreadFetchResultEntity?>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatThreadListControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatThreadListControllerHash() =>
    r'4459b9300244c35888d76c493d96791e82ad2836';

final class ChatThreadListControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatThreadListController,
          MessageThreadFetchResultEntity?,
          MessageThreadFetchResultEntity?,
          MessageThreadFetchResultEntity?,
          TabType
        > {
  const ChatThreadListControllerFamily._()
    : super(
        retry: null,
        name: r'chatThreadListControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatThreadListControllerProvider call({required TabType tabType}) =>
      ChatThreadListControllerProvider._(argument: tabType, from: this);

  @override
  String toString() => r'chatThreadListControllerProvider';
}

abstract class _$ChatThreadListController
    extends $Notifier<MessageThreadFetchResultEntity?> {
  late final _$args = ref.$arg as TabType;
  TabType get tabType => _$args;

  MessageThreadFetchResultEntity? build({required TabType tabType});
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(tabType: _$args);
    final ref =
        this.ref
            as $Ref<
              MessageThreadFetchResultEntity?,
              MessageThreadFetchResultEntity?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                MessageThreadFetchResultEntity?,
                MessageThreadFetchResultEntity?
              >,
              MessageThreadFetchResultEntity?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ChatThreadListControllerInternal)
const chatThreadListControllerInternalProvider =
    ChatThreadListControllerInternalFamily._();

final class ChatThreadListControllerInternalProvider
    extends
        $AsyncNotifierProvider<
          ChatThreadListControllerInternal,
          MessageThreadFetchResultEntity?
        > {
  const ChatThreadListControllerInternalProvider._({
    required ChatThreadListControllerInternalFamily super.from,
    required ({
      bool isSignedIn,
      String channelId,
      String threadId,
      String oauthUniqueId,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'chatThreadListControllerInternalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatThreadListControllerInternalHash();

  @override
  String toString() {
    return r'chatThreadListControllerInternalProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ChatThreadListControllerInternal create() =>
      ChatThreadListControllerInternal();

  @override
  bool operator ==(Object other) {
    return other is ChatThreadListControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatThreadListControllerInternalHash() =>
    r'b1406c2910c3e360612308bc361a6d6db55dc92b';

final class ChatThreadListControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatThreadListControllerInternal,
          AsyncValue<MessageThreadFetchResultEntity?>,
          MessageThreadFetchResultEntity?,
          FutureOr<MessageThreadFetchResultEntity?>,
          ({
            bool isSignedIn,
            String channelId,
            String threadId,
            String oauthUniqueId,
          })
        > {
  const ChatThreadListControllerInternalFamily._()
    : super(
        retry: null,
        name: r'chatThreadListControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatThreadListControllerInternalProvider call({
    required bool isSignedIn,
    required String channelId,
    required String threadId,
    required String oauthUniqueId,
  }) => ChatThreadListControllerInternalProvider._(
    argument: (
      isSignedIn: isSignedIn,
      channelId: channelId,
      threadId: threadId,
      oauthUniqueId: oauthUniqueId,
    ),
    from: this,
  );

  @override
  String toString() => r'chatThreadListControllerInternalProvider';
}

abstract class _$ChatThreadListControllerInternal
    extends $AsyncNotifier<MessageThreadFetchResultEntity?> {
  late final _$args =
      ref.$arg
          as ({
            bool isSignedIn,
            String channelId,
            String threadId,
            String oauthUniqueId,
          });
  bool get isSignedIn => _$args.isSignedIn;
  String get channelId => _$args.channelId;
  String get threadId => _$args.threadId;
  String get oauthUniqueId => _$args.oauthUniqueId;

  FutureOr<MessageThreadFetchResultEntity?> build({
    required bool isSignedIn,
    required String channelId,
    required String threadId,
    required String oauthUniqueId,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      isSignedIn: _$args.isSignedIn,
      channelId: _$args.channelId,
      threadId: _$args.threadId,
      oauthUniqueId: _$args.oauthUniqueId,
    );
    final ref =
        this.ref
            as $Ref<
              AsyncValue<MessageThreadFetchResultEntity?>,
              MessageThreadFetchResultEntity?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<MessageThreadFetchResultEntity?>,
                MessageThreadFetchResultEntity?
              >,
              AsyncValue<MessageThreadFetchResultEntity?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
