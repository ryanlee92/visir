import 'package:Visir/features/auth/application/notification_controller.dart';
import 'package:Visir/features/calendar/application/calendar_list_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/auth_image_view.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_item.dart';
import 'package:Visir/features/preference/application/calendar_integration_list_controller.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarNotificationPreferenceWidget extends ConsumerStatefulWidget {
  const CalendarNotificationPreferenceWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CalendarNotificationPreferenceWidgetState();
}

class _CalendarNotificationPreferenceWidgetState extends ConsumerState<CalendarNotificationPreferenceWidget> {
  @override
  Widget build(BuildContext context) {
    final showCalendarNotifications = ref.watch(localPrefControllerProvider.select((e) => e.value!.prefShowCalendarNotifications));
    final list = ref.watch(calendarIntegrationListControllerProvider).value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...[OAuthType.google, OAuthType.microsoft].map((type) {
          return Column(
            children: list.where((e) => e.type == type).map((e) {
              bool _value = showCalendarNotifications[e.email] ?? true;
              return VisirListItem(
                verticalMarginOverride: 8,
                verticalPaddingOverride: 0,
                titleLeadingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: AuthImageView(oauth: e, size: 28),
                    ),
                  ],
                ),
                titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: e.email, style: baseStyle),
                titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
                  children: [
                    WidgetSpan(
                      child: AnimatedToggleSwitch<bool>.rolling(
                        current: _value,
                        values: [false, true],
                        height: 32,
                        indicatorSize: Size(32, 32),
                        indicatorIconScale: 1,
                        iconOpacity: 0.5,
                        borderWidth: 0,
                        onChanged: (value) {
                          Map<String, bool> newData = Map<String, bool>.from(showCalendarNotifications);
                          newData[e.email] = value;
                          ref.read(localPrefControllerProvider.notifier).set(showCalendarNotifications: newData);
                          final calendarMap = ref.read(calendarListControllerProvider);
                          ref.read(notificationControllerProvider.notifier).updateLinkedCalendar(calendarMap);
                        },
                        iconBuilder: (showTaskNotification, selected) => VisirIcon(
                          type: showTaskNotification ? VisirIconType.notification : VisirIconType.notificationOff,
                          size: 16,
                          color: selected
                              ? showTaskNotification
                                    ? context.onBackground
                                    : context.error
                              : context.onBackground,
                          isSelected: selected,
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
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}
