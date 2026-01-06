import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_emoji_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_tag_entity.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/inbox/application/agent_file_list_controller.dart';
import 'package:Visir/features/inbox/presentation/widgets/agent_temporary_file_list.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/dependency/toasty_box/model/toast_model.dart';
import 'package:Visir/features/inbox/utils/agent_tag_controller.dart';
import 'package:Visir/features/calendar/application/calendar_event_list_controller.dart';
import 'package:Visir/features/task/application/task_list_controller.dart';
import 'package:Visir/features/preference/application/connection_list_controller.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/bottom_dialog_option.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/proxy_network_image.dart';
import 'package:Visir/features/common/presentation/widgets/selection_widget.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/inbox/application/agent_action_controller.dart';
import 'package:Visir/features/inbox/domain/entities/agent_model_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/common/domain/entities/ai_provider_entity.dart';
import 'package:Visir/features/inbox/presentation/widgets/inbox_action_suggestions_widget.dart';
import 'package:Visir/features/inbox/presentation/widgets/agent_chat_history_widget.dart';
import 'package:Visir/features/inbox/providers.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/common/domain/entities/connection_entity.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AgentInputField extends ConsumerStatefulWidget {
  final AgentTagController? messageController;
  final FocusNode? focusNode;
  final bool Function()? onPressEscape;
  final TabType tabType;
  final String? threadId;

  final VoidCallback? onLastMessageSelected;
  final bool Function(KeyEvent event)? onKeyDown;
  final bool Function(KeyEvent event)? onKeyRepeat;
  final ProjectEntity? initialProject;
  final ValueChanged<ProjectEntity?>? onProjectChanged;
  final List<InboxEntity>? inboxes;
  final TaskEntity? upNextTask;
  final EventEntity? upNextEvent;
  final Function(String mcpFunctionName, {InboxEntity? inbox, TaskEntity? task, EventEntity? event})? onActionTap;
  final Function(String title, String prompt)? onCustomPrompt;
  final GlobalKey<AgentInputFieldState>? fieldKey;
  final void Function(InboxEntity? inbox, TaskEntity? task, Offset offset)? onDragStart;
  final void Function(InboxEntity? inbox, TaskEntity? task, Offset offset)? onDragUpdate;
  final void Function(InboxEntity? inbox, TaskEntity? task, Offset offset)? onDragEnd;

  const AgentInputField({
    super.key,
    required this.messageController,
    required this.focusNode,
    required this.onPressEscape,
    required this.tabType,
    this.threadId,
    this.onLastMessageSelected,
    this.onKeyDown,
    this.onKeyRepeat,
    this.initialProject,
    this.onProjectChanged,
    this.inboxes,
    this.upNextTask,
    this.upNextEvent,
    this.onActionTap,
    this.onCustomPrompt,
    this.fieldKey,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
  });

  @override
  ConsumerState<AgentInputField> createState() => AgentInputFieldState();

  static AgentInputFieldState? of(BuildContext context) {
    return context.findAncestorStateOfType<AgentInputFieldState>();
  }
}

class AgentInputFieldState extends ConsumerState<AgentInputField> {
  bool get isMobileView => PlatformX.isMobileView;
  bool get isDarkMode => context.isDarkMode;

  AgentTagController? _messageController;

  AgentTagController get messageController {
    if (widget.messageController != null) return widget.messageController!;
    if (_messageController == null) {
      _messageController = AgentTagController();
    }
    return _messageController!;
  }

  FocusNode? _focusNode;
  FocusNode get focusNode {
    if (widget.focusNode != null) return widget.focusNode!;
    if (_focusNode == null) {
      _focusNode = FocusNode();
    }
    return _focusNode ?? FocusNode();
  }

  bool get tagListVisible => widget.messageController?.tagListVisible ?? false;

  // Tag search related
  final List<MessageTagEntity> tagList = [];
  final List<MessageTagEntity> taskTags = [];
  final List<MessageTagEntity> eventTags = [];
  final List<MessageTagEntity> connectionTags = [];
  final List<MessageTagEntity> channelTags = [];
  final List<MessageTagEntity> projectTags = [];
  String tagSearchWord = '';
  ValueNotifier<String> currentTagIdNotifier = ValueNotifier('');
  String _previousText = '';

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
  bool get isDummy => widget.messageController == null || widget.focusNode == null;

  OverlayEntry? tagListOverlayEntry;

  // Drag state
  bool _isDragOverInputField = false;
  bool _isDraggingInbox = false;
  bool _isDraggingTask = false;
  final GlobalKey _inputFieldKey = GlobalKey();

  void handleDragStart(InboxEntity? inbox, TaskEntity? task, Offset offset) {
    _isDraggingInbox = inbox != null;
    _isDraggingTask = task != null;
    widget.onDragStart?.call(inbox, task, offset);
  }

