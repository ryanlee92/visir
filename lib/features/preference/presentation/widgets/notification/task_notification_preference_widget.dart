import 'package:Visir/features/auth/application/notification_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_item.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskNotificationPreferenceWidget extends ConsumerStatefulWidget {
  const TaskNotificationPreferenceWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TaskNotificationPreferenceWidgetState();
}

class _TaskNotificationPreferenceWidgetState extends ConsumerState<TaskNotificationPreferenceWidget> {
  Widget build(BuildContext context) {
    final showTaskNotification = ref.watch(showTaskNotificationProvider);
    return VisirListItem(
      titleBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(text: context.tr.notification_task_reminders, style: baseStyle),
      titleTrailingBuilder: (height, baseStyle, subStyle, horizontalSpacing) => TextSpan(
        children: [
          WidgetSpan(
            child: AnimatedToggleSwitch<bool>.rolling(
              current: showTaskNotification,
              values: [false, true],
              height: 32,
              indicatorSize: Size(32, 32),
              indicatorIconScale: 1,
              iconOpacity: 0.5,
              borderWidth: 0,
              onChanged: (showTaskNotification) {
                ref.read(showTaskNotificationProvider.notifier).update(showTaskNotification);
                ref.read(notificationControllerProvider.notifier).updateShowTaskNotification(showTaskNotification);
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
  }
}
