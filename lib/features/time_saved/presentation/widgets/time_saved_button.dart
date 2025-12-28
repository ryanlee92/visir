import 'dart:ui';

import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/time_saved/application/user_action_switch_list_controller.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_entity.dart';
import 'package:Visir/features/time_saved/presentation/screens/time_saved_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class TimeSavedButton extends ConsumerStatefulWidget {
  const TimeSavedButton({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => TimeSavedButtonState();
}

class TimeSavedButtonState extends ConsumerState<TimeSavedButton> with SingleTickerProviderStateMixin {
  static const Duration animationDuration = Duration(milliseconds: 1200);

  late AnimationController _animationController;
  late Animation<double> textSlideAnimation;
  late Animation<double> textOpacityAnimation;
  late Animation<double> imageSlideAnimation;
  late Animation<double> imageOpacityAnimation;

  String savedMoneyString = '0';

  void updateMoneyString() {
    final prefHourlyWage = ref.read(hourlyWageProvider);
    double totalSavedTimeInHours = UserActionSwitchListControllerProviderX.savedTimeInHoursNotifier.value;
    double totalSavedMoney = totalSavedTimeInHours * prefHourlyWage;
    final nextSavedMoneyString = Utils.numberFormatter(totalSavedMoney);
    if (savedMoneyString != nextSavedMoneyString) {
      savedMoneyString = nextSavedMoneyString;
      setState(() {});
    }
  }

  Offset? getOffset() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      return renderBox.localToGlobal(Offset.zero);
    }
    return null;
  }

  Rect? getRect() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      final offset = renderBox.localToGlobal(Offset.zero);
      return Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height);
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: animationDuration, vsync: this);

    textSlideAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 33.33),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: -1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 33.33),
      TweenSequenceItem(tween: Tween<double>(begin: -1.0, end: 0.0).chain(CurveTween(curve: Curves.easeInCubic)), weight: 33.33),
    ]).animate(_animationController);

    textOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 33.33),
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.0), weight: 33.33),
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeInCubic)), weight: 33.33),
    ]).animate(_animationController);

    imageSlideAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: -1.0, end: 0.0).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 33.33),
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.0), weight: 33.33),
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeInCubic)), weight: 33.33),
    ]).animate(_animationController);

    imageOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 33.33),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 33.33),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeInCubic)), weight: 33.33),
    ]).animate(_animationController);

    UserActionSwitchListControllerProviderX.savedTimeInHoursNotifier.addListener(updateMoneyString);
  }

  @override
  void dispose() {
    _animationController.dispose();
    UserActionSwitchListControllerProviderX.savedTimeInHoursNotifier.removeListener(updateMoneyString);
    super.dispose();
  }

  void onTap() {
    Utils.showPopupDialog(disableEscapeClose: true, child: TimeSavedScreen(), size: Size(568, 1080));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(appTransitionAnimationControllerProvider, (prev, next) {
      if (next.isAnimating && _animationController.status != AnimationStatus.forward) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _animationController.forward(from: 0.0);
        });
      }
    });

    ref.listen(hourlyWageProvider, (prev, hourlyWage) {
      updateMoneyString();
    });

    ref.listen(authControllerProvider.select((v) => v.requireValue.userTotalDays), (prev, userTotalDays) {
      updateMoneyString();
    });

    final transitionState = ref.watch(appTransitionAnimationControllerProvider);

    ref.watch(defaultUserActionSwitchListControllerProvider);

    final value = ref.watch(timeSavedViewTypeProvider);

    Color foregroundColor = context.onBackground;

    return VisirButton(
      type: VisirButtonAnimationType.scaleAndOpacity,
      onTap: onTap,
      style: VisirButtonStyle(
        height: 32,
        margin: EdgeInsets.only(
          left: PlatformX.isWindows ? DesktopScaffold.backgroundPadding : DesktopScaffold.cardPadding,
          right: PlatformX.isWindows ? DesktopScaffold.cardPadding : DesktopScaffold.backgroundPadding,
        ),
        borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
        cursor: SystemMouseCursors.click,
        width: 88,
      ),
      options: VisirButtonOptions(message: value.getTooltipMessage(context), tooltipLocation: VisirButtonTooltipLocation.bottom),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Stack(
          children: [
            Positioned.fill(child: meshLoadingBackground),

            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  color: context.background.withValues(alpha: 0.7),
                  border: Border.all(color: context.onBackground.withValues(alpha: 0.1), width: 1),
                  borderRadius: BorderRadius.circular(DesktopScaffold.cardRadius),
                ),
              ),
            ),

            Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, textSlideAnimation.value * 20),
                    child: Opacity(opacity: textOpacityAnimation.value, child: child!),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    VisirIcon(type: VisirIconType.dollar, size: 16, color: foregroundColor, isSelected: true),
                    SizedBox(width: 4),
                    Text('\$${savedMoneyString}', style: context.bodyLarge?.textColor(foregroundColor)),
                    SizedBox(width: 4),
                  ],
                ),
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, imageSlideAnimation.value * 20),
                    child: Opacity(
                      opacity: imageOpacityAnimation.value,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (transitionState.prevImagePath != null)
                            Image.asset(
                              transitionState.prevImagePath ?? '',
                              width: 20,
                              height: 20,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox.shrink();
                              },
                            ),
                          const SizedBox(width: 8),
                          VisirIcon(type: VisirIconType.converted, size: 16, color: foregroundColor, isSelected: true),
                          const SizedBox(width: 8),
                          if (transitionState.nextImagePath != null)
                            Image.asset(
                              transitionState.nextImagePath ?? '',
                              width: 20,
                              height: 20,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox.shrink();
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final appTransitionAnimationControllerProvider = StateNotifierProvider<AppTransitionAnimationController, AppTransitionState>((ref) {
  return AppTransitionAnimationController();
});

class AppTransitionState {
  final bool isAnimating;
  final String? prevImagePath;
  final String? nextImagePath;

  AppTransitionState({this.isAnimating = false, this.prevImagePath, this.nextImagePath});

  AppTransitionState copyWith({bool? isAnimating, String? prevImagePath, String? nextImagePath}) {
    return AppTransitionState(isAnimating: isAnimating ?? this.isAnimating, prevImagePath: prevImagePath ?? this.prevImagePath, nextImagePath: nextImagePath ?? this.nextImagePath);
  }
}

class AppTransitionAnimationController extends StateNotifier<AppTransitionState> {
  AppTransitionAnimationController() : super(AppTransitionState());

  void triggerAnimation({required UserActionEntity prevAction, required UserActionEntity nextAction}) {
    if (state.isAnimating) return;

    state = state.copyWith(isAnimating: true, prevImagePath: prevAction.transitionAssetPath, nextImagePath: nextAction.transitionAssetPath);

    Future.delayed(TimeSavedButtonState.animationDuration, () {
      state = state.copyWith(isAnimating: false, prevImagePath: null, nextImagePath: null);
    });
  }
}
