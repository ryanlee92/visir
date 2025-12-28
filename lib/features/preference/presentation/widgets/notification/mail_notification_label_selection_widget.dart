import 'package:Visir/features/auth/application/notification_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/mail/application/mail_label_list_controller.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MailNotificationLabelSelectionWidget extends ConsumerStatefulWidget {
  final OAuthEntity oAuth;

  const MailNotificationLabelSelectionWidget({super.key, required this.oAuth});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MailNotificationLabelSelectionWidgetState();
}

class _MailNotificationLabelSelectionWidgetState extends ConsumerState<MailNotificationLabelSelectionWidget> {
  OAuthEntity get oAuth => widget.oAuth;

  @override
  Widget build(BuildContext context) {
    final labelsMap = ref.watch(mailLabelListControllerProvider);
    final labels = labelsMap[oAuth.email] ?? [];
    labels.removeWhere((e) => mailPrefExcludeLabelIds.contains(e.rawId));

    List<String> mailNotificationFilterLabelIds =
        ref.watch(localPrefControllerProvider.select((e) => e.value!.prefMailNotificationFilterLabelIds[oAuth.email])) ?? [];

    return Container(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            for (MailLabelEntity label in labels)
              VisirButton(
                type: VisirButtonAnimationType.scaleAndOpacity,
                onTap: () async {
                  final pref = ref.read(localPrefControllerProvider).value;
                  if (pref == null) return;
                  if (label.rawId == null) return;
                  List<String> newLabelIds = [...mailNotificationFilterLabelIds];
                  if (mailNotificationFilterLabelIds.contains(label.rawId)) {
                    newLabelIds.remove(label.rawId);
                  } else {
                    newLabelIds.add(label.rawId!);
                  }
                  Map<String, List<String>> newMailNotificationFilterLabelIds = Map.from(pref.prefMailNotificationFilterLabelIds);
                  newMailNotificationFilterLabelIds[oAuth.email] = newLabelIds;

                  await ref.read(localPrefControllerProvider.notifier).set(mailNotificationFilterLabelIds: newMailNotificationFilterLabelIds);
                  if (oAuth.type == OAuthType.google) {
                    await ref.read(notificationControllerProvider.notifier).updateLinkedGmail();
                  } else if (oAuth.type == OAuthType.microsoft) {
                    await ref.read(notificationControllerProvider.notifier).updateLinkedMsMail();
                  }
                },
                style: VisirButtonStyle(height: 40, backgroundColor: Colors.transparent),
                child: Row(
                  children: [
                    SizedBox(width: 12),
                    Container(
                      width: 16,
                      height: 16,
                      margin: EdgeInsets.only(right: 10),
                      decoration: ShapeDecoration(
                        color: mailNotificationFilterLabelIds.contains(label.rawId) ? context.primary : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: mailNotificationFilterLabelIds.contains(label.rawId) ? context.primary : context.inverseSurface),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: mailNotificationFilterLabelIds.contains(label.rawId) ? VisirIcon(type: VisirIconType.check, size: 12) : null,
                    ),
                    Expanded(
                      child: Text(label.name ?? '', style: context.bodyLarge!.textColor(context.outlineVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    SizedBox(width: 12),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
