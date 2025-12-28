// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(slackMessageDatasource)
const slackMessageDatasourceProvider = SlackMessageDatasourceProvider._();

final class SlackMessageDatasourceProvider
    extends
        $FunctionalProvider<
          SlackMessageDatasource,
          SlackMessageDatasource,
          SlackMessageDatasource
        >
    with $Provider<SlackMessageDatasource> {
  const SlackMessageDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'slackMessageDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$slackMessageDatasourceHash();

  @$internal
  @override
  $ProviderElement<SlackMessageDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SlackMessageDatasource create(Ref ref) {
    return slackMessageDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SlackMessageDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SlackMessageDatasource>(value),
    );
  }
}

String _$slackMessageDatasourceHash() =>
    r'6079a182677f91f77aaee815ad7b24e02555ef76';

@ProviderFor(chatRepository)
const chatRepositoryProvider = ChatRepositoryProvider._();

final class ChatRepositoryProvider
    extends $FunctionalProvider<ChatRepository, ChatRepository, ChatRepository>
    with $Provider<ChatRepository> {
  const ChatRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatRepositoryHash();

  @$internal
  @override
  $ProviderElement<ChatRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ChatRepository create(Ref ref) {
    return chatRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatRepository>(value),
    );
  }
}

String _$chatRepositoryHash() => r'0252823444a082c4868d42b299f88a7f9a556dbd';

@ProviderFor(ChatCondition)
const chatConditionProvider = ChatConditionFamily._();

final class ChatConditionProvider
    extends $NotifierProvider<ChatCondition, ChatListCondition> {
  const ChatConditionProvider._({
    required ChatConditionFamily super.from,
    required TabType super.argument,
  }) : super(
         retry: null,
         name: r'chatConditionProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatConditionHash();

  @override
  String toString() {
    return r'chatConditionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatCondition create() => ChatCondition();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatListCondition value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatListCondition>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatConditionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatConditionHash() => r'14def0c2ae3191080dcba47b5223e6ef13edcf1a';

final class ChatConditionFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatCondition,
          ChatListCondition,
          ChatListCondition,
          ChatListCondition,
          TabType
        > {
  const ChatConditionFamily._()
    : super(
        retry: null,
        name: r'chatConditionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ChatConditionProvider call(TabType tabType) =>
      ChatConditionProvider._(argument: tabType, from: this);

  @override
  String toString() => r'chatConditionProvider';
}

abstract class _$ChatCondition extends $Notifier<ChatListCondition> {
  late final _$args = ref.$arg as TabType;
  TabType get tabType => _$args;

  ChatListCondition build(TabType tabType);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<ChatListCondition, ChatListCondition>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatListCondition, ChatListCondition>,
              ChatListCondition,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ChatChannelStateList)
const chatChannelStateListProvider = ChatChannelStateListFamily._();

final class ChatChannelStateListProvider
    extends
        $NotifierProvider<
          ChatChannelStateList,
          Map<String, ChatChannelSection>
        > {
  const ChatChannelStateListProvider._({
    required ChatChannelStateListFamily super.from,
    required TabType super.argument,
  }) : super(
         retry: null,
         name: r'chatChannelStateListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatChannelStateListHash();

  @override
  String toString() {
    return r'chatChannelStateListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatChannelStateList create() => ChatChannelStateList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, ChatChannelSection> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, ChatChannelSection>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatChannelStateListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatChannelStateListHash() =>
    r'6b23e04aae6c405e13f8b82a77864ff13da73882';

final class ChatChannelStateListFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatChannelStateList,
          Map<String, ChatChannelSection>,
          Map<String, ChatChannelSection>,
          Map<String, ChatChannelSection>,
          TabType
        > {
  const ChatChannelStateListFamily._()
    : super(
        retry: null,
        name: r'chatChannelStateListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatChannelStateListProvider call(TabType tabType) =>
      ChatChannelStateListProvider._(argument: tabType, from: this);

  @override
  String toString() => r'chatChannelStateListProvider';
}

abstract class _$ChatChannelStateList
    extends $Notifier<Map<String, ChatChannelSection>> {
  late final _$args = ref.$arg as TabType;
  TabType get tabType => _$args;

  Map<String, ChatChannelSection> build(TabType tabType);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<
              Map<String, ChatChannelSection>,
              Map<String, ChatChannelSection>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, ChatChannelSection>,
                Map<String, ChatChannelSection>
              >,
              Map<String, ChatChannelSection>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ChatLastChannel)
const chatLastChannelProvider = ChatLastChannelFamily._();

final class ChatLastChannelProvider
    extends $NotifierProvider<ChatLastChannel, List<String>> {
  const ChatLastChannelProvider._({
    required ChatLastChannelFamily super.from,
    required TabType super.argument,
  }) : super(
         retry: null,
         name: r'chatLastChannelProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatLastChannelHash();

  @override
  String toString() {
    return r'chatLastChannelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatLastChannel create() => ChatLastChannel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatLastChannelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatLastChannelHash() => r'5c2d9aaef680500d0104e9cf9ab890b1e3f1c1e7';

final class ChatLastChannelFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatLastChannel,
          List<String>,
          List<String>,
          List<String>,
          TabType
        > {
  const ChatLastChannelFamily._()
    : super(
        retry: null,
        name: r'chatLastChannelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ChatLastChannelProvider call(TabType tabType) =>
      ChatLastChannelProvider._(argument: tabType, from: this);

  @override
  String toString() => r'chatLastChannelProvider';
}

abstract class _$ChatLastChannel extends $Notifier<List<String>> {
  late final _$args = ref.$arg as TabType;
  TabType get tabType => _$args;

  List<String> build(TabType tabType);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
