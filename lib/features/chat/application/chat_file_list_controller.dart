import 'package:Visir/config/providers.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/application/chat_emoji_list_controller.dart';
import 'package:Visir/features/chat/application/chat_group_list_controller.dart';
import 'package:Visir/features/chat/application/chat_member_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_emoji_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_file_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/chat/domain/entities/state/message_uploading_temp_file_entity.dart';
import 'package:Visir/features/chat/infrastructure/repositories/message_repository.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/common/domain/failures/failure.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:emoji_extension/emoji_extension.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_file_list_controller.g.dart';

@riverpod
class ChatFileListController extends _$ChatFileListController {
  bool get isUploading => _controller.isUploading;
  late ChatFileListControllerInternal _controller;

  @override
  List<MessageUploadingTempFileEntity> build({required TabType tabType, bool isThread = false}) {
    final threadId = isThread ? ref.watch(chatConditionProvider(tabType).select((v) => v.threadId)) : null;
    final channelType = ref.watch(chatConditionProvider(tabType).select((v) => v.channel?.messageType));
    final teamId = ref.watch(chatConditionProvider(tabType).select((v) => v.channel?.teamId));
    final channelId = ref.watch(chatConditionProvider(tabType).select((v) => v.channel?.id));

    if (channelId == null) return [];
    if (channelType == null) return [];
    if (teamId == null) return [];

    final oauthUniqueId = ref.watch(
      localPrefControllerProvider.select(
        (v) => v.value?.messengerOAuths?.firstWhereOrNull((e) => e.teamId == teamId && e.type == channelType.oAuthType)?.uniqueId,
      ),
    );

    if (oauthUniqueId == null) return [];

    _controller = ref.watch(
      chatFileListControllerInternalProvider(tabType: tabType, oauthUniqueId: oauthUniqueId, channelId: channelId, threadId: threadId).notifier,
    );

    return ref.watch(chatFileListControllerInternalProvider(tabType: tabType, oauthUniqueId: oauthUniqueId, channelId: channelId, threadId: threadId));
  }

  Future<void> getFileUploadUrl({required MessageChannelEntityType type, required PlatformFile file}) async {
    return _controller.getFileUploadUrl(type: type, file: file);
  }

  void removeTemporaryFile({required PlatformFile file}) {
    _controller.removeTemporaryFile(file: file);
  }

  Future<List<MessageFileEntity>?> postFilesToChannel({required MessageChannelEntityType type, required String html}) async {
    return _controller.postFilesToChannel(type: type, html: html);
  }
}

@riverpod
class ChatFileListControllerInternal extends _$ChatFileListControllerInternal {
  late ChatRepository _repository;

  OAuthEntity get _oauth =>
      ref.read(localPrefControllerProvider.select((v) => v.value?.messengerOAuths?.firstWhereOrNull((e) => e.uniqueId == oauthUniqueId)))!;
  MessageChannelEntity get _channel =>
      ref.read(chatChannelListControllerProvider.select((v) => v.entries.expand((e) => e.value.channels).firstWhereOrNull((e) => e.id == channelId)))!;
  List<MessageChannelEntity> get channels => ref.read(chatChannelListControllerProvider).entries.expand((e) => e.value.channels).toList();
  List<MessageMemberEntity> get members => ref.read(chatMemberListControllerProvider(tabType: tabType)).members;
  List<MessageGroupEntity> get groups => ref.read(chatGroupListControllerProvider(tabType: tabType)).groups;
  List<MessageEmojiEntity> get emojis => ref.read(chatEmojiListControllerProvider(tabType: tabType)).emojis;

  bool get isUploading => state.any((e) => e.onProcess);

  @override
  List<MessageUploadingTempFileEntity> build({required TabType tabType, required String oauthUniqueId, required String channelId, required String? threadId}) {
    _repository = ref.watch(chatRepositoryProvider);
    return [];
  }

  Future<void> getFileUploadUrl({required MessageChannelEntityType type, required PlatformFile file}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) throw Failure.unauthorized(StackTrace.current);

    if (state.where((e) => e.file.identifier == file.identifier).toList().isNotEmpty) return;

    state = List.from(state)..add(MessageUploadingTempFileEntity(file: file, onProcess: true, uploadUrl: null, fileId: null, ok: null));

    final result = await _repository.getFileUploadUrl(type: type, oauth: _oauth, file: file);

    List<MessageUploadingTempFileEntity> oldData = List.from(state);

    int? index = oldData.indexWhere((e) => e.file.identifier == file.identifier);

    result.fold(
      (l) {
        oldData[index] = MessageUploadingTempFileEntity(file: file, onProcess: false, uploadUrl: null, fileId: null, ok: false);
        state = oldData;
      },
      (r) {
        oldData[index] = r;
        state = oldData;
      },
    );
  }

  void removeTemporaryFile({required PlatformFile file}) {
    List<MessageUploadingTempFileEntity> oldData = List.from(state);
    oldData.removeWhere((e) {
      return e.file.identifier == file.identifier;
    });
    state = oldData;
  }

  Future<List<MessageFileEntity>?> postFilesToChannel({required MessageChannelEntityType type, required String html}) async {
    final _pref = ref.read(localPrefControllerProvider).value;
    if (_pref == null) throw Failure.unauthorized(StackTrace.current);

    List<MessageUploadingTempFileEntity> fileDataList = state;
    if (fileDataList.isEmpty) return [];

    MessageEntity newMessageToConvertText = MessageEntity.fromHtml(
      type: _channel.messageType,
      html: html,
      currentChannel: _channel,
      channels: channels,
      files: [],
      meId: _channel.meId,
      members: members,
      groups: groups,
      emojis: emojis,
    );
    state = [];

    final result = await _repository.postFilesTochannel(
      type: type,
      oauth: _oauth,
      fileDataList: fileDataList,
      channelId: _channel.id,
      message: newMessageToConvertText,
      threadId: threadId,
    );

    return result.fold(
      (l) {
        state = fileDataList;
        return null;
      },
      (r) {
        return r;
      },
    );
  }
}
