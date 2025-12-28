import 'package:Visir/config/providers.dart';
import 'package:Visir/features/chat/domain/entities/message_file_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/keyboard_shortcut.dart';
import 'package:Visir/features/common/presentation/widgets/proxy_network_image.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageImageScreen extends ConsumerStatefulWidget {
  final MessageFileEntity? file;
  final List<MessageFileEntity> imageFiles;
  final double maxWidth;
  final double maxHeight;
  final bool isFile;
  final String? imageUrl;
  final OAuthEntity? oauth;
  final TabType tabType;

  const MessageImageScreen({
    required this.file,
    required this.imageFiles,
    required this.maxWidth,
    required this.maxHeight,
    required this.isFile,
    required this.imageUrl,
    required this.oauth,
    required this.tabType,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageImageScreenState();
}

class _MessageImageScreenState extends ConsumerState<MessageImageScreen> {
  double imageWidth = 0;
  double imageHeight = 0;
  MessageFileEntity? imageOnView;
  bool isDownloading = false;

  List<String> get imageIds => widget.imageFiles.map((e) => e.id).whereType<String>().toList();

  bool get isList => widget.imageFiles.length > 1;

  bool get isFirst => isList ? imageIds.firstOrNull == imageOnView?.id : false;

  bool get isLast => isList ? imageIds.lastOrNull == imageOnView?.id : false;

  int get currentIndex => imageIds.contains(imageOnView?.id) ? imageIds.indexOf(imageOnView?.id ?? '') : -1;

  @override
  void initState() {
    super.initState();
    imageOnView = widget.file;
  }

  void pop() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void swipeLeft() {
    if (isFirst) return;
    if (currentIndex < 0) return;
    setState(() {
      imageOnView = widget.imageFiles[currentIndex - 1];
    });
  }

  void swipeRight() {
    if (isLast) return;
    if (currentIndex < 0) return;
    setState(() {
      imageOnView = widget.imageFiles[currentIndex + 1];
    });
  }

  bool _onKeyDown(KeyEvent event, {bool? justReturnResult}) {
    final logicalKeyPressed = ServicesBinding.instance.keyboard.logicalKeysPressed.where((e) => e != LogicalKeyboardKey.escape);

    if (logicalKeyPressed.length == 1) {
      if (logicalKeyPressed.contains(LogicalKeyboardKey.arrowLeft)) {
        if (justReturnResult == true) return true;
        swipeLeft();
        return true;
      }

      if (logicalKeyPressed.contains(LogicalKeyboardKey.arrowRight)) {
        if (justReturnResult == true) return true;
        swipeRight();
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardShortcut(
      targetTab: widget.tabType,
      onKeyDown: _onKeyDown,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (widget.isFile) {
            double aspectRatio = 16 / 9;
            if (imageOnView?.width360 != null && imageOnView?.height360 != null) {
              aspectRatio = (imageOnView!.width360! / imageOnView!.height360!);
            }

            double popupMaxWidth = constraints.maxWidth - 160 - 32;
            double poopupMaxHeight = constraints.maxHeight - 104;

            imageWidth = popupMaxWidth;
            imageHeight = poopupMaxHeight;

            if (aspectRatio > popupMaxWidth / poopupMaxHeight) {
              imageHeight = popupMaxWidth / aspectRatio;
            } else {
              imageWidth = poopupMaxHeight * aspectRatio;
            }
          } else {
            imageWidth = widget.maxWidth - 160 - 32;
            imageHeight = widget.maxHeight;
          }
          return FocusTraversalGroup(
            descendantsAreFocusable: false,
            child: Material(
              color: PlatformX.isDesktopView ? Colors.transparent : context.background,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                  child: TapRegion(
                    onTapOutside: (event) {
                      pop();
                    },
                    child: Container(
                      width: widget.maxWidth,
                      height: widget.maxHeight,
                      child: Column(
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: pop,
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: pop,
                                  child: Container(color: Colors.transparent, height: imageHeight),
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                height: imageHeight,
                                child: Column(
                                  children: [
                                    Flexible(
                                      child: GestureDetector(
                                        onTap: pop,
                                        child: Container(color: Colors.transparent),
                                      ),
                                    ),
                                    isList && !isFirst
                                        ? VisirButton(
                                            type: VisirButtonAnimationType.scaleAndOpacity,
                                            style: VisirButtonStyle(
                                              margin: const EdgeInsets.only(right: 20),
                                              padding: EdgeInsets.all(16),
                                              constraints: BoxConstraints(minHeight: 64),
                                            ),
                                            onTap: swipeLeft,
                                            child: VisirIcon(type: VisirIconType.arrowLeft, size: 28),
                                          )
                                        : SizedBox(width: 80),
                                    Flexible(
                                      child: GestureDetector(
                                        onTap: pop,
                                        child: Container(color: Colors.transparent),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      color: context.surface,
                                      width: imageWidth,
                                      height: imageHeight,
                                      child: ProxyNetworkImage(
                                        imageUrl: widget.isFile ? (imageOnView?.downloadUrl ?? '') : (widget.imageUrl ?? ''),
                                        oauth: widget.oauth,
                                        width: imageWidth,
                                        height: imageHeight,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: ShapeDecoration(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          VisirButton(
                                            type: VisirButtonAnimationType.scaleAndOpacity,
                                            style: VisirButtonStyle(
                                              padding: EdgeInsets.all(4),
                                              hoverColor: Colors.white.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(6),
                                              cursor: SystemMouseCursors.click,
                                            ),
                                            options: VisirButtonOptions(message: context.tr.file_options_download),
                                            child: isDownloading
                                                ? CustomCircularLoadingIndicator(size: 20)
                                                : VisirIcon(type: VisirIconType.download, color: context.onPrimary, size: 20, isSelected: true),
                                            onTap: () async {
                                              setState(() {
                                                isDownloading = true;
                                              });

                                              String downloadUrl = widget.file?.downloadUrl ?? widget.imageUrl ?? '';
                                              String name = widget.file?.name ?? widget.imageUrl?.split('/').last ?? '';
                                              String? extension =
                                                  widget.file?.filetype ?? widget.file?.name?.split('.').last ?? widget.imageUrl?.split('.').last;

                                              await proxyDownload(url: downloadUrl, oauth: widget.oauth, name: name, extension: extension, context: context);

                                              setState(() {
                                                isDownloading = false;
                                              });
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          VisirButton(
                                            type: VisirButtonAnimationType.scaleAndOpacity,
                                            style: VisirButtonStyle(
                                              padding: EdgeInsets.all(4),
                                              hoverColor: Colors.white.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(6),
                                              cursor: SystemMouseCursors.click,
                                            ),
                                            options: VisirButtonOptions(
                                              tabType: widget.tabType,
                                              shortcuts: [
                                                VisirButtonKeyboardShortcut(message: context.tr.mail_detail_tooltip_close, keys: [LogicalKeyboardKey.escape]),
                                              ],
                                            ),
                                            onTap: pop,
                                            child: VisirIcon(type: VisirIconType.close, color: context.onPrimary, size: 20, isSelected: true),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 80,
                                height: imageHeight,
                                child: Column(
                                  children: [
                                    Flexible(
                                      child: GestureDetector(
                                        onTap: pop,
                                        child: Container(color: Colors.transparent),
                                      ),
                                    ),
                                    isList && !isLast
                                        ? VisirButton(
                                            type: VisirButtonAnimationType.scaleAndOpacity,
                                            style: VisirButtonStyle(
                                              margin: const EdgeInsets.only(left: 20),
                                              padding: EdgeInsets.all(16),
                                              constraints: BoxConstraints(minHeight: 64),
                                            ),
                                            onTap: swipeRight,
                                            child: VisirIcon(type: VisirIconType.arrowRight, size: 28),
                                          )
                                        : SizedBox(width: 80),
                                    Flexible(
                                      child: GestureDetector(
                                        onTap: pop,
                                        child: Container(color: Colors.transparent),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: pop,
                                  child: Container(color: Colors.transparent, height: imageHeight),
                                ),
                              ),
                            ],
                          ),
                          Flexible(
                            child: GestureDetector(
                              onTap: pop,
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
