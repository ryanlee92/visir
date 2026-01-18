import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/dependency/toasty_box/model/toast_model.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/features/common/presentation/widgets/mesh_loading_background.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/selection_widget.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/tutorial/feature_tutorial_widget.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/time_saved/application/user_action_switch_list_controller.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_entity.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_switch_count_entity.dart';
import 'package:Visir/features/time_saved/presentation/screens/time_saved_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:super_clipboard/super_clipboard.dart';

// 정렬된 리스트를 반환하는 provider - build 메서드 내 정렬 제거
final _sortedUserActionSwitchListProvider = Provider.family<List<UserActionSwitchCountEntity>?, TimeSavedViewType>((ref, viewType) {
  final list = ref.watch(userActionSwitchListControllerProvider(viewType).select((v) => v.value));
  if (list == null) return null;
  return [...list]..sort((a, b) => b.count.compareTo(a.count));
});

class YourSavingWidget extends ConsumerStatefulWidget {
  final bool isTotalSavedPopup;

  const YourSavingWidget({super.key, this.isTotalSavedPopup = false});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _YourSavingWidgetState();
}

class _YourSavingWidgetState extends ConsumerState<YourSavingWidget> {
  ScreenshotController screenshotController = ScreenshotController();

  bool get isDarkMode => context.isDarkMode;
  bool get isMobileView => PlatformX.isMobileView;
  bool get isTotalSavedPopup => widget.isTotalSavedPopup;

  TimeSavedShareType? onLoadingShareType;

  Future<Uint8List?> captureImage({required double? currentWidth, required double maxWidth}) async {
    return await screenshotController.capture(delay: const Duration(milliseconds: 10), pixelRatio: 1200 / (currentWidth ?? maxWidth));
  }

  Future<void> downloadImage(Uint8List image, String text) async {
    await downloadBytes(bytes: [image], names: ['${text}.png'], context: context);
  }

  Future<void> writeImageToClipboard(Uint8List image) async {
    final clipboard = SystemClipboard.instance;
    if (clipboard == null) return;
    final item = DataWriterItem();
    item.add(Formats.png(image));
    await clipboard.write([item]);
    Utils.showToast(
      ToastModel(
        message: TextSpan(text: Utils.mainContext.tr.image_copied_to_clipboard),
        buttons: [],
      ),
    );
    await Future.delayed(Duration(seconds: 1), () {});
  }

  Future<void> shareImage(Uint8List image, String text) async {
    await SharePlus.instance.share(ShareParams(files: [XFile.fromData(image)], text: text, title: text, subject: text));
  }

