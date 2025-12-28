import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/widgets/keyboard_shortcut.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/mail/presentation/widgets/shims/dart_ui.dart' as ui;
import 'package:color_models/color_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;
import 'package:intl/intl.dart' as intl;
import 'package:parse_color/parse_color.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

import 'js_interop_stub.dart' if (dart.library.html) 'dart:js_interop';

typedef OnScrollHorizontalEndAction = Function(bool leftDirection);
typedef OnLoadWidthHtmlViewerAction = Function(bool isScrollPageViewActivated);
typedef OnMailtoDelegateAction = Future<void> Function(Uri? uri);

class Constant {
  static const acceptHeaderDefault = 'application/json';
  static const contentTypeHeaderDefault = 'application/json';
  static const pdfMimeType = 'application/pdf';
  static const base64Charset = 'base64';
  static const textHtmlMimeType = 'text/html';
  static const octetStreamMimeType = 'application/octet-stream';
  static const pdfExtension = '.pdf';
  static const imageType = 'image';
}

class UrlViewer extends StatefulWidget {
  final String url;
  final bool isDarkTheme;
  final bool isMobileView;
  final bool close;
  final double? initialWidth;
  final TextDirection? direction;
  final void Function(double width, double height)? onSizeChanged;

  final OnLoadWidthHtmlViewerAction? onLoadWidthHtmlViewer;
  final OnMailtoDelegateAction? onMailtoDelegateAction;
  final OnScrollHorizontalEndAction? onScrollHorizontalEnd;

