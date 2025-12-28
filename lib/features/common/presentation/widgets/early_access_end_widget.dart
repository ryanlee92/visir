import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EarlyAccessEndWidget extends ConsumerStatefulWidget {
  const EarlyAccessEndWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EarlyAccessEndWidgetState();
}

class _EarlyAccessEndWidgetState extends ConsumerState<EarlyAccessEndWidget> {
  @override
  void dispose() {
    updateUser();
    super.dispose();
  }

  void updateUser() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authControllerProvider).requireValue;
      if (!user.isSignedIn) return;

      Utils.ref
          .read(authControllerProvider.notifier)
          .updateUser(user: user.copyWith(userTutorialDoneList: [...user.tutorialDoneList, UserTutorialType.earlyAccessEnd].unique()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          '${(kDebugMode && kIsWeb) ? "" : "assets/"}images/subscription_done.png',
          width: 440,
          height: 226,
        ),
        Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr.early_access_done_title, style: context.titleMedium?.textColor(context.outlineVariant).textBold),
              SizedBox(height: 16),
              Text(context.tr.early_access_done_description, style: context.titleSmall?.textColor(context.shadow)),
              SizedBox(height: 20),
              Center(
                child: IntrinsicWidth(
                  child: VisirButton(
                    type: VisirButtonAnimationType.scaleAndOpacity,
                    style: VisirButtonStyle(
                      cursor: SystemMouseCursors.click,
                      backgroundColor: context.primary,
                      borderRadius: BorderRadius.circular(6),
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                    ),
                    onTap: () {
                      Navigator.of(Utils.mainContext).pop();
                    },
                    child: Text(context.tr.early_access_done_button, style: context.bodyLarge?.textColor(context.onPrimary)),
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
