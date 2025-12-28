import 'dart:async';
import 'dart:math';

import 'package:Visir/app.dart';
import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/pinch_scale/src/pinch_to_scale_value.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/keyboard_shortcut.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/mail/presentation/widgets/html_content_viewer_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

class HtmlViewportSync extends ConsumerStatefulWidget {
  final String html; // 렌더할 HTML 문자열
  final ScrollController scrollController; // 바깥 List/Scroll의 컨트롤러
  final double viewportHeight; // WebView가 차지할 고정 뷰포트 높이(예: 900)
  final double width;
  final void Function(double height)? onContentHeightChanged;
  final void Function()? onTapInsideWebView;
  final OnMailtoDelegateAction? onMailtoDelegateAction;
  final TabType? tabType;
  const HtmlViewportSync({
    super.key,
    required this.html,
    required this.tabType,
    required this.scrollController,
    required this.viewportHeight,
    required this.width,
    this.onContentHeightChanged,
    this.onTapInsideWebView,
    this.onMailtoDelegateAction,
  });

  @override
  ConsumerState<HtmlViewportSync> createState() => HtmlViewportSyncState();
}

class HtmlViewportSyncState extends ConsumerState<HtmlViewportSync> {
  final _itemKey = GlobalKey(); // 이 아이템의 위치 계산용
  final _webKey = GlobalKey();
  InAppWebViewController? _web;
  final double _minContentHeight = 1;
  double _webTop = 0;
  double _webLeft = 0;

  bool get isDummy => widget.html == 'about:blank';

  Timer? _measureDebounce;
  double? _pendingRestoreTop;
  double? _pendingRestoreLeft;
  bool _isContentReady = false;
  bool _isScrolling = false;
  bool _isInitialLoadComplete = false;
  // double? _outerScrollOffsetSnapshot;

  ScrollController _horizontalController = ScrollController();

  double _originalWebViewWidth = 0;
  double _originalWebViewHeight = 0;
  double _webViewWrapperWidth = 0;
  double _webViewWrapperHeight = 0;
  double _lastAppliedScale = 1.0;

  @override
  void initState() {
    super.initState();
    // ReverseDevicePixelRatio가 이미 ratio를 적용하므로, 초기값은 _pinchScale만 적용
    _webViewWrapperWidth = widget.width * _pinchScale;
    _webViewWrapperHeight = widget.viewportHeight * _pinchScale;
    widget.scrollController.addListener(_onScroll);
    _isContentReady = PlatformX.isWindows ? true : false;
  }

