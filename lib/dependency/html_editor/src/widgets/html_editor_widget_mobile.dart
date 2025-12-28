import 'dart:async';
import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/html_editor/html_editor.dart';
import 'package:Visir/dependency/html_editor/utils/utils.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// The HTML Editor widget itself, for mobile (uses InAppWebView)
class HtmlEditorWidget extends ConsumerStatefulWidget {
  HtmlEditorWidget({
    Key? key,
    required this.controller,
    this.callbacks,
    required this.plugins,
    required this.htmlEditorOptions,
    required this.htmlToolbarOptions,
    required this.otherOptions,
  }) : super(key: key);

  final HtmlEditorController controller;
  final Callbacks? callbacks;
  final List<Plugins> plugins;
  final HtmlEditorOptions htmlEditorOptions;
  final HtmlToolbarOptions htmlToolbarOptions;
  final OtherOptions otherOptions;

  @override
  _HtmlEditorWidgetMobileState createState() => _HtmlEditorWidgetMobileState();
}

/// State for the mobile Html editor widget
///
/// A stateful widget is necessary here to allow the height to dynamically adjust.
class _HtmlEditorWidgetMobileState extends ConsumerState<HtmlEditorWidget> {
  /// The height of the document loaded in the editor
  late double docHeight;

  /// String to use when creating the key for the widget
  late String key;

  /// Stream to transfer the [VisibilityInfo.visibleFraction] to the [onWindowFocus]
  /// function of the webview
  StreamController<double> visibleStream = StreamController<double>.broadcast();

  /// Helps get the height of the toolbar to accurately adjust the height of
  /// the editor when the keyboard is visible.
  GlobalKey toolbarKey = GlobalKey();

  /// Variable to cache the viewable size of the editor to update it in case
  /// the editor is focused much after its visibility changes
  double? cachedVisibleDecimal;

  final double defaultHeight = 12;

  GlobalKey webViewKey = GlobalKey();

