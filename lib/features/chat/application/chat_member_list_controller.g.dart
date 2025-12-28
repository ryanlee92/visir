// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_member_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatMemberListController)
const chatMemberListControllerProvider = ChatMemberListControllerFamily._();

final class ChatMemberListControllerProvider
    extends
        $NotifierProvider<
          ChatMemberListController,
          ChatFetchMembersResultEntity
        > {
  const ChatMemberListControllerProvider._({
    required ChatMemberListControllerFamily super.from,
    required TabType super.argument,
  }) : super(
         retry: null,
         name: r'chatMemberListControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatMemberListControllerHash();

  @override
  String toString() {
    return r'chatMemberListControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatMemberListController create() => ChatMemberListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatFetchMembersResultEntity value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatFetchMembersResultEntity>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatMemberListControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatMemberListControllerHash() =>
    r'1aa4a97a3bf05d60af89a4ec48dd6583ed65b80e';

final class ChatMemberListControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatMemberListController,
          ChatFetchMembersResultEntity,
          ChatFetchMembersResultEntity,
          ChatFetchMembersResultEntity,
          TabType
        > {
  const ChatMemberListControllerFamily._()
    : super(
        retry: null,
        name: r'chatMemberListControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatMemberListControllerProvider call({required TabType tabType}) =>
      ChatMemberListControllerProvider._(argument: tabType, from: this);

  @override
  String toString() => r'chatMemberListControllerProvider';
}

abstract class _$ChatMemberListController
    extends $Notifier<ChatFetchMembersResultEntity> {
  late final _$args = ref.$arg as TabType;
  TabType get tabType => _$args;

  ChatFetchMembersResultEntity build({required TabType tabType});
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(tabType: _$args);
    final ref =
        this.ref
            as $Ref<ChatFetchMembersResultEntity, ChatFetchMembersResultEntity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ChatFetchMembersResultEntity,
                ChatFetchMembersResultEntity
              >,
              ChatFetchMembersResultEntity,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ChatMemberListControllerInternal)
const chatMemberListControllerInternalProvider =
    ChatMemberListControllerInternalFamily._();

final class ChatMemberListControllerInternalProvider
    extends
        $NotifierProvider<
          ChatMemberListControllerInternal,
          MessageMemberEntity?
        > {
  const ChatMemberListControllerInternalProvider._({
    required ChatMemberListControllerInternalFamily super.from,
    required ({bool isSignedIn, String userId, String oauthUniqueId})
    super.argument,
  }) : super(
         retry: null,
         name: r'chatMemberListControllerInternalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatMemberListControllerInternalHash();

  @override
  String toString() {
    return r'chatMemberListControllerInternalProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ChatMemberListControllerInternal create() =>
      ChatMemberListControllerInternal();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MessageMemberEntity? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MessageMemberEntity?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatMemberListControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatMemberListControllerInternalHash() =>
    r'78296e885e82eb39affec1b7e5cbafeea2db6925';

final class ChatMemberListControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatMemberListControllerInternal,
          MessageMemberEntity?,
          MessageMemberEntity?,
          MessageMemberEntity?,
          ({bool isSignedIn, String userId, String oauthUniqueId})
        > {
  const ChatMemberListControllerInternalFamily._()
    : super(
        retry: null,
        name: r'chatMemberListControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatMemberListControllerInternalProvider call({
    required bool isSignedIn,
    required String userId,
    required String oauthUniqueId,
  }) => ChatMemberListControllerInternalProvider._(
    argument: (
      isSignedIn: isSignedIn,
      userId: userId,
      oauthUniqueId: oauthUniqueId,
    ),
    from: this,
  );

  @override
  String toString() => r'chatMemberListControllerInternalProvider';
}

abstract class _$ChatMemberListControllerInternal
    extends $Notifier<MessageMemberEntity?> {
  late final _$args =
      ref.$arg as ({bool isSignedIn, String userId, String oauthUniqueId});
  bool get isSignedIn => _$args.isSignedIn;
  String get userId => _$args.userId;
  String get oauthUniqueId => _$args.oauthUniqueId;

  MessageMemberEntity? build({
    required bool isSignedIn,
    required String userId,
    required String oauthUniqueId,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      isSignedIn: _$args.isSignedIn,
      userId: _$args.userId,
      oauthUniqueId: _$args.oauthUniqueId,
    );
    final ref = this.ref as $Ref<MessageMemberEntity?, MessageMemberEntity?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MessageMemberEntity?, MessageMemberEntity?>,
              MessageMemberEntity?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
