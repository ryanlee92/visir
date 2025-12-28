import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/mail/application/mail_thread_list_controller.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_file_entity.dart';
import 'package:Visir/features/mail/presentation/widgets/html_content_viewer_widget.dart';
import 'package:Visir/features/mail/presentation/widgets/html_scrollsync_viewport.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart' hide Element, Text;
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/dom.dart' show Element, Text, Document;
import 'package:html/parser.dart' as html;

class EmailContent {
  final String body;
  final String? quoted;

  EmailContent({required this.body, this.quoted});
}

class MailContentWidget extends ConsumerStatefulWidget {
  final String body;
  final String head;
  final bool isFromInbox;
  final bool isDarkTheme;
  final double width;
  final MailEntity mail;
  final TabType tabType;
  final void Function(double dx, double dy)? onScrollInsideIframe;
  final void Function()? onTapInsideWebView;
  final ScrollController scrollController;
  final double maxHeight;
  final GlobalKey<HtmlViewportSyncState> syncKey;

  const MailContentWidget({
    Key? key,
    required this.body,
    required this.head,
    required this.width,
    required this.isFromInbox,
    required this.isDarkTheme,
    required this.mail,
    required this.tabType,
    this.onScrollInsideIframe,
    this.onTapInsideWebView,
    required this.scrollController,
    required this.maxHeight,
    required this.syncKey,
  }) : super(key: key);

  @override
  MailContentWidgetState createState() => MailContentWidgetState();
}