  String get finalHtml {
    return summerNoteHtml.replaceFirst('</head>', '''
    <style>
    :root {
      --ui-sans: "Segoe UI Variable", "Segoe UI", system-ui, -apple-system, Arial, sans-serif;
      --ui-kr: "Pretendard Variable", "Noto Sans KR", "Malgun Gothic", sans-serif;
    }
    body { font-family: var(--ui-sans), var(--ui-kr); }
    .copy, .nav, .label { font-weight: 500; }  /* 400가 너무 얇으면 500~600 */
    h1 {
        margin: 0px 0px 4px !important;
        font-size: 32px !important;
    }
    h2 {
        margin: 0px 0px 4px !important;
        font-size: 18px !important;
    }
    p {
        margin: 0px 0px 4px !important;
        font-size: 13px !important;
    }
    h6 {
        margin: 0px 0px 4px !important;
        font-size 10px !important;
    }
    .note-btn:focus,
    .note-btn:active,
    .note-btn.active {
        background-color: #343434 !important;
    }
    .note-placeholder, .note-editable {
        font-size: 13px;
        line-height: 1.2;
    }

    .note-handle .note-control-selection>div {
      position: absolute;
    }


    .note-handle .note-control-selection .note-control-nw {
      top: -5px;
      left: -5px;
      border-right: none;
      border-bottom: none;
    }

    .note-handle .note-control-selection .note-control-ne {
      top: -5px;
      right: -5px;
      border-bottom: none;
      border-left: none;
    }

    .note-handle .note-control-selection .note-control-sw {
      bottom: -5px;
      left: -5px;
      border-top: none;
      border-right: none;
    }

    .note-handle .note-control-selection .note-control-se {
      right: -5px;
      bottom: -5px;
      cursor: se-resize;
    }

    .note-handle .note-control-selection .note-control-se.note-control-holder {
      cursor: default;
      border-top: none;
      border-left: none;
    }

    ${context.isDarkMode ? '''
      ::selection {
        background: ${Color(0xffB7D8FF).toHex()};
      }
      .note-handle .note-control-selection .note-control-selection-info {
        right: 0px;
        bottom: 0px;
        padding: 5px;
        margin: 5px;
        color: #fff;
        background-color: ${Utils.darkTheme.colorScheme.primary.toHex()};
        font-size: 12px;
        border-radius: 5px;
        -webkit-opacity: .7;
        -khtml-opacity: .7;
        -moz-opacity: .7;
        opacity: .7;
        -ms-filter: progid:DXImageTransform.Microsoft.Alpha(opacity=70);
        filter: alpha(opacity=70);
      }
      body {
          background: ${(Utils.darkTheme.colorScheme.background).toHex()} !important;
          caret-color: ${Utils.darkTheme.colorScheme.primary.toHex()};
      }
      .note-editing-area, .note-status-output, .note-codable, .CodeMirror, .CodeMirror-gutter, .note-modal-content, .note-input {
          background: ${Utils.darkTheme.colorScheme.background.toHex()} !important;
      }
      .panel-heading, .note-toolbar, .note-statusbar {
          background: #343434 !important;
      }
      input, select, textarea, .CodeMirror, .note-editable, [class^="note-icon-"], .caseConverter-toggle,
      button > b, button > code, button > var, button > kbd, button > samp, button > small, button > ins, button > del, button > p, button > i {
          color: ${Utils.darkTheme.colorScheme.onSurface.toHex()} !important;
      }
      textarea:focus, input:focus, span, label, .note-status-output {
          color: ${Utils.darkTheme.colorScheme.onSurface.toHex()} !important;
      }
      .note-icon-font {
          color: ${Utils.darkTheme.colorScheme.onSurface.toHex()} !important;
      }
      .note-btn:not(.note-color-btn) {
          background-color: ${Utils.darkTheme.colorScheme.background.toHex()} !important;
      }

      .note-handle .note-control-selection .note-control-selection-bg {
        width: 100%;
        height: 100%;
        background-color: ${Utils.darkTheme.colorScheme.primary.toHex()};
        -webkit-opacity: .3;
        -khtml-opacity: .3;
        -moz-opacity: .3;
        opacity: .3;
        -ms-filter: progid:DXImageTransform.Microsoft.Alpha(opacity=30);
        filter: alpha(opacity=30);
      }

      .note-handle .note-control-selection .note-control-handle,.note-handle .note-control-selection .note-control-holder,.note-handle .note-control-selection .note-control-sizing {
        width: 7px;
        height: 7px;
        border: 1px solid ${PlatformX.isMobileView ? 'transparent' : Utils.darkTheme.colorScheme.primary.toHex()};
      }

      .note-handle .note-control-selection .note-control-sizing {
        background-color: ${PlatformX.isMobileView ? 'transparent' : Utils.darkTheme.colorScheme.primary.toHex()};
      }
      .note-placeholder {
          color: ${Utils.darkTheme.colorScheme.inverseSurface.toHex()};
      }

      .note-handle .note-control-selection {
        position: absolute;
        display: none;
        border: 1px solid ${PlatformX.isMobileView ? 'transparent' : Utils.darkTheme.colorScheme.primary.toHex()};
      }
''' : '''
      ::selection {
        background: ${Color(0xff66809E).toHex()};
      }
      .note-handle .note-control-selection .note-control-selection-info {
        right: 0px;
        bottom: 0px;
        padding: 5px;
        margin: 5px;
        color: #fff;
        background-color: ${Utils.lightTheme.colorScheme.primary.toHex()};
        font-size: 12px;
        border-radius: 5px;
        -webkit-opacity: .7;
        -khtml-opacity: .7;
        -moz-opacity: .7;
        opacity: .7;
        -ms-filter: progid:DXImageTransform.Microsoft.Alpha(opacity=70);
        filter: alpha(opacity=70);
      }
      body {
          background: ${Utils.lightTheme.colorScheme.background.toHex()} !important;
          caret-color: ${Utils.lightTheme.colorScheme.primary.toHex()};
      }
      .note-editing-area, .note-status-output, .note-codable, .CodeMirror, .CodeMirror-gutter, .note-modal-content, .note-input {
          background: ${Utils.lightTheme.colorScheme.background.toHex()} !important;
      }
      .panel-heading, .note-toolbar, .note-statusbar {
          background: #343434 !important;
      }
      input, select, textarea, .CodeMirror, .note-editable, [class^="note-icon-"], .caseConverter-toggle,
      button > b, button > code, button > var, button > kbd, button > samp, button > small, button > ins, button > del, button > p, button > i {
          color: ${Utils.lightTheme.colorScheme.onSurface.toHex()} !important;
      }
      textarea:focus, input:focus, span, label, .note-status-output {
          color: ${Utils.lightTheme.colorScheme.onSurface.toHex()} !important;
      }
      .note-icon-font {
          color: ${Utils.lightTheme.colorScheme.onSurface.toHex()} !important;
      }
      .note-btn:not(.note-color-btn) {
          background-color: ${Utils.lightTheme.colorScheme.background.toHex()} !important;
      }

      .note-handle .note-control-selection .note-control-selection-bg {
        width: 100%;
        height: 100%;
        background-color: ${Utils.lightTheme.colorScheme.primary.toHex()};
        -webkit-opacity: .3;
        -khtml-opacity: .3;
        -moz-opacity: .3;
        opacity: .3;
        -ms-filter: progid:DXImageTransform.Microsoft.Alpha(opacity=30);
        filter: alpha(opacity=30);
      }

      .note-handle .note-control-selection .note-control-handle,.note-handle .note-control-selection .note-control-holder,.note-handle .note-control-selection .note-control-sizing {
        width: 7px;
        height: 7px;
        border: 1px solid ${PlatformX.isMobileView ? 'transparent' : Utils.lightTheme.colorScheme.primary.toHex()};
      }

      .note-handle .note-control-selection .note-control-sizing {
        background-color: ${PlatformX.isMobileView ? 'transparent' : Utils.lightTheme.colorScheme.primary.toHex()};
      }
      .note-placeholder {
          color: ${Utils.lightTheme.colorScheme.inverseSurface.toHex()};
      }

      .note-handle .note-control-selection {
        position: absolute;
        display: none;
        border: 1px solid ${PlatformX.isMobileView ? 'transparent' : Utils.lightTheme.colorScheme.primary.toHex()};
      }
'''}
    </style>
    <script>
      const splitRange = () => {
        var range = \$('#summernote-2').summernote('createRange');
        const textRng = range.splitText();
        return textRng;
      }
    </script>
</head>
''');
  }

