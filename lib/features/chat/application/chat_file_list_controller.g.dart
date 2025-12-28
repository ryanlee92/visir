// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_file_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ChatFileListController)
const chatFileListControllerProvider = ChatFileListControllerFamily._();

final class ChatFileListControllerProvider
    extends
        $NotifierProvider<
          ChatFileListController,
          List<MessageUploadingTempFileEntity>
        > {
  const ChatFileListControllerProvider._({
    required ChatFileListControllerFamily super.from,
    required ({TabType tabType, bool isThread}) super.argument,
  }) : super(
         retry: null,
         name: r'chatFileListControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatFileListControllerHash();

  @override
  String toString() {
    return r'chatFileListControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ChatFileListController create() => ChatFileListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<MessageUploadingTempFileEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<List<MessageUploadingTempFileEntity>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatFileListControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatFileListControllerHash() =>
    r'c3a815ace6cf89a83c60810171cbbd749e3e3d28';

final class ChatFileListControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatFileListController,
          List<MessageUploadingTempFileEntity>,
          List<MessageUploadingTempFileEntity>,
          List<MessageUploadingTempFileEntity>,
          ({TabType tabType, bool isThread})
        > {
  const ChatFileListControllerFamily._()
    : super(
        retry: null,
        name: r'chatFileListControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatFileListControllerProvider call({
    required TabType tabType,
    bool isThread = false,
  }) => ChatFileListControllerProvider._(
    argument: (tabType: tabType, isThread: isThread),
    from: this,
  );

  @override
  String toString() => r'chatFileListControllerProvider';
}

abstract class _$ChatFileListController
    extends $Notifier<List<MessageUploadingTempFileEntity>> {
  late final _$args = ref.$arg as ({TabType tabType, bool isThread});
  TabType get tabType => _$args.tabType;
  bool get isThread => _$args.isThread;

  List<MessageUploadingTempFileEntity> build({
    required TabType tabType,
    bool isThread = false,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(tabType: _$args.tabType, isThread: _$args.isThread);
    final ref =
        this.ref
            as $Ref<
              List<MessageUploadingTempFileEntity>,
              List<MessageUploadingTempFileEntity>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                List<MessageUploadingTempFileEntity>,
                List<MessageUploadingTempFileEntity>
              >,
              List<MessageUploadingTempFileEntity>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(ChatFileListControllerInternal)
const chatFileListControllerInternalProvider =
    ChatFileListControllerInternalFamily._();

final class ChatFileListControllerInternalProvider
    extends
        $NotifierProvider<
          ChatFileListControllerInternal,
          List<MessageUploadingTempFileEntity>
        > {
  const ChatFileListControllerInternalProvider._({
    required ChatFileListControllerInternalFamily super.from,
    required ({
      TabType tabType,
      String oauthUniqueId,
      String channelId,
      String? threadId,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'chatFileListControllerInternalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatFileListControllerInternalHash();

  @override
  String toString() {
    return r'chatFileListControllerInternalProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ChatFileListControllerInternal create() => ChatFileListControllerInternal();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<MessageUploadingTempFileEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<List<MessageUploadingTempFileEntity>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatFileListControllerInternalProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatFileListControllerInternalHash() =>
    r'a5cc0a998a369e0cdc5af47ae36784fba7b1f5fa';

final class ChatFileListControllerInternalFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatFileListControllerInternal,
          List<MessageUploadingTempFileEntity>,
          List<MessageUploadingTempFileEntity>,
          List<MessageUploadingTempFileEntity>,
          ({
            TabType tabType,
            String oauthUniqueId,
            String channelId,
            String? threadId,
          })
        > {
  const ChatFileListControllerInternalFamily._()
    : super(
        retry: null,
        name: r'chatFileListControllerInternalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChatFileListControllerInternalProvider call({
    required TabType tabType,
    required String oauthUniqueId,
    required String channelId,
    required String? threadId,
  }) => ChatFileListControllerInternalProvider._(
    argument: (
      tabType: tabType,
      oauthUniqueId: oauthUniqueId,
      channelId: channelId,
      threadId: threadId,
    ),
    from: this,
  );

  @override
  String toString() => r'chatFileListControllerInternalProvider';
}

abstract class _$ChatFileListControllerInternal
    extends $Notifier<List<MessageUploadingTempFileEntity>> {
  late final _$args =
      ref.$arg
          as ({
            TabType tabType,
            String oauthUniqueId,
            String channelId,
            String? threadId,
          });
  TabType get tabType => _$args.tabType;
  String get oauthUniqueId => _$args.oauthUniqueId;
  String get channelId => _$args.channelId;
  String? get threadId => _$args.threadId;

  List<MessageUploadingTempFileEntity> build({
    required TabType tabType,
    required String oauthUniqueId,
    required String channelId,
    required String? threadId,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      tabType: _$args.tabType,
      oauthUniqueId: _$args.oauthUniqueId,
      channelId: _$args.channelId,
      threadId: _$args.threadId,
    );
    final ref =
        this.ref
            as $Ref<
              List<MessageUploadingTempFileEntity>,
              List<MessageUploadingTempFileEntity>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                List<MessageUploadingTempFileEntity>,
                List<MessageUploadingTempFileEntity>
              >,
              List<MessageUploadingTempFileEntity>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
