import 'dart:developer' as developer;

import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/features/common/presentation/widgets/fgbg_detector.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmailConfirmScreen extends ConsumerStatefulWidget {
  final String email;
  final String password;

  static const String routeName = 'confirm';
  static const String routePath = 'confirm';

  const EmailConfirmScreen({super.key, required this.email, required this.password});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EmailConfirmScreenState();
}

class _EmailConfirmScreenState extends ConsumerState<EmailConfirmScreen> {
  bool get isMobileView => PlatformX.isMobileView;

  bool onLogin = false;

  Future<void> singInWithEmail() async {
    if (onLogin) return;

    setState(() {
      onLogin = true;
    });

    try {
      await Supabase.instance.client.auth.signInWithPassword(email: widget.email, password: widget.password);
      await ref.read(authControllerProvider.notifier).onSignInSuccess();
      logAnalyticsEvent(eventName: 'signup_email_confirm_success');
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      developer.log(e.toString());
    }

    setState(() {
      onLogin = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FGBGDetector(
      onChanged: (isForeground, isFirst) {
        if (!isForeground) return;
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          singInWithEmail();
        });
      },
      child: Material(
        color: context.background,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomCircularLoadingIndicator(size: 40),
              const SizedBox(height: 24),
              Text(context.tr.onboarding_waiting_for_confirm_email, style: context.titleSmall?.textColor(context.outlineVariant)),
              const SizedBox(height: 24),
              Padding(
                padding: isMobileView ? EdgeInsets.symmetric(horizontal: 16) : EdgeInsets.zero,
                child: VisirButton(
                  type: VisirButtonAnimationType.scaleAndOpacity,
                  style: VisirButtonStyle(
                    height: 48,
                    width: isMobileView ? null : 360,
                    backgroundColor: context.secondary,
                    borderRadius: BorderRadius.circular(12),
                    alignment: Alignment.center,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    logAnalyticsEvent(eventName: 'signup_email_confirm_return_options');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text(context.tr.onboarding_return_to_login_options, style: context.titleSmall?.textColor(context.outlineVariant))],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
