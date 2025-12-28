import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/presentation/screens/auth_screen.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/mesh_loading_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  @override
  void initState() {
    super.initState();

    tabNotifier = ValueNotifier<TabType>(TabType.home);

    notificationPayload = null;

    mailInputDraftEditListener = ValueNotifier(null);
    mailInputDraftEditKeyboardResetNotifier = ValueNotifier(0);

    mailEditScreenKey = GlobalKey();
    mailEditScreenVisibleNotifier = ValueNotifier(false);

    mailViewportSyncKey = {TabType.mail: GlobalKey(), TabType.home: GlobalKey(), TabType.task: GlobalKey(), TabType.calendar: GlobalKey(), TabType.chat: GlobalKey()};

    mailViewportSyncVisibleNotifier = {
      TabType.mail: ValueNotifier(false),
      TabType.home: ValueNotifier(false),
      TabType.task: ValueNotifier(false),
      TabType.calendar: ValueNotifier(false),
      TabType.chat: ValueNotifier(false),
    };
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider.select((v) => v.requireValue.isSignedIn), (previous, next) {});

    return Stack(
      children: [
        Positioned.fill(child: Container(color: context.background)),
        Positioned.fill(child: MeshLoadingBackground(doNotAnimate: true)),
        Positioned.fill(child: Container(color: context.background.withValues(alpha: 0.5))),
        AuthScreen(),
      ],
    );
    // return MainScreen(key: ValueKey('no_auth'));
  }
}
