import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_entity.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_switch_count_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransitionCountWidget extends ConsumerStatefulWidget {
  final UserActionSwitchCountEntity switchCount;
  final bool isFirstCalendar;

  const TransitionCountWidget({required this.switchCount, required this.isFirstCalendar});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TransitionCountWidgetState();
}

class _TransitionCountWidgetState extends ConsumerState<TransitionCountWidget> {
  UserActionSwitchCountEntity get switchCount => widget.switchCount;

  bool get isFirstCalendar => widget.isFirstCalendar;

  bool get isDarkMode => context.isDarkMode;

  Widget cell({required UserActionEntity action}) {
    String assetPath = action.assetPath;
    String title = action.getDescription(context);
    bool isCalendar = isFirstCalendar && (action.type == UserActionType.calendar);

    return Expanded(
      child: Container(
        width: 104,
        padding: EdgeInsets.only(left: 14, right: isCalendar ? 10 : 14, top: 10, bottom: 10),
        decoration: ShapeDecoration(
          color: context.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          children: [
            assetPath.isEmpty
                ? VisirIcon(type: VisirIconType.checkWithCircle, size: 20, color: isDarkMode ? context.outlineVariant : context.onInverseSurface)
                : Image.asset(assetPath, width: 20, height: 20, fit: BoxFit.contain),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: context.titleSmall?.textColor(context.outlineVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            if (isCalendar)
              Padding(
                padding: const EdgeInsets.only(left: 4),
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
                            context.tr.time_saved_calendars_are_not_separated,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobileView = PlatformX.isMobileView;

    return isMobileView
        ? Column(
            children: [
              Row(
                children: [
                  cell(action: switchCount.prevAction),
                  const SizedBox(width: 14),
                  VisirIcon(type: VisirIconType.arrowRight, size: 24, color: context.outlineVariant),
                  const SizedBox(width: 14),
                  cell(action: switchCount.nextAction),
                ],
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '${Utils.numberFormatter(switchCount.count.toDouble())} ', style: context.titleSmall?.textColor(context.outlineVariant)),
                    TextSpan(text: context.tr.time_saved_times, style: context.titleSmall?.textColor(context.inverseSurface)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          )
        : Row(
            children: [
              cell(action: switchCount.prevAction),
              const SizedBox(width: 14),
              VisirIcon(type: VisirIconType.arrowRight, size: 24, color: isDarkMode ? context.outlineVariant : context.onInverseSurface),
              const SizedBox(width: 14),
              cell(action: switchCount.nextAction),
              const SizedBox(width: 16),
              Container(
                width: 104,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: ShapeDecoration(
                  color: context.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${Utils.numberFormatter(switchCount.count.toDouble())} ',
                        style: context.titleSmall?.textColor(context.outlineVariant).textBold,
                      ),
                      TextSpan(text: context.tr.time_saved_times, style: context.titleSmall?.textColor(context.inverseSurface)),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
  }
}