  String get emptyHtml {
    return '''
<head>
    <style>
    :root {
      --ui-sans: "Segoe UI Variable", "Segoe UI", system-ui, -apple-system, Arial, sans-serif;
      --ui-kr: "Pretendard Variable", "Noto Sans KR", "Malgun Gothic", sans-serif;
    }
    body { font-family: var(--ui-sans), var(--ui-kr); }
    .copy, .nav, .label { font-weight: 500; }  /* 400가 너무 얇으면 500~600 */
    h1 {
        margin: 0px 0px 4px !important;
        font-size: 32px !important;
    }
    h2 {
        margin: 0px 0px 4px !important;
        font-size: 18px !important;
    }
    p {
        margin: 0px 0px 4px !important;
        font-size: 13px !important;
    }
    h6 {
        margin: 0px 0px 4px !important;
        font-size 10px !important;
    }
    .note-btn:focus,
    .note-btn:active,
    .note-btn.active {
        background-color: #343434 !important;
    }
    .note-placeholder, .note-editable {
        font-size: 13px;
        line-height: 1.2;
    }

    .note-handle .note-control-selection>div {
      position: absolute;
    }


    .note-handle .note-control-selection .note-control-nw {
      top: -5px;
      left: -5px;
      border-right: none;
      border-bottom: none;
    }

    .note-handle .note-control-selection .note-control-ne {
      top: -5px;
      right: -5px;
      border-bottom: none;
      border-left: none;
    }

    .note-handle .note-control-selection .note-control-sw {
      bottom: -5px;
      left: -5px;
      border-top: none;
      border-right: none;
    }

    .note-handle .note-control-selection .note-control-se {
      right: -5px;
      bottom: -5px;
      cursor: se-resize;
    }

    .note-handle .note-control-selection .note-control-se.note-control-holder {
      cursor: default;
      border-top: none;
      border-left: none;
    }

    ${context.isDarkMode ? '''
      ::selection {
        background: ${Color(0xffB7D8FF).toHex()};
      }
      .note-handle .note-control-selection .note-control-selection-info {
        right: 0px;
        bottom: 0px;
        padding: 5px;
        margin: 5px;
        color: #fff;
        background-color: ${Utils.darkTheme.colorScheme.primary.toHex()};
        font-size: 12px;
        border-radius: 5px;
        -webkit-opacity: .7;
        -khtml-opacity: .7;
        -moz-opacity: .7;
        opacity: .7;
        -ms-filter: progid:DXImageTransform.Microsoft.Alpha(opacity=70);
        filter: alpha(opacity=70);
      }
      body {
          background: ${Utils.darkTheme.colorScheme.background.toHex()} !important;
          caret-color: ${Utils.darkTheme.colorScheme.primary.toHex()};
      }
      .note-editing-area, .note-status-output, .note-codable, .CodeMirror, .CodeMirror-gutter, .note-modal-content, .note-input {
          background: ${Utils.darkTheme.colorScheme.background.toHex()} !important;
      }
      .panel-heading, .note-toolbar, .note-statusbar {
          background: #343434 !important;
      }
      input, select, textarea, .CodeMirror, .note-editable, [class^="note-icon-"], .caseConverter-toggle,
      button > b, button > code, button > var, button > kbd, button > samp, button > small, button > ins, button > del, button > p, button > i {
          color: ${Utils.darkTheme.colorScheme.onSurface.toHex()} !important;
      }
      textarea:focus, input:focus, span, label, .note-status-output {
          color: ${Utils.darkTheme.colorScheme.onSurface.toHex()} !important;
      }
      .note-icon-font {
          color: ${Utils.darkTheme.colorScheme.onSurface.toHex()} !important;
      }
      .note-btn:not(.note-color-btn) {
          background-color: ${Utils.darkTheme.colorScheme.background.toHex()} !important;
      }

      .note-handle .note-control-selection .note-control-selection-bg {
        width: 100%;
        height: 100%;
        background-color: ${Utils.darkTheme.colorScheme.primary.toHex()};
        -webkit-opacity: .3;
        -khtml-opacity: .3;
        -moz-opacity: .3;
        opacity: .3;
        -ms-filter: progid:DXImageTransform.Microsoft.Alpha(opacity=30);
        filter: alpha(opacity=30);
      }

      .note-handle .note-control-selection .note-control-handle,.note-handle .note-control-selection .note-control-holder,.note-handle .note-control-selection .note-control-sizing {
        width: 7px;
        height: 7px;
        border: 1px solid ${PlatformX.isMobileView ? 'transparent' : Utils.darkTheme.colorScheme.primary.toHex()};
      }

      .note-handle .note-control-selection .note-control-sizing {
        background-color: ${PlatformX.isMobileView ? 'transparent' : Utils.darkTheme.colorScheme.primary.toHex()};
      }
      .note-placeholder {
          color: ${Utils.darkTheme.colorScheme.inverseSurface.toHex()};
      }

      .note-handle .note-control-selection {
        position: absolute;
        display: none;
        border: 1px solid ${PlatformX.isMobileView ? 'transparent' : Utils.darkTheme.colorScheme.primary.toHex()};
      }
''' : '''
      ::selection {
        background: ${Color(0xff66809E).toHex()};
      }
      .note-handle .note-control-selection .note-control-selection-info {
        right: 0px;
        bottom: 0px;
        padding: 5px;
        margin: 5px;
        color: #fff;
        background-color: ${Utils.lightTheme.colorScheme.primary.toHex()};
        font-size: 12px;
        border-radius: 5px;
        -webkit-opacity: .7;
        -khtml-opacity: .7;
        -moz-opacity: .7;
        opacity: .7;
        -ms-filter: progid:DXImageTransform.Microsoft.Alpha(opacity=70);
        filter: alpha(opacity=70);
      }
      body {
          background: ${Utils.lightTheme.colorScheme.background.toHex()} !important;
          caret-color: ${Utils.lightTheme.colorScheme.primary.toHex()};
      }
      .note-editing-area, .note-status-output, .note-codable, .CodeMirror, .CodeMirror-gutter, .note-modal-content, .note-input {
          background: ${Utils.lightTheme.colorScheme.background.toHex()} !important;
      }
      .panel-heading, .note-toolbar, .note-statusbar {
          background: #343434 !important;
      }
      input, select, textarea, .CodeMirror, .note-editable, [class^="note-icon-"], .caseConverter-toggle,
      button > b, button > code, button > var, button > kbd, button > samp, button > small, button > ins, button > del, button > p, button > i {
          color: ${Utils.lightTheme.colorScheme.onSurface.toHex()} !important;
      }
      textarea:focus, input:focus, span, label, .note-status-output {
          color: ${Utils.lightTheme.colorScheme.onSurface.toHex()} !important;
      }
      .note-icon-font {
          color: ${Utils.lightTheme.colorScheme.onSurface.toHex()} !important;
      }
      .note-btn:not(.note-color-btn) {
          background-color: ${Utils.lightTheme.colorScheme.background.toHex()} !important;
      }

      .note-handle .note-control-selection .note-control-selection-bg {
        width: 100%;
        height: 100%;
        background-color: ${Utils.lightTheme.colorScheme.primary.toHex()};
        -webkit-opacity: .3;
        -khtml-opacity: .3;
        -moz-opacity: .3;
        opacity: .3;
        -ms-filter: progid:DXImageTransform.Microsoft.Alpha(opacity=30);
        filter: alpha(opacity=30);
      }

      .note-handle .note-control-selection .note-control-handle,.note-handle .note-control-selection .note-control-holder,.note-handle .note-control-selection .note-control-sizing {
        width: 7px;
        height: 7px;
        border: 1px solid ${PlatformX.isMobileView ? 'transparent' : Utils.lightTheme.colorScheme.primary.toHex()};
      }

      .note-handle .note-control-selection .note-control-sizing {
        background-color: ${PlatformX.isMobileView ? 'transparent' : Utils.lightTheme.colorScheme.primary.toHex()};
      }
      .note-placeholder {
          color: ${Utils.lightTheme.colorScheme.inverseSurface.toHex()};
      }

      .note-handle .note-control-selection {
        position: absolute;
        display: none;
        border: 1px solid ${PlatformX.isMobileView ? 'transparent' : Utils.lightTheme.colorScheme.primary.toHex()};
      }
'''}
    }
    </style>
    </head>
    <body></body>
    ''';
  }

