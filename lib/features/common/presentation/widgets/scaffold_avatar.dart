import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/presentation/screens/auth_screen.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/download_mobile_app_popup.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/local_pref_entity.dart';
import 'package:Visir/features/preference/presentation/screens/preference_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart' show ImageRenderMethodForWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScaffoldAvatar extends ConsumerWidget {
  const ScaffoldAvatar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isSignedIn = ref.read(isSignedInProvider);
    final tabBarDisplayType = ref.watch(localPrefControllerProvider.select((e) => e.value!.prefTabBarDisplayType));

    final name = ref.watch(authControllerProvider.select((e) => e.requireValue.name));
    final avatarUrl = ref.watch(authControllerProvider.select((e) => e.requireValue.avatarUrl));
    bool isTabBarCollapsed = context.isNarrowScaffold || (tabBarDisplayType == TabBarDisplayType.alwaysCollapsed);

    if (!isSignedIn) {
      return VisirButton(
        type: VisirButtonAnimationType.scaleAndOpacity,
        style: VisirButtonStyle(width: isTabBarCollapsed ? 36 : 56, borderRadius: BorderRadius.circular(8), cursor: SystemMouseCursors.click),
        isSelected: false,
        focusNode: FocusNode(skipTraversal: true),
        child: Column(
          children: [
            SizedBox(height: 8),
            VisirIcon(type: VisirIconType.profile, size: isTabBarCollapsed ? 20 : Theme.of(context).iconTheme.size ?? 20),
            if (!isTabBarCollapsed) ...[SizedBox(height: 6), Text(Utils.mainContext.tr.sign_in, style: context.labelMedium?.textColor(context.onBackground).appFont(context))],
            SizedBox(height: 8),
          ],
        ),
        onTap: () {
          Utils.showPopupDialog(child: AuthScreen(), size: Size(480, 600));
          logAnalyticsEvent(eventName: 'onboarding_sign_in');
        },
      );
    }

    return PopupMenu(
      type: ContextMenuActionType.tap,
      location: PopupMenuLocation.right,
      style: VisirButtonStyle(width: isTabBarCollapsed ? 36 : 44, height: isTabBarCollapsed ? 36 : 44, borderRadius: BorderRadius.circular(8)),
      borderRadius: 6,
      width: 160,
      options: VisirButtonOptions(
        tooltipLocation: VisirButtonTooltipLocation.none,
        bypassMailEditScreen: true,
        shortcuts: [
          VisirButtonKeyboardShortcut(
            message: context.tr.preferences_title,
            itemTitle: context.tr.preferences_title,
            keys: [LogicalKeyboardKey.comma, if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control],
            onTrigger: () {
              if (!PreferenceScreen.isOpened) {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Utils.showPopupDialog(
                  child: PreferenceScreen(key: Utils.preferenceScreenKey),
                  size: Size(640, 560),
                );
              }
              return true;
            },
          ),
          // VisirButtonKeyboardShortcut(
          //   message: context.tr.join_slack_community,
          //   itemTitle: context.tr.join_slack_community,
          //   keys: [],
          //   onTrigger: () {
          //     Utils.launchSlackCommunity();
          //     return true;
          //   },
          // ),
          VisirButtonKeyboardShortcut(
            message: context.tr.download_for_mobile,
            itemTitle: context.tr.download_for_mobile,
            keys: [],
            onTrigger: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Utils.showPopupDialog(child: DownloadMobileAppPopup(), size: Size(440, 394));
              return true;
            },
          ),
          if (PlatformX.isWeb)
            VisirButtonKeyboardShortcut(
              message: context.tr.pref_download,
              itemTitle: context.tr.pref_download,
              keys: [],
              onTrigger: () {
                Utils.launchUrlExternal(url: 'https://visir.pro/download');
                return true;
              },
            ),
        ],
      ),
      child: AdvancedAvatar(
        name: name ?? '',
        image: avatarUrl == null
            ? AssetImage('assets/place_holder/img_default_profile.png') as ImageProvider
            : CachedNetworkImageProvider(proxyUrl(avatarUrl), imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet),
        size: isTabBarCollapsed ? 24 : 28,
        autoTextSize: true,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
        style: TextStyle(color: context.onPrimary),
      ),
    );
  }
}
