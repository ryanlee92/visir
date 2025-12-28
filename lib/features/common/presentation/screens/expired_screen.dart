import 'package:Visir/dependency/custom_dialog/flutter_custom_dialog.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/presentation/screens/subscription_screen.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../auth/providers.dart';

class ExpiredScreen extends ConsumerStatefulWidget {
  const ExpiredScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExpiredScreenState();
}

class _ExpiredScreenState extends ConsumerState<ExpiredScreen> {
  bool isMobile = PlatformX.isMobile;

  onPressLogout() {
    Utils.ref.read(authControllerProvider.notifier).signOut();
  }

  onPressDeleteAccount() {
    final dialog = YYDialog().build(context)
      ..width = 280
      ..borderRadius = 12
      ..backgroundColor = context.surface
      ..text(
        text: context.tr.delete_confirm_text,
        color: context.onBackground,
        fontSize: context.bodyLarge!.fontSize,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      )
      ..doubleButton(
        gravity: Gravity.right,
        text1: context.tr.cancel,
        color1: context.primary,
        fontSize1: context.bodyMedium?.fontSize,
        isClickAutoDismiss: true,
        onTap1: () async {},
        text2: context.tr.delete_confirm_title,
        color2: context.error,
        fontSize2: context.bodyMedium?.fontSize,
        onTap2: () async {
          Navigator.of(context).popUntil((route) => route.isFirst);
          await Future.delayed(Duration(milliseconds: 200));
          Utils.ref.read(authControllerProvider.notifier).deleteUser();
        },
      );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dialog.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    String? provider = ref.watch(authRepositoryProvider.select((value) => value.provider));
    String email = ref.watch(authControllerProvider.select((v) => v.requireValue.subscription?.userEmail ?? v.requireValue.email ?? ''));

    bool isAppleHiddenEmail = provider?.toLowerCase() == 'apple' && email.isEmpty;

    return Material(
      color: Colors.transparent,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ValueListenableBuilder(
                valueListenable: Constants.isBetaBuildNotifier,
                builder: (context, isBetaBuild, child) {
                  return SizedBox(
                    width: isMobile ? double.maxFinite : 480,
                    child: PlatformX.isIOS && isBetaBuild
                        ? Center(
                            child: Text(
                              context.tr.expired_title_ios,
                              style: (isMobile ? context.titleLarge : context.titleMedium)?.textColor(Colors.white).textBold,
                              textAlign: TextAlign.center,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isMobile ? context.tr.expired_title_mobile : context.tr.expired_title,
                                style: (isMobile ? context.titleLarge : context.titleMedium)?.textColor(Colors.white).textBold,
                              ),
                              SizedBox(height: 16),
                              Text(
                                context.tr.expired_description,
                                style: (isMobile ? context.titleMedium : context.bodyMedium)?.textColor(Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 24),
                              IntrinsicWidth(
                                child: VisirButton(
                                  type: VisirButtonAnimationType.scaleAndOpacity,
                                  style: VisirButtonStyle(
                                    cursor: SystemMouseCursors.click,
                                    backgroundColor: context.primary,
                                    borderRadius: BorderRadius.circular(isMobile ? 8 : 6),
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                                  ),
                                  onTap: () {
                                    if (isMobile) {
                                      SharePlus.instance.share(ShareParams(uri: Uri.parse(Constants.taskeyDownloadUrl)));
                                    } else {
                                      Utils.showPopupDialog(
                                        child: SubscriptionScreen(isSmall: false, isFromExpiredScreen: true),
                                        size: Size(460, 560),
                                      );
                                    }
                                  },
                                  child: Text(
                                    isMobile ? context.tr.expired_button_mobile : context.tr.expired_button,
                                    style: (isMobile ? context.titleSmall : context.bodyLarge)?.textColor(context.onPrimary),
                                  ),
                                ),
                              ),
                              SizedBox(height: 40 + (isMobile ? 0 : Constants.desktopTitleBarHeight.toDouble())),
                            ],
                          ),
                  );
                },
              ),
              Positioned(
                bottom: 0,
                child: Column(
                  children: [
                    isAppleHiddenEmail
                        ? Text(
                            context.tr.expired_you_are_logged_in_with_apple,
                            style: (isMobile ? context.titleSmall : context.bodyLarge)?.textColor(Colors.white),
                          )
                        : RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: context.tr.expired_you_are_logged_in_as,
                                  style: (isMobile ? context.titleSmall : context.bodyLarge)?.textColor(Colors.white),
                                ),
                                TextSpan(text: ' $email', style: (isMobile ? context.titleSmall : context.bodyLarge)?.textColor(Colors.white).textBold),
                              ],
                            ),
                          ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        VisirButton(
                          type: VisirButtonAnimationType.scaleAndOpacity,
                          style: VisirButtonStyle(cursor: SystemMouseCursors.click, hoverColor: Colors.transparent),
                          onTap: onPressLogout,
                          child: Text(context.tr.expired_log_out, style: (isMobile ? context.titleSmall : context.bodyLarge)?.textColor(Colors.white)),
                        ),
                        SizedBox(width: 24),
                        VisirButton(
                          type: VisirButtonAnimationType.scaleAndOpacity,
                          style: VisirButtonStyle(cursor: SystemMouseCursors.click, hoverColor: Colors.transparent),
                          onTap: onPressDeleteAccount,
                          child: Text(context.tr.expired_delete_account, style: (isMobile ? context.titleSmall : context.bodyLarge)?.textColor(Colors.white)),
                        ),
                      ],
                    ),
                    SizedBox(height: 32 + context.padding.bottom),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
