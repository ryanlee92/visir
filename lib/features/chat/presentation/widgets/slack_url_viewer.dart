import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/widgets/keyboard_shortcut.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/mail/presentation/widgets/html_content_viewer_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart';
import 'package:universal_html/html.dart' as uh;

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

class SlackUrlViewer extends StatefulWidget {
  final String url;
  final bool isDarkTheme;
  final bool isMobileView;
  final bool close;
  final double? initialWidth;
  final double? initialHeight;
  final TextDirection? direction;
  final void Function(double width, double height)? onSizeChanged;
  final void Function(String magicToken, String teamId, String userId, List<Cookie>) onReceivedData;
  final String? userAgent;

  final OnLoadWidthHtmlViewerAction? onLoadWidthHtmlViewer;
  final OnMailtoDelegateAction? onMailtoDelegateAction;
  final OnScrollHorizontalEndAction? onScrollHorizontalEnd;

  const SlackUrlViewer({
    Key? key,
    required this.url,
    required this.isDarkTheme,
    required this.isMobileView,
    required this.close,
    this.initialWidth,
    this.initialHeight,
    this.direction,
    this.onLoadWidthHtmlViewer,
    this.onMailtoDelegateAction,
    this.onScrollHorizontalEnd,
    this.onSizeChanged,
    this.userAgent,
    required this.onReceivedData,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UrlViwerState();
}

class _UrlViwerState extends State<SlackUrlViewer> with AutomaticKeepAliveClientMixin {
  static const double _minHeight = 0.0;
  static const double _offsetHeight = 30.0;

  late InAppWebViewController _webViewController;
  late CookieManager cookieManager;
  late double _actualHeight;
  late double _actualWidth;
  late Set<Factory<OneSequenceGestureRecognizer>> _gestureRecognizers;

  final _loadingBarNotifier = ValueNotifier(true);

  HeadlessInAppWebView? headlessWebView;

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
    cookieManager = CookieManager.instance();
    _initialData();
  }

  @override
  void didUpdateWidget(covariant SlackUrlViewer oldWidget) {
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
          height: PlatformX.isWeb
              ? widget.initialHeight ?? 0
              : widget.close
              ? 0
              : _actualHeight,
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
                disableVerticalScroll: true,
                disableInputAccessoryView: true,
                disableHorizontalScroll: true,
                mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                useHybridComposition: true,
                allowFileAccessFromFileURLs: true,
                allowUniversalAccessFromFileURLs: true,
                blockNetworkImage: false,
                blockNetworkLoads: false,
                networkAvailable: true,
                useWideViewPort: false,
                userAgent: widget.userAgent,
                javaScriptEnabled: true,
                cacheMode: CacheMode.LOAD_DEFAULT,
                cacheEnabled: true,
              ),
              onWebViewCreated: _onWebViewCreated,
              onLoadStop: _onLoadStop,
              onProgressChanged: _onProgressChanged,
              onContentSizeChanged: _onContentSizeChanged,
              shouldOverrideUrlLoading: _shouldOverrideUrlLoading,
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

    if (PlatformX.isWeb) return;

    controller.addJavaScriptHandler(handlerName: HtmlInteraction.scrollEventJSChannelName, callback: _onHandleScrollEvent);

    if (PlatformX.isAndroid) {
      controller.addJavaScriptHandler(handlerName: HtmlInteraction.contentSizeChangedEventJSChannelName, callback: _onHandleContentSizeChangedEvent);
    }
  }

  void _onLoadStop(InAppWebViewController controller, WebUri? webUri) async {
    _getActualSizeHtmlViewer(false);
    _loadingBarNotifier.value = false;
    Future.delayed(Duration(milliseconds: 500), () {
      _getActualSizeHtmlViewer(true);
    });
  }

  bool sendData = false;
  String? magicToken;

  void _onProgressChanged(InAppWebViewController controller, int? progress) async {
    if (!mounted) return;
    await _getActualSizeHtmlViewer(false);

    final url = await controller.getUrl();

    if (url.toString().contains('/ssb/redirect')) {
      final cookies = await cookieManager.getCookies(url: WebUri(url!.toString().split('?').first));
      final cookie = cookies.where((d) => d.name == 'd').firstOrNull;

      if (cookie != null) {
        final bootData = jsonDecode(await controller.evaluateJavascript(source: 'JSON.stringify(boot_data)'));
        final response = await get(
          Uri.parse(url.toString().contains('?') ? '${url.toString()}&nojsmode=1' : '${url.toString()}?nojsmode=1'),
          headers: {"cookie": 'd=${cookie.value}'},
        );
        final html = response.body;

        final dom = uh.DomParser().parseFromString(html, 'text/html');

        final element = dom.getElementById('props_node');
        final escapedProps = element?.getAttribute('data-props');
        if (escapedProps != null) {
          final appUrlEscaped = jsonDecode(escapedProps)['appUrl'];
          if (appUrlEscaped != null) {
            final unescape = HtmlUnescape();
            final appUrl = unescape.convert(appUrlEscaped);
            final magicToken = appUrl.split('magic-login/').lastOrNull?.split('?').firstOrNull;
            if (magicToken != null) {
              this.magicToken = magicToken;
            }
          }
        }

        final teamId = bootData['team_id'];
        final userId = bootData['user_id'];
        if (teamId == null || userId == null || sendData || magicToken == null) return;
        sendData = true;
        widget.onReceivedData(magicToken!, teamId, userId, cookies);
      }
    }
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

  Future<NavigationActionPolicy?> _shouldOverrideUrlLoading(InAppWebViewController controller, NavigationAction navigationAction) async {
    final url = navigationAction.request.url?.toString();
    if (url?.startsWith('slack://') == true) return NavigationActionPolicy.CANCEL;
    return NavigationActionPolicy.ALLOW;
  }

  Duration? get _longPressGestureDurationIOS => const Duration(milliseconds: 100);

  @override
  void dispose() {
    _loadingBarNotifier.dispose();
    headlessWebView?.dispose();
    super.dispose();
  }
}
