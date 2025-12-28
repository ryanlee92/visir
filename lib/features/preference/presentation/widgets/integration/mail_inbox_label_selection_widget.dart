// ignore_for_file: unnecessary_null_comparison

import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/mail/application/mail_label_list_controller.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MailInboxLabelSelectionWidget extends ConsumerStatefulWidget {
  final OAuthEntity oAuth;

  const MailInboxLabelSelectionWidget({super.key, required this.oAuth});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MailInboxLabelSelectionWidgetState();
}

class _MailInboxLabelSelectionWidgetState extends ConsumerState<MailInboxLabelSelectionWidget> {
  OAuthEntity get oAuth => widget.oAuth;

  @override
  Widget build(BuildContext context) {
    final labels =
        ref.watch(
          mailLabelListControllerProvider.select(
            (v) => v[oAuth.email]?.where((e) => e.id != CommonMailLabels.draft.id && !mailPrefExcludeLabelIds.contains(e.id)).toList(),
          ),
        ) ??
        [];
    final mailInboxFilterLabelIds = ref.watch(authControllerProvider.select((v) => v.requireValue.userMilInboxFilterLabelIds[oAuth.email] ?? []));

    labels.sort((a, b) => mailInboxFilterLabelIds.contains(a.id) ? -1 : 1);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          for (MailLabelEntity label in labels)
            VisirButton(
              type: VisirButtonAnimationType.scaleAndOpacity,
              style: VisirButtonStyle(cursor: SystemMouseCursors.click, backgroundColor: Colors.transparent, height: 40),
              onTap: () async {
                final user = ref.read(authControllerProvider).requireValue;
                if (label.id == null) return;

                List<String> newLabelIds = [...mailInboxFilterLabelIds];
                if (mailInboxFilterLabelIds.contains(label.id)) {
                  newLabelIds.remove(label.id);
                } else {
                  newLabelIds.add(label.id!);
                }
                Map<String, List<String>> newMailInboxFilterLabelIds = Map.from(user.userMilInboxFilterLabelIds);
                newMailInboxFilterLabelIds[oAuth.email] = newLabelIds;

                await ref.read(authControllerProvider.notifier).updateUser(user: user.copyWith(mailInboxFilterLabelIds: newMailInboxFilterLabelIds));
              },
              child: Row(
                children: [
                  SizedBox(width: 12),
                  Container(
                    width: 16,
                    height: 16,
                    margin: EdgeInsets.only(right: 10),
                    decoration: ShapeDecoration(
                      color: mailInboxFilterLabelIds.contains(label.id) ? context.primary : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1, color: mailInboxFilterLabelIds.contains(label.id) ? context.primary : context.inverseSurface),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: mailInboxFilterLabelIds.contains(label.id) ? VisirIcon(type: VisirIconType.check, size: 12) : null,
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
    );
  }
}
