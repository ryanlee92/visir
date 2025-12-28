import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/mail/actions.dart';
import 'package:Visir/features/mail/application/mail_draft_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MailDraftList extends ConsumerStatefulWidget {
  @override
  _MailDraftListState createState() => _MailDraftListState();
}

class _MailDraftListState extends ConsumerState<MailDraftList> {
  @override
  Widget build(BuildContext context) {
    final drafts = ref.watch(mailDraftListControllerProvider).value ?? [];

    if (drafts.isEmpty) return SizedBox.shrink();
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 200),
      child: ClipRRect(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: drafts.map((d) {
              return Container(
                height: 40,
                width: 240,
                decoration: BoxDecoration(
                  color: context.surface,
                  border: drafts.lastOrNull == d ? null : Border(bottom: BorderSide(color: context.outline)),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 6),
                    VisirButton(
                      type: VisirButtonAnimationType.scaleAndOpacity,
                      onTap: () {
                        MailAction.removeDraftFromPreview(mail: d);
                      },
                      style: VisirButtonStyle(padding: EdgeInsets.all(6), borderRadius: BorderRadius.circular(4), width: 28, height: 28),
                      child: VisirIcon(type: VisirIconType.close, size: 16, color: context.onBackground),
                    ),
                    Expanded(
                      child: VisirButton(
                        type: VisirButtonAnimationType.scale,
                        style: VisirButtonStyle(hoverColor: Colors.transparent),
                        onTap: () => MailAction.openDraft(mail: d, fromDraftBanner: true),
                        child: Row(
                          children: [
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                d.draftSubject ?? (d.subject?.isNotEmpty == true ? d.subject! : context.tr.mail_new_message),
                                style: context.titleSmall?.textColor(context.onBackground),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 6),
                            Container(
                              padding: EdgeInsets.all(6),
                              child: VisirIcon(type: VisirIconType.outlink, size: 16, color: context.onBackground),
                            ),
                            SizedBox(width: 6),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
