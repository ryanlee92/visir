import 'package:Visir/config/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/mail/application/mail_thread_list_controller.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_file_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MailAttachmentWidget extends ConsumerStatefulWidget {
  final TabType tabType;
  final MailEntity email;
  final MailFileEntity file;
  final Color? backgroundColor;

  const MailAttachmentWidget({super.key, required this.email, required this.file, this.backgroundColor, required this.tabType});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MailAttachmentWidgetState();
}

class _MailAttachmentWidgetState extends ConsumerState<MailAttachmentWidget> {
  bool isLoading = false;
  bool isTextOverflowed = false;
  double? _lastMeasuredMaxWidth;

  @override
  Widget build(BuildContext context) {
    final name = widget.file.name;
    return Container(
      width: 180,
      height: 38,
      decoration: BoxDecoration(color: widget.backgroundColor ?? context.surfaceVariant, borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.only(left: 16.0, right: 6),
      child: Row(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (_lastMeasuredMaxWidth != constraints.maxWidth) {
                  final textSpan = TextSpan(text: name, style: context.bodyLarge?.textColor(context.onSurfaceVariant));
                  final textPainter = TextPainter(text: textSpan, maxLines: 1, textDirection: TextDirection.ltr);
                  textPainter.layout(minWidth: 0, maxWidth: constraints.maxWidth);
                  isTextOverflowed = textPainter.didExceedMaxLines;
                  _lastMeasuredMaxWidth = constraints.maxWidth;
                }

                Widget textWidge = Text(name, style: context.bodyLarge?.textColor(context.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis);

                return isTextOverflowed
                    ? Tooltip(
                        showDuration: Duration(days: 1),
                        triggerMode: PlatformX.isMobile ? TooltipTriggerMode.tap : null,
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        richMessage: TextSpan(
                          children: [
                            WidgetSpan(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 200),
                                child: Text(name, style: context.bodyMedium?.textColor(context.onSurfaceVariant), textAlign: TextAlign.center),
                              ),
                            ),
                          ],
                        ),
                        verticalOffset: 15,
                        textAlign: TextAlign.center,
                        decoration: ShapeDecoration(
                          color: context.surfaceVariant,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          shadows: [BoxShadow(color: Color(0x3F000000).withValues(alpha: 0.25), blurRadius: 12, offset: Offset(0, 4), spreadRadius: 0)],
                        ),
                        child: textWidge,
                      )
                    : textWidge;
              },
            ),
          ),
          const SizedBox(width: 4),
          VisirButton(
            type: VisirButtonAnimationType.scaleAndOpacity,
            style: VisirButtonStyle(
              cursor: SystemMouseCursors.click,
              borderRadius: BorderRadius.circular(4),
              padding: EdgeInsets.all(6),
              width: 14 + 12,
              height: 14 + 12,
            ),
            onTap: () async {
              final id = widget.file.id;
              if (widget.email.id == null) return;
              if (isLoading) return;

              isLoading = true;
              setState(() {});

              final data = await ref
                  .read(mailThreadListControllerProvider(tabType: widget.tabType).notifier)
                  .fetchAttachments(mail: widget.email, attachmentIds: [id]);

              if (!data.containsKey(id)) {
                isLoading = false;
                setState(() {});
                return;
              }

              await downloadBytes(bytes: [data[id]!], names: [name], context: context);

              isLoading = false;
              setState(() {});
            },
            child: isLoading
                ? CustomCircularLoadingIndicator(size: 14, color: context.onSurfaceVariant)
                : VisirIcon(
                    type: PlatformX.isMobileView
                        ? PlatformX.isAndroid
                              ? VisirIconType.more
                              : VisirIconType.share
                        : VisirIconType.download,
                    size: 14,

                    isSelected: true,
                  ),
          ),
        ],
      ),
    );
  }
}
