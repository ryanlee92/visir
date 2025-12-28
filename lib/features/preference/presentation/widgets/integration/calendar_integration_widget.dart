import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/application/notification_controller.dart';
import 'package:Visir/features/calendar/application/calendar_list_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/google_api_handler.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/microsoft_api_handler.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/auth_image_view.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_item.dart';
import 'package:Visir/features/preference/application/calendar_integration_list_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension OAuthTypeCalendarX on OAuthType {
  String getCalendarOAuthTitle(BuildContext context) {
    switch (this) {
      case OAuthType.google:
        return context.tr.integration_gcal;
      case OAuthType.microsoft:
        return context.tr.integration_outlook_cal;
      default:
        return '';
    }
  }

  String get calendarOAuthAssetPath {
    switch (this) {
      case OAuthType.google:
        return '${(kDebugMode && kIsWeb) ? "" : "assets/"}logos/logo_gcal.png';
      case OAuthType.microsoft:
        return '${(kDebugMode && kIsWeb) ? "" : "assets/"}logos/logo_outlook.png';
      default:
        return '';
    }
  }
}

class CalendarIntegrationWidget extends ConsumerStatefulWidget {
  const CalendarIntegrationWidget({super.key});

  @override
  ConsumerState createState() => _CalendarIntegrationWidgetState();
}

class _CalendarIntegrationWidgetState extends ConsumerState<CalendarIntegrationWidget> {
  bool get isDarkMode => context.isDarkMode;

  Future<void> refreshCalendar() async {
    await Utils.ref.read(calendarListControllerProvider.notifier).load();
    final calendarMap = Utils.ref.read(calendarListControllerProvider);
    await Utils.ref.read(notificationControllerProvider.notifier).updateLinkedCalendar(calendarMap);
  }

  Future<void> integrate({required OAuthType type}) async {
    bool? result = await Utils.ref.read(calendarIntegrationListControllerProvider.notifier).integrate(type: type);
    if (result == true) {
      if (type == OAuthType.google) GoogleApiHandler.getConnections(ref);
      if (type == OAuthType.microsoft) MicrosoftApiHandler.getConnections(ref);
      await refreshCalendar();
      final user = ref.read(authControllerProvider).requireValue;
      logAnalyticsEvent(
        eventName: user.onTrial ? 'trial_integrate_service' : 'integrate_service',
        properties: {'service': type.getAnalyticsServiceName(isCalendar: true, isMail: false)},
      );
    }
  }

  Future<void> unintegrate({required OAuthEntity oauth, required OAuthType type}) async {
    await Utils.ref.read(calendarIntegrationListControllerProvider.notifier).unintegrate(oauth: oauth);
    await refreshCalendar();
    final user = ref.read(authControllerProvider).requireValue;
    logAnalyticsEvent(
      eventName: user.onTrial ? 'trial_disconnect_service' : 'disconnect_service',
      properties: {'service': type.getAnalyticsServiceName(isCalendar: true, isMail: false)},
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(calendarIntegrationListControllerProvider).value ?? [];
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
                      child: Image.asset(type.calendarOAuthAssetPath, width: 20, height: 20, fit: BoxFit.contain),
                    ),
                  ),
                ),
                TextSpan(text: type.getCalendarOAuthTitle(context), style: baseStyle?.appFont(context).textBold),
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
                                width: 28,
                                height: 28,
                                borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                                backgroundColor: context.error,
                              ),
                              onTap: () => integrate(type: type),
                              child: VisirIcon(type: VisirIconType.caution, size: 16, color: context.onError, isSelected: true),
                            ),
                          if (e.needReAuth == true) const SizedBox(width: 8),
                          VisirButton(
                            type: VisirButtonAnimationType.scaleAndOpacity,
                            style: VisirButtonStyle(
                              cursor: SystemMouseCursors.click,
                              width: 28,
                              height: 28,
                              borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                              backgroundColor: context.surface,
                            ),
                            options: VisirButtonOptions(message: context.tr.disconnect),
                            onTap: () => unintegrate(oauth: e, type: type),
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
      ],
    );
  }
}
