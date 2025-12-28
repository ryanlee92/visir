import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:flutter/material.dart';

class VisirEmptyWidget extends StatelessWidget {
  final double? height;
  final double? width;
  final String? message;
  final String? buttonText;
  final VisirIconType? buttonIcon;
  final VoidCallback? onButtonTap;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryButtonTap;

  const VisirEmptyWidget({
    super.key,
    this.height,
    this.width,
    this.message,
    this.buttonText,
    this.buttonIcon,
    this.onButtonTap,
    this.secondaryButtonText,
    this.onSecondaryButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        height: height,
        width: width,
        constraints: BoxConstraints(maxWidth: 380),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              constraints: BoxConstraints(maxWidth: 240, maxHeight: 240),
              child: Image.asset('assets/illust/noselection.png', fit: BoxFit.contain),
            ),
            if (message != null)
              Padding(
                padding: EdgeInsets.only(top: 0, bottom: 24),
                child: Text(message!, style: context.titleMedium?.textColor(context.surfaceTint), textAlign: TextAlign.center),
              ),

            if (buttonText != null && onButtonTap != null)
              IntrinsicWidth(
                child: VisirButton(
                  type: VisirButtonAnimationType.scaleAndOpacity,
                  onTap: onButtonTap,
                  style: VisirButtonStyle(
                    margin: EdgeInsets.only(top: 16),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    backgroundColor: context.primary,
                    borderRadius: BorderRadius.circular(12),
                    cursor: SystemMouseCursors.click,
                  ),
                  child: Row(
                    children: [
                      if (buttonIcon != null) VisirIcon(type: buttonIcon!, size: 16, color: context.onPrimary),
                      if (buttonIcon != null) SizedBox(width: 6),
                      Text(buttonText!, style: context.titleMedium?.textColor(context.onPrimary)),
                    ],
                  ),
                ),
              ),

            if (secondaryButtonText != null && onSecondaryButtonTap != null)
              IntrinsicWidth(
                child: VisirButton(
                  type: VisirButtonAnimationType.scaleAndOpacity,
                  onTap: onSecondaryButtonTap,
                  style: VisirButtonStyle(
                    margin: EdgeInsets.only(top: 16),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    backgroundColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    cursor: SystemMouseCursors.click,
                  ),
                  child: Row(children: [Text(secondaryButtonText!, style: context.titleSmall?.textColor(context.outline))]),
                ),
              ),

            SizedBox(height: (PlatformX.isMobileView ? scrollViewBottomPadding.bottom : VisirAppBar.height)),
          ],
        ),
      ),
    );
  }
}
