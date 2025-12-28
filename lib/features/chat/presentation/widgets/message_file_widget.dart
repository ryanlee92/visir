import 'package:Visir/config/providers.dart';
import 'package:Visir/features/chat/domain/entities/message_file_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessageFileWidget extends ConsumerStatefulWidget {
  final MessageFileEntity file;
  final OAuthEntity? oauth;

  const MessageFileWidget({required this.file, required this.oauth});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageFileWidgetState();
}

class _MessageFileWidgetState extends ConsumerState<MessageFileWidget> {
  bool isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 48,
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 6),
      decoration: ShapeDecoration(
        color: (PlatformX.isMobileView
            ? context.surfaceVariant
            : context.isDarkMode
            ? context.outline
            : context.surfaceVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, top: 9, bottom: 9),
              child: Text(
                widget.file.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.titleSmall?.textBold.textColor(context.outlineVariant),
              ),
            ),
          ),
          UnconstrainedBox(
            child: VisirButton(
              type: VisirButtonAnimationType.scaleAndOpacity,
              style: VisirButtonStyle(
                padding: EdgeInsets.all(9),
                margin: EdgeInsets.only(left: 6, right: 3),
                width: 36,
                height: 36,
                cursor: SystemMouseCursors.click,
                borderRadius: BorderRadius.circular(6),
              ),
              child: isDownloading
                  ? CustomCircularLoadingIndicator(size: 18, color: context.outlineVariant)
                  : VisirIcon(
                      type: PlatformX.isMobileView
                          ? PlatformX.isAndroid
                                ? VisirIconType.more
                                : VisirIconType.share
                          : VisirIconType.download,
                      color: context.outlineVariant,
                      size: 18,
                    ),
              onTap: () async {
                setState(() {
                  isDownloading = true;
                });

                String downloadUrl = widget.file.downloadUrl ?? '';

                await proxyDownload(url: downloadUrl, oauth: widget.oauth, name: widget.file.name!, extension: widget.file.filetype, context: context);

                setState(() {
                  isDownloading = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
