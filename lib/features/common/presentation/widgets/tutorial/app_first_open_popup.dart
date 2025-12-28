import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppFirstOpenPopup extends ConsumerStatefulWidget {
  final double width;

  const AppFirstOpenPopup({Key? key, required this.width}) : super(key: key);

  @override
  ConsumerState<AppFirstOpenPopup> createState() => _AppFirstOpenPopupState();
}

class _AppFirstOpenPopupState extends ConsumerState<AppFirstOpenPopup> {
  @override
  void dispose() {
    updateUserAppOpened();
    super.dispose();
  }

  void updateUserAppOpened() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final user = Utils.ref.read(authControllerProvider).requireValue;
      if (!user.isSignedIn) return;

      if (PlatformX.isDesktop) {
        Utils.ref.read(authControllerProvider.notifier).updateUser(user: user.copyWith(desktopAppOpened: true));
      } else if (PlatformX.isMobile) {
        Utils.ref.read(authControllerProvider.notifier).updateUser(user: user.copyWith(mobileAppOpened: true));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isMobileView = PlatformX.isMobileView;

    String imagePath = '${(kDebugMode && kIsWeb) ? "" : "assets/"}images/tutorial_first_main${isMobileView ? '_mobile' : ''}.png';

    return Column(
      children: [
        Image.asset(imagePath, width: widget.width, fit: BoxFit.cover),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(context.tr.tutorial_welcome_to_taskey, style: Theme.of(context).textTheme.titleMedium?.textColor(context.outlineVariant).textBold),
              const SizedBox(height: 16),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: VisirIcon(type: VisirIconType.integration, size: 16, color: context.shadow),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(context.tr.tutorial_connect_apps, style: Theme.of(context).textTheme.titleSmall?.textColor(context.shadow))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: VisirIcon(type: VisirIconType.clock, size: 16, color: context.shadow),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(context.tr.tutorial_keep_everything_organized, style: Theme.of(context).textTheme.titleSmall?.textColor(context.shadow)),
                  ),
                ],
              ),
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
                    ),
                    onTap: () {
                      Navigator.of(Utils.mainContext).maybePop();
                    },
                    child: Text(context.tr.tutorial_get_started, style: context.bodyLarge?.textColor(context.onPrimary)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
