import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadButton extends ConsumerStatefulWidget {
  const DownloadButton({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FeedbackButtonState();
}

class _FeedbackButtonState extends ConsumerState<DownloadButton> {
  @override
  Widget build(BuildContext context) {
    if (!PlatformX.isWeb) return SizedBox.shrink();

    final tabBarDisplayType = ref.watch(localPrefControllerProvider.select((e) => e.value!.prefTabBarDisplayType));
    bool isTabBarCollapsed = context.isNarrowScaffold || (tabBarDisplayType == TabBarDisplayType.alwaysCollapsed);

    return VisirButton(
      type: VisirButtonAnimationType.scaleAndOpacity,
      style: VisirButtonStyle(
        margin: EdgeInsets.only(bottom: 6),
        width: isTabBarCollapsed ? 36 : 56,
        height: isTabBarCollapsed ? 36 : 56,
        borderRadius: BorderRadius.circular(8),
      ),
      options: VisirButtonOptions(message: context.tr.download_button, tooltipLocation: VisirButtonTooltipLocation.right),
      focusNode: FocusNode(skipTraversal: true),
      onTap: () {
        Utils.launchUrlExternal(url: 'https://visir.pro/download');
      },
      child: VisirIcon(type: VisirIconType.download, size: isTabBarCollapsed ? 20 : 24),
    );
  }
}
