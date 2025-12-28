import 'dart:math';

import 'package:Visir/dependency/fl_chart/fl_chart.dart';
import 'package:Visir/dependency/modal_bottom_sheet/src/utils/modal_scroll_controller.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/keyboard_shortcut.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/time_saved/application/time_saved_list_controller.dart';
import 'package:Visir/features/time_saved/application/total_user_action_switch_list_controller.dart';
import 'package:Visir/features/time_saved/application/user_action_switch_list_controller.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_switch_count_entity.dart';
import 'package:Visir/features/time_saved/presentation/widgets/transition_count_widget.dart';
import 'package:Visir/features/time_saved/presentation/widgets/your_saving_widget.dart';
import 'package:another_xlider/another_xlider.dart';
import 'package:another_xlider/models/handler.dart';
import 'package:another_xlider/models/tooltip/tooltip.dart';
import 'package:another_xlider/models/trackbar.dart';
import 'package:collection/collection.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:screenshot/screenshot.dart';

enum TimeSavedViewType { last7days, last14days, last28days, last12weeks, last12months, thisWeek, thisMonth, thisYear, total }

extension TimeSavedViewTypeExtension on TimeSavedViewType {
  String getTitle(BuildContext context) {
    switch (this) {
      case TimeSavedViewType.last7days:
        return context.tr.time_saved_last_7_days;
      case TimeSavedViewType.last14days:
        return context.tr.time_saved_last_14_days;
      case TimeSavedViewType.last28days:
        return context.tr.time_saved_last_28_days;
      case TimeSavedViewType.last12weeks:
        return context.tr.time_saved_last_12_weeks;
      case TimeSavedViewType.last12months:
        return context.tr.time_saved_last_12_months;
      case TimeSavedViewType.thisWeek:
        return context.tr.time_saved_this_week;
      case TimeSavedViewType.thisMonth:
        return context.tr.time_saved_this_month;
      case TimeSavedViewType.thisYear:
        return context.tr.time_saved_this_year;
      case TimeSavedViewType.total:
        return context.tr.time_saved_total;
    }
  }

  int getDays(DateTime userCreatedAt) {
    final today = DateUtils.dateOnly(DateTime.now());

    switch (this) {
      case TimeSavedViewType.last7days:
        return 7;
      case TimeSavedViewType.last14days:
        return 14;
      case TimeSavedViewType.last28days:
        return 28;
      case TimeSavedViewType.last12weeks:
        return 84;
      case TimeSavedViewType.last12months:
        return 365;
      case TimeSavedViewType.thisWeek:
        final monday = today.subtract(Duration(days: today.weekday - 1));
        final daysFromMonday = today.difference(monday).inDays;
        return daysFromMonday + 1;
      case TimeSavedViewType.thisMonth:
        final firstDayOfMonth = DateTime(today.year, today.month, 1);
        final daysFromFirstDay = today.difference(firstDayOfMonth).inDays;
        return daysFromFirstDay + 1;
      case TimeSavedViewType.thisYear:
        final firstDayOfYear = DateTime(today.year, 1, 1);
        final daysFromFirstDay = today.difference(firstDayOfYear).inDays;
        return daysFromFirstDay + 1;
      case TimeSavedViewType.total:
        return today.difference(userCreatedAt).inDays + 1;
    }
  }