class MailContentWidgetState extends ConsumerState<MailContentWidget> with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  bool showQuote = false;

  Map<MailFileEntity, String> base64Files = {};

  String? _lastProcessedBody;
  EmailContent? _cachedEmailContent;

  bool get isViewportSync => mailViewportSyncKey[widget.tabType] == widget.syncKey;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    Document doc = html.parse(widget.body);
    String _body = doc.body?.innerHtml ?? '';

    List<MailFileEntity> inlineAttachments = [
      ...widget.mail.getAttachments().where((a) {
        if (a.cid.trim().isNotEmpty) return true;
        return _body.contains('cid:${a.cid}');
      }),
    ];

    if (inlineAttachments.isEmpty) {
    } else {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        final attachmentIds = inlineAttachments.map((e) => e.id).whereType<String>().toList();
        ref.read(mailThreadListControllerProvider(tabType: widget.tabType).notifier).fetchAttachments(mail: widget.mail, attachmentIds: attachmentIds).then((
          fetchResult,
        ) {
          fetchResult.entries.forEach((entry) {
            final attachment = inlineAttachments.firstWhereOrNull((a) => a.id == entry.key);
            final bytes = entry.value;
            if (attachment != null && bytes != null) {
              final base64String = base64Encode(bytes);
              base64Files[attachment] = base64String;
            }
          });

          if (!mounted) return;
          setState(() {});
        });
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(MailContentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkTheme != widget.isDarkTheme) {
      if (mounted) setState(() {});
    }

    if (oldWidget.width != widget.width) {
      if (mounted) setState(() {});
    }

    if (oldWidget.body != widget.body) {
      _lastProcessedBody = null; // force recompute memoized content
    }
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    if (mounted) setState(() {});
  }

  String _applyInlineAttachments(String body) {
    var result = body;
    for (final attachment in base64Files.keys) {
      final data = base64Files[attachment];
      if (attachment.cid.trim().isNotEmpty) {
        result = result.replaceAll('cid:${attachment.cid.trim()}', 'data:${attachment.mimeType};base64,${data}');
      }
    }
    return result;
  }

  EmailContent extractQuotedHtml(String htmlContent) {
    if (htmlContent.trim().isEmpty) {
      return EmailContent(body: '', quoted: '');
    }

    final Document doc = html.parse(htmlContent);

    // Remove non-visible elements
    for (final sel in ['script', 'style', 'noscript', 'link', 'meta']) {
      doc.querySelectorAll(sel).forEach((el) => el.remove());
    }

    // Gmail's exact quoted content detection logic
    // Priority 1: Gmail's own markers
    final List<Element> quotedElements = [];

    // 1. gmail_quote (highest priority - Gmail's own wrapper)
    quotedElements.addAll(doc.querySelectorAll('.gmail_quote'));

    // 2. gmail_attr (attribution line that always precedes quoted content)
    quotedElements.addAll(doc.querySelectorAll('.gmail_attr'));

    // 3. blockquote elements (standard email quoting)
    quotedElements.addAll(doc.querySelectorAll('blockquote'));

    // 4. Other email client markers
    quotedElements.addAll(doc.querySelectorAll('.yahoo_quoted'));
    quotedElements.addAll(doc.querySelectorAll('.moz-cite-prefix'));

    // Extract and remove all quoted elements
    final List<String> quotedParts = [];
    for (final el in quotedElements) {
      quotedParts.add(el.outerHtml);
      el.remove();
    }

    // Priority 2: Look for attribution patterns (like "On [date], [person] wrote:")
    // This is what Gmail does when there's no explicit markup
    if (quotedParts.isEmpty) {
      final Element? body = doc.body;
      if (body != null) {
        Element? splitPoint;

        // Gmail looks for these patterns
        final attributionPatterns = [
          RegExp(r'On\s+.+?\s+wrote:', caseSensitive: false),
          RegExp(r'From:\s*.+', caseSensitive: false),
          RegExp(r'Sent:\s*.+', caseSensitive: false),
          RegExp(r'Date:\s*.+', caseSensitive: false),
          RegExp(r'Subject:\s*.+', caseSensitive: false),
          RegExp(r'To:\s*.+', caseSensitive: false),
          // Non-English patterns
          RegExp(r'De:\s*.+', caseSensitive: false), // Spanish/French
          RegExp(r'Von:\s*.+', caseSensitive: false), // German
          RegExp(r'Enviado:\s*.+', caseSensitive: false), // Spanish
          RegExp(r'Envoyé:\s*.+', caseSensitive: false), // French
          RegExp(r'Gesendet:\s*.+', caseSensitive: false), // German
        ];

        // Find the first element containing an attribution pattern
        void findSplitPoint(Element element) {
          if (splitPoint != null) return;

          final text = element.text.replaceAll('\u00A0', ' ').trim();
          for (final pattern in attributionPatterns) {
            if (pattern.hasMatch(text)) {
              // Found attribution - this is the split point
              splitPoint = element;
              return;
            }
          }

          // Recurse through children
          for (final child in element.children) {
            findSplitPoint(child);
            if (splitPoint != null) return;
          }
        }

        findSplitPoint(body);

        // If we found a split point, everything from there onwards is quoted
        if (splitPoint != null) {
          final parent = splitPoint!.parent;
          if (parent != null) {
            final siblings = parent.nodes.toList();
            final startIndex = siblings.indexOf(splitPoint!);

            if (startIndex >= 0) {
              final quotedBuf = StringBuffer();
              for (var i = startIndex; i < siblings.length; i++) {
                final node = siblings[i];
                if (node is Element) {
                  quotedBuf.write(node.outerHtml);
                } else if (node is Text) {
                  quotedBuf.write(node.text);
                }
              }

              if (quotedBuf.isNotEmpty) {
                quotedParts.add(quotedBuf.toString());
              }

              // Remove quoted nodes
              for (var i = startIndex; i < siblings.length; i++) {
                siblings[i].remove();
              }
            }
          }
        }
      }
    }

    // Priority 3: Check for Outlook-style containers
    if (quotedParts.isEmpty) {
      final outlookContainer = doc.querySelector('#mail-editor-reference-message-container') ?? doc.querySelector('[data-outlook-triage="container"]');

      if (outlookContainer != null) {
        quotedParts.add(outlookContainer.outerHtml);
        outlookContainer.remove();
      }
    }

    // Get final body and quoted content
    final bodyHtml = (doc.body?.innerHtml ?? '').trim();
    final quotedHtml = quotedParts.where((s) => s.trim().isNotEmpty).join('\n');

    // Safety check: if body is empty but quoted is not, return everything as body
    if (bodyHtml.isEmpty && quotedHtml.isNotEmpty) {
      return EmailContent(body: htmlContent.trim(), quoted: '');
    }

    return EmailContent(body: bodyHtml, quoted: quotedHtml);
  }

  Color get backgroundColor => context.outline;

  Color get placeholderColor => widget.isDarkTheme ? Color(0xff48484A) : Color(0xffDBDBE0);

  double parentWidth = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final processedBody = _applyInlineAttachments(widget.body);
    if (_lastProcessedBody != processedBody || _cachedEmailContent == null) {
      _cachedEmailContent = extractQuotedHtml(processedBody);
      _lastProcessedBody = processedBody;
    }

    String bodyMain = _cachedEmailContent?.body ?? '';
    String blockquote = _cachedEmailContent?.quoted ?? '';

    // Check if bodyMain has meaningful content
    final bodyDoc = html.parse(bodyMain);
    final bodyText = bodyDoc.body?.text.trim() ?? '';
    final hasBodyContent = bodyText.isNotEmpty || RegExp(r'<(img|video|iframe|embed|object)\b', caseSensitive: false).hasMatch(bodyMain);

    // If bodyMain is empty but quote has content, move quote to bodyMain
    if (!hasBodyContent && blockquote.trim().isNotEmpty) {
      bodyMain = blockquote;
      blockquote = '';
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (isViewportSync && PlatformX.isMobileView) {
          mailViewportSyncVisibleNotifier[widget.tabType]!.value = false;
        }
      },
      child: Container(
        key: ValueKey('mail_content_widget_${widget.isDarkTheme}'),
        width: widget.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildWebView(bodyMain, false, true),
            if (blockquote.trim().isNotEmpty)
              VisirButton(
                type: VisirButtonAnimationType.scaleAndOpacity,
                onTap: () {
                  setState(() {
                    showQuote = !showQuote;
                  });
                },
                style: VisirButtonStyle(
                  width: 24,
                  height: 14,
                  margin: EdgeInsets.only(left: 6, bottom: 12, top: 12),
                  borderRadius: BorderRadius.circular(7),
                  backgroundColor: context.surfaceVariant,
                ),
                child: VisirIcon(type: VisirIconType.more, size: 14, color: widget.isDarkTheme ? Colors.white : Colors.black),
              ),
            if (blockquote.trim().isNotEmpty) buildWebView(blockquote, !showQuote, false),
            // if (blockquote.trim().isEmpty) SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void onSizeChanged(double width, double height, bool isMain) {}

  Widget buildWebView(String html, bool close, bool isMain) {
    return ValueListenableBuilder(
      valueListenable: mailViewportSyncVisibleNotifier[widget.tabType]!,
      builder: (context, value, child) {
        if (!value && isViewportSync) return SizedBox.shrink();
        if (PlatformX.isWeb) {
          return HtmlContentViewerOnWeb(
            contentHtml: html,
            close: close,
            isDarkTheme: widget.isDarkTheme,
            widthContent: widget.width - 16,
            heightContent: 100,
            onSizeChanged: (width, height) => onSizeChanged(width, height, isMain),
            onTapInsideWebView: widget.onTapInsideWebView,
            onScrollInsideIframe: (dx, dy) {
              widget.onScrollInsideIframe?.call(dx, dy);
            },
          );
        }

        return HtmlContentViewer(
          syncKey: isMain ? widget.syncKey : null,
          tabType: widget.tabType,
          contentHtml: html,
          scrollController: widget.scrollController,
          close: close,
          isDarkTheme: widget.isDarkTheme,
          initialWidth: widget.width,
          isMobileView: PlatformX.isMobileView,
          onTapInsideWebView: widget.onTapInsideWebView,
          maxHeight: widget.maxHeight,
        );
      },
    );
  }
}
