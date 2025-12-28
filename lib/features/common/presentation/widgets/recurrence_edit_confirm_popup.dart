import 'package:Visir/features/calendar/application/calendar_event_list_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/custom_circualr_loading_indicator.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum RecurringTaskEditType { thisTaskOnly, thisAndFollowingTasks, allTasks }

extension RecurringTaskEditTypeX on RecurringTaskEditType {
  String getTitle(BuildContext context) {
    switch (this) {
      case RecurringTaskEditType.thisTaskOnly:
        return context.tr.this_task_only;
      case RecurringTaskEditType.thisAndFollowingTasks:
        return context.tr.this_and_following_tasks;
      case RecurringTaskEditType.allTasks:
        return context.tr.all_tasks;
    }
  }
}

class RecurrenceEditConfirmPopup extends ConsumerStatefulWidget {
  final bool isTask;

  const RecurrenceEditConfirmPopup({super.key, required this.isTask});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RecurrenceEditConfirmPopupState();
}

class _RecurrenceEditConfirmPopupState extends ConsumerState<RecurrenceEditConfirmPopup> {
  bool onProcess = false;

  bool get isMobileView => PlatformX.isMobileView;

  RecurringTaskEditType selectedTaskEditType = RecurringTaskEditType.thisTaskOnly;
  RecurringEventEditType selectedEventEditType = RecurringEventEditType.thisEventOnly;

  Future<void> onPressConfirm() async {
    if (onProcess) return;

    setState(() {
      onProcess = true;
    });

    if (widget.isTask) {
      Navigator.of(Utils.mainContext).pop(selectedTaskEditType);
    } else {
      Navigator.of(Utils.mainContext).pop(selectedEventEditType);
    }
  }

  void updateOption({required RecurringTaskEditType taskEditType, required RecurringEventEditType eventEditType}) {
    setState(() {
      if (widget.isTask) {
        selectedTaskEditType = taskEditType;
      } else {
        selectedEventEditType = eventEditType;
      }
    });
  }

