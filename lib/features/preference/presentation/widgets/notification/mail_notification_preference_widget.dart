import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/auth_image_view.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_item.dart';
import 'package:Visir/features/mail/application/mail_label_list_controller.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/application/mail_integration_list_controller.dart';
import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/preference/presentation/screens/mail_notification_filter_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MailNotificationPreferenceWidget extends ConsumerStatefulWidget {
  const MailNotificationPreferenceWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MailNotificationPreferenceWidgetState();
}

class _MailNotificationPreferenceWidgetState extends ConsumerState<MailNotificationPreferenceWidget> {
  bool get isDarkMode => context.isDarkMode;

  @override
  Widget build(BuildContext context) {
    final labelsMap = ref.watch(mailLabelListControllerProvider);
    final list = ref.watch(mailIntegrationListControllerProvider).value ?? [];

    final mailNotificationFilterLabelIds = ref.watch(localPrefControllerProvider.select((e) => e.value!.prefMailNotificationFilterLabelIds));
    final mailNotificationFilterTypes = ref.watch(localPrefControllerProvider.select((e) => e.value!.prefMailNotificationFilterTypes));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...[OAuthType.google, OAuthType.microsoft].map((type) {
          return Column(
            children: list.where((e) => e.type == type).map((e) {
              final labels = labelsMap[e.email] ?? [];
              List<String> _mailNotificationFilterLabelIds = mailNotificationFilterLabelIds[e.email] ?? [];
              List<MailLabelEntity> labelsOnFilter = labels.where((e) => _mailNotificationFilterLabelIds.contains(e.id)).toList();
              MailNotificationFilterType currentMailNotificationFilterType = mailNotificationFilterTypes[e.email] ?? MailNotificationFilterType.all;
              return VisirListItem(
                verticalMarginOverride: 8,
                verticalPaddingOverride: 0,
                titleLeadingBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) => TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: AuthImageView(oauth: e, size: 28),
                    ),
                  ],
                ),
                titleBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) => TextSpan(text: e.email, style: baseStyle),
                detailsBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) {
                  return Text(
                    '${currentMailNotificationFilterType.getDescription(context)}${currentMailNotificationFilterType == MailNotificationFilterType.withSpecificLables ? ' [${labelsOnFilter.map((e) => e.name).toList().join(',')}]' : ''}',
                    style: baseStyle,
                  );
                },
                titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
                  children: [
                    WidgetSpan(
                      child: PopupMenu(
                        location: PopupMenuLocation.bottom,
                        type: ContextMenuActionType.tap,
                        width: 180,
                        forcePopup: true,
                        popup: MailNotificationFilterScreen(oAuth: e),
                        style: VisirButtonStyle(
                          cursor: SystemMouseCursors.click,
                          padding: EdgeInsets.all(6),
                          borderRadius: BorderRadius.circular(6),
                          backgroundColor: context.surface,
                        ),
                        options: VisirButtonOptions(message: context.tr.notification_preference, tooltipLocation: VisirButtonTooltipLocation.left),
                        child: VisirIcon(type: VisirIconType.control, size: 16, isSelected: true),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
