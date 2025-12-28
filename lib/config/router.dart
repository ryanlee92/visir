import 'package:Visir/config/app_layout.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

/// Main router for the Example app
///
/// ! Pay attention to the order of routes.
/// Create:  example/create
/// View:    example/:eid
/// Edit:    example/:eid/edit
/// where :edit means example entity id.
///
/// ! Note about parameters
/// Router keeps parameters in global map. It means that if you create route
/// organization/:id and organization/:id/department/:id. Department id will
///  override organization id. So use :oid and :did instead of :id
/// Also router does not provide option to set regex for parameters.
/// If you put - example/:eid before - example/create for route - example/create
/// will be called route - example/:eid
///

enum TransitionType { none, slide }

TransitionType getTransitionType(BuildContext context) {
  if (PlatformX.isWeb) {
    return TransitionType.none;
  } else if (PlatformX.isMacOS) {
    return TransitionType.none;
  } else if (PlatformX.isWindows) {
    return TransitionType.none;
  } else if (PlatformX.isLinux) {
    return TransitionType.none;
  } else if (PlatformX.isIOS) {
    if (MediaQuery.of(context).size.width > AppLayout.tabletBreakdownWidth) {
      return TransitionType.none;
    }

    return TransitionType.slide;
  } else if (PlatformX.isAndroid) {
    if (MediaQuery.of(context).size.width > AppLayout.tabletBreakdownWidth) {
      return TransitionType.none;
    }
  }
  return TransitionType.none;
}

Page buildPageWithDefaultTransition<T>({required BuildContext context, required GoRouterState state, required Widget child}) {
  switch (getTransitionType(context)) {
    case TransitionType.none:
      return NoTransitionPage(child: child);
    case TransitionType.slide:
      return CupertinoPage(child: child);
  }
}
