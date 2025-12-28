import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/toasty_box/model/toast_model.dart';
import 'package:Visir/features/chat/actions.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/application/chat_draft_controller.dart';
import 'package:Visir/features/chat/application/chat_file_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/chat_draft_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_emoji_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_tag_entity.dart';
import 'package:Visir/features/chat/presentation/widgets/chat_input/message_temporary_file_list.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/chat/utils.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/bottom_dialog_option.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class MessageInputField extends ConsumerStatefulWidget {
  final CustomTagController messageController;
  final FocusNode focusNode;
  final bool isFromInbox;
  final VoidCallback highlightNextTag;
  final VoidCallback highlightPreviousTag;
  final VoidCallback enterTag;
  final bool Function() onPressEscape;
  final MessageChannelEntity channel;
  final List<MessageChannelEntity> channels;
  final List<MessageMemberEntity> members;
  final List<MessageGroupEntity> groups;
  final List<MessageEmojiEntity> emojis;
  final bool isThread;
  final bool isEdit;
  final TabType tabType;
  final String? threadId;

  final VoidCallback? onLastMessageSelected;
  final bool Function(KeyEvent event)? onKeyDown;
  final bool Function(KeyEvent event)? onKeyRepeat;

  const MessageInputField({
    super.key,
    required this.messageController,
    required this.focusNode,
    required this.isFromInbox,
    required this.highlightNextTag,
    required this.highlightPreviousTag,
    required this.enterTag,
    required this.onPressEscape,
    required this.channel,
    required this.channels,
    required this.isThread,
    required this.tabType,
    required this.isEdit,
    required this.members,
    required this.groups,
    required this.emojis,
    this.threadId,
    this.onLastMessageSelected,
    this.onKeyDown,
    this.onKeyRepeat,
  });

  @override
  ConsumerState<MessageInputField> createState() => MessageInputFieldState();
}

class MessageInputFieldState extends ConsumerState<MessageInputField> {
  bool get isMobileView => PlatformX.isMobileView;
  bool get isDarkMode => context.isDarkMode;
  bool get isFromInbox => widget.isFromInbox;

  CustomTagController get messageController => widget.messageController;
  bool get tagListVisible => widget.messageController.tagListVisible;
  VoidCallback get highlightNextTag => widget.highlightNextTag;
  VoidCallback get highlightPreviousTag => widget.highlightPreviousTag;
  VoidCallback get enterTag => widget.enterTag;

  VoidCallback? toggleBold;
  VoidCallback? toggleItalic;
  VoidCallback? toggleStrikeThrough;
  VoidCallback? toggleInlineCode;
  VoidCallback? toggleListNumbers;
  VoidCallback? toggleListBullets;
  VoidCallback? toggleCodeBlock;
  VoidCallback? toggleQuote;

  Offset? caretOffset;

  GlobalKey<QuillEditorState> editorKey = GlobalKey<QuillEditorState>();
  QuillEditor? editor;