  void handleDragUpdate(InboxEntity? inbox, TaskEntity? task, Offset offset) {
    // Update dragging state
    _isDraggingInbox = inbox != null;
    _isDraggingTask = task != null;

    // Check if drag position is over input field
    final RenderBox? renderBox = _inputFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final localPosition = renderBox.globalToLocal(offset);
      final size = renderBox.size;
      final isOver = localPosition.dx >= 0 && localPosition.dx <= size.width && localPosition.dy >= 0 && localPosition.dy <= size.height;

      if (isOver != _isDragOverInputField) {
        setState(() {
          _isDragOverInputField = isOver;
        });
      }
    }
    widget.onDragUpdate?.call(inbox, task, offset);
  }

  void handleDragEnd(InboxEntity? inbox, TaskEntity? task, Offset offset) {
    final RenderBox? renderBox = _inputFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && _isDragOverInputField) {
      // Add tag for inbox or task
      if (inbox != null) {
        _addInboxTag(inbox);
      } else if (task != null) {
        _addTaskTag(task);
      }
    }

    setState(() {
      _isDragOverInputField = false;
      _isDraggingInbox = false;
      _isDraggingTask = false;
    });

    widget.onDragEnd?.call(inbox, task, offset);
  }

  void _addInboxTag(InboxEntity inbox) {
    // Add to tagged list
    if (!messageController.taggedInboxes.any((i) => i.uniqueId == inbox.uniqueId)) {
      messageController.addTaggedData(inbox: inbox);
    }

    // Add @tag to text
    final displayName = inbox.suggestion?.decryptedSummary ?? inbox.decryptedTitle;
    final tagString = '\u200b@${displayName}\u200b ';
    final currentText = messageController.text;
    final selection = messageController.selection;
    final insertPosition = selection.end;

    messageController.text = currentText.substring(0, insertPosition) + tagString + currentText.substring(insertPosition);
    messageController.updateSelection(TextSelection.collapsed(offset: insertPosition + tagString.length), ChangeSource.local);

    setState(() {});
  }

  void _addTaskTag(TaskEntity task) {
    // Add to tagged list
    if (!messageController.taggedTasks.any((t) => t.id == task.id)) {
      messageController.addTaggedData(task: task);
    }

    // Add @tag to text
    final displayName = task.title ?? 'Untitled';
    final tagString = '\u200b@${displayName}\u200b ';
    final currentText = messageController.text;
    final selection = messageController.selection;
    final insertPosition = selection.end;

    messageController.text = currentText.substring(0, insertPosition) + tagString + currentText.substring(insertPosition);
    messageController.updateSelection(TextSelection.collapsed(offset: insertPosition + tagString.length), ChangeSource.local);

    setState(() {});
  }

  void requestFocus() {
    if (isDummy) return;
    if (PlatformX.isMobileView) {
      widget.messageController!.skipRequestKeyboard = false;
    }
    widget.focusNode!.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.focusNode!.requestFocus();
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
        if (isDummy) return;
        extraOptions.onPressed?.call();
        widget.focusNode!.requestFocus();
      },
      child: VisirIcon(type: icon, color: !widget.focusNode!.hasFocus ? context.inverseSurface : context.onBackground, size: 14),
    );
  }

  Offset? getCaretOffset() {
    if (isDummy) return null;
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
    contextProject = widget.initialProject;
    widget.messageController?.addListener(onChangeContent);
    tabNotifier.addListener(onTabChanged);
    refreshTagSearchResult();
  }

  @override
  void didUpdateWidget(AgentInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialProject != widget.initialProject) {
      contextProject = widget.initialProject;
      setState(() {});
    }
  }

  void onTabChanged() {
    if (PlatformX.isMobileView) return;
    if (isDummy) return;
    if (tabNotifier.value != widget.tabType) {
      widget.focusNode!.unfocus();
    }
  }

  @override
  void dispose() {
    if (isDummy) return;
    tagListOverlayEntry?.remove();
    tagListOverlayEntry?.dispose();
    tagListOverlayEntry = null;
    tabNotifier.removeListener(onTabChanged);
    widget.messageController!.removeListener(onChangeContent);
    currentTagIdNotifier.dispose();
    super.dispose();
  }

  void onChangeContent() {
    if (isDummy) return;
    final value = messageController.text;
    final selection = messageController.selection;
    final previousText = _previousText;
    _previousText = value;

    // Check if text was deleted (current text is shorter than previous)
    if (previousText.isNotEmpty && value.length < previousText.length) {
      // Check if we're deleting inside a tag pattern (\u200b@태그이름\u200b)
      final RegExp tagRegex = RegExp(r'\u200b@([^\u200b]*?)\u200b', unicode: true);

      // Find tags in previous text
      final previousTagMatches = tagRegex.allMatches(previousText);

      for (final match in previousTagMatches) {
        // Check if cursor is inside this tag in the previous text
        final tagStart = match.start;
        final tagEnd = match.end;

        // Check if cursor was inside this tag before deletion
        // We need to account for the fact that text was deleted
        final deletedLength = previousText.length - value.length;
        final previousCursorPosition = selection.baseOffset + deletedLength;

        if (previousCursorPosition > tagStart && previousCursorPosition <= tagEnd) {
          // Check if the tag still exists in current text
          final currentTagMatches = tagRegex.allMatches(value);
          bool tagStillExists = false;
          for (final currentMatch in currentTagMatches) {
            if (currentMatch.start == tagStart && currentMatch.end == tagEnd) {
              tagStillExists = true;
              break;
            }
          }

          // If tag was partially deleted, remove it completely
          if (!tagStillExists || (selection.baseOffset > tagStart && selection.baseOffset < tagEnd)) {
            final tagContent = match.group(1) ?? '';

            // Remove the entire tag completely
            final beforeTag = value.substring(0, tagStart.clamp(0, value.length));
            final afterTagStart = tagEnd.clamp(0, value.length);
            final afterTag = afterTagStart < value.length ? value.substring(afterTagStart) : '';
            final newText = beforeTag + afterTag;

            // Update text and move cursor to where tag was
            final newCursorPosition = tagStart.clamp(0, newText.length);
            messageController.text = newText;
            messageController.updateSelection(TextSelection.collapsed(offset: newCursorPosition), ChangeSource.local);

            // Also remove the entity from tagged lists
            final tagName = tagContent;
            messageController.taggedTasks.removeWhere((e) => e.title == tagName);
            messageController.taggedEvents.removeWhere((e) => e.title == tagName);
            messageController.taggedConnections.removeWhere((e) => e.name == tagName || e.email == tagName);

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {});
            });
            return;
          }
        }
      }
    }

    // Remove entities from tagged lists if their tags no longer exist in text
    final RegExp tagRegex = RegExp(r'\u200b@([^\u200b]*?)\u200b', unicode: true);
    final currentTagMatches = tagRegex.allMatches(value);
    final Set<String> existingTagNames = currentTagMatches.map((m) => m.group(1) ?? '').toSet();

    // Remove inboxes that are no longer in text
    messageController.taggedInboxes.removeWhere((inbox) {
      final displayName = inbox.suggestion?.decryptedSummary ?? inbox.decryptedTitle;
      return !existingTagNames.contains(displayName);
    });

    // Remove tasks that are no longer in text
    messageController.taggedTasks.removeWhere((task) {
      if (task.title == null) return true;
      return !existingTagNames.contains(task.title);
    });

    // Remove events that are no longer in text
    messageController.taggedEvents.removeWhere((event) {
      if (event.title == null) return true;
      return !existingTagNames.contains(event.title);
    });

    // Remove connections that are no longer in text
    messageController.taggedConnections.removeWhere((connection) {
      final name = connection.name ?? connection.email;
      if (name == null) return true;
      return !existingTagNames.contains(name);
    });

    refreshTagSearchResult();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final trimmedValue = value.trimRight();

      // Check if we're in a tag search context (@ followed by text)
      final textBeforeCursor = trimmedValue.substring(0, messageController.selection.start.clamp(0, trimmedValue.length));
      bool isInTagSearch = false;

      // Find the last @ that is not part of an email address
      for (int i = textBeforeCursor.length - 1; i >= 0; i--) {
        if (textBeforeCursor[i] == '@') {
          if (i == 0 || textBeforeCursor[i - 1] == ' ' || textBeforeCursor[i - 1] == '\n' || textBeforeCursor[i - 1] == '\u200b') {
            isInTagSearch = true;
            break;
          }
        }
      }

      if (trimmedValue.isEmpty) {
        messageController.tagListVisible = false;
        _hideTagListOverlay();
      } else if (isInTagSearch && tagList.isNotEmpty) {
        // If we're in tag search and have results, show overlay
        caretOffset = getCaretOffset();
        messageController.tagListVisible = true;
        _showTagListOverlay();
      } else if (((trimmedValue.length == 1 || messageController.selection.start == 1) && trimmedValue[0] == '@' && (trimmedValue.length < 2 || trimmedValue[1] == ' '))) {
        caretOffset = getCaretOffset();
        messageController.tagListVisible = true;
        _showTagListOverlay();
      } else if ((trimmedValue.length > 1 &&
          messageController.selection.start > 1 &&
          trimmedValue.length >= messageController.selection.start &&
          (trimmedValue.substring(messageController.selection.start - 2, messageController.selection.start) == ' @' ||
              trimmedValue.substring(messageController.selection.start - 2, messageController.selection.start) == '\n@'))) {
        caretOffset = getCaretOffset();
        messageController.tagListVisible = true;
        _showTagListOverlay();
      } else if (!isInTagSearch || tagList.isEmpty) {
        // Only hide if we're not in tag search or have no results
        messageController.tagListVisible = false;
        _hideTagListOverlay();
      }

      setState(() {});
    });
  }

  void _showTagListOverlay() {
    if (tagList.isEmpty || caretOffset == null) {
      _hideTagListOverlay();
      return;
    }

    _hideTagListOverlay();

    final editorState = editorKey.currentState;
    final renderEditor = editorState?.editableTextKey.currentState?.renderEditor;
    final editorContext = editorKey.currentContext;

    if (editorContext == null || renderEditor == null) return;

    final editorRenderBox = editorContext.findRenderObject() as RenderBox?;
    if (editorRenderBox == null) return;

    final selection = messageController.selection;
    if (selection.baseOffset == -1) return;

    // Get caret position in renderEditor's local coordinates
    final caretRect = renderEditor.getLocalRectForCaret(TextPosition(offset: selection.baseOffset));

    // renderEditor is a RenderEditable inside the editor, so we need to get its position
    // Find renderEditor's RenderBox by traversing up the tree
    RenderBox? renderEditorBox;
    RenderObject? current = renderEditor;
    while (current != null && current is! RenderBox) {
      current = current.parent;
    }
    renderEditorBox = current as RenderBox?;

    // Convert to global coordinates
    // If we found renderEditor's RenderBox, use it; otherwise use editorRenderBox
    final caretGlobalPosition = (renderEditorBox ?? editorRenderBox).localToGlobal(Offset(caretRect.left, caretRect.top));

    final overlay = Overlay.of(context);
    tagListOverlayEntry = OverlayEntry(builder: (context) => _buildTagListOverlay(caretGlobalPosition));

    overlay.insert(tagListOverlayEntry!);
  }

  void _hideTagListOverlay() {
    tagListOverlayEntry?.remove();
    tagListOverlayEntry?.dispose();
    tagListOverlayEntry = null;
  }

  Future<void> refreshTagSearchResult() async {
    if (isDummy) return;
    tagList.clear();

    if (messageController.value.selection.end > 1) {
      final textBeforeCursor = messageController.text.substring(0, messageController.value.selection.end);
      // Find the last @ that is not part of an email address (not followed by a valid email character immediately)
      // Look for @ that is preceded by space, newline, start of string, or zero-width space
      int searchFromIndex = -1;
      for (int i = textBeforeCursor.length - 1; i >= 0; i--) {
        if (textBeforeCursor[i] == '@') {
          // Check if this @ is at the start or preceded by whitespace/zero-width space
          if (i == 0 || textBeforeCursor[i - 1] == ' ' || textBeforeCursor[i - 1] == '\n' || textBeforeCursor[i - 1] == '\u200b') {
            searchFromIndex = i + 1;
            break;
          }
        }
      }

      if (searchFromIndex >= 0 && searchFromIndex > 0) {
        tagSearchWord = messageController.text.substring(searchFromIndex, messageController.value.selection.end);
      } else {
        tagSearchWord = '';
      }
    } else {
      tagSearchWord = '';
    }

    // If no @ symbol or search word is empty, hide tag list
    final textBeforeCursor = messageController.text.substring(0, messageController.value.selection.end);
    bool hasValidAtSymbol = false;
    for (int i = textBeforeCursor.length - 1; i >= 0; i--) {
      if (textBeforeCursor[i] == '@') {
        if (i == 0 || textBeforeCursor[i - 1] == ' ' || textBeforeCursor[i - 1] == '\n' || textBeforeCursor[i - 1] == '\u200b') {
          hasValidAtSymbol = true;
          break;
        }
      }
    }

    if (tagSearchWord.isEmpty && !hasValidAtSymbol) {
      messageController.tagListVisible = false;
      _hideTagListOverlay();
      return;
    }

    final pref = ref.read(localPrefControllerProvider).value;
    final user = ref.read(authControllerProvider).requireValue;
    if (pref == null || !user.isSignedIn) return;

    // Count how many sections will have results
    // Filter out cancelled and done tasks
    final allTasks = ref.read(taskListControllerProvider.select((v) => v.tasks.where((e) => !e.isEventDummyTask && !e.isCancelled && !e.isDone)));
    final taskMatches = tagSearchWord.isEmpty ? allTasks.toList() : allTasks.where((e) => (e.title?.toLowerCase().contains(tagSearchWord.toLowerCase()) ?? false)).toList();

    // Filter out cancelled events and past events (only show events from last 30 days or future)
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final allEvents = ref.read(calendarEventListControllerProvider(tabType: widget.tabType)).eventsOnView;
    final eventMatches = allEvents.where((e) {
      if (e.isCancelled) return false;
      // Show events from last 30 days or future events
      if (!e.endDate.isAfter(thirtyDaysAgo)) return false;
      return tagSearchWord.isEmpty || (e.title?.toLowerCase().contains(tagSearchWord.toLowerCase()) ?? false);
    }).toList();

    final connectionList = ref.read(connectionListControllerProvider).value ?? {};
    final allConnections = connectionList.values.expand((e) => e).toList();
    final connectionMatches = tagSearchWord.isEmpty
        ? allConnections
        : allConnections
              .where((e) => (e.name?.toLowerCase().contains(tagSearchWord.toLowerCase()) ?? false) || (e.email?.toLowerCase().contains(tagSearchWord.toLowerCase()) ?? false))
              .toList();

    // Search Slack channels
    final channelFetchResults = ref.read(chatChannelListControllerProvider);
    final allChannels = channelFetchResults.values.expand((result) => result.availableChannels).toList();
    final channelMatches = tagSearchWord.isEmpty ? allChannels : allChannels.where((e) => (e.name?.toLowerCase().contains(tagSearchWord.toLowerCase()) ?? false)).toList();

    // Search projects
    final projects = ref.read(projectListControllerProvider);
    final allProjects = projects.sortedProjectWithDepth.map((p) => p.project).toList();
    final projectMatches = tagSearchWord.isEmpty ? allProjects : allProjects.where((e) => (e.name.toLowerCase().contains(tagSearchWord.toLowerCase()))).toList();

    // Count active sections
    int activeSectionCount = 0;
    if (taskMatches.isNotEmpty) activeSectionCount++;
    if (eventMatches.isNotEmpty) activeSectionCount++;
    if (connectionMatches.isNotEmpty) activeSectionCount++;
    if (channelMatches.isNotEmpty) activeSectionCount++;
    if (projectMatches.isNotEmpty) activeSectionCount++;

    // If only one section remains, show up to 5 items, otherwise 3
    final int maxItemsPerSection = activeSectionCount == 1 ? 5 : 3;

    // Search tasks
    final matchedTasks = taskMatches.take(maxItemsPerSection).toList();

    // Search events
    final matchedEvents = eventMatches.take(maxItemsPerSection).toList();

    // Search connections
    final matchedConnections = connectionMatches.take(maxItemsPerSection).toList();

    // Search channels
    final matchedChannels = channelMatches.take(maxItemsPerSection).toList();

    // Search projects
    final matchedProjects = projectMatches.take(maxItemsPerSection).toList();

    // Add to tag list grouped by type
    taskTags.clear();
    eventTags.clear();
    connectionTags.clear();
    channelTags.clear();
    projectTags.clear();

    matchedTasks.forEach((e) {
      taskTags.add(MessageTagEntity(type: MessageTagEntityType.task, task: e));
    });
    matchedEvents.forEach((e) {
      eventTags.add(MessageTagEntity(type: MessageTagEntityType.event, event: e));
    });
    matchedConnections.forEach((e) {
      connectionTags.add(MessageTagEntity(type: MessageTagEntityType.connection, connection: e));
    });
    matchedChannels.forEach((e) {
      channelTags.add(MessageTagEntity(type: MessageTagEntityType.channel, channel: e));
    });
    matchedProjects.forEach((e) {
      projectTags.add(MessageTagEntity(type: MessageTagEntityType.project, project: e));
    });

    // Sort each group by startsWith match
    taskTags.sort((a, b) {
      final aStartsWith = a.displayName?.toLowerCase().startsWith(tagSearchWord.toLowerCase()) ?? false;
      final bStartsWith = b.displayName?.toLowerCase().startsWith(tagSearchWord.toLowerCase()) ?? false;
      if (aStartsWith && !bStartsWith) return -1;
      if (!aStartsWith && bStartsWith) return 1;
      return 0;
    });
    eventTags.sort((a, b) {
      final aStartsWith = a.displayName?.toLowerCase().startsWith(tagSearchWord.toLowerCase()) ?? false;
      final bStartsWith = b.displayName?.toLowerCase().startsWith(tagSearchWord.toLowerCase()) ?? false;
      if (aStartsWith && !bStartsWith) return -1;
      if (!aStartsWith && bStartsWith) return 1;
      return 0;
    });
    connectionTags.sort((a, b) {
      final aStartsWith = a.displayName?.toLowerCase().startsWith(tagSearchWord.toLowerCase()) ?? false;
      final bStartsWith = b.displayName?.toLowerCase().startsWith(tagSearchWord.toLowerCase()) ?? false;
      if (aStartsWith && !bStartsWith) return -1;
      if (!aStartsWith && bStartsWith) return 1;
      return 0;
    });
    channelTags.sort((a, b) {
      final aStartsWith = a.displayName?.toLowerCase().startsWith(tagSearchWord.toLowerCase()) ?? false;
      final bStartsWith = b.displayName?.toLowerCase().startsWith(tagSearchWord.toLowerCase()) ?? false;
      if (aStartsWith && !bStartsWith) return -1;
      if (!aStartsWith && bStartsWith) return 1;
      return 0;
    });
    projectTags.sort((a, b) {
      final aStartsWith = a.displayName?.toLowerCase().startsWith(tagSearchWord.toLowerCase()) ?? false;
      final bStartsWith = b.displayName?.toLowerCase().startsWith(tagSearchWord.toLowerCase()) ?? false;
      if (aStartsWith && !bStartsWith) return -1;
      if (!aStartsWith && bStartsWith) return 1;
      return 0;
    });

    // Combine all tags in order: tasks, events, connections, channels, projects
    tagList.clear();
    tagList.addAll(taskTags);
    tagList.addAll(eventTags);
    tagList.addAll(connectionTags);
    tagList.addAll(channelTags);
    tagList.addAll(projectTags);

    currentTagIdNotifier.value = tagList.firstOrNull?.id ?? '';

    if (tagList.isNotEmpty) {
      messageController.tagListVisible = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        caretOffset = getCaretOffset();
        _showTagListOverlay();
      });
    } else {
      _hideTagListOverlay();
    }
  }

  bool initialDraftSetted = false;

  ValueNotifier<bool> sendingFailedMessageInputFieldNotifier = ValueNotifier(false);
  String get teamId => ref.read(chatConditionProvider(widget.tabType).select((v) => v.channel!.teamId));
  List<MessageChannelEntity> get channels => ref.read(chatChannelListControllerProvider.select((v) => v[teamId]?.channels ?? []));
  List<MessageMemberEntity> get members => ref.read(chatChannelListControllerProvider.select((v) => v[teamId]?.members ?? []));
  List<MessageGroupEntity> get groups => ref.read(chatChannelListControllerProvider.select((v) => v[teamId]?.groups ?? []));
  List<MessageEmojiEntity> get emojis => ref.read(chatChannelListControllerProvider.select((v) => v[teamId]?.emojis ?? []));

  /// Convert HTML to plain text by removing tags and decoding entities
  String _htmlToPlainText(String html) {
    if (html.trim().isEmpty) return '';

    // Remove HTML tags
    String text = html.replaceAll(RegExp(r'<[^>]*>'), '');

    // Replace common HTML entities
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'");

    // Normalize whitespace
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    return text;
  }

  void clearMessage() {
    if (isDummy) return;
    messageController.clear();
    // ref.read(chatDraftControllerProvider(teamId: widget.channel.teamId, channelId: widget.channel.id, threadId: widget.threadId).notifier).setDraft(null);
  }

  Future<bool> postMessage({required bool uploadable, required String html}) async {
    if (onPickingFiles) return true;

    // 파일 업로드 중인지 확인
    if (ref.read(agentFileListControllerProvider(tabType: widget.tabType).notifier).isUploading == true) {
      Utils.showToast(
        ToastModel(
          message: TextSpan(text: context.tr.file_uploading_message_error),
          buttons: [],
        ),
      );
      return true;
    }

    // Check if agentAction is active
    final plainText = _htmlToPlainText(html);

    // 파일이 있으면 업로드 가능한 것으로 간주
    final agentFileList = ref.read(agentFileListControllerProvider(tabType: widget.tabType).select((v) => v));
    final hasFiles = agentFileList.where((e) => (e.ok ?? false)).toList().isNotEmpty;
    if (plainText.trim().isEmpty && !hasFiles) {
      return false;
    }

    // Get tagged entities from controller (copy lists before clearing)
    final taggedTasks = List<TaskEntity>.from(messageController.taggedTasks);
    final taggedEvents = List<EventEntity>.from(messageController.taggedEvents);
    final taggedInboxes = List<InboxEntity>.from(messageController.taggedInboxes);
    final taggedConnections = List<ConnectionEntity>.from(messageController.taggedConnections);
    final taggedChannels = List<MessageChannelEntity>.from(messageController.taggedChannels);
    final taggedProjects = List<ProjectEntity>.from(messageController.taggedProjects);

    // If taggedTasks is empty, try to find tasks from @mentions in the text
    if (taggedTasks.isEmpty) {
      final RegExp mentionRegex = RegExp(r'@([^\s@\n\r.,!?;:]+(?:\s+[^\s@\n\r.,!?;:]+)*)');
      final mentionMatches = mentionRegex.allMatches(plainText);
      // Filter out cancelled and done tasks
      final allTasks = ref.read(taskListControllerProvider.select((v) => v.tasks.where((e) => !e.isEventDummyTask && !e.isCancelled && !e.isDone)));

      for (final match in mentionMatches) {
        final mentionName = match.group(1) ?? ''; // "cpu 메모리 확인" (without @)

        // Try to find matching task by title
        final matchingTask = allTasks.firstWhereOrNull((task) {
          final taskTitle = task.title?.trim() ?? '';
          return taskTitle.toLowerCase() == mentionName.toLowerCase() || taskTitle.toLowerCase().contains(mentionName.toLowerCase());
        });

        if (matchingTask != null && !taggedTasks.any((t) => t.id == matchingTask.id)) {
          taggedTasks.add(matchingTask);
        }
      }
    }

    // contextProject가 선택되어 있으면 자동으로 taggedProjects에 추가
    if (contextProject != null && !taggedProjects.any((p) => p.uniqueId == contextProject!.uniqueId)) {
      taggedProjects.add(contextProject!);
    }

    // 태그된 프로젝트가 있으면 그것을 selectedProject로 사용 (우선순위)
    final effectiveSelectedProject = taggedProjects.isNotEmpty ? taggedProjects.first : contextProject;

    // 파일 목록 가져오기
    final files = agentFileList.where((e) => (e.ok ?? false)).map((e) => e.file).toList();

    // MCP 함수 호출을 통한 통합 처리
    clearMessage();

    // 파일 목록 초기화
    ref.read(agentFileListControllerProvider(tabType: widget.tabType).notifier).clear();

    await ref
        .read(agentActionControllerProvider.notifier)
        .handleMessageWithoutAction(
          plainText,
          selectedProject: effectiveSelectedProject,
          inboxes: null, // 초기 context는 제공하지 않음 - 사용자가 명시적으로 선택한 경우에만 전달
          taggedTasks: taggedTasks,
          taggedEvents: taggedEvents,
          taggedInboxes: taggedInboxes,
          taggedConnections: taggedConnections,
          taggedChannels: taggedChannels,
          taggedProjects: taggedProjects,
          files: files,
        );
    return true;

    // if (ref.read(chatFileListControllerProvider(tabType: widget.tabType, isThread: widget.isThread).notifier).isUploading == true) {
    //   Utils.showToast(
    //     ToastModel(
    //       message: TextSpan(text: context.tr.file_uploading_message_error),
    //       buttons: [],
    //     ),
    //   );
    //   return true;
    // }

    // final editingId = messageController.editingMessageId;

    // final taggedMembers = messageController.taggedMembers;
    // final taggedGroups = messageController.taggedGroups;
    // final taggedChannels = messageController.taggedChannels;

    // final finalMembers = [...members, ...taggedMembers].toSet().toList();
    // final finalGroups = [...groups, ...taggedGroups].toSet().toList();
    // final finalChannels = [...channels, ...taggedChannels].toSet().toList();

    // clearMessage();

    // bool result = false;
    // if (widget.isThread && editingId != widget.threadId) {
    //   result = await MessageAction.postReply(
    //     id: editingId,
    //     tabType: widget.tabType,
    //     html: html,
    //     channel: widget.channel,
    //     channels: finalChannels,
    //     members: finalMembers,
    //     groups: finalGroups,
    //     emojis: emojis,
    //     threadId: widget.threadId!,
    //   );
    // } else {
    //   result = await MessageAction.postMessage(
    //     id: editingId,
    //     tabType: widget.tabType,
    //     html: html,
    //     channel: widget.channel,
    //     channels: finalChannels,
    //     members: finalMembers,
    //     groups: finalGroups,
    //     emojis: emojis,
    //   );
    // }

    // if (result) {
    //   // scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    //   return true;
    // } else {
    //   messageController.setData(editingMessageId: editingId, html: html);
    //   sendingFailedMessageInputFieldNotifier.value = true;
    //   Future.delayed(Duration(milliseconds: 1000), () {
    //     sendingFailedMessageInputFieldNotifier.value = false;
    //   });

    //   return false;
    // }
  }

  Future<void> uploadFiles({required List<PlatformFile> files}) async {
    if (files.isNotEmpty) {
      for (final f in files) {
        final compressedFile = await Utils.compressOnlyVideoFileInMobile(originalFile: f);
        ref.read(agentFileListControllerProvider(tabType: widget.tabType).notifier).addFile(file: compressedFile);
      }
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
  ProjectEntity? contextProject;

  ThemeMode? prevThemeMode;

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectListControllerProvider);
    final agentAction = ref.watch(agentActionControllerProvider);
    final theme = ref.watch(themeSwitchProvider);
    if (prevThemeMode != theme) {
      prevThemeMode = theme;
      editor = null;
    }

    // 파일 목록 확인하여 uploadable 상태 업데이트
    final messageFileList = ref.watch(agentFileListControllerProvider(tabType: widget.tabType).select((v) => v));
    uploadable = messageController.text.trim().isNotEmpty || messageFileList.where((e) => (e.ok ?? false)).toList().isNotEmpty;

    final selectedModel = ref.watch(selectedAgentModelProvider).value;
    return DropTarget(
      onDragDone: (detail) async {
        for (final e in detail.files) {
          final bytes = await e.readAsBytes();
          final platformFile = PlatformFile(path: e.path, name: e.name, size: bytes.lengthInBytes, bytes: bytes, identifier: e.path);
          await uploadFiles(files: [platformFile]);
        }
      },
      child: Container(
        key: _inputFieldKey,
        decoration: BoxDecoration(
          border: Border.all(
            color: _isDragOverInputField ? context.primary.withValues(alpha: 0.7) : context.tertiary.withValues(alpha: 0.7),
            strokeAlign: BorderSide.strokeAlignOutside,
            width: _isDragOverInputField ? 2 : 1,
          ),
          color: _isDragOverInputField ? context.primary.withValues(alpha: 0.1) : context.background,
          borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
          boxShadow: PopupMenu.popupShadow,
        ),
        padding: EdgeInsets.only(bottom: 6),
        clipBehavior: Clip.none,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (agentAction.isEmpty && widget.inboxes != null && (widget.inboxes!.isNotEmpty || widget.upNextTask != null || widget.upNextEvent != null))
                      AgentActionSuggestionsWidget(
                        inboxes: widget.inboxes ?? [],
                        upNextTask: widget.upNextTask,
                        upNextEvent: widget.upNextEvent,
                        onActionTap: widget.onActionTap,
                        onCustomPrompt: widget.onCustomPrompt,
                      ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: BoxConstraints(minWidth: constraints.maxWidth),
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: AgentTemporaryFileList(tabType: widget.tabType),
                      ),
                    ),
                    SizedBox(height: 6),

                    Flexible(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(width: 10),
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
                                      Color inputHintColor = PlatformX.isDesktopView ? context.inverseSurface : context.surfaceTint;
                                      final baseHorizontalSpacing = HorizontalSpacing(0, 0);
                                      final baseVerticalSpacing = VerticalSpacing(0, 0);

                                      editor =
                                          editor ??
                                          QuillEditor(
                                            key: editorKey,
                                            controller: messageController,
                                            focusNode: focusNode,
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
                                                final RegExp mentionRegex = RegExp(r'\u200b\u0040([^]*?)\u200b', unicode: true);

                                                int offset = 0;

                                                final mentionMatches = mentionRegex.allMatches(text);

                                                // Get tagged entities from controller
                                                final taggedTasks = messageController.taggedTasks;
                                                final taggedEvents = messageController.taggedEvents;
                                                final taggedInboxes = messageController.taggedInboxes;
                                                final taggedConnections = messageController.taggedConnections;
                                                final taggedChannels = messageController.taggedChannels;
                                                final taggedProjects = messageController.taggedProjects;

                                                for (final match in mentionMatches) {
                                                  if (match.start > offset) {
                                                    spans.add(TextSpan(text: text.substring(offset, match.start)));
                                                  }

                                                  final piece = text.substring(match.start, match.end);
                                                  String tagName = piece.replaceAll('@', '').replaceAll('\u200b', '').trim();

                                                  // Find matching entity from tagged entities
                                                  InboxEntity? targetInbox = taggedInboxes
                                                      .where((e) => (e.suggestion?.decryptedSummary ?? e.decryptedTitle) == tagName)
                                                      .firstOrNull;

                                                  TaskEntity? targetTask = taggedTasks.where((e) => e.title != null && tagName == e.title).firstOrNull;

                                                  EventEntity? targetEvent = taggedEvents.where((e) => e.title != null && tagName == e.title).firstOrNull;

                                                  ConnectionEntity? targetConnection = taggedConnections
                                                      .where((e) => (e.name != null && tagName == e.name) || (e.email != null && tagName == e.email))
                                                      .firstOrNull;

                                                  MessageChannelEntity? targetChannel = taggedChannels.where((e) => e.name != null && tagName == e.name).firstOrNull;

                                                  ProjectEntity? targetProject = taggedProjects.where((e) => tagName == e.name).firstOrNull;

                                                  if (targetInbox != null) {
                                                    final displayName = targetInbox.suggestion?.decryptedSummary ?? targetInbox.decryptedTitle;
                                                    final name = '@$displayName';
                                                    final leftovers = piece.replaceAll(name, '').replaceAll('\u200b', '');

                                                    // Get inbox provider for avatarUrl and icon
                                                    final inboxProviders = targetInbox.providers;
                                                    final firstProvider = inboxProviders.isNotEmpty ? inboxProviders.first : null;
                                                    final avatarUrl = firstProvider?.avatarUrl;
                                                    final providerIcon = firstProvider?.icon;

                                                    spans.add(
                                                      WidgetSpan(
                                                        alignment: PlaceholderAlignment.middle,
                                                        child: Container(
                                                          constraints: const BoxConstraints(maxWidth: 200),
                                                          margin: const EdgeInsets.symmetric(horizontal: 2),
                                                          padding: const EdgeInsets.only(left: 4, right: 6, top: 4, bottom: 4),
                                                          decoration: BoxDecoration(
                                                            color: context.surface,
                                                            borderRadius: BorderRadius.circular(6),
                                                            border: Border.all(color: context.outline.withValues(alpha: 0.2), width: 1),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              avatarUrl != null || providerIcon != null
                                                                  ? ClipRRect(
                                                                      borderRadius: BorderRadius.circular(6),
                                                                      child: avatarUrl != null
                                                                          ? ProxyNetworkImage(imageUrl: avatarUrl, width: 12, height: 12, fit: BoxFit.cover)
                                                                          : Image.asset(providerIcon!, width: 12, height: 12, fit: BoxFit.cover),
                                                                    )
                                                                  : Container(
                                                                      width: 12,
                                                                      height: 12,
                                                                      alignment: Alignment.center,
                                                                      child: VisirIcon(type: VisirIconType.inbox, size: 12, color: context.onBackground, isSelected: true),
                                                                    ),
                                                              const SizedBox(width: 4),
                                                              Flexible(
                                                                child: Text(
                                                                  displayName,
                                                                  style: TextStyle(color: context.onBackground, fontSize: style?.fontSize ?? 14, height: 1.0),
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                    if (leftovers.isNotEmpty) spans.add(TextSpan(text: leftovers));
                                                  } else if (targetProject != null) {
                                                    final displayName = targetProject.name;
                                                    final name = '@${targetProject.name}';
                                                    final leftovers = piece.replaceAll(name, '').replaceAll('\u200b', '');
                                                    spans.add(
                                                      WidgetSpan(
                                                        alignment: PlaceholderAlignment.middle,
                                                        child: Container(
                                                          constraints: const BoxConstraints(maxWidth: 200),
                                                          margin: const EdgeInsets.symmetric(horizontal: 2),
                                                          padding: const EdgeInsets.only(left: 4, right: 6, top: 4, bottom: 4),
                                                          decoration: BoxDecoration(
                                                            color: targetProject.color != null ? targetProject.color!.withValues(alpha: 0.15) : context.surface,
                                                            borderRadius: BorderRadius.circular(6),
                                                            border: Border.all(
                                                              color: targetProject.color != null
                                                                  ? targetProject.color!.withValues(alpha: 0.3)
                                                                  : context.outline.withValues(alpha: 0.2),
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Container(
                                                                width: 12,
                                                                height: 12,
                                                                alignment: Alignment.center,
                                                                child: VisirIcon(
                                                                  type: targetProject.icon ?? VisirIconType.inbox,
                                                                  size: 12,
                                                                  color: targetProject.color ?? context.onBackground,
                                                                  isSelected: true,
                                                                ),
                                                              ),
                                                              const SizedBox(width: 4),
                                                              Flexible(
                                                                child: Text(
                                                                  displayName,
                                                                  style: TextStyle(color: context.onBackground, fontSize: style?.fontSize ?? 14, height: 1.0),
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                    if (leftovers.isNotEmpty) spans.add(TextSpan(text: leftovers));
                                                  } else if (targetTask != null) {
                                                    final displayName = targetTask.title!;
                                                    final name = '@${targetTask.title!}';
                                                    final leftovers = piece.replaceAll(name, '').replaceAll('\u200b', '');
                                                    spans.add(
                                                      WidgetSpan(
                                                        alignment: PlaceholderAlignment.middle,
                                                        child: Container(
                                                          constraints: const BoxConstraints(maxWidth: 200),
                                                          margin: const EdgeInsets.symmetric(horizontal: 2),
                                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                          decoration: BoxDecoration(
                                                            color: context.surface,
                                                            borderRadius: BorderRadius.circular(6),
                                                            border: Border.all(color: context.outline.withValues(alpha: 0.2), width: 1),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              VisirIcon(type: VisirIconType.task, size: 12, color: context.onBackground, isSelected: true),
                                                              const SizedBox(width: 4),
                                                              Flexible(
                                                                child: Text(
                                                                  displayName,
                                                                  style: TextStyle(color: context.onBackground, fontSize: style?.fontSize ?? 14, height: 1.0),
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                    if (leftovers.isNotEmpty) spans.add(TextSpan(text: leftovers));
                                                  } else if (targetEvent != null) {
                                                    final displayName = targetEvent.title!;
                                                    final name = '@${targetEvent.title!}';
                                                    final leftovers = piece.replaceAll(name, '').replaceAll('\u200b', '');
                                                    spans.add(
                                                      WidgetSpan(
                                                        alignment: PlaceholderAlignment.middle,
                                                        child: Container(
                                                          constraints: const BoxConstraints(maxWidth: 200),
                                                          margin: const EdgeInsets.symmetric(horizontal: 2),
                                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                          decoration: BoxDecoration(
                                                            color: context.surface,
                                                            borderRadius: BorderRadius.circular(6),
                                                            border: Border.all(color: context.outline.withValues(alpha: 0.2), width: 1),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              VisirIcon(type: VisirIconType.calendar, size: 12, color: context.onBackground, isSelected: true),
                                                              const SizedBox(width: 4),
                                                              Flexible(
                                                                child: Text(
                                                                  displayName,
                                                                  style: TextStyle(color: context.onBackground, fontSize: style?.fontSize ?? 14, height: 1.0),
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                    if (leftovers.isNotEmpty) spans.add(TextSpan(text: leftovers));
                                                  } else if (targetConnection != null) {
                                                    final displayName = targetConnection.name ?? targetConnection.email ?? '';
                                                    final name = '@$displayName';
                                                    final leftovers = piece.replaceAll(name, '').replaceAll('\u200b', '');
                                                    spans.add(
                                                      WidgetSpan(
                                                        alignment: PlaceholderAlignment.middle,
                                                        child: Container(
                                                          constraints: const BoxConstraints(maxWidth: 200),
                                                          margin: const EdgeInsets.symmetric(horizontal: 2),
                                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                          decoration: BoxDecoration(
                                                            color: context.surface,
                                                            borderRadius: BorderRadius.circular(6),
                                                            border: Border.all(color: context.outline.withValues(alpha: 0.2), width: 1),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              VisirIcon(type: VisirIconType.attendee, size: 12, color: context.onBackground, isSelected: true),
                                                              const SizedBox(width: 4),
                                                              Flexible(
                                                                child: Text(
                                                                  displayName,
                                                                  style: TextStyle(color: context.onBackground, fontSize: style?.fontSize ?? 14, height: 1.0),
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                    if (leftovers.isNotEmpty) spans.add(TextSpan(text: leftovers));
                                                  } else if (targetChannel != null) {
                                                    final displayName = targetChannel.name ?? '';
                                                    final name = '@$displayName';
                                                    final leftovers = piece.replaceAll(name, '').replaceAll('\u200b', '');
                                                    spans.add(
                                                      WidgetSpan(
                                                        alignment: PlaceholderAlignment.middle,
                                                        child: Container(
                                                          constraints: const BoxConstraints(maxWidth: 200),
                                                          margin: const EdgeInsets.symmetric(horizontal: 2),
                                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                          decoration: BoxDecoration(
                                                            color: context.surface,
                                                            borderRadius: BorderRadius.circular(6),
                                                            border: Border.all(color: context.outline.withValues(alpha: 0.2), width: 1),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              VisirIcon(type: VisirIconType.chatChannel, size: 12, color: context.onBackground, isSelected: true),
                                                              const SizedBox(width: 4),
                                                              Flexible(
                                                                child: Text(
                                                                  displayName,
                                                                  style: TextStyle(color: context.onBackground, fontSize: style?.fontSize ?? 14, height: 1.0),
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                    if (leftovers.isNotEmpty) spans.add(TextSpan(text: leftovers));
                                                  } else if (targetProject != null) {
                                                    final displayName = targetProject.name;
                                                    final name = '@$displayName';
                                                    final leftovers = piece.replaceAll(name, '').replaceAll('\u200b', '');
                                                    spans.add(
                                                      WidgetSpan(
                                                        alignment: PlaceholderAlignment.middle,
                                                        child: Container(
                                                          constraints: const BoxConstraints(maxWidth: 200),
                                                          margin: const EdgeInsets.symmetric(horizontal: 2),
                                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                          decoration: BoxDecoration(
                                                            color: context.surface,
                                                            borderRadius: BorderRadius.circular(6),
                                                            border: Border.all(color: context.outline.withValues(alpha: 0.2), width: 1),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              VisirIcon(
                                                                type: targetProject.icon ?? VisirIconType.project,
                                                                size: 12,
                                                                color: targetProject.color ?? context.onBackground,
                                                                isSelected: true,
                                                              ),
                                                              const SizedBox(width: 4),
                                                              Flexible(
                                                                child: Text(
                                                                  displayName,
                                                                  style: TextStyle(color: context.onBackground, fontSize: style?.fontSize ?? 14, height: 1.0),
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
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
                                                  messageController.skipRequestKeyboard = false;
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
                                                lineHeightNormal: DefaultTextBlockStyle(baseStyle, baseHorizontalSpacing, VerticalSpacing.zero, VerticalSpacing.zero, null),
                                                lineHeightTight: DefaultTextBlockStyle(baseStyle, baseHorizontalSpacing, VerticalSpacing.zero, VerticalSpacing.zero, null),
                                                lineHeightOneAndHalf: DefaultTextBlockStyle(baseStyle, baseHorizontalSpacing, VerticalSpacing.zero, VerticalSpacing.zero, null),
                                                lineHeightDouble: DefaultTextBlockStyle(baseStyle, baseHorizontalSpacing, VerticalSpacing.zero, VerticalSpacing.zero, null),
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
                                                if (isDummy) return KeyEventResult.ignored;
                                                if (event is KeyDownEvent) {
                                                  final logicalKeyPressed = ServicesBinding.instance.keyboard.logicalKeysPressed
                                                      .where((e) => e != LogicalKeyboardKey.escape)
                                                      .toList();
                                                  final keyboardControlPressed =
                                                      (logicalKeyPressed.isMetaPressed && PlatformX.isApple) || (logicalKeyPressed.isControlPressed && !PlatformX.isApple);

                                                  // Handle tag list navigation
                                                  if (tagListVisible && tagList.isNotEmpty) {
                                                    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                                                      highlightNextTag();
                                                      return KeyEventResult.handled;
                                                    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                                                      highlightPreviousTag();
                                                      return KeyEventResult.handled;
                                                    } else if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.tab) {
                                                      enterTag();
                                                      return KeyEventResult.handled;
                                                    }
                                                  }

                                                  if (keyboardControlPressed && logicalKeyPressed.contains(LogicalKeyboardKey.arrowUp)) {
                                                    if (widget.onLastMessageSelected != null) {
                                                      widget.onLastMessageSelected?.call();
                                                      focusNode.unfocus();
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
                                                    final result = widget.onPressEscape!.call();
                                                    if (result) {
                                                      widget.focusNode!.requestFocus();
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
                                                        messageController.replaceText(lastBacktick, codeText.length + 1, '', TextSelection.collapsed(offset: lastBacktick));
                                                        // Toggle inline code
                                                        toggleInlineCode?.call();
                                                        // Insert the text
                                                        messageController.replaceText(lastBacktick, 0, codeText, TextSelection.collapsed(offset: lastBacktick + codeText.length));
                                                        return KeyEventResult.handled;
                                                      }
                                                    }
                                                  } else if (event.logicalKey == LogicalKeyboardKey.backspace) {
                                                    if (!hasListBullets && !hasListNumbers && !hasQuote && !hasCodeBlock) {
                                                      // Check if cursor is at the end of or inside a tag
                                                      final text = messageController.text;
                                                      final selection = messageController.selection;
                                                      final cursorPosition = selection.baseOffset;

                                                      final RegExp tagRegex = RegExp(r'\u200b@([^\u200b]*?)\u200b', unicode: true);
                                                      final tagMatches = tagRegex.allMatches(text);

                                                      for (final match in tagMatches) {
                                                        final tagStart = match.start;
                                                        final tagEnd = match.end;

                                                        // If cursor is at the end of tag or inside tag, delete entire tag
                                                        if (cursorPosition > tagStart && cursorPosition <= tagEnd) {
                                                          final tagContent = match.group(1) ?? '';

                                                          // Remove the entire tag
                                                          final beforeTag = text.substring(0, tagStart);
                                                          final afterTag = text.substring(tagEnd);
                                                          final newText = beforeTag + afterTag;

                                                          // Update text and move cursor to where tag was
                                                          final newCursorPosition = tagStart.clamp(0, newText.length);
                                                          messageController.text = newText;
                                                          messageController.updateSelection(TextSelection.collapsed(offset: newCursorPosition), ChangeSource.local);

                                                          // Remove entity from tagged lists
                                                          messageController.taggedInboxes.removeWhere((e) => (e.suggestion?.decryptedSummary ?? e.decryptedTitle) == tagContent);
                                                          messageController.taggedTasks.removeWhere((e) => e.title == tagContent);
                                                          messageController.taggedEvents.removeWhere((e) => e.title == tagContent);
                                                          messageController.taggedConnections.removeWhere((e) => e.name == tagContent || e.email == tagContent);

                                                          WidgetsBinding.instance.addPostFrameCallback((_) {
                                                            if (!mounted) return;
                                                            setState(() {});
                                                          });

                                                          return KeyEventResult.handled;
                                                        }
                                                      }

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
                                                    if (keyboardControlPressed && logicalKeyPressed.isShiftPressed && logicalKeyPressed.contains(LogicalKeyboardKey.keyX)) {
                                                      toggleStrikeThrough?.call();
                                                      return KeyEventResult.handled;
                                                    }
                                                    if (keyboardControlPressed && logicalKeyPressed.isShiftPressed && logicalKeyPressed.contains(LogicalKeyboardKey.keyC)) {
                                                      toggleInlineCode?.call();
                                                      return KeyEventResult.handled;
                                                    }
                                                    if (keyboardControlPressed && logicalKeyPressed.isShiftPressed && logicalKeyPressed.contains(LogicalKeyboardKey.digit7)) {
                                                      toggleListNumbers?.call();
                                                      return KeyEventResult.handled;
                                                    }
                                                    if (keyboardControlPressed && logicalKeyPressed.isShiftPressed && logicalKeyPressed.contains(LogicalKeyboardKey.digit8)) {
                                                      toggleListBullets?.call();
                                                      return KeyEventResult.handled;
                                                    }
                                                    if (keyboardControlPressed && logicalKeyPressed.isShiftPressed && logicalKeyPressed.contains(LogicalKeyboardKey.digit9)) {
                                                      toggleQuote?.call();
                                                      return KeyEventResult.handled;
                                                    }
                                                  } else if (logicalKeyPressed.length == 2) {
                                                    if (keyboardControlPressed && logicalKeyPressed.contains(LogicalKeyboardKey.keyV)) {
                                                      // pasteFileFromClipboard(
                                                      //   isReply: widget.isThread,
                                                      //   controller: messageController,
                                                      //   tabType: widget.tabType,
                                                      //   channel: widget.channel,
                                                      // );
                                                      // return KeyEventResult.handled;
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
                                                        if (tagListVisible && tagList.isNotEmpty) {
                                                          highlightNextTag();
                                                          return KeyEventResult.handled;
                                                        }
                                                        break;
                                                      case LogicalKeyboardKey.arrowUp:
                                                        if (tagListVisible && tagList.isNotEmpty) {
                                                          highlightPreviousTag();
                                                          return KeyEventResult.handled;
                                                        }
                                                        break;
                                                      case LogicalKeyboardKey.tab:
                                                        if (tagListVisible && tagList.isNotEmpty) {
                                                          enterTag();
                                                          return KeyEventResult.handled;
                                                        } else {
                                                          messageController.indentSelection(true);
                                                          return KeyEventResult.handled;
                                                        }
                                                      default:
                                                        break;
                                                    }
                                                  }

                                                  switch (event.logicalKey) {
                                                    case LogicalKeyboardKey.enter:
                                                    case LogicalKeyboardKey.numpadEnter:
                                                      if (tagListVisible && tagList.isNotEmpty) {
                                                        enterTag();
                                                        return KeyEventResult.handled;
                                                      } else {
                                                        if (HardwareKeyboard.instance.isShiftPressed) {
                                                          return KeyEventResult.ignored;
                                                        } else {
                                                          postMessage(html: messageController.html, uploadable: uploadable);
                                                          return KeyEventResult.handled;
                                                        }
                                                      }
                                                    default:
                                                      break;
                                                  }
                                                } else if (event is KeyRepeatEvent) {
                                                  final logicalKeyPressed = ServicesBinding.instance.keyboard.logicalKeysPressed.where((e) => e != LogicalKeyboardKey.escape);

                                                  if (logicalKeyPressed.length == 1) {
                                                    switch (event.logicalKey) {
                                                      case LogicalKeyboardKey.arrowDown:
                                                        if (tagListVisible && tagList.isNotEmpty) {
                                                          highlightNextTag();
                                                          return KeyEventResult.handled;
                                                        }
                                                        break;
                                                      case LogicalKeyboardKey.arrowUp:
                                                        if (tagListVisible && tagList.isNotEmpty) {
                                                          highlightPreviousTag();
                                                          return KeyEventResult.handled;
                                                        }
                                                        break;
                                                      case LogicalKeyboardKey.tab:
                                                        if (tagListVisible && tagList.isNotEmpty) {
                                                          enterTag();
                                                          return KeyEventResult.handled;
                                                        } else {
                                                          messageController.indentSelection(true);
                                                          return KeyEventResult.handled;
                                                        }
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
                                                SingleActivator(LogicalKeyboardKey.digit1, control: !PlatformX.isMacOS, meta: PlatformX.isMacOS): const DoNothingIntent(),
                                                SingleActivator(LogicalKeyboardKey.digit2, control: !PlatformX.isMacOS, meta: PlatformX.isMacOS): const DoNothingIntent(),
                                                SingleActivator(LogicalKeyboardKey.digit3, control: !PlatformX.isMacOS, meta: PlatformX.isMacOS): const DoNothingIntent(),
                                                SingleActivator(LogicalKeyboardKey.digit4, control: !PlatformX.isMacOS, meta: PlatformX.isMacOS): const DoNothingIntent(),
                                                SingleActivator(LogicalKeyboardKey.digit5, control: !PlatformX.isMacOS, meta: PlatformX.isMacOS): const DoNothingIntent(),
                                                SingleActivator(LogicalKeyboardKey.digit6, control: !PlatformX.isMacOS, meta: PlatformX.isMacOS): const DoNothingIntent(),
                                                SingleActivator(LogicalKeyboardKey.digit0, control: !PlatformX.isMacOS, meta: PlatformX.isMacOS): const DoNothingIntent(),
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
                        ],
                      ),
                    ),
                    Container(
                      height: 28,
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                IntrinsicWidth(
                                  child: PopupMenu(
                                    location: PopupMenuLocation.right,
                                    width: 480,
                                    height: 600,
                                    borderRadius: 12,
                                    backgroundColor: PlatformX.isMobileView ? context.background : null,
                                    type: ContextMenuActionType.tap,
                                    style: VisirButtonStyle(padding: EdgeInsets.all(6), borderRadius: BorderRadius.circular(4), margin: EdgeInsets.only(left: 6)),
                                    options: VisirButtonOptions(message: '챗 히스토리', tooltipLocation: VisirButtonTooltipLocation.top, doNotConvertCase: true),
                                    beforePopup: () {
                                      // 기본적으로 모든 프로젝트의 최근 히스토리 표시
                                      ref.read(agentChatHistoryFilterProvider.notifier).setFilter(null);
                                      ref.read(agentChatHistorySearchQueryProvider.notifier).setSearchQuery('');
                                      ref.read(agentChatHistorySortProvider.notifier).setSortType(AgentChatHistorySortType.updatedAtDesc);
                                    },
                                    popup: AgentChatHistoryPopupMenu(projectId: contextProject?.uniqueId),
                                    child: VisirIcon(type: VisirIconType.clock, size: 14, isSelected: true),
                                  ),
                                ),
                                IntrinsicWidth(
                                  child: VisirButton(
                                    enabled: true,
                                    type: VisirButtonAnimationType.scaleAndOpacity,
                                    style: VisirButtonStyle(padding: EdgeInsets.all(6), borderRadius: BorderRadius.circular(4), margin: EdgeInsets.only(left: 6)),
                                    options: VisirButtonOptions(
                                      message: context.tr.attach,
                                      customShortcutTooltip: context.tr.drag_and_drop,
                                      tooltipLocation: VisirButtonTooltipLocation.top,
                                      doNotConvertCase: true,
                                    ),
                                    onTap: isDummy ? null : onPressUpload,
                                    child: onPickingFiles
                                        ? CustomCircularLoadingIndicator(size: 14, color: focusNode.hasFocus ? context.onInverseSurface : context.surface)
                                        : SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: VisirIcon(type: VisirIconType.file, size: 14, isSelected: focusNode.hasFocus),
                                          ),
                                  ),
                                ),
                                IntrinsicWidth(
                                  child: PopupMenu(
                                    beforePopup: () => FocusScope.of(context).unfocus(),
                                    enabled: true,
                                    forcePopup: true,
                                    location: PopupMenuLocation.bottom,
                                    width: 180,
                                    borderRadius: 6,
                                    type: ContextMenuActionType.tap,
                                    popup: isDummy
                                        ? null
                                        : Builder(
                                            builder: (context) {
                                              final sortedProjects = projects.sortedProjectWithDepth;
                                              return SelectionWidget<ProjectEntity?>(
                                                current: contextProject,
                                                items: [...sortedProjects.map((e) => e.project).toList()],
                                                options: (project) => VisirButtonOptions(
                                                  tooltipLocation: project?.description?.isNotEmpty == true ? VisirButtonTooltipLocation.right : VisirButtonTooltipLocation.none,
                                                  message: project?.description,
                                                ),
                                                getChild: (project) {
                                                  final depth = sortedProjects.firstWhereOrNull((e) => e.project.uniqueId == project?.uniqueId)?.depth ?? 0;
                                                  return Row(
                                                    children: [
                                                      SizedBox(width: 10 + depth * 12),
                                                      if (project != null)
                                                        Container(
                                                          width: 16,
                                                          height: 16,
                                                          decoration: BoxDecoration(color: project.color, borderRadius: BorderRadius.circular(6)),
                                                          alignment: Alignment.center,
                                                          child: project.icon == null ? null : VisirIcon(type: project.icon!, size: 12, color: Colors.white, isSelected: true),
                                                        ),
                                                      if (project != null) SizedBox(width: 6),
                                                      Expanded(
                                                        child: Text(
                                                          project?.name ?? context.tr.agent_select_project_remove,
                                                          style: context.bodyMedium!.textColor(context.shadow),
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      SizedBox(width: 12),
                                                    ],
                                                  );
                                                },
                                                onSelect: (p) {
                                                  contextProject = p;
                                                  widget.onProjectChanged?.call(p);
                                                  setState(() {});
                                                },
                                              );
                                            },
                                          ),
                                    style: VisirButtonStyle(
                                      margin: EdgeInsets.only(left: 6),
                                      borderRadius: BorderRadius.circular(8),
                                      padding: EdgeInsets.symmetric(horizontal: 6),
                                      backgroundColor: contextProject?.color?.withValues(alpha: 0.5),
                                      height: 28,
                                    ),
                                    options: contextProject?.description?.isNotEmpty == true
                                        ? VisirButtonOptions(tooltipLocation: VisirButtonTooltipLocation.top, message: contextProject!.description)
                                        : null,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: VisirIcon(type: contextProject?.icon ?? VisirIconType.project, size: 14, isSelected: contextProject != null),
                                        ),
                                        if (contextProject != null) SizedBox(width: 4),
                                        if (contextProject != null) Text(contextProject!.name, style: context.bodyLarge?.textColor(context.onBackground)),
                                        if (contextProject != null) SizedBox(width: 3),
                                        if (contextProject != null)
                                          VisirButton(
                                            style: VisirButtonStyle(padding: EdgeInsets.all(4), hoverColor: Colors.transparent, borderRadius: BorderRadius.circular(6)),
                                            options: VisirButtonOptions(tooltipLocation: VisirButtonTooltipLocation.top, message: context.tr.agent_select_project_remove),
                                            onTap: () {
                                              contextProject = null;
                                              widget.onProjectChanged?.call(null);
                                              setState(() {});
                                            },
                                            child: VisirIcon(type: VisirIconType.closeWithCircle, size: 12, isSelected: true),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IntrinsicWidth(
                                child: Builder(
                                  builder: (context) {
                                    final aiApiKeys = ref.watch(aiApiKeysProvider);

                                    return PopupMenu(
                                      forcePopup: true,
                                      location: PopupMenuLocation.bottom,
                                      width: 200,
                                      borderRadius: 6,
                                      type: ContextMenuActionType.tap,
                                      style: VisirButtonStyle(padding: EdgeInsets.all(6), borderRadius: BorderRadius.circular(4), margin: EdgeInsets.only(left: 6)),
                                      options: VisirButtonOptions(
                                        message: context.tr.agent_select_model_hint,
                                        tooltipLocation: VisirButtonTooltipLocation.top,
                                        doNotConvertCase: true,
                                      ),
                                      popup: Builder(
                                        builder: (context) {
                                          final apiKeys = aiApiKeys;
                                          final currentUseUserApiKey = selectedModel?.useUserApiKey ?? false;

                                          // Visir API Key 섹션: 모든 모델
                                          final taskeyApiModels = AgentModel.values.toList();

                                          // User API Key 섹션: 사용자가 API 키를 입력한 provider의 모델만
                                          final userApiModels = <AgentModel>[];
                                          for (final provider in AiProvider.values) {
                                            final hasApiKey = apiKeys[provider.key] != null && apiKeys[provider.key]!.isNotEmpty;
                                            if (hasApiKey) {
                                              userApiModels.addAll(AgentModel.values.where((model) => model.provider == provider).toList());
                                            }
                                          }

                                          // 현재 선택된 모델이 어떤 섹션에 속하는지 결정
                                          final isCurrentModelInVisirSection = taskeyApiModels.contains(selectedModel?.model) && !currentUseUserApiKey;
                                          final isCurrentModelInUserSection = userApiModels.contains(selectedModel?.model) && currentUseUserApiKey;

                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              // Use Visir API Key 섹션 헤더
                                              Padding(
                                                padding: EdgeInsets.only(left: 12, top: 8, bottom: 3),
                                                child: Text(context.tr.agent_use_taskey_api_key, style: context.labelSmall?.textColor(context.inverseSurface).textBold),
                                              ),
                                              // Visir API Key 모델들
                                              SelectionWidget<AgentModel>(
                                                current: isCurrentModelInVisirSection ? selectedModel?.model : null,
                                                items: taskeyApiModels,
                                                getChildHeight: (model) => 28,
                                                getTitle: (model) => model.displayName,
                                                onSelect: (model) {
                                                  ref.read(agentActionControllerProvider.notifier).setModel(model, useUserApiKey: false);
                                                },
                                              ),
                                              // Use User API Key 섹션 헤더 (API 키가 있을 때만)
                                              if (userApiModels.isNotEmpty) ...[
                                                Padding(
                                                  padding: EdgeInsets.only(left: 12, top: 12, bottom: 3),
                                                  child: Text(context.tr.agent_use_user_api_key, style: context.labelSmall?.textColor(context.inverseSurface).textBold),
                                                ),
                                                // User API Key 모델들
                                                SelectionWidget<AgentModel>(
                                                  current: isCurrentModelInUserSection ? selectedModel?.model : null,
                                                  items: userApiModels,
                                                  getChildHeight: (model) => 28,
                                                  getTitle: (model) => model.displayName,
                                                  onSelect: (model) {
                                                    ref.read(agentActionControllerProvider.notifier).setModel(model, useUserApiKey: true);
                                                  },
                                                ),
                                              ],
                                            ],
                                          );
                                        },
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(width: 14, height: 14, child: VisirIcon(type: VisirIconType.agent, size: 14, isSelected: true)),
                                          SizedBox(width: 4),
                                          Text(
                                            aiApiKeys.keys.isEmpty
                                                ? selectedModel?.model.displayName ?? ''
                                                : '${selectedModel?.model.displayName ?? ''} (${(selectedModel?.useUserApiKey ?? false) ? context.tr.agent_use_user_api_key : context.tr.agent_use_taskey_api_key})',
                                            style: context.bodyLarge?.textColor(context.onBackground),
                                          ),
                                          SizedBox(width: 3),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              IntrinsicWidth(
                                child: VisirButton(
                                  type: VisirButtonAnimationType.scaleAndOpacity,
                                  style: VisirButtonStyle(padding: EdgeInsets.all(6), margin: EdgeInsets.only(right: 6), borderRadius: BorderRadius.circular(4)),
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
                                          if (isDummy) return false;
                                          if (!widget.focusNode!.hasFocus) return false;
                                          // Don't send if tag list is visible
                                          if (tagListVisible && tagList.isNotEmpty) return false;
                                          postMessage(html: messageController.html, uploadable: uploadable);
                                          return true;
                                        },
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    postMessage(html: messageController.html, uploadable: uploadable);
                                  },
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
                        ],
                      ),
                    ),
                  ],
                ),

                if (_isDragOverInputField)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(color: context.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius)),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: context.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: context.primary.withValues(alpha: 0.3), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              VisirIcon(type: _isDraggingInbox ? VisirIconType.inbox : VisirIconType.task, size: 16, color: context.primary, isSelected: true),
                              SizedBox(width: 6),
                              Text(_isDraggingInbox ? 'Drop inbox' : (_isDraggingTask ? 'Drop task' : 'Drop here'), style: context.bodyMedium?.textColor(context.primary).textBold),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void highlightNextTag() {
    int index = tagList.indexWhere((e) => e.id == currentTagIdNotifier.value);
    if (index > -1) {
      int nextIndex = index == tagList.length - 1 ? 0 : index + 1;
      currentTagIdNotifier.value = tagList[nextIndex].id ?? '';
      setState(() {});
    }
  }

  void highlightPreviousTag() {
    int index = tagList.indexWhere((e) => e.id == currentTagIdNotifier.value);
    if (index > -1) {
      int previousIndex = index == 0 ? tagList.length - 1 : index - 1;
      currentTagIdNotifier.value = tagList[previousIndex].id ?? '';
      setState(() {});
    }
  }

  void enterTag() {
    int index = tagList.indexWhere((e) => e.id == currentTagIdNotifier.value);
    if (index < 0 || index >= tagList.length) return;
    final tag = tagList[index];

    // First add entity to controller (this stores the entity reference)
    switch (tag.type) {
      case MessageTagEntityType.task:
        if (tag.task != null) messageController.addTaggedData(task: tag.task);
        break;
      case MessageTagEntityType.event:
        if (tag.event != null) messageController.addTaggedData(event: tag.event);
        break;
      case MessageTagEntityType.connection:
        if (tag.connection != null) messageController.addTaggedData(connection: tag.connection);
        break;
      case MessageTagEntityType.channel:
        if (tag.channel != null) messageController.addTaggedData(channel: tag.channel);
        break;
      case MessageTagEntityType.project:
        if (tag.project != null) messageController.addTaggedData(project: tag.project);
        break;
      default:
        break;
    }

    // Then insert tag string (textSpanBuilder will render it as a styled tag)
    String tagString = '\u200b@${tag.displayName}\u200b ';
    final textBeforeCursor = messageController.text.substring(0, messageController.value.selection.end);
    int lastIndex = -1;
    // Find the last @ that is not part of an email address
    for (int i = textBeforeCursor.length - 1; i >= 0; i--) {
      if (textBeforeCursor[i] == '@') {
        if (i == 0 || textBeforeCursor[i - 1] == ' ' || textBeforeCursor[i - 1] == '\n' || textBeforeCursor[i - 1] == '\u200b') {
          lastIndex = i;
          break;
        }
      }
    }
    if (lastIndex < 0) return;

    messageController.text = messageController.text.replaceRange(lastIndex, messageController.value.selection.end, tagString);
    focusNode.requestFocus();
    messageController.updateSelection(TextSelection.collapsed(offset: lastIndex + tagString.length), ChangeSource.local);
    messageController.tagListVisible = false;
    _hideTagListOverlay();

    setState(() {});
  }

  Widget _buildTagListOverlay(Offset caretGlobalPosition) {
    final double itemHeight = 36.0;
    final double sectionHeaderHeight = 28.0;
    final double verticalPadding = 6.0;

    double totalHeight = verticalPadding * 2; // top and bottom padding
    if (taskTags.isNotEmpty) totalHeight += sectionHeaderHeight + (taskTags.length * itemHeight);
    if (eventTags.isNotEmpty) totalHeight += sectionHeaderHeight + (eventTags.length * itemHeight);
    if (connectionTags.isNotEmpty) totalHeight += sectionHeaderHeight + (connectionTags.length * itemHeight);
    if (channelTags.isNotEmpty) totalHeight += sectionHeaderHeight + (channelTags.length * itemHeight);
    if (projectTags.isNotEmpty) totalHeight += sectionHeaderHeight + (projectTags.length * itemHeight);

    final screenSize = MediaQuery.of(context).size;
    // caretGlobalPosition is the caret's top-left corner in global coordinates
    // overlay should appear 6px above the caret, so:
    // overlay bottom = caret top + 6
    final overlayBottom = screenSize.height - (caretGlobalPosition.dy);
    final overlayX = caretGlobalPosition.dx + 10;

    return Positioned(
      bottom: overlayBottom,
      left: overlayX,
      child: TapRegion(
        onTapOutside: (tap) {
          messageController.tagListVisible = false;
          _hideTagListOverlay();
          setState(() {});
        },
        behavior: HitTestBehavior.opaque,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300,
            constraints: BoxConstraints(maxHeight: (totalHeight + 14).clamp(0, double.infinity)),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: context.outline),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (taskTags.isNotEmpty) ...[_buildSectionHeader(context.tr.agent_tag_section_task, taskTags.length), ...taskTags.map((tag) => _buildTagItem(tag, itemHeight))],
                  if (eventTags.isNotEmpty) ...[
                    _buildSectionHeader(context.tr.agent_tag_section_event, eventTags.length),
                    ...eventTags.map((tag) => _buildTagItem(tag, itemHeight)),
                  ],
                  if (connectionTags.isNotEmpty) ...[
                    _buildSectionHeader(context.tr.agent_tag_section_connections, connectionTags.length),
                    ...connectionTags.map((tag) => _buildTagItem(tag, itemHeight)),
                  ],
                  if (channelTags.isNotEmpty) ...[_buildSectionHeader('Channel', channelTags.length), ...channelTags.map((tag) => _buildTagItem(tag, itemHeight))],
                  if (projectTags.isNotEmpty) ...[_buildSectionHeader('Project', projectTags.length), ...projectTags.map((tag) => _buildTagItem(tag, itemHeight))],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Text(title, style: context.titleSmall?.copyWith(color: context.outlineVariant)),
    );
  }

  Widget _buildTagItem(MessageTagEntity tag, double height) {
    return ValueListenableBuilder<String>(
      valueListenable: currentTagIdNotifier,
      builder: (context, value, child) {
        bool isSelected = value == tag.id;
        return VisirButton(
          type: VisirButtonAnimationType.scaleAndOpacity,
          style: VisirButtonStyle(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            backgroundColor: isSelected ? context.outlineVariant.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.zero,
            height: height,
          ),
          onEnter: (event) {
            currentTagIdNotifier.value = tag.id ?? '';
          },
          onTap: () {
            currentTagIdNotifier.value = tag.id ?? '';
            enterTag();
          },
          child: Row(
            children: [
              if (tag.iconData != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: VisirIcon(type: tag.iconData!, size: 16, color: context.onSurface),
                ),
              Expanded(
                child: Text(
                  tag.displayName ?? '',
                  style: context.bodyMedium?.copyWith(color: context.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