  @override
  void dispose() {
    _measureDebounce?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HtmlViewportSync oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.html != widget.html && widget.html != 'about:blank') {
      // if (widget.scrollController.hasClients) {
      //   _outerScrollOffsetSnapshot = widget.scrollController.offset;
      // }
      _pendingRestoreTop = null;
      _pendingRestoreLeft = null;
      _webTop = 0;
      _webLeft = 0;
      _isContentReady = PlatformX.isWindows ? true : false;
      _isInitialLoadComplete = false; // 새 HTML 로드 시 초기화
      _measuredScale = 1;
      _userScale = 1;
      _originalWebViewWidth = widget.width;
      _originalWebViewHeight = _minContentHeight;
      // 초기 로드 시 _lastAppliedScale을 -1로 설정하여 측정 완료 후 확실히 업데이트되도록 함
      _lastAppliedScale = -1;
      // ReverseDevicePixelRatio가 이미 ratio를 적용하므로, Flutter wrapper 크기는 _pinchScale만 사용
      _webViewWrapperWidth = _originalWebViewWidth * _pinchScale;
      _webViewWrapperHeight = _originalWebViewHeight * _pinchScale;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.scrollController.jumpTo(0);
      });

      widget.scrollController.removeListener(_onScroll);
      widget.scrollController.addListener(_onScroll);
    }

    if (oldWidget.html != widget.html && widget.html != 'about:blank') {
      _web?.loadData(
        data: widget.html.replaceAll('</body>', '''
                <script>$_injectorJs</script>
                </body>
                '''),
      );
    }
  }

  // 스크롤 시: 아이템 내 가시 오프셋 계산 → WebView2에 scrollTo 메시지
  void _onScroll() {
    if (!mounted) return;
    _isScrolling = true;
    _syncToViewport();
    // 스크롤이 끝난 후 측정 허용
    _measureDebounce?.cancel();
    _measureDebounce = Timer(const Duration(milliseconds: 300), () {
      _isScrolling = false;
    });
  }

  void _syncToViewport() {
    if (isDummy) return;
    final itemBox = _itemKey.currentContext?.findRenderObject() as RenderBox?;
    final scrollable = Scrollable.of(context);
    final scrollBox = scrollable.context.findRenderObject();

    if (itemBox == null || scrollBox == null) return;

    // 아이템의 top(position) in 스크롤러 좌표계
    final itemOffset = itemBox.localToGlobal(Offset.zero, ancestor: scrollBox);

    // 스크롤러의 현재 스크롤 오프셋을 좌표계로 사용
    // ListView에서는 global y==0이 뷰포트 상단이므로,
    // 아이템 상단이 뷰포트 위로 얼마나 지나갔는지 = -itemTopInScroll
    final visibleYOffset = max(0.0, -itemOffset.dy);
    final visibleXOffset = max(0.0, _horizontalController.offset);

    // WebView 위치(아이템 내부에서의 배치 top)
    // 웹뷰 높이를 넘어서는 이동은 막음
    // ReverseDevicePixelRatio가 이미 ratio를 적용하므로, Flutter Container 크기는 _pinchScale만 사용
    final scaledHeight = _originalWebViewHeight * _pinchScale;
    final scaledWidth = _originalWebViewWidth * _pinchScale;
    // Container 높이에서 wrapper 높이를 뺀 값이 최대 스크롤 거리
    final maxVertical = max(0.0, scaledHeight - _webViewWrapperHeight);
    final maxHorizontal = max(0.0, scaledWidth - _webViewWrapperWidth);

    double cappedTop = visibleYOffset.clamp(0.0, maxVertical).toDouble();
    double cappedLeft = visibleXOffset.clamp(0.0, maxHorizontal).toDouble();

    if (_pendingRestoreTop != null) {
      cappedTop = _pendingRestoreTop!.clamp(0.0, maxVertical);
      _pendingRestoreTop = null;
    }

    if (_pendingRestoreLeft != null) {
      cappedLeft = _pendingRestoreLeft!.clamp(0.0, maxHorizontal);
      _pendingRestoreLeft = null;
    }

    // 화면 내 배치는 요소 top을 그대로 쓰되, 실제 WebView 내부 스크롤도 동일값으로 보냄
    // JavaScript의 transform scale은 ratio * _pinchScale이므로 이를 고려하여 스크롤 위치 계산
    final ratio = Utils.ref.read(zoomRatioProvider);
    final jsTotalScale = ratio * _pinchScale;
    if (_webTop != cappedTop || _webLeft != cappedLeft) {
      _webTop = cappedTop;
      _webLeft = 0; //cappedLeft;
      setState(() {});
      _postScrollTo(cappedTop / jsTotalScale, cappedLeft / jsTotalScale);
    }
  }

  Future<void> _postScrollTo(double y, double x) async {
    final c = _web;
    if (c == null) return;
    c.evaluateJavascript(source: 'window.scrollTo(0, ${y});');
  }

  // HTML 전체 높이 측정 → item placeholder 높이로 사용
  Future<void> _performContentMeasurement() async {
    final controller = _web;
    if (controller == null || !mounted) return;

    double? measuredHeight = null; //PlatformX.isApple ? (await controller.getContentHeight())?.toDouble() : null;
    double? measuredWidth = null; //PlatformX.isApple ? (await controller.getContentWidth())?.toDouble() : null;

    // try {
    //   if (PlatformX.isMobile) {
    //     measuredHeight = (await controller.getContentHeight())?.toDouble();
    //     measuredWidth = (await controller.getContentWidth())?.toDouble();
    //   }
    // } catch (e) {
    //   print('[DEBUG] _performContentMeasurement: 측정 중 오류 발생 - $e');
    // }

    dynamic metrics;
    try {
      metrics = await controller.evaluateJavascript(
        source: '''
        (function() {
          // wrapper div가 있으면 wrapper div 내부의 실제 content 크기를 측정
          const wrapper = document.getElementById('taskey-webview-wrapper');
          if (wrapper) {
            // wrapper div 내부의 실제 content 크기 측정
            // wrapper div의 scrollWidth/scrollHeight는 내부 content의 실제 크기를 반환
            // 하지만 wrapper div에 transform scale이 적용되어 있으면 getBoundingClientRect()는 scale된 크기를 반환
            // 따라서 wrapper div의 첫 번째 자식 요소의 원본 크기를 측정하거나
            // wrapper div 자체의 scrollWidth/scrollHeight를 사용
            
            // 방법 1: wrapper div의 scrollWidth/scrollHeight 사용 (내부 content의 실제 크기)
            let width = wrapper.scrollWidth;
            let height = wrapper.scrollHeight;
            
            // 방법 2: wrapper div 내부의 모든 자식 요소의 크기 확인
            const wrapperChildren = wrapper.children;
            if (wrapperChildren.length > 0) {
              for (let i = 0; i < wrapperChildren.length; i++) {
                const child = wrapperChildren[i];
                // getBoundingClientRect()는 transform scale이 적용된 크기를 반환하므로
                // scrollWidth/scrollHeight를 사용하여 원본 크기를 얻음
                const childWidth = child.scrollWidth || child.offsetWidth;
                const childHeight = child.scrollHeight || child.offsetHeight;
                width = Math.max(width, childWidth);
                height = Math.max(height, childHeight);
              }
            }
            
            // document.body와 document.documentElement의 크기도 확인 (fallback)
            const body = document.body, html = document.documentElement;
            width = Math.max(width, body.scrollWidth || 0, html.scrollWidth || 0);
            height = Math.max(height, body.scrollHeight || 0, html.scrollHeight || 0);
            
            return { height: height, width: width };
          } else {
            // wrapper div가 없으면 기존 방식대로 측정
            const body = document.body, html = document.documentElement;
            const height = Math.max(
              body.scrollHeight,
              html.scrollHeight,
            );
            const width = Math.max(
              body.scrollWidth,
              html.scrollWidth,
            );
            return { height: height, width: width };
          }
        })();
      ''',
      );
    } catch (_) {
      return;
    }
    if (metrics is Map) {
      measuredHeight ??= measuredHeight ?? (metrics['height'] as num?)?.toDouble();
      measuredWidth ??= (metrics['width'] as num?)?.toDouble();
    } else if (metrics is List && metrics.length >= 2) {
      measuredHeight ??= measuredHeight ?? (metrics[0] as num?)?.toDouble();
      measuredWidth ??= (metrics[1] as num?)?.toDouble();
    } else if (metrics is num) {
      measuredHeight ??= measuredHeight ?? metrics.toDouble();
    }

    // if (_originalWebViewWidth.floor() != max(widget.width, measuredWidth ?? widget.width).floor()) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     _web?.loadData(
    //       data: widget.html.replaceAll('</body>', '''
    //             <script>$_injectorJs</script>
    //             </body>
    //             '''),
    //     );
    //   });
    // }

    final newWidth = (max(widget.width, measuredWidth ?? widget.width).floor()).toDouble();
    final newHeight = (measuredHeight ?? _minContentHeight).floor().toDouble();

    // 원본 크기가 실제로 변경되었을 때만 업데이트
    final widthChanged = (_originalWebViewWidth - newWidth).abs() > 1;
    final heightChanged = (_originalWebViewHeight - newHeight).abs() > 1;

    if (widthChanged || heightChanged) {
      final oldMeasuredScale = _measuredScale;
      _originalWebViewWidth = newWidth;
      _originalWebViewHeight = newHeight;
      // _measuredScale을 자동으로 적용 (사용자가 pinch 액션을 하지 않은 경우 기본값)
      final newMeasuredScale = min(1.0, widget.width / _originalWebViewWidth).toDouble();

      final measuredScaleChanged = (oldMeasuredScale - newMeasuredScale).abs() > 0.001;
      _measuredScale = newMeasuredScale;

      // _measuredScale이 변경되면 _lastAppliedScale을 초기화하여 업데이트가 확실히 적용되도록 함
      if (measuredScaleChanged) {
        _lastAppliedScale = -1; // 강제로 업데이트되도록 초기화
      }

      // 원본 크기가 변경되었을 때만 wrapper 크기 업데이트
      // _measuredScale이 적용된 새로운 scale로 업데이트 (ratio * _measuredScale * _userScale)
      // 재시도 로직을 사용하여 확실히 적용되도록 함
      _updateWrapperSizeWithRetry();
    }

    // final rawWidth = measuredWidth ?? widget.width;
    // final rawHeight = max(_minContentHeight, measuredHeight ?? _contentHeight);
    // final nextScaleWidth = max(1, rawWidth / widget.width);

    // bool didUpdate = false;
    // final markReady = !isDummy && rawHeight > _minContentHeight + _dimensionTolerance;

    // if (pinchScale == 1) {
    //   final nextSafeLogical = rawHeight / nextScaleWidth;
    //   final shouldUpdate =
    //       (nextSafeLogical - safeLogical).abs() > _dimensionTolerance ||
    //       (_contentWidth - widget.width).abs() > _dimensionTolerance ||
    //       (nextScaleWidth - _scaleWidth).abs() > 1e-3;

    //   safeLogical = nextSafeLogical;

    //   if (shouldUpdate) {
    //     setState(() {
    //       _scaleWidth = nextScaleWidth.toDouble();
    //       _contentWidth = rawWidth;
    //       _contentHeight = !PlatformX.isWindows ? rawHeight : safeLogical;
    //       if (markReady) {
    //         _isContentReady = true;
    //       }
    //     });
    //     setZoom();
    //     didUpdate = true;
    //   } else if (markReady && !_isContentReady) {
    //     setState(() {
    //       _isContentReady = true;
    //     });
    //     WidgetsBinding.instance.addPostFrameCallback((_) {
    //       if (!mounted) return;
    //       _restoreOuterScrollIfNecessary();
    //     });
    //   }
    // } else {
    //   final scaledWidth = max(widget.width, rawWidth * pinchScale);
    //   final scaledHeight = rawHeight * pinchScale;
    //   final targetLogicalHeight = scaledHeight / nextScaleWidth;

    //   bool shouldUpdate = false;
    //   double nextContentWidth = _contentWidth;
    //   double nextContentHeight = _contentHeight;

    //   if (PlatformX.isWindows && scaledWidth - _contentWidth > _dimensionTolerance) {
    //     nextContentWidth = scaledWidth;
    //     shouldUpdate = true;
    //   }

    //   if (PlatformX.isWindows && targetLogicalHeight - _contentHeight > _dimensionTolerance) {
    //     nextContentHeight = targetLogicalHeight;
    //     shouldUpdate = true;
    //   }

    //   if ((nextScaleWidth - _scaleWidth).abs() > 1e-3) {
    //     shouldUpdate = true;
    //   }

    //   if (shouldUpdate) {
    //     setState(() {
    //       _scaleWidth = nextScaleWidth.toDouble();
    //       _contentWidth = nextContentWidth;
    //       _contentHeight = nextContentHeight;
    //     });
    //     setZoom();
    //     didUpdate = true;
    //   }
    //   if (markReady && !_isContentReady) {
    //     setState(() {
    //       _isContentReady = true;
    //     });
    //     WidgetsBinding.instance.addPostFrameCallback((_) {
    //       if (!mounted) return;
    //       _restoreOuterScrollIfNecessary();
    //     });
    //   }
    // }

    // if (didUpdate) {
    //   if (!mounted) return;
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     if (!mounted) return;

    //     _syncToViewport();
    //     if (pinchScale == 1) {
    //       widget.onContentHeightChanged?.call(safeLogical);
    //     }
    //     _restoreOuterScrollIfNecessary();
    //   });
    // } else if (_pendingRestoreTop != null || _pendingRestoreLeft != null) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     if (!mounted) return;
    //     _syncToViewport();
    //     _restoreOuterScrollIfNecessary();
    //   });
    // }
  }

  // WebMessage 수신 JS 설치 (Windows WebView2 기준)
  static String _injectorJs =
      '''
    (function() {
      function onHostMessage(e) {
        try {
          var msg = e.data;
          if (typeof msg === 'string') msg = JSON.parse(msg);
          if (msg && typeof msg.scrollTo === 'number') {
            window.scrollTo(window.scrollX, msg.scrollTo|0);
          }
        } catch (e) {}
      }

      if (window.chrome && window.chrome.webview) {
        window.chrome.webview.addEventListener('message', onHostMessage);
      } else {
        // iOS/Android 등 다른 플랫폼 대비: 일단 noop
        window.addEventListener('message', onHostMessage);
      }

      ${PlatformX.isAndroid ? '''
        // 안드로이드에서 스크롤 이벤트를 막아서 외부 스크롤만 작동하도록 함
        // 클릭은 여전히 작동함
        if (navigator.userAgent.indexOf('Android') > -1) {
          document.addEventListener('touchstart', function(e) {
            // 터치 시작은 허용 (클릭을 위해)
          }, { passive: true });
          
          document.addEventListener('touchmove', function(e) {
            // 스크롤 이벤트를 막음 - 외부 스크롤만 작동
            e.preventDefault();
          }, { passive: false });
          
          document.addEventListener('touchend', function(e) {
            // 터치 종료는 허용 (클릭을 위해)
          }, { passive: true });
        }
      ''' : ''}
    })();
  ''';

  void _updateWrapperSize() {
    if (_originalWebViewWidth == 0 || _originalWebViewHeight == 0) return;

    // Positioned의 크기는 Container의 크기와 일치해야 함
    // Container는 _pinchScale만 사용하므로, Positioned도 동일하게 설정
    // JavaScript의 transform scale에는 ratio * _pinchScale을 사용
    final flutterScale = _pinchScale;

    // Flutter wrapper 크기를 scale에 맞게 조절 (zoom 효과)
    final newWrapperWidth = _originalWebViewWidth * flutterScale;
    final newWrapperHeight = _originalWebViewHeight * flutterScale;

    // scale 값과 wrapper 크기가 모두 변경되지 않았으면 업데이트하지 않음
    // _lastAppliedScale이 -1이면 강제 업데이트
    final scaleChanged = _lastAppliedScale < 0 || (_lastAppliedScale - flutterScale).abs() >= 0.001;
    final widthChanged = (_webViewWrapperWidth - newWrapperWidth).abs() > 1;
    final heightChanged = (_webViewWrapperHeight - newWrapperHeight).abs() > 1;

    if (!scaleChanged && !widthChanged && !heightChanged) {
      return;
    }

    _lastAppliedScale = flutterScale;
    _webViewWrapperWidth = newWrapperWidth;
    _webViewWrapperHeight = newWrapperHeight;

    setState(() {});

    // JavaScript wrapper div 크기도 업데이트 (내부 콘텐츠 scale 적용)
    _updateWrapperDivSize();
  }

  Future<String?> _updateWrapperDivSize() async {
    if (_web == null || _originalWebViewWidth == 0 || _originalWebViewHeight == 0) {
      return null;
    }

    final ratio = Utils.ref.read(zoomRatioProvider);
    final totalScale = ratio * _pinchScale;

    final result = await _web?.evaluateJavascript(
      source:
          '''
          (function() {
            try {
              // DOM이 준비되었는지 확인
              if (!document.body || !document.documentElement) {
                return 'dom-not-ready';
              }
              
              // wrapper div가 없으면 생성
              let wrapper = document.getElementById('taskey-webview-wrapper');
              if (!wrapper) {
                wrapper = document.createElement('div');
                wrapper.id = 'taskey-webview-wrapper';
                wrapper.style.position = 'relative';
                wrapper.style.overflow = 'hidden';
                wrapper.style.width = '${_originalWebViewWidth}px';
                wrapper.style.height = '${_originalWebViewHeight * _userScale}px';
                
                // body의 모든 자식 노드를 wrapper로 이동 (스크립트 포함)
                const bodyChildren = Array.from(document.body.childNodes);
                bodyChildren.forEach(function(child) {
                  wrapper.appendChild(child);
                });
                
                document.body.appendChild(wrapper);
              }
              
              // wrapper div에 transform scale 적용 (zoom 효과)
              wrapper.style.transform = 'scale(${totalScale})';
              wrapper.style.transformOrigin = 'top left';
              wrapper.style.width = '${_originalWebViewWidth}px';
              wrapper.style.height = '${_originalWebViewHeight * _userScale}px';
              
              // body와 html의 높이는 콘텐츠에 맞게 자동으로 조절되도록 함 (minHeight를 최소값으로 설정)
              document.body.style.minHeight = '1px';
              document.documentElement.style.minHeight = '1px';
              
              return 'wrapper-scale-updated';
            } catch (e) {
              return 'error: ' + e.message;
            }
          })();
        ''',
    );

    return result?.toString();
  }

  void _updateWrapperSizeWithRetry({int retryCount = 0}) async {
    if (_originalWebViewWidth == 0 || _originalWebViewHeight == 0) {
      return;
    }

    // Flutter wrapper 크기 업데이트
    _updateWrapperSize();

    // JavaScript wrapper div 크기 업데이트 (재시도 로직 포함)
    if (_web != null && mounted) {
      final result = await _updateWrapperDivSize();
      if (result == 'dom-not-ready' && retryCount < 5) {
        Future.delayed(Duration(milliseconds: 100 * (retryCount + 1)), () {
          if (mounted) {
            _updateWrapperSizeWithRetry(retryCount: retryCount + 1);
          }
        });
      }
    }
  }

  double _userScale = 1;
  double _measuredScale = 1;
  double get _pinchScale => _userScale * _measuredScale;

  void _scheduleMeasure({Duration delay = const Duration(milliseconds: 50)}) {
    // 초기 로드 완료 후에는 측정하지 않음 (zoom이 유지되도록)
    if (isDummy || !mounted || _isScrolling || _isInitialLoadComplete) return;
    _measureDebounce?.cancel();
    _measureDebounce = Timer(delay, () {
      if (!mounted || _isScrolling || _isInitialLoadComplete) return;
      _performContentMeasurement();
    });
  }

  // void _restoreOuterScrollIfNecessary() {
  //   final controller = _attachedScrollController;
  //   final snapshot = _outerScrollOffsetSnapshot;
  //   if (controller == null || snapshot == null || !controller.hasClients) {
  //     return;
  //   }

  //   final current = controller.offset;
  //   if (current < snapshot - 0.5) {
  //     final maxExtent = controller.position.maxScrollExtent;
  //     final target = min(snapshot, maxExtent);
  //     if ((target - current).abs() > 0.5) {
  //       controller.jumpTo(target);
  //     }
  //   }

  //   _outerScrollOffsetSnapshot = null;
  // }

  @override
  Widget build(BuildContext context) {
    ref.listen(zoomRatioProvider, (previous, next) {
      if (_originalWebViewWidth != 0 && _originalWebViewHeight != 0) {
        _updateWrapperSize(); // 내부에서 _updateWrapperDivSize()도 호출됨
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _syncToViewport();
          }
        });
      }
    });

    return KeyboardShortcut(
      onKeyDown: (event) {
        final logicalKeyPressed = ServicesBinding.instance.keyboard.logicalKeysPressed.where((e) => e != LogicalKeyboardKey.escape).toList();
        final controlPressed = (logicalKeyPressed.isMetaPressed && (PlatformX.isApple)) || (logicalKeyPressed.isControlPressed && (!PlatformX.isApple));
        if (controlPressed && logicalKeyPressed.length == 2) {
          if (event.logicalKey == LogicalKeyboardKey.keyC && widget.tabType == tabNotifier.value) {
            _web?.evaluateJavascript(source: 'window.getSelection().toString()').then((text) {
              if (text?.isNotEmpty == true) {
                Clipboard.setData(ClipboardData(text: text!));
              }
            });
            return true;
          }
        }

        return false;
      },
      child: Container(
        width: widget.width,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            controller: _horizontalController,
            child: Builder(
              builder: (context) {
                // ReverseDevicePixelRatio가 이미 ratio를 적용하므로, 여기서는 _pinchScale만 사용
                final scaledWidth = _originalWebViewWidth * _pinchScale;
                final scaledHeight = _originalWebViewHeight * _pinchScale;
                return Container(
                  key: _itemKey,
                  width: scaledWidth,
                  height: scaledHeight,
                  child: PinchScale(
                    baseValue: _pinchScale,
                    currentValue: () => _pinchScale,
                    minValue: min(1, widget.width / _originalWebViewWidth),
                    maxValue: 2.0,
                    onValueChanged: (newValue) {
                      if (_originalWebViewWidth == 0 || _originalWebViewHeight == 0) return;

                      // _measuredScale을 기준으로 _userScale 계산
                      _userScale = newValue / _measuredScale;

                      // Flutter wrapper 크기 업데이트 (내부에서 JavaScript도 업데이트)
                      _updateWrapperSize();

                      // 스크롤 동기화
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          _syncToViewport();
                        }
                      });
                    },
                    child: Stack(
                      children: [
                        Positioned(
                          top: _webTop,
                          left: 0,
                          width: _webViewWrapperWidth,
                          height: _webViewWrapperHeight,
                          child: ReverseDevicePixelRatio(
                            child: InAppWebView(
                              key: _webKey,
                              webViewEnvironment: webViewEnvironment,
                              initialSettings: InAppWebViewSettings(
                                verticalScrollBarEnabled: false,
                                horizontalScrollBarEnabled: false,
                                disableVerticalScroll: true,
                                disableHorizontalScroll: true,
                                mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                                useHybridComposition: true,
                                allowFileAccessFromFileURLs: true,
                                allowUniversalAccessFromFileURLs: true,
                                blockNetworkImage: false,
                                blockNetworkLoads: false,
                                networkAvailable: true,
                                supportZoom: false,
                                needInitialFocus: false,
                                defaultFontSize: context.textScaler.scale(context.bodyMedium!.fontSize!).toInt(),
                                defaultFixedFontSize: context.textScaler.scale(context.bodyMedium!.fontSize!).toInt(),
                              ),
                              initialData: InAppWebViewInitialData(
                                data: widget.html.replaceAll('</body>', '''
                                  <script>$_injectorJs</script>
                                  </body>
                                  '''),
                              ),
                              // gestureRecognizers를 제거하여 웹뷰가 스크롤 이벤트를 소비하지 않도록 함
                              // 외부 스크롤만 작동하도록 함
                              gestureRecognizers: null,
                              onWebViewCreated: (controller) {
                                _web = controller;
                              },
                              onLoadStart: (c, _) {
                                if (isDummy) return;
                                _pendingRestoreTop ??= _webTop;
                                _pendingRestoreLeft ??= _webLeft;
                                _scheduleMeasure(delay: const Duration(milliseconds: 32));
                                _isContentReady = true;
                                // 초기 wrapper 크기 설정 (측정 전에도 기본 zoom 적용)
                                if (_originalWebViewWidth > 0 && _originalWebViewHeight > 0) {
                                  _updateWrapperSize();
                                }
                                setState(() {});
                              },
                              onLoadStop: (c, _) async {
                                if (isDummy) return;
                                c.addJavaScriptHandler(
                                  handlerName: HtmlInteraction.clickEventJSChannelName,
                                  callback: () {
                                    widget.onTapInsideWebView?.call();
                                  },
                                );

                                _pendingRestoreTop ??= _webTop;
                                _pendingRestoreLeft ??= _webLeft;

                                // 초기 측정만 수행
                                _scheduleMeasure(delay: const Duration(milliseconds: 32));
                                _scheduleMeasure(delay: const Duration(milliseconds: 250));
                                _scheduleMeasure(delay: const Duration(milliseconds: 500));
                                _scheduleMeasure(delay: const Duration(milliseconds: 1000));

                                // 초기 wrapper 크기 설정 (측정 전에도 기본 zoom 적용)
                                if (_originalWebViewWidth > 0 && _originalWebViewHeight > 0) {
                                  _lastAppliedScale = -1; // 강제로 업데이트되도록 초기화
                                  _updateWrapperSize();
                                }

                                // 초기 로드 완료 플래그 설정 (zoom은 이미 설정되어 있고, 측정에서도 유지되므로 다시 설정하지 않음)
                                Future.delayed(const Duration(milliseconds: 1200), () {
                                  if (mounted) {
                                    _isInitialLoadComplete = true;
                                  }
                                });
                              },
                              onProgressChanged: (c, progress) {
                                // 초기 로드 완료 전에만 측정 (로드 완료 후에는 zoom 유지를 위해 측정하지 않음)
                                if (isDummy || _isInitialLoadComplete) return;
                                _scheduleMeasure(delay: const Duration(milliseconds: 48));
                              },
                              onWindowFocus: (controller) {
                                // controller.clearFocus();
                                Utils.focusApp(focusNode: Utils.mainFocus, forceReset: true);
                              },
                              shouldOverrideUrlLoading: (controller, navigationAction) async {
                                // Allow initial about:blank load for the prewarmed dummy WebView to avoid macOS WebKit policy spam
                                final url = navigationAction.request.url?.toString();
                                if (navigationAction.isForMainFrame && (url == null || url == 'about:blank')) {
                                  return NavigationActionPolicy.ALLOW;
                                }

                                if (isDummy) return NavigationActionPolicy.CANCEL;

                                final uri = Uri.parse(url!);
                                final mailtoHandler = widget.onMailtoDelegateAction;
                                if (mailtoHandler != null && uri.isScheme('mailto')) {
                                  await mailtoHandler(uri);
                                  return NavigationActionPolicy.CANCEL;
                                }

                                if (await launcher.canLaunchUrl(uri) &&
                                    (navigationAction.navigationType == NavigationType.LINK_ACTIVATED || navigationAction.navigationType == null)) {
                                  await launcher.launchUrl(uri, mode: launcher.LaunchMode.externalApplication);
                                }

                                return NavigationActionPolicy.CANCEL;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
