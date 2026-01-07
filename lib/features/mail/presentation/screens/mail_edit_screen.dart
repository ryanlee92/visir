import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/dependency/html_editor/html_editor.dart';
import 'package:Visir/dependency/modal_bottom_sheet/src/utils/modal_scroll_controller.dart';
import 'package:Visir/dependency/super_tag_editor/tag_editor.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/features/common/presentation/widgets/keyboard_shortcut.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/selection_widget.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/mail/actions.dart';
import 'package:Visir/features/mail/application/mail_list_controller.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_file_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_signature_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_user_entity.dart';
import 'package:Visir/features/mail/presentation/widgets/mail_editor_toolbar.dart';
import 'package:Visir/features/preference/application/connection_list_controller.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:collection/collection.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/parser.dart' as html;
import 'package:html_unescape/html_unescape.dart';
import 'package:mime/mime.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:uuid/uuid.dart';

enum FocusType { none, to, cc, bcc, subject, body }

class MailEditScreen extends ConsumerStatefulWidget {
  final MailUserEntity? from;
  final List<MailUserEntity>? to;
  final List<MailUserEntity>? cc;
  final List<MailUserEntity>? bcc;
  final String? subject;
  final String? bodyHtml;
  final List<MailFileEntity>? attachments;
  final List<MailFileEntity>? inlineImage;
  final String? prevMessageId;
  final String? threadId;
  final String? draftId;
  final String? viewTitle;
  final bool? fromDraftBanner;

  const MailEditScreen({
    Key? key,
    this.viewTitle,
    this.from,
    this.to,
    this.cc,
    this.bcc,
    this.subject,
    this.bodyHtml,
    this.attachments,
    this.inlineImage,
    this.prevMessageId,
    this.threadId,
    this.draftId,
    this.fromDraftBanner,
  }) : super(key: key);

  @override
  ConsumerState<MailEditScreen> createState() => MailEditScreenState();
}

class MailEditScreenState extends ConsumerState<MailEditScreen> with WidgetsBindingObserver {
  bool get isDarkMode => context.isDarkMode;

  GlobalKey<ToolbarWidgetState> toolbarWidgetKey = GlobalKey<ToolbarWidgetState>();

  TextEditingController toTextEditingController = TextEditingController();
  TextEditingController ccTextEditingController = TextEditingController();
  TextEditingController bccTextEditingController = TextEditingController();

  FocusNode toFocus = FocusNode();
  FocusNode ccFocus = FocusNode();
  FocusNode bccFocus = FocusNode();
  FocusNode subjectFocus = FocusNode();
  bool bodyFocusHasFocus = false;

  GlobalKey bodyKey = GlobalKey();
  GlobalKey toKey = GlobalKey();
  GlobalKey ccKey = GlobalKey();
  GlobalKey bccKey = GlobalKey();
  GlobalKey subjectKey = GlobalKey();

  GlobalKey _topMenuKey = GlobalKey();

  final _bodyController = HtmlEditorController();
  final _subjectController = TextEditingController();

  late MailUserEntity from;

  bool showCc = false;
  bool showBcc = false;
  bool isDragging = false;

  FocusType focusType = FocusType.none;

  List<MailUserEntity> toUsers = [];
  List<MailUserEntity> ccUsers = [];
  List<MailUserEntity> bccUsers = [];

  List<MailUserEntity> suggestion = [];

  List<MailFileEntity> attachments = [];
  List<MailFileEntity> inlineImage = [];

  int? currentSignature;

  bool isSent = false;
  bool isCloseButtonPressed = false;

  late String messageId;

  String? defaultSignature;
  String? currentBody;
  late String subject;

  late bool isEdited;

  ScrollController? _scrollController;

  String? get initialHtml {
    String html = '';
    if (widget.bodyHtml?.contains('taskey_signature') == true) {
      html = widget.bodyHtml!;
    }

    if (widget.bodyHtml != null || defaultSignature != null) {
      html =
          '''
        ${defaultSignature ?? ''}
        ${widget.bodyHtml ?? ''}
        ''';
    }

    html = widget.bodyHtml ?? '';
    inlineImage.forEach((image) {
      html = html.replaceAll('cid:${image.cid.trim()}', 'data:${image.mimeType};base64,${image.base64String}');
    });

    return html;
  }

  @override
  initState() {
    super.initState();
    initData();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(MailEditScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scrollController?.dispose();
    _scrollController = null;
    initData();
  }

  void initData() {
    showCc = false;
    showBcc = false;
    isDragging = false;

    focusType = FocusType.none;

    toUsers = [];
    ccUsers = [];
    bccUsers = [];

    suggestion = [];

    attachments = [];
    inlineImage = [];

    currentSignature = null;

    isSent = false;
    isCloseButtonPressed = false;

    defaultSignature = null;
    currentBody = null;

    isEdited = false;
    _scrollController = ScrollController();

    messageId = Uuid().v4();

    toFocus.addListener(toFocusListener);
    ccFocus.addListener(ccFocusListener);
    bccFocus.addListener(bccFocusListener);
    subjectFocus.addListener(subjectFocusListener);

    final pref = ref.read(localPrefControllerProvider).value;
    final mails = pref?.mailOAuths ?? [];

    from = widget.from != null
        ? MailUserEntity(
            email: widget.from!.email,
            name: widget.from!.name,
            type: mails.where((e) => e.email == widget.from!.email).firstOrNull?.type.mailType ?? MailEntityType.google,
          )
        : MailUserEntity(
            email: mails.firstOrNull?.email ?? fakeUser.email!,
            name: mails.firstOrNull?.name ?? fakeUser.name,
            type: mails.firstOrNull?.type.mailType ?? MailEntityType.google,
          );

    toUsers = widget.to ?? [];
    ccUsers = widget.cc ?? [];
    bccUsers = widget.bcc ?? [];

    showCc = ccUsers.isNotEmpty;
    showBcc = bccUsers.isNotEmpty;

    subject = widget.subject ?? '';
    _subjectController.text = subject;
    _subjectController.addListener(onSubjectChanged);

    if (widget.prevMessageId != null) {
      List<MailFileEntity> allAttachments = [...(widget.attachments?.toList() ?? [])];
      attachments = allAttachments.where((a) => widget.bodyHtml?.contains('cid:${a.cid}') != true).toList();
      inlineImage = allAttachments.where((a) => widget.bodyHtml?.contains('cid:${a.cid}') == true).toList();

      final attachmentIds = allAttachments.map((e) => e.id).toList();

      ref
          .read(mailListControllerProvider.notifier)
          .fetchAttachments(email: widget.from!.email, type: from.type!, messageId: widget.prevMessageId!, attachmentIds: attachmentIds)
          .then((value) {
            value?.keys.forEach((key) {
              final a = allAttachments.firstWhereOrNull((e) => key == e.id);
              final pref = ref.read(localPrefControllerProvider).value;

              if (a != null && pref != null) {
                final id = a.id;
                final cid = a.cid;
                final name = a.name;
                final data = value[key];

                if (widget.bodyHtml?.contains('cid:${cid}') == true) {
                  if (data != null) {
                    final index = inlineImage.indexWhere((a) => a.id == id);
                    inlineImage.insert(index, MailFileEntity(id: id, cid: cid, name: name, data: data, mimeType: a.mimeType, base64String: base64Encode(data)));
                    inlineImage.removeWhere((a) => a.id == id && a.data == null);
                  } else {
                    inlineImage.removeWhere((a) => a.id == id);
                  }

                  if (initialHtml != null) _bodyController.setText(initialHtml!);
                } else {
                  if (data != null) {
                    final index = attachments.indexWhere((a) => a.id == id);
                    attachments.insert(index, MailFileEntity(id: id, cid: cid, name: name, data: data, mimeType: a.mimeType));
                    attachments.removeWhere((a) => a.id == id && a.data == null);
                  } else {
                    attachments.removeWhere((a) => a.id == id);
                  }
                }
              }
            });

            if (!mounted) return;
            setState(() {});
          });
    }

    final user = ref.read(authControllerProvider).requireValue;
    if (!user.isSignedIn) return;

    final defaultSignatures = user.userDefaultSignatures;
    final item = defaultSignatures[from.email];
    if (item != null) {
      List<MailSignatureEntity> mailSignatures = [...user.userMailSignatures];
      currentSignature = item;
      final signatureHtml = mailSignatures.where((e) => e.number == item).first.signature;
      defaultSignature =
          '''
      <br><br><div id="taskey_signature">$signatureHtml</div>
      ''';
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    final condition = (isEdited || widget.fromDraftBanner == true) && !isSent;
    if (condition) sendMail(isDraft: true);
    Utils.focusApp(forceReset: true, focusNode: Utils.mainFocus);

    toFocus.removeListener(toFocusListener);
    ccFocus.removeListener(ccFocusListener);
    bccFocus.removeListener(bccFocusListener);
    subjectFocus.removeListener(subjectFocusListener);
    _subjectController.removeListener(onSubjectChanged);
  }

  @override
  dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);

    toFocus.dispose();
    ccFocus.dispose();
    bccFocus.dispose();
    subjectFocus.dispose();

    _subjectController.dispose();
    _scrollController?.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    if (mounted) setState(() {});
  }

