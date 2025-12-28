import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/admin_scaffold/admin_scaffold.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/mail/application/mail_label_list_controller.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/mail/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class MailSideBar extends SideBar {
  final TabType tabType;
  const MailSideBar({super.key, required this.tabType})
    : super(
        selectedRoute: '',
        activeBackgroundColor: Colors.transparent,
        hoverBackgroundColor: Colors.transparent,
        tabType: tabType,
        items: const <AdminMenuItem>[],
      );

  @override
  _MailSideBarState createState() => _MailSideBarState();
}

class _MailSideBarState extends SideBarState {
  bool get isDarkMode => context.isDarkMode;

  @override
  void initState() {
    super.initState();
    if (widget.drawerCallback != null) {
      widget.drawerCallback!(true);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.drawerCallback != null) {
      widget.drawerCallback!(false);
    }
  }

  @override
  void didUpdateWidget(MailSideBar oldWidget) {
    if (oldWidget.selectedRoute != widget.selectedRoute) {
      setState(() {});
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final labels = ref.watch(mailLabelListControllerProvider);
    final mailColors = ref.watch(authControllerProvider.select((v) => v.requireValue.userMailColors));

    ref.watch(themeSwitchProvider);

    final hostEmail = ref.watch(mailConditionProvider(TabType.mail).select((v) => v.email));
    final labelId = ref.watch(mailConditionProvider(TabType.mail).select((v) => v.label));
    final selectedRoute = hostEmail == null ? '${labelId}' : '${hostEmail}${labelId}';

    return SideBar(
      tabType: widget.tabType,
      backgroundColor: context.background,
      hoverBackgroundColor: context.outlineVariant.withValues(alpha: 0.05),
      borderColor: context.surface,
      activeIconColor: context.onPrimary,
      iconColor: context.onSurface,
      activeBackgroundColor: context.outlineVariant.withValues(alpha: context.isDarkMode ? 0.12 : 0.06),
      textStyle: PlatformX.isMobileView
          ? context.titleMedium!.copyWith(color: context.onBackground).appFont(context).textBold
          : context.labelLarge!.copyWith(color: context.onBackground).appFont(context),
      activeTextStyle: PlatformX.isMobileView
          ? context.titleMedium!.copyWith(color: context.onBackground).appFont(context).textBold
          : context.labelLarge!.copyWith(color: context.onBackground).appFont(context),
      subtextStyle: PlatformX.isMobileView
          ? context.labelLarge!.copyWith(color: context.outlineVariant).appFont(context).textBold
          : context.labelMedium!.copyWith(color: context.outlineVariant).appFont(context),
      activeSubtextStyle: PlatformX.isMobileView
          ? context.labelLarge!.copyWith(color: context.outlineVariant).appFont(context).textBold
          : context.labelMedium!.copyWith(color: context.outlineVariant).appFont(context),

      selectedRoute: selectedRoute,
      width: widget.width,
      items: [
        AdminMenuItem(
          route: 'mail',
          title: context.tr.tab_mail,
          isSection: true,
          children: [
            ...[CommonMailLabels.inbox, CommonMailLabels.unread, CommonMailLabels.pinned, CommonMailLabels.draft, CommonMailLabels.sent].map((e) {
              final list = labels.values.expand((e) => e).where((l) => l.id == (e == CommonMailLabels.unread ? CommonMailLabels.inbox : e).id).toList();
              final badge = e == CommonMailLabels.inbox
                  ? 0
                  : e == CommonMailLabels.pinned || e == CommonMailLabels.draft
                  ? list.isEmpty
                        ? 0
                        : list.length == 1
                        ? list.first.total
                        : list.map((e) => e.total).reduce((a, b) => a + b)
                  : list.isEmpty
                  ? 0
                  : list.length == 1
                  ? list.first.unread
                  : list.map((e) => e.unread).reduce((a, b) => a + b);
              return AdminMenuItem(route: e.id, title: e.getTitle(context), badge: badge, isSelected: selectedRoute == e.id);
            }).toList(),
            AdminMenuItem(
              route: context.tr.mail_label_more,
              titleOnExpanded: context.tr.mail_label_less,
              children: [CommonMailLabels.all, CommonMailLabels.spam, CommonMailLabels.trash].map((e) {
                final list = labels.values.expand((e) => e).where((l) => l.id == e.id).toList();
                final badge = e == CommonMailLabels.all
                    ? 0
                    : list.isEmpty
                    ? 0
                    : list.length == 1
                    ? list.first.unread
                    : list.map((e) => e.unread).reduce((a, b) => a + b);

                return AdminMenuItem(route: e.id, title: e.getTitle(context), badge: badge, isSelected: selectedRoute == e.id);
              }).toList(),
            ),
            ...labels.keys.map((e) {
              return AdminMenuItem(
                route: e,
                subtext: true,
                color: mailColors[e] != null ? ColorX.fromHex(mailColors[e]!) : Colors.transparent,
                children: labels[e]!.map((l) {
                  final list = labels[e]!.where((d) => d.id == l.id).toList();
                  final badge = l.id == CommonMailLabels.unread.id
                      ? 0
                      : l.id == CommonMailLabels.pinned.id || e == CommonMailLabels.draft.id || e == CommonMailLabels.spam.id || e == CommonMailLabels.trash.id
                      ? list.isEmpty
                            ? 0
                            : list.length == 1
                            ? list.first.total
                            : list.map((l) => l.total).reduce((a, b) => a + b)
                      : list.isEmpty
                      ? 0
                      : list.length == 1
                      ? list.first.unread
                      : list.map((l) => l.unread).reduce((a, b) => a + b);

                  final commonLabel = CommonMailLabels.values.where((e) => e.id == l.id).firstOrNull;
                  final labelName = commonLabel != null ? commonLabel.getTitle(context) : l.name;

                  return AdminMenuItem(
                    route: e + (l.id ?? Uuid().v4()),
                    title: labelName,
                    badge: badge,
                    subtext: true,
                    email: e,
                    isSelected: selectedRoute == e + (l.id ?? Uuid().v4()),
                  );
                }).toList(),
              );
            }).toList(),
          ],
        ),
      ],
      onSelected: (item) {
        widget.onSelected?.call(item);
        final email = item.email;
        final label = item.route.substring(email?.length ?? 0);
        ref.read(mailConditionProvider(TabType.mail).notifier).setLabelAndEmail(label, email);
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Navigator.maybePop(context);
        });
      },
    );
  }
}
