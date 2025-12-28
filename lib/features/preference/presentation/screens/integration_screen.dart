import 'package:Visir/dependency/master_detail_flow/master_detail_flow.dart';
import 'package:Visir/dependency/modal_bottom_sheet/src/utils/modal_scroll_controller.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_section.dart';
import 'package:Visir/features/common/presentation/widgets/tutorial/feature_tutorial_widget.dart';
import 'package:Visir/features/preference/application/mail_integration_list_controller.dart';
import 'package:Visir/features/preference/application/messenger_integration_list_controller.dart';
import 'package:Visir/features/preference/presentation/widgets/integration/calendar_integration_widget.dart';
import 'package:Visir/features/preference/presentation/widgets/integration/chat_integration_widget.dart';
import 'package:Visir/features/preference/presentation/widgets/integration/mail_integration_widget.dart';
import 'package:change_case/change_case.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum IntegrationType { calendar, email, chat }

extension IntegrationTypeX on IntegrationType {
  Widget Function({Key? key, VoidCallback? showInboxFilterTutorialPopupOnMobile}) get builder =>
      ({Key? key, VoidCallback? showInboxFilterTutorialPopupOnMobile}) {
        switch (this) {
          case IntegrationType.calendar:
            return CalendarIntegrationWidget();
          case IntegrationType.email:
            return MailIntegrationWidget();
          case IntegrationType.chat:
            return ChatIntegrationWidget();
        }
      };
}

class IntegrationScreen extends ConsumerStatefulWidget {
  final bool isSmall;
  final VoidCallback? onClose;

  const IntegrationScreen({super.key, required this.isSmall, this.onClose});

  @override
  ConsumerState createState() => _IntegrationScreenState();
}

class _IntegrationScreenState extends ConsumerState<IntegrationScreen> {
  ScrollController? _scrollController;

  Map<IntegrationType, GlobalKey> keys = {};

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showInboxFilterTutorialPopupOnMobile();
    });
  }

  @override
  void dispose() {
    _scrollController?.dispose();

    widget.onClose?.call();
    super.dispose();
  }

  void showInboxFilterTutorialPopupOnMobile() {
    if (!PlatformX.isMobile) return;
    final user = Utils.ref.read(authControllerProvider).requireValue;
    if (!user.isSignedIn) return;

    final mailOAuths = ref.read(mailIntegrationListControllerProvider).value ?? [];
    final messengerOAuths = ref.read(messengerIntegrationListControllerProvider).value ?? [];

    if (!user.mobileInboxFilterTutorialDone && (mailOAuths.isNotEmpty || messengerOAuths.isNotEmpty)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Utils.showPopupDialog(
          child: FeatureTutorialWidget(type: FeatureTutorialType.inboxFilter),
          size: Size(300, 0),
          forcePopup: true,
          isFlexibleHeightPopup: true,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _scrollController ??= ModalScrollController.ofSyncGroup(context)?.addAndGet() ?? ScrollController();
    return DetailsItem(
      title: widget.isSmall ? context.tr.integration_pref_title : null,
      hideBackButton: !widget.isSmall,
      scrollController: _scrollController,
      scrollPhysics: Utils.getScrollPhysicsForBottomSheet(context, _scrollController),
      appbarColor: context.background,
      bodyColor: context.background,
      children: [
        ...IntegrationType.values
            .mapIndexed<List<Widget>>((index, type) {
              return <Widget>[
                VisirListSection(
                  removeTopMargin: index == 0,
                  titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: type.name.toSentenceCase(), style: baseStyle),
                ),
                type.builder(key: keys[type]),
              ];
            })
            .toList()
            .expand((e) => e)
            .toList(),
      ],
    );
  }
}