  List<DateTime> getSeparatorInDays(DateTime userCreatedAt) {
    final today = DateUtils.dateOnly(DateTime.now());

    switch (this) {
      case TimeSavedViewType.last7days:
        return List.generate(7, (i) => today.subtract(Duration(days: 7 - i)));
      case TimeSavedViewType.last14days:
        return List.generate(14, (i) => today.subtract(Duration(days: 14 - i)));
      case TimeSavedViewType.last28days:
        return List.generate(28, (i) => today.subtract(Duration(days: 28 - i)));
      case TimeSavedViewType.last12weeks:
        return List.generate(12, (i) => today.subtract(Duration(days: (12 - i) * 7)));
      case TimeSavedViewType.last12months:
        return List.generate(12, (i) => DateTime(today.year, today.month - (11 - i)));
      case TimeSavedViewType.thisWeek:
        final monday = today.subtract(Duration(days: today.weekday - 1));
        final daysFromMonday = today.difference(monday).inDays;
        return List.generate(daysFromMonday + 1, (index) => monday.add(Duration(days: index)));
      case TimeSavedViewType.thisMonth:
        final firstDayOfMonth = DateTime(today.year, today.month, 1);
        final daysFromFirstDay = today.difference(firstDayOfMonth).inDays;
        return List.generate(daysFromFirstDay + 1, (index) => firstDayOfMonth.add(Duration(days: index)));
      case TimeSavedViewType.thisYear:
        return List.generate(today.month, (month) => DateTime(today.year, month + 1, 1));
      case TimeSavedViewType.total:
        final firstDay = DateUtils.dateOnly(userCreatedAt);
        final totalDays = today.difference(firstDay).inDays + 1;

        if (totalDays <= 7) {
          // 7일 이하면 일 단위
          return List.generate(totalDays, (i) => firstDay.add(Duration(days: i)));
        } else if (totalDays <= 84) {
          // 28일 이하면 주 단위 (7일씩)
          final weeks = (totalDays / 7).ceil();
          return List.generate(weeks, (i) => firstDay.add(Duration(days: i * 7)));
        } else {
          // 그 이상이면 월 단위
          final months = ((today.year - firstDay.year) * 12 + today.month - firstDay.month) + 1;
          return List.generate(months, (i) => DateTime(firstDay.year, firstDay.month + i, 1));
        }
    }
  }

  double getBarChartWidth(bool isMobileView, DateTime userCreatedAt) {
    final today = DateUtils.dateOnly(DateTime.now());

    switch (this) {
      case TimeSavedViewType.last7days:
      case TimeSavedViewType.thisWeek:
        return 24;
      case TimeSavedViewType.last14days:
        return 16;
      case TimeSavedViewType.last28days:
      case TimeSavedViewType.thisMonth:
        return 10;
      case TimeSavedViewType.last12weeks:
      case TimeSavedViewType.thisYear:
        return 20;
      case TimeSavedViewType.last12months:
        return 20;
      case TimeSavedViewType.total:
        final firstDay = DateUtils.dateOnly(userCreatedAt);
        final totalDays = today.difference(firstDay).inDays + 1;

        if (totalDays <= 7) {
          return 24;
        } else if (totalDays <= 84) {
          return 10;
        } else {
          return 20;
        }
    }
  }

  String getTooltipMessage(BuildContext context) {
    switch (this) {
      case TimeSavedViewType.last7days:
      case TimeSavedViewType.last14days:
      case TimeSavedViewType.last28days:
      case TimeSavedViewType.last12weeks:
      case TimeSavedViewType.last12months:
        return '${context.tr.time_saved_saved_in_the} ${getTitle(context).toLowerCase()}';
      case TimeSavedViewType.thisWeek:
      case TimeSavedViewType.total:
      case TimeSavedViewType.thisMonth:
        return '${context.tr.time_saved_saved_in} ${getTitle(context).toLowerCase()}';
      case TimeSavedViewType.thisYear:
        return '${context.tr.time_saved_saved} ${getTitle(context).toLowerCase()}';
    }
  }

  String getShareText(BuildContext context, String hourText, String moneyText) {
    switch (this) {
      case TimeSavedViewType.last7days:
      case TimeSavedViewType.last14days:
      case TimeSavedViewType.last28days:
      case TimeSavedViewType.last12weeks:
      case TimeSavedViewType.last12months:
        return '${context.tr.time_saved_taskey_helped_you_save(hourText, moneyText)} ${context.tr.time_saved_in_the(getTitle(context).toLowerCase())}';
      case TimeSavedViewType.thisWeek:
      case TimeSavedViewType.thisMonth:
      case TimeSavedViewType.thisYear:
        return '${context.tr.time_saved_taskey_helped_you_save(hourText, moneyText)} ${getTitle(context).toLowerCase()}';
      case TimeSavedViewType.total:
        return '${context.tr.time_saved_taskey_helped_you_save(hourText, moneyText)} ${context.tr.time_saved_in(getTitle(context).toLowerCase())}';
    }
  }
}

