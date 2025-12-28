import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/dependency/html_editor/html_editor.dart';
import 'package:Visir/dependency/master_detail_flow/src/details_item.dart';
import 'package:Visir/dependency/modal_bottom_sheet/src/utils/modal_scroll_controller.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/selection_widget.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_item.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_section.dart';
import 'package:Visir/features/mail/domain/entities/mail_signature_entity.dart';
import 'package:Visir/features/mail/presentation/widgets/html_content_viewer_widget.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/presentation/screens/mail_signature_edit_screen.dart';
import 'package:Visir/features/preference/presentation/screens/preference_screen.dart';
import 'package:Visir/features/preference/presentation/widgets/mail_color_picker_widget.dart';
import 'package:Visir/features/preference/presentation/widgets/notification/mail_inbox_filter_preference_widget.dart';
import 'package:Visir/features/preference/presentation/widgets/notification/mail_notification_preference_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MailPrefScreen extends ConsumerStatefulWidget {
  final bool isSmall;
  final VoidCallback? onClose;

  const MailPrefScreen({super.key, required this.isSmall, this.onClose});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MailPrefScreenState();
}

class _MailPrefScreenState extends ConsumerState<MailPrefScreen> {
  int? selectedSignautre;

  HtmlEditorController? signatureController;

  ScrollController? _scrollController;

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    widget.onClose?.call();
    super.dispose();
  }

  void updateSignature(String html) {
    final user = ref.read(authControllerProvider).requireValue;
    List<MailSignatureEntity> mailSignatures = [...user.userMailSignatures]
        .map((e) {
          if (e.number == selectedSignautre) return e.copyWith(signature: html);
          return e;
        })
        .whereType<MailSignatureEntity>()
        .toList();
    ref.read(authControllerProvider.notifier).updateUser(user: user.copyWith(mailSignatures: mailSignatures));
  }

  @override
  Widget build(BuildContext context) {
    _scrollController ??= ModalScrollController.ofSyncGroup(context)?.addAndGet() ?? ScrollController();
    bool isMobileView = PlatformX.isMobileView;
    List<String> emails = ref.watch(localPrefControllerProvider.select((e) => e.value?.mailOAuths?.map((e) => e.email).toList())) ?? [];

    final mailColors = ref.watch(authControllerProvider.select((e) => e.requireValue.userMailColors));
    final signatures = ref.watch(authControllerProvider.select((e) => e.requireValue.userMailSignatures));
    final defaultSignatures = ref.watch(authControllerProvider.select((e) => e.requireValue.userDefaultSignatures));
    final mailContentThemeType = ref.watch(authControllerProvider.select((e) => e.requireValue.userMailContentThemeType));
    final mailSwipeLeftActionType = ref.watch(authControllerProvider.select((e) => e.requireValue.userMailSwipeLeftActionType));

    final buttonWidth = PreferenceScreen.buttonWidth;
    final buttonHeight = PreferenceScreen.buttonHeight;
    return LayoutBuilder(
      builder: (context, constraints) {
        return DetailsItem(
          title: widget.isSmall ? context.tr.mail_pref_title : null,
          hideBackButton: !widget.isSmall,
          scrollController: _scrollController,
          scrollPhysics: Utils.getScrollPhysicsForBottomSheet(context, _scrollController),
          appbarColor: context.background,
          bodyColor: context.background,
          children: [
            VisirListSection(
              removeTopMargin: true,
              titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.mail_pref_appearance, style: baseStyle),
            ),

            VisirListItem(
              verticalPaddingOverride: 0,
              titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.mail_pref_email_content_theme, style: baseStyle),
              titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
                children: [
                  WidgetSpan(
                    child: PopupMenu(
                      forcePopup: true,
                      location: PopupMenuLocation.bottom,
                      width: buttonWidth,
                      borderRadius: 6,
                      type: ContextMenuActionType.tap,
                      popup: SelectionWidget<MailContentThemeType>(
                        current: mailContentThemeType,
                        items: MailContentThemeType.values,
                        getTitle: (mailContentThemeType) => mailContentThemeType.getTitle(context),
                        onSelect: (mailContentThemeType) async {
                          final user = ref.read(authControllerProvider).requireValue;
                          await ref.read(authControllerProvider.notifier).updateUser(user: user.copyWith(mailContentThemeType: mailContentThemeType));
                        },
                      ),
                      style: VisirButtonStyle(
                        width: buttonWidth,
                        height: buttonHeight,
                        backgroundColor: context.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 12),
                          Expanded(child: Text(mailContentThemeType.getTitle(context), style: context.bodyMedium?.textColor(context.outlineVariant))),
                          SizedBox(width: 6),
                          VisirIcon(type: VisirIconType.arrowDown, size: 12, color: context.outlineVariant),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            VisirListSection(
              titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.mail_pref_account_color, style: baseStyle),
            ),

            ...emails.map(
              (email) => VisirListItem(
                verticalPaddingOverride: 0,
                titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: email, style: baseStyle),
                titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
                  children: [
                    WidgetSpan(
                      child: PopupMenu(
                        forcePopup: true,
                        location: PopupMenuLocation.bottom,
                        width: buttonWidth + 40,
                        borderRadius: 6,
                        type: ContextMenuActionType.tap,
                        popup: MailColorPickerWidget(email: email),
                        style: VisirButtonStyle(
                          width: buttonWidth,
                          height: buttonHeight,
                          backgroundColor: context.surface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 12),
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: mailColors[email] != null ? ColorX.fromHex(mailColors[email]!) : Colors.transparent,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(Utils.getColorString(context, mailColors[email]), style: context.bodyMedium?.textColor(context.outlineVariant)),
                            ),
                            SizedBox(width: 6),
                            VisirIcon(type: VisirIconType.arrowDown, size: 12, color: context.outlineVariant),
                            SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            VisirListSection(
              titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.mail_pref_signature_list, style: baseStyle),
              titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
                children: [
                  WidgetSpan(
                    child: VisirButton(
                      type: VisirButtonAnimationType.scaleAndOpacity,
                      style: VisirButtonStyle(
                        width: buttonWidth,
                        height: buttonHeight,
                        backgroundColor: context.surface,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      onTap: () => Utils.showPopupDialog(context: context, size: Size(500, 600), child: MailSignatureEditScreen(signature: null)),
                      child: Row(
                        children: [
                          SizedBox(width: 12),
                          Expanded(child: Text(context.tr.create_signautre, style: context.bodyMedium?.textColor(context.outlineVariant))),
                          SizedBox(width: 6),
                          VisirIcon(type: VisirIconType.add, size: 12, color: context.outlineVariant),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            ...signatures.map(
              (signature) => VisirListItem(
                titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) =>
                    TextSpan(text: context.tr.mail_pref_signature_number(signature.number + 1), style: baseStyle),
                titleTrailingBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) => TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: VisirIcon(type: VisirIconType.arrowRight, size: 16, color: context.outlineVariant),
                    ),
                  ],
                ),
                detailsBuilder: (height, baseStyle, verticalSpacing, horizontalSpacing) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(6)),
                    child: HtmlContentViewer(
                      contentHtml: signature.signature,
                      isDarkTheme: context.isDarkMode,
                      isMobileView: isMobileView,
                      close: false,
                      initialWidth: constraints.maxWidth,
                      maxHeight: 300,
                      scrollController: ScrollController(),
                      syncKey: GlobalKey(),
                      tabType: tabNotifier.value,
                    ),
                  );
                },
                onTap: () {
                  Utils.showPopupDialog(
                    context: context,
                    size: Size(500, 600),
                    child: MailSignatureEditScreen(signature: signature),
                  );
                },
              ),
            ),

            VisirListSection(
              titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.mail_pref_default_signature, style: baseStyle),
            ),

            ...emails.map(
              (email) => VisirListItem(
                verticalPaddingOverride: 0,
                titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: email, style: baseStyle),
                titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
                  children: [
                    WidgetSpan(
                      child: PopupMenu(
                        forcePopup: true,
                        location: PopupMenuLocation.bottom,
                        width: buttonWidth,
                        borderRadius: 6,
                        type: ContextMenuActionType.tap,
                        popup: SelectionWidget<int>(
                          current: defaultSignatures[email] != null && signatures.map((e) => e.number).contains(defaultSignatures[email])
                              ? defaultSignatures[email]!
                              : -1,
                          items: [-1, ...signatures.map((e) => e.number)],
                          getTitle: (item) => item == -1 ? context.tr.mail_pref_signature_none : context.tr.mail_pref_signature_number(item + 1),
                          onSelect: (item) async {
                            final user = ref.read(authControllerProvider).requireValue;
                            Map<String, int> defaultSignatures = {...user.userDefaultSignatures};
                            if (item == -1) {
                              defaultSignatures.remove(email);
                            } else {
                              defaultSignatures[email] = item;
                            }

                            await ref.read(authControllerProvider.notifier).updateUser(user: user.copyWith(defaultSignatures: defaultSignatures));
                          },
                        ),
                        style: VisirButtonStyle(
                          width: buttonWidth,
                          height: buttonHeight,
                          backgroundColor: context.surface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 12),
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  final number = defaultSignatures[email] != null && signatures.map((e) => e.number).contains(defaultSignatures[email])
                                      ? defaultSignatures[email]!
                                      : -1;
                                  return Text(
                                    number == -1 ? context.tr.mail_pref_signature_none : context.tr.mail_pref_signature_number(number + 1),
                                    style: context.bodyMedium?.textColor(context.outlineVariant),
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 6),
                            VisirIcon(type: VisirIconType.arrowDown, size: 12, color: context.outlineVariant),
                            SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (isMobileView) ...[
              VisirListSection(
                titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.mail_pref_swipe_actions, style: baseStyle),
              ),

              VisirListItem(
                verticalPaddingOverride: 0,
                titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.mail_pref_swipe_left, style: baseStyle),
                titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
                  children: [
                    WidgetSpan(
                      child: PopupMenu(
                        forcePopup: true,
                        location: PopupMenuLocation.bottom,
                        width: buttonWidth,
                        borderRadius: 6,
                        type: ContextMenuActionType.tap,
                        popup: SelectionWidget<MailPrefSwipeActionType>(
                          current: mailSwipeLeftActionType,
                          items: MailPrefSwipeActionType.values,
                          getTitle: (mailSwipeLeftActionType) => mailSwipeLeftActionType.getTitle(context),
                          onSelect: (mailSwipeLeftActionType) async {
                            final user = ref.read(authControllerProvider).requireValue;
                            await ref.read(authControllerProvider.notifier).updateUser(user: user.copyWith(mailSwipeLeftActionType: mailSwipeLeftActionType));
                          },
                        ),
                        style: VisirButtonStyle(
                          width: buttonWidth,
                          height: buttonHeight,
                          backgroundColor: context.surface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 12),
                            Expanded(child: Text(mailSwipeLeftActionType.getTitle(context), style: context.bodyMedium?.textColor(context.outlineVariant))),
                            SizedBox(width: 6),
                            VisirIcon(type: VisirIconType.arrowDown, size: 12, color: context.outlineVariant),
                            SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            VisirListSection(
              titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.mail_pref_filter_inbox_filter, style: baseStyle),
            ),

            MailInboxFilterPreferenceWidget(),

            VisirListSection(
              titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.notification_pref_title, style: baseStyle),
            ),

            MailNotificationPreferenceWidget(),
          ],
        );
      },
    );
  }
}
