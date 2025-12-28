import 'dart:async';

import 'package:Visir/config/image_cache_config.dart';
import 'package:Visir/config/providers.dart';
import 'package:Visir/features/chat/domain/entities/message_file_entity.dart';
import 'package:Visir/features/chat/presentation/widgets/message_image_screen.dart';
import 'package:Visir/features/chat/presentation/widgets/mobile_message_image_screen.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/proxy_network_image.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageImageWidget extends ConsumerStatefulWidget {
  final String teamId;
  final MessageFileEntity? imageFile;
  final List<MessageFileEntity> imageFiles;
  final bool isFile;
  final String? imageUrl;
  final OAuthEntity? oauth;
  final TabType tabType;

  const MessageImageWidget({
    required this.teamId,
    required this.imageFile,
    required this.imageFiles,
    required this.isFile,
    required this.imageUrl,
    required this.oauth,
    required this.tabType,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageImageWidgetState();
}

class _MessageImageWidgetState extends ConsumerState<MessageImageWidget> {
  Future<Size> _getImageInfo({required String imageUrl}) {
    Completer<Size> completer = Completer();
    // Memory optimization: use centralized cache manager with size limits
    final imageProvider = CachedNetworkImageProvider(
      imageUrl,
      cacheManager: VisirImageCacheManager.instance,
      maxHeight: VisirImageCacheManager.maxImageHeight,
      maxWidth: VisirImageCacheManager.maxImageWidth,
    );
    imageProvider
        .resolve(ImageConfiguration())
        .addListener(
          ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) {
            var myImage = imageInfo.image;
            Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
            completer.complete(size);
          }),
        );
    return completer.future;
  }

  double width = 200;
  final double height = 200;

  @override
  void initState() {
    super.initState();
    setWidth();
  }

  Future<void> setWidth() async {
    if (widget.imageUrl != null) {
      final size = await _getImageInfo(imageUrl: widget.imageUrl!);
      width = height * (size.width / size.height);
    } else if (widget.imageFile != null && widget.imageFile!.width != null && widget.imageFile!.height != null) {
      width = height * (widget.imageFile!.width! / widget.imageFile!.height!);
    }

    double maxWidth = 280;
    double minWidth = 40;

    if (width < minWidth) width = minWidth;
    if (width > maxWidth) width = maxWidth;
    if (widget.imageUrl != null) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.isFile ? (widget.imageFile?.imageSource ?? '') : (widget.imageUrl ?? '');

    return IntrinsicWidth(
      child: VisirButton(
        type: VisirButtonAnimationType.scaleAndOpacity,
        style: VisirButtonStyle(cursor: WidgetStateMouseCursor.clickable, borderRadius: BorderRadius.circular(6)),
        onTap: () async {
          if (PlatformX.isMobileView) {
            showModalBottomSheet(
              context: context,
              useRootNavigator: true,
              isScrollControlled: true,
              useSafeArea: true,
              barrierColor: context.background,
              builder: (context) {
                return MobileMessageImageScreen(
                  imageFile: widget.imageFile,
                  imageFiles: widget.imageFiles,
                  isFile: widget.isFile,
                  imageUrl: widget.imageUrl,
                  oauth: widget.oauth,
                );
              },
            );
          } else {
            double defaultAspectRatio = 16 / 9;
            List<double> widths = [];
            List<double> heights = [];

            if (widget.isFile) {
              widget.imageFiles.forEach((e) {
                if (e.width360 != null && e.height360 != null) {
                  defaultAspectRatio = (e.width360! / e.height360!);
                }

                double popupMaxWidth = MediaQuery.of(context).size.width - 160;
                double poopupMaxHeight = MediaQuery.of(context).size.height - 104;

                double popupWidth = popupMaxWidth;
                double popupHeight = poopupMaxHeight;

                if (defaultAspectRatio > popupMaxWidth / poopupMaxHeight) {
                  popupHeight = popupMaxWidth / defaultAspectRatio;
                } else {
                  popupWidth = poopupMaxHeight * defaultAspectRatio;
                }

                widths.add(popupWidth);
                heights.add(popupHeight);
              });
            } else {
              Size size = await _getImageInfo(imageUrl: widget.imageUrl ?? '');
              defaultAspectRatio = size.width / size.height;

              double popupMaxWidth = MediaQuery.of(context).size.width - 160;
              double poopupMaxHeight = MediaQuery.of(context).size.height - 104;

              double popupWidth = popupMaxWidth;
              double popupHeight = poopupMaxHeight;

              if (defaultAspectRatio > popupMaxWidth / poopupMaxHeight) {
                popupHeight = popupMaxWidth / defaultAspectRatio;
              } else {
                popupWidth = poopupMaxHeight * defaultAspectRatio;
              }

              widths.add(popupWidth);
              heights.add(popupHeight);
            }

            Utils.showPopupDialog(
              child: MessageImageScreen(
                tabType: widget.tabType,
                maxWidth: widths.max + 160,
                maxHeight: heights.max,
                file: widget.imageFile,
                imageFiles: widget.imageFiles,
                isFile: widget.isFile,
                imageUrl: widget.imageUrl,
                oauth: widget.oauth,
              ),
              size: Size(widths.max + 160, heights.max),
              isMedia: true,
            );
          }
        },
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: context.background,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: context.outlineVariant.withValues(alpha: 0.1), width: 1),
          ),
          child: Padding(
            padding: EdgeInsets.all(0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: AspectRatio(
                aspectRatio: 1,
                child: ProxyNetworkImage(imageUrl: imageUrl, oauth: widget.oauth, width: width, height: height, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
