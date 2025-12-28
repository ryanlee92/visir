import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/dependency/master_detail_flow/src/details_item.dart';
import 'package:Visir/dependency/modal_bottom_sheet/src/utils/modal_scroll_controller.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/selection_widget.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_item.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_section.dart';
import 'package:Visir/features/preference/presentation/screens/preference_screen.dart';
import 'package:Visir/features/preference/presentation/widgets/notification/task_notification_preference_widget.dart';
import 'package:Visir/features/task/domain/entities/task_reminder_option_type.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskPrefScreen extends ConsumerStatefulWidget {
  final bool isSmall;
  final VoidCallback? onClose;

  const TaskPrefScreen({required this.isSmall, this.onClose});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TaskPrefScreenState();
}

class _TaskPrefScreenState extends ConsumerState<TaskPrefScreen> {
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController?.dispose();

    widget.onClose?.call();
    super.dispose();
  }

  String getWeekStartString(int? weekday) {
    if (weekday == 0) return context.tr.today;
    if (weekday == 7) return context.tr.sunday;
    if (weekday == 1) return context.tr.monday;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    _scrollController ??= ModalScrollController.ofSyncGroup(context)?.addAndGet() ?? ScrollController();

    // final taskColorHex = ref.watch(authControllerProvider.select((e) => e.requireValue.userTaskColorHex));
    final taskDefaultDurationInMinutes = ref.watch(authControllerProvider.select((e) => e.requireValue.userTaskDefaultDurationInMinutes));
    final defaultTaskReminderType = ref.watch(authControllerProvider.select((e) => e.requireValue.userDefaultTaskReminderType));
    final defaultAllDayTaskReminderType = ref.watch(authControllerProvider.select((e) => e.requireValue.userDefaultAllDayTaskReminderType));
    final completedTaskOptionType = ref.watch(authControllerProvider.select((e) => e.requireValue.userCompletedTaskOptionType));
    final taskCompletionSound = ref.watch(authControllerProvider.select((e) => e.requireValue.userTaskCompletionSound));

    final buttonWidth = PreferenceScreen.buttonWidth;
    final buttonHeight = PreferenceScreen.buttonHeight;

    return DetailsItem(
      title: widget.isSmall ? context.tr.home_pref_title : null,
      hideBackButton: !widget.isSmall,
      scrollController: _scrollController,
      scrollPhysics: Utils.getScrollPhysicsForBottomSheet(context, _scrollController),
      appbarColor: context.background,
      bodyColor: context.background,

      children: [
        VisirListSection(
          removeTopMargin: true,
          titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.default_pref, style: baseStyle),
        ),

        // VisirListItem(
        //   verticalPaddingOverride: 0,
        //   titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.home_pref_default_task_color, style: baseStyle),
        //   titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
        //     children: [
        //       WidgetSpan(
        //         child: PopupMenu(
        //           forcePopup: true,
        //           location: PopupMenuLocation.bottom,
        //           width: buttonWidth,
        //           borderRadius: 6,
        //           type: ContextMenuActionType.tap,
        //           popup: TaskColorPickerWidget(
        //             color: ColorX.fromHex(taskColorHex),
        //             onColorSelected: (color) async {
        //               final user = ref.read(authControllerProvider).requireValue;
        //               await ref.read(authControllerProvider.notifier).updateUser(user: user.copyWith(taskColorHex: color.toHex()));
        //             },
        //           ),
        //           style: VisirButtonStyle(width: buttonWidth, height: buttonHeight, backgroundColor: context.surface, borderRadius: BorderRadius.circular(6)),
        //           child: Row(
        //             children: [
        //               SizedBox(width: 12),
        //               Container(
        //                 width: 14,
        //                 height: 14,
        //                 decoration: BoxDecoration(color: ColorX.fromHex(taskColorHex), borderRadius: BorderRadius.circular(4)),
        //               ),
        //               SizedBox(width: 6),
        //               Expanded(child: Text(Utils.getColorString(context, taskColorHex), style: context.bodyMedium?.textColor(context.outlineVariant))),
        //               SizedBox(width: 6),
        //               VisirIcon(type: VisirIconType.arrowDown, size: 12, color: context.outlineVariant),
        //               SizedBox(width: 10),
        //             ],
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        VisirListItem(
          verticalPaddingOverride: 0,
          titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.home_pref_default_task_duration, style: baseStyle),
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
                    current: taskDefaultDurationInMinutes,
                    items: [15, 30, 45, 60, 90, 120],
                    getTitle: (item) => Utils.getTimeString(context, item),
                    onSelect: (taskDefaultDurationInMinutes) async {
                      final user = ref.read(authControllerProvider).requireValue;
                      logAnalyticsEvent(eventName: 'default_task_duration', properties: {'duration': taskDefaultDurationInMinutes});
                      await ref
                          .read(authControllerProvider.notifier)
                          .updateUser(user: user.copyWith(taskDefaultDurationInMinutes: taskDefaultDurationInMinutes));
                    },
                  ),
                  style: VisirButtonStyle(width: buttonWidth, height: buttonHeight, backgroundColor: context.surface, borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    children: [
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(Utils.getTimeString(context, taskDefaultDurationInMinutes), style: context.bodyMedium?.textColor(context.outlineVariant)),
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

        VisirListItem(
          verticalPaddingOverride: 0,
          titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.home_pref_default_task_reminder, style: baseStyle),
          titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
            children: [
              WidgetSpan(
                child: PopupMenu(
                  forcePopup: true,
                  location: PopupMenuLocation.bottom,
                  width: buttonWidth,
                  borderRadius: 6,
                  type: ContextMenuActionType.tap,
                  popup: SelectionWidget<TaskReminderOptionType>(
                    current: defaultTaskReminderType,
                    items: [
                      TaskReminderOptionType.none,
                      TaskReminderOptionType.atTheStart,
                      TaskReminderOptionType.fiveMinutesBefore,
                      TaskReminderOptionType.tenMinutesBefore,
                      TaskReminderOptionType.thirtyMinutesBefore,
                      TaskReminderOptionType.hourBefore,
                      TaskReminderOptionType.dayBefore,
                    ],
                    getTitle: (type) => type.getSelectionOptionTitle(context, false),
                    onSelect: (type) async {
                      final user = ref.read(authControllerProvider).requireValue;
                      logAnalyticsEvent(eventName: 'default_task_reminder', properties: {'option': type.getSelectionOptionTitle(context, false)});
                      await ref.read(authControllerProvider.notifier).updateUser(user: user.copyWith(defaultTaskReminderType: type));
                    },
                  ),
                  style: VisirButtonStyle(width: buttonWidth, height: buttonHeight, backgroundColor: context.surface, borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    children: [
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          defaultTaskReminderType.getSelectionOptionTitle(context, false),
                          style: context.bodyMedium?.textColor(context.outlineVariant),
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

        VisirListItem(
          verticalPaddingOverride: 0,
          titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) =>
              TextSpan(text: context.tr.home_pref_default_all_day_task_reminder, style: baseStyle),
          titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
            children: [
              WidgetSpan(
                child: PopupMenu(
                  forcePopup: true,
                  location: PopupMenuLocation.bottom,
                  width: buttonWidth,
                  borderRadius: 6,
                  type: ContextMenuActionType.tap,
                  popup: SelectionWidget<TaskReminderOptionType>(
                    current: defaultAllDayTaskReminderType,
                    items: [TaskReminderOptionType.none, TaskReminderOptionType.nineHoursAfter, TaskReminderOptionType.fifteenHoursBefore],
                    getTitle: (type) => type.getSelectionOptionTitle(context, true),
                    onSelect: (type) async {
                      final user = ref.read(authControllerProvider).requireValue;
                      logAnalyticsEvent(eventName: 'default_all_day_task_reminder', properties: {'option': type.getSelectionOptionTitle(context, false)});
                      await ref.read(authControllerProvider.notifier).updateUser(user: user.copyWith(defaultAllDayTaskReminderType: type));
                    },
                  ),
                  style: VisirButtonStyle(width: buttonWidth, height: buttonHeight, backgroundColor: context.surface, borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    children: [
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          defaultAllDayTaskReminderType.getSelectionOptionTitle(context, true),
                          style: context.bodyMedium?.textColor(context.outlineVariant),
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

        VisirListSection(
          titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.pref_actions, style: baseStyle),
        ),

        VisirListItem(
          verticalPaddingOverride: 0,
          titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.home_pref_completed_tasks, style: baseStyle),
          titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
            children: [
              WidgetSpan(
                child: PopupMenu(
                  forcePopup: true,
                  location: PopupMenuLocation.bottom,
                  width: buttonWidth,
                  borderRadius: 6,
                  type: ContextMenuActionType.tap,
                  popup: SelectionWidget<CompletedTaskOptionType>(
                    current: completedTaskOptionType,
                    items: CompletedTaskOptionType.values,
                    getTitle: (value) => value.getTitle(context),
                    onSelect: (value) async {
                      final user = ref.read(authControllerProvider).requireValue;
                      logAnalyticsEvent(eventName: 'completed_tasks', properties: {'option': value.getTitle(context)});
                      await ref.read(authControllerProvider.notifier).updateUser(user: user.copyWith(completedTaskOptionType: value));
                    },
                  ),
                  style: VisirButtonStyle(width: buttonWidth, height: buttonHeight, backgroundColor: context.surface, borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    children: [
                      SizedBox(width: 12),
                      Expanded(child: Text(completedTaskOptionType.getTitle(context), style: context.bodyMedium?.textColor(context.outlineVariant))),
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

        if (!PlatformX.isAndroid)
          VisirListItem(
            verticalPaddingOverride: 0,
            titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.home_pref_task_completion_sound, style: baseStyle),
            titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
              children: [
                WidgetSpan(
                  child: AnimatedToggleSwitch<bool>.rolling(
                    current: taskCompletionSound,
                    values: [false, true],
                    height: PreferenceScreen.buttonHeight,
                    indicatorSize: Size(PreferenceScreen.buttonWidth / 2, PreferenceScreen.buttonHeight),
                    indicatorIconScale: 1,
                    iconOpacity: 0.5,
                    borderWidth: 0,
                    onChanged: (value) async {
                      final user = ref.read(authControllerProvider).requireValue;
                      logAnalyticsEvent(eventName: 'task_completion_sound', properties: {'value': value});
                      await ref.read(authControllerProvider.notifier).updateUser(user: user.copyWith(taskCompletionSound: value));
                    },
                    iconBuilder: (taskCompletionSound, selected) => VisirIcon(
                      type: taskCompletionSound ? VisirIconType.soundOn : VisirIconType.soundOff,
                      size: 16,
                      color: !selected
                          ? context.onBackground
                          : taskCompletionSound
                          ? context.onBackground
                          : context.error,
                      isSelected: true,
                    ),
                    style: ToggleStyle(
                      backgroundColor: context.surface,
                      borderRadius: BorderRadius.circular(6),
                      borderColor: context.surface.withValues(alpha: 1),
                      indicatorColor: context.surfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

        VisirListSection(
          titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.notification_pref_title, style: baseStyle),
        ),

        TaskNotificationPreferenceWidget(),
      ],
    );
  }
}