  void onSubjectChanged() {
    if (subject == _subjectController.text) return;
    subject = _subjectController.text;
    isEdited = true;
  }

  Future<void> _selectAll() async {
    await _bodyController.evaluateJavascript(
      source: """
      (function(){
        var editor = document.querySelector('.note-editable');
        if (editor) {
          editor.focus();
          var range = document.createRange();
          range.selectNodeContents(editor);
          var sel = window.getSelection();
          sel.removeAllRanges();
          sel.addRange(range);
        }
      })();
    """,
    );
  }

  Future<void> _copy() async {
    final text = await _bodyController.evaluateJavascriptWithResult(source: "window.getSelection()?.toString() ?? '';") as String?;

    if (text != null && text.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: text));
    }
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData('text/plain');
    final txt = (data?.text ?? '').replaceAll("'", "\\'");
    await _bodyController.evaluateJavascript(source: "document.execCommand('insertText', false, '$txt');");
  }

  bool _onKeyDown(KeyEvent event, {bool? justReturnResult}) {
    final logicalKeyPressed = ServicesBinding.instance.keyboard.logicalKeysPressed.where((e) => e != LogicalKeyboardKey.escape).toList();
    final shiftPressed = logicalKeyPressed.isShiftPressed;
    final controlPressed = PlatformX.isApple ? logicalKeyPressed.isMetaPressed : logicalKeyPressed.isControlPressed;

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Utils.closeMailEditScreen();
      return true;
    }

    if (toFocus.hasFocus) {
      if (logicalKeyPressed.length == 1 && logicalKeyPressed.contains(LogicalKeyboardKey.tab)) {
        if (justReturnResult == true) return true;
        if (toTextEditingController.text.isNotEmpty) {
          toTextEditingController.text += ' ';
        }

        if (showCc) {
          focusToFocusType(FocusType.cc);
        } else if (showBcc) {
          focusToFocusType(FocusType.bcc);
        } else {
          focusToFocusType(FocusType.subject);
        }
        return true;
      }

      if (logicalKeyPressed.length == 2 && logicalKeyPressed.contains(LogicalKeyboardKey.tab) && shiftPressed) {
        if (justReturnResult == true) return true;
        if (toTextEditingController.text.isNotEmpty) {
          toTextEditingController.text += ' ';
        }

        focusToFocusType(FocusType.body);
        return true;
      }
      return false;
    }
    if (ccFocus.hasFocus) {
      if (logicalKeyPressed.length == 1 && logicalKeyPressed.contains(LogicalKeyboardKey.tab)) {
        if (justReturnResult == true) return true;
        if (ccTextEditingController.text.isNotEmpty) {
          ccTextEditingController.text += ' ';
        }

        if (showBcc) {
          focusToFocusType(FocusType.bcc);
        } else {
          focusToFocusType(FocusType.subject);
        }
        return true;
      }

      if (logicalKeyPressed.length == 2 && logicalKeyPressed.contains(LogicalKeyboardKey.tab) && shiftPressed) {
        if (justReturnResult == true) return true;
        if (ccTextEditingController.text.isNotEmpty) {
          ccTextEditingController.text += ' ';
        }

        focusToFocusType(FocusType.to);
        return true;
      }
      return false;
    }
    if (bccFocus.hasFocus) {
      if (logicalKeyPressed.length == 1 && logicalKeyPressed.contains(LogicalKeyboardKey.tab)) {
        if (justReturnResult == true) return true;
        if (bccTextEditingController.text.isNotEmpty) {
          bccTextEditingController.text += ' ';
        }

        focusToFocusType(FocusType.subject);
        return true;
      }

      if (logicalKeyPressed.length == 2 && logicalKeyPressed.contains(LogicalKeyboardKey.tab) && shiftPressed) {
        if (justReturnResult == true) return true;
        if (bccTextEditingController.text.isNotEmpty) {
          bccTextEditingController.text += ' ';
        }

        if (showCc) {
          focusToFocusType(FocusType.cc);
        } else {
          focusToFocusType(FocusType.to);
        }
        return true;
      }
      return false;
    }
    if (subjectFocus.hasFocus) {
      if (logicalKeyPressed.length == 1 && logicalKeyPressed.contains(LogicalKeyboardKey.tab)) {
        if (justReturnResult == true) return true;
        focusToFocusType(FocusType.body);
        return true;
      }

      if (logicalKeyPressed.length == 2 && logicalKeyPressed.contains(LogicalKeyboardKey.tab) && shiftPressed) {
        if (justReturnResult == true) return true;
        if (showBcc) {
          focusToFocusType(FocusType.bcc);
        } else if (showCc) {
          focusToFocusType(FocusType.cc);
        } else {
          focusToFocusType(FocusType.to);
        }
        return true;
      }
      return false;
    }

    if (bodyFocusHasFocus) {
      if (logicalKeyPressed.length == 2 && controlPressed) {
        if (logicalKeyPressed.contains(LogicalKeyboardKey.keyA)) {
          _selectAll();
        }

        if (logicalKeyPressed.contains(LogicalKeyboardKey.keyC)) {
          _copy();
        }

        if (logicalKeyPressed.contains(LogicalKeyboardKey.keyV)) {
          _paste();
        }
      }
      return true;
    }

    return false;
  }

  void toFocusListener() {
    tagBuilderFocusListener(type: FocusType.to);
  }

  void ccFocusListener() {
    tagBuilderFocusListener(type: FocusType.cc);
  }

  void bccFocusListener() {
    tagBuilderFocusListener(type: FocusType.bcc);
  }

  void subjectFocusListener() {
    tagBuilderFocusListener(type: FocusType.subject);
  }

  void focusToFocusType(FocusType type, {bool? silent}) async {
    if (focusType == type && type != FocusType.body && silent != true) return;

    focusType = type;
    final useHardwareKeyboard = context.viewInset.bottom == 0;
    if (silent != true || !useHardwareKeyboard) setState(() {});

    Future.delayed(Duration(milliseconds: 100), () {
      switch (type) {
        case FocusType.none:
          if (toFocus.hasFocus) toFocus.unfocus();
          if (ccFocus.hasFocus) ccFocus.unfocus();
          if (bccFocus.hasFocus) bccFocus.unfocus();
          if (subjectFocus.hasFocus) subjectFocus.unfocus();
          if (silent != true) _bodyController.clearFocus();
          break;
        case FocusType.to:
          if (ccFocus.hasFocus) ccFocus.unfocus();
          if (bccFocus.hasFocus) bccFocus.unfocus();
          if (subjectFocus.hasFocus) subjectFocus.unfocus();
          if (silent != true) _bodyController.clearFocus();
          if (!toFocus.hasFocus) toFocus.requestFocus();
          break;
        case FocusType.cc:
          if (toFocus.hasFocus) toFocus.unfocus();
          if (bccFocus.hasFocus) bccFocus.unfocus();
          if (subjectFocus.hasFocus) subjectFocus.unfocus();
          if (silent != true) _bodyController.clearFocus();
          if (!ccFocus.hasFocus) ccFocus.requestFocus();
          break;
        case FocusType.bcc:
          if (toFocus.hasFocus) toFocus.unfocus();
          if (ccFocus.hasFocus) ccFocus.unfocus();
          if (subjectFocus.hasFocus) subjectFocus.unfocus();
          if (silent != true) _bodyController.clearFocus();
          if (!bccFocus.hasFocus) bccFocus.requestFocus();
          break;
        case FocusType.subject:
          if (toFocus.hasFocus) toFocus.unfocus();
          if (ccFocus.hasFocus) ccFocus.unfocus();
          if (bccFocus.hasFocus) bccFocus.unfocus();
          if (silent != true) _bodyController.clearFocus();
          if (!subjectFocus.hasFocus) subjectFocus.requestFocus();
          break;
        case FocusType.body:
          if (useHardwareKeyboard) {
            if (toFocus.hasFocus) toFocus.unfocus();
            if (ccFocus.hasFocus) ccFocus.unfocus();
            if (bccFocus.hasFocus) bccFocus.unfocus();
            if (subjectFocus.hasFocus) subjectFocus.unfocus();
          }

          if (silent != true) {
            _bodyController.setFocus();

            if (PlatformX.isWindows && !bodyFocusHasFocus && silent != true) {
              final renderBox = bodyKey.currentContext?.findRenderObject() as RenderBox?;
              Offset? offset = renderBox?.localToGlobal(Offset.zero);
              if (offset == null) return;
              offset = Offset(offset.dx + 20, offset.dy + 20);
              GestureBinding.instance.handlePointerEvent(PointerDownEvent(position: offset));
              GestureBinding.instance.handlePointerEvent(PointerUpEvent(position: offset));
            }
          }
          break;
      }
    });
  }

  void tagBuilderFocusListener({required FocusType type}) {
    final node = type == FocusType.to
        ? toFocus
        : type == FocusType.cc
        ? ccFocus
        : type == FocusType.bcc
        ? bccFocus
        : type == FocusType.subject
        ? subjectFocus
        : null;

    if (node?.hasFocus == true && focusType != type) {
      focusType = type;
      setState(() {});
    }
  }

  void updateSignature(String email) {
    final user = ref.read(authControllerProvider).requireValue;
    final defaultSignatures = user.userDefaultSignatures;

    final item = defaultSignatures[email];
    if (item != null) {
      setSignature(item);
    }
  }

  Future<void> setSignature(int number) async {
    final user = ref.read(authControllerProvider).requireValue;

    List<MailSignatureEntity> mailSignatures = [...user.userMailSignatures];

    currentSignature = number;
    final signature = mailSignatures.where((e) => e.number == number).firstOrNull?.signature;
    if (signature == null) {
      _bodyController.evaluateJavascript(
        source: '''
        var exists = \$('#taskey_signature').length > 0
        if (exists) {
            \$('#taskey_signature').html('')
        } else {
            var html = \$('#summernote-2').summernote('code');
            \$('#summernote-2').summernote('code', html);
        }
    ''',
      );
    } else {
      _bodyController.evaluateJavascript(
        source:
            '''
        var exists = \$('#taskey_signature').length > 0
        if (exists) {
            \$('#taskey_signature').html('$signature')
        } else {
            var html = \$('#summernote-2').summernote('code');
            \$('#summernote-2').summernote('code', html + '<br><br><div id="taskey_signature">$signature</div>');
        }
    ''',
      );
    }

    setState(() {});
  }

  FutureOr<List<MailUserEntity>> findSuggestions(String query) async {
    if (query.isEmpty) return [];
    List<MailUserEntity> list = [];

    final email = from.email;
    final oauth = ref.read(localPrefControllerProvider).value?.mailOAuths?.firstWhereOrNull((e) => e.email == email && e.type.mailType == from.type);
    if (oauth == null) return [];
    final emailConnections = await ref.read(connectionListControllerProvider.notifier).search(provider: oauth.uniqueId, query: query);

    emailConnections.removeWhere((p) => list.map((e) => e.email).toSet().intersection(([p.email]).toSet()).isNotEmpty);
    emailConnections.forEach((p) {
      final email = p.email;
      final name = p.name;
      if (email?.contains(query) == true || name?.contains(query) == true) {
        list.add(MailUserEntity(email: email!, name: name));
      }
    });

    list.sort((a, b) {
      final aEmailIndex = a.email.indexOf(query);
      final bEmailIndex = b.email.indexOf(query);

      final aNameIndex = a.name?.indexOf(query);
      final bNameIndex = b.name?.indexOf(query);

      final aIndex = aNameIndex == null
          ? aEmailIndex
          : aNameIndex < 0
          ? aEmailIndex
          : aEmailIndex < 0
          ? aNameIndex
          : min(aNameIndex, aEmailIndex);

      final bIndex = bNameIndex == null
          ? bEmailIndex
          : bNameIndex < 0
          ? bEmailIndex
          : bEmailIndex < 0
          ? bNameIndex
          : min(bNameIndex, bEmailIndex);

      return aIndex < bIndex ? -1 : 1;
    });

    suggestion = list.sublist(0, list.length > 5 ? 5 : list.length);
    setState(() {});
    return suggestion;
  }

  Widget suggestionBuilder(BuildContext context, TagsEditorState<MailUserEntity> state, MailUserEntity data, int index, int lenght, bool highlight, String? suggestionValid) {
    return Container(
      width: double.maxFinite,
      height: 46,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: suggestion.length > index
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(suggestion[index].email, style: context.bodyLarge?.textColor(context.outlineVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (suggestion[index].name != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(suggestion[index].name!, style: context.bodySmall?.textColor(context.onInverseSurface)),
                  ),
              ],
            )
          : SizedBox.shrink(),
    );
  }

  Future<void> sendMail({required bool isDraft}) async {
    if (toUsers.isEmpty && !isDraft) return;
    if (isSent) return;

    isSent = true;
    final threadId = widget.threadId;
    final messageId = this.messageId;
    final draftId = widget.draftId;

    final from = this.from.copyWith();
    final body = currentBody ?? '';

    // const HtmlEscape htmlEscape = HtmlEscape();

    final document = html.parse(body);
    document.querySelectorAll('img').forEach((element) {
      final src = element.attributes['src'];
      final name = element.attributes['data-filename'];
      if (src != null && src.contains(';base64,')) {
        final cid = Uuid().v4();
        final base64 = src.split(';base64,')[1];
        final mimeType = src.split('data:')[1].split(';base64,')[0];
        if (!inlineImage.any((e) => e.base64String == base64)) {
          final file = MailFileEntity(id: Uuid().v4(), cid: cid, data: base64Decode(base64), name: name ?? Uuid().v4(), mimeType: mimeType);
          inlineImage.add(file);
          element.attributes['src'] = 'cid:$cid';
        }
      }
    });

    HtmlUnescape unescape = HtmlUnescape();
    final _body = unescape.convert(document.body!.innerHtml);

    // Manually encode subject to RFC 2047 Base64 to handle emojis and long text properly
    String encodeSubjectRfc2047(String text) {
      final utf8Bytes = utf8.encode(text);
      final base64Text = base64.encode(utf8Bytes);

      // Split into 60-char chunks to stay under 75-char limit with "=?UTF-8?B?" prefix and "?=" suffix
      const chunkSize = 60;
      if (base64Text.length <= chunkSize) {
        return '=?UTF-8?B?$base64Text?=';
      }

      // Split into multiple encoded-words
      final chunks = <String>[];
      for (var i = 0; i < base64Text.length; i += chunkSize) {
        final end = (i + chunkSize < base64Text.length) ? i + chunkSize : base64Text.length;
        chunks.add('=?UTF-8?B?${base64Text.substring(i, end)}?=');
      }
      return chunks.join('\r\n '); // RFC 2047: continue on next line with space
    }

    final encodedSubject = encodeSubjectRfc2047(subject);

    final builder = MessageBuilder(characterSet: CharacterSet.utf8, transferEncoding: TransferEncoding.base64)
      ..from = [MailAddress(from.name, from.email)]
      ..to = toUsers.map((e) => MailAddress(e.name, e.email)).toList()
      ..cc = ccUsers.map((e) => MailAddress(e.name, e.email)).toList()
      ..bcc = bccUsers.map((e) => MailAddress(e.name, e.email)).toList();

    // Set subject manually as a header to use our custom encoding
    builder.setHeader('Subject', encodedSubject);

    builder.addTextHtml(_body);

    for (MailFileEntity a in attachments) {
      if (a.data != null) {
        final partBuilder = await builder.addBinary(a.data!, MediaType.fromText(a.mimeType), filename: a.name, disposition: ContentDispositionHeader.attachment());
        partBuilder.addHeader('Content-ID', '<${a.cid}>');
      }
    }

    for (MailFileEntity a in inlineImage) {
      if (a.data != null) {
        final partBuilder = await builder.addBinary(
          a.data!,
          MediaType.fromText(a.mimeType),
          filename: a.name,
          disposition: ContentDispositionHeader.inline(filename: a.name),
        );
        partBuilder.addHeader('Content-ID', '<${a.cid}>');
      }
    }

    final mimeMessage = builder.buildMimeMessage();

    if (isDraft) {
      MailAction.saveDarft(
        minimize: !isCloseButtonPressed,
        mail: MailEntity(mailType: from.type!, from: from, draftId: draftId, draftHtml: body, messageId: messageId, threadId: threadId, mimeMessage: mimeMessage, subject: subject),
      );
    } else {
      MailAction.sendMail(
        mimeMessage: mimeMessage,
        mail: MailEntity(mailType: from.type!, from: from, draftId: draftId, messageId: messageId, threadId: threadId, mimeMessage: mimeMessage, subject: subject),
      );

      logAnalyticsEvent(eventName: 'mail_sent');
    }

    if (isDraft != true) {
      Utils.closeMailEditScreen();
    }
  }

  Future<void> deleteDraft() async {
    if (widget.draftId == null) return;
    if (isSent) return;

    isSent = true;

    MailAction.removeDarft(
      mail: MailEntity(
        mailType: widget.from!.type!,
        from: widget.from!,
        draftId: widget.draftId,
        messageId: null,
        threadId: null,
        mimeMessage: null,
        subject: _subjectController.text,
      ),
    );

    Utils.closeMailEditScreen();
  }

  void close() {
    isCloseButtonPressed = true;
    Utils.closeMailEditScreen();
  }

  double scrollViewHeight = 0;
  Map<int, bool> webviewKeycode = {};
  Map<dynamic, dynamic> prevCaretPosition = {};

  Future<void> checkCursorPositionAndScrollIfNeeded() async {
    final rectJson = await _bodyController.evaluateJavascriptWithResult(source: 'JSON.stringify(document.getSelection().getRangeAt(0).getClientRects());');

    if (rectJson == null) return;
    final rect = rectJson is String ? Map.from(jsonDecode(rectJson)) : Map.from(jsonDecode(rectJson['position']));

    final prevFirstNode = prevCaretPosition.values.firstOrNull;
    final currentFirstNode = rect.values.firstOrNull;

    if (currentFirstNode is Map && prevFirstNode is Map) {
      double y = (rect.values.firstOrNull['y'])?.toDouble();
      double height = (rect.values.firstOrNull['height'])?.toDouble();

      if (currentFirstNode['x'] == prevFirstNode['x'] &&
          currentFirstNode['y'] == prevFirstNode['y'] &&
          currentFirstNode['width'] == prevFirstNode['width'] &&
          currentFirstNode['height'] == prevFirstNode['height']) {
        y = (rect.values.last['y']).toDouble();
        height = (rect.values.last['height']).toDouble();
      }

      final topMenu = _topMenuKey.currentContext?.findRenderObject() as RenderBox;
      final targetY = y + topMenu.size.height;

      if (_scrollController != null) {
        if (targetY < _scrollController!.offset) {
          _scrollController!.jumpTo(targetY);
        } else if (targetY + height + 16 > _scrollController!.offset + scrollViewHeight) {
          _scrollController!.jumpTo(targetY + height + 16 - scrollViewHeight);
        }
      }
    }

    prevCaretPosition = rect;
  }

  Widget buildTagBuilder(FocusType type) {
    if (type != FocusType.to && type != FocusType.cc && type != FocusType.bcc) return SizedBox.shrink();
    final textEditingController = type == FocusType.to
        ? toTextEditingController
        : type == FocusType.cc
        ? ccTextEditingController
        : bccTextEditingController;
    final focusNode = type == FocusType.to
        ? toFocus
        : type == FocusType.cc
        ? ccFocus
        : bccFocus;
    final users = type == FocusType.to
        ? toUsers
        : type == FocusType.cc
        ? ccUsers
        : bccUsers;

    if (focusType != type) {
      return Padding(
        padding: EdgeInsets.only(top: 11, bottom: 11, left: 4),
        child: Text(
          users.map((e) => e.name?.isNotEmpty == true ? e.name : e.email).join(', '),
          style: context.titleSmall?.textColor(context.outlineVariant),
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    final textStyle = context.titleSmall?.textColor(context.outlineVariant);
    return TagEditor<MailUserEntity>(
      controller: textEditingController,
      focusNode: focusNode,
      offset: 18,
      customYOffsetOnShowBottom: -11,
      length: users.length,
      delimiters: [',', ' '],
      hasAddButton: false,
      autofocus: false,
      borderRadius: 6,
      padding: EdgeInsets.only(top: 4, bottom: 8),
      borderColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      suggestionsBoxRadius: 6,
      keyboardType: TextInputType.emailAddress,
      onTagChanged: (newValue) {
        users.add(MailUserEntity(email: newValue));
        isEdited = true;
        setState(() {});
      },
      inputHeight: focusType != type ? textStyle!.fontSize! * textStyle.height! : 26,
      inputMargin: focusType != type ? EdgeInsets.only(top: 12) : EdgeInsets.only(top: 4),
      inputDecoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0)),
        errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0)),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0)),
        hoverColor: Colors.transparent,
        fillColor: Colors.transparent,
        filled: true,
      ),
      textStyle: textStyle?.textColor(context.outlineVariant),
      tagBuilder: (context, index) {
        if (focusType != type) {
          return IntrinsicWidth(
            child: VisirButton(
              type: VisirButtonAnimationType.scaleAndOpacity,
              onTap: () {
                focusToFocusType(type);
              },
              style: VisirButtonStyle(margin: EdgeInsets.only(top: 9), padding: EdgeInsets.only(left: 0, right: 0)),
              child: Text(
                '${(users[index].name == null ? users[index].email : '${users[index].name} (${users[index].email})')}${index == users.length - 1 ? '' : ', '}',
                style: context.titleSmall?.textColor(context.outlineVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }

        return Container(
          height: 26,
          decoration: BoxDecoration(color: context.isDarkMode ? context.surfaceTint : context.surface, borderRadius: BorderRadius.circular(6)),
          margin: EdgeInsets.only(right: 8, top: 4, bottom: 2),
          padding: EdgeInsets.only(left: 8, right: 2),
          child: IntrinsicWidth(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    users[index].name?.isNotEmpty != true ? users[index].email : '${users[index].name} (${users[index].email})',
                    style: context.bodyLarge?.textColor(context.outlineVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                VisirButton(
                  type: VisirButtonAnimationType.scaleAndOpacity,
                  style: VisirButtonStyle(padding: EdgeInsets.all(6)),
                  onTap: () {
                    users.removeAt(index);
                    isEdited = true;
                    setState(() {});
                  },
                  child: VisirIcon(type: VisirIconType.closeWithCircle, size: 12, color: context.outlineVariant),
                ),
              ],
            ),
          ),
        );
      },
      onDeleteTagAction: () {
        if (users.isEmpty) return;
        users.removeLast();
        isEdited = true;
        setState(() {});
      },
      suggestionsBoxBackgroundColor: context.surface,
      suggestionItemHeight: 46,
      suggestionPadding: EdgeInsets.symmetric(vertical: 6),
      suggestionMargin: EdgeInsets.symmetric(vertical: 8),
      suggestionBuilder: suggestionBuilder,
      enableSuggestions: suggestion.isNotEmpty,
      onSelectOptionAction: (value) {
        users.add(value);
        isEdited = true;
        setState(() {});
      },
      suggestionsBoxElevation: 0,
      findSuggestions: findSuggestions,
    );
  }

  Size? getDropTargetSize() {
    final topMenuKeyContext = _topMenuKey.currentContext;
    if (topMenuKeyContext != null) {
      final box = topMenuKeyContext.findRenderObject() as RenderBox;
      return box.size;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    _scrollController ??= ModalScrollController.ofSyncGroup(context)?.addAndGet() ?? ScrollController();
    final mailUsers =
        ref.watch(localPrefControllerProvider.select((e) => e.value!.mailOAuths?.map((e) => MailUserEntity(email: e.email, name: e.name, type: e.type.mailType)))) ?? [];

    final useHardwareKeyboard = context.viewInset.bottom == 0;

    final signatures = ref.watch(authControllerProvider.select((e) => e.requireValue.mailSignatures ?? []));
    final backgroundColor = context.background;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        mailEditScreenVisibleNotifier.value = false;
      },
      child: KeyboardShortcut(
        bypassTextField: true,
        bypassMailEditScreen: true,
        onKeyDown: _onKeyDown,
        child: Container(
          decoration: PlatformX.isDesktopView
              ? BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                  border: Border.all(color: context.outline, width: 0.5),
                )
              : null,
          child: ClipRRect(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            child: Material(
              color: backgroundColor,
              child: SafeArea(
                child: GestureDetector(
                  onTap: () => focusToFocusType(FocusType.none),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VisirAppBar(
                        title: widget.viewTitle ?? context.tr.mail_new_message,
                        leadings: [
                          VisirAppBarButton(
                            icon: VisirIconType.close,
                            onTap: close,
                            options: VisirButtonOptions(
                              tooltipLocation: VisirButtonTooltipLocation.right,
                              bypassMailEditScreen: true,
                              shortcuts: [
                                VisirButtonKeyboardShortcut(
                                  message: context.tr.close,
                                  keys: [LogicalKeyboardKey.escape],
                                  onTrigger: () {
                                    if (toolbarWidgetKey.currentState?.isMenuShown() == true) {
                                      toolbarWidgetKey.currentState?.hideMenu();
                                      return true;
                                    } else if (suggestion.isNotEmpty) {
                                      suggestion = [];
                                      setState(() {});
                                      return true;
                                    } else {
                                      Utils.closeMailEditScreen();
                                      return true;
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                        trailings: [
                          if (widget.draftId != null)
                            VisirAppBarButton(
                              backgroundColor: context.surface,
                              foregroundColor: context.outlineVariant,
                              squareForChild: true,
                              margin: EdgeInsets.symmetric(horizontal: 9),
                              options: VisirButtonOptions(
                                tooltipLocation: VisirButtonTooltipLocation.left,
                                bypassMailEditScreen: true,
                                shortcuts: [
                                  VisirButtonKeyboardShortcut(
                                    message: context.tr.mail_discard_draft,
                                    keys: [LogicalKeyboardKey.backspace, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                                    subkeys: [
                                      [LogicalKeyboardKey.delete, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                                    ],
                                  ),
                                ],
                              ),
                              icon: VisirIconType.trash,
                              onTap: deleteDraft,
                            ),
                          VisirAppBarButton(
                            backgroundColor: context.primary,
                            options: VisirButtonOptions(
                              tooltipLocation: VisirButtonTooltipLocation.left,
                              bypassMailEditScreen: true,
                              shortcuts: [
                                VisirButtonKeyboardShortcut(
                                  message: '',
                                  keys: [LogicalKeyboardKey.enter, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                VisirIcon(type: VisirIconType.send, color: context.onPrimary, size: 16, isSelected: true),
                                SizedBox(width: 6),
                                Text(context.tr.mail_send, style: context.labelLarge?.textColor(context.onPrimary).appFont(context)),
                              ],
                            ),
                            onTap: () => sendMail(isDraft: false),
                          ),
                        ],
                      ),
                      Container(height: 1, width: double.maxFinite, color: context.surface),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            scrollViewHeight = constraints.maxHeight;
                            return Stack(
                              children: [
                                SingleChildScrollView(
                                  controller: _scrollController,
                                  physics: Utils.getScrollPhysicsForBottomSheet(context, _scrollController),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        key: _topMenuKey,
                                        children: [
                                          Container(
                                            constraints: BoxConstraints(minHeight: 42),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(width: 16),
                                                Container(
                                                  height: 42,
                                                  alignment: Alignment.center,
                                                  child: Text(context.tr.mail_to, style: context.titleSmall?.textColor(context.onInverseSurface).appFont(context)),
                                                ),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: VisirButton(
                                                    key: toKey,
                                                    type: VisirButtonAnimationType.none,
                                                    onTap: () => focusToFocusType(FocusType.to),
                                                    style: VisirButtonStyle(
                                                      cursor: SystemMouseCursors.text,
                                                      constraints: BoxConstraints(minHeight: 42),
                                                      alignment: Alignment.centerLeft,
                                                    ),
                                                    child: buildTagBuilder(FocusType.to),
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      height: 42,
                                                      child: Row(
                                                        children: [
                                                          if (!showCc)
                                                            VisirButton(
                                                              type: VisirButtonAnimationType.scaleAndOpacity,
                                                              style: VisirButtonStyle(
                                                                cursor: SystemMouseCursors.click,
                                                                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                                                backgroundColor: context.surface,
                                                                borderRadius: BorderRadius.circular(6),
                                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                              ),
                                                              child: Text(context.tr.mail_cc, style: context.labelLarge?.textColor(context.onBackground).appFont(context)),
                                                              onTap: () {
                                                                showCc = true;
                                                                setState(() {});
                                                                focusToFocusType(FocusType.cc);
                                                              },
                                                            ),
                                                          if (!showBcc)
                                                            VisirButton(
                                                              type: VisirButtonAnimationType.scaleAndOpacity,
                                                              style: VisirButtonStyle(
                                                                cursor: SystemMouseCursors.click,
                                                                backgroundColor: context.surface,
                                                                borderRadius: BorderRadius.circular(6),
                                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                                              ),
                                                              child: Text(context.tr.mail_bcc, style: context.labelLarge?.textColor(context.onBackground).appFont(context)),
                                                              onTap: () {
                                                                showBcc = true;
                                                                setState(() {});
                                                                focusToFocusType(FocusType.bcc);
                                                              },
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(width: 12),
                                              ],
                                            ),
                                          ),
                                          Container(height: 1, width: double.maxFinite, color: context.surface, margin: EdgeInsets.symmetric(horizontal: 16)),
                                          if (showCc)
                                            Container(
                                              constraints: BoxConstraints(minHeight: 42),
                                              child: Row(
                                                children: [
                                                  SizedBox(width: 16),
                                                  Text(context.tr.mail_cc, style: context.titleSmall?.textColor(context.onInverseSurface).appFont(context)),
                                                  SizedBox(width: 12),
                                                  Expanded(
                                                    child: VisirButton(
                                                      type: VisirButtonAnimationType.none,
                                                      style: VisirButtonStyle(
                                                        cursor: SystemMouseCursors.text,
                                                        constraints: BoxConstraints(minHeight: 42),
                                                        alignment: Alignment.centerLeft,
                                                      ),
                                                      onTap: () => focusToFocusType(FocusType.cc),
                                                      onFocusChange: (focus) {
                                                        if (!focus) return;
                                                        focusToFocusType(FocusType.cc);
                                                      },
                                                      child: buildTagBuilder(FocusType.cc),
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),
                                                ],
                                              ),
                                            ),
                                          if (showCc) Container(height: 1, width: double.maxFinite, color: context.surface, margin: EdgeInsets.symmetric(horizontal: 16)),
                                          if (showBcc)
                                            Container(
                                              constraints: BoxConstraints(minHeight: 42),
                                              child: Row(
                                                children: [
                                                  SizedBox(width: 16),
                                                  Text(context.tr.mail_bcc, style: context.titleSmall?.textColor(context.onInverseSurface).appFont(context)),
                                                  SizedBox(width: 12),
                                                  Expanded(
                                                    child: VisirButton(
                                                      key: bccKey,
                                                      onFocusChange: (focus) {
                                                        if (!focus) return;
                                                        focusToFocusType(FocusType.bcc);
                                                      },
                                                      type: VisirButtonAnimationType.none,
                                                      style: VisirButtonStyle(
                                                        cursor: SystemMouseCursors.text,
                                                        constraints: BoxConstraints(minHeight: 42),
                                                        alignment: Alignment.centerLeft,
                                                      ),
                                                      onTap: () => focusToFocusType(FocusType.bcc),
                                                      child: buildTagBuilder(FocusType.bcc),
                                                    ),
                                                  ),
                                                  SizedBox(width: 12),
                                                ],
                                              ),
                                            ),
                                          if (showBcc) Container(height: 1, width: double.maxFinite, color: context.surface, margin: EdgeInsets.symmetric(horizontal: 16)),
                                          Container(
                                            height: 42,
                                            child: Row(
                                              children: [
                                                SizedBox(width: 16),
                                                Text(context.tr.mail_from, style: context.titleSmall?.textColor(context.onInverseSurface).appFont(context)),
                                                SizedBox(width: 12),
                                                Expanded(
                                                  child: LayoutBuilder(
                                                    builder: (context, constraints) {
                                                      return Row(
                                                        children: [
                                                          PopupMenu(
                                                            forcePopup: true,
                                                            location: PopupMenuLocation.bottom,
                                                            width: constraints.maxWidth,
                                                            borderRadius: 6,
                                                            type: ContextMenuActionType.tap,
                                                            popup: SelectionWidget<MailUserEntity>(
                                                              current: from,
                                                              items: [from, ...mailUsers.where((e) => e.email != from.email)],
                                                              getChild: (from) {
                                                                return Row(
                                                                  children: [
                                                                    SizedBox(width: 12),
                                                                    Expanded(
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        children: [
                                                                          Text(
                                                                            from.email,
                                                                            style: context.bodyLarge!.textColor(context.outlineVariant),
                                                                            maxLines: 1,
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                          if (from.name != null)
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(top: 4.0),
                                                                              child: Text(
                                                                                from.name ?? '',
                                                                                style: context.bodySmall!.textColor(context.onInverseSurface),
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    SizedBox(width: 12),
                                                                  ],
                                                                );
                                                              },
                                                              onSelect: (selected) {
                                                                from = selected;
                                                                isEdited = true;
                                                                updateSignature(from.email);
                                                                setState(() {});
                                                              },
                                                            ),
                                                            style: VisirButtonStyle(
                                                              height: 26,
                                                              borderRadius: BorderRadius.circular(6),
                                                              backgroundColor: context.surface,
                                                              padding: EdgeInsets.symmetric(horizontal: 8),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  from.name != null ? '${from.name} (${from.email})' : from.email,
                                                                  style: context.bodyLarge?.textColor(context.outlineVariant),
                                                                ),
                                                                SizedBox(width: 6),
                                                                VisirIcon(type: VisirIconType.arrowDown, size: 12, color: context.outlineVariant),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                              ],
                                            ),
                                          ),
                                          Container(height: 1, width: double.maxFinite, color: context.surface, margin: EdgeInsets.symmetric(horizontal: 16)),
                                          Container(
                                            height: 42,
                                            alignment: Alignment.centerLeft,
                                            child: MouseRegion(
                                              cursor: SystemMouseCursors.text,
                                              child: Focus(
                                                onFocusChange: (focus) {
                                                  if (!focus) return;
                                                  focusToFocusType(FocusType.subject);
                                                },
                                                child: GestureDetector(
                                                  onTap: () => focusToFocusType(FocusType.subject),
                                                  child: Container(
                                                    key: subjectKey,
                                                    color: backgroundColor,
                                                    width: double.maxFinite,
                                                    constraints: BoxConstraints(minHeight: 42),
                                                    child: focusType != FocusType.subject && useHardwareKeyboard
                                                        ? Padding(
                                                            padding: EdgeInsets.only(top: 11, bottom: 11, left: 16, right: 12),
                                                            child: Text(
                                                              _subjectController.text.isNotEmpty ? _subjectController.text : context.tr.mail_subject,
                                                              style: context.titleSmall?.textColor(
                                                                _subjectController.text.isNotEmpty ? context.outlineVariant : context.onInverseSurface,
                                                              ),
                                                              maxLines: 1,
                                                            ),
                                                          )
                                                        : Padding(
                                                            padding: const EdgeInsets.only(top: 3, left: 12, right: 12),
                                                            child: TextFormField(
                                                              focusNode: subjectFocus,
                                                              controller: _subjectController,
                                                              style: context.titleSmall?.textColor(context.outlineVariant),
                                                              maxLines: 1,
                                                              onTap: () {
                                                                focusToFocusType(FocusType.subject);
                                                              },
                                                              cursorColor: focusType == FocusType.subject ? context.primary : Colors.transparent,
                                                              decoration: InputDecoration(
                                                                border: InputBorder.none,
                                                                isDense: true,
                                                                fillColor: Colors.transparent,
                                                                hoverColor: Colors.transparent,
                                                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                                                                hintText: context.tr.mail_subject,
                                                                hintStyle: context.titleSmall?.textColor(context.onInverseSurface),
                                                              ),
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(height: 1, width: double.maxFinite, color: context.surface, margin: EdgeInsets.symmetric(horizontal: 16)),
                                        ],
                                      ),
                                      Utils.buildDropTarget(
                                        onDropEnter: () {
                                          isDragging = true;
                                          setState(() {});
                                        },
                                        onDropLeave: () {
                                          isDragging = false;
                                          setState(() {});
                                        },
                                        onDrop: (files) {
                                          attachments.addAll(
                                            files.map(
                                              (e) => MailFileEntity(id: Uuid().v4(), cid: Uuid().v4(), name: e.name, data: e.bytes, mimeType: lookupMimeType(e.name) ?? ''),
                                            ),
                                          );
                                          isDragging = false;
                                          isEdited = true;
                                          setState(() {});
                                        },
                                        child: Padding(
                                          key: bodyKey,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          child: Stack(
                                            children: [
                                              HtmlEditor(
                                                onScrollInsideIframe: (dx, dy) {
                                                  _scrollController?.jumpTo(min(max(0, _scrollController!.offset + dy), _scrollController!.position.maxScrollExtent));
                                                },
                                                controller: _bodyController,
                                                htmlEditorOptions: HtmlEditorOptions(
                                                  width: constraints.maxWidth,
                                                  hint: context.tr.mail_body_placeholder,
                                                  initialText: initialHtml,
                                                  darkMode: context.isDarkMode,
                                                  backgroundColor: backgroundColor,
                                                  defaultFontColor: context.onSurface,
                                                  placeholderColor: context.inverseSurface,
                                                  defaultFontSize: (1.2 * context.textScaler.scale(12.0)).floor(),
                                                  defaultLineHeight: 20,
                                                  minHeight: constraints.maxHeight - 12,
                                                ),
                                                otherOptions: OtherOptions(height: constraints.maxHeight - 12, decoration: BoxDecoration()),
                                                callbacks: Callbacks(
                                                  onBeforeCommand: (_) {},
                                                  onChangeCodeview: (_) {},
                                                  onChangeSelection: (_) {},
                                                  onBlurCodeview: () {},
                                                  onDialogShown: () {},
                                                  onEnter: () {},
                                                  onImageLinkInsert: (_) {},
                                                  onImageUpload: (_) {},
                                                  onImageUploadError: (file, _, err) {},
                                                  onMouseDown: () {
                                                    toolbarWidgetKey.currentState?.hideMenu();
                                                  },
                                                  onMouseUp: () {},
                                                  onNavigationRequestMobile: (_) {
                                                    return NavigationActionPolicy.ALLOW;
                                                  },
                                                  onPaste: () {},
                                                  onInit: () {
                                                    Utils.focusApp(forceReset: true);

                                                    if (PlatformX.isMobileView) return;

                                                    if (toUsers.isEmpty) {
                                                      Future.delayed(Duration(milliseconds: 500), () {
                                                        focusToFocusType(FocusType.to);
                                                      });
                                                    } else if (_subjectController.text.isEmpty) {
                                                      Future.delayed(Duration(milliseconds: 500), () {
                                                        focusToFocusType(FocusType.subject);
                                                      });
                                                    } else {
                                                      focusToFocusType(FocusType.subject);
                                                      Future.delayed(Duration(milliseconds: 500), () {
                                                        focusToFocusType(FocusType.body);
                                                      });
                                                    }
                                                  },
                                                  onChangeContent: (content) {
                                                    currentBody = content;
                                                    if (content?.trim().isNotEmpty != true) {
                                                      isEdited = false;
                                                    } else {
                                                      if (content?.replaceAll(RegExp(r"\s+"), "") != initialHtml?.replaceAll(RegExp(r"\s+"), "")) {
                                                        isEdited = true;
                                                      }
                                                    }

                                                    if (PlatformX.isWeb) checkCursorPositionAndScrollIfNeeded();
                                                  },
                                                  onFocus: () {
                                                    if (bodyFocusHasFocus) return;
                                                    focusToFocusType(FocusType.body, silent: true);
                                                    _bodyController.evaluateJavascript(source: 'window.getSelection().collapseToEnd();');

                                                    webviewKeycode.clear();
                                                    final logicalKeyPressed = ServicesBinding.instance.keyboard.logicalKeysPressed
                                                        .where((e) => e != LogicalKeyboardKey.escape)
                                                        .toList();
                                                    if (logicalKeyPressed.isShiftPressed) {
                                                      webviewKeycode[16] = true;
                                                    }
                                                    bodyFocusHasFocus = true;
                                                  },
                                                  onBlur: () {
                                                    if (!bodyFocusHasFocus) return;
                                                    bodyFocusHasFocus = false;
                                                    Utils.focusApp(doNotFocus: true, forceReset: true);
                                                  },
                                                  onKeyDown: (code) {
                                                    if (!bodyFocusHasFocus) return;
                                                    if (code == null) return;
                                                    webviewKeycode[code] = true;

                                                    if (code == 9) {
                                                      if (webviewKeycode.containsKey(16)) {
                                                        Future.delayed(Duration(milliseconds: 100), () {
                                                          focusToFocusType(FocusType.subject);
                                                        });
                                                      } else {
                                                        Future.delayed(Duration(milliseconds: 100), () {
                                                          focusToFocusType(FocusType.to);
                                                        });
                                                      }
                                                    }

                                                    if (code == 13) {
                                                      if (webviewKeycode.containsKey(91)) {
                                                        sendMail(isDraft: false);
                                                      }
                                                    }

                                                    if (webviewKeycode.containsKey(91)) {
                                                      if (code == 67) {
                                                        _copy();
                                                      }

                                                      if (code == 86) {
                                                        _paste();
                                                      }

                                                      if (code == 65) {
                                                        _selectAll();
                                                      }
                                                    }

                                                    if (code == 27) {
                                                      if (toolbarWidgetKey.currentState?.isMenuShown() == true) {
                                                        toolbarWidgetKey.currentState?.hideMenu();
                                                      } else {
                                                        Utils.closeMailEditScreen();
                                                      }
                                                    }
                                                  },
                                                  onKeyUp: (code) {
                                                    if (code == null) return;
                                                    webviewKeycode.remove(code);
                                                  },
                                                  onScroll: () {
                                                    checkCursorPositionAndScrollIfNeeded();
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isDragging)
                                  Positioned(
                                    top: getDropTargetSize()?.height,
                                    child: Container(
                                      color: context.background.withValues(alpha: 0.75),
                                      height: scrollViewHeight - (getDropTargetSize()?.height ?? 0),
                                      width: getDropTargetSize()?.width,
                                      padding: EdgeInsets.all(16),
                                      child: DottedBorder(
                                        options: RoundedRectDottedBorderOptions(radius: Radius.circular(8), dashPattern: [12, 12], color: context.outline, strokeWidth: 6),
                                        child: Container(
                                          child: Center(child: Text(context.tr.mail_drop_to_attach, style: context.displayMedium?.textColor(context.inverseSurface))),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      if (attachments.isNotEmpty)
                        ExcludeFocus(
                          child: Container(height: 1, width: double.maxFinite, color: context.surface, margin: EdgeInsets.symmetric(horizontal: 16)),
                        ),
                      if (attachments.isNotEmpty)
                        ExcludeFocus(
                          child: Padding(
                            padding: EdgeInsets.only(left: 16, bottom: 12, top: 8, right: 4),
                            child: Wrap(
                              runSpacing: 8,
                              spacing: 8,
                              children: attachments.map((e) {
                                return Container(
                                  width: 192,
                                  height: 50,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        width: 180,
                                        height: 38,
                                        child: Container(
                                          width: 180,
                                          height: 38,
                                          decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(8)),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            child: Text(e.name, style: context.bodyLarge?.textColor(context.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        width: 24,
                                        height: 24,
                                        child: VisirButton(
                                          type: VisirButtonAnimationType.scaleAndOpacity,
                                          style: VisirButtonStyle(
                                            cursor: SystemMouseCursors.click,
                                            width: 24,
                                            height: 24,
                                            alignment: Alignment.center,
                                            hoverColor: Colors.transparent,
                                          ),
                                          onTap: () {
                                            attachments.remove(e);
                                            isEdited = true;
                                            setState(() {});
                                          },
                                          child: CircleAvatar(
                                            radius: 8,
                                            backgroundColor: context.surfaceVariant,
                                            child: e.data == null
                                                ? CustomCircularLoadingIndicator(size: 8, color: context.onSurface)
                                                : VisirIcon(type: VisirIconType.close, size: 10, color: context.onSurface),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ExcludeFocus(
                        child: Container(height: 1, width: double.maxFinite, color: context.surface),
                      ),
                      ExcludeFocus(
                        child: Container(
                          height: 48,
                          alignment: Alignment.center,
                          color: backgroundColor,
                          child: MailEditorToolbar(
                            toolbarWidgetKey: toolbarWidgetKey,
                            controller: _bodyController,
                            signatures: signatures,
                            onChangeSignature: (number) {
                              isEdited = true;
                              setSignature(number);
                            },
                            onFileAdded: (files) {
                              attachments.addAll(files);
                              isEdited = true;
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
