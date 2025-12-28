import 'dart:ui';

import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/provider.dart' hide TextScaler;
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_suggestion_entity.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:change_case/change_case.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_infinite_marquee/flutter_infinite_marquee.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:intl/intl.dart';

class ProjectSummaryCardsWidget extends StatelessWidget {
  final List<MapEntry<String?, Map<String, dynamic>>> projectMap;
  final List<String> projectHide;
  final ResizableController resizableController;
  final ValueChanged<ProjectEntity?>? onProjectSelected;

  ProjectSummaryCardsWidget({super.key, required this.projectMap, required this.projectHide, required this.resizableController, this.onProjectSelected});

  String _getDateString(BuildContext context, {required DateTime date, bool? forceDate}) {
    if (DateUtils.isSameDay(DateTime.now(), date) && forceDate != true) return DateFormat.jm().format(date);
    if (DateUtils.isSameDay(DateTime.now(), date) && forceDate == true) return context.tr.today;
    if (DateUtils.isSameDay(DateTime.now().subtract(Duration(days: 1)), date)) return context.tr.yesterday;
    if (DateUtils.isSameDay(DateTime.now().add(Duration(days: 1)), date)) return context.tr.tomorrow;
    if (date.isBefore(DateUtils.dateOnly(DateTime.now().add(Duration(days: 7)))) && date.isAfter(DateUtils.dateOnly(DateTime.now()))) return DateFormat.E().format(date);
    if (date.year == DateTime.now().year) return DateFormat.MMMd().format(date);
    return DateFormat.yMMMd().format(date);
  }

  final Map<String, GlobalKey> _globalKeys = {};
  final Map<String, MarqueeController> _marqueeControllers = {};