  Future<void> onPressShareTimeSaved({required TimeSavedShareType type, required String text, required double? currentWidth, required double maxWidth}) async {
    setState(() {
      onLoadingShareType = type;
    });

    final imageData = await captureImage(currentWidth: currentWidth, maxWidth: maxWidth);

    String joinedText = '${text}\n${context.tr.time_saved_check_out_taskey_here(Constants.taskeyHomeUrl)}';
    String encodedText = Uri.encodeComponent(joinedText);

    try {
      switch (type) {
        case TimeSavedShareType.x:
          if (imageData != null) await writeImageToClipboard(imageData);
          await Utils.launchUrlExternal(url: 'https://twitter.com/intent/tweet?text=$encodedText&hashtags=Visir,Productivity');

        case TimeSavedShareType.linkedin:
          if (imageData != null) await writeImageToClipboard(imageData);
          await Utils.launchUrlExternal(
            url: PlatformX.isMobile ? 'https://www.linkedin.com/shareArticle?mini=true' : 'https://www.linkedin.com/feed/?shareActive=true&text=$encodedText',
          );

        case TimeSavedShareType.facebook:
          if (imageData != null) await writeImageToClipboard(imageData);
          await Utils.launchUrlExternal(url: 'https://www.facebook.com/sharer/sharer.php?');

        case TimeSavedShareType.reddit:
          if (imageData != null) await writeImageToClipboard(imageData);
          await Utils.launchUrlExternal(url: 'https://www.reddit.com/submit?title=$encodedText');

        case TimeSavedShareType.thread:
          if (imageData != null) await writeImageToClipboard(imageData);
          await Utils.launchUrlExternal(url: 'https://www.threads.com/intent/post?text=$encodedText');

        case TimeSavedShareType.share:
          if (imageData != null) await shareImage(imageData, joinedText);

        case TimeSavedShareType.download:
          if (imageData != null) await downloadImage(imageData, text);
      }

      logAnalyticsEvent(eventName: 'time_saved_share', properties: {'platform': type.name});

      setState(() {
        onLoadingShareType = null;
      });
    } catch (e) {
      setState(() {
        onLoadingShareType = null;
      });
      Utils.showToast(
        ToastModel(
          message: TextSpan(text: Utils.mainContext.tr.onboarding_email_sign_up_failed),
          buttons: [],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefHourlyWage = ref.watch(hourlyWageProvider);
    UserEntity? user = ref.watch(authControllerProvider.select((v) => v.requireValue));
    DateTime firstDay = user?.isSignedIn == true ? DateUtils.dateOnly(user?.createdAt ?? DateTime.now()) : DateUtils.dateOnly(DateTime.now().subtract(Duration(days: 366)));
    int totalDays = DateUtils.dateOnly(DateTime.now()).difference(firstDay).inDays;

    final viewType = widget.isTotalSavedPopup ? TimeSavedViewType.total : ref.watch(timeSavedViewTypeProvider);

    bool timeSavedShareTutorialDone = ref.watch(authControllerProvider.select((v) => v.requireValue.timeSavedShareTutorialDone));

    const double maxWidth = 536;
    double? currentWidth;

    final loadingNotifier = ref.watch(userActionSwitchListControllerProvider(viewType).notifier).isLoadingNotifier;

    // 정렬된 리스트 사용 - build 메서드 내 정렬 제거로 성능 개선
    final list = ref.watch(_sortedUserActionSwitchListProvider(viewType));

    Color _gray800 = context.onInverseSurface;
    Color _gray900 = context.onSurfaceVariant;
    Color _black = context.onBackground;
    Color _secondary = context.secondary;

    final mostFrequentSwitch = list?.firstOrNull;
    final timeSaved = list?.totalWastedTime ?? 0;
    final moneySaved = timeSaved * prefHourlyWage;
    final productiveHoursReclaimedRatio = timeSaved / (viewType.getDays(user?.createdAt ?? DateUtils.dateOnly(DateTime.now())) / 7 * 40);
    final totalAppSwitches = list?.totalCount ?? 0;
    final lowFocusTimeInHours = list?.totalLowFocusDuration ?? 0;

    const double burgerPrice = 5;
    const double episodeLengthInHours = 0.5;

    double burgerCount = moneySaved / burgerPrice;
    double episodeCount = timeSaved / episodeLengthInHours;

    // 각 count가 1 이하인 값이면 소수점 첫째자리까지, 1 초과면 소수점 반올림
    double formattedBurgerCount = burgerCount <= 1 ? double.parse(burgerCount.toStringAsFixed(1)) : burgerCount.roundToDouble();
    double formattedEpisodeCount = episodeCount <= 1 ? double.parse(episodeCount.toStringAsFixed(1)) : episodeCount.roundToDouble();

    // 소수면 소수 첫째자리까지, 정수면 정수만 표시하는 String
    String formatDisplayValue(double value) {
      if (value == value.toInt()) {
        return value.toInt().toString();
      } else {
        return value.toStringAsFixed(1);
      }
    }

    final shareTypes = TimeSavedShareType.values.toList();
    if (PlatformX.isDesktop) {
      shareTypes.remove(TimeSavedShareType.share);
    } else if (PlatformX.isMobile) {
      shareTypes.remove(TimeSavedShareType.facebook);
      shareTypes.remove(TimeSavedShareType.download);
    }

    Widget buildStackedImages(double count, String imagePath) {
      final imageCount = count < 1 ? 1 : count.toInt();
      final displayCount = imageCount > 12 ? 12 : imageCount; // 1개 이상이면 12개만 표시
      final totalWidth = (displayCount - 1) * 12 + 48; // 마지막 이미지의 오른쪽 끝까지의 총 넓이
      final startLeft = (176 - totalWidth) / 2; // 중앙 정렬을 위한 시작 위치

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 176,
            height: 48,
            child: Stack(
              children: [
                ...List.generate(
                  displayCount,
                  (index) => Positioned(
                    left: startLeft + index * 12,
                    child: Image.asset(imagePath, width: 48, height: 48, fit: BoxFit.contain),
                  ),
                ),
                // 10개 이상일 때 "..." 표시
              ],
            ),
          ),
          if (imageCount > 9)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text('...', style: context.bodyLarge?.textColor(_gray800)),
            ),
        ],
      );
    }

