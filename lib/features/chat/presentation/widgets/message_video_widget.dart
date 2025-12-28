import 'package:Visir/config/providers.dart';
import 'package:Visir/features/chat/domain/entities/message_file_entity.dart';
import 'package:Visir/features/chat/presentation/widgets/message_video_screen.dart';
import 'package:Visir/features/chat/presentation/widgets/mobile_message_video_screen.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/proxy_network_image.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageVideoWidget extends ConsumerStatefulWidget {
  final MessageFileEntity file;
  final OAuthEntity? oauth;
  final TabType tabType;

  const MessageVideoWidget({super.key, required this.file, required this.oauth, required this.tabType});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageVideoWidgetState();
}

class _MessageVideoWidgetState extends ConsumerState<MessageVideoWidget> {
  bool get isDarkMode => context.isDarkMode;

  @override
  Widget build(BuildContext context) {
    final originalWidth = widget.file.width ?? 280 * 16 / 9;
    final originalHeight = widget.file.height ?? 280;

    double height = 280;
    double width = height * originalWidth / originalHeight;

    return IntrinsicWidth(
      child: VisirButton(
        type: VisirButtonAnimationType.scaleAndOpacity,
        style: VisirButtonStyle(
          cursor: WidgetStateMouseCursor.clickable,
          backgroundColor: context.surface,
          borderRadius: BorderRadius.circular(4),
          width: width,
          height: height,
        ),
        onTap: () {
          if (PlatformX.isMobileView) {
            showModalBottomSheet(
              context: context,
              useRootNavigator: true,
              isScrollControlled: true,
              useSafeArea: true,
              barrierColor: context.background,
              builder: (context) {
                return MobileMessageVideoScreen(file: widget.file, oauth: widget.oauth);
              },
            );
          } else {
            double aspectRatio = width / height;

            double popupMaxWidth = MediaQuery.of(context).size.width - 160;
            double poopupMaxHeight = MediaQuery.of(context).size.height - 104;

            double popupWidth = popupMaxWidth;
            double popupHeight = poopupMaxHeight;

            if (aspectRatio > popupMaxWidth / poopupMaxHeight) {
              popupHeight = popupMaxWidth / aspectRatio;
            } else {
              popupWidth = poopupMaxHeight * aspectRatio;
            }

            Utils.showPopupDialog(
              child: MessageVideoScreen(tabType: widget.tabType, file: widget.file, width: popupWidth, height: popupHeight, oauth: widget.oauth),
              size: Size(popupWidth, popupHeight),
              isMedia: true,
            );
          }
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              ProxyNetworkImage(imageUrl: widget.file.imageSource!, oauth: widget.oauth, width: width, height: height, fit: BoxFit.cover),
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: context.primary, borderRadius: BorderRadius.circular(22)),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: VisirIcon(type: VisirIconType.play, size: 20, color: Colors.white, isSelected: true),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
