import 'dart:convert';
import 'dart:math' as math;

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/date_time_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/dependency/rrule/src/recurrence_rule.dart';
import 'package:Visir/features/calendar/application/calendar_list_controller.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/inbox/application/agent_action_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_file_entity.dart';
import 'package:collection/collection.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/presentation/widgets/inbox_action_suggestions_widget.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_user_entity.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:Visir/features/task/application/task_list_controller.dart';
import 'package:Visir/features/task/application/calendar_task_list_controller.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/application/chat_member_list_controller.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:uuid/uuid.dart';

class AgentActionMessagesWidget extends ConsumerStatefulWidget {
  final double maxHeight;
  AgentActionMessagesWidget({super.key, this.maxHeight = 600});

  @override
  ConsumerState<AgentActionMessagesWidget> createState() => _AgentActionMessagesWidgetState();
}

class _AgentActionMessagesWidgetState extends ConsumerState<AgentActionMessagesWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<String> _getLoadingMessages(BuildContext context, AgentActionType? actionType, Map<String, dynamic>? pendingTaskInfo) {
    if (actionType == null) {
      return [context.tr.agent_action_loading_thinking, context.tr.agent_action_loading_processing_request];
    }

    final isConfirmed = pendingTaskInfo?['isConfirmed'] as bool? ?? false;
    final isModifying = pendingTaskInfo != null && !isConfirmed;

