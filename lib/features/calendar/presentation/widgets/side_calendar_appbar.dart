import 'package:Visir/dependency/contextmenu/contextmenu.dart';
import 'package:Visir/dependency/omni_datetime_picker/omni_datetime_picker.dart';
import 'package:Visir/dependency/omni_datetime_picker/src/omni_datetime_picker.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class SideCalendarAppBar extends ConsumerWidget {
  final DateTime selectedDateTime;
  final void Function(DateTime dateTime) onDateButtonPressed;

  const SideCalendarAppBar({super.key, required this.selectedDateTime, required this.onDateButtonPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PreferredSize(
      preferredSize: Size.fromHeight(48),
      child: Container(
        height: context.appBarTheme.toolbarHeight ?? kToolbarHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            VisirButton(
              type: VisirButtonAnimationType.scaleAndOpacity,
              style: VisirButtonStyle(
                cursor: SystemMouseCursors.click,
                width: 24,
                height: 24,
                margin: EdgeInsets.symmetric(horizontal: 8),
                backgroundColor: context.surface,
                borderRadius: BorderRadius.circular(4),
              ),
              options: VisirButtonOptions(message: context.tr.tooltip_prev_month),
              onTap: () {
                onDateButtonPressed.call(DateTime(selectedDateTime.year, selectedDateTime.month - 1, selectedDateTime.day));
              },
              child: VisirIcon(type: VisirIconType.arrowLeft, size: 16),
            ),
            IntrinsicHeight(
              child: PopupMenu(
                width: 296,
                height: 300,
                forcePopup: true,
                location: PopupMenuLocation.bottom,
                type: ContextMenuActionType.tap,
                popup: OmniDateTimePicker(
                  type: OmniDateTimePickerType.date,
                  initialDate: selectedDateTime,
                  onDateChanged: (dateTime) {
                    onDateButtonPressed(dateTime);
                  },
                ),
                style: VisirButtonStyle(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3), borderRadius: BorderRadius.circular(6)),
                child: Row(
                  children: [
                    Text(DateFormat.MMM().format(selectedDateTime) + ' ', style: context.titleLarge?.textColor(context.onBackground).textBold.appFont(context)),
                    Text(DateFormat.y().format(selectedDateTime), style: context.titleLarge?.textColor(context.tertiary).textBold.appFont(context)),
                    SizedBox(width: 8),
                    VisirIcon(type: VisirIconType.arrowDown, size: 16),
                  ],
                ),
              ),
            ),
            VisirButton(
              type: VisirButtonAnimationType.scaleAndOpacity,
              style: VisirButtonStyle(
                cursor: SystemMouseCursors.click,
                margin: EdgeInsets.symmetric(horizontal: 8),
                width: 24,
                height: 24,
                backgroundColor: context.surface,
                borderRadius: BorderRadius.circular(4),
              ),
              options: VisirButtonOptions(message: context.tr.tooltip_next_month),
              onTap: () {
                onDateButtonPressed.call(DateTime(selectedDateTime.year, selectedDateTime.month + 1, selectedDateTime.day));
              },
              child: VisirIcon(type: VisirIconType.arrowRight, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
