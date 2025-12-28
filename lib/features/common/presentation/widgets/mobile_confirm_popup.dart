import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MobileConfirmPopup extends ConsumerStatefulWidget {
  final String title;
  final String description;
  final String cancelString;
  final String confirmString;
  final bool isWarning;
  final Future<void> Function() onPressConfirm;
  final VoidCallback? afterPressConfirm;
  final Future<void> Function()? onPressCancel;
  final bool hideCancelButton;

  const MobileConfirmPopup({
    required this.title,
    required this.description,
    required this.cancelString,
    required this.confirmString,
    required this.isWarning,
    required this.onPressConfirm,
    required this.onPressCancel,
    required this.hideCancelButton,
    this.afterPressConfirm,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MobileConfirmPopupState();
}

class _MobileConfirmPopupState extends ConsumerState<MobileConfirmPopup> {
  bool onProcess = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Text(widget.title, style: context.titleMedium?.textColor(context.outlineVariant).textBold, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(widget.description, style: context.titleSmall?.textColor(context.onInverseSurface), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Row(
            children: [
              if (!widget.hideCancelButton)
                Expanded(
                  child: VisirButton(
                    type: VisirButtonAnimationType.scaleAndOpacity,
                    style: VisirButtonStyle(
                      backgroundColor: context.surface,
                      borderRadius: BorderRadius.circular(8),
                      height: 48,
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      alignment: Alignment.center,
                    ),
                    onTap: () {
                      widget.onPressCancel?.call();
                      context.pop(false);
                    },
                    child: Text(widget.cancelString, style: context.titleSmall?.textColor(context.outlineVariant)),
                  ),
                ),
              if (!widget.hideCancelButton) SizedBox(width: 8),
              Expanded(
                child: VisirButton(
                  type: VisirButtonAnimationType.scaleAndOpacity,
                  style: VisirButtonStyle(
                    height: 48,
                    backgroundColor: widget.isWarning ? context.surface : context.primary,
                    borderRadius: BorderRadius.circular(8),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    alignment: Alignment.center,
                  ),
                  onTap: () async {
                    if (onProcess) return;
                    onProcess = true;
                    setState(() {});
                    await widget.onPressConfirm();
                    if (!mounted) return;
                    onProcess = false;
                    setState(() {});
                    context.pop(true);
                    widget.afterPressConfirm?.call();
                  },
                  child: onProcess
                      ? CustomCircularLoadingIndicator(size: 18, color: context.onPrimary)
                      : Text(widget.confirmString, style: context.titleSmall?.textColor(widget.isWarning ? context.error : context.onPrimary)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
