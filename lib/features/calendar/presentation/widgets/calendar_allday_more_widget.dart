import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/calendar/calendar.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class CalendarAllDayMoreWidget extends ConsumerStatefulWidget {
  final TabType tabType;
  final List<CalendarAppointmentDetails> details;
  final DateTime selectedDate;
  final void Function(DateTime date) moveToDateOnDayView;
  final Widget Function(
    TaskEntity e, {
    required bool isMonth,
    required double height,
    required double width,
    required DateTime date,
    double? availableHeight,
    Rect? bounds,
  })
  buildTaskView;

  const CalendarAllDayMoreWidget({
    super.key,
    required this.details,
    required this.selectedDate,
    required this.moveToDateOnDayView,
    required this.tabType,
    required this.buildTaskView,
  });

  @override
  ConsumerState createState() => _CalendarAllDayMoreWidgetState();
}

class _CalendarAllDayMoreWidgetState extends ConsumerState<CalendarAllDayMoreWidget> {
  Widget buildAppointment(BuildContext context, TaskEntity e) {
    return SizedBox(
      height: 28,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return widget.buildTaskView(e, isMonth: false, height: 28, width: constraints.maxWidth, date: widget.selectedDate);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final details = [...widget.details];

    return Column(
      children: [
        Container(
          height: VisirAppBar.height,
          child: Row(
            children: [
              SizedBox(width: 6),
              VisirAppBarButton(icon: VisirIconType.close, onTap: () => Navigator.pop(Utils.mainContext)).getButton(context: context),
              SizedBox(width: 6),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: widget.selectedDate.day.toString() + ' ', style: context.titleLarge?.textColor(context.outlineVariant).appFont(context)),
                      TextSpan(text: DateFormat('E').format(widget.selectedDate).toUpperCase(), style: context.titleSmall?.textColor(context.inverseSurface)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 6),
            ],
          ),
        ),
        Container(
          constraints: BoxConstraints(maxHeight: max(MediaQuery.of(context).size.height * 0.4, 200)),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 6, left: 8, right: 8),
            child: Column(
              children: [
                ...details.map((e) {
                  return Row(
                    children: e.appointments.map((d) {
                      final t = d as TaskEntity;
                      if (t.isCancelled) return SizedBox.shrink();

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 3.0),
                          child: widget.buildTaskView(
                            t,
                            isMonth: true,
                            height: 28,
                            width: 180,
                            date: widget.selectedDate,
                            bounds: e.bounds,
                            availableHeight: e.availableHeight,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
