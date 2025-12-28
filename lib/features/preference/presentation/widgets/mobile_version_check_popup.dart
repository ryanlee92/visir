import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MobileVersionCheckPopup extends ConsumerStatefulWidget {
  final bool isLatestVersion;
  const MobileVersionCheckPopup({
    super.key,
    required this.isLatestVersion,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MobileVersionCheckPopupState();
}

class _MobileVersionCheckPopupState extends ConsumerState<MobileVersionCheckPopup> {
  bool onProcess = false;

  bool get isLatestVersion => widget.isLatestVersion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(isLatestVersion ? context.tr.version_up_to_date_title : context.tr.version_new_version_ready_title,
              style: context.titleMedium?.textColor(context.outlineVariant).textBold),
          const SizedBox(height: 12),
          Text(
            isLatestVersion ? context.tr.version_up_to_date_description : context.tr.version_new_version_ready_description,
            style: context.titleSmall?.textColor(context.onInverseSurface),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          VisirButton(
            type: VisirButtonAnimationType.scaleAndOpacity,
            style: VisirButtonStyle(
              height: 40,
              backgroundColor: context.primary,
              borderRadius: BorderRadius.circular(8),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            ),
            onTap: () async {
              if (isLatestVersion) {
                context.pop();
              } else {
                Utils.openStorePage();
                context.pop();
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                onProcess
                    ? CustomCircularLoadingIndicator(size: 18, color: context.outlineVariant)
                    : Text(
                        isLatestVersion ? context.tr.version_up_to_date_confirm : context.tr.version_new_version_ready_confirm,
                        style: context.labelLarge?.textColor(context.onPrimary),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
