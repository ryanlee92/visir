import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/common/domain/entities/connection_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_delta_from_html/parser/html_to_delta.dart' as html_to_delta;
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart' as quill_delta_to_html;

class AgentTagController extends QuillController {
  bool _tagListVisible = false;
  String? _editingMessageId;

  List<TaskEntity> taggedTasks = [];
  List<EventEntity> taggedEvents = [];
  List<InboxEntity> taggedInboxes = [];
  List<ConnectionEntity> taggedConnections = [];
  List<MessageChannelEntity> taggedChannels = [];
  List<ProjectEntity> taggedProjects = [];

  AgentTagController({String? text})
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

  set tagListVisible(bool value) {
    _tagListVisible = value;
    // notifyListeners();
  }

  bool get tagListVisible => _tagListVisible;

  set editingMessageId(String? value) {
    if (value == _editingMessageId) return;
    _editingMessageId = value;
    try {
      notifyListeners();
    } catch (e) {
      // Controller may be disposed, ignore
      if (!e.toString().contains('disposed')) {
        rethrow;
      }
    }
  }

  String? get editingMessageId => _editingMessageId;

  String get text => document.toPlainText();
  String get html {
    final ops = document.toDelta().toJson();
    final converter = quill_delta_to_html.QuillDeltaToHtmlConverter(ops, quill_delta_to_html.ConverterOptions.forEmail());

    final html = converter.convert();
    return html;
  }

  set text(String value) {
    // Document.fromJson은 마지막 줄이 \n으로 끝나야 함
    final textWithNewline = value.endsWith('\n') ? value : '$value\n';
    document = Document.fromJson([
      {'insert': textWithNewline},
    ]);
    try {
      notifyListeners();
    } catch (e) {
      // Controller may be disposed, ignore
      if (!e.toString().contains('disposed')) {
        rethrow;
      }
    }
  }

  TextEditingValue get value => TextEditingValue(text: text, selection: selection);

  set value(TextEditingValue value) {
    document = Document.fromJson([
      {'insert': value.text},
    ]);
    try {
      updateSelection(value.selection, ChangeSource.local);
      notifyListeners();
    } catch (e) {
      // Controller may be disposed, ignore
      if (!e.toString().contains('disposed')) {
        rethrow;
      }
    }
  }

  bool get isMobileView => PlatformX.isMobileView;

  @override
  void updateSelection(TextSelection newSelection, ChangeSource source) {
    try {
      super.updateSelection(newSelection, source);
    } catch (e) {
      // Controller may be disposed, ignore
      if (!e.toString().contains('disposed')) {
        rethrow;
      }
    }
  }

  void addTaggedData({TaskEntity? task, EventEntity? event, InboxEntity? inbox, ConnectionEntity? connection, MessageChannelEntity? channel, ProjectEntity? project}) {
    if (task != null) taggedTasks.add(task);
    if (event != null) taggedEvents.add(event);
    if (inbox != null) taggedInboxes.add(inbox);
    if (connection != null) taggedConnections.add(connection);
    if (channel != null) taggedChannels.add(channel);
    if (project != null) taggedProjects.add(project);
  }

  @override
  void clear() {
    editingMessageId = null;
    taggedTasks.clear();
    taggedEvents.clear();
    taggedInboxes.clear();
    taggedConnections.clear();
    taggedChannels.clear();
    taggedProjects.clear();
    document = Document();
  }

  void setData({required String html, required String? editingMessageId}) {
    document = Document.fromJson(html_to_delta.HtmlToDelta().convert(html, transformTableAsEmbed: false).toJson());
    this.editingMessageId = editingMessageId;
    try {
      notifyListeners();
    } catch (e) {
      // Controller may be disposed, ignore
      if (!e.toString().contains('disposed')) {
        rethrow;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}

