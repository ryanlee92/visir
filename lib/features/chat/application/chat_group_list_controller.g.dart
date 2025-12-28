// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_group_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatGroupListController)
const chatGroupListControllerProvider = ChatGroupListControllerFamily._();

final class ChatGroupListControllerProvider
    extends
        $NotifierProvider<
          ChatGroupListController,
          ChatFetchGroupsResultEntity
        > {
  const ChatGroupListControllerProvider._({
    required ChatGroupListControllerFamily super.from,
    required TabType super.argument,
  }) : super(
         retry: null,
         name: r'chatGroupListControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatGroupListControllerHash();

  @override
  String toString() {
    return r'chatGroupListControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatGroupListController create() => ChatGroupListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatFetchGroupsResultEntity value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatFetchGroupsResultEntity>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatGroupListControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatGroupListControllerHash() =>
    r'322825d525d58c41ba0629244cfcf44b4a984812';

final class ChatGroupListControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatGroupListController,
          ChatFetchGroupsResultEntity,
          ChatFetchGroupsResultEntity,
          ChatFetchGroupsResultEntity,
          TabType
        > {
  const ChatGroupListControllerFamily._()
    : super(
        retry: null,
        name: r'chatGroupListControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatGroupListControllerProvider call({required TabType tabType}) =>
      ChatGroupListControllerProvider._(argument: tabType, from: this);

  @override
  String toString() => r'chatGroupListControllerProvider';
}

abstract class _$ChatGroupListController
    extends $Notifier<ChatFetchGroupsResultEntity> {
  late final _$args = ref.$arg as TabType;
  TabType get tabType => _$args;

  ChatFetchGroupsResultEntity build({required TabType tabType});
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(tabType: _$args);
    final ref =
        this.ref
            as $Ref<ChatFetchGroupsResultEntity, ChatFetchGroupsResultEntity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                ChatFetchGroupsResultEntity,
                ChatFetchGroupsResultEntity
              >,
              ChatFetchGroupsResultEntity,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ChatGroupListControllerInternal)
const chatGroupListControllerInternalProvider =
    ChatGroupListControllerInternalFamily._();

final class ChatGroupListControllerInternalProvider
    extends
        $AsyncNotifierProvider<
          ChatGroupListControllerInternal,
          ChatFetchGroupsResultEntity
        > {
  const ChatGroupListControllerInternalProvider._({
    required ChatGroupListControllerInternalFamily super.from,
    required ({
      bool isSignedIn,
      MessageChannelEntityType type,
      String oauthUniqueId,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'chatGroupListControllerInternalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatGroupListControllerInternalHash();

  @override
  String toString() {
    return r'chatGroupListControllerInternalProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ChatGroupListControllerInternal create() => ChatGroupListControllerInternal();

  @override
  bool operator ==(Object other) {
    return other is ChatGroupListControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatGroupListControllerInternalHash() =>
    r'058fa0c1ca7751acd40a6d5ce51c583994b138b2';

final class ChatGroupListControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatGroupListControllerInternal,
          AsyncValue<ChatFetchGroupsResultEntity>,
          ChatFetchGroupsResultEntity,
          FutureOr<ChatFetchGroupsResultEntity>,
          ({
            bool isSignedIn,
            MessageChannelEntityType type,
            String oauthUniqueId,
          })
        > {
  const ChatGroupListControllerInternalFamily._()
    : super(
        retry: null,
        name: r'chatGroupListControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatGroupListControllerInternalProvider call({
    required bool isSignedIn,
    required MessageChannelEntityType type,
    required String oauthUniqueId,
  }) => ChatGroupListControllerInternalProvider._(
    argument: (
      isSignedIn: isSignedIn,
      type: type,
      oauthUniqueId: oauthUniqueId,
    ),
    from: this,
  );

  @override
  String toString() => r'chatGroupListControllerInternalProvider';
}

abstract class _$ChatGroupListControllerInternal
    extends $AsyncNotifier<ChatFetchGroupsResultEntity> {
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

  FutureOr<ChatFetchGroupsResultEntity> build({
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
              AsyncValue<ChatFetchGroupsResultEntity>,
              ChatFetchGroupsResultEntity
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ChatFetchGroupsResultEntity>,
                ChatFetchGroupsResultEntity
              >,
              AsyncValue<ChatFetchGroupsResultEntity>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