    switch (actionType) {
      case AgentActionType.createTask:
        if (isConfirmed) {
          return [context.tr.agent_action_loading_creating_task, context.tr.agent_action_loading_saving_task_details, context.tr.agent_action_loading_finalizing_task];
        } else if (isModifying) {
          return [
            context.tr.agent_action_loading_updating_task_details,
            context.tr.agent_action_loading_modifying_task_info,
            context.tr.agent_action_loading_adjusting_task_params,
          ];
        } else {
          return [context.tr.agent_action_loading_analyzing_inbox, context.tr.agent_action_loading_generating_task_details, context.tr.agent_action_loading_preparing_task_info];
        }
      case AgentActionType.reply:
        if (isModifying) {
          return [
            context.tr.agent_action_loading_updating_reply_draft,
            context.tr.agent_action_loading_modifying_email_content,
            context.tr.agent_action_loading_adjusting_response,
          ];
        } else {
          return [context.tr.agent_action_loading_analyzing_email, context.tr.agent_action_loading_drafting_reply, context.tr.agent_action_loading_generating_response];
        }
      case AgentActionType.createEvent:
        if (isConfirmed) {
          return [context.tr.agent_action_loading_creating_event, context.tr.agent_action_loading_saving_event_details, context.tr.agent_action_loading_finalizing_event];
        } else if (isModifying) {
          return [
            context.tr.agent_action_loading_updating_event_details,
            context.tr.agent_action_loading_modifying_event_info,
            context.tr.agent_action_loading_adjusting_event_params,
          ];
        } else {
          return [context.tr.agent_action_loading_analyzing_inbox, context.tr.agent_action_loading_generating_event_details, context.tr.agent_action_loading_preparing_event_info];
        }
      default:
        return [context.tr.agent_action_loading_processing_request, context.tr.agent_action_loading_analyzing_info, context.tr.agent_action_loading_generating_response];
    }
  }

  Widget _buildInboxWidget(BuildContext context, InboxEntity inbox, bool isUser) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser ? context.primaryContainer.withValues(alpha: 0.3) : context.surface,
        border: Border.all(color: isUser ? context.primaryContainer : context.outline.withValues(alpha: 0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Inbox Item',
            style: context.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: isUser ? context.onPrimaryContainer : context.primary),
          ),
          const SizedBox(height: 12),
          if (inbox.title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                inbox.title,
                style: context.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: (context.bodyLarge?.fontSize ?? 14) * 1.1,
                  color: isUser ? context.onPrimaryContainer : context.onSurface,
                  height: 1.4,
                ),
              ),
            ),
          if (inbox.description != null && inbox.description!.isNotEmpty)
            Text(inbox.description!, style: context.bodyLarge?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildTaskWidget(BuildContext context, TaskEntity task, bool isUser) {
    final projects = ref.read(projectListControllerProvider);
    final defaultProject = projects.firstWhere((p) => p.isDefault);
    final project = task.projectId != null ? projects.where((p) => p.uniqueId == task.projectId).firstOrNull : defaultProject;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isUser ? context.primaryContainer.withValues(alpha: 0.3) : context.surfaceVariant.withValues(alpha: 0.5),
        border: Border.all(color: isUser ? context.primaryContainer : context.outline.withValues(alpha: 0.3), width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (task.title != null && task.title!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title!,
                      style: context.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: (context.bodyLarge?.fontSize ?? 14) * 1.1,
                        color: isUser ? context.onPrimaryContainer : context.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (task.description != null && task.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(task.description!, style: context.bodyLarge?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant, height: 1.5)),
            ),

          Wrap(
            runSpacing: 6,
            spacing: 6,
            children: [
              if (project != null)
                IntrinsicWidth(
                  child: Container(
                    decoration: BoxDecoration(color: project.color, borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      children: [
                        VisirIcon(
                          type: project.icon ?? VisirIconType.project,
                          size: context.bodySmall!.height! * context.bodySmall!.fontSize! - 2,
                          color: Colors.white,
                          isSelected: true,
                        ),
                        const SizedBox(width: 4),
                        Text(project.name, style: context.bodySmall?.copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              Builder(
                builder: (context) {
                  final startAt = task.startAt ?? DateTime.now().dateOnly;
                  final isAllDay = task.startAt == null ? true : task.isAllDay;
                  final endAt = task.endAt ?? DateTime.now().dateOnly.add(isAllDay ? const Duration(days: 1) : const Duration(hours: 1));
                  final duration = endAt.difference(startAt).inMinutes;

                  String timeText;
                  if (isAllDay) {
                    timeText = startAt.forceDateString + ' • ' + context.tr.all_day;
                  } else {
                    timeText = startAt.forceDateTimeString;
                  }

                  if (!isAllDay) timeText += ', ${context.tr.ai_suggestion_duration(duration)}';
                  return IntrinsicWidth(
                    child: Container(
                      decoration: BoxDecoration(color: context.surfaceVariant, borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Row(
                        children: [
                          VisirIcon(type: VisirIconType.clock, size: context.bodySmall!.height! * context.bodySmall!.fontSize! - 2, color: Colors.white, isSelected: true),
                          const SizedBox(width: 4),
                          Text(timeText, style: context.bodySmall?.copyWith(color: Colors.white)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (task.rrule != null)
                IntrinsicWidth(
                  child: Container(
                    decoration: BoxDecoration(color: context.surfaceVariant, borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      children: [
                        VisirIcon(type: VisirIconType.repeat, size: context.bodySmall!.height! * context.bodySmall!.fontSize! - 2, color: Colors.white, isSelected: true),
                        const SizedBox(width: 4),
                        Text(
                          task.rrule!.toText(l10n: ref.read(rruleL10nEnProvider).asData!.value),
                          style: context.bodySmall?.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Event data structure for display
  Map<String, dynamic> _parseEventFromJson(Map<String, dynamic> jsonData) {
    return {
      'id': jsonData['id'],
      'title': jsonData['title'],
      'description': jsonData['description'],
      'calendar_id': jsonData['calendar_id'] ?? jsonData['calendarId'], // calendarId도 지원
      'start_at': jsonData['start_at'] ?? jsonData['startAt'],
      'end_at': jsonData['end_at'] ?? jsonData['endAt'],
      'location': jsonData['location'],
      'rrule': jsonData['rrule'],
      'attendees': jsonData['attendees'] as List<dynamic>? ?? [],
      'conference_link': jsonData['conference_link'],
      'isAllDay': jsonData['isAllDay'] ?? false,
    };
  }

  Widget _buildEventWidget(BuildContext context, Map<String, dynamic> eventData, bool isUser) {
    final calendarMap = ref.read(calendarListControllerProvider);
    final calendarList = calendarMap.values.expand((e) => e).toList();
    // calendar_id 또는 calendarId 모두 지원
    final calendarId = eventData['calendar_id'] as String? ?? eventData['calendarId'] as String?;
    CalendarEntity? calendar;
    if (calendarId != null && calendarId.isNotEmpty) {
      calendar = calendarList.firstWhereOrNull((c) => c.uniqueId == calendarId);
    }
    // calendarId가 없거나 찾지 못한 경우 첫 번째 캘린더 사용
    if (calendar == null && calendarList.isNotEmpty) {
      calendar = calendarList.first;
    }

    final startAtStr = eventData['start_at'] as String?;
    final endAtStr = eventData['end_at'] as String?;
    final isAllDay = eventData['isAllDay'] as bool? ?? false;

    DateTime? startAt;
    DateTime? endAt;
    if (startAtStr != null) {
      try {
        startAt = DateTime.parse(startAtStr).toLocal();
      } catch (e) {
        // Error parsing date
      }
    }
    if (endAtStr != null) {
      try {
        endAt = DateTime.parse(endAtStr).toLocal();
      } catch (e) {
        // Error parsing date
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border.all(color: context.outline.withValues(alpha: 0.3), width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (eventData['title'] != null && (eventData['title'] as String).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      eventData['title'] as String,
                      style: context.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: (context.bodyLarge?.fontSize ?? 14) * 1.1,
                        color: isUser ? context.onPrimaryContainer : context.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (eventData['description'] != null && (eventData['description'] as String).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                eventData['description'] as String,
                style: context.bodyLarge?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant, height: 1.5),
              ),
            ),

          Wrap(
            runSpacing: 6,
            spacing: 6,
            children: [
              if (calendar != null)
                IntrinsicWidth(
                  child: Container(
                    decoration: BoxDecoration(color: ColorX.fromHex(calendar.backgroundColor), borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      children: [
                        VisirIcon(type: VisirIconType.calendar, size: context.bodySmall!.height! * context.bodySmall!.fontSize! - 2, color: Colors.white, isSelected: true),
                        const SizedBox(width: 4),
                        Text(calendar.name, style: context.bodySmall?.copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              if (startAt != null)
                Builder(
                  builder: (context) {
                    final duration = (startAt != null && endAt != null) ? endAt.difference(startAt).inMinutes : 60;

                    String timeText;
                    if (startAt == null) {
                      timeText = context.tr.all_day;
                    } else if (isAllDay) {
                      timeText = startAt.forceDateString + ' • ' + context.tr.all_day;
                    } else {
                      timeText = startAt.forceDateTimeString;
                    }

                    if (!isAllDay && endAt != null) {
                      timeText += ', ${context.tr.ai_suggestion_duration(duration)}';
                    }
                    return IntrinsicWidth(
                      child: Container(
                        decoration: BoxDecoration(color: context.surfaceVariant, borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Row(
                          children: [
                            VisirIcon(type: VisirIconType.clock, size: context.bodySmall!.height! * context.bodySmall!.fontSize! - 2, color: Colors.white, isSelected: true),
                            const SizedBox(width: 4),
                            Text(timeText, style: context.bodySmall?.copyWith(color: Colors.white)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              if (eventData['location'] != null && (eventData['location'] as String).isNotEmpty)
                IntrinsicWidth(
                  child: Container(
                    decoration: BoxDecoration(color: context.surfaceVariant, borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      children: [
                        VisirIcon(type: VisirIconType.location, size: context.bodySmall!.height! * context.bodySmall!.fontSize! - 2, color: Colors.white, isSelected: true),
                        const SizedBox(width: 4),
                        Text(eventData['location'] as String, style: context.bodySmall?.copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              if (eventData['rrule'] != null && (eventData['rrule'] as String).isNotEmpty)
                Builder(
                  builder: (context) {
                    try {
                      final rruleStr = eventData['rrule'] as String;
                      final rrule = RecurrenceRule.fromString(rruleStr);
                      return IntrinsicWidth(
                        child: Container(
                          decoration: BoxDecoration(color: context.surfaceVariant, borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Row(
                            children: [
                              VisirIcon(type: VisirIconType.repeat, size: context.bodySmall!.height! * context.bodySmall!.fontSize! - 2, color: Colors.white, isSelected: true),
                              const SizedBox(width: 4),
                              Text(
                                rrule.toText(l10n: ref.read(rruleL10nEnProvider).asData!.value),
                                style: context.bodySmall?.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    } catch (e) {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              if (eventData['attendees'] != null && (eventData['attendees'] as List).isNotEmpty)
                IntrinsicWidth(
                  child: Container(
                    decoration: BoxDecoration(color: context.surfaceVariant, borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      children: [
                        VisirIcon(type: VisirIconType.attendee, size: context.bodySmall!.height! * context.bodySmall!.fontSize! - 2, color: Colors.white, isSelected: true),
                        const SizedBox(width: 4),
                        Text('${(eventData['attendees'] as List).join(', ')}', style: context.bodySmall?.copyWith(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              if (eventData['conference_link'] != null && (eventData['conference_link'] as String).isNotEmpty)
                IntrinsicWidth(
                  child: Container(
                    decoration: BoxDecoration(color: context.primary, borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      children: [
                        VisirIcon(type: VisirIconType.videoCall, size: context.bodySmall!.height! * context.bodySmall!.fontSize! - 2, color: context.onPrimary, isSelected: true),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMailSummaryWidget(BuildContext context, String summary, bool isUser) {
    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.surface,
        border: Border.all(color: context.outline.withValues(alpha: 0.3), width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(summary, style: context.bodyMedium?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant, height: 1.5)),
    );
  }

  Widget _buildMailReplyWidget(BuildContext context, Map<String, dynamic> replyData, bool isUser) {
    final reply = replyData['reply'] as String? ?? '';
    final subject = replyData['subject'] as String?;
    final fromList = (replyData['from'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final toList = (replyData['to'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final ccList = (replyData['cc'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final bccList = (replyData['bcc'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final suggestReplyAll = replyData['suggest_reply_all'] as bool? ?? false;

    // Check if reply contains snippet (forward preview)
    final hasSnippet = reply.contains('---------- Forwarded message ---------') || reply.contains('snippet');

    // Convert recipients to MailUserEntity
    MailUserEntity? fromUser;
    if (fromList.isNotEmpty) {
      final fromData = fromList.first;
      final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.mailOAuths)) ?? [];
      final oauth = oauths.firstWhereOrNull((o) => o.email == fromData['email']);
      final mailType = oauth?.type.mailType ?? MailEntityType.google;
      fromUser = MailUserEntity(email: fromData['email'] ?? '', name: fromData['name'], type: mailType);
    }

    final toUsers = toList.map((r) => MailUserEntity(email: r['email'] ?? '', name: r['name'])).where((u) => u.email.isNotEmpty).toList();
    final ccUsers = ccList.map((r) => MailUserEntity(email: r['email'] ?? '', name: r['name'])).where((u) => u.email.isNotEmpty).toList();
    final bccUsers = bccList.map((r) => MailUserEntity(email: r['email'] ?? '', name: r['name'])).where((u) => u.email.isNotEmpty).toList();

    return VisirButton(
      type: VisirButtonAnimationType.scaleAndOpacity,
      style: VisirButtonStyle(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(vertical: 8),
        backgroundColor: context.surface,
        border: Border.all(color: context.outline.withValues(alpha: 0.3), width: 1),
        borderRadius: BorderRadius.circular(6),
        hoverColor: context.outlineVariant.withValues(alpha: 0.1),
      ),
      onTap: () {
        // Open mailEditScreen when clicked
        Utils.showMailEditScreen(
          viewTitle: subject != null ? 'Forward' : null,
          from: fromUser,
          to: toUsers,
          cc: ccUsers,
          bcc: bccUsers,
          subject: subject,
          bodyHtml: reply.replaceAll('\\n', '\n'),
        );
      },
      child: SizedBox(
        width: double.maxFinite,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject section (if available)
            if (subject != null && subject.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  subject,
                  style: context.titleMedium?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurface, fontWeight: FontWeight.bold),
                ),
              ),
            ],
            // Recipients section (including From)
            if (fromList.isNotEmpty || toList.isNotEmpty || ccList.isNotEmpty || bccList.isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (fromList.isNotEmpty) ...[_buildRecipientRow(context, 'From', fromList, isUser), const SizedBox(height: 6)],
                  if (toList.isNotEmpty) ...[_buildRecipientRow(context, 'To', toList, isUser), const SizedBox(height: 6)],
                  if (ccList.isNotEmpty) ...[_buildRecipientRow(context, 'CC', ccList, isUser), const SizedBox(height: 6)],
                  if (bccList.isNotEmpty) ...[_buildRecipientRow(context, 'BCC', bccList, isUser), const SizedBox(height: 6)],
                ],
              ),
            ],
            // Only show divider and content if reply is not empty
            if (reply.isNotEmpty) ...[
              const SizedBox(height: 2),
              Container(height: 1, color: context.outline),
              const SizedBox(height: 8),
              // Reply content
              Text(reply.replaceAll('\\n', '\n'), style: context.bodyMedium?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurface, height: 1.5)),
              // Show snippet message if it's a forward preview
              if (hasSnippet) ...[
                const SizedBox(height: 8),
                Text(
                  context.tr.agent_action_see_full_email,
                  style: context.bodySmall?.copyWith(color: context.primary, fontStyle: FontStyle.italic),
                ),
              ],
            ],
            // Reply All suggestion
            if (suggestReplyAll) ...[
              const SizedBox(height: 8),
              Container(height: 1, color: context.outline),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: context.primaryContainer.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(6)),
                child: Row(
                  children: [
                    VisirIcon(type: VisirIconType.replyAll, size: context.bodySmall!.height! * context.bodySmall!.fontSize! - 2, color: context.primary, isSelected: true),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This email has CC recipients. Would you like to use "Reply All" instead?',
                        style: context.bodySmall?.copyWith(color: context.primary, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientRow(BuildContext context, String label, List<Map<String, dynamic>> recipients, bool isUser) {
    final recipientTexts = recipients
        .map((r) {
          final name = r['name'] as String? ?? '';
          final email = r['email'] as String? ?? '';
          if (name.isNotEmpty && name != email) {
            return '$name <$email>';
          }
          return email;
        })
        .join(', ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            label,
            style: context.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: Text(recipientTexts, style: context.bodySmall?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant)),
        ),
      ],
    );
  }

  String _getFunctionConfirmationMessage(String functionName, Map<String, dynamic> args) {
    switch (functionName) {
      case 'sendMail':
        return Utils.mainContext.tr.agent_action_confirm_send_mail;
      case 'replyMail':
        return Utils.mainContext.tr.agent_action_confirm_reply_mail;
      case 'forwardMail':
        return Utils.mainContext.tr.agent_action_confirm_forward_mail;
      case 'deleteTask':
        return Utils.mainContext.tr.agent_action_confirm_delete_task;
      case 'deleteEvent':
        return Utils.mainContext.tr.agent_action_confirm_delete_event;
      case 'deleteMail':
        return Utils.mainContext.tr.agent_action_confirm_delete_mail;
      case 'updateTask':
        return Utils.mainContext.tr.agent_action_confirm_update_task;
      case 'updateEvent':
        return Utils.mainContext.tr.agent_action_confirm_update_event;
      case 'markMailAsRead':
        return Utils.mainContext.tr.agent_action_confirm_mark_mail_read;
      case 'markMailAsUnread':
        return Utils.mainContext.tr.agent_action_confirm_mark_mail_unread;
      case 'archiveMail':
        return Utils.mainContext.tr.agent_action_confirm_archive_mail;
      case 'responseCalendarInvitation':
        final response = args['response'] as String? ?? '';
        return Utils.mainContext.tr.agent_action_confirm_response_calendar_invitation(response);
      case 'createTask':
        return Utils.mainContext.tr.agent_action_confirm_create_task;
      case 'createEvent':
        return Utils.mainContext.tr.agent_action_confirm_create_event;
      default:
        return Utils.mainContext.tr.agent_action_confirm_execute_action;
    }
  }

  Widget _buildActionConfirmWidget(BuildContext context, String functionName, Map<String, dynamic> functionArgs, String actionId, bool isUser) {
    final confirmationMessage = _getFunctionConfirmationMessage(functionName, functionArgs);
    final state = ref.watch(agentActionControllerProvider);
    final pendingCalls = state.pendingFunctionCalls ?? [];
    final isPending = pendingCalls.any((call) => call['action_id'] == actionId);

    // 이미 확인된 경우 빈 위젯 반환
    if (!isPending) {
      return const SizedBox.shrink();
    }

    return _ActionConfirmWidget(functionName: functionName, functionArgs: functionArgs, actionId: actionId, confirmationMessage: confirmationMessage, isUser: isUser);
  }

  /// Check if a function is a write action (requires confirmation)
  bool _isWriteAction(String functionName) {
    const writeActions = {
      // Task actions
      'createTask',
      'updateTask',
      'deleteTask',
      'toggleTaskStatus',
      'assignProject',
      'setPriority',
      'addTags',
      'removeTags',
      'setDueDate',
      'setReminder',
      'setRecurrence',
      'duplicateTask',
      'removeReminder',
      'removeRecurrence',
      'moveTask',
      // Event actions
      'createEvent',
      'updateEvent',
      'deleteEvent',
      'responseCalendarInvitation',
      'duplicateEvent',
      'moveEvent',
      'optimizeSchedule',
      'reschedule',
      // Mail actions
      'sendMail',
      'replyMail',
      'forwardMail',
      'deleteMail',
      'archiveMail',
      'unarchiveMail',
      'pinMail',
      'unpinMail',
      'markMailAsRead',
      'markMailAsUnread',
      'markMailAsImportant',
      'markMailAsNotImportant',
      'spamMail',
      'unspamMail',
      'moveMailToLabel',
      'replyAllMail',
      // Message actions
      'sendMessage',
      'replyMessage',
      'editMessage',
      'deleteMessage',
      'addReaction',
      'removeReaction',
      // Project actions
      'createProject',
      'updateProject',
      'deleteProject',
      'moveProject',
      'inviteUserToProject',
      'removeUserFromProject',
      'linkToProject',
      // Inbox actions
      'pinInbox',
      'unpinInbox',
      'createTaskFromInbox',
    };
    return writeActions.contains(functionName);
  }

  Widget _buildTaskEntityWithConfirm(BuildContext context, Map<String, dynamic> functionArgs, String actionId, bool isUser, {String? functionName, List<dynamic>? updatedTaggedTasks}) {
    try {
      final user = ref.read(authControllerProvider).requireValue;
      
      // updateTask인 경우 taskId로 기존 task 찾기
      final taskId = functionArgs['taskId'] as String?;
      TaskEntity? existingTask;
      
      // 먼저 updatedTaggedTasks에서 찾기
      if (updatedTaggedTasks != null && taskId != null && taskId.isNotEmpty) {
        for (final taskData in updatedTaggedTasks) {
          if (taskData is TaskEntity && taskData.id == taskId) {
            existingTask = taskData;
            break;
          } else if (taskData is Map<String, dynamic> && taskData['id'] == taskId) {
            // Map 형태인 경우 TaskEntity로 변환 시도
            try {
              existingTask = TaskEntity.fromJson(taskData);
            } catch (_) {}
            break;
          }
        }
      }
      
      // updatedTaggedTasks에서 찾지 못하면 taskId로 컨트롤러에서 찾기
      if (existingTask == null && taskId != null && taskId.isNotEmpty) {
        // taskListController에서 찾기
        try {
          final taskListState = ref.read(taskListControllerProvider);
          existingTask = taskListState.tasks.firstWhereOrNull((t) => t.id == taskId && !t.isEventDummyTask);
        } catch (_) {}
        
        // 찾지 못하면 calendarTaskListController에서 찾기
        if (existingTask == null) {
          try {
            final calendarState = ref.read(calendarTaskListControllerProvider(tabType: TabType.home));
            existingTask = calendarState.tasks.firstWhereOrNull((t) => t.id == taskId && !t.isEventDummyTask);
          } catch (_) {}
        }
      }
      
      // functionArgs에서 업데이트할 정보 가져오기
      final title = functionArgs['title'] as String? ?? existingTask?.title ?? '';
      final description = functionArgs['description'] as String? ?? existingTask?.description ?? '';
      final projectId = functionArgs['projectId'] as String? ?? existingTask?.projectId;
      final startAtStr = functionArgs['startAt'] as String? ?? functionArgs['start_at'] as String?;
      final endAtStr = functionArgs['endAt'] as String? ?? functionArgs['end_at'] as String?;
      final isAllDay = functionArgs['isAllDay'] as bool? ?? existingTask?.isAllDay ?? false;

      DateTime? startAt = existingTask?.startAt;
      DateTime? endAt = existingTask?.endAt;
      
      if (startAtStr != null) {
        try {
          startAt = DateTime.parse(startAtStr).toLocal();
        } catch (e) {
          startAt = startAt ?? DateTime.now();
        }
      } else {
        startAt = startAt ?? DateTime.now();
      }

      if (endAtStr != null) {
        try {
          endAt = DateTime.parse(endAtStr).toLocal();
        } catch (e) {
          endAt = endAt ?? startAt.add(isAllDay ? const Duration(days: 1) : const Duration(hours: 1));
        }
      } else {
        endAt = endAt ?? startAt.add(isAllDay ? const Duration(days: 1) : const Duration(hours: 1));
      }

      final task = existingTask?.copyWith(
        title: title,
        description: description,
        projectId: projectId,
        startAt: startAt,
        endAt: endAt,
        isAllDay: isAllDay,
      ) ?? TaskEntity(
        id: taskId ?? const Uuid().v4(),
        ownerId: user.id,
        title: title,
        description: description,
        projectId: projectId,
        startAt: startAt,
        endAt: endAt,
        isAllDay: isAllDay,
        createdAt: existingTask?.createdAt ?? DateTime.now(),
        status: existingTask?.status ?? TaskStatus.none,
      );

      return _buildTaskWidget(context, task, isUser);
    } catch (e) {
      return Padding(padding: const EdgeInsets.only(top: 6), child: _buildActionConfirmWidget(context, 'createTask', functionArgs, actionId, isUser));
    }
  }

  Widget _buildEventEntityWithConfirm(BuildContext context, Map<String, dynamic> functionArgs, String actionId, bool isUser) {
    try {
      final title = functionArgs['title'] as String? ?? '';
      final description = functionArgs['description'] as String? ?? '';
      final calendarId = functionArgs['calendarId'] as String?;
      final startAtStr = functionArgs['startAt'] as String? ?? functionArgs['start_at'] as String?;
      final endAtStr = functionArgs['endAt'] as String? ?? functionArgs['end_at'] as String?;
      final isAllDay = functionArgs['isAllDay'] as bool? ?? false;
      final location = functionArgs['location'] as String?;
      final attendeesList = functionArgs['attendees'] as List<dynamic>?;

      DateTime? startAt;
      DateTime? endAt;
      if (startAtStr != null) {
        try {
          startAt = DateTime.parse(startAtStr).toLocal();
        } catch (e) {
          startAt = DateTime.now();
        }
      } else {
        startAt = DateTime.now();
      }

      if (endAtStr != null) {
        try {
          endAt = DateTime.parse(endAtStr).toLocal();
        } catch (e) {
          endAt = startAt.add(isAllDay ? const Duration(days: 1) : const Duration(hours: 1));
        }
      } else {
        endAt = startAt.add(isAllDay ? const Duration(days: 1) : const Duration(hours: 1));
      }

      final eventData = {
        'id': const Uuid().v4(),
        'title': title,
        'description': description,
        'calendar_id': calendarId,
        'start_at': startAt.toIso8601String(),
        'end_at': endAt.toIso8601String(),
        'location': location,
        'attendees': attendeesList ?? [],
        'isAllDay': isAllDay,
      };

      return _buildEventWidget(context, eventData, isUser);
    } catch (e) {
      return Padding(padding: const EdgeInsets.only(top: 6), child: _buildActionConfirmWidget(context, 'createEvent', functionArgs, actionId, isUser));
    }
  }

  /// Check if content appears to be Markdown format
  bool _isMarkdownContent(String content) {
    if (content.trim().isEmpty) return false;

    // Common Markdown patterns
    final markdownPatterns = [
      RegExp(r'^#{1,6}\s+.+', multiLine: true), // Headers (# Header)
      RegExp(r'^\s*[-*+]\s+.+', multiLine: true), // Unordered lists
      RegExp(r'^\s*\d+\.\s+.+', multiLine: true), // Ordered lists
      RegExp(r'\*\*.*?\*\*', dotAll: true), // Bold (**text**)
      RegExp(r'\*.*?\*', dotAll: true), // Italic (*text*)
      RegExp(r'__.*?__', dotAll: true), // Bold (__text__)
      RegExp(r'_.*?_', dotAll: true), // Italic (_text_)
      RegExp(r'\[.*?\]\(.*?\)', dotAll: true), // Links [text](url)
      RegExp(r'^>\s+.+', multiLine: true), // Blockquotes
      RegExp(r'```[\s\S]*?```', dotAll: true), // Code blocks
      RegExp(r'`[^`]+`', dotAll: true), // Inline code
      RegExp(r'^\s*\|.*\|', multiLine: true), // Tables
      RegExp(r'^---+$', multiLine: true), // Horizontal rules
    ];

    // Check if content matches any Markdown pattern
    int matchCount = 0;
    for (final pattern in markdownPatterns) {
      if (pattern.hasMatch(content)) {
        matchCount++;
      }
    }

    // If multiple patterns match, it's likely Markdown
    return matchCount >= 2;
  }

  /// Extract tagged projects from message content
  Widget _buildMessageContent(BuildContext context, String content, bool isUser) {
    final baseStyle = context.bodyLarge?.textColor(context.onSurfaceVariant);

    // Remove function call JSON arrays from content (agent responses may contain raw function calls)
    String cleanedContent = content;

    // Remove JSON arrays that contain function calls (format: [{"function": "...", "arguments": {...}}, ...])
    final functionCallArrayRegex = RegExp(
      r'\[\s*\{[^}]*"function"\s*:\s*"[^"]+"[^}]*"arguments"\s*:\s*\{[^}]*\}[^}]*\}(?:\s*,\s*\{[^}]*"function"\s*:\s*"[^"]+"[^}]*"arguments"\s*:\s*\{[^}]*\}[^}]*\})*\s*\]',
      dotAll: true,
    );
    cleanedContent = cleanedContent.replaceAll(functionCallArrayRegex, '');

    // Also try to detect and remove function call arrays by parsing JSON
    try {
      // Find all JSON array patterns
      final jsonArrayRegex = RegExp(r'\[(?:\s*\{[^}]*\}(?:\s*,\s*\{[^}]*\})*)?\s*\]', dotAll: true);
      final matches = jsonArrayRegex.allMatches(cleanedContent).toList();

      // Process matches in reverse order to maintain positions
      for (final match in matches.reversed) {
        try {
          final arrayStr = cleanedContent.substring(match.start, match.end);
          final parsed = jsonDecode(arrayStr) as List<dynamic>?;
          if (parsed != null && parsed.isNotEmpty) {
            bool isFunctionCallArray = false;
            for (final item in parsed) {
              if (item is Map<String, dynamic> && item.containsKey('function') && item.containsKey('arguments')) {
                isFunctionCallArray = true;
                break;
              }
            }
            if (isFunctionCallArray) {
              // Remove the function call array
              cleanedContent = cleanedContent.substring(0, match.start) + cleanedContent.substring(match.end);
            }
          }
        } catch (e) {
          // Skip invalid JSON
        }
      }
    } catch (e) {
      // If parsing fails, continue with cleaned content
    }

    // Remove any remaining standalone function call objects
    final functionCallObjectRegex = RegExp(r'\{\s*"function"\s*:\s*"[^"]+"\s*,\s*"arguments"\s*:\s*\{[^}]*\}\s*\}', dotAll: true);
    cleanedContent = cleanedContent.replaceAll(functionCallObjectRegex, '');

    // Clean up any extra whitespace or newlines left behind
    cleanedContent = cleanedContent.replaceAll(RegExp(r'\n\s*\n\s*\n+'), '\n\n').trim();

    // Remove <function_call> tags and their content (only show as block, don't render content)
    final functionCallTagRegex = RegExp(r'<function_call[^>]*>.*?</function_call>', dotAll: true);
    cleanedContent = cleanedContent.replaceAll(functionCallTagRegex, '');

    // Remove conversation_title tags completely (they should not be rendered)
    cleanedContent = cleanedContent.replaceAll(RegExp(r'<conversation_title>.*?</conversation_title>', dotAll: true), '');
    cleanedContent = cleanedContent.replaceAll(RegExp(r'&lt;conversation_title&gt;.*?&lt;/conversation_title&gt;', dotAll: true), '');

    // 전역적으로 모든 HTML 엔티티 unescape 처리 (특정 태그가 아니라 모든 엔티티)
    final unescape = HtmlUnescape();
    cleanedContent = unescape.convert(cleanedContent);

    // Extract tagged items from HTML tags first
    final Map<String, Map<String, dynamic>> taggedItems = {};
    final RegExp taggedTaskRegex = RegExp(r'<tagged_task>(.*?)</tagged_task>', dotAll: true);
    final RegExp taggedEventRegex = RegExp(r'<tagged_event>(.*?)</tagged_event>', dotAll: true);
    // tagged_connection, tagged_channel, tagged_project are handled inline via customWidgetBuilder

    // Extract tagged tasks
    for (final match in taggedTaskRegex.allMatches(cleanedContent)) {
      try {
        final jsonText = match.group(1)?.trim() ?? '';
        if (jsonText.isNotEmpty) {
          final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
          final title = jsonData['title'] as String? ?? '';
          if (title.isNotEmpty) {
            taggedItems['@$title'] = {'type': 'task', 'data': jsonData};
          }
        }
      } catch (e) {
        // Skip invalid JSON
      }
    }

    // Extract tagged events
    for (final match in taggedEventRegex.allMatches(cleanedContent)) {
      try {
        final jsonText = match.group(1)?.trim() ?? '';
        if (jsonText.isNotEmpty) {
          final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
          final title = jsonData['title'] as String? ?? '';
          if (title.isNotEmpty) {
            taggedItems['@$title'] = {'type': 'event', 'data': jsonData};
          }
        }
      } catch (e) {
        // Skip invalid JSON
      }
    }

    // Note: We don't extract tagged_connection, tagged_channel, or tagged_project to taggedItems
    // because they are rendered inline via customWidgetBuilder.
    // Adding them to taggedItems would cause duplicate rendering (@mention + tagged_xxx tag)

    // Convert tagged_item tags to inapp_entity tags for UI rendering
    // (cleanedContent already initialized above with function call JSON removed)

    // Convert all tagged_task to inapp_task (process in reverse order to maintain positions)
    final taggedTaskMatches = taggedTaskRegex.allMatches(cleanedContent).toList();
    for (final match in taggedTaskMatches.reversed) {
      try {
        final jsonText = match.group(1)?.trim() ?? '';
        if (jsonText.isNotEmpty) {
          final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
          // Convert to inapp_task format
          final inappTaskJson = jsonEncode(jsonData);
          cleanedContent = cleanedContent.substring(0, match.start) + '<inapp_task>$inappTaskJson</inapp_task>' + cleanedContent.substring(match.end);
        }
      } catch (e) {
        // Skip invalid JSON
      }
    }

    // Convert all tagged_event to inapp_event (process in reverse order to maintain positions)
    final taggedEventMatches = taggedEventRegex.allMatches(cleanedContent).toList();
    for (final match in taggedEventMatches.reversed) {
      try {
        final jsonText = match.group(1)?.trim() ?? '';
        if (jsonText.isNotEmpty) {
          final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
          // Convert to inapp_event format
          final inappEventJson = jsonEncode(jsonData);
          cleanedContent = cleanedContent.substring(0, match.start) + '<inapp_event>$inappEventJson</inapp_event>' + cleanedContent.substring(match.end);
        }
      } catch (e) {
        // Skip invalid JSON
      }
    }

    // Keep tagged_connection, tagged_channel, tagged_project for inline badge rendering
    // They will be handled by HtmlWidget's customWidgetBuilder
    // The text content will be hidden via customStylesBuilder

    // Remove @mention text that matches tagged_project, tagged_channel, or tagged_connection names
    // to prevent duplicate rendering (both @mention and tagged_xxx tag)
    final Set<String> namesToRemove = {};

    // Extract project names from tagged_project tags
    final taggedProjectMatches = RegExp(r'<tagged_project>(.*?)</tagged_project>', dotAll: true).allMatches(cleanedContent);
    for (final match in taggedProjectMatches) {
      try {
        final jsonText = match.group(1)?.trim() ?? '';
        if (jsonText.isNotEmpty) {
          final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
          final name = jsonData['name'] as String? ?? '';
          if (name.isNotEmpty) {
            namesToRemove.add('@$name');
          }
        }
      } catch (e) {
        // Skip invalid JSON
      }
    }

    // Extract channel names from tagged_channel tags
    final taggedChannelMatches = RegExp(r'<tagged_channel>(.*?)</tagged_channel>', dotAll: true).allMatches(cleanedContent);
    for (final match in taggedChannelMatches) {
      try {
        final jsonText = match.group(1)?.trim() ?? '';
        if (jsonText.isNotEmpty) {
          final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
          final name = jsonData['name'] as String? ?? '';
          if (name.isNotEmpty) {
            namesToRemove.add('@$name');
          }
        }
      } catch (e) {
        // Skip invalid JSON
      }
    }

    // Extract connection names from tagged_connection tags
    final taggedConnectionMatches = RegExp(r'<tagged_connection>(.*?)</tagged_connection>', dotAll: true).allMatches(cleanedContent);
    for (final match in taggedConnectionMatches) {
      try {
        final jsonText = match.group(1)?.trim() ?? '';
        if (jsonText.isNotEmpty) {
          final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
          final name = jsonData['name'] as String? ?? '';
          final email = jsonData['email'] as String? ?? '';
          final displayName = name.isNotEmpty && name != 'No name' ? name : (email.isNotEmpty ? email : '');
          if (displayName.isNotEmpty) {
            namesToRemove.add('@$displayName');
          }
        }
      } catch (e) {
        // Skip invalid JSON
      }
    }

    // Remove @mention text that matches the names (but keep the tags)
    for (final mentionToRemove in namesToRemove) {
      final escapedMention = RegExp.escape(mentionToRemove);
      // Remove @mentions that are not inside HTML tags (including tagged_xxx tags)
      cleanedContent = cleanedContent.replaceAllMapped(
        RegExp('(?<!<[^>]*)$escapedMention(?!<[^>]*>)', multiLine: true),
        (match) => '', // Remove the @mention text
      );
    }

    // Wrap content in <div> if it doesn't start with < (to make it HTML)
    if (!cleanedContent.trim().startsWith('<')) {
      cleanedContent = '<div>$cleanedContent</div>';
    }

    // Check if content is Markdown (contains Markdown patterns)
    final isMarkdown = _isMarkdownContent(cleanedContent);

    // If content is markdown, convert it to HTML
    // <inapp_> and <tagged_> tags will be preserved as-is since they're already HTML tags
    String finalContent = cleanedContent;
    if (isMarkdown) {
      try {
        // If content doesn't start with <, wrap it in <div> first
        String contentToConvert = cleanedContent;
        bool wasWrapped = false;
        if (!contentToConvert.trim().startsWith('<')) {
          contentToConvert = '<div>$contentToConvert</div>';
          wasWrapped = true;
        }

        // Convert markdown to HTML
        // Note: The markdown parser may escape custom tags like <inapp_task>, so we need to restore them
        final htmlFromMarkdown = md.markdownToHtml(contentToConvert);

        // 전역적으로 모든 HTML 엔티티 unescape 처리 (markdown 변환 후)
        final unescape = HtmlUnescape();
        String restoredHtml = unescape.convert(htmlFromMarkdown);

        // Remove conversation_title tags completely (they should not be rendered)
        restoredHtml = restoredHtml.replaceAll(RegExp(r'<conversation_title>.*?</conversation_title>', dotAll: true), '');

        // Restore escaped inapp_ and tagged_ tags
        // The markdown parser escapes < and > in unknown tags, so we need to restore them

        // First, restore escaped tag pairs: &lt;inapp_xxx&gt;...&lt;/inapp_xxx&gt; -> <inapp_xxx>...</inapp_xxx>
        // Also restore conversation_title tags
        // Match the entire tag pair including escaped content (non-greedy, dotall mode)
        final escapedTagPairRegex = RegExp(r'&lt;(inapp_|tagged_|conversation_)([a-z_]+)&gt;([\s\S]*?)&lt;/(inapp_|tagged_|conversation_)([a-z_]+)&gt;', caseSensitive: false, dotAll: true);

        restoredHtml = restoredHtml.replaceAllMapped(escapedTagPairRegex, (match) {
          final openingPrefix = match.group(1)!;
          final openingTagName = match.group(2)!;
          final content = match.group(3)!;
          final closingPrefix = match.group(4)!;
          final closingTagName = match.group(5)!;

          // Verify that opening and closing tags match
          if (openingPrefix == closingPrefix && openingTagName == closingTagName) {
            // Restore HTML entities in the JSON content
            final restoredContent = content
                .replaceAll('&quot;', '"')
                .replaceAll('&amp;', '&')
                .replaceAll('&#39;', "'")
                .replaceAll('&#x27;', "'")
                .replaceAll('&lt;', '<')
                .replaceAll('&gt;', '>');
            return '<$openingPrefix$openingTagName>$restoredContent</$closingPrefix$closingTagName>';
          }
          // If tags don't match, return original
          return match.group(0)!;
        });

        // Also handle cases where tags might be on separate lines or have different escaping
        // Restore any remaining escaped opening tags (standalone, not part of a pair)
        restoredHtml = restoredHtml.replaceAllMapped(RegExp(r'&lt;(inapp_|tagged_|conversation_)([a-z_]+)&gt;', caseSensitive: false), (match) => '<${match.group(1)}${match.group(2)}>');

        // Restore any remaining escaped closing tags (standalone, not part of a pair)
        restoredHtml = restoredHtml.replaceAllMapped(RegExp(r'&lt;/(inapp_|tagged_|conversation_)([a-z_]+)&gt;', caseSensitive: false), (match) => '</${match.group(1)}${match.group(2)}>');

        // Also restore JSON quotes that might still be escaped in restored tags
        // Find all restored tag pairs and unescape their content
        final restoredTagPairRegex = RegExp(r'<(inapp_|tagged_)([a-z_]+)>([\s\S]*?)</(inapp_|tagged_)([a-z_]+)>', caseSensitive: false, dotAll: true);

        restoredHtml = restoredHtml.replaceAllMapped(restoredTagPairRegex, (match) {
          final openingPrefix = match.group(1)!;
          final openingTagName = match.group(2)!;
          final content = match.group(3)!;
          final closingPrefix = match.group(4)!;
          final closingTagName = match.group(5)!;

          // Verify that opening and closing tags match
          if (openingPrefix == closingPrefix && openingTagName == closingTagName) {
            // Restore any remaining HTML entities in the JSON content
            final restoredContent = content.replaceAll('&quot;', '"').replaceAll('&amp;', '&').replaceAll('&#39;', "'").replaceAll('&#x27;', "'");
            return '<$openingPrefix$openingTagName>$restoredContent</$closingPrefix$closingTagName>';
          }
          return match.group(0)!;
        });

        // If we wrapped it, remove the outer <div> wrapper that markdown parser might have added
        if (wasWrapped) {
          // Remove wrapper div if markdown parser added another one
          finalContent = restoredHtml.replaceAllMapped(RegExp(r'^<div>\s*(.*?)\s*</div>$', dotAll: true), (m) => m.group(1) ?? restoredHtml);
          // If no wrapper was added, ensure we have one
          if (!finalContent.trim().startsWith('<')) {
            finalContent = '<div>$finalContent</div>';
          }
        } else {
          finalContent = restoredHtml;
        }
      } catch (e) {
        // If conversion fails, keep original content
        finalContent = cleanedContent;
      }
    }

    // All content is now HTML (isHtml is always true), process @mentions
    {
      // For HTML content (or mixed HTML/Markdown), we need to handle @mentions in text nodes
      // HtmlWidget doesn't easily support inline widgets in text, so we'll process the HTML string
      // and replace @mentions with special markers that we can handle in customWidgetBuilder
      String processedHtml = finalContent;
      if (taggedItems.isNotEmpty) {
        // Replace @mentions in HTML text with special placeholders
        for (final entry in taggedItems.entries) {
          final mentionKey = entry.key; // "@taskname"
          final mentionName = mentionKey.substring(1); // "taskname"
          // Escape special regex characters
          final escapedMention = RegExp.escape(mentionKey);
          // Replace @mentions that are not inside HTML tags
          processedHtml = processedHtml.replaceAllMapped(
            RegExp('(?<!<[^>]*)$escapedMention(?!<[^>]*>)', multiLine: true),
            (match) => '<span class="tagged-mention" data-mention="$mentionName">$mentionKey</span>',
          );
        }
      }

      // baseStyle에서 fontFamily를 제거하여 기본 폰트 사용
      final htmlTextStyle = baseStyle?.copyWith(fontFamily: null);

      print('############# html: ${processedHtml}');

      return Container(
        decoration: isUser ? BoxDecoration(color: context.primary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(6)) : null,
        padding: isUser ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6) : null,
        child: HtmlWidget(
          processedHtml,
          textStyle: htmlTextStyle,
          renderMode: RenderMode.column,
          customWidgetBuilder: (element) {
            // Hide conversation_title tags completely
            if (element.localName == 'conversation_title') {
              return const SizedBox.shrink();
            }
            // Handle tagged mentions in HTML text
            if (element.localName == 'span' && element.classes.contains('tagged-mention')) {
              final mentionName = element.attributes['data-mention'] ?? '';
              final mentionText = '@$mentionName';
              // Find matching tagged item
              String? matchedKey;
              if (taggedItems.containsKey(mentionText)) {
                matchedKey = mentionText;
              } else {
                // Try case-insensitive match
                final normalizedMentionName = mentionName.trim().toLowerCase();
                for (final key in taggedItems.keys) {
                  final keyName = key.substring(1).trim().toLowerCase();
                  if (keyName == normalizedMentionName) {
                    matchedKey = key;
                    break;
                  }
                }
              }

              if (matchedKey != null && taggedItems.containsKey(matchedKey)) {
                final itemData = taggedItems[matchedKey]!;
                final itemType = itemData['type'] as String;
                final displayText = matchedKey.substring(1); // Remove @

                // Determine icon based on item type
                VisirIconType iconType;
                switch (itemType) {
                  case 'task':
                    iconType = VisirIconType.task;
                    break;
                  case 'event':
                    iconType = VisirIconType.calendar;
                    break;
                  case 'connection':
                    iconType = VisirIconType.attendee;
                    break;
                  case 'channel':
                    iconType = VisirIconType.chatChannel;
                    break;
                  case 'project':
                    iconType = VisirIconType.project;
                    break;
                  default:
                    iconType = VisirIconType.task;
                }

                return InlineCustomWidget(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.surface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: context.outline.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        VisirIcon(type: iconType, size: 12, color: isUser ? context.onPrimaryContainer : context.onSurface, isSelected: true),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            displayText,
                            style: (baseStyle ?? context.bodyLarge ?? const TextStyle()).copyWith(
                              color: isUser ? context.onPrimaryContainer : context.onSurface,
                              fontSize: ((baseStyle ?? context.bodyLarge)?.fontSize ?? 14),
                              height: 1.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            }
            if (element.localName == 'inapp_inbox') {
              try {
                final jsonText = element.text.trim();
                final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
                final inbox = InboxEntity.fromJson(jsonData, local: true);
                return _buildInboxWidget(context, inbox, isUser);
              } catch (e) {
                return Text('Error parsing inbox: $e', style: baseStyle?.copyWith(color: context.error));
              }
            }
            if (element.localName == 'inapp_task') {
              try {
                final jsonText = element.text.trim();
                if (jsonText.isEmpty) {
                  return const SizedBox.shrink();
                }
                // Extract first valid JSON object if multiple JSON objects are concatenated
                Map<String, dynamic> jsonData;
                try {
                  jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
                } catch (e) {
                  // Try to extract first JSON object using regex
                  final jsonMatch = RegExp(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}').firstMatch(jsonText);
                  if (jsonMatch != null) {
                    jsonData = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
                  } else {
                    rethrow;
                  }
                }

                // Filter out null values and string "null" values
                final cleanedData = <String, dynamic>{};
                jsonData.forEach((key, value) {
                  if (value != null && value != 'null' && !(value is String && value.toLowerCase() == 'null')) {
                    cleanedData[key] = value;
                  }
                });

                // Convert camelCase to snake_case for TaskEntity.fromJson
                final normalizedData = <String, dynamic>{};
                cleanedData.forEach((key, value) {
                  String snakeKey = key;
                  if (key == 'startAt') {
                    snakeKey = 'start_at';
                  } else if (key == 'endAt') {
                    snakeKey = 'end_at';
                  } else if (key == 'projectId') {
                    snakeKey = 'project_id';
                  } else if (key == 'createdAt') {
                    snakeKey = 'created_at';
                  } else if (key == 'updatedAt') {
                    snakeKey = 'updated_at';
                  } else if (key == 'isAllDay') {
                    snakeKey = 'is_all_day';
                  } else if (key == 'recurrenceEndAt') {
                    snakeKey = 'recurrence_end_at';
                  } else if (key == 'recurringTaskId') {
                    snakeKey = 'recurring_task_id';
                  } else if (key == 'excludedRecurrenceDate') {
                    snakeKey = 'excluded_recurrence_date';
                  } else if (key == 'editedRecurrenceTaskIds') {
                    snakeKey = 'edited_recurrence_task_ids';
                  } else if (key == 'doNotApplyDateOffset') {
                    snakeKey = 'do_not_apply_date_offset';
                  }
                  normalizedData[snakeKey] = value;
                });

                // Normalize rrule if present
                if (normalizedData['rrule'] != null && normalizedData['rrule'] is String) {
                  final rruleStr = normalizedData['rrule'] as String;
                  if (rruleStr.isNotEmpty && !rruleStr.toUpperCase().startsWith('RRULE:')) {
                    normalizedData['rrule'] = 'RRULE:$rruleStr';
                  }
                }

                var task = TaskEntity.fromJson(normalizedData, local: true);

                // If id is null, try to find task from controllers
                if (task.id == null || task.id!.isEmpty) {
                  final title = normalizedData['title'] as String?;
                  TaskEntity? foundTask;

                  // Try to find task by title from controllers
                  if (title != null && title.isNotEmpty) {
                    try {
                      final taskListState = ref.read(taskListControllerProvider);
                      final allTasks = taskListState.tasks;
                      foundTask = allTasks.firstWhereOrNull((t) => t.title == title);
                    } catch (_) {}

                    if (foundTask == null) {
                      try {
                        final calendarState = ref.read(calendarTaskListControllerProvider(tabType: TabType.home));
                        final calendarTasks = calendarState.tasks;
                        foundTask = calendarTasks.firstWhereOrNull((t) => t.title == title);
                      } catch (_) {}
                    }

                    if (foundTask != null) {
                      // Update task with found id and other fields
                      task = foundTask;
                    }
                  }
                }

                return _buildTaskWidget(context, task, isUser);
              } catch (e) {
                // 디버깅을 위해 에러 메시지 표시
                return Text('${context.tr.agent_action_task_generation_failed}: $e', style: baseStyle?.copyWith(color: context.error));
              }
            }
            if (element.localName == 'inapp_event') {
              try {
                final jsonText = element.text.trim();
                if (jsonText.isEmpty) {
                  return const SizedBox.shrink();
                }
                // Extract first valid JSON object if multiple JSON objects are concatenated
                Map<String, dynamic> jsonData;
                try {
                  jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
                } catch (e) {
                  // Try to extract first JSON object using regex
                  final jsonMatch = RegExp(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}').firstMatch(jsonText);
                  if (jsonMatch != null) {
                    jsonData = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
                  } else {
                    rethrow;
                  }
                }

                // Debug: Log raw JSON data
                // Normalize rrule if present
                if (jsonData['rrule'] != null && jsonData['rrule'] is String) {
                  final rruleStr = jsonData['rrule'] as String;
                  if (rruleStr.isNotEmpty && !rruleStr.toUpperCase().startsWith('RRULE:')) {
                    jsonData['rrule'] = 'RRULE:$rruleStr';
                  }
                }

                final eventData = _parseEventFromJson(jsonData);
                return _buildEventWidget(context, eventData, isUser);
              } catch (e) {
                // 디버깅을 위해 에러 메시지 표시
                return Text(context.tr.agent_action_task_generation_failed.replaceAll('task', 'event'), style: baseStyle?.copyWith(color: context.error));
              }
            }
            if (element.localName == 'inapp_mail_summary') {
              try {
                final jsonText = element.text.trim();
                if (jsonText.isEmpty) {
                  return const SizedBox.shrink();
                }
                // Extract first valid JSON object if multiple JSON objects are concatenated
                Map<String, dynamic> jsonData;
                try {
                  jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
                } catch (e) {
                  // Try to extract first JSON object using regex
                  final jsonMatch = RegExp(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}').firstMatch(jsonText);
                  if (jsonMatch != null) {
                    jsonData = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
                  } else {
                    rethrow;
                  }
                }

                final summary = jsonData['summary'] as String? ?? '';
                if (summary.isEmpty) {
                  return const SizedBox.shrink();
                }
                return _buildMailSummaryWidget(context, summary, isUser);
              } catch (e) {
                return Text('Error parsing mail summary: $e', style: baseStyle?.copyWith(color: context.error));
              }
            }
            if (element.localName == 'inapp_mail') {
              try {
                final jsonText = element.text.trim();
                if (jsonText.isEmpty) {
                  return const SizedBox.shrink();
                }
                // Extract first valid JSON object if multiple JSON objects are concatenated
                Map<String, dynamic> jsonData;
                try {
                  jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
                } catch (e) {
                  // Try to extract first JSON object using regex
                  final jsonMatch = RegExp(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}').firstMatch(jsonText);
                  if (jsonMatch != null) {
                    jsonData = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
                  } else {
                    rethrow;
                  }
                }

                final mailData = jsonData;
                if (mailData['reply'] == null && mailData['message'] != null) {
                  mailData['reply'] = mailData['message'];
                }
                return _buildMailReplyWidget(context, mailData, isUser);
              } catch (e) {
                return Text('Error parsing mail: $e', style: baseStyle?.copyWith(color: context.error));
              }
            }
            if (element.localName == 'inapp_mail_entity') {
              try {
                final jsonText = element.text.trim();
                if (jsonText.isEmpty) {
                  return const SizedBox.shrink();
                }
                Map<String, dynamic> jsonData;
                try {
                  jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
                } catch (e) {
                  final jsonMatch = RegExp(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}').firstMatch(jsonText);
                  if (jsonMatch != null) {
                    jsonData = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
                  } else {
                    rethrow;
                  }
                }

                final mail = MailEntity.fromJson(jsonData);
                return _buildMailEntityWidget(context, mail, isUser);
              } catch (e) {
                return Text('Error parsing mail entity: $e', style: baseStyle?.copyWith(color: context.error));
              }
            }
            if (element.localName == 'inapp_message') {
              try {
                final jsonText = element.text.trim();
                if (jsonText.isEmpty) {
                  return const SizedBox.shrink();
                }
                Map<String, dynamic> jsonData;
                try {
                  jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
                } catch (e) {
                  final jsonMatch = RegExp(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}').firstMatch(jsonText);
                  if (jsonMatch != null) {
                    jsonData = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
                  } else {
                    rethrow;
                  }
                }
                final message = MessageEntity.fromJson(jsonData);
                return _buildMessageWidget(context, message, isUser);
              } catch (e) {
                return Text('Error parsing message: $e', style: baseStyle?.copyWith(color: context.error));
              }
            }
            if (element.localName == 'inapp_calendar') {
              try {
                final jsonText = element.text.trim();
                if (jsonText.isEmpty) {
                  return const SizedBox.shrink();
                }
                Map<String, dynamic> jsonData;
                try {
                  jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
                } catch (e) {
                  final jsonMatch = RegExp(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}').firstMatch(jsonText);
                  if (jsonMatch != null) {
                    jsonData = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
                  } else {
                    rethrow;
                  }
                }
                final calendar = CalendarEntity.fromJson(jsonData);
                return _buildCalendarWidget(context, calendar, isUser);
              } catch (e) {
                return Text('Error parsing calendar: $e', style: baseStyle?.copyWith(color: context.error));
              }
            }
            if (element.localName == 'inapp_event_entity') {
              try {
                final jsonText = element.text.trim();
                if (jsonText.isEmpty) {
                  return const SizedBox.shrink();
                }
                Map<String, dynamic> jsonData;
                try {
                  jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
                } catch (e) {
                  final jsonMatch = RegExp(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}').firstMatch(jsonText);
                  if (jsonMatch != null) {
                    jsonData = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
                  } else {
                    rethrow;
                  }
                }
                final event = EventEntity.fromJson(jsonData);
                return _buildEventEntityWidget(context, event, isUser);
              } catch (e) {
                return Text('Error parsing event entity: $e', style: baseStyle?.copyWith(color: context.error));
              }
            }
            // Tagged items rendering - inline badges
            if (element.localName == 'tagged_task') {
              try {
                final jsonText = element.text.trim();
                if (jsonText.isEmpty) {
                  return const SizedBox.shrink();
                }
                Map<String, dynamic> jsonData;
                try {
                  jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
                } catch (e) {
                  final jsonMatch = RegExp(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}').firstMatch(jsonText);
                  if (jsonMatch != null) {
                    jsonData = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
                  } else {
                    rethrow;
                  }
                }

                final taskTitle = jsonData['title'] as String? ?? 'Untitled';
                return InlineCustomWidget(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(4)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        VisirIcon(type: VisirIconType.task, size: 12, color: isUser ? context.onPrimaryContainer : context.onSurface, isSelected: true),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            taskTitle,
                            style: (baseStyle ?? context.bodyLarge ?? const TextStyle()).copyWith(
                              color: isUser ? context.onPrimaryContainer : context.onSurface,
                              fontSize: ((baseStyle ?? context.bodyLarge)?.fontSize ?? 14),
                              height: 1.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } catch (e) {
                return const SizedBox.shrink();
              }
            }
            if (element.localName == 'tagged_event') {
              try {
                final jsonText = element.text.trim();
                if (jsonText.isEmpty) {
                  return const SizedBox.shrink();
                }
                Map<String, dynamic> jsonData;
                try {
                  jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
                } catch (e) {
                  final jsonMatch = RegExp(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}').firstMatch(jsonText);
                  if (jsonMatch != null) {
                    jsonData = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
                  } else {
                    rethrow;
                  }
                }

                final eventTitle = jsonData['title'] as String? ?? 'Untitled';
                return InlineCustomWidget(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(4)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        VisirIcon(type: VisirIconType.calendar, size: 12, color: isUser ? context.onPrimaryContainer : context.onSurface, isSelected: true),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            eventTitle,
                            style: (baseStyle ?? context.bodyLarge ?? const TextStyle()).copyWith(
                              color: isUser ? context.onPrimaryContainer : context.onSurface,
                              fontSize: ((baseStyle ?? context.bodyLarge)?.fontSize ?? 14),
                              height: 1.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } catch (e) {
                return const SizedBox.shrink();
              }
            }
            if (element.localName == 'tagged_connection') {
              try {
                final jsonText = element.text.trim();
                if (jsonText.isEmpty) {
                  return const SizedBox.shrink();
                }
                Map<String, dynamic> jsonData;
                try {
                  jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
                } catch (e) {
                  final jsonMatch = RegExp(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}').firstMatch(jsonText);
                  if (jsonMatch != null) {
                    jsonData = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
                  } else {
                    rethrow;
                  }
                }

                final name = jsonData['name'] as String? ?? '';
                final email = jsonData['email'] as String? ?? '';
                final displayName = name.isNotEmpty && name != 'No name' ? name : (email.isNotEmpty ? email : 'Unknown');

                return InlineCustomWidget(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(4)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        VisirIcon(type: VisirIconType.attendee, size: 12, color: isUser ? context.onPrimaryContainer : context.onSurface, isSelected: true),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            displayName,
                            style: (baseStyle ?? context.bodyLarge ?? const TextStyle()).copyWith(
                              color: isUser ? context.onPrimaryContainer : context.onSurface,
                              fontSize: ((baseStyle ?? context.bodyLarge)?.fontSize ?? 14),
                              height: 1.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } catch (e) {
                return const SizedBox.shrink();
              }
            }
            if (element.localName == 'tagged_project') {
              try {
                final jsonText = element.text.trim();
                if (jsonText.isEmpty) {
                  return const SizedBox.shrink();
                }
                Map<String, dynamic> jsonData;
                try {
                  jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
                } catch (e) {
                  final jsonMatch = RegExp(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}').firstMatch(jsonText);
                  if (jsonMatch != null) {
                    jsonData = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
                  } else {
                    rethrow;
                  }
                }

                final name = jsonData['name'] as String? ?? '';
                if (name.isEmpty) {
                  return const SizedBox.shrink();
                }

                return InlineCustomWidget(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(4)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        VisirIcon(type: VisirIconType.project, size: 12, color: isUser ? context.onPrimaryContainer : context.onSurface, isSelected: true),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            name,
                            style: (baseStyle ?? context.bodyLarge ?? const TextStyle()).copyWith(
                              color: isUser ? context.onPrimaryContainer : context.onSurface,
                              fontSize: ((baseStyle ?? context.bodyLarge)?.fontSize ?? 14),
                              height: 1.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } catch (e) {
                return const SizedBox.shrink();
              }
            }
            if (element.localName == 'tagged_channel') {
              try {
                final jsonText = element.text.trim();
                if (jsonText.isEmpty) {
                  return const SizedBox.shrink();
                }
                Map<String, dynamic> jsonData;
                try {
                  jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
                } catch (e) {
                  final jsonMatch = RegExp(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}').firstMatch(jsonText);
                  if (jsonMatch != null) {
                    jsonData = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
                  } else {
                    rethrow;
                  }
                }

                final name = jsonData['name'] as String? ?? '';
                if (name.isEmpty) {
                  return const SizedBox.shrink();
                }

                return InlineCustomWidget(
                  alignment: PlaceholderAlignment.middle,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(4)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        VisirIcon(type: VisirIconType.chatChannel, size: 12, color: isUser ? context.onPrimaryContainer : context.onSurface, isSelected: true),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            name,
                            style: (baseStyle ?? context.bodyLarge ?? const TextStyle()).copyWith(
                              color: isUser ? context.onPrimaryContainer : context.onSurface,
                              fontSize: ((baseStyle ?? context.bodyLarge)?.fontSize ?? 14),
                              height: 1.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } catch (e) {
                return const SizedBox.shrink();
              }
            }
            return null;
          },
          customStylesBuilder: (element) {
            // Hide text content of tagged_project, tagged_channel, tagged_connection tags
            // customWidgetBuilder will render widgets for these, so we don't want the raw text to show
            if (element.localName == 'tagged_project' || element.localName == 'tagged_channel' || element.localName == 'tagged_connection') {
              return {'font-size': '0', 'line-height': '0', 'color': 'transparent', 'display': 'inline-block'};
            }
            // Hide conversation_title tags completely
            if (element.localName == 'conversation_title') {
              return {'display': 'none'};
            }
            if (element.localName == 'div' && element.classes.contains('inbox-section')) {
              return {
                'background-color': (isUser ? context.primaryContainer.withValues(alpha: 0.3) : context.surface).toHex(),
                'border': '1px solid ${(isUser ? context.primaryContainer : context.outline.withValues(alpha: 0.3)).toHex()}',
                'border-radius': '8px',
                'padding': '12px',
                'margin-bottom': '12px',
              };
            }
            if (element.localName == 'div' && element.classes.contains('section-title')) {
              return {'font-weight': 'bold', 'color': (isUser ? context.onPrimaryContainer : context.primary).toHex(), 'margin-bottom': '12px'};
            }
            if (element.localName == 'div' && element.classes.contains('title-content')) {
              return {
                'font-weight': 'bold',
                'font-size': '1.1em',
                'color': (isUser ? context.onPrimaryContainer : context.onSurface).toHex(),
                'margin-bottom': '8px',
                'line-height': '1.4',
              };
            }
            if (element.localName == 'div' && element.classes.contains('description-content')) {
              return {'color': (isUser ? context.onPrimaryContainer : context.onSurfaceVariant).toHex(), 'line-height': '1.5', 'white-space': 'pre-wrap'};
            }
            if (element.localName == 'div' && element.classes.contains('field')) {
              return {'margin-bottom': '6px'};
            }
            if (element.localName == 'span' && element.classes.contains('label')) {
              return {'font-weight': 'bold', 'color': (isUser ? context.onPrimaryContainer : context.primary).toHex()};
            }
            if (element.localName == 'span' && element.classes.contains('value')) {
              return {'color': (isUser ? context.onPrimaryContainer : context.onSurfaceVariant).toHex()};
            }
            return null;
          },
        ),
      );
    }
    // All content is now HTML (wrapped in <div> if needed), so we always render as HTML
    // HTML content with markdown inside will be processed above
  }

  Widget _buildActionButtonText(BuildContext context, ({AgentActionType? actionType, InboxEntity? inbox, String? conversationSummary}) agentAction) {
    if (agentAction.actionType == null) return const SizedBox.shrink();

    // 대화 시작 메시지의 summary 사용 (없으면 actionType의 title 사용)
    final displayText = agentAction.conversationSummary ?? agentAction.actionType!.getTitle(context);

    String? itemName;

    switch (agentAction.actionType!) {
      case AgentActionType.createTask:
        if (agentAction.inbox != null) {
          final suggestion = agentAction.inbox!.suggestion;
          final summary = suggestion?.summary ?? '';
          itemName = summary.isNotEmpty ? summary : null;
        }
        break;
      case AgentActionType.createEvent:
        if (agentAction.inbox != null) {
          final suggestion = agentAction.inbox!.suggestion;
          final summary = suggestion?.summary ?? '';
          itemName = summary.isNotEmpty ? summary : null;
        }
        break;
      case AgentActionType.reply:
        if (agentAction.inbox != null) {
          final suggestion = agentAction.inbox!.suggestion;
          final summary = suggestion?.summary ?? agentAction.inbox!.title;
          final senderName = suggestion?.sender_name;
          if (summary.isNotEmpty) {
            if (senderName != null && senderName.isNotEmpty) {
              itemName = '$summary ($senderName)';
            } else {
              itemName = summary;
            }
          }
        }
        break;
      default:
        break;
    }

    final baseStyle = context.titleMedium?.copyWith(color: context.onSurface);
    final boldStyle = baseStyle?.textBold;

    if (itemName != null && itemName.isNotEmpty) {
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: displayText, style: boldStyle),
            TextSpan(text: ' · ', style: baseStyle),
            TextSpan(text: itemName, style: baseStyle),
          ],
        ),
        overflow: TextOverflow.ellipsis,
      );
    }
    return Text(displayText, style: boldStyle, overflow: TextOverflow.ellipsis);
  }

  @override
  Widget build(BuildContext context) {
    // 모델 변경에 반응하지 않도록 selectedModel과 useUserApiKey를 제외한 상태만 감시
    final agentAction = ref.watch(
      agentActionControllerProvider.select(
        (state) => (
          messages: state.messages,
          isLoading: state.isLoading,
          actionType: state.actionType,
          inbox: state.inbox,
          pendingTaskInfo: state.pendingTaskInfo,
          conversationSummary: state.conversationSummary,
        ),
      ),
    );
    final controller = ref.read(agentActionControllerProvider.notifier);

    final isEmpty = agentAction.messages.isEmpty && !agentAction.isLoading;

    // Scroll to bottom when new message is added
    ref.listen(agentActionControllerProvider.select((state) => state.messages.length), (previous, next) {
      if (previous != null && next > previous) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
          }
        });
      }
    });

    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(PlatformX.isMobileView ? 20 : DesktopScaffold.cardRadius),
      topRight: Radius.circular(PlatformX.isMobileView ? 20 : DesktopScaffold.cardRadius),
    );
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: SizeTransitionWithoutClip(axis: Axis.vertical, axisAlignment: 1.0, sizeFactor: animation, child: child),
        );
      },
      child: isEmpty
          ? const SizedBox.shrink(key: ValueKey('empty'))
          : AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              clipBehavior: Clip.none,
              child: Container(
                height: widget.maxHeight,
                decoration: BoxDecoration(
                  color: context.background,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 6, offset: Offset(0, 4), spreadRadius: 0)],
                  border: PlatformX.isMobileView ? null : Border.all(color: context.outline.withValues(alpha: 0.3), width: 1),
                  borderRadius: borderRadius,
                ),
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: SelectionArea(
                    child: Container(
                      color: context.surface.withValues(alpha: 0.25),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Action title and close button at the top
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0, right: 8.0, top: 8.0, bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (agentAction.actionType != null)
                                  Expanded(
                                    child: _buildActionButtonText(context, (
                                      actionType: agentAction.actionType,
                                      inbox: agentAction.inbox,
                                      conversationSummary: agentAction.conversationSummary,
                                    )),
                                  )
                                else if (agentAction.conversationSummary != null && agentAction.conversationSummary!.isNotEmpty)
                                  Expanded(
                                    child: Text(
                                      agentAction.conversationSummary!,
                                      style: context.titleMedium?.copyWith(color: context.onSurface, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                else
                                  const Spacer(),
                                const SizedBox(width: 8),
                                VisirButton(
                                  type: VisirButtonAnimationType.scaleAndOpacity,
                                  style: VisirButtonStyle(padding: EdgeInsets.all(4), borderRadius: BorderRadius.circular(6)),
                                  onTap: () => controller.cancelAction(),
                                  child: VisirIcon(type: VisirIconType.close, size: 18, color: context.onSurfaceVariant, isSelected: true),
                                  options: VisirButtonOptions(
                                    tabType: TabType.home,
                                    bypassTextField: true,
                                    shortcuts: [
                                      VisirButtonKeyboardShortcut(message: context.tr.cancel, keys: [LogicalKeyboardKey.escape]),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              controller: _scrollController,
                              itemCount: agentAction.messages.length + (agentAction.isLoading ? 1 : 0),
                              itemBuilder: (context, index) {
                                final state = ref.watch(agentActionControllerProvider);
                                final pendingCalls = state.pendingFunctionCalls ?? [];
                                final isLoading = state.isLoading;
                                final writeActions = pendingCalls.where((call) {
                                  final functionName = call['function_name'] as String? ?? '';
                                  return _isWriteAction(functionName);
                                }).toList();

                                final messagesLength = agentAction.messages.length;

                                // Regular message items
                                if (index == messagesLength) {
                                  return Container(
                                    margin: const EdgeInsets.only(top: 6, bottom: 6, left: 0, right: 0),
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        VisirIcon(type: VisirIconType.agent, size: 16, color: context.primary, isSelected: true),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: AnimatedTextKit(
                                            animatedTexts: _getLoadingMessages(context, agentAction.actionType, agentAction.pendingTaskInfo)
                                                .map(
                                                  (text) => TypewriterAnimatedText(
                                                    text,
                                                    textStyle: context.bodyLarge?.textColor(context.onSurfaceVariant),
                                                    speed: const Duration(milliseconds: 100),
                                                  ),
                                                )
                                                .toList(),
                                            repeatForever: true,
                                            pause: const Duration(milliseconds: 500),
                                            displayFullTextOnTap: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                final message = agentAction.messages[index];
                                final isUser = message.role == 'user';

                                final isLastMessage = index == agentAction.messages.length - 1;

                                final writeActionsForMessage = <Map<String, dynamic>>[];
                                final seenActionIds = <String>{};
                                final seenFunctionSignatures = <String>{};
                                for (final call in pendingCalls) {
                                  final functionName = call['function_name'] as String? ?? '';
                                  final actionId = call['action_id'] as String? ?? '';
                                  final functionArgs = call['function_args'] as Map<String, dynamic>? ?? {};
                                  final messageIndex = call['message_index'] as int?;

                                  // 이 메시지에 속한 write action만 표시
                                  if (_isWriteAction(functionName) && actionId.isNotEmpty && messageIndex == index) {
                                    String signature = functionName;
                                    if (functionName == 'createTask' || functionName == 'updateTask' || functionName == 'createEvent' || functionName == 'updateEvent') {
                                      final title = functionArgs['title'] as String? ?? '';
                                      final startAt = functionArgs['startAt'] as String? ?? functionArgs['start_at'] as String? ?? '';
                                      final endAt = functionArgs['endAt'] as String? ?? functionArgs['end_at'] as String? ?? '';
                                      signature = '$functionName|$title|$startAt|$endAt';
                                    }

                                    if (!seenActionIds.contains(actionId) && !seenFunctionSignatures.contains(signature)) {
                                      seenActionIds.add(actionId);
                                      seenFunctionSignatures.add(signature);
                                      writeActionsForMessage.add(call);
                                    }
                                  }
                                }

                                return Container(
                                  margin: EdgeInsets.only(top: 6, bottom: isLastMessage && writeActionsForMessage.isNotEmpty ? 0 : 6, left: 0, right: 0),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(8)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Message content (project tags are now rendered inline via customWidgetBuilder)
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (!isUser) ...[VisirIcon(type: VisirIconType.agent, size: 16, color: context.primary, isSelected: true), const SizedBox(width: 8)],
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                _buildMessageContent(context, message.content, isUser),
                                                // 파일 첨부 표시
                                                if (message.files != null && message.files!.isNotEmpty) ...[
                                                  const SizedBox(height: 12),
                                                  Wrap(
                                                    alignment: WrapAlignment.start,
                                                    crossAxisAlignment: WrapCrossAlignment.start,
                                                    spacing: 8,
                                                    runSpacing: 8,
                                                    children: message.files!.map((file) {
                                                      final isImage = file.isImage;
                                                      final isVideo = file.isVideo;
                                                      return isImage
                                                          ? ClipRRect(
                                                              borderRadius: BorderRadius.circular(8),
                                                              child: Container(
                                                                width: 200,
                                                                height: 200,
                                                                decoration: BoxDecoration(
                                                                  color: context.surfaceVariant,
                                                                  borderRadius: BorderRadius.circular(8),
                                                                ),
                                                                child: file.bytes != null
                                                                    ? Image.memory(
                                                                        file.bytes!,
                                                                        fit: BoxFit.cover,
                                                                      )
                                                                    : Center(
                                                                        child: VisirIcon(type: VisirIconType.caution, size: 24, color: context.surfaceTint),
                                                                      ),
                                                              ),
                                                            )
                                                          : Container(
                                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                              decoration: BoxDecoration(
                                                                color: context.surfaceVariant,
                                                                borderRadius: BorderRadius.circular(8),
                                                              ),
                                                              child: Row(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  VisirIcon(
                                                                    type: isVideo ? VisirIconType.videoCall : VisirIconType.file,
                                                                    size: 16,
                                                                    color: context.outlineVariant,
                                                                  ),
                                                                  const SizedBox(width: 8),
                                                                  Text(
                                                                    file.name,
                                                                    style: context.titleSmall?.textColor(context.outlineVariant),
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                    }).toList(),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (writeActionsForMessage.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        ...writeActionsForMessage.asMap().entries.map((entry) {
                                          final index = entry.key;
                                          final call = entry.value;
                                          final isLast = index == writeActionsForMessage.length - 1;
                                          final functionName = call['function_name'] as String? ?? '';
                                          final functionArgs = call['function_args'] as Map<String, dynamic>? ?? {};
                                          final actionId = call['action_id'] as String? ?? '';
                                          // updateTask인 경우 updated_tagged_tasks에서 task 정보 가져오기
                                          final updatedTaggedTasks = call['updated_tagged_tasks'] as List<dynamic>?;

                                          if (functionName == 'createTask' || functionName == 'updateTask') {
                                            return Padding(
                                              padding: EdgeInsets.only(bottom: isLast ? 0 : 6),
                                              child: _buildTaskEntityWithConfirm(context, functionArgs, actionId, isUser, functionName: functionName, updatedTaggedTasks: updatedTaggedTasks),
                                            );
                                          } else if (functionName == 'createEvent' || functionName == 'updateEvent') {
                                            return Padding(
                                              padding: EdgeInsets.only(bottom: isLast ? 0 : 6),
                                              child: _buildEventEntityWithConfirm(context, functionArgs, actionId, isUser),
                                            );
                                          } else {
                                            return Padding(
                                              padding: EdgeInsets.only(bottom: isLast ? 0 : 6),
                                              child: _buildActionConfirmWidget(context, functionName, functionArgs, actionId, isUser),
                                            );
                                          }
                                        }),
                                        // Confirm 버튼을 첫 번째 메시지(또는 task block이 있는 메시지)에만 표시
                                        // 로딩 중이 아니고 writeActions가 있고, 이 메시지가 마지막 메시지일 때만 표시
                                        if (writeActions.isNotEmpty && !isLoading && isLastMessage) ...[
                                          Container(
                                            margin: const EdgeInsets.only(top: 12, bottom: 12),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                IntrinsicWidth(
                                                  child: VisirButton(
                                                    type: VisirButtonAnimationType.scaleAndOpacity,
                                                    style: VisirButtonStyle(
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                      backgroundColor: context.primary,
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    options: VisirButtonOptions(
                                                      bypassTextField: true,
                                                      shortcuts: [
                                                        VisirButtonKeyboardShortcut(
                                                          keys: [
                                                            if (PlatformX.isApple) LogicalKeyboardKey.meta,
                                                            if (!PlatformX.isApple) LogicalKeyboardKey.control,
                                                            LogicalKeyboardKey.enter,
                                                          ],
                                                          message: context.tr.confirm,
                                                        ),
                                                      ],
                                                    ),
                                                    onTap: () async {
                                                      final controller = ref.read(agentActionControllerProvider.notifier);
                                                      // 모든 write action을 한번에 처리
                                                      final actionIds = writeActions.map((call) => call['action_id'] as String? ?? '').where((id) => id.isNotEmpty).toList();
                                                      if (actionIds.isNotEmpty) {
                                                        await controller.confirmActions(actionIds: actionIds);
                                                      }
                                                    },
                                                    child: Text(context.tr.confirm, style: context.bodyMedium?.copyWith(color: context.onPrimary)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  // Mail Entity Widget
  Widget _buildMailEntityWidget(BuildContext context, MailEntity mail, bool isUser) {
    final fromName = mail.from?.name ?? mail.from?.email ?? '';
    final subject = mail.subject ?? '';
    final snippet = mail.snippet ?? '';
    final dateStr = mail.getDateString(context) ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser ? context.primaryContainer.withValues(alpha: 0.3) : context.surface,
        border: Border.all(color: isUser ? context.primaryContainer : context.outline.withValues(alpha: 0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              VisirIcon(type: VisirIconType.mail, size: 16, color: isUser ? context.onPrimaryContainer : context.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '메일',
                  style: context.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: isUser ? context.onPrimaryContainer : context.primary),
                ),
              ),
              if (dateStr.isNotEmpty) Text(dateStr, style: context.bodySmall?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 8),
          if (fromName.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '보낸 사람: $fromName',
                style: context.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: isUser ? context.onPrimaryContainer : context.onSurface),
              ),
            ),
          if (subject.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                subject,
                style: context.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: isUser ? context.onPrimaryContainer : context.onSurface),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (snippet.isNotEmpty)
            Text(
              snippet,
              style: context.bodyMedium?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  // Message Widget
  Widget _buildMessageWidget(BuildContext context, MessageEntity message, bool isUser) {
    final channels = ref.read(chatChannelListControllerProvider).values.expand((e) => e.channels).toList();
    final members = ref.read(chatMemberListControllerProvider(tabType: TabType.home)).members;

    final channelId = message.channelId;
    final channel = channelId != null ? channels.firstWhereOrNull((c) => c.id == channelId) : null;
    final channelName = channel?.displayName ?? channel?.name ?? '알 수 없는 채널';

    // Get user name from message
    String userName = '알 수 없는 사용자';
    final userId = message.userId;
    if (userId != null) {
      final member = members.firstWhereOrNull((m) => m.id == userId);
      userName = member?.displayName ?? userId;
    }

    // Get text from message
    String text = '';
    switch (message.type) {
      case MessageEntityType.slack:
        text = message.slackMessage?.text ?? '';
        break;
    }

    final createdAt = message.createdAt;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser ? context.primaryContainer.withValues(alpha: 0.3) : context.surface,
        border: Border.all(color: isUser ? context.primaryContainer : context.outline.withValues(alpha: 0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              VisirIcon(type: channel?.icon ?? VisirIconType.chatChannel, size: 16, color: isUser ? context.onPrimaryContainer : context.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  channelName,
                  style: context.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: isUser ? context.onPrimaryContainer : context.primary),
                ),
              ),
              if (createdAt != null) Text(createdAt.forceDateTimeString, style: context.bodySmall?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$userName: $text',
            style: context.bodyMedium?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurface, height: 1.4),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Calendar Widget
  Widget _buildCalendarWidget(BuildContext context, CalendarEntity calendar, bool isUser) {
    final bgColor = ColorX.fromHex(calendar.backgroundColor);
    final fgColor = ColorX.fromHex(calendar.foregroundColor);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: isUser ? 0.3 : 0.15),
        border: Border.all(color: bgColor.withValues(alpha: isUser ? 0.5 : 0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          VisirIcon(type: VisirIconType.calendar, size: 16, color: isUser ? context.onPrimaryContainer : fgColor, isSelected: true),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              calendar.name,
              style: context.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: isUser ? context.onPrimaryContainer : fgColor),
            ),
          ),
          if (calendar.email != null && calendar.email!.isNotEmpty)
            Text(calendar.email!, style: context.bodySmall?.copyWith(color: isUser ? context.onPrimaryContainer : fgColor.withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  // Event Entity Widget
  Widget _buildEventEntityWidget(BuildContext context, EventEntity event, bool isUser) {
    final calendar = event.calendar;
    final title = event.title ?? '';
    final description = event.description ?? '';
    final location = event.location ?? '';
    final startDate = event.startDate;
    final endDate = event.endDate;
    final isAllDay = event.isAllDay;
    final attendees = event.attendees;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUser ? context.primaryContainer.withValues(alpha: 0.3) : context.surface,
        border: Border.all(color: isUser ? context.primaryContainer : context.outline.withValues(alpha: 0.3), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(color: ColorX.fromHex(calendar.backgroundColor), borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  calendar.name,
                  style: context.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: isUser ? context.onPrimaryContainer : context.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (title.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                title,
                style: context.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: isUser ? context.onPrimaryContainer : context.onSurface),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                VisirIcon(type: VisirIconType.clock, size: 14, color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                  isAllDay
                      ? '${startDate.forceDateString}${endDate != startDate ? ' - ${endDate.forceDateString}' : ''} • ${context.tr.all_day}'
                      : '${startDate.forceDateTimeString} - ${endDate.forceDateTimeString}',
                  style: context.bodyMedium?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (location.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  VisirIcon(type: VisirIconType.location, size: 14, color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      location,
                      style: context.bodyMedium?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          if (attendees.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  VisirIcon(type: VisirIconType.attendee, size: 14, color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      attendees.map((a) => a.email ?? a.displayName ?? '').where((e) => e.isNotEmpty).join(', '),
                      style: context.bodyMedium?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          if (description.isNotEmpty)
            Text(
              description,
              style: context.bodyMedium?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}

class _ActionConfirmWidget extends ConsumerStatefulWidget {
  final String functionName;
  final Map<String, dynamic> functionArgs;
  final String actionId;
  final String confirmationMessage;
  final bool isUser;

  const _ActionConfirmWidget({required this.functionName, required this.functionArgs, required this.actionId, required this.confirmationMessage, required this.isUser});

  @override
  ConsumerState<_ActionConfirmWidget> createState() => _ActionConfirmWidgetState();
}

class _ActionConfirmWidgetState extends ConsumerState<_ActionConfirmWidget> {
  late final FocusNode _focusNode;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final controller = ref.read(agentActionControllerProvider.notifier);
      await controller.confirmAction(actionId: widget.actionId);
    } catch (e) {
      // 에러 발생 시 처리 (필요시 에러 메시지 표시)
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(agentActionControllerProvider);
    final pendingCalls = state.pendingFunctionCalls ?? [];
    final isPending = pendingCalls.any((call) => call['action_id'] == widget.actionId);

    if (!isPending) {
      return const SizedBox.shrink();
    }

    final messages = state.messages;
    if (messages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Focus(
      focusNode: _focusNode,
      autofocus: false,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && !_isProcessing) {
          final logicalKeysPressed = ServicesBinding.instance.keyboard.logicalKeysPressed.where((e) => e != LogicalKeyboardKey.escape).toList();

          // isApple이면 Command + Enter, 나머지는 Ctrl + Enter
          final isCommandEnter = PlatformX.isApple && logicalKeysPressed.isMetaPressed && logicalKeysPressed.contains(LogicalKeyboardKey.enter);
          final isCtrlEnter = !PlatformX.isApple && logicalKeysPressed.isControlPressed && logicalKeysPressed.contains(LogicalKeyboardKey.enter);

          if (isCommandEnter || isCtrlEnter) {
            _handleConfirm();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: context.surface,
          border: Border.all(color: context.outline.withValues(alpha: 0.3), width: 1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.confirmationMessage, style: context.bodyMedium?.copyWith(color: widget.isUser ? context.onPrimaryContainer : context.onSurfaceVariant, height: 1.5)),
            if (widget.functionName == 'sendMail' || widget.functionName == 'replyMail' || widget.functionName == 'forwardMail') ...[
              _buildMailActionDetailsForConfirm(context, widget.functionName, widget.functionArgs, widget.isUser),
            ] else if (widget.functionName == 'createTask' || widget.functionName == 'updateTask') ...[
              _buildTaskActionDetailsForConfirm(context, widget.functionArgs, widget.isUser),
            ] else if (widget.functionName == 'createEvent' || widget.functionName == 'updateEvent') ...[
              _buildEventActionDetailsForConfirm(context, widget.functionArgs, widget.isUser),
            ],
            const SizedBox(height: 6),
            if (!_isProcessing)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IntrinsicWidth(
                    child: VisirButton(
                      type: VisirButtonAnimationType.scaleAndOpacity,
                      style: VisirButtonStyle(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        backgroundColor: context.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      options: VisirButtonOptions(
                        bypassTextField: true,
                        shortcuts: [
                          VisirButtonKeyboardShortcut(
                            keys: [if (PlatformX.isApple) LogicalKeyboardKey.meta, if (!PlatformX.isApple) LogicalKeyboardKey.control, LogicalKeyboardKey.enter],
                            message: context.tr.confirm,
                          ),
                        ],
                      ),
                      onTap: _handleConfirm,
                      child: Text(context.tr.confirm, style: context.bodyMedium?.copyWith(color: context.onPrimary)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMailActionDetailsForConfirm(BuildContext context, String functionName, Map<String, dynamic> args, bool isUser) {
    final toList = (args['to'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final ccList = (args['cc'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final bccList = (args['bcc'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final subject = args['subject'] as String? ?? '';
    final reply = args['reply'] as String? ?? args['message'] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (subject.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              Utils.mainContext.tr.agent_action_confirm_title(subject),
              style: context.bodyMedium?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant),
            ),
          ),
        ],
        if (toList.isNotEmpty || ccList.isNotEmpty || bccList.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (toList.isNotEmpty) _buildRecipientRowForConfirm(context, Utils.mainContext.tr.agent_action_confirm_recipient_to, toList, isUser),
                if (ccList.isNotEmpty) _buildRecipientRowForConfirm(context, Utils.mainContext.tr.agent_action_confirm_recipient_cc, ccList, isUser),
                if (bccList.isNotEmpty) _buildRecipientRowForConfirm(context, Utils.mainContext.tr.agent_action_confirm_recipient_bcc, bccList, isUser),
              ],
            ),
          ),
        ],
        if (reply.isNotEmpty) ...[
          Container(height: 1, color: context.outline),
          const SizedBox(height: 8),
          Text(
            reply.replaceAll('\\n', '\n'),
            style: context.bodySmall?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant, height: 1.4),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildTaskActionDetailsForConfirm(BuildContext context, Map<String, dynamic> args, bool isUser) {
    final title = args['title'] as String? ?? '';
    final description = args['description'] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              Utils.mainContext.tr.agent_action_confirm_title(title),
              style: context.bodyMedium?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        if (description.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(description, style: context.bodyMedium?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant)),
          ),
        ],
      ],
    );
  }

  Widget _buildEventActionDetailsForConfirm(BuildContext context, Map<String, dynamic> args, bool isUser) {
    final title = args['title'] as String? ?? '';
    final description = args['description'] as String? ?? '';
    final startAtStr = args['startAt'] as String? ?? args['start_at'] as String?;
    final endAtStr = args['endAt'] as String? ?? args['end_at'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              Utils.mainContext.tr.agent_action_confirm_title(title),
              style: context.bodyMedium?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        if (description.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(description, style: context.bodyMedium?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant)),
          ),
        ],
        if (startAtStr != null || endAtStr != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              Utils.mainContext.tr.agent_action_confirm_time(startAtStr ?? '', endAtStr != null ? ' - $endAtStr' : ''),
              style: context.bodyMedium?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRecipientRowForConfirm(BuildContext context, String label, List<Map<String, dynamic>> recipients, bool isUser) {
    final recipientTexts = recipients
        .map((r) {
          final name = r['name'] as String? ?? '';
          final email = r['email'] as String? ?? '';
          if (name.isNotEmpty && name != email) {
            return '$name <$email>';
          }
          return email;
        })
        .join(', ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            label,
            style: context.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: Text(recipientTexts, style: context.bodySmall?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant)),
        ),
      ],
    );
  }
}

class SizeTransitionWithoutClip extends AnimatedWidget {
  /// Creates a size transition.
  ///
  /// The [axis] argument defaults to [Axis.vertical]. The [axisAlignment]
  /// defaults to zero, which centers the child along the main axis during the
  /// transition.
  const SizeTransitionWithoutClip({
    super.key,
    this.axis = Axis.vertical,
    required Animation<double> sizeFactor,
    this.axisAlignment = 0.0,
    this.fixedCrossAxisSizeFactor,
    this.child,
  }) : assert(fixedCrossAxisSizeFactor == null || fixedCrossAxisSizeFactor >= 0.0),
       super(listenable: sizeFactor);

  /// [Axis.horizontal] if [sizeFactor] modifies the width, otherwise
  /// [Axis.vertical].
  final Axis axis;

  /// The animation that controls the (clipped) size of the child.
  ///
  /// The width or height (depending on the [axis] value) of this widget will be
  /// its intrinsic width or height multiplied by [sizeFactor]'s value at the
  /// current point in the animation.
  ///
  /// If the value of [sizeFactor] is less than one, the child will be clipped
  /// in the appropriate axis.
  Animation<double> get sizeFactor => listenable as Animation<double>;

  /// Describes how to align the child along the axis that [sizeFactor] is
  /// modifying.
  ///
  /// A value of -1.0 indicates the top when [axis] is [Axis.vertical], and the
  /// start when [axis] is [Axis.horizontal]. The start is on the left when the
  /// text direction in effect is [TextDirection.ltr] and on the right when it
  /// is [TextDirection.rtl].
  ///
  /// A value of 1.0 indicates the bottom or end, depending upon the [axis].
  ///
  /// A value of 0.0 (the default) indicates the center for either [axis] value.
  final double axisAlignment;

  /// The factor by which to multiply the cross axis size of the child.
  ///
  /// If the value of [fixedCrossAxisSizeFactor] is less than one, the child
  /// will be clipped along the appropriate axis.
  ///
  /// If `null` (the default), the cross axis size is as large as the parent.
  final double? fixedCrossAxisSizeFactor;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    if (axis == Axis.vertical) {
      // Vertical axis: clip only from bottom
      return ClipRect(
        clipper: _BottomOnlyClipper(sizeFactor: sizeFactor.value),
        child: Align(alignment: AlignmentDirectional(-1.0, axisAlignment), heightFactor: math.max(sizeFactor.value, 0.0), widthFactor: fixedCrossAxisSizeFactor, child: child),
      );
    } else {
      // Horizontal axis: use default ClipRect behavior
      return ClipRect(
        child: Align(alignment: AlignmentDirectional(axisAlignment, -1.0), heightFactor: fixedCrossAxisSizeFactor, widthFactor: math.max(sizeFactor.value, 0.0), child: child),
      );
    }
  }
}

class _BottomOnlyClipper extends CustomClipper<Rect> {
  final double sizeFactor;

  _BottomOnlyClipper({required this.sizeFactor});

  @override
  Rect getClip(Size size) {
    // Clip from bottom, show content from bottom up
    final visibleHeight = size.height * math.max(sizeFactor, 0.0);
    final topOffset = size.height - visibleHeight;
    return Rect.fromLTWH(-20, topOffset, size.width + 40, visibleHeight + 20);
  }

  @override
  bool shouldReclip(_BottomOnlyClipper oldClipper) {
    return oldClipper.sizeFactor != sizeFactor;
  }
}
