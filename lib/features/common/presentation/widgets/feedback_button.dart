import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedbackButton extends ConsumerStatefulWidget {
  const FeedbackButton({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FeedbackButtonState();
}

class _FeedbackButtonState extends ConsumerState<FeedbackButton> {
  @override
  Widget build(BuildContext context) {
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
      options: VisirButtonOptions(tooltipLocation: VisirButtonTooltipLocation.right, message: context.tr.join_community),
      focusNode: FocusNode(skipTraversal: true),
      onTap: () {
        Utils.launchSlackCommunity();
      },
      child: Image.asset(
        '${(kDebugMode && kIsWeb) ? "" : "assets/"}logos/logo_slack.png',
        width: isTabBarCollapsed ? 20 : 24,
        height: isTabBarCollapsed ? 20 : 24,
      ),
    );
  }
}