enum TimeSavedShareType { x, linkedin, facebook, reddit, thread, share, download }

extension TimeSavedShareTypeX on TimeSavedShareType {
  bool get isSocial {
    switch (this) {
      case TimeSavedShareType.x:
      case TimeSavedShareType.linkedin:
      case TimeSavedShareType.facebook:
      case TimeSavedShareType.reddit:
      case TimeSavedShareType.thread:
        return true;
      case TimeSavedShareType.share:
      case TimeSavedShareType.download:
        return false;
    }
  }

  String get imagePath {
    switch (this) {
      case TimeSavedShareType.x:
        return '${(kDebugMode && kIsWeb) ? "" : "assets/"}logos/social_x.png';
      case TimeSavedShareType.linkedin:
        return '${(kDebugMode && kIsWeb) ? "" : "assets/"}logos/social_linkedin.png';
      case TimeSavedShareType.facebook:
        return '${(kDebugMode && kIsWeb) ? "" : "assets/"}logos/social_facebook.png';
      case TimeSavedShareType.reddit:
        return '${(kDebugMode && kIsWeb) ? "" : "assets/"}logos/social_reddit.png';
      case TimeSavedShareType.thread:
        return '${(kDebugMode && kIsWeb) ? "" : "assets/"}logos/social_thread.png';
      case TimeSavedShareType.share:
        return '';
      case TimeSavedShareType.download:
        return '';
    }
  }

  VisirIconType? get icon {
    switch (this) {
      case TimeSavedShareType.share:
        return VisirIconType.share;
      case TimeSavedShareType.download:
        return VisirIconType.download;
      case TimeSavedShareType.x:
      case TimeSavedShareType.linkedin:
      case TimeSavedShareType.facebook:
      case TimeSavedShareType.reddit:
      case TimeSavedShareType.thread:
        return null;
    }
  }

  String getHoverMessage(BuildContext context) {
    switch (this) {
      case TimeSavedShareType.share:
        return context.tr.time_saved_share;
      case TimeSavedShareType.download:
        return context.tr.time_saved_download_image;
      case TimeSavedShareType.x:
      case TimeSavedShareType.linkedin:
      case TimeSavedShareType.facebook:
      case TimeSavedShareType.reddit:
      case TimeSavedShareType.thread:
        return this.name[0].toUpperCase() + this.name.substring(1);
    }
  }
}

class TimeSavedScreen extends ConsumerStatefulWidget {
  final void Function()? closeOnMobile;

  const TimeSavedScreen({super.key, this.closeOnMobile});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TimeSavedScreenState();
}

class _TimeSavedScreenState extends ConsumerState<TimeSavedScreen> {
  ScreenshotController screenshotController = ScreenshotController();

  late double hourlyWage;
  double minimumHourlyWage = 10;
  double maximumHourlyWage = 9999;
  double sliderMaximumHourlyWage = 250;

  int showMoreCount = 3;

  bool showMore = false;
  bool isEditingWage = false;
  late TextEditingController _wageController;

  bool get isDarkMode => context.isDarkMode;
  bool get isMobileView => PlatformX.isMobileView;

  int get userTotalDays => ref.read(authControllerProvider.select((v) => v.requireValue.userTotalDays));
  double get totalSavedTimeInHours => ref.read(totalUserActionSwitchListControllerProvider.select((v) => v.value?.userActions.totalWastedTime ?? 0));
  int get totalAppSwitches => ref.read(totalUserActionSwitchListControllerProvider.select((v) => v.value?.userActions.totalCount ?? 0));

  ScrollController? _scrollController;
  TimeSavedShareType? onLoadingShareType;

  @override
  void initState() {
    super.initState();
    hourlyWage = ref.read(hourlyWageProvider);

    _wageController = TextEditingController(text: '\$${hourlyWage.round()}');
    final user = ref.read(authControllerProvider).requireValue;
    logAnalyticsEvent(eventName: user.onTrial ? 'trial_time_saved' : 'time_saved');
  }

