import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/widgets/selection_widget.dart';
import 'package:flutter/widgets.dart';
import 'package:time/time.dart';

class CalendarDesktopTimeListSimpleCreate extends StatefulWidget {
  final bool isEndDateTime;
  final DateTime selectedDateTime;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final void Function(DateTime dateTime) onDateChanged;

  CalendarDesktopTimeListSimpleCreate({
    Key? key,
    required this.isEndDateTime,
    required this.selectedDateTime,
    required this.startDateTime,
    required this.endDateTime,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  State<CalendarDesktopTimeListSimpleCreate> createState() => _CalendarDesktopTimeListSimpleCreateState();
}

class _CalendarDesktopTimeListSimpleCreateState extends State<CalendarDesktopTimeListSimpleCreate> {
  double cellHeight = 36;

  late DateTime selectedDateTime;

  List<DateTime> dateTimes = [];

  ScrollController scrollController = ScrollController();

  void resetTimeList(bool isInitial) {
    selectedDateTime = widget.selectedDateTime;
    dateTimes = List.generate(96, (index) {
      if (widget.isEndDateTime) {
        if (widget.startDateTime.date == widget.endDateTime.date) {
          return DateTime(
                  widget.startDateTime.year, widget.startDateTime.month, widget.startDateTime.day, widget.startDateTime.hour, widget.startDateTime.minute)
              .add(Duration(minutes: 15 * (index + 1)));
        } else {
          return DateTime(widget.endDateTime.year, widget.endDateTime.month, widget.endDateTime.day, 0, 0).add(Duration(minutes: 15 * index));
        }
      } else {
        return DateTime(selectedDateTime.year, selectedDateTime.month, selectedDateTime.day, 0, 0).add(Duration(minutes: 15 * index));
      }
    });
    dateTimes.add(selectedDateTime);
    dateTimes.unique();
    dateTimes.sort();

    int index = dateTimes.indexOf(selectedDateTime);

    if (isInitial) {
      scrollController = ScrollController(initialScrollOffset: cellHeight * (index - 2));
    } else {
      scrollController.jumpTo(cellHeight * (index - 2));
    }
  }

  @override
  void initState() {
    super.initState();
    resetTimeList(true);
  }

  @override
  void didUpdateWidget(covariant CalendarDesktopTimeListSimpleCreate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (selectedDateTime != widget.selectedDateTime) {
      resetTimeList(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        controller: scrollController,
        child: SelectionWidget<DateTime?>(
          current: selectedDateTime,
          cellHeight: cellHeight,
          edgePadding: EdgeInsets.all(0),
          items: [
            ...dateTimes,
          ],
          getTitle: (dateTime) {
            if (dateTime == null) return '';
            return EventEntity.getTimeForEditWithMinutes(dateTime);
          },
          getDescription: widget.isEndDateTime
              ? (dateTime) {
                  if (dateTime == null) return '';
                  final duration = dateTime.difference(widget.startDateTime);
                  final hours = duration.inHours;
                  final minutes = duration.inMinutes.remainder(60);
                  return hours == 0
                      ? '${minutes}m'
                      : minutes == 0
                          ? '${hours}h'
                          : '${hours}h ${minutes}m';
                }
              : null,
          onSelect: (dateTime) {
            if (dateTime == null) {
            } else {
              selectedDateTime = DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour, dateTime.minute);
            }
            setState(() {});
            widget.onDateChanged(selectedDateTime);
          },
        ),
      ),
    );
  }
}