  String summerNoteHtml = '';
  @override
  void initState() {
    docHeight = defaultHeight;
    key = getRandString(10);

    rootBundle.loadString('assets/html_editor/summernote-no-plugins.html').then((value) {
      summerNoteHtml = value;
    });

    super.initState();
  }

  @override
  void dispose() {
    visibleStream.close();
    widget.controller.editorController?.dispose();
    super.dispose();
  }

  bool get isDummy => widget.htmlEditorOptions.initialText == 'about:blank';

  void setData() {
    if (isDummy) {
      widget.controller.editorController?.loadData(data: emptyHtml);
    } else {
      docHeight = defaultHeight;

      widget.controller.addJavaScriptHandler(
        handlerName: 'FormatSettings',
        callback: (e) {
          var json = e[0] as Map<String, dynamic>;
          if (widget.controller.toolbar != null) {
            widget.controller.toolbar!.updateToolbar(json);
          }
          widget.callbacks?.onScroll?.call();
        },
      );

      widget.controller.addJavaScriptHandler(
        handlerName: 'setHeight',
        callback: (height) {
          if (height.first != 'reset') {
            setState(mounted, this.setState, () {
              docHeight = (double.tryParse(height.first.toString()) ?? widget.otherOptions.height);
            });
          }
        },
      );

      widget.controller.addJavaScriptHandler(
        handlerName: 'totalChars',
        callback: (keyCode) {
          widget.controller.characterCount = keyCode.first as int;
        },
      );
      widget.controller.addJavaScriptHandler(
        handlerName: 'onChangeContent',
        callback: (contents) {
          if (widget.htmlEditorOptions.shouldEnsureVisible) {
            Scrollable.of(context).position.ensureVisible(context.findRenderObject()!);
          }
          if (widget.callbacks != null && widget.callbacks!.onChangeContent != null) {
            widget.callbacks!.onChangeContent!.call(contents.first.toString());
          }

          if (widget.htmlEditorOptions.autoAdjustHeight) {
            widget.controller.recalculateHeight();
          }

          if (contents.length == 1 && (contents.first == '<div><br></div>' || contents.first == '<br>')) {
            widget.controller.clear();
          }
        },
      );

      widget.controller.editorController?.loadData(data: finalHtml);
    }
  }

