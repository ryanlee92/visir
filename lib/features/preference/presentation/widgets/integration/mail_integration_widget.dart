import 'dart:math';

import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/application/notification_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/google_api_handler.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/microsoft_api_handler.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/auth_image_view.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_item.dart';
import 'package:Visir/features/inbox/application/inbox_controller.dart';
import 'package:Visir/features/mail/application/mail_label_list_controller.dart';
import 'package:Visir/features/mail/application/mail_list_controller.dart';
import 'package:Visir/features/mail/domain/entities/mail_signature_entity.dart';
import 'package:Visir/features/preference/application/mail_integration_list_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/preference/presentation/screens/mail_pref_filter_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension OAuthTypeMailX on OAuthType {
  String getMailOAuthTitle(BuildContext context) {
    switch (this) {
      case OAuthType.google:
        return context.tr.integration_gmail;
      case OAuthType.microsoft:
        return context.tr.integration_outlook;
      default:
        return '';
    }
  }

  String get mailOAuthAssetPath {
    switch (this) {
      case OAuthType.google:
        return '${(kDebugMode && kIsWeb) ? "" : "assets/"}logos/logo_gmail.png';
      case OAuthType.microsoft:
        return '${(kDebugMode && kIsWeb) ? "" : "assets/"}logos/logo_outlook.png';
      default:
        return '';
    }
  }
}

class MailIntegrationWidget extends ConsumerStatefulWidget {
  const MailIntegrationWidget({super.key});

  @override
  ConsumerState createState() => _MailIntegrationWidgetState();
}

class _MailIntegrationWidgetState extends ConsumerState<MailIntegrationWidget> {
  OAuthType? loadingType;
  bool get isDarkMode => context.isDarkMode;

  String? lastIntegratedEmail;

  List<Color> accountColors = [
    Colors.red,
    Colors.orange,
    Colors.lightGreen,
    Colors.teal,
    Colors.indigo,
    Colors.purple,
    Colors.deepOrange,
    Colors.yellow,
    Colors.green,
    Colors.lightBlue,
    Colors.deepPurple,
    Colors.brown,
  ];

  Future<void> refreshMail() async {
    final refreshInbox = Utils.ref.read(inboxControllerProvider.notifier).refresh();
    await Future.wait(
      [Utils.ref.read(mailListControllerProvider.notifier).refresh(), refreshInbox].whereType<Future>(),
    );
    Utils.ref.read(mailLabelListControllerProvider.notifier).load();
  }

  Future<void> integrate({required OAuthType type}) async {
    loadingType = type;
    setState(() {});

    final oauth = await Utils.ref.read(mailIntegrationListControllerProvider.notifier).integrate(type: type);
    if (oauth == null) {
      loadingType = null;
      setState(() {});
      return;
    }

    switch (type) {
      case OAuthType.google:
        GoogleApiHandler.getConnections(ref);
        await Utils.ref.read(notificationControllerProvider.notifier).updateLinkedGmail();
        break;
      case OAuthType.microsoft:
        MicrosoftApiHandler.getConnections(ref);
        await Utils.ref.read(notificationControllerProvider.notifier).updateLinkedMsMail();
        break;
      default:
        break;
    }

    final email = oauth.email;

    final user = Utils.ref.read(authControllerProvider).requireValue;
    if (!user.isSignedIn) {
      loadingType = null;
      setState(() {});
      return;
    }

    setState(() {
      lastIntegratedEmail = email;
    });

    final mailColors = {...user.userMailColors};
    if (mailColors[email] == null) {
      int i = 0;

      while (mailColors.values.contains(accountColors[i].toHex())) {
        i = (i + 1) % accountColors.length;
        if (i == 0) break;
      }

      mailColors[email] = accountColors[i].toHex();
    }

    final signatures = await Utils.ref.read(mailIntegrationListControllerProvider.notifier).fetchSignature(oauth: oauth);
    List<MailSignatureEntity> mailSignatures = [...user.userMailSignatures];

    signatures.forEach((s) {
      if (mailSignatures.where((m) => m.signature == s).isEmpty) {
        int number = mailSignatures.length == 0
            ? 0
            : mailSignatures.length == 1
            ? mailSignatures.first.number + 1
            : mailSignatures.map((m) => m.number).reduce(max) + 1;
        mailSignatures.add(MailSignatureEntity(number: number, signature: s));
      }
    });

    await Utils.ref
        .read(authControllerProvider.notifier)
        .updateUser(
          user: user.copyWith(mailColors: mailColors, mailSignatures: mailSignatures),
        );

    await refreshMail();

    if (mounted) {
      loadingType = null;
      setState(() {});
    }
  }

