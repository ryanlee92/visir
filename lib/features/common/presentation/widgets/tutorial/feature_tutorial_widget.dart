import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/presentation/screens/preference_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

enum FeatureTutorialType { inboxIntegration, inboxDragAndDrop, gcalPermission, gmailPermission, inboxFilter, timeSaved, timeSavedShare, createTaskFromMail }

extension FeatureTutorialTypeX on FeatureTutorialType {
  String getImagePath(BuildContext context) {
    bool isMobileView = PlatformX.isMobileView;

    switch (this) {
      case FeatureTutorialType.inboxIntegration:
        return '${(kDebugMode && PlatformX.isWeb) ? "" : "assets/"}images/tutorial_inbox${isMobileView ? '_mobile' : ''}.png';
      case FeatureTutorialType.inboxDragAndDrop:
        return '${(kDebugMode && PlatformX.isWeb) ? "" : "assets/"}images/tutorial_inbox_drag${isMobileView ? '_mobile' : ''}.png';
      case FeatureTutorialType.gcalPermission:
        return '${(kDebugMode && PlatformX.isWeb) ? "" : "assets/"}images/tutorial_integration_google_calendar${isMobileView ? '_mobile' : ''}.png';
      case FeatureTutorialType.gmailPermission:
        return '${(kDebugMode && PlatformX.isWeb) ? "" : "assets/"}images/tutorial_integration_gmail${isMobileView ? '_mobile' : ''}.png';
      case FeatureTutorialType.inboxFilter:
        return '';
      case FeatureTutorialType.timeSaved:
        return '${(kDebugMode && PlatformX.isWeb) ? "" : "assets/"}images/tutorial_time_saved.png';
      case FeatureTutorialType.createTaskFromMail:
        return '';
      case FeatureTutorialType.timeSavedShare:
        return '';
    }
  }

  String getTitle(BuildContext context) {
    bool isMobileView = PlatformX.isMobileView;

    switch (this) {
      case FeatureTutorialType.inboxIntegration:
        return context.tr.feature_tutorial_inbox_integration_title;
      case FeatureTutorialType.inboxDragAndDrop:
        return isMobileView ? context.tr.feature_tutorial_mobile_inbox_drag_and_drop_title : context.tr.feature_tutorial_inbox_drag_and_drop_title;
      case FeatureTutorialType.gcalPermission:
        return context.tr.google_calendar_permission_title;
      case FeatureTutorialType.gmailPermission:
        return context.tr.google_mail_permission_title;
      case FeatureTutorialType.inboxFilter:
        return context.tr.inbox_filter_tutorial_title;
      case FeatureTutorialType.timeSaved:
        return context.tr.feature_tutorial_time_saved_title;
      case FeatureTutorialType.createTaskFromMail:
        return context.tr.feature_tutorial_create_task_from_mail_title;
      case FeatureTutorialType.timeSavedShare:
        return context.tr.time_saved_share_tutorial_title;
    }
  }

  String getDescription(BuildContext context) {
    bool isMobileView = PlatformX.isMobileView;

    switch (this) {
      case FeatureTutorialType.inboxIntegration:
        return context.tr.feature_tutorial_inbox_integration_description;
      case FeatureTutorialType.inboxDragAndDrop:
        return isMobileView ? context.tr.feature_tutorial_mobile_inbox_drag_and_drop_description : context.tr.feature_tutorial_inbox_drag_and_drop_description;
      case FeatureTutorialType.gcalPermission:
        return context.tr.google_calendar_permission_description;
      case FeatureTutorialType.gmailPermission:
        return context.tr.google_mail_permission_description;
      case FeatureTutorialType.inboxFilter:
        return context.tr.inbox_filter_tutorial_description;
      case FeatureTutorialType.timeSaved:
        return context.tr.feature_tutorial_time_saved_description;
      case FeatureTutorialType.createTaskFromMail:
        return context.tr.feature_tutorial_create_task_from_mail_description;
      case FeatureTutorialType.timeSavedShare:
        return '';
    }
  }

