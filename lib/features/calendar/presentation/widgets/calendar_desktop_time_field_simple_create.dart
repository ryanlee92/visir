import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart';
import 'package:Visir/dependency/omni_datetime_picker/omni_datetime_picker.dart';
import 'package:Visir/dependency/omni_datetime_picker/src/omni_datetime_picker.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_desktop_time_list_simple_create.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CalendarDesktopTimeFieldSimpleCreate extends ConsumerStatefulWidget {
  final DateTime selectedDateTime;
  final bool isAllDay;
  final bool isEndDateTime;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final double height;
  final void Function(DateTime dateTime) onDateChanged;

  CalendarDesktopTimeFieldSimpleCreate({
    Key? key,
    required this.selectedDateTime,
    required this.isAllDay,
    required this.isEndDateTime,
    required this.startDateTime,
    required this.endDateTime,
    required this.onDateChanged,
    required this.height,
  }) : super(key: key);

  @override
  ConsumerState createState() => _CalendarDesktopTimeFieldSimpleCreateState();
}

class _CalendarDesktopTimeFieldSimpleCreateState extends ConsumerState<CalendarDesktopTimeFieldSimpleCreate> {
  late DateTime selectedDateTime;
  late DateTime startDateTime;
  late DateTime endDateTime;

  FocusNode hourFocusNode = FocusNode();
  FocusNode minuteFocusNode = FocusNode();
  FocusNode meridiemFocusNode = FocusNode();

  late TextEditingController hourController;
  late TextEditingController minuteController;
  late TextEditingController meridiemController;

  late String hour;
  late String minute;
  late String meridiem;

  bool get isFocused => hourFocusNode.hasFocus || minuteFocusNode.hasFocus || meridiemFocusNode.hasFocus;

  bool get isAM => meridiem == 'AM';

  bool get isPM => meridiem == 'PM';

  bool get isDarkMode => context.isDarkMode;

