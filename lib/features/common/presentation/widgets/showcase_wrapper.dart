import 'package:Visir/dependency/showcase_tutorial/showcase_tutorial.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowcaseWrapper extends ConsumerWidget {
  final Widget child;
  final String? showcaseKey;
  final Future<void> Function()? onBeforeShowcase;
  final TooltipPosition? tooltipPosition;
  final bool? closePopupOnNext;
  final BorderRadius? targetBorderRadius;
  final GlobalKey childKey = GlobalKey();

  ShowcaseWrapper({Key? key, required this.child, required this.showcaseKey, this.onBeforeShowcase, this.tooltipPosition, this.closePopupOnNext, this.targetBorderRadius});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
    if (isSignedIn) return child;
    if (showcaseKey == null) return child;

    return ValueListenableBuilder(
      valueListenable: isShowcaseOn,
      builder: (context, value, _) {
        if (value != showcaseKey) return Container(key: childKey, child: child);
        return Showcase(
          tooltipPosition: tooltipPosition,
          key: getShowcaseEntities()[showcaseKey]!.key,
          keys: PlatformX.isMobileView && showcaseKey != taskOnCalendarShowcaseKeyString ? null : getShowcaseEntities()[showcaseKey]!.keys,
          title: getShowcaseEntities()[showcaseKey]!.title,
          description: getShowcaseEntities()[showcaseKey]!.description,
          targetBorderRadius: targetBorderRadius ?? BorderRadius.circular(12),
          onBeforeShowcase: onBeforeShowcase,
          closePopupOnNext: closePopupOnNext ?? false,
          tooltipBackgroundColor: context.onBackground,
          textColor: context.background,
          child: Container(key: childKey, child: child),
        );
      },
    );
  }
}
