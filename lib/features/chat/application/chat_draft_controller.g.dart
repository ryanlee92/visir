// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_draft_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatDraftController)
const chatDraftControllerProvider = ChatDraftControllerFamily._();

final class ChatDraftControllerProvider
    extends $NotifierProvider<ChatDraftController, ChatDraftEntity?> {
  const ChatDraftControllerProvider._({
    required ChatDraftControllerFamily super.from,
    required ({String teamId, String channelId, String? threadId})
    super.argument,
  }) : super(
         retry: null,
         name: r'chatDraftControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatDraftControllerHash();

  @override
  String toString() {
    return r'chatDraftControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ChatDraftController create() => ChatDraftController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatDraftEntity? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatDraftEntity?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatDraftControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatDraftControllerHash() =>
    r'0f53b919d1bb9841a069a6b973f4941cf2f82ef7';

final class ChatDraftControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatDraftController,
          ChatDraftEntity?,
          ChatDraftEntity?,
          ChatDraftEntity?,
          ({String teamId, String channelId, String? threadId})
        > {
  const ChatDraftControllerFamily._()
    : super(
        retry: null,
        name: r'chatDraftControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatDraftControllerProvider call({
    required String teamId,
    required String channelId,
    String? threadId,
  }) => ChatDraftControllerProvider._(
    argument: (teamId: teamId, channelId: channelId, threadId: threadId),
    from: this,
  );

  @override
  String toString() => r'chatDraftControllerProvider';
}

abstract class _$ChatDraftController extends $Notifier<ChatDraftEntity?> {
  late final _$args =
      ref.$arg as ({String teamId, String channelId, String? threadId});
  String get teamId => _$args.teamId;
  String get channelId => _$args.channelId;
  String? get threadId => _$args.threadId;

  ChatDraftEntity? build({
    required String teamId,
    required String channelId,
    String? threadId,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      teamId: _$args.teamId,
      channelId: _$args.channelId,
      threadId: _$args.threadId,
    );
    final ref = this.ref as $Ref<ChatDraftEntity?, ChatDraftEntity?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatDraftEntity?, ChatDraftEntity?>,
              ChatDraftEntity?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ChatDraftControllerInternal)
const chatDraftControllerInternalProvider =
    ChatDraftControllerInternalFamily._();

final class ChatDraftControllerInternalProvider
    extends
        $AsyncNotifierProvider<ChatDraftControllerInternal, ChatDraftEntity?> {
  const ChatDraftControllerInternalProvider._({
    required ChatDraftControllerInternalFamily super.from,
    required (String, String, String?, bool) super.argument,
  }) : super(
         retry: null,
         name: r'chatDraftControllerInternalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatDraftControllerInternalHash();

  @override
  String toString() {
    return r'chatDraftControllerInternalProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ChatDraftControllerInternal create() => ChatDraftControllerInternal();

  @override
  bool operator ==(Object other) {
    return other is ChatDraftControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatDraftControllerInternalHash() =>
    r'2582986222d15f8b9cd698f62a995b875b802c51';

final class ChatDraftControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatDraftControllerInternal,
          AsyncValue<ChatDraftEntity?>,
          ChatDraftEntity?,
          FutureOr<ChatDraftEntity?>,
          (String, String, String?, bool)
        > {
  const ChatDraftControllerInternalFamily._()
    : super(
        retry: null,
        name: r'chatDraftControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatDraftControllerInternalProvider call(
    String teamId,
    String channelId,
    String? threadId,
    bool isSignedIn,
  ) => ChatDraftControllerInternalProvider._(
    argument: (teamId, channelId, threadId, isSignedIn),
    from: this,
  );

  @override
  String toString() => r'chatDraftControllerInternalProvider';
}

abstract class _$ChatDraftControllerInternal
    extends $AsyncNotifier<ChatDraftEntity?> {
  late final _$args = ref.$arg as (String, String, String?, bool);
  String get teamId => _$args.$1;
  String get channelId => _$args.$2;
  String? get threadId => _$args.$3;
  bool get isSignedIn => _$args.$4;

  FutureOr<ChatDraftEntity?> build(
    String teamId,
    String channelId,
    String? threadId,
    bool isSignedIn,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args.$1, _$args.$2, _$args.$3, _$args.$4);
    final ref =
        this.ref as $Ref<AsyncValue<ChatDraftEntity?>, ChatDraftEntity?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ChatDraftEntity?>, ChatDraftEntity?>,
              AsyncValue<ChatDraftEntity?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