  @override
  Widget build(BuildContext context) {
    final cardProject = projectMap.where((e) {
      final project = e.value['project'] as ProjectEntity?;
      if (projectHide.contains(project?.uniqueId)) return false;
      return true;
    });

    final scaleRatio = PlatformX.isMobileView ? 0.7 : 1.0;

    final child = Container(
      width: PlatformX.isDesktopView ? null : context.width / (scaleRatio * Utils.ref.read(zoomRatioProvider)),
      child: MediaQuery(
        data: context.mediaQuery.copyWith(textScaler: TextScaler.linear(1)),
        child: Material(
          color: Colors.transparent,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(left: PlatformX.isMobileView ? 12 : 24, right: PlatformX.isMobileView ? 12 : 16 + (resizableController.pixels.lastOrNull ?? 0)),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: cardProject
                    .map((e) {
                      final project = e.value['project'] as ProjectEntity?;
                      final inboxes = e.value['inboxes'] as List<InboxEntity>;

                      final height = 200.0;
                      final width = height * 1.58;

                      final color = project?.color ?? context.onSurfaceVariant;

                      final suggestions =
                          [InboxSuggestionUrgency.urgent, InboxSuggestionUrgency.important, InboxSuggestionUrgency.action_required, InboxSuggestionUrgency.need_review]
                              .map((t) => {'reason': t, 'inboxes': inboxes.where((element) => element.suggestion?.urgency == t).toList()})
                              .where((e) => (e['inboxes']! as List<InboxEntity>).isNotEmpty)
                              .take(2)
                              .toList();

                      if (suggestions.length == 1) {
                        final currentSuggestionReason = suggestions.first['reason'] as InboxSuggestionUrgency;
                        if (currentSuggestionReason == InboxSuggestionUrgency.urgent) {
                          suggestions.add({'reason': InboxSuggestionUrgency.important, 'inboxes': <InboxEntity>[]});
                        } else {
                          suggestions.insert(0, {'reason': InboxSuggestionUrgency.urgent, 'inboxes': <InboxEntity>[]});
                        }
                      } else if (suggestions.isEmpty) {
                        suggestions.addAll([
                          {'reason': InboxSuggestionUrgency.urgent, 'inboxes': <InboxEntity>[]},
                          {'reason': InboxSuggestionUrgency.important, 'inboxes': <InboxEntity>[]},
                        ]);
                      }

                      if (suggestions.map((e) => (e['inboxes'] as List<InboxEntity>).length).reduce((a, b) => a + b) == 0) {
                        return null;
                      }

                      _globalKeys[project?.uniqueId ?? ''] ??= GlobalKey();

                      return VisirButton(
                        type: VisirButtonAnimationType.scaleAndOpacity,
                        style: VisirButtonStyle(
                          width: width,
                          height: height,
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          borderRadius: BorderRadius.circular(21),
                          border: Border.all(color: context.outline),
                          hoverColor: Colors.white.withValues(alpha: context.isDarkMode ? 0.1 : 0.7),
                        ),
                        onTap: () => onProjectSelected?.call(project),
                        onEnter: (event) {
                          _marqueeControllers.forEach((key, value) {
                            if (key.startsWith(project?.uniqueId ?? 'null')) {
                              value.play();
                            }
                          });
                        },
                        onExit: (event) {
                          _marqueeControllers.forEach((key, value) {
                            if (key.startsWith(project?.uniqueId ?? 'null')) {
                              value.pause();
                            }
                          });
                        },
                        child: ClipRRect(
                          key: _globalKeys[project?.uniqueId ?? ''],
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Container(color: color.withValues(alpha: context.isDarkMode ? 0.2 : 0.35)),
                                ),
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 12, bottom: 12, left: 20, right: 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(right: 12.0),
                                              child: VisirIcon(type: project?.icon ?? VisirIconType.project, size: context.textScaler.scale(22), color: color, isSelected: true),
                                            ),
                                            Expanded(
                                              child: Text(
                                                project?.name ?? context.tr.no_project_suggested,
                                                style: context.headlineMedium?.textColor(context.onSurfaceVariant),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),

                                        Expanded(
                                          child: LayoutBuilder(
                                            builder: (context, constraints) {
                                              return Column(
                                                spacing: 8,
                                                children: suggestions.mapIndexed((index, t) {
                                                  final reason = t['reason'] as InboxSuggestionUrgency;
                                                  final targetInboxes = t['inboxes']! as List<InboxEntity>;
                                                  
                                                  // urgency 문자열을 미리 저장 (context를 사용하여 로컬라이제이션 가져오기)
                                                  final urgencyTitle = reason.title.isNotEmpty 
                                                      ? reason.title 
                                                      : (reason == InboxSuggestionUrgency.urgent 
                                                          ? context.tr.ai_suggestion_urgency_urgent
                                                          : reason == InboxSuggestionUrgency.important
                                                              ? context.tr.ai_suggestion_urgency_important
                                                              : reason == InboxSuggestionUrgency.action_required
                                                                  ? context.tr.ai_suggestion_urgency_action_required
                                                                  : reason == InboxSuggestionUrgency.need_review
                                                                      ? context.tr.ai_suggestion_urgency_need_review
                                                                      : '');
                                                  
                                                  // urgencyTitle이 비어있으면 기본값으로 name 사용
                                                  final urgencyName = urgencyTitle.isNotEmpty 
                                                      ? urgencyTitle 
                                                      : reason.name.toSentenceCase();

                                                  final inboxBuilder = (InboxEntity inbox) {
                                                    final isAsap = inbox.suggestion?.isASAP ?? false;
                                                    final targetDate = inbox.suggestion?.target_date;
                                                    final isAllDay = inbox.suggestion?.isAllDay ?? false;
                                                    final duration = inbox.suggestion?.duration;
                                                    final isEvent = inbox.suggestion?.date_type == InboxSuggestionDateType.event;

                                                    final dateString = targetDate != null ? _getDateString(context, date: targetDate, forceDate: true) : '';
                                                    final timeString = targetDate != null
                                                        ? targetDate.minute == 0
                                                              ? DateFormat('h a').format(targetDate)
                                                              : DateFormat('h:mm a').format(targetDate)
                                                        : '';

                                                    final baseStyle = context.bodyLarge!;
                                                    // final iconHeight = baseStyle.height! * baseStyle.fontSize!;

                                                    // Build schedule text without unnecessary commas
                                                    String scheduleText;
                                                    if (isAsap) {
                                                      scheduleText = context.tr.ai_suggestion_due_asap;
                                                    } else if (isAllDay) {
                                                      scheduleText = dateString.isNotEmpty ? dateString : context.tr.no_suggested_schedule;
                                                    } else {
                                                      final parts = <String>[];
                                                      if (dateString.isNotEmpty) parts.add(dateString);
                                                      if (timeString.isNotEmpty) parts.add(timeString);
                                                      if (duration != null) parts.add('${context.tr.ai_suggestion_duration(duration)} slot');

                                                      scheduleText = parts.isEmpty ? context.tr.no_suggested_schedule : parts.join(', ');
                                                    }

                                                    return Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text.rich(
                                                              TextSpan(children: [TextSpan(text: inbox.suggestion?.decryptedSummary ?? inbox.decryptedTitle)]),

                                                              style: baseStyle.textColor(context.onBackground),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 6),
                                                        Text.rich(
                                                          TextSpan(
                                                            children: [
                                                              WidgetSpan(
                                                                alignment: PlaceholderAlignment.middle,
                                                                child: VisirIcon(
                                                                  type: isEvent ? VisirIconType.calendar : VisirIconType.task,
                                                                  size: context.bodySmall!.height! * context.bodySmall!.fontSize!,
                                                                  color: context.onBackground,
                                                                  isSelected: true,
                                                                ),
                                                              ),
                                                              WidgetSpan(child: SizedBox(width: 6)),
                                                              TextSpan(text: scheduleText, style: context.bodySmall?.textColor(context.onSurface)),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  };

                                                  _marqueeControllers[(project?.uniqueId ?? 'null') + index.toString()] ??= MarqueeController();

                                                  return Container(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              targetInboxes.length.toString(),
                                                              style: context.displayLarge
                                                                  ?.textColor(targetInboxes.isEmpty ? context.inverseSurface : reason.color)
                                                                  .copyWith(height: 1),
                                                            ),
                                                            SizedBox(width: 12),
                                                            if (targetInboxes.isNotEmpty)
                                                              Expanded(
                                                                child: SizedBox(
                                                                  height: 36,
                                                                  child: ShaderMask(
                                                                    shaderCallback: (bounds) {
                                                                      return LinearGradient(
                                                                        begin: Alignment.centerLeft,
                                                                        end: Alignment.centerRight,
                                                                        colors: <Color>[
                                                                          Colors.white.withValues(alpha: 0.0),
                                                                          Colors.white,
                                                                          Colors.white,
                                                                          Colors.white.withValues(alpha: 0.0),
                                                                        ],
                                                                        stops: [0.0, 0.08, 0.92, 1.0], // Adjust these values to control the fade length
                                                                      ).createShader(Rect.fromLTRB(0, 0, bounds.width, bounds.height));
                                                                    },
                                                                    blendMode: BlendMode.dstIn,
                                                                    child: InfiniteMarquee(
                                                                      speed: 30,
                                                                      autoplay: false,
                                                                      controller: _marqueeControllers[(project?.uniqueId ?? 'null') + index.toString()],
                                                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                                                      itemBuilder: (BuildContext context, int index) {
                                                                        final inbox = targetInboxes[index % targetInboxes.length];
                                                                        return inboxBuilder(inbox);
                                                                      },
                                                                      separatorBuilder: (context, index) => Container(
                                                                        width: 4,
                                                                        margin: EdgeInsets.symmetric(horizontal: 16),
                                                                        height: context.bodyLarge!.height! * context.bodyLarge!.fontSize!,
                                                                        decoration: BoxDecoration(
                                                                          color: context.onBackground.withValues(alpha: 0.1),
                                                                          borderRadius: BorderRadius.circular(2),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 1),
                                                        Text(
                                                          urgencyName,
                                                          style: context.titleSmall?.textColor(targetInboxes.isEmpty ? context.inverseSurface : reason.color).appFont(context),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }).toList(),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    })
                    .whereType<Widget>()
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );

    if (PlatformX.isDesktopView) {
      return child;
    }

    return Container(
      height: 200 * scaleRatio.toDouble(),
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: NeverScrollableScrollPhysics(),
            child: Row(
              children: [Transform.scale(alignment: Alignment.topLeft, scale: PlatformX.isMobileView ? scaleRatio : 1, child: child)],
            ),
          ),
        ),
      ),
    );
  }
}
