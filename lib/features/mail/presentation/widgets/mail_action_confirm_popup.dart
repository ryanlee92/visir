import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MailActionConfirmPopup extends ConsumerStatefulWidget {
  final String title;
  final String description;
  final Future<void> Function() onPressOk;

  const MailActionConfirmPopup({super.key, required this.title, required this.description, required this.onPressOk});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MailActionConfirmPopupState();
}

class _MailActionConfirmPopupState extends ConsumerState<MailActionConfirmPopup> {
  bool onProcess = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.title, style: context.titleMedium?.textColor(context.outlineVariant).textBold),
          const SizedBox(height: 12),
          Text(widget.description, style: context.titleSmall?.textColor(context.onInverseSurface), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          VisirButton(
            type: VisirButtonAnimationType.scaleAndOpacity,
            style: VisirButtonStyle(
              height: 36,
              width: 288,
              backgroundColor: context.primary,
              borderRadius: BorderRadius.circular(8),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            ),
            options: VisirButtonOptions(
              shortcuts: [
                VisirButtonKeyboardShortcut(message: context.tr.ok, keys: [LogicalKeyboardKey.enter]),
              ],
            ),
            onTap: () async {
              if (onProcess) return;

              setState(() {
                onProcess = true;
              });

              await widget.onPressOk();

              setState(() {
                onProcess = false;
              });

              context.pop();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                onProcess
                    ? CustomCircularLoadingIndicator(size: 18, color: context.outlineVariant)
                    : Text(context.tr.ok, style: context.labelLarge?.textColor(context.onPrimary)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          VisirButton(
            type: VisirButtonAnimationType.scaleAndOpacity,
            style: VisirButtonStyle(
              height: 36,
              width: 288,
              backgroundColor: context.surface,
              borderRadius: BorderRadius.circular(8),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            ),
            options: VisirButtonOptions(
              shortcuts: [
                VisirButtonKeyboardShortcut(message: context.tr.cancel, keys: [LogicalKeyboardKey.escape]),
              ],
            ),
            onTap: () => context.pop(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text(context.tr.cancel, style: context.labelLarge?.textColor(context.outlineVariant))],
            ),
          ),
        ],
      ),
    );
  }
}