  Widget optionButton({required RecurringTaskEditType taskEditType, required RecurringEventEditType eventEditType}) {
    bool isSelected = widget.isTask ? selectedTaskEditType == taskEditType : selectedEventEditType == eventEditType;

    return VisirButton(
      type: VisirButtonAnimationType.scaleAndOpacity,
      style: VisirButtonStyle(
        height: 40,
        width: isMobileView ? null : 304,
        backgroundColor: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      onTap: () {
        updateOption(eventEditType: eventEditType, taskEditType: taskEditType);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          isSelected
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: ShapeDecoration(
                        shape: OvalBorder(side: BorderSide(width: 2, color: context.primary)),
                      ),
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: ShapeDecoration(color: context.primary, shape: OvalBorder()),
                    ),
                  ],
                )
              : Container(
                  width: 20,
                  height: 20,
                  decoration: ShapeDecoration(
                    shape: OvalBorder(side: BorderSide(width: 2, color: context.onInverseSurface)),
                  ),
                ),
          const SizedBox(width: 14),
          Text(widget.isTask ? taskEditType.getTitle(context) : eventEditType.getTitle(context), style: context.titleSmall?.textColor(context.shadow)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: isMobileView ? 0 : 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isMobileView)
            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 12),
              child: Text(
                widget.isTask ? context.tr.edit_recurring_task : context.tr.edit_recurring_event,
                style: context.titleMedium?.textColor(context.outlineVariant).textBold,
              ),
            ),
          optionButton(taskEditType: RecurringTaskEditType.thisTaskOnly, eventEditType: RecurringEventEditType.thisEventOnly),
          optionButton(taskEditType: RecurringTaskEditType.thisAndFollowingTasks, eventEditType: RecurringEventEditType.thisAndFutureEvents),
          optionButton(taskEditType: RecurringTaskEditType.allTasks, eventEditType: RecurringEventEditType.allEvents),
          const SizedBox(height: 12),
          isMobileView
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: VisirButton(
                          type: VisirButtonAnimationType.scaleAndOpacity,
                          style: VisirButtonStyle(
                            height: 48,
                            backgroundColor: context.surface,
                            borderRadius: BorderRadius.circular(10),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          ),
                          onTap: () => context.pop(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Text(context.tr.cancel, style: context.titleSmall?.textColor(context.outlineVariant))],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: VisirButton(
                          type: VisirButtonAnimationType.scaleAndOpacity,
                          style: VisirButtonStyle(
                            height: 48,
                            backgroundColor: context.primary,
                            borderRadius: BorderRadius.circular(10),
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                          ),
                          onTap: onPressConfirm,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              onProcess
                                  ? CustomCircularLoadingIndicator(size: 18, color: context.outlineVariant)
                                  : Text(context.tr.ok, style: context.titleSmall?.textColor(context.onPrimary)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    VisirButton(
                      type: VisirButtonAnimationType.scaleAndOpacity,
                      style: VisirButtonStyle(
                        height: 36,
                        width: 288,
                        backgroundColor: context.primary,
                        borderRadius: BorderRadius.circular(8),
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      ),
                      options: VisirButtonOptions(
                        customShortcutTooltip: '',
                        tooltipLocation: VisirButtonTooltipLocation.none,
                        shortcuts: [
                          VisirButtonKeyboardShortcut(keys: [LogicalKeyboardKey.enter], message: context.tr.ok),
                          VisirButtonKeyboardShortcut(
                            keys: [LogicalKeyboardKey.arrowDown],
                            message: '',
                            onTrigger: () {
                              if (widget.isTask) {
                                switch (selectedTaskEditType) {
                                  case RecurringTaskEditType.thisTaskOnly:
                                    updateOption(taskEditType: RecurringTaskEditType.thisAndFollowingTasks, eventEditType: selectedEventEditType);
                                  case RecurringTaskEditType.thisAndFollowingTasks:
                                    updateOption(taskEditType: RecurringTaskEditType.allTasks, eventEditType: selectedEventEditType);
                                  case RecurringTaskEditType.allTasks:
                                    updateOption(taskEditType: RecurringTaskEditType.thisTaskOnly, eventEditType: selectedEventEditType);
                                }
                              } else {
                                switch (selectedEventEditType) {
                                  case RecurringEventEditType.thisEventOnly:
                                    updateOption(taskEditType: selectedTaskEditType, eventEditType: RecurringEventEditType.thisAndFutureEvents);
                                  case RecurringEventEditType.thisAndFutureEvents:
                                    updateOption(taskEditType: selectedTaskEditType, eventEditType: RecurringEventEditType.allEvents);
                                  case RecurringEventEditType.allEvents:
                                    updateOption(taskEditType: selectedTaskEditType, eventEditType: RecurringEventEditType.thisEventOnly);
                                  default:
                                    break;
                                }
                              }

                              return true;
                            },
                          ),
                          VisirButtonKeyboardShortcut(
                            keys: [LogicalKeyboardKey.arrowUp],
                            message: '',
                            onTrigger: () {
                              if (widget.isTask) {
                                switch (selectedTaskEditType) {
                                  case RecurringTaskEditType.thisTaskOnly:
                                    updateOption(taskEditType: RecurringTaskEditType.allTasks, eventEditType: selectedEventEditType);
                                  case RecurringTaskEditType.thisAndFollowingTasks:
                                    updateOption(taskEditType: RecurringTaskEditType.thisTaskOnly, eventEditType: selectedEventEditType);
                                  case RecurringTaskEditType.allTasks:
                                    updateOption(taskEditType: RecurringTaskEditType.thisAndFollowingTasks, eventEditType: selectedEventEditType);
                                }
                              } else {
                                switch (selectedEventEditType) {
                                  case RecurringEventEditType.thisEventOnly:
                                    updateOption(taskEditType: selectedTaskEditType, eventEditType: RecurringEventEditType.allEvents);
                                  case RecurringEventEditType.thisAndFutureEvents:
                                    updateOption(taskEditType: selectedTaskEditType, eventEditType: RecurringEventEditType.thisEventOnly);
                                  case RecurringEventEditType.allEvents:
                                    updateOption(taskEditType: selectedTaskEditType, eventEditType: RecurringEventEditType.thisAndFutureEvents);
                                  default:
                                    break;
                                }
                              }

                              return true;
                            },
                          ),
                        ],
                      ),
                      onTap: onPressConfirm,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          onProcess
                              ? CustomCircularLoadingIndicator(size: 18, color: context.outlineVariant)
                              : Text(context.tr.ok, style: context.titleSmall?.textColor(context.onPrimary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    VisirButton(
                      type: VisirButtonAnimationType.scaleAndOpacity,
                      style: VisirButtonStyle(
                        height: 36,
                        width: 288,
                        backgroundColor: context.surface,
                        borderRadius: BorderRadius.circular(8),
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      ),
                      onTap: () => context.pop(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Text(context.tr.cancel, style: context.titleSmall?.textColor(context.outlineVariant))],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
        ],
      ),
    );
  }
}