  Future<void> unintegrate({required OAuthEntity oauth}) async {
    final oauths = await Utils.ref.read(mailIntegrationListControllerProvider.notifier).unintegrate(oauth: oauth);
    if (oauths == null) return;
    await Utils.ref.read(notificationControllerProvider.notifier).updateLinkedGmail();
    await refreshMail();
    final user = ref.read(authControllerProvider).requireValue;
    logAnalyticsEvent(
      eventName: user.onTrial ? 'trial_disconnect_service' : 'disconnect_service',
      properties: {'service': oauth.type.getAnalyticsServiceName(isCalendar: false, isMail: true)},
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(mailIntegrationListControllerProvider).value ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...[OAuthType.google, OAuthType.microsoft].map(
          (type) => VisirListItem(
            titleBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) => TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    width: 28,
                    height: 28,
                    margin: EdgeInsets.only(right: horizontalSpacing * 2),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                      alignment: Alignment.center,
                      child: Image.asset(type.mailOAuthAssetPath, width: 20, height: 20, fit: BoxFit.contain),
                    ),
                  ),
                ),
                TextSpan(text: type.getMailOAuthTitle(context), style: baseStyle?.appFont(context).textBold),
              ],
            ),
            titleTrailingBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) => TextSpan(
              children: [
                WidgetSpan(
                  child: VisirButton(
                    type: VisirButtonAnimationType.scaleAndOpacity,
                    style: VisirButtonStyle(
                      height: height + 12,
                      padding: EdgeInsets.symmetric(horizontal: horizontalSpacing * 2),
                      backgroundColor: context.primary,
                      borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                    ),
                    onTap: () async {
                      await integrate(type: type);
                    },
                    child: Text(context.tr.integration_connect, style: baseStyle?.textColor(context.onPrimary)),
                  ),
                ),
              ],
            ),
            detailsBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) {
              return Padding(
                padding: EdgeInsets.only(left: 4),
                child: Column(
                  children: list.where((e) => e.type == type).map((e) {
                    return Container(
                      padding: EdgeInsets.only(bottom: verticalSpacing),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          AuthImageView(oauth: e, size: 24),
                          SizedBox(width: horizontalSpacing * 2),
                          Expanded(child: Text(e.email, style: baseStyle?.textColor(context.outlineVariant))),
                          SizedBox(width: horizontalSpacing),
                          if (e.needReAuth == true)
                            VisirButton(
                              type: VisirButtonAnimationType.scaleAndOpacity,
                              style: VisirButtonStyle(
                                cursor: SystemMouseCursors.click,
                                borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                                width: 28,
                                height: 28,
                                backgroundColor: context.error,
                              ),
                              onTap: () => integrate(type: type),
                              child: VisirIcon(type: VisirIconType.caution, size: 16, color: context.onError, isSelected: true),
                            ),
                          if (e.needReAuth != true)
                            PopupMenu(
                              type: ContextMenuActionType.tap,
                              forcePopup: true,
                              location: PopupMenuLocation.bottom,
                              popup: MailPrefFilterScreen(oAuth: e),
                              width: 200,
                              style: VisirButtonStyle(
                                cursor: SystemMouseCursors.click,
                                borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                                backgroundColor: context.surface,
                                width: 28,
                                height: 28,
                              ),
                              options: VisirButtonOptions(message: context.tr.inbox_filter),
                              child: VisirIcon(type: VisirIconType.control, size: 16, isSelected: true),
                            ),
                          SizedBox(width: horizontalSpacing),
                          VisirButton(
                            type: VisirButtonAnimationType.scaleAndOpacity,
                            style: VisirButtonStyle(
                              cursor: SystemMouseCursors.click,
                              borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                              backgroundColor: context.surface,
                              width: 28,
                              height: 28,
                            ),
                            options: VisirButtonOptions(message: context.tr.disconnect),
                            onTap: () => unintegrate(oauth: e),
                            child: VisirIcon(type: VisirIconType.trash, size: 16, isSelected: true),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
