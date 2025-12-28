import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/selection_widget.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/mail/application/mail_label_list_controller.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/preference/presentation/widgets/integration/mail_inbox_label_selection_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MailPrefFilterScreen extends ConsumerStatefulWidget {
  final OAuthEntity oAuth;

  const MailPrefFilterScreen({super.key, required this.oAuth});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MailPrefFilterScreenState();
}

class _MailPrefFilterScreenState extends ConsumerState<MailPrefFilterScreen> {
  bool get isMobileView => PlatformX.isMobileView;

  OAuthEntity get oAuth => widget.oAuth;

  @override
  Widget build(BuildContext context) {
    final labelsMap = ref.watch(mailLabelListControllerProvider);
    final labels = labelsMap[oAuth.email] ?? [];
    labels.removeWhere((e) => mailPrefExcludeLabelIds.contains(e.id));

    final mailInboxFilterLabelIds = ref.watch(authControllerProvider.select((e) => e.requireValue.userMilInboxFilterLabelIds[oAuth.email])) ?? [];
    final labelsOnFilter = labels.where((e) => mailInboxFilterLabelIds.contains(e.id)).toList();
    final currentMailInboxFilterType =
        ref.watch(authControllerProvider.select((e) => e.requireValue.userMailInboxFilterTypes[oAuth.email])) ?? MailInboxFilterType.all;
    final mailInboxFilterTypes = List<MailInboxFilterType>.from(MailInboxFilterType.values);
    if (labels.isEmpty) mailInboxFilterTypes.remove(MailInboxFilterType.withSpecificLables);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text(context.tr.mail_pref_filter_inbox_filter, style: context.titleSmall?.textBold.textColor(context.outlineVariant)),
          ),
          SizedBox(height: 6),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text(context.tr.mail_pref_filter_inbox_filter_description, style: context.labelMedium?.textColor(context.inverseSurface)),
          ),
          Padding(
            padding: EdgeInsets.only(top: 6),
            child: Container(
              height: 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
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
                        popup: SelectionWidget<MailInboxFilterType>(
                          current: currentMailInboxFilterType,
                          items: mailInboxFilterTypes,
                          getTitle: (item) => item.getTitle(context),
                          onSelect: (mailInboxFilterType) async {
                            final user = ref.read(authControllerProvider).requireValue;
                            Map<String, MailInboxFilterType> newMailInboxFilterTypes = Map.from(user.userMailInboxFilterTypes);
                            newMailInboxFilterTypes[oAuth.email] = mailInboxFilterType;
                            await ref.read(authControllerProvider.notifier).updateUser(user: user.copyWith(mailInboxFilterTypes: newMailInboxFilterTypes));
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
                                currentMailInboxFilterType.getTitle(context),
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
          if (currentMailInboxFilterType == MailInboxFilterType.withSpecificLables)
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: Container(
                height: 32,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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
                          popup: MailInboxLabelSelectionWidget(oAuth: oAuth),
                          style: VisirButtonStyle(
                            height: 32,
                            constraints: BoxConstraints(maxWidth: 180),
                            backgroundColor: context.surface,
                            borderRadius: BorderRadius.circular(6),
                            padding: EdgeInsets.only(left: 10, right: 6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  labelsOnFilter.isEmpty
                                      ? context.tr.mail_pref_filter_none
                                      : labelsOnFilter.length > 1
                                      ? '${context.tr.n_selected(labelsOnFilter.length)}'
                                      : labelsOnFilter.first.name!,
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
