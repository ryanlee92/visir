import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/features/auth/application/notification_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/selection_widget.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/mail/application/mail_label_list_controller.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/preference/presentation/widgets/notification/mail_notification_label_selection_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MailNotificationFilterScreen extends ConsumerStatefulWidget {
  final OAuthEntity oAuth;

  const MailNotificationFilterScreen({super.key, required this.oAuth});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MailNotificationFilterScreenState();
}

class _MailNotificationFilterScreenState extends ConsumerState<MailNotificationFilterScreen> {
  OAuthEntity get oAuth => widget.oAuth;

  bool get isMobileView => PlatformX.isMobileView;

  @override
  Widget build(BuildContext context) {
    final labelsMap = ref.watch(mailLabelListControllerProvider);
    final labels = labelsMap[oAuth.email] ?? [];
    labels.removeWhere((e) => mailPrefExcludeLabelIds.contains(e.id));

    final mailNotificationFilterLabelIds = ref.watch(localPrefControllerProvider.select((e) => e.value!.prefMailNotificationFilterLabelIds[oAuth.email])) ?? [];
    final labelsOnFilter = labels.where((e) => mailNotificationFilterLabelIds.contains(e.id)).toList();

    final currentMailNotificationFilterType =
        ref.watch(localPrefControllerProvider.select((e) => e.value!.prefMailNotificationFilterTypes[oAuth.email])) ?? MailNotificationFilterType.all;
    final mailNotificationFilterType = List<MailNotificationFilterType>.from(MailNotificationFilterType.values);
    if (labels.isEmpty) mailNotificationFilterType.remove(MailNotificationFilterType.withSpecificLables);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text(context.tr.notification_mails_notifications, style: context.titleSmall?.textBold.textColor(context.outlineVariant)),
          ),
          SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text(context.tr.notification_mail_description, style: context.labelMedium?.textColor(context.inverseSurface)),
          ),
          Padding(
            padding: EdgeInsets.only(top: 6),
            child: Container(
              height: 32,
              child: Row(
                children: [
                  SizedBox(width: 8),
                  Text(context.tr.mail_pref_filter_mails, style: context.bodyLarge?.textColor(context.outlineVariant)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: PopupMenu(
                        forcePopup: true,
                        location: PopupMenuLocation.bottom,
                        width: 180,
                        borderRadius: 6,
                        type: ContextMenuActionType.tap,
                        popup: SelectionWidget<MailNotificationFilterType>(
                          current: currentMailNotificationFilterType,
                          items: mailNotificationFilterType,
                          getTitle: (item) => item.getTitle(context),
                          onSelect: (mailNotificationFilterType) async {
                            final pref = ref.read(localPrefControllerProvider).value;
                            if (pref == null) return;
                            Map<String, MailNotificationFilterType> newMailNotificationFilterTypes = Map.from(pref.prefMailNotificationFilterTypes);
                            newMailNotificationFilterTypes[oAuth.email] = mailNotificationFilterType;
                            await ref.read(localPrefControllerProvider.notifier).set(mailNotificationFilterTypes: newMailNotificationFilterTypes);
                            if (oAuth.type == OAuthType.google) {
                              await ref.read(notificationControllerProvider.notifier).updateLinkedGmail();
                            } else if (oAuth.type == OAuthType.microsoft) {
                              await ref.read(notificationControllerProvider.notifier).updateLinkedMsMail();
                            }
                          },
                        ),
                        style: VisirButtonStyle(
                          height: 32,
                          backgroundColor: context.surface,
                          borderRadius: BorderRadius.circular(6),
                          padding: EdgeInsets.only(left: 10, right: 6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                currentMailNotificationFilterType.getTitle(context),
                                style: context.bodyMedium?.textColor(context.outlineVariant),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 6),
                            VisirIcon(type: VisirIconType.arrowDown, size: 12, color: context.outlineVariant),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (currentMailNotificationFilterType == MailNotificationFilterType.withSpecificLables)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Container(
                height: 32,
                child: Row(
                  children: [
                    SizedBox(width: 8),
                    Text(context.tr.mail_pref_filter_labels, style: context.bodyLarge?.textColor(context.outlineVariant)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: PopupMenu(
                          forcePopup: true,
                          location: PopupMenuLocation.bottom,
                          width: 180,
                          borderRadius: 6,
                          type: ContextMenuActionType.tap,
                          popup: Container(
                            constraints: BoxConstraints(maxHeight: 230, minHeight: 0),
                            child: SingleChildScrollView(child: MailNotificationLabelSelectionWidget(oAuth: oAuth)),
                          ),
                          style: VisirButtonStyle(
                            height: 32,
                            constraints: BoxConstraints(maxWidth: 180),
                            backgroundColor: context.surface,
                            borderRadius: BorderRadius.circular(6),
                            padding: EdgeInsets.only(left: 10, right: 6),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  labelsOnFilter.isEmpty
                                      ? context.tr.mail_pref_filter_none
                                      : labelsOnFilter.length > 1
                                      ? '${context.tr.n_selected(labelsOnFilter.length)}'
                                      : labelsOnFilter.map((e) => e.name).toList().join(','),
                                  style: context.bodyMedium?.textColor(context.outlineVariant),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 6),
                              VisirIcon(type: VisirIconType.arrowDown, size: 12, color: context.outlineVariant),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: 6),
        ],
      ),
    );
  }
}