  String getButtonTitle(BuildContext context) {
    switch (this) {
      case FeatureTutorialType.inboxIntegration:
        return context.tr.feature_tutorial_inbox_integration_button;
      case FeatureTutorialType.inboxDragAndDrop:
        return context.tr.feature_tutorial_inbox_drag_and_drop_button;
      case FeatureTutorialType.gcalPermission:
        return context.tr.google_calendar_permission_button;
      case FeatureTutorialType.gmailPermission:
        return context.tr.google_mail_permission_button;
      case FeatureTutorialType.inboxFilter:
        return context.tr.inbox_filter_tutorial_button;
      case FeatureTutorialType.timeSaved:
        return context.tr.feature_tutorial_time_saved_button;
      case FeatureTutorialType.createTaskFromMail:
        return context.tr.feature_tutorial_create_task_from_mail_button;
      case FeatureTutorialType.timeSavedShare:
        return context.tr.time_saved_share_tutorial_button;
    }
  }

  double? get minWidth {
    switch (this) {
      case FeatureTutorialType.inboxIntegration:
      case FeatureTutorialType.gcalPermission:
      case FeatureTutorialType.gmailPermission:
      case FeatureTutorialType.timeSaved:
      case FeatureTutorialType.createTaskFromMail:
      case FeatureTutorialType.timeSavedShare:
        return null;
      case FeatureTutorialType.inboxDragAndDrop:
      case FeatureTutorialType.inboxFilter:
        return 80;
    }
  }
}

class FeatureTutorialWidget extends StatefulWidget {
  final FeatureTutorialType type;
  final VoidCallback? onPresseContinue;
  final String? description;

  const FeatureTutorialWidget({Key? key, required this.type, this.onPresseContinue, this.description})
    : assert(
        type != FeatureTutorialType.gcalPermission && type != FeatureTutorialType.gmailPermission || onPresseContinue != null,
        'onPresseContinue must be provided for gcalPermission and gmailPermission types',
      ),
      super(key: key);

  @override
  State<FeatureTutorialWidget> createState() => _FeatureTutorialWidgetState();
}

class _FeatureTutorialWidgetState extends State<FeatureTutorialWidget> {
  @override
  void dispose() {
    onClose();
    super.dispose();
  }

  void onClose() {
    final user = Utils.ref.read(authControllerProvider).requireValue;
    if (!user.isSignedIn) return;

    SchedulerBinding.instance.addPostFrameCallback((_) {
      switch (widget.type) {
        case FeatureTutorialType.inboxIntegration:
          break;
        case FeatureTutorialType.inboxDragAndDrop:
          if (PlatformX.isMobile) {
            Utils.ref
                .read(authControllerProvider.notifier)
                .updateUser(user: user.copyWith(userTutorialDoneList: [...user.tutorialDoneList, UserTutorialType.mobileInboxDrag].unique()));
          }
        case FeatureTutorialType.gcalPermission:
          if (PlatformX.isDesktop) {
            Utils.ref
                .read(authControllerProvider.notifier)
                .updateUser(user: user.copyWith(userTutorialDoneList: [...user.tutorialDoneList, UserTutorialType.desktopGcalPermission].unique()));
          } else if (PlatformX.isMobile) {
            Utils.ref
                .read(authControllerProvider.notifier)
                .updateUser(user: user.copyWith(userTutorialDoneList: [...user.tutorialDoneList, UserTutorialType.mobileGcalPermission].unique()));
          }
        case FeatureTutorialType.gmailPermission:
          if (PlatformX.isDesktop) {
            Utils.ref
                .read(authControllerProvider.notifier)
                .updateUser(user: user.copyWith(userTutorialDoneList: [...user.tutorialDoneList, UserTutorialType.desktopGmailPermission].unique()));
          } else if (PlatformX.isMobile) {
            Utils.ref
                .read(authControllerProvider.notifier)
                .updateUser(user: user.copyWith(userTutorialDoneList: [...user.tutorialDoneList, UserTutorialType.mobileGmailPermission].unique()));
          }
        case FeatureTutorialType.inboxFilter:
          if (PlatformX.isDesktop) {
            Utils.ref
                .read(authControllerProvider.notifier)
                .updateUser(user: user.copyWith(userTutorialDoneList: [...user.tutorialDoneList, UserTutorialType.desktopInboxFilter].unique()));
          } else if (PlatformX.isMobile) {
            Utils.ref
                .read(authControllerProvider.notifier)
                .updateUser(user: user.copyWith(userTutorialDoneList: [...user.tutorialDoneList, UserTutorialType.mobileInboxFilter].unique()));
          }
        case FeatureTutorialType.timeSaved:
          Utils.ref
              .read(authControllerProvider.notifier)
              .updateUser(user: user.copyWith(userTutorialDoneList: [...user.tutorialDoneList, UserTutorialType.timeSaved].unique()));
        case FeatureTutorialType.createTaskFromMail:
          Utils.ref.read(createTaskFromMailTutorialDoneProvider.notifier).update(true);
        case FeatureTutorialType.timeSavedShare:
          Utils.ref
              .read(authControllerProvider.notifier)
              .updateUser(user: user.copyWith(userTutorialDoneList: [...user.tutorialDoneList, UserTutorialType.timeSavedShare].unique()));
      }
    });
  }

