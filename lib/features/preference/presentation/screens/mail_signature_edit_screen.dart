import 'dart:math';

import 'package:Visir/dependency/html_editor/html_editor.dart';
import 'package:Visir/dependency/master_detail_flow/src/details_item.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/keyboard_shortcut.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/mail/domain/entities/mail_signature_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MailSignatureEditScreen extends ConsumerStatefulWidget {
  final MailSignatureEntity? signature;

  const MailSignatureEditScreen({super.key, this.signature});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MailSignatureEditScreenState();
}

class _MailSignatureEditScreenState extends ConsumerState<MailSignatureEditScreen> {
  late HtmlEditorController _bodyController;
  late String _currentHtml;
  Map<int, bool> webviewKeycode = {};
  bool bodyFocusHasFocus = false;
  GlobalKey<ToolbarWidgetState> toolbarWidgetKey = GlobalKey<ToolbarWidgetState>();

  @override
  void initState() {
    super.initState();
    _bodyController = HtmlEditorController();
    _currentHtml = widget.signature?.signature ?? '';
  }

  @override
  void dispose() {
    _bodyController.disable();
    super.dispose();
  }

  Future<void> _save() async {
    final user = ref.read(authControllerProvider).requireValue;
    List<MailSignatureEntity> mailSignatures = [...user.userMailSignatures];

    if (widget.signature != null) {
      // Update existing
      mailSignatures = mailSignatures.map((e) {
        if (e.number == widget.signature!.number) {
          return e.copyWith(signature: _currentHtml);
        }
        return e;
      }).toList();
    } else {
      // Create new
      int number = mailSignatures.isEmpty
          ? 0
          : mailSignatures.length == 1
          ? mailSignatures.first.number + 1
          : mailSignatures.map((m) => m.number).reduce(max) + 1;
      mailSignatures.add(MailSignatureEntity(number: number, signature: _currentHtml));
    }

    await ref.read(authControllerProvider.notifier).updateUser(user: user.copyWith(mailSignatures: mailSignatures));
    Navigator.of(Utils.mainContext).pop();
  }

  Future<void> _delete() async {
    if (widget.signature == null) return;

    final user = ref.read(authControllerProvider).requireValue;
    List<MailSignatureEntity> mailSignatures = [...user.userMailSignatures].where((e) => e.number != widget.signature!.number).toList();

    await ref.read(authControllerProvider.notifier).updateUser(user: user.copyWith(mailSignatures: mailSignatures));
    Navigator.of(Utils.mainContext).pop();
  }

  Future<void> _copy() async {
    webviewKeycode.clear();
    final text = await _bodyController.evaluateJavascriptWithResult(source: "window.getSelection()?.toString() ?? '';") as String?;

    if (text != null && text.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: text));
    }
  }

  Future<void> _paste() async {
    webviewKeycode.clear();
    final data = await Clipboard.getData('text/plain');
    final txt = (data?.text ?? '').replaceAll("'", "\\'");
    await _bodyController.evaluateJavascript(source: "document.execCommand('insertText', false, '$txt');");
  }

  Future<void> _selectAll() async {
    webviewKeycode.clear();
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

  bool _onKeyDown(KeyEvent event, {bool? justReturnResult}) {
    final logicalKeyPressed = ServicesBinding.instance.keyboard.logicalKeysPressed.where((e) => e != LogicalKeyboardKey.escape).toList();
    final controlPressed = PlatformX.isApple ? logicalKeyPressed.isMetaPressed : logicalKeyPressed.isControlPressed;

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(Utils.mainContext);
      return true;
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

  @override
  Widget build(BuildContext context) {
    return DetailsItem(
      title: widget.signature == null ? context.tr.create_signature_title : context.tr.edit_signature_title,
      hideBackButton: true,
      leadings: [VisirAppBarButton(icon: VisirIconType.close, onTap: Navigator.of(Utils.mainContext).pop)],
      actions: [
        if (widget.signature != null) VisirAppBarButton(icon: VisirIconType.trash, onTap: _delete),
        VisirAppBarButton(icon: VisirIconType.check, onTap: _save),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(
                child: Scaffold(
                  backgroundColor: Colors.transparent,
                  body: Padding(
                    padding: const EdgeInsets.only(left: 12.0, right: 12, top: 8),
                    child: KeyboardShortcut(
                      bypassTextField: true,
                      onKeyDown: _onKeyDown,
                      child: HtmlEditor(
                        onScrollInsideIframe: (dx, dy) {
                          // _scrollController?.jumpTo(min(max(0, _scrollController!.offset + dy), _scrollController!.position.maxScrollExtent));
                        },
                        controller: _bodyController,
                        htmlEditorOptions: HtmlEditorOptions(
                          width: constraints.maxWidth,
                          hint: context.tr.mail_body_placeholder,
                          initialText: _currentHtml,
                          darkMode: context.isDarkMode,
                          backgroundColor: context.background,
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
                          onMouseDown: () {},
                          onMouseUp: () {},
                          onNavigationRequestMobile: (_) {
                            return NavigationActionPolicy.ALLOW;
                          },
                          onPaste: () {},
                          onInit: () {
                            Utils.focusApp(forceReset: true);
                            if (PlatformX.isMobileView) return;
                          },
                          onFocus: () {
                            if (bodyFocusHasFocus) return;
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
                          onChangeContent: (content) {
                            _currentHtml = content ?? '';
                          },
                          onKeyUp: (code) {
                            if (code == null) return;
                            webviewKeycode.remove(code);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(width: double.maxFinite, height: 1, color: context.outline),
              Container(height: 6),
              Container(
                height: 44,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ToolbarWidget(
                    key: toolbarWidgetKey,
                    controller: _bodyController,
                    htmlToolbarOptions: HtmlToolbarOptions(
                      renderSeparatorWidget: false,
                      toolbarType: ToolbarType.nativeGrid,
                      overlayColor: context.outline,
                      gridViewVerticalSpacing: 4,
                      gridViewHorizontalSpacing: 0,
                    ),
                    callbacks: Callbacks(),
                    signatures: null,
                    onChangeSignature: null,
                    onFileAdded: null,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
