import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DownloadMobileAppPopup extends StatefulWidget {
  const DownloadMobileAppPopup({super.key});

  @override
  State<DownloadMobileAppPopup> createState() => _DownloadMobileAppPopupState();
}

class _DownloadMobileAppPopupState extends State<DownloadMobileAppPopup> {
  String imagePath = '${(kDebugMode && kIsWeb) ? "" : "assets/"}images/mobile_download.png';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(imagePath, width: 440, fit: BoxFit.cover),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(context.tr.download_mobile_app_popup_title, style: Theme.of(context).textTheme.titleMedium?.textColor(context.outlineVariant).textBold),
              const SizedBox(height: 12),
              Text(context.tr.download_mobile_app_popup_description, style: Theme.of(context).textTheme.titleSmall?.textColor(context.shadow)),
              const SizedBox(height: 20),
              Center(
                child: IntrinsicWidth(
                  child: VisirButton(
                    type: VisirButtonAnimationType.scaleAndOpacity,
                    style: VisirButtonStyle(
                      cursor: SystemMouseCursors.click,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                      borderRadius: BorderRadius.circular(6),
                      backgroundColor: context.primary,
                      width: 80,
                    ),
                    onTap: () {
                      Navigator.of(Utils.mainContext).maybePop();
                    },
                    child: Text(
                      context.tr.download_mobile_app_popup_button,
                      style: context.bodyLarge?.textColor(context.onPrimary),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