  @override
  void dispose() {
    _scrollController?.dispose();

    _wageController.dispose();
    widget.closeOnMobile?.call();
    super.dispose();
  }

  void toggleEditMode() {
    setState(() {
      isEditingWage = !isEditingWage;
      if (isEditingWage) {
        _wageController.text = '\$${hourlyWage.round()}';
      }
    });
  }

  void finishEditing() {
    final text = _wageController.text;
    final numberText = text.replaceFirst('\$', '');
    final newValue = double.tryParse(numberText);
    if (newValue != null) {
      final clampedValue = newValue.clamp(minimumHourlyWage, maximumHourlyWage);
      setHourlyWage(value: clampedValue);
    }
    setState(() {
      isEditingWage = false;
    });
  }

  bool _onKeyDown(KeyEvent event, {bool? justReturnResult}) {
    if (ServicesBinding.instance.keyboard.logicalKeysPressed.length == 1) {
      if (ServicesBinding.instance.keyboard.logicalKeysPressed.contains(LogicalKeyboardKey.escape)) {
        if (justReturnResult == true) return true;
        if (isEditingWage) {
          finishEditing();
          return true;
        }
        close();
        return true;
      } else if (ServicesBinding.instance.keyboard.logicalKeysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        if (justReturnResult == true) return true;
        if (isEditingWage) return false;
        FocusManager.instance.primaryFocus?.unfocus();
        setHourlyWage(value: hourlyWage + 1);
        return true;
      } else if (ServicesBinding.instance.keyboard.logicalKeysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
        if (justReturnResult == true) return true;
        if (isEditingWage) return false;
        FocusManager.instance.primaryFocus?.unfocus();
        setHourlyWage(value: hourlyWage - 1);
        return true;
      } else if (ServicesBinding.instance.keyboard.logicalKeysPressed.contains(LogicalKeyboardKey.tab)) {
        if (isEditingWage) {
          finishEditing();
          return true;
        }
      }
    }

    return false;
  }

  void close() {
    if (widget.closeOnMobile != null) {
      widget.closeOnMobile!();
      return;
    } else {
      Navigator.of(Utils.mainContext).maybePop();
    }
  }

  void setHourlyWage({required double value}) {
    if (value < minimumHourlyWage) value = minimumHourlyWage;
    if (value > maximumHourlyWage) value = maximumHourlyWage;
    hourlyWage = value;

    if (!isEditingWage) {
      _wageController.text = '\$${hourlyWage.round()}';
    }

    setState(() {});

    EasyDebounce.debounce('time_saved_change_hourly_wage', const Duration(milliseconds: 250), () {
      ref.read(hourlyWageProvider.notifier).update(hourlyWage);
      logAnalyticsEvent(eventName: 'time_saved_change_hourly_wage');
    });
  }