    Widget _detailSection({required TextSpan titleTextSpan, required String contentString, String? unitString, Widget? contentWidget}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 15, child: Text.rich(titleTextSpan, style: context.bodyLarge?.textColor(_gray800))),
          SizedBox(height: 4),
          SizedBox(
            height: 49,
            child: contentWidget == null
                ? RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: contentString,
                          style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w700, fontSize: 40, height: 49 / 40, letterSpacing: -0.3, color: _black),
                        ),
                        if (unitString != null)
                          TextSpan(
                            text: ' ${unitString}',
                            style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.w500, fontSize: 18, height: 49 / 18, letterSpacing: -0.3, color: _black),
                          ),
                      ],
                    ),
                  )
                : contentWidget,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!widget.isTotalSavedPopup)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(context.tr.time_saved_your_savings, style: context.titleLarge?.textColor(isDarkMode ? context.outlineVariant : context.shadow).textBold),
              Spacer(),
              Tooltip(
                showDuration: Duration(days: 1),
                triggerMode: PlatformX.isMobile ? TooltipTriggerMode.tap : null,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                richMessage: TextSpan(
                  children: [
                    WidgetSpan(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 200),
                        child: Text(
                          context.tr.subscription_your_savings_tooptip_desktop,
                          style: context.bodyMedium?.textColor(context.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                verticalOffset: 15,
                textAlign: TextAlign.center,
                decoration: ShapeDecoration(
                  color: context.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(color: context.outline, width: 0.5),
                  ),
                  shadows: [BoxShadow(color: Color(0x3F000000).withValues(alpha: 0.25), blurRadius: 12, offset: Offset(0, 4), spreadRadius: 0)],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: VisirIcon(type: VisirIconType.infoWithCircle, size: 14, isSelected: true),
                ),
              ),
              if (isMobileView) SizedBox(width: 8),
              PopupMenu(
                width: 120,
                forcePopup: true,
                location: PopupMenuLocation.bottom,
                type: ContextMenuActionType.tap,
                borderRadius: 6,
                style: VisirButtonStyle(height: 32, backgroundColor: context.surface, borderRadius: BorderRadius.circular(4)),
                child: SizedBox(
                  width: 120,
                  child: Row(
                    children: [
                      SizedBox(width: 12),
                      Expanded(child: Text(viewType.getTitle(context), style: context.labelMedium?.textColor(context.outlineVariant))),
                      SizedBox(width: 8),
                      VisirIcon(type: VisirIconType.arrowDown, size: 12, color: context.outlineVariant),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
                popup: SelectionWidget<TimeSavedViewType>(
                  current: ref.watch(timeSavedViewTypeProvider),
                  items: TimeSavedViewType.values,
                  getTitle: (value) => value.getTitle(context),
                  onSelect: (value) {
                    ref.read(timeSavedViewTypeProvider.notifier).set(value);
                    ref.read(lastTimeSavedViewTypeProvider.notifier).update(value);
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        if (!widget.isTotalSavedPopup) const SizedBox(height: 16),
        IgnorePointer(
          child: Screenshot(
            controller: screenshotController,
            child: ValueListenableBuilder(
              valueListenable: loadingNotifier,
              builder: (context, isLoading, child) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    currentWidth = constraints.maxWidth;

                    return Container(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Container(
                          width: maxWidth,
                          height: maxWidth,

                          // image: DecorationImage(image: AssetImage('${(kDebugMode && kIsWeb) ? "" : "assets/"}images/saved_background.jpg'), fit: BoxFit.cover),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              children: [
                                Positioned.fill(child: MeshLoadingBackground(doNotAnimate: true)),
                                Positioned.fill(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 42, right: 42, top: 16, bottom: 16),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(context.tr.time_saved_savings_with, style: context.titleLarge?.textColor(_gray900).appFont(context).textBold),
                                              SizedBox(width: 6),
                                              // Visir logo with icon and text (same style as splash screen)
                                              Row(
                                                textDirection: TextDirection.ltr,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Image.asset('${(kDebugMode && kIsWeb) ? "" : "assets/"}app_icon/visir_foreground.png', width: 22, height: 22),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    'Visir',
                                                    style: GoogleFonts.playfairDisplay(
                                                      fontSize: context.titleLarge!.fontSize,
                                                      fontWeight: FontWeight.bold,
                                                      color: _gray900,
                                                      letterSpacing: -0.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '${viewType.getTitle(context)}${viewType == TimeSavedViewType.total ? ' (${totalDays} ${context.tr.days.toLowerCase()})' : ''}',
                                          style: context.titleSmall?.textColor(_secondary).appFont(context),
                                        ),
                                        if (mostFrequentSwitch == null && !isLoading)
                                          Expanded(
                                            child: Center(
                                              child: FutureBuilder(
                                                future: Future.delayed(const Duration(milliseconds: 200)),
                                                builder: (context, snapshot) {
                                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                                    return const SizedBox.shrink();
                                                  }
                                                  return Text(
                                                    context.tr.time_saved_start_using_taskey,
                                                    style: context.titleMedium?.textColor(_gray900).appFont(context).textBold,
                                                    textAlign: TextAlign.center,
                                                  );
                                                },
                                              ),
                                            ),
                                          )
                                        else ...[
                                          SizedBox(height: 16),
                                          Row(
                                            spacing: 44,
                                            children: [
                                              Expanded(
                                                child: _detailSection(
                                                  titleTextSpan: TextSpan(text: context.tr.time_saved_time_saved),
                                                  contentString: timeSaved.toStringAsFixed(1),
                                                  unitString: context.tr.hours.toLowerCase(),
                                                ),
                                              ),
                                              Expanded(
                                                child: _detailSection(
                                                  titleTextSpan: TextSpan(text: context.tr.time_saved_money_saved),
                                                  contentString: '\$${Utils.numberFormatter(moneySaved)}',
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 22),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 1),
                                            child: Text(context.tr.time_saved_that_is_equivalent_to, style: context.titleMedium?.textColor(_gray900).appFont(context).textBold),
                                          ),
                                          SizedBox(height: 20),
                                          Row(
                                            spacing: 44,
                                            children: [
                                              Expanded(
                                                child: _detailSection(
                                                  titleTextSpan: TextSpan(
                                                    text: context.tr.time_saved_watching,
                                                    children: [
                                                      TextSpan(text: ' ${formatDisplayValue(formattedEpisodeCount)} ', style: context.bodyLarge?.textColor(_gray800).textBold),
                                                      TextSpan(
                                                        text: context.tr.time_saved_episodes.replaceAll(RegExp(r's$'), formattedEpisodeCount == 1 ? '' : 's'),
                                                        style: context.bodyLarge?.textColor(_gray800),
                                                      ),
                                                    ],
                                                  ),
                                                  contentString: '',
                                                  contentWidget: buildStackedImages(formattedEpisodeCount, '${(kDebugMode && kIsWeb) ? "" : "assets/"}images/saved_popcorn.png'),
                                                ),
                                              ),
                                              Expanded(
                                                child: _detailSection(
                                                  titleTextSpan: TextSpan(
                                                    text: context.tr.time_saved_buy,
                                                    children: [
                                                      TextSpan(text: ' ${formatDisplayValue(formattedBurgerCount)} ', style: context.bodyLarge?.textColor(_gray800).textBold),
                                                      TextSpan(
                                                        text: context.tr.time_saved_burgers.replaceAll(RegExp(r's$'), formattedBurgerCount == 1 ? '' : 's'),
                                                        style: context.bodyLarge?.textColor(_gray800),
                                                      ),
                                                    ],
                                                  ),
                                                  contentString: '',
                                                  contentWidget: buildStackedImages(formattedBurgerCount, '${(kDebugMode && kIsWeb) ? "" : "assets/"}images/saved_burger.png'),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 28),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 1),
                                            child: Text(context.tr.time_saved_how_i_did_it, style: context.titleMedium?.textColor(_gray900).appFont(context).textBold),
                                          ),
                                          SizedBox(height: 20),
                                          Row(
                                            spacing: 44,
                                            children: [
                                              Expanded(
                                                child: _detailSection(
                                                  titleTextSpan: TextSpan(text: context.tr.time_saved_switches_avoided),
                                                  contentString: Utils.numberFormatter(totalAppSwitches.toDouble()),
                                                  unitString: context.tr.time_saved_times,
                                                ),
                                              ),
                                              Expanded(
                                                child: _detailSection(
                                                  titleTextSpan: TextSpan(text: context.tr.time_saved_most_frequent_switch),
                                                  contentString: '',
                                                  contentWidget: mostFrequentSwitch == null
                                                      ? const SizedBox.shrink()
                                                      : Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Image.asset(
                                                              mostFrequentSwitch.prevAction.transitionAssetPath,
                                                              width: 36,
                                                              height: 36,
                                                              fit: BoxFit.contain,
                                                              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                                                            ),
                                                            const SizedBox(width: 8),
                                                            VisirIcon(type: VisirIconType.arrowRight, size: 24, color: _gray800),
                                                            const SizedBox(width: 8),
                                                            Image.asset(
                                                              mostFrequentSwitch.nextAction.transitionAssetPath,
                                                              width: 36,
                                                              height: 36,
                                                              fit: BoxFit.contain,
                                                              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                                                            ),
                                                          ],
                                                        ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 26),
                                          Row(
                                            spacing: 44,
                                            children: [
                                              Expanded(
                                                child: _detailSection(
                                                  titleTextSpan: TextSpan(text: context.tr.time_saved_hours_in_low_focus),
                                                  contentString: lowFocusTimeInHours.toStringAsFixed(1),
                                                  unitString: context.tr.hours.toLowerCase(),
                                                ),
                                              ),
                                              Expanded(
                                                child: _detailSection(
                                                  titleTextSpan: TextSpan(text: context.tr.time_saved_productive_hours_reclaimed),
                                                  contentString: (productiveHoursReclaimedRatio * 100).toStringAsFixed(1),
                                                  unitString: '%',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: isTotalSavedPopup ? 8 : 16, bottom: isTotalSavedPopup ? 8 : 0),
          child: Row(
            children: [
              Expanded(child: SizedBox.shrink()),
              Text(context.tr.time_saved_share, style: context.titleSmall?.textColor(context.onInverseSurface)),
              const SizedBox(width: 12),
              Container(
                decoration: ShapeDecoration(
                  color: context.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  spacing: 8,
                  children: shareTypes.map((e) {
                    bool isLoading = onLoadingShareType == e;
                    String shareText = isTotalSavedPopup
                        ? context.tr.time_saved_total_share_text(totalDays.toString(), timeSaved.toStringAsFixed(1), Utils.numberFormatter(moneySaved))
                        : viewType.getShareText(context, timeSaved.toStringAsFixed(1), Utils.numberFormatter(moneySaved));

                    if (isTotalSavedPopup && totalDays == 1) {
                      shareText = shareText.replaceAll('days', 'day');
                    }

                    Widget child = Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: context.inversePrimary, shape: BoxShape.circle),
                      child: e.imagePath.isEmpty
                          ? isLoading
                                ? CustomCircularLoadingIndicator(size: 16, color: context.onSurface)
                                : e.icon == null
                                ? SizedBox.shrink()
                                : VisirIcon(type: e.icon!, size: 16, color: context.onSurface, isSelected: true)
                          : ClipOval(child: Image.asset(e.imagePath, width: 28, height: 28)),
                    );

                    return !timeSavedShareTutorialDone || !e.isSocial
                        ? VisirButton(
                            type: VisirButtonAnimationType.scaleAndOpacity,
                            style: VisirButtonStyle(
                              cursor: SystemMouseCursors.click,
                              backgroundColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            options: VisirButtonOptions(tooltipLocation: VisirButtonTooltipLocation.top, message: e.getHoverMessage(context)),
                            onTap: () async {
                              if (isLoading) return;

                              onPressShareTimeSaved(type: e, text: shareText, currentWidth: currentWidth, maxWidth: maxWidth);
                            },
                            child: child,
                          )
                        : PopupMenu(
                            type: ContextMenuActionType.tap,
                            location: PopupMenuLocation.bottom,
                            popup: FeatureTutorialWidget(
                              type: FeatureTutorialType.timeSavedShare,
                              description:
                                  '${context.tr.time_saved_share_tutorial_description(e.getHoverMessage(context))}${PlatformX.isMobile
                                      ? '.'
                                      : PlatformX.isMacOS
                                      ? ' with ⌘ V.'
                                      : ' with Ctrl V.'}',
                              onPresseContinue: () {
                                onPressShareTimeSaved(type: e, text: shareText, currentWidth: currentWidth, maxWidth: maxWidth);
                              },
                            ),
                            width: 232,
                            options: VisirButtonOptions(tooltipLocation: VisirButtonTooltipLocation.top, message: e.getHoverMessage(context)),
                            style: VisirButtonStyle(
                              cursor: SystemMouseCursors.click,
                              borderRadius: BorderRadius.circular(14),
                              backgroundColor: context.surface,
                              width: 28,
                              height: 28,
                            ),
                            child: child,
                          );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