  const UrlViewer({
    Key? key,
    required this.url,
    required this.isDarkTheme,
    required this.isMobileView,
    required this.close,
    this.initialWidth,
    this.direction,
    this.onLoadWidthHtmlViewer,
    this.onMailtoDelegateAction,
    this.onScrollHorizontalEnd,
    this.onSizeChanged,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UrlViwerState();
}

class _UrlViwerState extends State<UrlViewer> with AutomaticKeepAliveClientMixin {
  static const double _minHeight = 0.0;
  static const double _offsetHeight = 30.0;

  late InAppWebViewController _webViewController;
  late double _actualHeight;
  late double _actualWidth;
  late Set<Factory<OneSequenceGestureRecognizer>> _gestureRecognizers;

  final _loadingBarNotifier = ValueNotifier(true);

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (PlatformX.isAndroid) {
      _gestureRecognizers = {
        Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer()),
        Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
        Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()),
      };
    } else {
      _gestureRecognizers = {
        Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer(duration: _longPressGestureDurationIOS)),
        Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
      };
    }
    _initialData();
  }

  @override
  void didUpdateWidget(covariant UrlViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url || widget.direction != oldWidget.direction) {
      _initialData();
    }
  }

  void _initialData() {
    _actualHeight = _minHeight;
    _actualWidth = (widget.initialWidth ?? 0) + 16;
    widget.onSizeChanged?.call(_actualWidth, _actualHeight);
  }

  bool _onKeyDown(KeyEvent event, {bool? justReturnResult}) {
    final logicalKeyPressed = ServicesBinding.instance.keyboard.logicalKeysPressed.where((e) => e != LogicalKeyboardKey.escape).toList();
    final controlPressed = (logicalKeyPressed.isMetaPressed && PlatformX.isApple) || (logicalKeyPressed.isControlPressed && !PlatformX.isApple);

    if (controlPressed && logicalKeyPressed.length == 2) {
      if (event.logicalKey == LogicalKeyboardKey.keyC) {
        if (justReturnResult == true) return true;
        _webViewController.getSelectedText().then((text) {
          if (text?.isNotEmpty == true) Clipboard.setData(ClipboardData(text: text!));
        });
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        SizedBox(
          height: widget.close ? 0 : _actualHeight,
          width: _actualWidth,
          child: KeyboardShortcut(
            onKeyDown: _onKeyDown,
            child: InAppWebView(
              key: ValueKey(widget.url),
              webViewEnvironment: webViewEnvironment,
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              initialSettings: InAppWebViewSettings(
                verticalScrollBarEnabled: false,
                horizontalScrollBarEnabled: false,
                disableVerticalScroll: false,
                disableInputAccessoryView: true,
                disableHorizontalScroll: true,
                incognito: true,
                mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                useHybridComposition: true,
                allowFileAccessFromFileURLs: true,
                allowUniversalAccessFromFileURLs: true,
                blockNetworkImage: false,
                blockNetworkLoads: false,
                networkAvailable: true,
                useWideViewPort: false,
              ),
              onWebViewCreated: _onWebViewCreated,
              onLoadStop: _onLoadStop,
              onProgressChanged: _onProgressChanged,
              onContentSizeChanged: _onContentSizeChanged,
              gestureRecognizers: _gestureRecognizers,
              onScrollChanged: (controller, x, y) => controller.scrollTo(x: 0, y: 0),
            ),
          ),
        ),
        ValueListenableBuilder(
          valueListenable: _loadingBarNotifier,
          builder: (context, loading, child) {
            if (loading) {
              return const SizedBox.shrink();
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ],
    );
  }

  void _onWebViewCreated(InAppWebViewController controller) async {
    _webViewController = controller;

    await controller.loadUrl(urlRequest: URLRequest(url: WebUri(widget.url)));

    controller.addJavaScriptHandler(handlerName: HtmlInteraction.scrollEventJSChannelName, callback: _onHandleScrollEvent);

    if (PlatformX.isAndroid) {
      controller.addJavaScriptHandler(handlerName: HtmlInteraction.contentSizeChangedEventJSChannelName, callback: _onHandleContentSizeChangedEvent);
    }
  }

  void _onLoadStop(InAppWebViewController controller, WebUri? webUri) async {
    await _getActualSizeHtmlViewer(false);
    _loadingBarNotifier.value = false;
    Future.delayed(Duration(milliseconds: 500), () {
      _getActualSizeHtmlViewer(true);
    });
  }

  void _onProgressChanged(InAppWebViewController controller, int? progress) async {
    if (!mounted) return;
    await _getActualSizeHtmlViewer(false);
  }

  void _onContentSizeChanged(InAppWebViewController controller, Size oldContentSize, Size newContentSize) async {
    final maxContentHeight = math.max(oldContentSize.height, newContentSize.height);
    if (maxContentHeight > _actualHeight && !_loadingBarNotifier.value && mounted) {
      _actualHeight = maxContentHeight + _offsetHeight;
      setState(() {});
      widget.onSizeChanged?.call(_actualWidth, _actualHeight);
    }
  }

  void _onHandleScrollEvent(List<dynamic> parameters) {
    final message = parameters.first;
    if (message == HtmlInteraction.scrollLeftEndAction) {
      widget.onScrollHorizontalEnd?.call(true);
    } else if (message == HtmlInteraction.scrollRightEndAction) {
      widget.onScrollHorizontalEnd?.call(false);
    }
  }

  void _onHandleContentSizeChangedEvent(List<dynamic> parameters) async {
    _getActualSizeHtmlViewer(true);
  }

  Future<void> _getActualSizeHtmlViewer(bool updateWidth) async {
    final listSize = await Future.wait([
      _webViewController.evaluateJavascript(source: 'document.getElementsByClassName("tmail-content")[0].scrollWidth'),
      _webViewController.evaluateJavascript(source: 'document.getElementsByClassName("tmail-content")[0].offsetWidth'),
      _webViewController.evaluateJavascript(source: 'document.body.scrollHeight'),
    ]);

    Set<Factory<OneSequenceGestureRecognizer>>? newGestureRecognizers;
    bool isScrollActivated = false;

    if (updateWidth && listSize[0] is num && listSize[1] is num) {
      final scrollWidth = listSize[0] as num;
      final offsetWidth = listSize[1] as num;
      _actualWidth = scrollWidth.toDouble() + 16;

      isScrollActivated = scrollWidth.round() == offsetWidth.round();

      if (!isScrollActivated && PlatformX.isApple) {
        newGestureRecognizers = {
          Factory<LongPressGestureRecognizer>(() => LongPressGestureRecognizer(duration: _longPressGestureDurationIOS)),
          Factory<PanGestureRecognizer>(() => PanGestureRecognizer()),
          // Factory<HorizontalDragGestureRecognizer>(() => HorizontalDragGestureRecognizer()),
        };
      }
    }

    if (listSize[2] is num) {
      final scrollHeight = listSize[2] as num;
      if (mounted && scrollHeight > 0) {
        setState(() {
          _actualHeight = scrollHeight + _offsetHeight;
          if (newGestureRecognizers != null) {
            _gestureRecognizers = newGestureRecognizers;
          }
        });
      }
    } else {
      if (mounted && newGestureRecognizers != null) {
        setState(() {
          _gestureRecognizers = newGestureRecognizers!;
        });
      }
    }

    if (!isScrollActivated) {
      await _webViewController.evaluateJavascript(source: HtmlInteraction.runScriptsHandleScrollEvent);
    }
    widget.onLoadWidthHtmlViewer?.call(isScrollActivated);
    widget.onSizeChanged?.call(_actualWidth, _actualHeight);
  }

  Duration? get _longPressGestureDurationIOS => const Duration(milliseconds: 100);

  @override
  void dispose() {
    _loadingBarNotifier.dispose();
    super.dispose();
  }
}

class HtmlContentViewerOnWeb extends StatefulWidget {
  final String contentHtml;
  final double widthContent;
  final double heightContent;
  final bool isDarkTheme;
  final bool close;
  final TextDirection? direction;
  final void Function(double width, double height)? onSizeChanged;

  /// Handler for mailto: links
  final Function(Uri?)? mailtoDelegate;

  // if widthContent is bigger than width of htmlContent, set this to true let widget able to resize to width of htmlContent
  final bool allowResizeToDocumentSize;

  const HtmlContentViewerOnWeb({
    Key? key,
    required this.contentHtml,
    required this.close,
    required this.isDarkTheme,
    required this.widthContent,
    required this.heightContent,
    this.allowResizeToDocumentSize = true,
    this.mailtoDelegate,
    this.direction,
    this.onSizeChanged,
  }) : super(key: key);

  @override
  State<HtmlContentViewerOnWeb> createState() => _HtmlContentViewerOnWebState();
}

class _HtmlContentViewerOnWebState extends State<HtmlContentViewerOnWeb> {
  static const double _minWidth = 300;

  /// The view ID for the IFrameElement. Must be unique.
  late String _createdViewId;

  /// The actual height of the content view, used to automatically set the height
  late double _actualHeight;

  /// The actual width of the content view, used to automatically set the width
  late double _actualWidth;

  Future<bool>? _webInit;
  String? _htmlData;
  bool _isLoading = true;
  double minHeight = 100;
  late final StreamSubscription<html.MessageEvent> sizeListener;
  bool _iframeLoaded = false;
  static const String iframeOnLoadMessage = 'iframeHasBeenLoaded';

  @override
  void initState() {
    super.initState();
    _actualHeight = widget.heightContent;
    _actualWidth = widget.widthContent;
    widget.onSizeChanged?.call(_actualWidth, _actualHeight);

    _createdViewId = _getRandString(10);
    _setUpWeb();

    sizeListener = html.window.onMessage.listen((event) {
      var data = json.decode(event.data);

      if (data['view'] != _createdViewId) return;

      if (data['message'] == iframeOnLoadMessage) {
        _iframeLoaded = true;
      }

      if (!_iframeLoaded) return;

      if (data['type'] != null && data['type'].contains('toDart: htmlHeight')) {
        final docHeight = data['height'] ?? _actualHeight;
        if (docHeight != null && mounted) {
          final scrollHeightWithBuffer = docHeight + 30.0;
          if (scrollHeightWithBuffer > minHeight) {
            _actualHeight = scrollHeightWithBuffer;
            _isLoading = false;
            setState(() {});
            widget.onSizeChanged?.call(_actualWidth, _actualHeight);
          }
        }
        if (mounted && _isLoading) {
          setState(() {
            _isLoading = false;
          });
        }
      }

      if (data['type'] != null && data['type'].contains('toDart: htmlWidth')) {
        final docWidth = data['width'] ?? _actualWidth;
        if (docWidth != null && mounted) {
          if (docWidth > _minWidth && widget.allowResizeToDocumentSize) {
            _actualWidth = docWidth;
            setState(() {});
            widget.onSizeChanged?.call(_actualWidth, _actualHeight);
          }
        }
      }

      if (data['type'] != null && data['type'].contains('toDart: OpenLink')) {
        final link = data['url'];
        if (link != null && mounted) {
          final urlString = link as String;
          if (urlString.startsWith('mailto:')) {
            widget.mailtoDelegate?.call(Uri.parse(urlString));
          }
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant HtmlContentViewerOnWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.contentHtml != oldWidget.contentHtml || widget.direction != oldWidget.direction) {
      _createdViewId = _getRandString(10);
      _setUpWeb();
    }

    if (widget.heightContent != oldWidget.heightContent) {
      _actualHeight = widget.heightContent;
      widget.onSizeChanged?.call(_actualWidth, _actualHeight);
    }

    if (widget.widthContent != oldWidget.widthContent) {
      _actualWidth = widget.widthContent;
      widget.onSizeChanged?.call(_actualWidth, _actualHeight);
    }
  }

  String _getRandString(int len) {
    var random = math.Random.secure();
    var values = List<int>.generate(len, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  String _generateHtmlDocument(String content) {
    final webViewActionScripts =
        '''
      <script type="text/javascript">
        window.parent.addEventListener('message', handleMessage, false);
        window.addEventListener('load', handleOnLoad);
        window.addEventListener('pagehide', (event) => {
          window.parent.removeEventListener('message', handleMessage, false);
        });

        function handleMessage(e) {
          if (e && e.data && e.data.includes("toIframe:")) {
            var data = JSON.parse(e.data);
            if (data["view"].includes("$_createdViewId")) {
              if (data["type"].includes("getHeight")) {
                var height = document.body.scrollHeight;
                window.parent.postMessage(JSON.stringify({"view": "$_createdViewId", "type": "toDart: htmlHeight", "height": height}), "*");
              }
              if (data["type"].includes("getWidth")) {
                var width = document.body.scrollWidth;
                window.parent.postMessage(JSON.stringify({"view": "$_createdViewId", "type": "toDart: htmlWidth", "width": width}), "*");
              }
              if (data["type"].includes("execCommand")) {
                if (data["argument"] === null) {
                  document.execCommand(data["command"], false);
                } else {
                  document.execCommand(data["command"], false, data["argument"]);
                }
              }
            }
          }
        }

        function handleOnClickEmailLink(e) {
           var href = this.href;
           window.parent.postMessage(JSON.stringify({"view": "$_createdViewId", "type": "toDart: OpenLink", "url": "" + href}), "*");
           e.preventDefault();
        }

        function handleOnLoad() {
          window.parent.postMessage(JSON.stringify({"view": "$_createdViewId", "message": "$iframeOnLoadMessage"}), "*");
          window.parent.postMessage(JSON.stringify({"view": "$_createdViewId", "type": "toIframe: getHeight"}), "*");
          window.parent.postMessage(JSON.stringify({"view": "$_createdViewId", "type": "toIframe: getWidth"}), "*");

          var emailLinks = document.querySelectorAll('a[href^="mailto:"]');
          for(var i=0; i < emailLinks.length; i++){
              emailLinks[i].addEventListener('click', handleOnClickEmailLink);
          }
        }
      </script>
    ''';

    const scriptsDisableZoom = '''
      <script type="text/javascript">
        document.addEventListener('wheel', function(e) {
          e.ctrlKey && e.preventDefault();
        }, {
          passive: false,
        });
        window.addEventListener('keydown', function(e) {
          if (event.metaKey || event.ctrlKey) {
            switch (event.key) {
              case '=':
              case '-':
                event.preventDefault();
                break;
            }
          }
        });
      </script>
    ''';

    final htmlTemplate = HtmlUtils.generateHtmlDocument(
      content: content,
      minHeight: minHeight,
      width: widget.widthContent,
      minWidth: _minWidth,
      styleCSS: HtmlTemplate.tooltipLinkCss,
      javaScripts: webViewActionScripts + scriptsDisableZoom + HtmlInteraction.scriptsHandleLazyLoadingBackgroundImage,
      direction: widget.direction,
      isDarkTheme: widget.isDarkTheme,
      isMobileView: false,
    );

    return htmlTemplate;
  }

  void _setUpWeb() {
    _htmlData = _generateHtmlDocument(widget.contentHtml);

    final iframe = html.IFrameElement()
      ..width = _actualWidth.toString()
      ..height = _actualHeight.toString()
      ..srcdoc = _htmlData ?? ''
      ..style.border = 'none'
      ..style.overflow = 'hidden'
      ..style.width = '100%'
      ..style.height = '100%';

    ui.platformViewRegistry.registerViewFactory(_createdViewId, (int viewId) => iframe);

    if (mounted) {
      setState(() {
        _webInit = Future.value(true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        minHeight = math.max(constraint.maxHeight, minHeight);
        return Stack(
          children: [
            if (_htmlData?.isNotEmpty == false)
              const SizedBox.shrink()
            else
              FutureBuilder<bool>(
                future: _webInit,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return SizedBox(
                      height: widget.close ? 0 : _actualHeight,
                      width: _actualWidth,
                      child: HtmlElementView(key: ValueKey(_htmlData), viewType: _createdViewId),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            if (_isLoading)
              const Align(
                alignment: Alignment.topCenter,
                child: Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 30, height: 30)),
              ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _htmlData = null;
    sizeListener.cancel();
    super.dispose();
  }
}

class HtmlInteraction {
  static const String scrollRightEndAction = 'ScrollRightEndAction';
  static const String scrollLeftEndAction = 'ScrollLeftEndAction';
  static const String scrollEventJSChannelName = 'ScrollEventListener';
  static const String contentSizeChangedEventJSChannelName = 'ContentSizeChangedEventListener';

  static const String runScriptsHandleScrollEvent =
      '''
    let contentElement = document.getElementsByClassName('tmail-content')[0];
    var xDown = null;
    var yDown = null;

    contentElement.addEventListener('touchstart', handleTouchStart, false);
    contentElement.addEventListener('touchmove', handleTouchMove, false);

    function getTouches(evt) {
      return evt.touches || evt.originalEvent.touches;
    }

    function handleTouchStart(evt) {
      const firstTouch = getTouches(evt)[0];
      xDown = firstTouch.clientX;
      yDown = firstTouch.clientY;
    }

    function handleTouchMove(evt) {
      if (!xDown || !yDown) {
        return;
      }

      var xUp = evt.touches[0].clientX;
      var yUp = evt.touches[0].clientY;

      var xDiff = xDown - xUp;
      var yDiff = yDown - yUp;

      if (Math.abs(xDiff) > Math.abs(yDiff)) {
        let newScrollLeft = contentElement.scrollLeft;
        let scrollWidth = contentElement.scrollWidth;
        let offsetWidth = contentElement.offsetWidth;
        let maxOffset = Math.round(scrollWidth - offsetWidth);
        let scrollLeftRounded = Math.round(newScrollLeft);

        if (xDiff > 0) {
          if (maxOffset === scrollLeftRounded ||
              maxOffset === (scrollLeftRounded + 1) ||
              maxOffset === (scrollLeftRounded - 1)) {
            window.flutter_inappwebview.callHandler('$scrollEventJSChannelName', '$scrollRightEndAction');
          }
        } else {
          if (scrollLeftRounded === 0) {
            window.flutter_inappwebview.callHandler('$scrollEventJSChannelName', '$scrollLeftEndAction');
          }
        }
      }

      xDown = null;
      yDown = null;
    }
  ''';

  static const String scriptsHandleContentSizeChanged =
      '''
    <script>
      const bodyResizeObserver = new ResizeObserver(entries => {
        window.flutter_inappwebview.callHandler('$contentSizeChangedEventJSChannelName', '');
      })

      bodyResizeObserver.observe(document.body)
    </script>
  ''';

  static const String scriptsHandleLazyLoadingBackgroundImage = '''
    <script>
      const lazyImages = document.querySelectorAll('[lazy]');
      const lazyImageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            const lazyImage = entry.target;
            const src = lazyImage.dataset.src;
            lazyImage.tagName.toLowerCase() === 'img'
              ? lazyImage.src = src
              : lazyImage.style.backgroundImage = "url(\'" + src + "\')";
            lazyImage.removeAttribute('lazy');
            observer.unobserve(lazyImage);
          }
        });
      });

      lazyImages.forEach((lazyImage) => {
        lazyImageObserver.observe(lazyImage);
      });
    </script>
  ''';

  static const String scriptHandleInvokePrinterOnBrowser = '''
    <script type="text/javascript">
      document.body.onload = function() {
        window.print();
      };
    </script>
  ''';
}

class _ScriptDefinition {
  final String script;
  final String name;

  const _ScriptDefinition({
    required this.script,
    required this.name,
  });
}

class HtmlUtils {
  static const lineHeight100Percent = _ScriptDefinition(
    script: '''
      document.querySelectorAll("*")
        .forEach((element) => {
          if (element.style.lineHeight !== "normal")
            element.style.lineHeight = "100%";
        });''',
    name: 'lineHeight100Percent',
  );

  static const registerDropListener = _ScriptDefinition(
    script: '''
      document.querySelector(".note-editable").addEventListener(
        "drop",
        (event) => window.parent.postMessage(
          JSON.stringify({"name": "registerDropListener"})))''',
    name: 'registerDropListener',
  );

  static const unregisterDropListener = _ScriptDefinition(
    script: '''
      const editor = document.querySelector(".note-editable");
      const newEditor = editor.cloneNode(true);
      editor.parentNode.replaceChild(newEditor, editor);''',
    name: 'unregisterDropListener',
  );

  static String customCssStyleHtmlEditor({TextDirection direction = TextDirection.ltr}) {
    if (PlatformX.isWeb) {
      return '''
        <style>
          .note-editable {
            direction: ${direction.name};
          }

          .note-editable .tmail-signature {
            text-align: ${direction == TextDirection.rtl ? 'right' : 'left'};
          }
        </style>
      ''';
    } else {
      return '''
        #editor {
          direction: ${direction.name};
        }

        #editor .tmail-signature {
          text-align: ${direction == TextDirection.rtl ? 'right' : 'left'};
        }
      ''';
    }
  }

  static String validateHtmlImageResourceMimeType(String mimeType) {
    if (mimeType.endsWith('svg')) {
      mimeType = 'image/svg+xml';
    }
    return mimeType;
  }

  static String convertBase64ToImageResourceData({required String base64Data, required String mimeType}) {
    mimeType = validateHtmlImageResourceMimeType(mimeType);
    if (!base64Data.endsWith('==')) {
      base64Data.append('==');
    }
    final imageResource = 'data:$mimeType;base64,$base64Data';
    return imageResource;
  }

  static String generateHtmlDocument({
    required String content,
    required bool isDarkTheme,
    required bool isMobileView,
    required double width,
    double? minHeight,
    double? minWidth,
    String? styleCSS,
    String? javaScripts,
    bool hideScrollBar = true,
    TextDirection? direction,
  }) {
    final html = content.isNotEmpty ? content.replaceAll('http://', 'https://') : '(No Content)';

    final result =
        '''
      <!DOCTYPE html>
      <html>
      <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
      ${isDarkTheme ? '<meta name="color-scheme" content="light dark">' : ''}
      <style>
        * {
            font-family: sans-serif;
        }
        body {
            font-size: ${isMobileView ? 14 : 12}px;
        }
        ::selection {
          background: ${isDarkTheme ? Color(0xff66809E).toHex() : Color(0xffB7D8FF).toHex()};
        }
        .tmail-content {
          min-height: ${minHeight ?? 0}px;
          min-width: ${minWidth ?? 0}px;
          overflow: auto;
        }
        ${hideScrollBar ? '''
          .tmail-content::-webkit-scrollbar {
            display: none;
          }
          .tmail-content {
            -ms-overflow-style: none;  /* IE and Edge */
            scrollbar-width: none;  /* Firefox */
          }
        ''' : ''}
        ${styleCSS ?? ''}
      </style>
      </head>
      <body ${direction == TextDirection.rtl ? 'dir="rtl"' : ''} >
      <div class="tmail-content">${enableMaxWidth(isDarkTheme ? enableDarkMode(html) : html, width)}</div>
      ${javaScripts ?? ''}
      </body>
      </html>
    ''';

    return result;
  }

  static String enableMaxWidth(String htmlContent, double maxWidth) {
    dom.Document document = parse(htmlContent);

    List<dom.Element> elementsToStyle = document.querySelectorAll(
      'body, img, p, h1, h2, h3, h4, h5, h6, a, span, div, td, th, li, table, link, ul, tbody, tr, font, b, u, title, time, thead, th, tfoot, textarea, template, svg, sup, summary, sub, style, string, span, source, small, select, section, search, script, samp, s, ruby, rt, rp, q, progress, pre, param, output, option, ptgroup, ol, object, noscript, nav, meter, meta, menu, mark, link, li, legend, label, kbd, ins, input',
    );

    // Apply dark mode styles using element.attributes
    for (dom.Element element in elementsToStyle) {
      String existingStyles = element.attributes['style'] ?? '';
      List<String> currentStyles = existingStyles.split(';').where((e) => e.trim().isNotEmpty).map((e) => e.trim()).toList();

      String? tagStyle = currentStyles.where((e) => e.startsWith('display:')).firstOrNull;
      String displayString = tagStyle?.split(':')[1].split('!').firstOrNull ?? '';
      bool displayBlock = displayString.trim() == 'block' || element.localName == 'body';

      for (final tag in ['width', 'max-width', 'min-width']) {
        String? tagStyle = currentStyles.where((e) => e.startsWith('${tag}:')).firstOrNull;
        String widthString = tagStyle?.split(':')[1].split('!').firstOrNull ?? '';
        double? width = double.tryParse(widthString) ?? (widthString.contains('px') ? double.tryParse(widthString.split('px').first) : null);

        if (width != null && width > maxWidth) {
          currentStyles = currentStyles.map((e) {
            if (e.startsWith('${tag}:')) {
              return tagStyle!.replaceAll('${tag}:${widthString}', '${tag}: ${maxWidth.floor()}px');
            }
            return e;
          }).toList();
        } else if (widthString.isEmpty && tag == 'max-width') {
          currentStyles.add('${tag}: 100%');
        }
      }
      if (currentStyles.isNotEmpty) {
        element.attributes['style'] = currentStyles.join('; ');
      }

      for (final tag in ['width', 'max-width', 'min-width']) {
        String widthString = element.attributes[tag] ?? '';
        double? width = double.tryParse(widthString) ?? (widthString.contains('px') ? double.tryParse(widthString.split('px').first) : null);
        if (width != null && width > maxWidth) {
          element.attributes[tag] = '${maxWidth.floor()}';
        } else if (widthString.isEmpty && displayBlock && tag == 'width') {
          element.attributes[tag] = '${maxWidth.floor()}';
        }
      }
    }

    return document.outerHtml;
  }

  static String enableDarkMode(String htmlContent) {
    dom.Document document = parse(htmlContent);

    List<dom.Element> elementsToStyle = document.querySelectorAll(
      'body, p, h1, h2, h3, h4, h5, h6, a, span, div, td, th, li, table, link, ul, tbody, tr, font, b, u, title, time, thead, th, tfoot, textarea, template, svg, sup, summary, sub, style, string, span, source, small, select, section, search, script, samp, s, ruby, rt, rp, q, progress, pre, param, output, option, ptgroup, ol, object, noscript, nav, meter, meta, menu, mark, link, li, legend, label, kbd, ins, input',
    );

    // Apply dark mode styles using element.attributes
    for (dom.Element element in elementsToStyle) {
      String existingStyles = element.attributes['style'] ?? '';
      List<String> currentStyles = existingStyles.split(';').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      for (final tag in ['color', 'background', 'background-color', 'font-color']) {
        String? tagStyle = currentStyles.where((e) => e.startsWith('${tag}:')).firstOrNull;
        String colorHex = tagStyle?.split(':')[1].split('!').firstOrNull ?? '';

        if (colorHex.trim() != 'transparent' && colorHex.trim() != 'inherit') {
          if (colorHex.trim().isNotEmpty && element.localName != 'body') {
            Color color = UIColor(colorHex.trim());
            if (colorHex.trim().startsWith('#') && colorHex.trim().length == 4) {
              final characters = colorHex.trim().characters;
              color = UIColor(
                '#${characters.elementAt(1)}${characters.elementAt(1)}${characters.elementAt(2)}${characters.elementAt(2)}${characters.elementAt(3)}${characters.elementAt(3)}',
              );
            }

            String invertedHex = RgbColor(
              (color.r * 255).round(),
              (color.g * 255).round(),
              (color.b * 255).round(),
              (color.a * 255).round(),
            ).rotateHue(180).inverted.hex;
            currentStyles = currentStyles.map((e) {
              if (e.startsWith('${tag}:')) {
                return tagStyle!.replaceAll('${tag}:${colorHex}', '${tag}: ${invertedHex}');
              }
              return e;
            }).toList();
          } else if (element.localName == 'body') {
            if (colorHex.trim().isNotEmpty) {
              currentStyles = currentStyles.map((e) {
                if (e.startsWith('${tag}:')) {
                  return tagStyle!.replaceAll('${tag}:${colorHex}', '${tag}: ${tag == 'color' ? Colors.white.toHex() : Color(0xff3A3A3C).toHex()}!important');
                }
                return e;
              }).toList();
            } else {
              currentStyles.add('${tag}: ${tag == 'color' ? Colors.white.toHex() : Color(0xff3A3A3C).toHex()}!important');
            }
          }
        }
      }

      element.attributes['style'] = currentStyles.join('; ');

      for (final tag in ['bgcolor']) {
        String colorHex = element.attributes[tag] ?? '';

        if (colorHex != 'transparent') {
          if (colorHex.trim().isNotEmpty && element.localName != 'body') {
            Color color = UIColor(colorHex.trim());
            String invertedHex = RgbColor(
              (color.r * 255).round(),
              (color.g * 255).round(),
              (color.b * 255).round(),
              (color.a * 255).round(),
            ).rotateHue(180).inverted.hex;
            element.attributes[tag] = invertedHex;
          }
        }
      }
    }

    return document.outerHtml;
  }

  static String createTemplateHtmlDocument({String? title}) {
    return '''
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
          <meta http-equiv="X-UA-Compatible" content="IE=edge">
          ${title != null ? '<title>$title</title>' : ''}
        </head>
        <body></body>
      </html>
    ''';
  }

  static String generateSVGImageData(String base64Data) => 'data:image/svg+xml;base64,$base64Data';

  static void openNewTabHtmlDocument(String htmlDocument) {
    final blob = html.Blob([htmlDocument], Constant.textHtmlMimeType);

    final url = html.Url.createObjectUrlFromBlob(blob);

    html.window.open(url, '_blank');

    html.Url.revokeObjectUrl(url);
  }

  static String chromePdfViewer(Uint8List bytes, String fileName) {
    return '''
      <!DOCTYPE html>
      <html lang="en">
        <head>
        <meta charset="utf-8" />
        <title>$fileName</title>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/4.0.379/pdf.min.mjs" type="module"></script>
        <style>
          body {
            background-color: black;
          }

          #pdf-container {
            $_pdfContainerStyle
          }

          #pdf-viewer {
            $_pdfViewerStyle
          }

          #app-bar {
            $_pdfAppBarStyle
          }

          #download-btn {
            $_pdfDownloadButtonStyle
          }

          #file-info {
            $_pdfFileInfoStyle
          }

          #file-name {
            $_pdfFileNameStyle
          }
        </style>
        </head>
        <body>
          <div id="pdf-container">
            $_pdfAppbarElement
            <div id="pdf-viewer"></div>
          </div>

          <script type="module">
            function renderPage(pdfDoc, pageNumber, canvas) {
              pdfDoc.getPage(pageNumber).then(page => {
                const viewport = page.getViewport({ scale: 1 });
                canvas.height = viewport.height;
                canvas.width = viewport.width;

                const context = canvas.getContext('2d');
                const renderContext = {
                  canvasContext: context,
                  viewport: viewport
                };

                page.render(renderContext);
              });
            }

            const bytesJs = new Uint8Array(${bytes.toJS});
            const pdfContainer = document.getElementById('pdf-viewer');

            var { pdfjsLib } = globalThis;

            pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/4.0.379/pdf.worker.min.mjs';

            var loadingTask = pdfjsLib.getDocument(bytesJs);
            loadingTask.promise.then(function(pdf) {
              const numPages = pdf.numPages;

              for (let i = 1; i <= numPages; i++) {
                const pageContainer = document.createElement('div');
                pageContainer.classList.add('pdf-page');

                const canvas = document.createElement('canvas');
                canvas.id = `page-\${i}`;

                pageContainer.appendChild(canvas);
                pdfContainer.appendChild(pageContainer);

                renderPage(pdf, i, canvas);
              }
            }, function (reason) {
              console.error(reason);
            });

            ${_fileInfoScript(fileName)}

            ${_downloadButtonListenerScript(bytes, fileName)}
          </script>
        </body>
      </html>''';
  }

  static String safariPdfViewer(Uint8List bytes, String fileName) {
    final base64 = base64Encode(bytes);

    return '''
      <!DOCTYPE html>
      <html lang="en">
        <head>
        <meta charset="utf-8" />
        <title>$fileName</title>
        <style>
          body {
            background-color: black;
          }

          body, html {
            margin: 0;
            padding: 0;
            height: 100%;
          }

          #pdf-container {
            $_pdfContainerStyle
            overflow: hidden;
          }

          #pdf-viewer {
            $_pdfViewerStyle
            width: 100%;
            height: calc(100vh - 53px);
          }

          #app-bar {
            $_pdfAppBarStyle
          }

          #download-btn {
            $_pdfDownloadButtonStyle
          }

          #file-info {
            $_pdfFileInfoStyle
          }

          #file-name {
            $_pdfFileNameStyle
          }
        </style>
        </head>
        <body>
          <div id="pdf-container">
            $_pdfAppbarElement
            <div id="pdf-viewer"></div>
          </div>

          <script src="https://cdnjs.cloudflare.com/ajax/libs/pdfobject/2.3.0/pdfobject.min.js"></script>
          <script>
            const bytesJs = new Uint8Array(${bytes.toJS});
            PDFObject.embed('data:application/pdf;base64,$base64', "#pdf-viewer");

            ${_fileInfoScript(fileName)}

            ${_downloadButtonListenerScript(bytes, fileName)}
          </script>
        </body>
      </html>''';
  }

  static void openFileViewer({required Uint8List bytes, required String fileName, String? mimeType}) {
    final blob = html.Blob([bytes], mimeType);
    final file = html.File([blob], fileName, {'type': mimeType});
    final url = html.Url.createObjectUrl(file);
    html.window.open(url, '_blank');
    html.Url.revokeObjectUrl(url);
  }

  static const String _pdfContainerStyle = '''
    display: flex;
    flex-direction: column;
    width: 100%;''';

  static const String _pdfViewerStyle = '''
    flex: 1; /* Allow viewer to fill remaining space */
    border: 1px solid #ddd;
    margin-left: auto;
    margin-right: auto;
    padding-top: 53px;
    border: none;''';

  static const String _pdfAppBarStyle = '''
    position: fixed; /* Fix app bar to top */
    top: 0;
    left: 0;
    right: 0; /* Stretch across entire viewport */
    display: flex;
    justify-content: space-between;
    padding: 5px 10px;
    background-color: #f0f0f0;
    z-index: 100; /* Ensure buttons stay on top */''';

  static const String _pdfDownloadButtonStyle = '''
    padding: 5px 10px;
    border: 1px solid #ddd;
    border-radius: 5px;
    cursor: pointer;
    margin-left: 10px;''';

  static const String _pdfFileInfoStyle = '''
    width: 30%;
    display: flex;
    align-items: center;
    padding: 5px 10px;''';

  static const String _pdfFileNameStyle = '''
    overflow: hidden;
    text-overflow: ellipsis;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    line-clamp: 2;
    -webkit-box-orient: vertical;''';

  static const String _pdfAppbarElement = '''
    <div id="app-bar">
      <div id="file-info">
        <span id="file-name" style="margin-right: 10px;"></span>
        (<span id="file-size" style="white-space: nowrap;"></span>)
      </div>
      <div style="width: 10px;"></div>
      <div id="buttons">
        <button id="download-btn">
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M19 20V18H5V20H19ZM19 10H15V4H9V10H5L12 17L19 10Z" fill="#7B7B7B"/>
          </svg>
        </button>
      </div>
    </div>''';

  static String _downloadButtonListenerScript(Uint8List bytes, String? fileName) {
    return '''
      const downloadBtn = document.getElementById('download-btn');
      downloadBtn.addEventListener('click', () => {
        const buffer = new Uint8Array(${bytes.toJS}).buffer;
        const blob = new Blob([buffer], { type: "application/pdf" });
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.download = "$fileName";
        a.href = url;
        document.body.appendChild(a);
        a.click();
        window.URL.revokeObjectURL(url);
        document.body.removeChild(a);
      });''';
  }

  static String _fileInfoScript(String? fileName) {
    return '''
      function formatFileSize(bytes) {
        if (bytes === 0) return '0 Bytes';
        const k = 1024;
        const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat(bytes / Math.pow(k, i)).toFixed(2) + ' ' + sizes[i];
      }

      const fileNameSpan = document.getElementById('file-name');
      fileNameSpan.textContent = "$fileName";

      const fileSizeSpan = document.getElementById('file-size');
      fileSizeSpan.textContent = formatFileSize(bytesJs.length);''';
  }
}

extension HtmlExtension on String {
  static const String editorStartTags = '<div><br><br></div>';
  static const String signaturePrefix = '--&nbsp;';

  String addBlockTag(String tag, {String? attribute}) => attribute != null ? '<$tag $attribute>$this</$tag>' : '<$tag>$this</$tag>';

  String append(String value) => this + value;

  String addNewLineTag({int count = 1}) {
    if (count == 1) return '$this</br>';

    var htmlString = this;
    for (var i = 0; i < count; i++) {
      htmlString = '$htmlString</br>';
    }
    return htmlString;
  }

  String addBlockQuoteTag() =>
      addBlockTag('blockquote', attribute: 'style="margin-left:8px;margin-right:8px;padding-left:12px;padding-right:12px;border-left:5px solid #eee;"');

  String signaturePrefixTagHtml() => '<span class="tmail_signature_prefix">$signaturePrefix</span>';

  String asSignatureHtml() => '${signaturePrefixTagHtml()}<br>$this<br>';

  String removeEditorStartTag() {
    if (trim() == editorStartTags) {
      return '';
    }
    return this;
  }

  String addCiteTag() => addBlockTag('cite', attribute: 'style="text-align: left;display: block;"');
}

class HtmlTemplate {
  static const String nameClassToolTip = 'tmail-tooltip';
  static const String tooltipLinkCss =
      '''
    .$nameClassToolTip .tooltiptext {
      visibility: hidden;
      max-width: 400px;
      background-color: black;
      color: #fff;
      text-align: center;
      border-radius: 6px;
      padding: 5px 8px 5px 8px;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
      position: absolute;
      z-index: 1;
    }
    .$nameClassToolTip:hover .tooltiptext {
      visibility: visible;
    }
  ''';

  static const String printDocumentCssStyle = '''
    <style>
      body,td,div,p,a,input {
        font-family: arial, sans-serif;
      }

      body, td {
        font-size: 13px;
      }

      a:link, a:active {
        color: #1155CC;
        text-decoration: none;
      }

      a:hover {
        text-decoration: underline;
        cursor: pointer;
      }

      a:visited{
        color: #6611CC;
      }

      img {
         border: 0px
      }

      pre {
         white-space: pre;
         white-space: -moz-pre-wrap;
         white-space: -o-pre-wrap;
         white-space: pre-wrap;
         word-wrap: break-word;
         max-width: 800px;
         overflow: auto;
      }

      .logo {
         position: relative;
      }
     </style>
  ''';
}

class AppUtils {
  static Future<bool> launchLink(String url, {bool isNewTab = true}) async {
    return await launchUrl(Uri.parse(url), webOnlyWindowName: isNewTab ? '_blank' : '_self', mode: LaunchMode.externalApplication);
  }

  static bool isDirectionRTL(BuildContext context) {
    return intl.Bidi.isRtlLanguage(Localizations.localeOf(context).languageCode);
  }

  static TextDirection getCurrentDirection(BuildContext context) => Directionality.maybeOf(context) ?? TextDirection.ltr;

  static bool isEmailLocalhost(String email) {
    return RegExp(r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@localhost$').hasMatch(email);
  }

  static String getTimeZone() {
    final timeZoneOffset = DateTime.now().timeZoneOffset.inHours;
    final timeZoneOffsetAsString = timeZoneOffset >= 0 ? '+$timeZoneOffset' : '$timeZoneOffset';
    return 'GMT$timeZoneOffsetAsString';
  }
}