  Widget summarySection() {
    final totalSavedMoney = totalSavedTimeInHours * hourlyWage;
    final projectedAnnualSavings = totalSavedMoney / userTotalDays * 365;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.maxFinite,
          padding: EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: context.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: context.tr.time_saved_projection_description_first,
                  style: context.titleMedium?.textColor(context.onInverseSurface).appFont(context),
                ),
                TextSpan(
                  text: context.tr.time_saved_projection_days(userTotalDays),
                  style: context.titleMedium?.textColor(context.outlineVariant).appFont(context).textBold,
                ),
                TextSpan(
                  text: context.tr.time_saved_projection_description_second,
                  style: context.titleMedium?.textColor(context.onInverseSurface).appFont(context),
                ),
                TextSpan(
                  text: context.tr.time_saved_projection_app_switches(Utils.numberFormatter(totalAppSwitches.toDouble())),
                  style: context.titleMedium?.textColor(context.outlineVariant).appFont(context).textBold,
                ),
                TextSpan(
                  text: context.tr.time_saved_projection_description_third,
                  style: context.titleMedium?.textColor(context.onInverseSurface).appFont(context),
                ),
                TextSpan(
                  text: context.tr.time_saved_projection_hours(totalSavedTimeInHours.toStringAsFixed(1)),
                  style: context.titleMedium?.textColor(context.outlineVariant).appFont(context).textBold,
                ),
                TextSpan(
                  text: context.tr.time_saved_projection_description_fourth,
                  style: context.titleMedium?.textColor(context.onInverseSurface).appFont(context),
                ),
                TextSpan(
                  text: '\$${Utils.numberFormatter(totalSavedMoney)}',
                  style: context.titleMedium?.textColor(context.outlineVariant).appFont(context).textBold,
                ),
                TextSpan(
                  text: context.tr.time_saved_projection_description_fifth,
                  style: context.titleMedium?.textColor(context.onInverseSurface).appFont(context),
                ),
                TextSpan(
                  text: '\$${Utils.numberFormatter(projectedAnnualSavings)}',
                  style: context.titleMedium?.textColor(context.primary).appFont(context).textBold,
                ),
                TextSpan(text: '.', style: context.titleMedium?.textColor(context.onInverseSurface).appFont(context)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Stack(
          children: [
            Container(
              width: double.maxFinite,
              padding: EdgeInsets.only(top: 12, left: 16, right: 8, bottom: 18),
              decoration: ShapeDecoration(
                color: context.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      const SizedBox(height: 8),
                      Text(context.tr.time_saved_hourly_wage, style: context.titleSmall?.textColor(context.shadow)),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 8 + (isMobileView ? 30 : 144)),
                            Expanded(
                              child: Container(
                                child: GestureDetector(
                                  onTap: toggleEditMode,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                        decoration: ShapeDecoration(
                                          color: isEditingWage ? context.primary.withAlpha(25) : Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(width: 1, color: isEditingWage ? context.primary : context.surfaceTint),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(minWidth: 48),
                                          child: IntrinsicWidth(
                                            child: isEditingWage
                                                ? TextFormField(
                                                    controller: _wageController,
                                                    textAlign: TextAlign.center,
                                                    keyboardType: TextInputType.number,
                                                    inputFormatters: [DollarSignProtector()],
                                                    style: context.titleMedium?.textColor(context.primary).textBold.appFont(context),
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      fillColor: Colors.transparent,
                                                      focusColor: Colors.transparent,
                                                      hoverColor: Colors.transparent,
                                                      contentPadding: EdgeInsets.zero,
                                                    ),
                                                    onFieldSubmitted: (value) => finishEditing(),
                                                    onEditingComplete: finishEditing,
                                                    onTapOutside: (event) => finishEditing(),
                                                    autofocus: true,
                                                  )
                                                : Text(
                                                    '\$${hourlyWage.round()}',
                                                    textAlign: TextAlign.center,
                                                    style: context.titleMedium
                                                        ?.textColor(isDarkMode ? context.outlineVariant : context.shadow)
                                                        .textBold
                                                        .appFont(context),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        context.tr.time_saved_per_hour,
                                        style: context.titleMedium?.textColor(isDarkMode ? context.outlineVariant : context.shadow).textBold.appFont(context),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8 + (isMobileView ? 30 : 144)),
                          ],
                        ),
                        FlutterSlider(
                          values: [min(hourlyWage, sliderMaximumHourlyWage)],
                          max: sliderMaximumHourlyWage,
                          min: minimumHourlyWage,
                          onDragging: (handlerIndex, lowerValue, upperValue) {
                            setHourlyWage(value: lowerValue);
                          },
                          tooltip: FlutterSliderTooltip(disabled: true),
                          trackBar: FlutterSliderTrackBar(
                            inactiveTrackBar: BoxDecoration(borderRadius: BorderRadius.circular(4), color: context.surfaceVariant),
                            activeTrackBar: BoxDecoration(borderRadius: BorderRadius.circular(4), color: context.primary),
                          ),
                          handlerHeight: 16,
                          handlerWidth: 16,
                          handler: FlutterSliderHandler(
                            decoration: BoxDecoration(),
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: ShapeDecoration(color: isDarkMode ? context.outlineVariant : context.background, shape: OvalBorder()),
                            ),
                          ),
                        ),
                        Stack(
                          children: [
                            Container(height: 14, width: double.maxFinite, color: Colors.transparent),
                            Transform.translate(
                              offset: Offset(0, -4),
                              child: Row(
                                children: [
                                  const SizedBox(width: 8),
                                  Text('\$${minimumHourlyWage.round()}', style: context.bodyMedium?.textColor(context.inverseSurface)),
                                  Expanded(child: Container()),
                                  Text('\$${sliderMaximumHourlyWage.round()}', style: context.bodyMedium?.textColor(context.inverseSurface)),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Tooltip(
                showDuration: Duration(days: 1),
                triggerMode: PlatformX.isMobile ? TooltipTriggerMode.tap : null,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                richMessage: TextSpan(
                  children: [
                    WidgetSpan(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 200),
                        child: Text(
                          context.tr.time_saved_hourly_wage_only_device,
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
            ),
          ],
        ),
      ],
    );
  }

  Widget savingsTrendSection() {
    UserEntity? user = ref.watch(authControllerProvider.select((v) => v.requireValue));
    final viewType = ref.watch(timeSavedViewTypeProvider);
    Map<DateTime, List<UserActionSwitchCountEntity>> data = ref.watch(timeSavedListControllerProvider).value ?? {};

    bool includeDummyData = data.entries.length < 4;

    if (includeDummyData) {
      final firstKey = data.entries.firstOrNull?.key;
      final lastKey = data.entries.lastOrNull?.key;
      if (firstKey != null && lastKey != null) {
        data = {firstKey.subtract(Duration(days: 1)): [], ...data, lastKey.add(Duration(days: 1)): []};
      }
    }

    Map<DateTime, double> groupedSavingsBarChartData = data.map((key, value) => MapEntry(key, value.totalWastedTime * hourlyWage));
    double maxValue = max(10, [...groupedSavingsBarChartData.values, 0.0, 0.0, 0.0].reduce((a, b) => a > b ? a : b));

    // 최대값보다 큰 15의 배수로 설정
    if (maxValue > 0) {
      maxValue = ((maxValue / 15).ceil() * 15).toDouble();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr.time_saved_trend, style: context.titleMedium?.textColor(isDarkMode ? context.outlineVariant : context.shadow).textBold),
        const SizedBox(height: 16),
        Container(
          width: double.maxFinite,
          height: 156,
          padding: EdgeInsets.only(bottom: 10, top: 16, left: 14, right: 25),
          decoration: ShapeDecoration(
            color: context.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: BarChart(
            duration: Duration(milliseconds: 0),
            BarChartData(
              alignment: BarChartAlignment.spaceBetween,
              maxY: maxValue,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                drawHorizontalLine: true,
                horizontalInterval: (maxValue / 3),
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: context.surfaceVariant, strokeWidth: 1);
                },
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  top: BorderSide(color: context.surfaceVariant, width: 1),
                  bottom: BorderSide(color: context.surfaceVariant, width: 1),
                  left: BorderSide(color: Colors.transparent, width: 4),
                  right: BorderSide(color: Colors.transparent, width: 4),
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    interval: (maxValue / 3),
                    minIncluded: false,
                    getTitlesWidget: (value, meta) {
                      return Text('\$${Utils.numberFormatter(value)}', style: context.bodyMedium?.textColor(context.onInverseSurface));
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 26,
                    getTitlesWidget: (value, meta) {
                      int length = data.entries.length;
                      final date = data.entries.elementAt(value.toInt()).key;

                      if (includeDummyData) {
                        if (value.toInt() == 0 || value.toInt() == length - 1) {
                          return const SizedBox.shrink();
                        }
                      }

                      bool hideLabel = false;

                      if (PlatformX.isMobileView) {
                        if (length > 26) {
                          hideLabel = value.toInt() % 3 != 0;
                        } else if (length > 13) {
                          hideLabel = value.toInt() % 2 != 0;
                        }
                      } else {
                        if (length > 28) {
                          hideLabel = value.toInt() % 3 != 0;
                        } else if (length > 13) {
                          hideLabel = value.toInt() % 2 != 0;
                        }
                      }

                      String labelString = '';

                      final firstDay = DateUtils.dateOnly(user?.createdAt ?? DateUtils.dateOnly(DateTime.now()));
                      final totalDays = DateUtils.dateOnly(DateTime.now()).difference(firstDay).inDays + 1;

                      switch (viewType) {
                        case TimeSavedViewType.last7days:
                        case TimeSavedViewType.last14days:
                        case TimeSavedViewType.last28days:
                        case TimeSavedViewType.last12weeks:
                        case TimeSavedViewType.thisMonth:
                          labelString = '${date.month}/${date.day}';
                        case TimeSavedViewType.last12months:
                        case TimeSavedViewType.thisYear:
                          labelString = DateFormat('MMM').format(date);
                        case TimeSavedViewType.thisWeek:
                          labelString = DateFormat('EEE').format(date);
                        case TimeSavedViewType.total:
                          if (totalDays <= 84) {
                            labelString = '${date.month}/${date.day}';
                          } else {
                            labelString = DateFormat('MMM').format(date);
                          }
                      }

                      return hideLabel
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Text(labelString, style: context.bodyMedium?.textColor(context.inverseSurface)),
                            );
                    },
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barGroups: groupedSavingsBarChartData.entries.mapIndexed((index, e) {
                bool isFirst = index == 0;
                bool isLast = index == groupedSavingsBarChartData.entries.length - 1;
                return getBarChartGroupData(e.value, index, user?.createdAt ?? DateUtils.dateOnly(DateTime.now()), includeDummyData && (isFirst || isLast));
              }).toList(),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBorderRadius: BorderRadius.circular(4),
                  tooltipPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  tooltipMargin: 6,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem('\$${Utils.numberFormatter(rod.toY)}', context.bodyMedium!.textColor(context.onBackground));
                  },
                  getTooltipColor: (data) {
                    return context.surfaceVariant;
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData getBarChartGroupData(double value, int index, DateTime userCreatedAt, bool isDummyData) {
    final viewType = ref.watch(timeSavedViewTypeProvider);
    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: max(value, isDummyData ? 0 : 0.01),
          width: viewType.getBarChartWidth(isMobileView, userCreatedAt),
          color: context.primary,
          borderRadius: BorderRadius.circular(2),
        ),
      ],
    );
  }

  Widget descriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.tr.time_saved_calculation_method, style: context.titleLarge?.textColor(isDarkMode ? context.outlineVariant : context.shadow).textBold),
        const SizedBox(height: 16),
        Text(context.tr.time_saved_hidden_coast, style: context.titleMedium?.textColor(isDarkMode ? context.outlineVariant : context.shadow).textBold),
        const SizedBox(height: 16),
        Text(context.tr.time_saved_opening_apps_title, style: context.titleSmall?.textColor(context.shadow).textBold),
        const SizedBox(height: 8),
        Text(context.tr.time_saved_opening_apps_description, style: context.titleSmall?.textColor(context.onInverseSurface)),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(context.tr.time_saved_ease_switch_title, style: context.titleSmall?.textColor(context.shadow).textBold),
            Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Tooltip(
                showDuration: Duration(days: 1),
                triggerMode: PlatformX.isMobile ? TooltipTriggerMode.tap : null,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                verticalOffset: 15,
                richMessage: TextSpan(
                  children: [
                    WidgetSpan(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 200),
                        child: Text(
                          context.tr.time_saved_according_to_research,
                          style: context.bodyMedium?.textColor(context.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
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
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(context.tr.time_saved_ease_switch_description, style: context.titleSmall?.textColor(context.onInverseSurface)),
        const SizedBox(height: 16),
        Text(context.tr.time_saved_how_solved_title, style: context.titleSmall?.textColor(context.shadow).textBold),
        const SizedBox(height: 8),
        Text(context.tr.time_saved_how_solved_description, style: context.titleSmall?.textColor(context.onInverseSurface)),
      ],
    );
  }

  Widget mostFrequentTransitionSection(List<UserActionSwitchCountEntity> userActionSwitchCountListOnShow, bool shorterThenShowMoreCount) {
    userActionSwitchCountListOnShow.sort((a, b) => b.count.compareTo(a.count));
    final firstCalendarIndex = userActionSwitchCountListOnShow.indexWhere((e) => e.isCalendar);
    if (!showMore) userActionSwitchCountListOnShow = userActionSwitchCountListOnShow.take(showMoreCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr.time_saved_most_frequent_transitions,
          style: context.titleMedium?.textColor(isDarkMode ? context.outlineVariant : context.shadow).textBold,
        ),
        const SizedBox(height: 19),
        ...userActionSwitchCountListOnShow.mapIndexed((index, e) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: TransitionCountWidget(switchCount: e, isFirstCalendar: firstCalendarIndex == index),
          );
        }).toList(),
        if (!showMore && !shorterThenShowMoreCount)
          Padding(
            padding: EdgeInsets.only(top: 4),
            child: Center(
              child: VisirButton(
                type: VisirButtonAnimationType.scaleAndOpacity,
                style: VisirButtonStyle(cursor: SystemMouseCursors.click, padding: EdgeInsets.all(4), hoverColor: Colors.transparent),
                onTap: () {
                  showMore = !showMore;
                  setState(() {});
                },
                child: Text(context.tr.time_saved_load_more, style: context.titleSmall?.textColor(isDarkMode ? context.inverseSurface : context.surfaceTint)),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _scrollController ??= ModalScrollController.ofSyncGroup(context)?.addAndGet() ?? ScrollController();
    ref.watch(defaultUserActionSwitchListControllerProvider);

    final timeSavedList = ref.watch(timeSavedListControllerProvider.notifier).mergedUserActionSwitchList;

    bool shorterThenShowMoreCount = timeSavedList.length <= showMoreCount;
    final backgroundColor = context.background;

    return KeyboardShortcut(
      onKeyDown: _onKeyDown,
      bypassTextField: true,
      child: Material(
        color: backgroundColor,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              VisirAppBar(
                title: context.tr.time_saved_screen_title,
                leadings: isMobileView
                    ? [VisirAppBarButton(icon: VisirIconType.arrowLeft, onTap: close)]
                    : [
                        VisirAppBarButton(
                          icon: VisirIconType.close,
                          onTap: close,
                          options: VisirButtonOptions(
                            tooltipLocation: VisirButtonTooltipLocation.right,
                            shortcuts: isEditingWage
                                ? null
                                : [
                                    VisirButtonKeyboardShortcut(message: context.tr.close, keys: [LogicalKeyboardKey.escape]),
                                  ],
                          ),
                        ),
                      ],
                trailings: [],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: Utils.getScrollPhysicsForBottomSheet(context, _scrollController),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16),
                          summarySection(),
                          SizedBox(height: 32),
                          YourSavingWidget(),
                          SizedBox(height: 24),
                          savingsTrendSection(),
                          SizedBox(height: 24),
                          if (timeSavedList.isNotEmpty) mostFrequentTransitionSection(timeSavedList, shorterThenShowMoreCount),
                          if (timeSavedList.isNotEmpty) SizedBox(height: 24),
                          descriptionSection(),
                          SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// $ 기호를 보호하는 커스텀 TextInputFormatter
class DollarSignProtector extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // $ 기호가 없으면 추가
    if (!text.startsWith('\$')) {
      final cleanText = text.replaceAll('\$', '');
      return TextEditingValue(
        text: '\$$cleanText',
        selection: TextSelection.collapsed(offset: cleanText.length + 1),
      );
    }

    // $ 기호 이후의 숫자만 허용 (최대 4자리)
    final numberPart = text.substring(1).replaceAll(RegExp(r'[^0-9]'), '');
    final limitedNumberPart = numberPart.length > 4 ? numberPart.substring(0, 4) : numberPart;
    final result = '\$$limitedNumberPart';

    // 커서 위치 조정
    int cursorPosition = newValue.selection.baseOffset;
    if (cursorPosition < 1) cursorPosition = 1; // $ 기호 이전으로 커서가 가지 않도록
    if (cursorPosition > result.length) cursorPosition = result.length; // 텍스트 길이를 초과하지 않도록

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}