  void onPressButton() {
    final user = Utils.ref.read(authControllerProvider).requireValue;
    if (!user.isSignedIn) return;

    switch (widget.type) {
      case FeatureTutorialType.inboxIntegration:
        Utils.showPopupDialog(
          child: PreferenceScreen(key: Utils.preferenceScreenKey, initialPreferenceScreenType: PreferenceScreenType.integration),
          size: Size(640, 560),
        );
      case FeatureTutorialType.inboxDragAndDrop:
        if (PlatformX.isMobileView) {
          Navigator.of(Utils.mainContext).popUntil((route) => route.isFirst);
        } else if (PlatformX.isDesktopView) {
          Utils.ref
              .read(authControllerProvider.notifier)
              .updateUser(user: user.copyWith(userTutorialDoneList: [...user.tutorialDoneList, UserTutorialType.desktopInboxDrag].unique()));
        }
      case FeatureTutorialType.gcalPermission:
        Navigator.of(Utils.mainContext).maybePop();
        widget.onPresseContinue?.call();
      case FeatureTutorialType.gmailPermission:
        Navigator.of(Utils.mainContext).maybePop();
        widget.onPresseContinue?.call();
      case FeatureTutorialType.inboxFilter:
        Navigator.of(Utils.mainContext).maybePop();
      case FeatureTutorialType.timeSaved:
        if (PlatformX.isMobileView) {
          Navigator.of(Utils.mainContext).popUntil((route) => route.isFirst);
          Utils.showPopupDialog(
            child: PreferenceScreen(key: Utils.preferenceScreenKey, initialPreferenceScreenType: PreferenceScreenType.saved),
          );
        } else if (PlatformX.isDesktopView) {
          Navigator.of(Utils.mainContext).maybePop().then((value) {
            Constants.timeSavedButtonKey.currentState?.onTap();
          });
        }
      case FeatureTutorialType.createTaskFromMail:
        Navigator.of(Utils.mainContext).maybePop();
      case FeatureTutorialType.timeSavedShare:
        Navigator.of(Utils.mainContext).maybePop();
        widget.onPresseContinue?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobileView = PlatformX.isMobileView;

    double width = isMobileView ? 300 : 232;

    return Container(
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: context.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        shadows: [BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 4), spreadRadius: 0)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.type.getImagePath(context).isNotEmpty) Image.asset(widget.type.getImagePath(context), width: width, fit: BoxFit.cover),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(widget.type.getTitle(context), style: context.bodyMedium?.textColor(context.outlineVariant).textBold, textAlign: TextAlign.center),
                SizedBox(height: 4),
                Text(
                  widget.description ?? widget.type.getDescription(context),
                  style: context.bodyMedium?.textColor(context.shadow),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Center(
                  child: IntrinsicWidth(
                    child: VisirButton(
                      type: VisirButtonAnimationType.scaleAndOpacity,
                      style: VisirButtonStyle(
                        cursor: SystemMouseCursors.click,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        borderRadius: BorderRadius.circular(4),
                        backgroundColor: context.primary,
                        width: widget.type.minWidth,
                      ),
                      onTap: onPressButton,
                      child: Text(widget.type.getButtonTitle(context), style: context.bodyMedium?.textColor(context.onPrimary)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