  @override
  void initState() {
    super.initState();

    selectedDateTime = widget.selectedDateTime;
    startDateTime = widget.startDateTime;
    endDateTime = widget.endDateTime;

    hour = DateFormat('hh').format(selectedDateTime);
    minute = DateFormat('mm').format(selectedDateTime);
    meridiem = DateFormat('a').format(selectedDateTime);
    hourController = TextEditingController(text: hour);
    minuteController = TextEditingController(text: minute);
    meridiemController = TextEditingController(text: meridiem);

    hourFocusNode.addListener(updateHourView);
    minuteFocusNode.addListener(updateMinuteView);
    meridiemFocusNode.addListener(updateMeridiemView);

    hourFocusNode.onKeyEvent = (node, event) {
      final key = event.logicalKey;

      if (event is KeyDownEvent) {
        if (key == LogicalKeyboardKey.arrowUp) {
          updateWithArrow(true);
          return KeyEventResult.handled;
        } else if (key == LogicalKeyboardKey.arrowDown) {
          updateWithArrow(false);
          return KeyEventResult.handled;
        } else if (key == LogicalKeyboardKey.arrowRight) {
          hourFocusNode.unfocus();
          minuteFocusNode.requestFocus();
          return KeyEventResult.handled;
        } else if (key == LogicalKeyboardKey.arrowLeft) {
          hourFocusNode.unfocus();
          meridiemFocusNode.requestFocus();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    };

    minuteFocusNode.onKeyEvent = (node, event) {
      final key = event.logicalKey;

      if (event is KeyDownEvent) {
        if (key == LogicalKeyboardKey.arrowUp) {
          updateWithArrow(true);
          return KeyEventResult.handled;
        } else if (key == LogicalKeyboardKey.arrowDown) {
          updateWithArrow(false);
          return KeyEventResult.handled;
        } else if (key == LogicalKeyboardKey.arrowRight) {
          minuteFocusNode.unfocus();
          meridiemFocusNode.requestFocus();
          return KeyEventResult.handled;
        } else if (key == LogicalKeyboardKey.arrowLeft) {
          minuteFocusNode.unfocus();
          hourFocusNode.requestFocus();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    };

    meridiemFocusNode.onKeyEvent = (node, event) {
      final key = event.logicalKey;

      if (event is KeyDownEvent) {
        if (key == LogicalKeyboardKey.arrowUp) {
          updateWithArrow(true);
          return KeyEventResult.handled;
        } else if (key == LogicalKeyboardKey.arrowDown) {
          updateWithArrow(false);
          return KeyEventResult.handled;
        } else if (key == LogicalKeyboardKey.arrowRight) {
          meridiemFocusNode.unfocus();
          hourFocusNode.requestFocus();
          return KeyEventResult.handled;
        } else if (key == LogicalKeyboardKey.arrowLeft) {
          meridiemFocusNode.unfocus();
          minuteFocusNode.requestFocus();
          return KeyEventResult.handled;
        }
      }
      return KeyEventResult.ignored;
    };
  }

  @override
  void dispose() {
    hourFocusNode.removeListener(updateHourView);
    minuteFocusNode.removeListener(updateMinuteView);
    meridiemFocusNode.removeListener(updateMeridiemView);

    hourFocusNode.dispose();
    minuteFocusNode.dispose();
    meridiemFocusNode.dispose();

    hourController.dispose();
    minuteController.dispose();
    meridiemController.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CalendarDesktopTimeFieldSimpleCreate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (selectedDateTime != widget.selectedDateTime) {
      selectedDateTime = widget.selectedDateTime;
      hour = DateFormat('hh').format(selectedDateTime);
      minute = DateFormat('mm').format(selectedDateTime);
      meridiem = DateFormat('a').format(selectedDateTime);
      hourController.text = hour;
      minuteController.text = minute;
      meridiemController.text = meridiem;
    }
  }

  void updateSelectedDateTime({DateTime? dateTIme}) {
    int _hours = int.parse(hour);

    if (_hours == 12) {
      _hours -= (isAM ? 12 : 0);
    } else {
      _hours += (isPM ? 12 : 0);
    }
    selectedDateTime = dateTIme ?? DateTime(selectedDateTime.year, selectedDateTime.month, selectedDateTime.day, _hours, int.parse(minute));
    setState(() {});
    widget.onDateChanged(selectedDateTime);
  }

  void updateHourView() {
    if (hourFocusNode.hasFocus) {
      hourController.text = '';
      setState(() {});
    } else {
      if (hour.isEmpty) {
        hour = '12';
      } else if (hour.length == 1) {
        hour = '0$hour';
      }

      if (int.parse(hour) >= 13) {
        hour = (int.parse(hour) % 12 + 100).toString().substring(1);
      }

      updateSelectedDateTime();
    }
  }

  void updateMinuteView() {
    if (minuteFocusNode.hasFocus) {
      minuteController.text = '';
      setState(() {});
    } else {
      if (minute.isEmpty) {
        minute = '00';
      } else if (minute.length == 1) {
        minute = '0$minute';
      }

      if (int.parse(minute) >= 60) {
        minute = (int.parse(minute) % 60 + 100).toString().substring(1);
      }

      updateSelectedDateTime();
    }
  }

  void updateMeridiemView() {
    if (meridiemFocusNode.hasFocus) {
      meridiemController.text = '';
      setState(() {});
    } else {
      if (meridiem.toUpperCase() == 'AM') {
        meridiem = 'AM';
      } else if (meridiem.toUpperCase() == 'PM') {
        meridiem = 'PM';
      } else {
        meridiem = DateFormat('a').format(selectedDateTime);
      }

      updateSelectedDateTime();
    }
  }

  bool updateWithArrow(bool increase) {
    if (hourFocusNode.hasFocus) {
      int hourNum = increase ? (int.parse(hour) + 1) : (int.parse(hour) - 1);
      if (hourNum < 1) {
        hour = '12';
        setState(() {});
        return true;
      } else if (hourNum > 12) {
        hour = '01';
        setState(() {});
        return true;
      } else {
        hour = (100 + hourNum).toString().substring(1);
      }
    } else if (minuteFocusNode.hasFocus) {
      int minuteNum = increase ? (int.parse(minute) + 1) : (int.parse(minute) - 1);
      if (minuteNum < 0) {
        minute = '59';
        int hourNum = int.parse(hour) - 1;
        if (hourNum == 11) {
          hour = '11';
          meridiem = meridiem == 'AM' ? 'PM' : 'AM';
          int _hours = int.parse(hour);
          if (_hours == 12) {
            _hours -= (isAM ? 12 : 0);
          } else {
            _hours += (isPM ? 12 : 0);
          }
          updateSelectedDateTime(
            dateTIme: DateTime(selectedDateTime.year, selectedDateTime.month, selectedDateTime.day, _hours, int.parse(minute)).subtract(Duration(days: 1)),
          );
        } else if (hourNum < 0) {
          hour = '23';
          setState(() {});
          return true;
        } else {
          hour = (100 + hourNum).toString().substring(1);
        }
      } else if (minuteNum > 59) {
        minute = '00';

        int hourNum = (int.parse(hour) + 1);
        if (hourNum == 12) {
          hour = '12';
          meridiem = meridiem == 'AM' ? 'PM' : 'AM';
          int _hours = int.parse(hour);
          if (_hours == 12) {
            _hours -= (isAM ? 12 : 0);
          } else {
            _hours += (isPM ? 12 : 0);
          }
          updateSelectedDateTime(
            dateTIme: DateTime(selectedDateTime.year, selectedDateTime.month, selectedDateTime.day, _hours, int.parse(minute)).add(Duration(days: 1)),
          );
        } else if (hourNum > 23) {
          hour = '00';
          setState(() {});
          return true;
        } else {
          hour = (100 + hourNum).toString().substring(1);
        }
      } else {
        minute = (100 + minuteNum).toString().substring(1);
      }
    } else if (meridiemFocusNode.hasFocus) {
      if (isAM) {
        meridiem = 'PM';
      } else if (isPM) {
        meridiem = 'AM';
      }
    }

    setState(() {});
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final numberWidth = 7.5;
    return Container(
      color: context.surfaceVariant,
      height: widget.height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        minuteFocusNode.unfocus();
                        hourFocusNode.requestFocus();
                      },
                      child: Container(
                        width: numberWidth * 2 + 2,
                        height: 16,
                        decoration: BoxDecoration(color: hourFocusNode.hasFocus ? context.primary : Colors.transparent, borderRadius: BorderRadius.circular(4)),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              hour,
                              style: context.bodyLarge
                                  ?.textColor(hourFocusNode.hasFocus ? context.onPrimary : context.outlineVariant)
                                  .appFont(context)
                                  .copyWith(fontFeatures: <FontFeature>[FontFeature.tabularFigures()]),
                            ),
                            IgnorePointer(
                              child: Opacity(
                                opacity: 0,
                                child: TextFormField(
                                  focusNode: hourFocusNode,
                                  controller: hourController,
                                  textInputAction: TextInputAction.none,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  maxLength: 2,
                                  onChanged: (value) {
                                    hour = value;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      ':',
                      style: context.bodyLarge
                          ?.textColor(context.outlineVariant)
                          .appFont(context)
                          .copyWith(fontFeatures: <FontFeature>[FontFeature.tabularFigures()]),
                    ),
                    GestureDetector(
                      onTap: () {
                        hourFocusNode.unfocus();
                        minuteFocusNode.requestFocus();
                      },
                      child: Container(
                        width: numberWidth * 2 + 2,
                        height: 16,
                        decoration: BoxDecoration(
                          color: minuteFocusNode.hasFocus ? context.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              minute,
                              style: context.bodyLarge
                                  ?.textColor(minuteFocusNode.hasFocus ? context.onPrimary : context.outlineVariant)
                                  .appFont(context)
                                  .copyWith(fontFeatures: <FontFeature>[FontFeature.tabularFigures()]),
                            ),
                            IgnorePointer(
                              child: Opacity(
                                opacity: 0,
                                child: TextFormField(
                                  focusNode: minuteFocusNode,
                                  controller: minuteController,
                                  textInputAction: TextInputAction.none,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  maxLength: 2,
                                  onChanged: (value) {
                                    minute = value;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: GestureDetector(
                        onTap: () {
                          hourFocusNode.unfocus();
                          minuteFocusNode.unfocus();
                          meridiemFocusNode.requestFocus();
                        },
                        child: Container(
                          width: 10 * 2 + 2,
                          height: 16,
                          decoration: BoxDecoration(
                            color: meridiemFocusNode.hasFocus ? context.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                meridiem,
                                style: context.bodyLarge
                                    ?.textColor(meridiemFocusNode.hasFocus ? context.onPrimary : context.outlineVariant)
                                    .appFont(context)
                                    .copyWith(fontFeatures: <FontFeature>[FontFeature.tabularFigures()]),
                              ),
                              IgnorePointer(
                                child: Opacity(
                                  opacity: 0,
                                  child: TextFormField(
                                    focusNode: meridiemFocusNode,
                                    controller: meridiemController,
                                    textInputAction: TextInputAction.none,
                                    maxLength: 2,
                                    onChanged: (value) {
                                      meridiem = value;
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isEndDateTime)
                Positioned(
                  top: 7,
                  right: 8,
                  child: PopupMenu(
                    width: 296,
                    height: 300,
                    forcePopup: true,
                    location: PopupMenuLocation.bottom,
                    type: ContextMenuActionType.tap,
                    popup: OmniDateTimePicker(
                      type: OmniDateTimePickerType.date,
                      initialDate: selectedDateTime,
                      backgroundColor: context.surfaceVariant,
                      onDateChanged: (dateTime) {
                        selectedDateTime = dateTime;

                        if (widget.isAllDay) {
                          endDateTime = dateTime;
                          if (startDateTime.compareTo(dateTime) > 0) {
                            startDateTime = dateTime;
                          }
                        } else {
                          final user = ref.read(authControllerProvider).requireValue;
                          endDateTime = dateTime;
                          if (startDateTime.compareTo(dateTime) > 0) {
                            startDateTime = dateTime.subtract(Duration(minutes: user.userDefaultDurationInMinutes));
                          }
                        }
                        setState(() {});
                        widget.onDateChanged(selectedDateTime);
                      },
                    ),
                    style: VisirButtonStyle(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      // backgroundColor: context.scrim,
                      border: Border.all(width: 1, color: context.scrim),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(EventEntity.getDateForEditSimple(selectedDateTime), style: context.bodyLarge?.textColor(context.outlineVariant)),
                  ),
                ),
            ],
          ),
          Container(
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 0.5, strokeAlign: BorderSide.strokeAlignCenter, color: context.scrim),
              ),
            ),
          ),
          Expanded(
            child: CalendarDesktopTimeListSimpleCreate(
              selectedDateTime: selectedDateTime,
              onDateChanged: widget.onDateChanged,
              isEndDateTime: widget.isEndDateTime,
              startDateTime: startDateTime,
              endDateTime: endDateTime,
            ),
          ),
        ],
      ),
    );
  }
}
