import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/preference/presentation/screens/preference_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IntegrationPlaceHolder extends ConsumerStatefulWidget {
  final String title;
  final String description;
  final String buttonText;

  const IntegrationPlaceHolder({required this.title, required this.description, required this.buttonText});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _IntegrationPlaceHolderState();
}

class _IntegrationPlaceHolderState extends ConsumerState<IntegrationPlaceHolder> {
  bool get isMobileView => PlatformX.isMobileView;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: isMobileView ? 300 : 236,
        decoration: ShapeDecoration(
          color: context.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          shadows: [BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 4), spreadRadius: 0)],
        ),
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(widget.title, style: context.bodyMedium?.textColor(context.outlineVariant).textBold, textAlign: TextAlign.center),
            SizedBox(height: 4),
            Text(widget.description, style: context.bodyMedium?.textColor(context.shadow), textAlign: TextAlign.center),
            SizedBox(height: 12),
            Center(
              child: IntrinsicWidth(
                child: VisirButton(
                  type: VisirButtonAnimationType.scaleAndOpacity,
                  style: VisirButtonStyle(
                    cursor: SystemMouseCursors.click,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    borderRadius: BorderRadius.circular(4),
                    backgroundColor: context.primary,
                  ),
                  onTap: () {
                    Utils.showPopupDialog(
                      child: PreferenceScreen(key: Utils.preferenceScreenKey, initialPreferenceScreenType: PreferenceScreenType.integration),
                      size: isMobileView ? null : Size(640, 560),
                    );
                  },
                  child: Text(widget.buttonText, style: context.bodyMedium?.textColor(context.onPrimary)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
