import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../omni_datetime_picker.dart';
import '../../components/calendar.dart';
import '../../components/custom_tab_bar.dart';
import '../../components/time_picker_spinner.dart';

class OmniDtpRange extends StatefulWidget {
  const OmniDtpRange({
    super.key,
    this.startInitialDate,
    this.startFirstDate,
    this.startLastDate,
    this.endInitialDate,
    this.endFirstDate,
    this.endLastDate,
    this.isShowSeconds,
    this.is24HourMode,
    this.minutesInterval,
    this.secondsInterval,
    this.isForce2Digits,
    this.constraints,
    this.type,
    this.selectableDayPredicate,
    this.defaultView = DefaultView.start,
  });

  final DateTime? startInitialDate;
  final DateTime? startFirstDate;
  final DateTime? startLastDate;

  final DateTime? endInitialDate;
  final DateTime? endFirstDate;
  final DateTime? endLastDate;

  final bool? isShowSeconds;
  final bool? is24HourMode;
  final int? minutesInterval;
  final int? secondsInterval;
  final bool? isForce2Digits;
  final BoxConstraints? constraints;
  final OmniDateTimePickerType? type;
  final bool Function(DateTime start, DateTime end)? selectableDayPredicate;
  final DefaultView defaultView;

  @override
  State<OmniDtpRange> createState() => _OmniDtpRangeState();
}

class _OmniDtpRangeState extends State<OmniDtpRange> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime start;
  late DateTime end;
  late String timezone;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.index = widget.defaultView.index;

    final _locations = tz.timeZoneDatabase.locations;
    timezone = "US/Pacific";

    for (var item in _locations.entries) {
      if (item.value.currentTimeZone.abbreviation == DateTime.now().timeZoneName) {
        timezone = item.key;
        break;
      }
    }

    start = widget.startInitialDate ?? DateTime.now();
    end = widget.endInitialDate ?? DateTime.now().add(Duration(hours: 1));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12),
          CustomTabBar(tabController: _tabController),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 500,
            ),
            child: TabBarView(
              controller: _tabController,
              children: [
                PickerView(
                  type: widget.type,
                  initialDate: start,
                  firstDate: widget.startFirstDate,
                  lastDate: widget.startLastDate,
                  isShowSeconds: widget.isShowSeconds,
                  is24HourMode: widget.is24HourMode ?? false,
                  minutesInterval: widget.minutesInterval,
                  secondsInterval: widget.secondsInterval,
                  isForce2Digits: widget.isForce2Digits ?? false,
                  selectableDayPredicate: (date) {
                    start = date;
                    end = date.add(Duration(hours: 1));

                    widget.selectableDayPredicate?.call(start, end);
                    return true;
                  },
                ),
                PickerView(
                    type: widget.type,
                    initialDate: end,
                    firstDate: widget.endFirstDate,
                    lastDate: widget.endLastDate,
                    isShowSeconds: widget.isShowSeconds,
                    is24HourMode: widget.is24HourMode ?? false,
                    minutesInterval: widget.minutesInterval,
                    secondsInterval: widget.secondsInterval,
                    isForce2Digits: widget.isForce2Digits ?? false,
                    selectableDayPredicate: (date) {
                      start = date;
                      end = date.add(Duration(hours: 1));

                      widget.selectableDayPredicate?.call(start, end);
                      return true;
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PickerView extends StatefulWidget {
  const PickerView(
      {super.key,
      this.initialDate,
      this.firstDate,
      this.lastDate,
      this.isShowSeconds,
      this.is24HourMode,
      this.minutesInterval,
      this.secondsInterval,
      this.isForce2Digits,
      this.type,
      this.selectableDayPredicate});

  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;

  final bool? isShowSeconds;
  final bool? is24HourMode;
  final int? minutesInterval;
  final int? secondsInterval;
  final bool? isForce2Digits;

  final bool Function(DateTime)? selectableDayPredicate;

  final OmniDateTimePickerType? type;

  @override
  State<PickerView> createState() => _PickerViewState();
}

class _PickerViewState extends State<PickerView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late DateTime date;
  late TimeOfDay time;
  late String timezone;

  @override
  void initState() {
    date = widget.initialDate == null ? DateTime.now() : DateUtils.dateOnly(widget.initialDate!);
    time = widget.initialDate != null ? TimeOfDay.fromDateTime(widget.initialDate!) : TimeOfDay.now();

    final _locations = tz.timeZoneDatabase.locations;
    timezone = "US/Pacific";

    for (var item in _locations.entries) {
      if (item.value.currentTimeZone.abbreviation == DateTime.now().timeZoneName) {
        timezone = item.key;
        break;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final localizations = MaterialLocalizations.of(context);
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Calendar(
            initialDate: widget.initialDate ?? DateTime.now(),
            firstDate: widget.firstDate,
            lastDate: widget.lastDate,
            onDateChanged: (date) {
              this.date = DateUtils.dateOnly(date);
              if (widget.type == OmniDateTimePickerType.date) {
                widget.selectableDayPredicate?.call(date);
              } else {
                widget.selectableDayPredicate?.call(DateTime(date.year, date.month, date.day, time.hour, time.minute));
              }
              setState(() {});
            },
          ),
          if (widget.type == OmniDateTimePickerType.dateAndTime)
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0, left: 20, right: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.tr.all_day,
                          style: context.bodyMedium?.textColor(context.onSurface.withValues(alpha: 0.6)),
                        ),
                      ),
                    ],
                  ),
                  if (widget.type == OmniDateTimePickerType.dateAndTime)
                    TimePickerSpinner(
                      time: DateTime(date.year, date.month, date.day, time.hour, time.minute).toLocal(),
                      amText: localizations.anteMeridiemAbbreviation,
                      pmText: localizations.postMeridiemAbbreviation,
                      isShowSeconds: widget.isShowSeconds ?? false,
                      is24HourMode: widget.is24HourMode ?? false,
                      minutesInterval: widget.minutesInterval ?? 1,
                      secondsInterval: widget.secondsInterval ?? 1,
                      isForce2Digits: widget.isForce2Digits ?? false,
                      onTimeChange: (dateTime) {
                        this.time = TimeOfDay.fromDateTime(dateTime);

                        if (widget.type == OmniDateTimePickerType.date) {
                          widget.selectableDayPredicate?.call(date);
                        } else {
                          widget.selectableDayPredicate?.call(DateTime(date.year, date.month, date.day, time.hour, time.minute));
                        }
                        setState(() {});
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