  void requestFocus() {
    if (PlatformX.isMobileView) {
      widget.messageController.skipRequestKeyboard = false;
    }
    widget.focusNode.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.focusNode.requestFocus();
    });
  }

  Widget buildToggleButton({
    required VisirIconType icon,
    required QuillToolbarToggleStyleButtonExtraOptions extraOptions,
    required String tooltip,
    List<LogicalKeyboardKey>? keys,
  }) {
    return VisirButton(
      type: VisirButtonAnimationType.scaleAndOpacity,
      isSelected: extraOptions.isToggled,
      style: VisirButtonStyle(padding: EdgeInsets.all(6), borderRadius: BorderRadius.circular(6)),
      options: VisirButtonOptions(
        tabType: widget.tabType,
        message: keys != null ? null : tooltip,
        tooltipLocation: VisirButtonTooltipLocation.top,
        doNotConvertCase: true,
        shortcuts: keys != null ? [VisirButtonKeyboardShortcut(keys: keys, message: tooltip)] : null,
      ),
      onTap: () {
        extraOptions.onPressed?.call();
        widget.focusNode.requestFocus();
      },
      child: VisirIcon(type: icon, color: !widget.focusNode.hasFocus ? context.inverseSurface : context.onBackground, size: 14),
    );
  }

  Offset? getCaretOffset() {
    final editorState = editorKey.currentState;

    final renderEditor = editorState?.editableTextKey.currentState?.renderEditor;
    final height = editorKey.currentContext?.size?.height;

    final selection = messageController.selection;

    if (height != null && renderEditor != null && selection.baseOffset != -1) {
      final caretRect = renderEditor.getLocalRectForCaret(TextPosition(offset: selection.baseOffset));

      return Offset(caretRect.left, height - caretRect.top);
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    widget.messageController.addListener(onChangeContent);
    tabNotifier.addListener(onTabChanged);
  }

  void onTabChanged() {
    if (PlatformX.isMobileView) return;
    if (tabNotifier.value != widget.tabType) {
      widget.focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    tabNotifier.removeListener(onTabChanged);
    widget.messageController.removeListener(onChangeContent);
    super.dispose();
  }

  void onChangeContent() {
    final html = widget.messageController.html;
    final editingMessageId = widget.messageController.editingMessageId;
    ref
        .read(chatDraftControllerProvider(teamId: widget.channel.teamId, channelId: widget.channel.id, threadId: widget.threadId).notifier)
        .setDraft(
          ChatDraftEntity(
            id: Uuid().v4(),
            teamId: widget.channel.teamId,
            channelId: widget.channel.id,
            threadId: widget.threadId,
            content: html,
            editingMessageId: editingMessageId,
          ),
        );
  }

  bool initialDraftSetted = false;

  ValueNotifier<bool> sendingFailedMessageInputFieldNotifier = ValueNotifier(false);
  String get teamId => ref.read(chatConditionProvider(widget.tabType).select((v) => v.channel!.teamId));
  List<MessageChannelEntity> get channels => ref.read(chatChannelListControllerProvider.select((v) => v[teamId]?.channels ?? []));
  List<MessageMemberEntity> get members => ref.read(chatChannelListControllerProvider.select((v) => v[teamId]?.members ?? []));
  List<MessageGroupEntity> get groups => ref.read(chatChannelListControllerProvider.select((v) => v[teamId]?.groups ?? []));
  List<MessageEmojiEntity> get emojis => ref.read(chatChannelListControllerProvider.select((v) => v[teamId]?.emojis ?? []));

  void clearMessage() {
    messageController.clear();
    ref.read(chatDraftControllerProvider(teamId: widget.channel.teamId, channelId: widget.channel.id, threadId: widget.threadId).notifier).setDraft(null);
  }

  Future<bool> postMessage({required bool uploadble, required String html}) async {
    if (onPickingFiles) return true;
    if (!uploadble) return true;

    if (ref.read(chatFileListControllerProvider(tabType: widget.tabType, isThread: widget.isThread).notifier).isUploading == true) {
      Utils.showToast(
        ToastModel(
          message: TextSpan(text: context.tr.file_uploading_message_error),
          buttons: [],
        ),
      );
      return true;
    }

    final editingId = messageController.editingMessageId;

    final taggedMembers = messageController.taggedMembers;
    final taggedGroups = messageController.taggedGroups;
    final taggedChannels = messageController.taggedChannels;

    final finalMembers = [...members, ...taggedMembers].toSet().toList();
    final finalGroups = [...groups, ...taggedGroups].toSet().toList();
    final finalChannels = [...channels, ...taggedChannels].toSet().toList();

    clearMessage();

    bool result = false;
    if (widget.isThread && editingId != widget.threadId) {
      result = await MessageAction.postReply(
        id: editingId,
        tabType: widget.tabType,
        html: html,
        channel: widget.channel,
        channels: finalChannels,
        members: finalMembers,
        groups: finalGroups,
        emojis: emojis,
        threadId: widget.threadId!,
      );
    } else {
      result = await MessageAction.postMessage(
        id: editingId,
        tabType: widget.tabType,
        html: html,
        channel: widget.channel,
        channels: finalChannels,
        members: finalMembers,
        groups: finalGroups,
        emojis: emojis,
      );
    }

    if (result) {
      // scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      return true;
    } else {
      messageController.setData(editingMessageId: editingId, html: html);
      sendingFailedMessageInputFieldNotifier.value = true;
      Future.delayed(Duration(milliseconds: 1000), () {
        sendingFailedMessageInputFieldNotifier.value = false;
      });

      return false;
    }
  }

  Future<void> uploadFiles({required List<PlatformFile> files}) async {
    if (files.isNotEmpty) {
      files.forEach((f) async {
        final compressedFile = await Utils.compressOnlyVideoFileInMobile(originalFile: f);
        ref
            .read(chatFileListControllerProvider(tabType: widget.tabType, isThread: false).notifier)
            .getFileUploadUrl(type: widget.channel.type, file: compressedFile);
      });
    }
  }

  bool onPickingFiles = false;

  Future<void> onPressUpload() async {
    if (onPickingFiles) return;

    if (isMobileView) {
      Utils.showBottomDialog(
        title: TextSpan(text: context.tr.chat_upload),
        body: Column(
          children: [
            BottomDialogOption(
              icon: VisirIconType.photo,
              title: context.tr.chat_photo_or_video,
              onTap: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.media, allowMultiple: true, compressionQuality: 100);

                if (result == null) return;
                uploadFiles(files: result.files);
              },
            ),
            BottomDialogOption(
              icon: VisirIconType.file,
              title: context.tr.chat_file,
              onTap: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

                if (result == null) return;
                uploadFiles(files: result.files);
              },
            ),
          ],
        ),
      );
    } else {
      FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

      if (result == null) return;
      uploadFiles(files: result.files);
    }
  }

  bool uploadable = false;

  @override
  Widget build(BuildContext context) {
    ref.listen(chatDraftControllerProvider(teamId: widget.channel.teamId, channelId: widget.channel.id, threadId: widget.threadId), (previous, next) {
      final draft = next;
      if (draft != null && draft.content.isNotEmpty) {
        widget.messageController.setData(html: draft.content, editingMessageId: draft.editingMessageId);
        widget.messageController.updateSelection(TextSelection.collapsed(offset: draft.content.length), ChangeSource.local);
      }
    });

    final messageFileList = ref.watch(chatFileListControllerProvider(tabType: widget.tabType, isThread: widget.isThread).select((v) => v));
    bool uploadable = messageController.text.trim().isNotEmpty || messageFileList.where((e) => (e.ok ?? false)).toList().isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: MessageTemporaryFileList(isReply: widget.isThread, tabType: widget.tabType),
              ),
            ),
            SizedBox(height: 6),
            Row(
              children: [
                SizedBox(width: 6),
                QuillSimpleToolbar(
                  controller: widget.messageController,
                  config: QuillSimpleToolbarConfig(
                    buttonOptions: QuillSimpleToolbarButtonOptions(
                      bold: QuillToolbarToggleStyleButtonOptions(
                        childBuilder: (dynamic o1, dynamic o2) {
                          final extraOptions = o2 as QuillToolbarToggleStyleButtonExtraOptions;
                          toggleBold = extraOptions.onPressed;
                          return buildToggleButton(
                            icon: VisirIconType.formatBold,
                            extraOptions: extraOptions,
                            tooltip: 'Bold',
                            keys: [LogicalKeyboardKey.keyB, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                          );
                        },
                      ),
                      italic: QuillToolbarToggleStyleButtonOptions(
                        childBuilder: (dynamic o1, dynamic o2) {
                          final extraOptions = o2 as QuillToolbarToggleStyleButtonExtraOptions;
                          toggleItalic = extraOptions.onPressed;
                          return buildToggleButton(
                            icon: VisirIconType.formatItalic,
                            extraOptions: extraOptions,
                            tooltip: 'Italic',
                            keys: [LogicalKeyboardKey.keyI, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                          );
                        },
                      ),
                      strikeThrough: QuillToolbarToggleStyleButtonOptions(
                        childBuilder: (dynamic o1, dynamic o2) {
                          final extraOptions = o2 as QuillToolbarToggleStyleButtonExtraOptions;
                          toggleStrikeThrough = extraOptions.onPressed;
                          return buildToggleButton(
                            icon: VisirIconType.formatStrikethrough,
                            extraOptions: extraOptions,
                            tooltip: 'Strikethrough',
                            keys: [
                              LogicalKeyboardKey.keyX,
                              LogicalKeyboardKey.shift,
                              if (PlatformX.isApple) LogicalKeyboardKey.meta,
                              if (!PlatformX.isApple) LogicalKeyboardKey.control,
                            ],
                          );
                        },
                      ),
                      inlineCode: QuillToolbarToggleStyleButtonOptions(
                        childBuilder: (dynamic o1, dynamic o2) {
                          final extraOptions = o2 as QuillToolbarToggleStyleButtonExtraOptions;
                          toggleInlineCode = extraOptions.onPressed;
                          return buildToggleButton(
                            icon: VisirIconType.formatInlineCode,
                            extraOptions: extraOptions,
                            tooltip: 'Inline Code',
                            keys: [
                              LogicalKeyboardKey.keyC,
                              LogicalKeyboardKey.shift,
                              if (PlatformX.isApple) LogicalKeyboardKey.meta,
                              if (!PlatformX.isApple) LogicalKeyboardKey.control,
                            ],
                          );
                        },
                      ),
                      listNumbers: QuillToolbarToggleStyleButtonOptions(
                        childBuilder: (dynamic o1, dynamic o2) {
                          final extraOptions = o2 as QuillToolbarToggleStyleButtonExtraOptions;
                          toggleListNumbers = extraOptions.onPressed;
                          return buildToggleButton(
                            icon: VisirIconType.formatListNumbers,
                            extraOptions: extraOptions,
                            tooltip: 'List Numbers',
                            keys: [
                              LogicalKeyboardKey.digit7,
                              LogicalKeyboardKey.shift,
                              if (PlatformX.isApple) LogicalKeyboardKey.meta,
                              if (!PlatformX.isApple) LogicalKeyboardKey.control,
                            ],
                          );
                        },
                      ),
                      listBullets: QuillToolbarToggleStyleButtonOptions(
                        childBuilder: (dynamic o1, dynamic o2) {
                          final extraOptions = o2 as QuillToolbarToggleStyleButtonExtraOptions;
                          toggleListBullets = extraOptions.onPressed;
                          return buildToggleButton(
                            icon: VisirIconType.formatListBullets,
                            extraOptions: extraOptions,
                            tooltip: 'List Bullets',
                            keys: [
                              LogicalKeyboardKey.digit8,
                              LogicalKeyboardKey.shift,
                              if (PlatformX.isApple) LogicalKeyboardKey.meta,
                              if (!PlatformX.isApple) LogicalKeyboardKey.control,
                            ],
                          );
                        },
                      ),
                      codeBlock: QuillToolbarToggleStyleButtonOptions(
                        childBuilder: (dynamic o1, dynamic o2) {
                          final extraOptions = o2 as QuillToolbarToggleStyleButtonExtraOptions;
                          toggleCodeBlock = extraOptions.onPressed;
                          return buildToggleButton(
                            icon: VisirIconType.formatCodeBlock,
                            extraOptions: extraOptions,
                            tooltip: 'Code Block',
                            keys: [
                              LogicalKeyboardKey.keyC,
                              LogicalKeyboardKey.shift,
                              LogicalKeyboardKey.alt,
                              if (PlatformX.isApple) LogicalKeyboardKey.meta,
                              if (!PlatformX.isApple) LogicalKeyboardKey.control,
                            ],
                          );
                        },
                      ),
                      quote: QuillToolbarToggleStyleButtonOptions(
                        childBuilder: (dynamic o1, dynamic o2) {
                          final extraOptions = o2 as QuillToolbarToggleStyleButtonExtraOptions;
                          toggleQuote = extraOptions.onPressed;
                          return buildToggleButton(
                            icon: VisirIconType.formatQuote,
                            extraOptions: extraOptions,
                            tooltip: 'Quote',
                            keys: [
                              LogicalKeyboardKey.digit9,
                              LogicalKeyboardKey.shift,
                              if (PlatformX.isApple) LogicalKeyboardKey.meta,
                              if (!PlatformX.isApple) LogicalKeyboardKey.control,
                            ],
                          );
                        },
                      ),
                    ),
                    showFontFamily: false,
                    showFontSize: false,
                    showDividers: false,
                    showBoldButton: true,
                    showItalicButton: true,
                    showSmallButton: false,
                    showUnderLineButton: false,
                    showLineHeightButton: false,
                    showStrikeThrough: true,
                    showInlineCode: true,
                    showColorButton: false,
                    showBackgroundColorButton: false,
                    showClearFormat: false,
                    showAlignmentButtons: false,
                    showLeftAlignment: false,
                    showCenterAlignment: false,
                    showRightAlignment: false,
                    showJustifyAlignment: false,
                    showHeaderStyle: false,
                    showListNumbers: true,
                    showListBullets: true,
                    showListCheck: false,
                    showCodeBlock: true,
                    showQuote: true,
                    showIndent: false,
                    showLink: false,
                    showUndo: false,
                    showRedo: false,
                    showDirection: false,
                    showSearchButton: false,
                    showSubscript: false,
                    showSuperscript: false,
                  ),
                ),
              ],
            ),
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IntrinsicWidth(
                    child: VisirButton(
                      enabled: messageController.editingMessageId == null,
                      type: VisirButtonAnimationType.scaleAndOpacity,
                      style: VisirButtonStyle(
                        padding: EdgeInsets.all(6),
                        borderRadius: BorderRadius.circular(4),
                        margin: EdgeInsets.only(left: 6, bottom: context.textFieldPadding(context.titleSmall!.fontSize!) / 2),
                      ),
                      options: VisirButtonOptions(
                        message: context.tr.attach,
                        customShortcutTooltip: context.tr.drag_and_drop,
                        tooltipLocation: VisirButtonTooltipLocation.top,
                        doNotConvertCase: true,
                      ),
                      onTap: onPressUpload,
                      child: onPickingFiles
                          ? CustomCircularLoadingIndicator(size: 14, color: widget.focusNode.hasFocus ? context.onInverseSurface : context.surface)
                          : SizedBox(
                              width: 14,
                              height: 14,
                              child: VisirIcon(type: VisirIconType.file, size: 14, isSelected: widget.focusNode.hasFocus),
                            ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        constraints: BoxConstraints(maxHeight: isMobileView ? 140 : 280),
                        padding: EdgeInsets.only(left: 3, right: 3),
                        child: Padding(
                          padding: EdgeInsets.only(bottom: context.textFieldPadding(9), top: 6),
                          child: Builder(
                            builder: (context) {
                              final baseStyle = context.titleSmall!.textColor(context.outlineVariant);
                              Color inputHintColor = PlatformX.isDesktopView && isFromInbox ? context.inverseSurface : context.surfaceTint;
                              final baseHorizontalSpacing = HorizontalSpacing(0, 0);
                              final baseVerticalSpacing = VerticalSpacing(0, 0);

                              editor =
                                  editor ??
                                  QuillEditor(
                                    key: editorKey,
                                    controller: messageController,
                                    focusNode: widget.focusNode,
                                    scrollController: ScrollController(),
                                    cursorStyle: CursorStyle(
                                      color: context.primary,
                                      backgroundColor: Colors.transparent,
                                      width: 1,
                                      radius: Radius.zero,
                                      offset: Offset(
                                        0,
                                        PlatformX.isMacOS
                                            ? -1
                                            : PlatformX.isIOS
                                            ? 2 / context.devicePixelRatio
                                            : 0,
                                      ),
                                      paintAboveText: true,
                                      opacityAnimates: false,
                                    ),
                                    config: QuillEditorConfig(
                                      autoFocus: false,
                                      placeholder: [
                                        context.tr.chat_message,
                                        if (PlatformX.isDesktopView)
                                          (widget.onLastMessageSelected != null
                                              ? context.tr.chat_focus_last_message(
                                                  [
                                                    (PlatformX.isApple ? LogicalKeyboardKey.meta : LogicalKeyboardKey.control).title,
                                                    LogicalKeyboardKey.arrowUp.title,
                                                  ].join(),
                                                )
                                              : ''),
                                      ].join(' '),
                                      expands: false,
                                      onTapOutsideEnabled: PlatformX.isMobileView,
                                      scrollable: true,
                                      keyboardAppearance: context.isDarkMode ? Brightness.dark : Brightness.light,
                                      padding: EdgeInsets.only(top: 2, bottom: 3),
                                      textSpanBuilder: (context, node, textOffset, text, style, recognizer) {
                                        String remainingText = text;
                                        final List<InlineSpan> spans = [];
                                        final RegExp mentionRegex = RegExp(r'@([^@\n]+)|\u200b\u0040([^]*?)\u200b|\u200b\u0023([^]*?)\u200b', unicode: true);

                                        int offset = 0;

                                        final broadcastChannelTag = MessageTagEntity(type: MessageTagEntityType.broadcastChannel);
                                        final broadcastHereTag = MessageTagEntity(type: MessageTagEntityType.broadcastHere);
                                        final mentionMatches = mentionRegex.allMatches(text);
                                        final channels = widget.channels;
                                        final channel = channels.firstWhereOrNull((e) => e.id == widget.channel.id);
                                        for (final match in mentionMatches) {
                                          if (match.start > offset) {
                                            spans.add(TextSpan(text: text.substring(offset, match.start)));
                                          }

                                          final piece = text.substring(match.start, match.end);

                                          bool isTag = mentionRegex.hasMatch(piece);
                                          String tagName = isTag ? piece.replaceAll('@', '').replaceAll('\u200b', '') : '';

                                          MessageMemberEntity? targetMembers = [
                                            ...widget.members,
                                            ...widget.messageController.taggedMembers,
                                          ].where((e) => e.displayName != null && tagName.startsWith(e.displayName!)).firstOrNull;
                                          MessageGroupEntity? targetGroups = [
                                            ...widget.groups,
                                            ...widget.messageController.taggedGroups,
                                          ].where((e) => e.displayName != null && tagName.startsWith(e.displayName!)).firstOrNull;
                                          MessageChannelEntity? targetChannel = [
                                            ...widget.channels,
                                            ...widget.messageController.taggedChannels,
                                          ].where((e) => e.name != null && tagName.startsWith(e.name!)).firstOrNull;

                                          bool isMe = targetMembers?.id == channel?.meId;
                                          bool isMyGroup = targetGroups?.users?.contains(channel?.meId) ?? false;
                                          bool isBroadcastChannel = tagName == broadcastChannelTag.displayName;
                                          bool isBroadcastHere = tagName == broadcastHereTag.displayName;

                                          if (targetMembers != null) {
                                            final name = '@${targetMembers.displayName!}';
                                            final leftovers = piece.replaceAll(name, '');
                                            spans.add(
                                              TextSpan(
                                                text: name,
                                                style: TextStyle(color: isMe ? context.primary : context.secondary),
                                              ),
                                            );
                                            if (leftovers.isNotEmpty) spans.add(TextSpan(text: leftovers));
                                          } else if (targetGroups != null) {
                                            final name = '@${targetGroups.displayName!}';
                                            final leftovers = piece.replaceAll(name, '');
                                            spans.add(
                                              TextSpan(
                                                text: name,
                                                style: TextStyle(color: isMyGroup ? context.primary : context.secondary),
                                              ),
                                            );
                                            if (leftovers.isNotEmpty) spans.add(TextSpan(text: leftovers));
                                          } else if (targetChannel != null) {
                                            final name = '#${targetChannel.name!}';
                                            final leftovers = piece.replaceAll(name, '');
                                            spans.add(
                                              TextSpan(
                                                text: name,
                                                style: TextStyle(color: context.secondary),
                                              ),
                                            );
                                            if (leftovers.isNotEmpty) spans.add(TextSpan(text: leftovers));
                                          } else if (isBroadcastHere) {
                                            final name = '@${broadcastHereTag.displayName}';
                                            final leftovers = piece.replaceAll(name, '');
                                            spans.add(
                                              TextSpan(
                                                text: name,
                                                style: TextStyle(color: context.secondary),
                                              ),
                                            );
                                            if (leftovers.isNotEmpty) spans.add(TextSpan(text: leftovers));
                                          } else if (isBroadcastChannel) {
                                            final name = '@${broadcastChannelTag.displayName}';
                                            final leftovers = piece.replaceAll(name, '');
                                            spans.add(
                                              TextSpan(
                                                text: name,
                                                style: TextStyle(color: context.secondary),
                                              ),
                                            );
                                            if (leftovers.isNotEmpty) spans.add(TextSpan(text: leftovers));
                                          } else {
                                            spans.add(TextSpan(text: piece));
                                          }

                                          offset = match.end;
                                        }

                                        if (offset < text.length) {
                                          remainingText = text.substring(offset);
                                          spans.add(TextSpan(text: remainingText));
                                        }

                                        return TextSpan(children: spans, style: style);
                                      },
                                      onTapDown: (details, getPosition) {
                                        if (PlatformX.isMobileView) {
                                          widget.messageController.skipRequestKeyboard = false;
                                        }
                                        return false;
                                      },
                                      customStyles: DefaultStyles(
                                        h1: DefaultTextBlockStyle(
                                          baseStyle.copyWith(
                                            // fontSize: 34,
                                            // color: baseStyle.color,
                                            // letterSpacing: -0.5,
                                            // height: 1.083,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.none,
                                          ),
                                          baseHorizontalSpacing,
                                          VerticalSpacing.zero,
                                          VerticalSpacing.zero,
                                          null,
                                        ),
                                        h2: DefaultTextBlockStyle(
                                          baseStyle.copyWith(
                                            fontSize: 30,
                                            color: baseStyle.color,
                                            letterSpacing: -0.8,
                                            height: 1.067,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.none,
                                          ),
                                          baseHorizontalSpacing,
                                          VerticalSpacing.zero,
                                          VerticalSpacing.zero,
                                          null,
                                        ),
                                        h3: DefaultTextBlockStyle(
                                          baseStyle.copyWith(
                                            // fontSize: 24,
                                            // letterSpacing: -0.5,
                                            // height: 1.083,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.none,
                                          ),
                                          baseHorizontalSpacing,
                                          VerticalSpacing.zero,
                                          VerticalSpacing.zero,
                                          null,
                                        ),
                                        h4: DefaultTextBlockStyle(
                                          baseStyle.copyWith(
                                            // fontSize: 20,
                                            // letterSpacing: -0.4,
                                            // height: 1.1,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.none,
                                          ),
                                          baseHorizontalSpacing,
                                          VerticalSpacing.zero,
                                          VerticalSpacing.zero,
                                          null,
                                        ),
                                        h5: DefaultTextBlockStyle(
                                          baseStyle.copyWith(
                                            // fontSize: 18,
                                            // letterSpacing: -0.2,
                                            // height: 1.11,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.none,
                                          ),
                                          baseHorizontalSpacing,
                                          VerticalSpacing.zero,
                                          VerticalSpacing.zero,
                                          null,
                                        ),
                                        h6: DefaultTextBlockStyle(
                                          baseStyle.copyWith(
                                            // fontSize: 16,
                                            // letterSpacing: -0.1,
                                            // height: 1.125,
                                            fontWeight: FontWeight.bold,
                                            decoration: TextDecoration.none,
                                          ),
                                          baseHorizontalSpacing,
                                          VerticalSpacing.zero,
                                          VerticalSpacing.zero,
                                          null,
                                        ),
                                        lineHeightNormal: DefaultTextBlockStyle(
                                          baseStyle,
                                          baseHorizontalSpacing,
                                          VerticalSpacing.zero,
                                          VerticalSpacing.zero,
                                          null,
                                        ),
                                        lineHeightTight: DefaultTextBlockStyle(
                                          baseStyle,
                                          baseHorizontalSpacing,
                                          VerticalSpacing.zero,
                                          VerticalSpacing.zero,
                                          null,
                                        ),
                                        lineHeightOneAndHalf: DefaultTextBlockStyle(
                                          baseStyle,
                                          baseHorizontalSpacing,
                                          VerticalSpacing.zero,
                                          VerticalSpacing.zero,
                                          null,
                                        ),
                                        lineHeightDouble: DefaultTextBlockStyle(
                                          baseStyle,
                                          baseHorizontalSpacing,
                                          VerticalSpacing.zero,
                                          VerticalSpacing.zero,
                                          null,
                                        ),
                                        paragraph: DefaultTextBlockStyle(baseStyle, baseHorizontalSpacing, VerticalSpacing.zero, VerticalSpacing.zero, null),
                                        subscript: baseStyle.copyWith(fontFeatures: [FontFeature.liningFigures(), FontFeature.subscripts()]),
                                        superscript: baseStyle.copyWith(fontFeatures: [FontFeature.liningFigures(), FontFeature.superscripts()]),
                                        bold: TextStyle(fontWeight: FontWeight.bold),
                                        italic: TextStyle(fontStyle: FontStyle.italic),
                                        strikeThrough: TextStyle(decoration: TextDecoration.lineThrough),
                                        inlineCode: InlineCodeStyle(
                                          backgroundColor: context.surfaceVariant,
                                          radius: const Radius.circular(4),
                                          style: baseStyle,
                                          header1: baseStyle.copyWith(fontSize: 32, fontWeight: FontWeight.w500),
                                          header2: baseStyle.copyWith(fontSize: 22, fontWeight: FontWeight.w500),
                                          header3: baseStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w500),
                                        ),
                                        link: baseStyle.copyWith(color: context.primary, decoration: TextDecoration.underline),
                                        placeHolder: DefaultTextBlockStyle(
                                          baseStyle.textColor(inputHintColor),
                                          baseHorizontalSpacing,
                                          VerticalSpacing(0, 0),
                                          VerticalSpacing.zero,
                                          BoxDecoration(color: context.error),
                                        ),
                                        lists: DefaultListBlockStyle(baseStyle, baseHorizontalSpacing, baseVerticalSpacing, VerticalSpacing(0, 6), null, null),
                                        quote: DefaultTextBlockStyle(
                                          baseStyle.textColor(baseStyle.color!.withValues(alpha: 0.6)),
                                          baseHorizontalSpacing,
                                          baseVerticalSpacing,
                                          VerticalSpacing(6, 2),
                                          BoxDecoration(
                                            border: Border(left: BorderSide(width: 4, color: Colors.grey.shade300)),
                                          ),
                                        ),
                                        code: DefaultTextBlockStyle(
                                          baseStyle,
                                          baseHorizontalSpacing,
                                          baseVerticalSpacing,
                                          VerticalSpacing.zero,
                                          BoxDecoration(color: context.surfaceVariant, borderRadius: BorderRadius.circular(4)),
                                        ),
                                        indent: DefaultTextBlockStyle(baseStyle, baseHorizontalSpacing, baseVerticalSpacing, const VerticalSpacing(0, 0), null),
                                        align: DefaultTextBlockStyle(baseStyle, baseHorizontalSpacing, VerticalSpacing.zero, VerticalSpacing.zero, null),
                                        leading: DefaultTextBlockStyle(baseStyle, baseHorizontalSpacing, VerticalSpacing.zero, VerticalSpacing.zero, null),
                                        sizeSmall: baseStyle,
                                        sizeLarge: baseStyle,
                                        sizeHuge: baseStyle,
                                      ),
                                      onKeyPressed: (event, node) {
                                        if (event is KeyDownEvent) {
                                          final logicalKeyPressed = ServicesBinding.instance.keyboard.logicalKeysPressed
                                              .where((e) => e != LogicalKeyboardKey.escape)
                                              .toList();
                                          final keyboardControlPressed =
                                              (logicalKeyPressed.isMetaPressed && PlatformX.isApple) ||
                                              (logicalKeyPressed.isControlPressed && !PlatformX.isApple);

                                          if (keyboardControlPressed && logicalKeyPressed.contains(LogicalKeyboardKey.arrowUp)) {
                                            if (widget.onLastMessageSelected != null) {
                                              widget.onLastMessageSelected?.call();
                                              widget.focusNode.unfocus();
                                              return KeyEventResult.handled;
                                            }
                                          }

                                          final styles = messageController.getAllSelectionStyles();
                                          bool hasListNumbers = false;
                                          bool hasListBullets = false;
                                          bool hasQuote = false;
                                          bool hasCodeBlock = false;

                                          for (final style in styles) {
                                            for (final attr in style.attributes.values) {
                                              if (attr.key == 'list' && attr.value == 'ordered') {
                                                hasListNumbers = true;
                                              } else if (attr.key == 'list' && attr.value == 'bullet') {
                                                hasListBullets = true;
                                              } else if (attr.key == 'blockquote') {
                                                hasQuote = true;
                                              } else if (attr.key == 'code-block') {
                                                hasCodeBlock = true;
                                              }
                                            }
                                          }

                                          if (event.logicalKey == LogicalKeyboardKey.escape) {
                                            final result = widget.onPressEscape();
                                            if (result) {
                                              widget.focusNode.requestFocus();
                                              return KeyEventResult.handled;
                                            }
                                          }

                                          // Handle automatic list toggling
                                          if (event.logicalKey == LogicalKeyboardKey.space) {
                                            // Get the current line's text
                                            final selection = messageController.selection;

                                            // Get the text from the start of the document to the cursor position
                                            final textBeforeCursor = messageController.document.toPlainText().substring(0, selection.start);
                                            // Find the last newline before the cursor
                                            final lastNewline = textBeforeCursor.lastIndexOf('\n');
                                            // Get the text from the last newline to the cursor
                                            final currentLineText = textBeforeCursor.substring(lastNewline + 1).trim();

                                            // Check if we're at the end of the line
                                            if (currentLineText == '1.' || currentLineText == '1. ') {
                                              if (!hasListNumbers) {
                                                // Toggle numbered list
                                                toggleListNumbers?.call();
                                                // Remove the prefix string
                                                final prefixLength = currentLineText.length;
                                                messageController.replaceText(
                                                  selection.start - prefixLength,
                                                  prefixLength,
                                                  '',
                                                  TextSelection.collapsed(offset: selection.start - prefixLength),
                                                );
                                                return KeyEventResult.handled;
                                              }
                                            } else if (currentLineText == '-' || currentLineText == '- ' || currentLineText == '*' || currentLineText == '* ') {
                                              if (!hasListBullets) {
                                                // Toggle bullet list
                                                toggleListBullets?.call();
                                                // Remove the prefix string
                                                final prefixLength = currentLineText.length;
                                                messageController.replaceText(
                                                  selection.start - prefixLength,
                                                  prefixLength,
                                                  '',
                                                  TextSelection.collapsed(offset: selection.start - prefixLength),
                                                );
                                                return KeyEventResult.handled;
                                              }
                                            } else if (currentLineText == '>' || currentLineText == '> ') {
                                              if (!hasQuote) {
                                                // Toggle quote
                                                toggleQuote?.call();
                                                // Remove the prefix string
                                                final prefixLength = currentLineText.length;
                                                messageController.replaceText(
                                                  selection.start - prefixLength,
                                                  prefixLength,
                                                  '',
                                                  TextSelection.collapsed(offset: selection.start - prefixLength),
                                                );
                                                return KeyEventResult.handled;
                                              }
                                            }
                                          } else if (event.logicalKey == LogicalKeyboardKey.backquote) {
                                            // Get the current selection
                                            final selection = messageController.selection;

                                            // Get the text from the start of the document to the cursor position
                                            final textBeforeCursor = messageController.document.toPlainText().substring(0, selection.start);

                                            // Check for three backticks
                                            if (!hasCodeBlock && textBeforeCursor.endsWith('``')) {
                                              // Count how many backticks we have in the last 3 characters
                                              final lastThreeChars = textBeforeCursor.substring(textBeforeCursor.length - 2);
                                              final backtickCount = lastThreeChars.split('').where((c) => c == '`').length;
                                              if (backtickCount == 2) {
                                                // final isEmpty = messageController.document.toPlainText().trim() == '``';
                                                // Remove the backticks
                                                messageController.replaceText(
                                                  selection.start - backtickCount,
                                                  backtickCount,
                                                  '',
                                                  TextSelection.collapsed(offset: selection.start - backtickCount),
                                                );

                                                toggleCodeBlock?.call();
                                                return KeyEventResult.handled;
                                              }
                                            }

                                            // Find the last backtick before the cursor
                                            final lastBacktick = textBeforeCursor.lastIndexOf('`', textBeforeCursor.length - 1);
                                            if (lastBacktick != -1) {
                                              // Get the text between backticks
                                              final codeText = textBeforeCursor.substring(lastBacktick + 1, textBeforeCursor.length);
                                              // Only proceed if there's actual text between the backticks
                                              if (codeText.isNotEmpty) {
                                                // Remove both backticks and the text between them
                                                messageController.replaceText(
                                                  lastBacktick,
                                                  codeText.length + 1,
                                                  '',
                                                  TextSelection.collapsed(offset: lastBacktick),
                                                );
                                                // Toggle inline code
                                                toggleInlineCode?.call();
                                                // Insert the text
                                                messageController.replaceText(
                                                  lastBacktick,
                                                  0,
                                                  codeText,
                                                  TextSelection.collapsed(offset: lastBacktick + codeText.length),
                                                );
                                                return KeyEventResult.handled;
                                              }
                                            }
                                          } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
                                            if (!hasListBullets && !hasListNumbers && !hasQuote && !hasCodeBlock) {
                                              Future.delayed(const Duration(milliseconds: 100), () {
                                                if (messageController.text.trim().isEmpty) {
                                                  final attributes = <Attribute>{};
                                                  for (final style in messageController.getAllSelectionStyles()) {
                                                    for (final attr in style.attributes.values) {
                                                      attributes.add(attr);
                                                    }
                                                  }
                                                  for (final attribute in attributes) {
                                                    messageController.formatSelection(Attribute.clone(attribute, null));
                                                  }
                                                }
                                              });
                                            }
                                          }

                                          if (logicalKeyPressed.length == 4) {
                                            if (keyboardControlPressed &&
                                                logicalKeyPressed.isShiftPressed &&
                                                logicalKeyPressed.isAltPressed &&
                                                logicalKeyPressed.contains(LogicalKeyboardKey.keyC)) {
                                              toggleCodeBlock?.call();
                                              return KeyEventResult.handled;
                                            }
                                          } else if (logicalKeyPressed.length == 3) {
                                            if (keyboardControlPressed &&
                                                logicalKeyPressed.isShiftPressed &&
                                                logicalKeyPressed.contains(LogicalKeyboardKey.keyX)) {
                                              toggleStrikeThrough?.call();
                                              return KeyEventResult.handled;
                                            }
                                            if (keyboardControlPressed &&
                                                logicalKeyPressed.isShiftPressed &&
                                                logicalKeyPressed.contains(LogicalKeyboardKey.keyC)) {
                                              toggleInlineCode?.call();
                                              return KeyEventResult.handled;
                                            }
                                            if (keyboardControlPressed &&
                                                logicalKeyPressed.isShiftPressed &&
                                                logicalKeyPressed.contains(LogicalKeyboardKey.digit7)) {
                                              toggleListNumbers?.call();
                                              return KeyEventResult.handled;
                                            }
                                            if (keyboardControlPressed &&
                                                logicalKeyPressed.isShiftPressed &&
                                                logicalKeyPressed.contains(LogicalKeyboardKey.digit8)) {
                                              toggleListBullets?.call();
                                              return KeyEventResult.handled;
                                            }
                                            if (keyboardControlPressed &&
                                                logicalKeyPressed.isShiftPressed &&
                                                logicalKeyPressed.contains(LogicalKeyboardKey.digit9)) {
                                              toggleQuote?.call();
                                              return KeyEventResult.handled;
                                            }
                                          } else if (logicalKeyPressed.length == 2) {
                                            if (keyboardControlPressed && logicalKeyPressed.contains(LogicalKeyboardKey.keyV)) {
                                              pasteFileFromClipboard(
                                                isReply: widget.isThread,
                                                controller: messageController,
                                                tabType: widget.tabType,
                                                channel: widget.channel,
                                              );
                                              return KeyEventResult.handled;
                                            }

                                            if (keyboardControlPressed && logicalKeyPressed.contains(LogicalKeyboardKey.keyK)) {
                                              return KeyEventResult.handled;
                                            }

                                            if (logicalKeyPressed.isShiftPressed && logicalKeyPressed.contains(LogicalKeyboardKey.tab)) {
                                              messageController.indentSelection(false);
                                              return KeyEventResult.handled;
                                            }
                                          } else if (logicalKeyPressed.length == 1) {
                                            switch (event.logicalKey) {
                                              case LogicalKeyboardKey.arrowDown:
                                                if (tagListVisible) {
                                                  highlightNextTag();
                                                  return KeyEventResult.handled;
                                                }
                                              case LogicalKeyboardKey.arrowUp:
                                                if (tagListVisible) {
                                                  highlightPreviousTag();
                                                  return KeyEventResult.handled;
                                                }
                                              case LogicalKeyboardKey.tab:
                                                messageController.indentSelection(true);
                                                return KeyEventResult.handled;
                                              default:
                                                break;
                                            }
                                          }

                                          switch (event.logicalKey) {
                                            case LogicalKeyboardKey.enter:
                                            case LogicalKeyboardKey.numpadEnter:
                                              if (tagListVisible) {
                                                enterTag();
                                                return KeyEventResult.handled;
                                              } else {
                                                if (HardwareKeyboard.instance.isShiftPressed) {
                                                  return KeyEventResult.ignored;
                                                } else {
                                                  postMessage(html: messageController.html, uploadble: uploadable);
                                                  return KeyEventResult.handled;
                                                }
                                              }
                                            default:
                                              break;
                                          }
                                        } else if (event is KeyRepeatEvent) {
                                          final logicalKeyPressed = ServicesBinding.instance.keyboard.logicalKeysPressed.where(
                                            (e) => e != LogicalKeyboardKey.escape,
                                          );

                                          if (logicalKeyPressed.length == 1) {
                                            switch (event.logicalKey) {
                                              case LogicalKeyboardKey.arrowDown:
                                                if (tagListVisible) {
                                                  highlightNextTag();
                                                  return KeyEventResult.handled;
                                                }
                                              case LogicalKeyboardKey.arrowUp:
                                                if (tagListVisible) {
                                                  highlightPreviousTag();
                                                  return KeyEventResult.handled;
                                                }
                                              case LogicalKeyboardKey.tab:
                                                messageController.indentSelection(true);
                                                return KeyEventResult.handled;
                                              default:
                                                break;
                                            }
                                          }
                                        }

                                        return KeyEventResult.ignored;
                                      },
                                      customShortcuts: {
                                        SingleActivator(LogicalKeyboardKey.digit1, control: !PlatformX.isMacOS, meta: PlatformX.isMacOS): DoNothingIntent(),
                                        SingleActivator(LogicalKeyboardKey.digit2, control: !PlatformX.isMacOS, meta: PlatformX.isMacOS): DoNothingIntent(),
                                        SingleActivator(LogicalKeyboardKey.digit3, control: !PlatformX.isMacOS, meta: PlatformX.isMacOS): DoNothingIntent(),
                                        SingleActivator(LogicalKeyboardKey.digit4, control: !PlatformX.isMacOS, meta: PlatformX.isMacOS): DoNothingIntent(),
                                        SingleActivator(LogicalKeyboardKey.digit5, control: !PlatformX.isMacOS, meta: PlatformX.isMacOS): DoNothingIntent(),
                                        SingleActivator(LogicalKeyboardKey.digit6, control: !PlatformX.isMacOS, meta: PlatformX.isMacOS): DoNothingIntent(),
                                        SingleActivator(LogicalKeyboardKey.digit0, control: !PlatformX.isMacOS, meta: PlatformX.isMacOS): DoNothingIntent(),
                                        SingleActivator(LogicalKeyboardKey.keyK, control: !PlatformX.isMacOS, meta: PlatformX.isMacOS): DoNothingIntent(),
                                        SingleActivator(LogicalKeyboardKey.digit1, control: !PlatformX.isMacOS, meta: PlatformX.isMacOS):
                                            const DoNothingIntent(),
                                        SingleActivator(LogicalKeyboardKey.digit2, control: !PlatformX.isMacOS, meta: PlatformX.isMacOS):
                                            const DoNothingIntent(),
                                        SingleActivator(LogicalKeyboardKey.digit3, control: !PlatformX.isMacOS, meta: PlatformX.isMacOS):
                                            const DoNothingIntent(),
                                        SingleActivator(LogicalKeyboardKey.digit4, control: !PlatformX.isMacOS, meta: PlatformX.isMacOS):
                                            const DoNothingIntent(),
                                        SingleActivator(LogicalKeyboardKey.digit5, control: !PlatformX.isMacOS, meta: PlatformX.isMacOS):
                                            const DoNothingIntent(),
                                        SingleActivator(LogicalKeyboardKey.digit6, control: !PlatformX.isMacOS, meta: PlatformX.isMacOS):
                                            const DoNothingIntent(),
                                        SingleActivator(LogicalKeyboardKey.digit0, control: !PlatformX.isMacOS, meta: PlatformX.isMacOS):
                                            const DoNothingIntent(),
                                        SingleActivator(LogicalKeyboardKey.keyF, control: !PlatformX.isMacOS, meta: PlatformX.isMacOS): const DoNothingIntent(),
                                      },
                                    ),
                                  );

                              return DefaultTextStyle(style: context.titleSmall!.textColor(context.outlineVariant), child: editor!);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (messageController.editingMessageId != null)
                    IntrinsicWidth(
                      child: VisirButton(
                        type: VisirButtonAnimationType.scaleAndOpacity,
                        style: VisirButtonStyle(
                          padding: EdgeInsets.all(6),
                          margin: EdgeInsets.only(right: 6, bottom: context.textFieldPadding(context.titleSmall!.fontSize!) / 2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        options: VisirButtonOptions(
                          tabType: widget.tabType,
                          tooltipLocation: VisirButtonTooltipLocation.top,
                          doNotConvertCase: true,
                          shortcuts: [
                            VisirButtonKeyboardShortcut(
                              message: context.tr.cancel,
                              keys: [LogicalKeyboardKey.escape],
                              prevOnKeyDown: widget.onKeyDown,
                              prevOnKeyRepeat: widget.onKeyRepeat,
                              onTrigger: () => false,
                            ),
                          ],
                        ),
                        onTap: clearMessage,
                        child: VisirIcon(type: VisirIconType.close, size: 14, color: context.error, isSelected: true),
                      ),
                    ),
                  IntrinsicWidth(
                    child: VisirButton(
                      type: VisirButtonAnimationType.scaleAndOpacity,
                      style: VisirButtonStyle(
                        padding: EdgeInsets.all(6),
                        margin: EdgeInsets.only(right: 6, bottom: context.textFieldPadding(context.titleSmall!.fontSize!) / 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      options: VisirButtonOptions(
                        tabType: widget.tabType,
                        tooltipLocation: VisirButtonTooltipLocation.top,
                        doNotConvertCase: true,
                        bypassTextField: true,
                        shortcuts: [
                          VisirButtonKeyboardShortcut(
                            message: context.tr.send,
                            keys: [LogicalKeyboardKey.enter],
                            prevOnKeyDown: widget.onKeyDown,
                            prevOnKeyRepeat: widget.onKeyRepeat,
                            onTrigger: () {
                              if (!widget.focusNode.hasFocus) return false;
                              postMessage(html: messageController.html, uploadble: uploadable);
                              return true;
                            },
                          ),
                        ],
                      ),
                      onTap: () => postMessage(html: messageController.html, uploadble: uploadable),
                      child: ValueListenableBuilder(
                        valueListenable: sendingFailedMessageInputFieldNotifier,
                        builder: (context, value, child) {
                          return AnimatedSwitcher(
                            duration: Duration(milliseconds: 250),
                            child: VisirIcon(
                              type: VisirIconType.send,
                              key: ValueKey('message_list_controller:send_button_${value.toString()}_${uploadable.toString()}'),
                              size: 14,
                              isSelected: uploadable,
                              color: uploadable
                                  ? value
                                        ? context.error
                                        : context.primary
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