  @override
  void didUpdateWidget(HtmlEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.htmlEditorOptions.initialText != oldWidget.htmlEditorOptions.initialText) {
      setData();
    }
  }

  final iosLineBreakScript = UserScript(
    source: r"""
// iOS caret/줄바꿈 안전 패치 (documentStart)
(function() {
  // 편집영역 속성: 자동교정류 비활성
  document.addEventListener('DOMContentLoaded', function(){
    var nodes = document.querySelectorAll('.note-editable, [contenteditable="true"]');
    nodes.forEach(function(el){
      el.setAttribute('autocorrect','off');
      el.setAttribute('autocapitalize','off');
      el.setAttribute('spellcheck','false');
      el.setAttribute('autocomplete','off');
      el.setAttribute('inputmode','text');
    });
  });

  // iOS-safe linebreak
  function insertLineBreakIOSSafe() {
    var sel = window.getSelection();
    if (!sel || !sel.rangeCount) return;
    var range = sel.getRangeAt(0);
    range.deleteContents();
    var br = document.createElement('br');
    var zwsp = document.createTextNode('\u200B'); // 또는 '\u2063'
    var frag = document.createDocumentFragment();
    frag.appendChild(br); frag.appendChild(zwsp);
    range.insertNode(frag);
    range.setStart(zwsp, 1); range.setEnd(zwsp, 1);
    sel.removeAllRanges(); sel.addRange(range);
    requestAnimationFrame(function(){ sel.removeAllRanges(); sel.addRange(range); });
  }

  // iOS에서 Enter 처리 가로채기
  document.addEventListener('beforeinput', function(e){
    var t = e.inputType;
    if (t === 'insertParagraph' || t === 'insertLineBreak') {
      e.preventDefault();
      insertLineBreakIOSSafe();
    }
  }, {capture:true});
})();
  """,
    injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
    // iOS 14+에서 페이지 컨텍스트로
    iosForMainFrameOnly: true,
  );

  void setZoom() {
    final ratio = ref.read(zoomRatioProvider);
    widget.controller.editorController?.evaluateJavascript(
      source:
          '''
          document.body.style.zoom = "${1 / 1 * ratio}";
    ''',
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(zoomRatioProvider, (previous, next) {
      setZoom();
    });

    return VisirButton(
      type: VisirButtonAnimationType.none,
      style: VisirButtonStyle(),
      onTap: () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
      child: VisibilityDetector(
        key: Key(key),
        onVisibilityChanged: (VisibilityInfo info) async {
          if (!visibleStream.isClosed && !isDummy) {
            cachedVisibleDecimal = info.visibleFraction == 1 ? (info.size.height / widget.otherOptions.height).clamp(0, 1) : info.visibleFraction;
            visibleStream.add(info.visibleFraction == 1 ? (info.size.height / widget.otherOptions.height).clamp(0, 1) : info.visibleFraction);
          }
        },
        child: Container(
          width: widget.htmlEditorOptions.width,
          height: max(docHeight + 20, widget.htmlEditorOptions.minHeight ?? 0),
          child: SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: Container(
              width: max(1, widget.htmlEditorOptions.width ?? 1),
              height: isDummy ? 1 : max(docHeight + 200, widget.htmlEditorOptions.minHeight ?? 1),
              child: InAppWebView(
                key: webViewKey,
                webViewEnvironment: webViewEnvironment,
                initialData: InAppWebViewInitialData(data: isDummy ? emptyHtml : finalHtml),
                initialSettings: InAppWebViewSettings(
                  transparentBackground: false,
                  javaScriptEnabled: true,
                  useShouldOverrideUrlLoading: true,
                  useHybridComposition: widget.htmlEditorOptions.androidUseHybridComposition,
                  loadWithOverviewMode: true,
                  disableInputAccessoryView: true,
                  mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                  incognito: true,
                  verticalScrollBarEnabled: false,
                  horizontalScrollBarEnabled: false,
                  disableVerticalScroll: true,
                  disableHorizontalScroll: true,
                  needInitialFocus: false,
                ),
                onWebViewCreated: (InAppWebViewController controller) {
                  widget.controller.editorController = controller;
                  setData();
                },
                // initialUserScripts: widget.htmlEditorOptions.mobileInitialScripts as UnmodifiableListView<UserScript>?,
                // contextMenu: widget.htmlEditorOptions.mobileContextMenu as ContextMenu?,
                gestureRecognizers: {
                  // Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer()),
                  Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer(duration: widget.htmlEditorOptions.mobileLongPressDuration)),
                  Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
                },
                shouldOverrideUrlLoading: (controller, action) async {
                  if (!action.request.url.toString().contains('summernote')) {
                    return (await widget.callbacks?.onNavigationRequestMobile?.call(action.request.url.toString())) ?? NavigationActionPolicy.ALLOW;
                  }
                  return NavigationActionPolicy.ALLOW;
                },
                onLoadStop: (controller, uri) async {
                  if (isDummy) return;
                  var maximumFileSize = 10485760;
                  var summernoteToolbar = '[\n';
                  var summernoteCallbacks =
                      '''callbacks: {
                        onKeydown: function(e) {
                            var chars = \$(".note-editable").text();
                            var totalChars = chars.length;
                            var charCode = e.charCode || e.keyCode || e.which;
                            if (!taskeyPressedKeys.includes(charCode)) {
                              taskeyPressedKeys.push(charCode);
                            }
                            
                            window.flutter_inappwebview.callHandler('onKeyDown', JSON.stringify(e.keyCode));
                            
                            if (charCode == 27){
                              e.preventDefault();
                              return true;
                            }
                            
                            if (charCode == 13 && taskeyPressedKeys.includes(91)) {
                              e.preventDefault();
                              return true;
                            }
                            
                            ${widget.htmlEditorOptions.characterLimit != null ? '''allowedKeys = (
                                e.which === 8 ||  /* BACKSPACE */
                                e.which === 35 || /* END */
                                e.which === 36 || /* HOME */
                                e.which === 37 || /* LEFT */
                                e.which === 38 || /* UP */
                                e.which === 39 || /* RIGHT*/
                                e.which === 40 || /* DOWN */
                                e.which === 46 || /* DEL*/
                                e.ctrlKey === true && e.which === 65 || /* CTRL + A */
                                e.ctrlKey === true && e.which === 88 || /* CTRL + X */
                                e.ctrlKey === true && e.which === 67 || /* CTRL + C */
                                e.ctrlKey === true && e.which === 86 || /* CTRL + V */
                                e.ctrlKey === true && e.which === 90    /* CTRL + Z */
                            );
                            if (!allowedKeys && \$(e.target).text().length >= ${widget.htmlEditorOptions.characterLimit}) {
                                e.preventDefault();
                            }''' : ''}

                            window.flutter_inappwebview.callHandler('totalChars', JSON.stringify(totalChars));
                        },
                        onKeyup: function(e) {
                          var charCode = e.charCode || e.keyCode || e.which;
                                                    
                          var index = taskeyPressedKeys.indexOf(charCode);
                          if (index !== -1) {
                            taskeyPressedKeys.splice(index, 1);
                          }
                          
                          window.flutter_inappwebview.callHandler('onKeyUp', JSON.stringify(e.keyCode));
                        },
                        onEnter: function (e) {
                          e.preventDefault();                       // 기본 <p> 생성 막기
                          document.execCommand('insertLineBreak');  // 대신 <br> 삽입
                        },
                    ''';
                  if (widget.plugins.isNotEmpty) {
                    summernoteToolbar = summernoteToolbar + "['plugins', [";
                    for (var p in widget.plugins) {
                      summernoteToolbar =
                          summernoteToolbar +
                          (p.getToolbarString().isNotEmpty ? "'${p.getToolbarString()}'" : '') +
                          (p == widget.plugins.last
                              ? ']]\n'
                              : p.getToolbarString().isNotEmpty
                              ? ', '
                              : '');
                      if (p is SummernoteAtMention) {
                        summernoteCallbacks =
                            summernoteCallbacks +
                            """
                            \nsummernoteAtMention: {
                              getSuggestions: async function(value) {
                                var result = await window.flutter_inappwebview.callHandler('getSuggestions', JSON.stringify(value));
                                var resultList = result.split(',');
                                return resultList;
                              },
                              onSelect: (value) => {
                                  window.flutter_inappwebview.callHandler('onSelectMention', JSON.stringify(value));
                              },
                            },
                          """;
                        // widget.controller.addJavaScriptHandler(
                        //     handlerName: 'getSuggestions',
                        //     callback: (value) {
                        //       p.getSuggestionsMobile!.call(value.first.toString()).toString().replaceAll('[', '').replaceAll(']', '');
                        //     });
                        if (p.onSelect != null) {
                          // widget.controller.addJavaScriptHandler(
                          //     handlerName: 'onSelectMention',
                          //     callback: (value) {
                          //       p.onSelect!.call(value.first.toString());
                          //     });
                        }
                      }
                    }
                  }
                  if (widget.callbacks != null) {
                    if (widget.callbacks!.onImageLinkInsert != null) {
                      summernoteCallbacks =
                          summernoteCallbacks +
                          """
                            onImageLinkInsert: function(url) {
                              window.flutter_inappwebview.callHandler('onImageLinkInsert', JSON.stringify(url));
                            },
                          """;
                    }
                    if (widget.callbacks!.onImageUpload != null) {
                      summernoteCallbacks =
                          summernoteCallbacks +
                          """
                            onImageUpload: function(files) {
                              var reader = new FileReader();
                              var base64 = "<an error occurred>";
                              reader.onload = function (_) {
                                base64 = reader.result;
                                var newObject = {
                                   'lastModified': files[0].lastModified,
                                   'lastModifiedDate': files[0].lastModifiedDate,
                                   'name': files[0].name,
                                   'size': files[0].size,
                                   'type': files[0].type,
                                   'base64': base64
                                };

                                window.flutter_inappwebview.callHandler('onImageUpload', JSON.stringify(newObject));
                              };
                              reader.onerror = function (_) {
                                var newObject = {
                                   'lastModified': files[0].lastModified,
                                   'lastModifiedDate': files[0].lastModifiedDate,
                                   'name': files[0].name,
                                   'size': files[0].size,
                                   'type': files[0].type,
                                   'base64': base64
                                };

                                window.flutter_inappwebview.callHandler('onImageUpload', JSON.stringify(newObject));
                              };
                              reader.readAsDataURL(files[0]);
                            },
                          """;
                    }
                    if (widget.callbacks!.onImageUploadError != null) {
                      summernoteCallbacks =
                          summernoteCallbacks +
                          """
                              onImageUploadError: function(file, error) {
                                if (typeof file === 'string') {
                                  window.flutter_inappwebview.callHandler('onImageUploadError', JSON.stringify(file));
                                } else {
                                  var newObject = {
                                     'lastModified': file.lastModified,
                                     'lastModifiedDate': file.lastModifiedDate,
                                     'name': file.name,
                                     'size': file.size,
                                     'type': file.type,
                                  };
                                  window.flutter_inappwebview.callHandler('onImageUploadError', JSON.stringify(newObject));
                                }
                              },
                          """;
                    }
                  }
                  summernoteToolbar = summernoteToolbar + '],';
                  summernoteCallbacks = summernoteCallbacks + '}';
                  await widget.controller.evaluateJavascript(
                    source:
                        """
                        \$('#summernote-2').summernote({
                            prettifyHtml: false,
                            placeholder: "${widget.htmlEditorOptions.hint ?? ""}",
                            tabsize: 2,
                            height: ${widget.otherOptions.height},
                            toolbar: false,
                            popover: false,
                            disableGrammar: false,
                            disableDragAndDrop: true,
                            spellCheck: ${widget.htmlEditorOptions.spellCheck},
                            maximumFileSize: $maximumFileSize,
                            ${widget.htmlEditorOptions.customOptions}
                            $summernoteCallbacks
                        });


                        \$('#summernote-2').summernote('code', '');
                        \$("#summernote-2").summernote("fullscreen.toggle");

                        var totalHeight = 0;
                        if (\$('div.note-editable').children().length > 0) {
                            \$('div.note-editable').children().each(function(){
                                totalHeight += \$(this).outerHeight(true); // true = include margins
                            });
                        } else {
                            totalHeight = \$('div.note-placeholder').height();
                        }

                        totalHeight += parseInt(\$('div.note-editable').css('padding-top'), 10);
                        totalHeight += parseInt(\$('div.note-editable').css('padding-bottom'), 10);

                        window.flutter_inappwebview.callHandler('setHeight', JSON.stringify(totalHeight));

                        \$('#summernote-2').on('summernote.change', function(_, contents, \$editable) {
                          window.flutter_inappwebview.callHandler('onChangeContent', JSON.stringify(contents));
                        });

                        function onSelectionChange() {
                          let {anchorNode, anchorOffset, focusNode, focusOffset} = document.getSelection();
                          var isBold = false;
                          var isItalic = false;
                          var isUnderline = false;
                          var isStrikethrough = false;
                          var isSuperscript = false;
                          var isSubscript = false;
                          var isUL = false;
                          var isOL = false;
                          var isLeft = false;
                          var isRight = false;
                          var isCenter = false;
                          var isFull = false;
                          var parent;
                          var fontName;
                          var fontSize = 16;
                          var foreColor;
                          var backColor;
                          var focusNode2 = \$(window.getSelection().focusNode);
                          var parentList = focusNode2.closest("div.note-editable ol, div.note-editable ul");
                          var parentListType = parentList.css('list-style-type');
                          var lineHeight = \$(focusNode.parentNode).css('line-height');
                          var direction = \$(focusNode.parentNode).css('direction');
                          if (document.queryCommandState) {
                            isBold = document.queryCommandState('bold');
                            isItalic = document.queryCommandState('italic');
                            isUnderline = document.queryCommandState('underline');
                            isStrikethrough = document.queryCommandState('strikeThrough');
                            isSuperscript = document.queryCommandState('superscript');
                            isSubscript = document.queryCommandState('subscript');
                            isUL = document.queryCommandState('insertUnorderedList');
                            isOL = document.queryCommandState('insertOrderedList');
                            isLeft = document.queryCommandState('justifyLeft');
                            isRight = document.queryCommandState('justifyRight');
                            isCenter = document.queryCommandState('justifyCenter');
                            isFull = document.queryCommandState('justifyFull');
                          }
                          if (document.queryCommandValue) {
                            parent = document.queryCommandValue('formatBlock');
                            fontSize = document.queryCommandValue('fontSize');
                            foreColor = document.queryCommandValue('foreColor');
                            backColor = document.queryCommandValue('hiliteColor');
                            fontName = document.queryCommandValue('fontName');
                          }
                          var message = {
                            'style': parent,
                            'fontName': fontName,
                            'fontSize': fontSize,
                            'font': [isBold, isItalic, isUnderline],
                            'miscFont': [isStrikethrough, isSuperscript, isSubscript],
                            'color': [foreColor, backColor],
                            'paragraph': [isUL, isOL],
                            'listStyle': parentListType,
                            'align': [isLeft, isCenter, isRight, isFull],
                            'lineHeight': lineHeight,
                            'direction': direction,
                          };

                          window.flutter_inappwebview.callHandler('FormatSettings', JSON.stringify(message));
                        }
                    """,
                  );
                  await widget.controller.evaluateJavascript(source: "document.onselectionchange = onSelectionChange; console.log('done');");
                  await widget.controller.evaluateJavascript(
                    source: "document.getElementsByClassName('note-editable')[0].setAttribute('inputmode', '${(widget.htmlEditorOptions.inputType).name}');",
                  );

                  //set the text once the editor is loaded
                  if (widget.htmlEditorOptions.initialText != null) {
                    widget.controller.setText(widget.htmlEditorOptions.initialText!);
                  }

                  //disable editor if necessary
                  if (widget.htmlEditorOptions.disabled) {
                    widget.controller.disable();
                  }
                  //initialize callbacks
                  if (widget.callbacks != null) {
                    addJSCallbacks(widget.callbacks!);
                  }

                  if (widget.callbacks != null) {
                    addJSHandlers(widget.callbacks!);
                  }

                  //call onInit callback
                  if (widget.callbacks != null && widget.callbacks!.onInit != null) {
                    widget.callbacks!.onInit!.call();
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// adds the callbacks set by the user into the scripts
  void addJSCallbacks(Callbacks c) {
    if (c.onBeforeCommand != null) {
      widget.controller.evaluateJavascript(
        source: """
          \$('#summernote-2').on('summernote.before.command', function(_, contents) {
            window.flutter_inappwebview.callHandler('onBeforeCommand', JSON.stringify("fired"));
          });
        """,
      );
    }
    if (c.onChangeCodeview != null) {
      widget.controller.evaluateJavascript(
        source: """
          \$('#summernote-2').on('summernote.change.codeview', function(_, contents, \$editable) {
            window.flutter_inappwebview.callHandler('onChangeCodeview', JSON.stringify("fired"));
          });
        """,
      );
    }
    if (c.onDialogShown != null) {
      widget.controller.evaluateJavascript(
        source: """
          \$('#summernote-2').on('summernote.dialog.shown', function() {
            window.flutter_inappwebview.callHandler('onDialogShown', JSON.stringify("fired"));
          });
        """,
      );
    }
    if (c.onEnter != null) {
      widget.controller.evaluateJavascript(
        source: """
          \$('#summernote-2').on('summernote.enter', function() {
            window.flutter_inappwebview.callHandler('onEnter', JSON.stringify("fired"));
          });
        """,
      );
    }
    if (c.onFocus != null) {
      widget.controller.evaluateJavascript(
        source: """
          \$('#summernote-2').on('summernote.focus', function() {
            window.flutter_inappwebview.callHandler('onFocus', JSON.stringify("fired"));
          });
        """,
      );
    }
    if (c.onBlur != null) {
      widget.controller.evaluateJavascript(
        source: """
          \$('#summernote-2').on('summernote.blur', function() {
            window.flutter_inappwebview.callHandler('onBlur', JSON.stringify("fired"));
          });
        """,
      );
    }
    if (c.onBlurCodeview != null) {
      widget.controller.evaluateJavascript(
        source: """
          \$('#summernote-2').on('summernote.blur.codeview', function() {
            window.flutter_inappwebview.callHandler('onBlurCodeview', JSON.stringify("fired"));
          });
        """,
      );
    }

    // if (c.onKeyUp != null) {
    //   widget.controller.evaluateJavascript(source: """
    //       \$('#summernote-2').on('summernote.keyup', function(_, e) {
    //         ${controller.javascriptChannelMessage(name: 'onKeyUp', data: 'e.keyCode')}
    //       });
    //     """);
    // }
    if (c.onMouseDown != null) {
      widget.controller.evaluateJavascript(
        source: """
          \$('#summernote-2').on('summernote.mousedown', function(_) {
            window.flutter_inappwebview.callHandler('onMouseDown', JSON.stringify("fired"));
          });
        """,
      );
    }
    if (c.onMouseUp != null) {
      widget.controller.evaluateJavascript(
        source: """
          \$('#summernote-2').on('summernote.mouseup', function(_) {
            window.flutter_inappwebview.callHandler('onMouseUp', JSON.stringify("fired"));
          });
        """,
      );
    }
    if (c.onPaste != null) {
      widget.controller.evaluateJavascript(
        source: """
          \$('#summernote-2').on('summernote.paste', function(_) {
            window.flutter_inappwebview.callHandler('onPaste', JSON.stringify("fired"));
          });
        """,
      );
    }
    if (c.onScroll != null) {
      widget.controller.evaluateJavascript(
        source: """
          \$('#summernote-2').on('summernote.scroll', function(_) {
            window.flutter_inappwebview.callHandler('onScroll', JSON.stringify("fired"));
          });
        """,
      );
    }
  }

  /// creates flutter_inappwebview JavaScript Handlers to handle any callbacks the
  /// user has defined
  void addJSHandlers(Callbacks c) {
    if (c.onBeforeCommand != null) {
      widget.controller.addJavaScriptHandler(
        handlerName: 'onBeforeCommand',
        callback: (contents) {
          c.onBeforeCommand!.call(contents.first.toString());
        },
      );
    }
    if (c.onChangeCodeview != null) {
      widget.controller.addJavaScriptHandler(
        handlerName: 'onChangeCodeview',
        callback: (contents) {
          c.onChangeCodeview!.call(contents.first.toString());
        },
      );
    }
    if (c.onDialogShown != null) {
      widget.controller.addJavaScriptHandler(
        handlerName: 'onDialogShown',
        callback: (_) {
          c.onDialogShown!.call();
        },
      );
    }
    if (c.onEnter != null) {
      widget.controller.addJavaScriptHandler(
        handlerName: 'onEnter',
        callback: (_) {
          c.onEnter!.call();
        },
      );
    }
    if (c.onFocus != null) {
      widget.controller.addJavaScriptHandler(
        handlerName: 'onFocus',
        callback: (_) {
          c.onFocus!.call();
        },
      );
    }
    if (c.onBlur != null) {
      widget.controller.addJavaScriptHandler(
        handlerName: 'onBlur',
        callback: (_) {
          c.onBlur!.call();
        },
      );
    }
    if (c.onBlurCodeview != null) {
      widget.controller.addJavaScriptHandler(
        handlerName: 'onBlurCodeview',
        callback: (_) {
          c.onBlurCodeview!.call();
        },
      );
    }
    if (c.onImageLinkInsert != null) {
      widget.controller.addJavaScriptHandler(
        handlerName: 'onImageLinkInsert',
        callback: (url) {
          c.onImageLinkInsert!.call(url.first.toString());
        },
      );
    }
    if (c.onImageUpload != null) {
      widget.controller.addJavaScriptHandler(
        handlerName: 'onImageUpload',
        callback: (files) {
          var file = fileUploadFromJson(files.first);
          c.onImageUpload!.call(file);
        },
      );
    }
    if (c.onImageUploadError != null) {
      widget.controller.addJavaScriptHandler(
        handlerName: 'onImageUploadError',
        callback: (args) {
          if (!args.first.toString().startsWith('{')) {
            c.onImageUploadError!.call(
              null,
              args.first,
              args.last.contains('base64')
                  ? UploadError.jsException
                  : args.last.contains('unsupported')
                  ? UploadError.unsupportedFile
                  : UploadError.exceededMaxSize,
            );
          } else {
            var file = fileUploadFromJson(args.first.toString());
            c.onImageUploadError!.call(
              file,
              null,
              args.last.contains('base64')
                  ? UploadError.jsException
                  : args.last.contains('unsupported')
                  ? UploadError.unsupportedFile
                  : UploadError.exceededMaxSize,
            );
          }
        },
      );
    }
    if (c.onKeyUp != null) {
      widget.controller.addJavaScriptHandler(
        handlerName: 'onKeyUp',
        callback: (keyCode) {
          c.onKeyUp!.call(keyCode.first);
        },
      );
    }
    if (c.onKeyDown != null) {
      widget.controller.addJavaScriptHandler(
        handlerName: 'onKeyDown',
        callback: (keyCode) {
          c.onKeyDown!.call(keyCode.first);
        },
      );
    }
    if (c.onMouseDown != null) {
      widget.controller.addJavaScriptHandler(
        handlerName: 'onMouseDown',
        callback: (_) {
          c.onMouseDown!.call();
        },
      );
    }
    if (c.onMouseUp != null) {
      widget.controller.addJavaScriptHandler(
        handlerName: 'onMouseUp',
        callback: (_) {
          c.onMouseUp!.call();
        },
      );
    }
    if (c.onPaste != null) {
      widget.controller.addJavaScriptHandler(
        handlerName: 'onPaste',
        callback: (_) {
          c.onPaste!.call();
        },
      );
    }
    if (c.onScroll != null) {
      widget.controller.addJavaScriptHandler(
        handlerName: 'onScroll',
        callback: (_) {
          c.onScroll!.call();
        },
      );
    }
  }
}
