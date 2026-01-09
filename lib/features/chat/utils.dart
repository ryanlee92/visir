import 'dart:typed_data';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/chat/application/chat_file_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_delta_from_html/parser/html_to_delta.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:uuid/uuid.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

Future<void> pasteFileFromClipboard({required CustomTagController controller, required bool isReply, required TabType tabType, required MessageChannelEntity channel}) async {
  final clipboard = SystemClipboard.instance;
  if (clipboard == null) return;

  final reader = await clipboard.read();

  for (final item in reader.items) {
    await item.getFile(null, (file) async {
      String fileName = file.fileName ?? Uuid().v4();
      Uint8List? bytes = await file.readAll();
      String? mimeType = lookupMimeType('', headerBytes: bytes);

      if (mimeType == null) {
        controller.clipboardPaste();
        return;
      }

      if (controller.editingMessageId != null) return;

      // fileName 없는 경우: MIME 타입으로 분기
      if (file.fileName == null) {
        final ext = extensionFromMime(mimeType);
        fileName = 'Clipboard_${DateFormat(DateFormat.YEAR_ABBR_MONTH_DAY).add_Hms().format(DateTime.now())}.$ext';
      }

      final platformFile = PlatformFile(name: fileName, size: bytes.lengthInBytes, bytes: bytes, identifier: fileName);
      await Utils.ref.read(chatFileListControllerProvider(tabType: tabType, isThread: isReply).notifier).getFileUploadUrl(type: channel.type, file: platformFile);
    });
  }
}

class CustomTagController extends QuillController {
  List<MessageChannelEntity> channels;
  MessageChannelEntity? channel;

  MessageMemberEntity? me;
  String? _editingMessageId;

  List<MessageMemberEntity> taggedMembers = [];
  List<MessageGroupEntity> taggedGroups = [];
  List<MessageChannelEntity> taggedChannels = [];

  CustomTagController({required this.channel, required this.channels, String? text})
    : super(
        config: const QuillControllerConfig(clipboardConfig: QuillClipboardConfig(enableExternalRichPaste: false)),
        document: text?.isNotEmpty != true
            ? Document()
            : Document.fromJson([
                {'insert': text},
              ]),
        selection: const TextSelection.collapsed(offset: 0),
      ) {
    // addListener(_handleTextChange);
  }

  set editingMessageId(String? value) {
    if (value == _editingMessageId) return;
    _editingMessageId = value;
    notifyListeners();
  }

  String? get editingMessageId => _editingMessageId;

  String get text => document.toPlainText();
  String get html {
    final ops = document.toDelta().toJson();
    final converter = QuillDeltaToHtmlConverter(ops, ConverterOptions.forEmail());

    final html = converter.convert();
    return html;
  }

  set text(String value) {
    document = Document.fromJson([
      {'insert': value},
    ]);
    notifyListeners();
  }

  TextEditingValue get value => TextEditingValue(text: text, selection: selection);

  set value(TextEditingValue value) {
    document = Document.fromJson([
      {'insert': value.text},
    ]);
    updateSelection(value.selection, ChangeSource.local);
    notifyListeners();
  }

  bool get isMobileView => PlatformX.isMobileView;

  void setChannel(MessageChannelEntity channel) {
    this.channel = channel;
    notifyListeners();
  }

  void addTaggedData({MessageMemberEntity? member, MessageGroupEntity? group, MessageChannelEntity? channel}) {
    if (member != null) taggedMembers.add(member);
    if (group != null) taggedGroups.add(group);
    if (channel != null) taggedChannels.add(channel);
  }

  @override
  void clear() {
    editingMessageId = null;
    document = Document();
  }

  void setData({required String html, required String? editingMessageId}) {
    document = Document.fromJson(HtmlToDelta().convert(html, transformTableAsEmbed: false).toJson());
    this.editingMessageId = editingMessageId;
    notifyListeners();
  }
}
