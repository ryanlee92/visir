import 'dart:convert';
import 'dart:math' as math;

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/date_time_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/widgets/desktop_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/dependency/rrule/src/recurrence_rule.dart';
import 'package:Visir/features/calendar/application/calendar_list_controller.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/inbox/application/agent_action_controller.dart';
import 'package:collection/collection.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/presentation/widgets/inbox_action_suggestions_widget.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_user_entity.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart' show InlineCustomWidget;
import 'package:html_unescape/html_unescape.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AgentActionMessagesWidget extends ConsumerStatefulWidget {
  final double maxHeight;
  AgentActionMessagesWidget({super.key, this.maxHeight = 500});

  @override
  ConsumerState<AgentActionMessagesWidget> createState() => _AgentActionMessagesWidgetState();
}

class _AgentActionMessagesWidgetState extends ConsumerState<AgentActionMessagesWidget> {
  final ScrollController _scrollController = ScrollController();
  final HtmlUnescape _htmlUnescape = HtmlUnescape();

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

  Widget _buildTaskWidget(BuildContext context, TaskEntity task, bool isUser, {bool isSuggested = false}) {
    final projects = ref.read(projectListControllerProvider);
    final defaultProject = projects.firstWhere((p) => p.isDefault);
    final project = task.projectId != null ? projects.where((p) => p.uniqueId == task.projectId).firstOrNull : defaultProject;

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
      'calendar_id': jsonData['calendar_id'],
      'start_at': jsonData['start_at'],
      'end_at': jsonData['end_at'],
      'location': jsonData['location'],
      'rrule': jsonData['rrule'],
      'attendees': jsonData['attendees'] as List<dynamic>? ?? [],
      'conference_link': jsonData['conference_link'],
      'isAllDay': jsonData['isAllDay'] ?? false,
    };
  }

  Widget _buildEventWidget(BuildContext context, Map<String, dynamic> eventData, bool isUser, {bool isSuggested = false}) {
    final calendarMap = ref.read(calendarListControllerProvider);
    final calendarList = calendarMap.values.expand((e) => e).toList();
    final calendarId = eventData['calendar_id'] as String?;
    final calendar = calendarId != null ? calendarList.firstWhereOrNull((c) => c.uniqueId == calendarId) : null;

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
        final to = (args['to'] as List<dynamic>?)?.map((e) => e.toString()).join(', ') ?? '';
        final subject = args['subject'] as String? ?? '';
        return '다음 이메일을 전송하시겠습니까?\n\n받는 사람: $to\n제목: $subject';
      case 'replyMail':
        final subject = args['subject'] as String? ?? '';
        return '이메일에 답장을 보내시겠습니까?\n\n제목: $subject';
      case 'forwardMail':
        final to = (args['to'] as List<dynamic>?)?.map((e) => e.toString()).join(', ') ?? '';
        return '이메일을 다음 주소로 전달하시겠습니까?\n\n받는 사람: $to';
      case 'deleteTask':
        return '작업을 삭제하시겠습니까?';
      case 'deleteEvent':
        return '일정을 삭제하시겠습니까?';
      case 'deleteMail':
        return '이메일을 삭제하시겠습니까?';
      case 'updateTask':
        final title = args['title'] as String? ?? '';
        return '작업을 수정하시겠습니까?\n\n제목: $title';
      case 'updateEvent':
        final title = args['title'] as String? ?? '';
        return '일정을 수정하시겠습니까?\n\n제목: $title';
      case 'markMailAsRead':
        return '이메일을 읽음으로 표시하시겠습니까?';
      case 'markMailAsUnread':
        return '이메일을 읽지 않음으로 표시하시겠습니까?';
      case 'archiveMail':
        return '이메일을 보관하시겠습니까?';
      case 'responseCalendarInvitation':
        final response = args['response'] as String? ?? '';
        return '캘린더 초대에 "$response"로 응답하시겠습니까?';
      case 'createTask':
        final title = args['title'] as String? ?? '';
        return '다음 작업을 생성하시겠습니까?\n\n제목: $title';
      case 'createEvent':
        final title = args['title'] as String? ?? '';
        return '다음 일정을 생성하시겠습니까?\n\n제목: $title';
      default:
        return '이 작업을 실행하시겠습니까?';
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
  List<Map<String, dynamic>> _extractTaggedProjects(String content) {
    final List<Map<String, dynamic>> projects = [];
    // Use non-greedy matching with dotAll to match across newlines
    final RegExp taggedProjectRegex = RegExp(r'<tagged_project>([\s\S]*?)</tagged_project>', multiLine: true);

    for (final match in taggedProjectRegex.allMatches(content)) {
      try {
        final jsonText = match.group(1)?.trim() ?? '';
        if (jsonText.isNotEmpty) {
          final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
          // Ensure we have at least a name or id
          if ((jsonData['name'] as String? ?? '').isNotEmpty || (jsonData['id'] as String? ?? '').isNotEmpty) {
            projects.add(jsonData);
          }
        }
      } catch (e) {
        // Skip invalid JSON
      }
    }

    return projects;
  }

  /// Build project tag widget to display above message
  Widget _buildProjectTagWidget(BuildContext context, Map<String, dynamic> projectData, bool isUser) {
    final name = projectData['name'] as String? ?? '';
    final projectId = projectData['id'] as String? ?? '';

    if (name.isEmpty) return const SizedBox.shrink();

    // Get project from project list controller to get color and icon
    final projects = ref.read(projectListControllerProvider);
    final project = projects.firstWhereOrNull((p) => p.uniqueId == projectId);

    final projectColor = project?.color ?? context.primaryContainer;
    final projectIcon = project?.icon ?? VisirIconType.project;
    final iconColor = isUser ? context.onPrimaryContainer : (projectColor.computeLuminance() > 0.5 ? context.onSurface : Colors.white);

    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: projectColor.withValues(alpha: isUser ? 0.3 : 0.15),
        border: Border.all(color: projectColor.withValues(alpha: isUser ? 0.5 : 0.3), width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          VisirIcon(type: projectIcon, size: 14, color: iconColor, isSelected: true),
          const SizedBox(width: 6),
          Text(
            name,
            style: context.bodySmall?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurface, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _getFunctionConfirmationMessageForConfirm(String functionName, Map<String, dynamic> args) {
    switch (functionName) {
      case 'sendMail':
        final to = (args['to'] as List<dynamic>?)?.map((e) => e.toString()).join(', ') ?? '';
        final subject = args['subject'] as String? ?? '';
        return '다음 이메일을 전송하시겠습니까?\n\n받는 사람: $to\n제목: $subject';
      case 'replyMail':
        final subject = args['subject'] as String? ?? '';
        return '이메일에 답장을 보내시겠습니까?\n\n제목: $subject';
      case 'forwardMail':
        final to = (args['to'] as List<dynamic>?)?.map((e) => e.toString()).join(', ') ?? '';
        return '이메일을 다음 주소로 전달하시겠습니까?\n\n받는 사람: $to';
      case 'deleteTask':
        return '작업을 삭제하시겠습니까?';
      case 'deleteEvent':
        return '일정을 삭제하시겠습니까?';
      case 'deleteMail':
        return '이메일을 삭제하시겠습니까?';
      case 'updateTask':
        final title = args['title'] as String? ?? '';
        return '작업을 수정하시겠습니까?\n\n제목: $title';
      case 'updateEvent':
        final title = args['title'] as String? ?? '';
        return '일정을 수정하시겠습니까?\n\n제목: $title';
      case 'markMailAsRead':
        return '이메일을 읽음으로 표시하시겠습니까?';
      case 'markMailAsUnread':
        return '이메일을 읽지 않음으로 표시하시겠습니까?';
      case 'archiveMail':
        return '이메일을 보관하시겠습니까?';
      case 'responseCalendarInvitation':
        final response = args['response'] as String? ?? '';
        return '캘린더 초대에 "$response"로 응답하시겠습니까?';
      case 'createTask':
        final title = args['title'] as String? ?? '';
        return '다음 작업을 생성하시겠습니까?\n\n제목: $title';
      case 'createEvent':
        final title = args['title'] as String? ?? '';
        return '다음 일정을 생성하시겠습니까?\n\n제목: $title';
      default:
        return '이 작업을 실행하시겠습니까?';
    }
  }

  Widget _buildMessageContent(BuildContext context, String content, bool isUser) {
    final baseStyle = context.bodyLarge?.textColor(context.onSurfaceVariant);

    // Extract tagged items from HTML tags first
    final Map<String, Map<String, dynamic>> taggedItems = {};
    final RegExp taggedTaskRegex = RegExp(r'<tagged_task>(.*?)</tagged_task>', dotAll: true);
    final RegExp taggedEventRegex = RegExp(r'<tagged_event>(.*?)</tagged_event>', dotAll: true);
    final RegExp taggedConnectionRegex = RegExp(r'<tagged_connection>(.*?)</tagged_connection>', dotAll: true);
    final RegExp taggedChannelRegex = RegExp(r'<tagged_channel>(.*?)</tagged_channel>', dotAll: true);
    final RegExp taggedProjectRegex = RegExp(r'<tagged_project>(.*?)</tagged_project>', dotAll: true);

    // Extract tagged tasks
    for (final match in taggedTaskRegex.allMatches(content)) {
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
    for (final match in taggedEventRegex.allMatches(content)) {
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

    // Extract tagged connections
    for (final match in taggedConnectionRegex.allMatches(content)) {
      try {
        final jsonText = match.group(1)?.trim() ?? '';
        if (jsonText.isNotEmpty) {
          final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
          final name = jsonData['name'] as String? ?? '';
          final email = jsonData['email'] as String? ?? '';
          final displayName = name.isNotEmpty && name != 'No name' ? name : (email.isNotEmpty ? email : '');
          if (displayName.isNotEmpty) {
            taggedItems['@$displayName'] = {'type': 'connection', 'data': jsonData};
          }
        }
      } catch (e) {
        // Skip invalid JSON
      }
    }

    // Extract tagged channels
    for (final match in taggedChannelRegex.allMatches(content)) {
      try {
        final jsonText = match.group(1)?.trim() ?? '';
        if (jsonText.isNotEmpty) {
          final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
          final name = jsonData['name'] as String? ?? '';
          if (name.isNotEmpty) {
            taggedItems['@$name'] = {'type': 'channel', 'data': jsonData};
          }
        }
      } catch (e) {
        // Skip invalid JSON
      }
    }

    // Extract tagged projects
    for (final match in taggedProjectRegex.allMatches(content)) {
      try {
        final jsonText = match.group(1)?.trim() ?? '';
        if (jsonText.isNotEmpty) {
          final jsonData = jsonDecode(jsonText) as Map<String, dynamic>;
          final name = jsonData['name'] as String? ?? '';
          if (name.isNotEmpty) {
            taggedItems['@$name'] = {'type': 'project', 'data': jsonData};
          }
        }
      } catch (e) {
        // Skip invalid JSON
      }
    }

    // Remove tagged item tags from content for display (but keep @mentions in text)
    String cleanedContent = content
        .replaceAll(taggedTaskRegex, '')
        .replaceAll(taggedEventRegex, '')
        .replaceAll(taggedConnectionRegex, '')
        .replaceAll(taggedChannelRegex, '')
        .replaceAll(taggedProjectRegex, '');

    // Check if content is HTML (contains HTML tags)
    final isHtml = cleanedContent.contains('<') && cleanedContent.contains('>');

    // Check if content is Markdown (contains Markdown patterns)
    final isMarkdown = !isHtml && _isMarkdownContent(cleanedContent);

    // For HTML content, we need to process @mentions in the text and replace them with inline badges
    // We'll do this by wrapping HtmlWidget and processing the text content
    if (isHtml && taggedItems.isNotEmpty) {
      // Extract text content and replace @mentions with inline badges
      // But HtmlWidget doesn't easily support inline widgets in text, so we need a different approach
      // We'll use customWidgetBuilder to handle tagged_task, tagged_event, tagged_connection tags
      // But we also need to handle @mentions in the plain text parts
    }

    if (isHtml) {
      // Check if this is a suggested task/event message
      final isSuggestedTaskMessage = content.contains('suggested') || content.contains('Would you like to create');
      final isSuggestedEventMessage = content.contains('suggested') || content.contains('Would you like to create');

      // For HTML content, we need to handle @mentions in text nodes
      // HtmlWidget doesn't easily support inline widgets in text, so we'll process the HTML string
      // and replace @mentions with special markers that we can handle in customWidgetBuilder
      String processedHtml = cleanedContent;
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

      return HtmlWidget(
        processedHtml,
        textStyle: htmlTextStyle,
        renderMode: RenderMode.column,
        customWidgetBuilder: (element) {
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

              // Normalize rrule if present
              if (jsonData['rrule'] != null && jsonData['rrule'] is String) {
                final rruleStr = jsonData['rrule'] as String;
                if (rruleStr.isNotEmpty && !rruleStr.toUpperCase().startsWith('RRULE:')) {
                  jsonData['rrule'] = 'RRULE:$rruleStr';
                }
              }

              final task = TaskEntity.fromJson(jsonData, local: true);
              return _buildTaskWidget(context, task, isUser);
            } catch (e) {
              // 디버깅을 위해 에러 메시지 표시
              return Text(context.tr.agent_action_task_generation_failed, style: baseStyle?.copyWith(color: context.error));
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

              // Parse mail data - reply 필드 또는 message 필드 모두 지원 (forward는 message, reply는 reply)
              // 빈 문자열도 허용 (forward의 경우 메시지 없이 포워딩 가능)

              // Always use jsonData as mailData (it contains reply/message, to, cc, bcc, suggest_reply_all)
              final mailData = jsonData;
              // reply 필드가 없으면 message 필드를 reply로 사용
              if (mailData['reply'] == null && mailData['message'] != null) {
                mailData['reply'] = mailData['message'];
              }
              return _buildMailReplyWidget(context, mailData, isUser);
            } catch (e) {
              return Text('Error parsing mail: $e', style: baseStyle?.copyWith(color: context.error));
            }
          }
          if (element.localName == 'inapp_action_confirm') {
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

              final functionName = jsonData['function_name'] as String? ?? '';
              final functionArgs = jsonData['function_args'] as Map<String, dynamic>? ?? {};
              final actionId = jsonData['action_id'] as String? ?? '';

              return _buildActionConfirmWidget(context, functionName, functionArgs, actionId, isUser);
            } catch (e) {
              return Text('Error parsing action confirm: $e', style: baseStyle?.copyWith(color: context.error));
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
          return null;
        },
        customStylesBuilder: (element) {
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
      );
    } else if (isMarkdown) {
      // Render Markdown content
      final unescapedContent = _htmlUnescape.convert(cleanedContent);

      // baseStyle에서 fontFamily를 제거하여 기본 폰트 사용
      final defaultStyle = baseStyle?.copyWith(fontFamily: null);
      final baseFontSize = defaultStyle?.fontSize ?? 14;
      final baseColor = defaultStyle?.color ?? context.onSurfaceVariant;

      // 모든 header에 기본 폰트를 명시적으로 설정 (완전히 새로운 TextStyle 생성)
      final createHeaderStyle = (double fontSize) => TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: baseColor,
        fontFamily: null, // 기본 폰트 사용
        inherit: false, // 상속 비활성화
      );

      return MarkdownBody(
        data: unescapedContent,
        styleSheet: MarkdownStyleSheet(
          p: defaultStyle,
          h1: createHeaderStyle(baseFontSize * 1.5),
          h2: createHeaderStyle(baseFontSize * 1.3),
          h3: createHeaderStyle(baseFontSize * 1.1),
          h4: createHeaderStyle(baseFontSize * 1.05),
          h5: createHeaderStyle(baseFontSize),
          h6: createHeaderStyle(baseFontSize * 0.95),
          code: defaultStyle?.copyWith(
            backgroundColor: Colors.transparent,
            color: context.primaryContainer,
            fontFamily: 'monospace',
            leadingDistribution: TextLeadingDistribution.even,
          ),
          codeblockDecoration: BoxDecoration(color: context.onBackground.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(6)),
          blockquote: defaultStyle?.copyWith(color: context.onSurfaceVariant, fontStyle: FontStyle.italic, fontFamily: null),
          blockquoteDecoration: BoxDecoration(
            border: Border(left: BorderSide(color: context.outline, width: 3)),
          ),
          listBullet: defaultStyle,
          tableHead: defaultStyle?.copyWith(fontWeight: FontWeight.bold, fontFamily: null),
          tableBody: defaultStyle,
        ),
      );
    } else {
      final unescapedContent = _htmlUnescape.convert(cleanedContent);

      // Build inline badges for tagged items in text
      // First, find all known tagged items in the text by searching for their keys
      final List<InlineSpan> spans = [];
      int lastIndex = 0;

      // Find all mentions of tagged items in the text
      final List<({int start, int end, String key, String type})> taggedMentions = [];
      for (final entry in taggedItems.entries) {
        final key = entry.key;
        final itemData = entry.value;
        final itemType = itemData['type'] as String;
        final mentionName = key.substring(1); // Remove @
        // Create a pattern that matches the mention with optional zero-width spaces between words
        final words = mentionName.split(' ');
        final pattern = words.map((word) => RegExp.escape(word)).join(r'\s*\u200b?\s*');
        final regex = RegExp('@$pattern', caseSensitive: false);
        final matches = regex.allMatches(unescapedContent);
        for (final match in matches) {
          taggedMentions.add((start: match.start, end: match.end, key: key, type: itemType));
        }
      }

      // Sort by start position
      taggedMentions.sort((a, b) => a.start.compareTo(b.start));

      // Process text and replace mentions with badges
      for (final mention in taggedMentions) {
        // Add text before the mention
        if (mention.start > lastIndex) {
          spans.add(TextSpan(text: unescapedContent.substring(lastIndex, mention.start), style: baseStyle));
        }

        final displayText = mention.key.substring(1); // Remove @ from key
        final itemType = mention.type;
        final itemData = taggedItems[mention.key]?['data'] as Map<String, dynamic>?;

        // Determine icon based on item type
        VisirIconType iconType;
        Color? iconColor;
        Color? backgroundColor;
        Color? borderColor;

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
            // Get project from project list controller to get color and icon
            final projects = ref.read(projectListControllerProvider);
            final projectId = itemData?['id'] as String?;
            final project = projectId != null ? projects.firstWhereOrNull((p) => p.uniqueId == projectId) : null;

            iconType = project?.icon ?? VisirIconType.project;
            if (project != null && project.color != null) {
              backgroundColor = project.color!.withValues(alpha: isUser ? 0.3 : 0.15);
              borderColor = project.color!.withValues(alpha: isUser ? 0.5 : 0.3);
              iconColor = isUser ? context.onPrimaryContainer : (project.color!.computeLuminance() > 0.5 ? context.onSurface : Colors.white);
            } else {
              iconColor = isUser ? context.onPrimaryContainer : context.onSurface;
            }
            break;
          default:
            iconType = VisirIconType.task;
        }

        // Create inline badge widget with icon and max width
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 200),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.only(left: 4, right: 6, top: 2, bottom: 2),
              decoration: BoxDecoration(
                color: backgroundColor ?? context.surface,
                borderRadius: BorderRadius.circular(4),
                border: borderColor != null ? Border.all(color: borderColor, width: 1) : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (itemType == 'project' && itemData?['id'] != null)
                    Builder(
                      builder: (context) {
                        final projects = ref.read(projectListControllerProvider);
                        final projectId = itemData?['id'] as String?;
                        final project = projectId != null ? projects.firstWhereOrNull((p) => p.uniqueId == projectId) : null;

                        if (project != null && project.color != null) {
                          return Container(
                            width: 12,
                            height: 12,
                            alignment: Alignment.center,
                            child: project.icon == null ? null : VisirIcon(type: project.icon!, size: 12, color: project.color ?? context.onBackground, isSelected: true),
                          );
                        } else {
                          return VisirIcon(type: iconType, size: 12, color: iconColor ?? (isUser ? context.onPrimaryContainer : context.onSurface), isSelected: true);
                        }
                      },
                    )
                  else
                    VisirIcon(type: iconType, size: 12, color: iconColor ?? (isUser ? context.onPrimaryContainer : context.onSurface), isSelected: true),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      displayText,
                      style: baseStyle?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurface, fontSize: (baseStyle?.fontSize ?? 14)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        lastIndex = mention.end;
      }

      // Add remaining text
      if (lastIndex < unescapedContent.length) {
        spans.add(TextSpan(text: unescapedContent.substring(lastIndex), style: baseStyle));
      }

      return Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Expanded(
            child: isUser
                ? IntrinsicWidth(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: context.outline, width: 1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Text.rich(
                        TextSpan(
                          children: spans.isEmpty ? [TextSpan(text: unescapedContent, style: baseStyle)] : spans,
                        ),
                        style: baseStyle,
                      ),
                    ),
                  )
                : Text.rich(
                    TextSpan(
                      children: spans.isEmpty ? [TextSpan(text: unescapedContent, style: baseStyle)] : spans,
                    ),
                    style: baseStyle,
                  ),
          ),
        ],
      );
    }
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
          } else if (senderName != null && senderName.isNotEmpty) {
            itemName = senderName;
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
          : Transform.translate(
              offset: Offset(0, PlatformX.isMobileView ? 0 : 12),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                clipBehavior: Clip.none,
                child: Container(
                  height: widget.maxHeight - (PlatformX.isMobileView ? 0 : VisirAppBar.height * 2 / 3 + 12),
                  margin: EdgeInsets.only(top: PlatformX.isMobileView ? 0 : VisirAppBar.height * 2 / 3 - 12),
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
                            // Batch confirmation button if multiple pending actions exist
                            Builder(
                              builder: (context) {
                                final state = ref.watch(agentActionControllerProvider);
                                final pendingCalls = state.pendingFunctionCalls ?? [];
                                final selectedIds = state.selectedActionIds;
                                
                                if (pendingCalls.length < 2) {
                                  return const SizedBox.shrink();
                                }
                                
                                final hasSelected = selectedIds.isNotEmpty;
                                
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: context.surfaceVariant.withValues(alpha: 0.5),
                                    border: Border(
                                      bottom: BorderSide(color: context.outline.withValues(alpha: 0.2), width: 1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: selectedIds.length == pendingCalls.length,
                                        tristate: true,
                                        onChanged: (value) {
                                          controller.toggleAllActionsSelection(value ?? false);
                                        },
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${selectedIds.length}/${pendingCalls.length}개 선택됨',
                                          style: context.bodySmall?.copyWith(color: context.onSurfaceVariant),
                                        ),
                                      ),
                                      if (hasSelected)
                                        VisirButton(
                                          type: VisirButtonAnimationType.scaleAndOpacity,
                                          style: VisirButtonStyle(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            backgroundColor: context.primary,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          onTap: () async {
                                            await controller.confirmActions(actionIds: selectedIds.toList());
                                          },
                                          child: Text(
                                            '선택한 항목 확인 (${selectedIds.length})',
                                            style: context.bodySmall?.copyWith(color: context.onPrimary),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            Expanded(
                              child: ListView.builder(
                                controller: _scrollController,
                                itemCount: agentAction.messages.length + (agentAction.isLoading ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == agentAction.messages.length) {
                                    return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          VisirIcon(type: VisirIconType.agent, size: 20, color: context.primary, isSelected: true),
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

                                  // Extract tagged projects for this message
                                  final taggedProjects = _extractTaggedProjects(message.content);

                                  return Container(
                                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Display project tags if any
                                        if (taggedProjects.isNotEmpty)
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            children: taggedProjects.map((projectData) => _buildProjectTagWidget(context, projectData, isUser)).toList(),
                                          ),
                                        if (taggedProjects.isNotEmpty) const SizedBox(height: 8),
                                        // Message content
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (!isUser) ...[VisirIcon(type: VisirIconType.agent, size: 20, color: context.primary, isSelected: true), const SizedBox(width: 8)],
                                            Expanded(child: _buildMessageContent(context, message.content, isUser)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),

                            SizedBox(height: PlatformX.isMobileView ? 0 : 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
  final HtmlUnescape _htmlUnescape = HtmlUnescape();

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
    // pending 상태 확인
    final state = ref.watch(agentActionControllerProvider);
    final pendingCalls = state.pendingFunctionCalls ?? [];
    final isPending = pendingCalls.any((call) => call['action_id'] == widget.actionId);

    // 이미 확인된 경우 빈 위젯 반환
    if (!isPending) {
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
            // Checkbox for batch selection
            Row(
              children: [
                Checkbox(
                  value: state.selectedActionIds.contains(widget.actionId),
                  onChanged: !_isProcessing
                      ? (value) {
                          ref.read(agentActionControllerProvider.notifier).toggleActionSelection(widget.actionId);
                        }
                      : null,
                ),
                Expanded(
                  child: Text(
                    widget.confirmationMessage,
                    style: context.bodyMedium?.copyWith(color: widget.isUser ? context.onPrimaryContainer : context.onSurfaceVariant, height: 1.5),
                  ),
                ),
              ],
            ),
            // Action details based on function type
            if (widget.functionName == 'sendMail' || widget.functionName == 'replyMail' || widget.functionName == 'forwardMail') ...[
              _buildMailActionDetailsForConfirm(context, widget.functionName, widget.functionArgs, widget.isUser),
            ] else if (widget.functionName == 'createTask' || widget.functionName == 'updateTask') ...[
              _buildTaskActionDetailsForConfirm(context, widget.functionArgs, widget.isUser),
            ] else if (widget.functionName == 'createEvent' || widget.functionName == 'updateEvent') ...[
              _buildEventActionDetailsForConfirm(context, widget.functionArgs, widget.isUser),
            ],
            const SizedBox(height: 12),
            // Confirm button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!_isProcessing)
                  VisirButton(
                    type: VisirButtonAnimationType.scaleAndOpacity,
                    style: VisirButtonStyle(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      backgroundColor: context.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    onTap: _handleConfirm,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(context.tr.ok, style: context.bodyMedium?.copyWith(color: context.onPrimary)),
                        const SizedBox(width: 4),
                        Text(
                          PlatformX.isApple ? '⌘⏎' : 'Ctrl+Enter',
                          style: context.bodySmall?.copyWith(color: context.onPrimary.withValues(alpha: 0.7), fontSize: (context.bodySmall?.fontSize ?? 12) * 0.9),
                        ),
                      ],
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
            child: Text('제목: $subject', style: context.bodySmall?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant)),
          ),
        ],
        if (toList.isNotEmpty || ccList.isNotEmpty || bccList.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (toList.isNotEmpty) _buildRecipientRowForConfirm(context, '받는 사람', toList, isUser),
                if (ccList.isNotEmpty) _buildRecipientRowForConfirm(context, '참조', ccList, isUser),
                if (bccList.isNotEmpty) _buildRecipientRowForConfirm(context, '숨은 참조', bccList, isUser),
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
              '제목: $title',
              style: context.bodySmall?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        if (description.isNotEmpty) ...[
          Text(
            description,
            style: context.bodySmall?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant, height: 1.4),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildEventActionDetailsForConfirm(BuildContext context, Map<String, dynamic> args, bool isUser) {
    final title = args['title'] as String? ?? '';
    final description = args['description'] as String? ?? '';
    final startAtStr = args['start_at'] as String?;
    final endAtStr = args['end_at'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '제목: $title',
              style: context.bodySmall?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        if (startAtStr != null || endAtStr != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '시간: ${startAtStr ?? ''}${endAtStr != null ? ' - $endAtStr' : ''}',
              style: context.bodySmall?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant),
            ),
          ),
        ],
        if (description.isNotEmpty) ...[
          Text(
            description,
            style: context.bodySmall?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant, height: 1.4),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
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

  String _getFunctionConfirmationMessageForConfirm(String functionName, Map<String, dynamic> args) {
    switch (functionName) {
      case 'sendMail':
        final to = (args['to'] as List<dynamic>?)?.map((e) => e.toString()).join(', ') ?? '';
        final subject = args['subject'] as String? ?? '';
        return '다음 이메일을 전송하시겠습니까?\n\n받는 사람: $to\n제목: $subject';
      case 'replyMail':
        final subject = args['subject'] as String? ?? '';
        return '이메일에 답장을 보내시겠습니까?\n\n제목: $subject';
      case 'forwardMail':
        final to = (args['to'] as List<dynamic>?)?.map((e) => e.toString()).join(', ') ?? '';
        return '이메일을 다음 주소로 전달하시겠습니까?\n\n받는 사람: $to';
      case 'deleteTask':
        return '작업을 삭제하시겠습니까?';
      case 'deleteEvent':
        return '일정을 삭제하시겠습니까?';
      case 'deleteMail':
        return '이메일을 삭제하시겠습니까?';
      case 'updateTask':
        final title = args['title'] as String? ?? '';
        return '작업을 수정하시겠습니까?\n\n제목: $title';
      case 'updateEvent':
        final title = args['title'] as String? ?? '';
        return '일정을 수정하시겠습니까?\n\n제목: $title';
      case 'markMailAsRead':
        return '이메일을 읽음으로 표시하시겠습니까?';
      case 'markMailAsUnread':
        return '이메일을 읽지 않음으로 표시하시겠습니까?';
      case 'archiveMail':
        return '이메일을 보관하시겠습니까?';
      case 'responseCalendarInvitation':
        final response = args['response'] as String? ?? '';
        return '캘린더 초대에 "$response"로 응답하시겠습니까?';
      case 'createTask':
        final title = args['title'] as String? ?? '';
        return '다음 작업을 생성하시겠습니까?\n\n제목: $title';
      case 'createEvent':
        final title = args['title'] as String? ?? '';
        return '다음 일정을 생성하시겠습니까?\n\n제목: $title';
      default:
        return '이 작업을 실행하시겠습니까?';
    }
  }

  Widget _buildMailActionDetails(BuildContext context, String functionName, Map<String, dynamic> args, bool isUser) {
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
            child: Text('제목: $subject', style: context.bodySmall?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant)),
          ),
        ],
        if (toList.isNotEmpty || ccList.isNotEmpty || bccList.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (toList.isNotEmpty) _buildRecipientRowForConfirm(context, '받는 사람', toList, isUser),
                if (ccList.isNotEmpty) _buildRecipientRowForConfirm(context, '참조', ccList, isUser),
                if (bccList.isNotEmpty) _buildRecipientRowForConfirm(context, '숨은 참조', bccList, isUser),
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

  Widget _buildTaskActionDetails(BuildContext context, Map<String, dynamic> args, bool isUser) {
    final title = args['title'] as String? ?? '';
    final description = args['description'] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '제목: $title',
              style: context.bodySmall?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        if (description.isNotEmpty) ...[
          Text(
            description,
            style: context.bodySmall?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant, height: 1.4),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildEventActionDetails(BuildContext context, Map<String, dynamic> args, bool isUser) {
    final title = args['title'] as String? ?? '';
    final description = args['description'] as String? ?? '';
    final startAtStr = args['start_at'] as String?;
    final endAtStr = args['end_at'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '제목: $title',
              style: context.bodySmall?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        if (startAtStr != null || endAtStr != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '시간: ${startAtStr ?? ''}${endAtStr != null ? ' - $endAtStr' : ''}',
              style: context.bodySmall?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant),
            ),
          ),
        ],
        if (description.isNotEmpty) ...[
          Text(
            description,
            style: context.bodySmall?.copyWith(color: isUser ? context.onPrimaryContainer : context.onSurfaceVariant, height: 1.4),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
