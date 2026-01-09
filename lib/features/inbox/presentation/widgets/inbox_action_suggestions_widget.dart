import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/selection_widget.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_suggestion_entity.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// AgentActionType enum (기존 코드와의 호환성을 위해 유지)
enum AgentActionType {
  // Task actions
  createTask,
  updateTask,
  deleteTask,
  toggleTaskStatus,
  assignProject,
  setPriority,
  addTags,
  removeTags,
  setDueDate,

  // Calendar actions
  createEvent,
  editEvent,
  deleteEvent,
  responseCalendarInvitation,
  optimizeSchedule,

  // Mail actions
  reply,
  forward,
  send,

  // Project actions
  createProject,
  linkToProject,
}

extension AgentActionTypeExtension on AgentActionType {
  String getTitle(BuildContext context) {
    switch (this) {
      // Task actions
      case AgentActionType.createTask:
        return context.tr.create_task;
      case AgentActionType.updateTask:
        return 'Update Task'; // TODO: 번역 키 추가 필요
      case AgentActionType.deleteTask:
        return context.tr.task_deleted;
      case AgentActionType.toggleTaskStatus:
        return context.tr.task_done;
      case AgentActionType.assignProject:
        return 'Assign Project'; // TODO: 번역 키 추가 필요
      case AgentActionType.setPriority:
        return 'Set Priority'; // TODO: 번역 키 추가 필요
      case AgentActionType.addTags:
        return 'Add Tags'; // TODO: 번역 키 추가 필요
      case AgentActionType.removeTags:
        return 'Remove Tags'; // TODO: 번역 키 추가 필요
      case AgentActionType.setDueDate:
        return 'Set Due Date'; // TODO: 번역 키 추가 필요

      // Calendar actions
      case AgentActionType.createEvent:
        return context.tr.command_create_event('').replaceAll(' {title}', '');
      case AgentActionType.editEvent:
        return context.tr.event_edited;
      case AgentActionType.deleteEvent:
        return context.tr.event_deleted;
      case AgentActionType.responseCalendarInvitation:
        return context.tr.event_created; // TODO: 적절한 번역 키로 변경 필요
      case AgentActionType.optimizeSchedule:
        return 'Optimize Schedule'; // TODO: 번역 키 추가 필요

      // Mail actions
      case AgentActionType.reply:
        return context.tr.mail_reply;
      case AgentActionType.forward:
        return context.tr.mail_forward;
      case AgentActionType.send:
        return context.tr.mail_send;

      // Project actions
      case AgentActionType.createProject:
        return 'Create Project'; // TODO: 번역 키 추가 필요
      case AgentActionType.linkToProject:
        return 'Link to Project'; // TODO: 번역 키 추가 필요
    }
  }

  VisirIconType get icon {
    switch (this) {
      // Task actions
      case AgentActionType.createTask:
        return VisirIconType.task;
      case AgentActionType.updateTask:
        return VisirIconType.edit;
      case AgentActionType.deleteTask:
        return VisirIconType.trash;
      case AgentActionType.toggleTaskStatus:
        return VisirIconType.check;
      case AgentActionType.assignProject:
        return VisirIconType.project;
      case AgentActionType.setPriority:
        return VisirIconType.star;
      case AgentActionType.addTags:
        return VisirIconType.star;
      case AgentActionType.removeTags:
        return VisirIconType.star;
      case AgentActionType.setDueDate:
        return VisirIconType.calendar;

      // Calendar actions
      case AgentActionType.createEvent:
        return VisirIconType.calendar;
      case AgentActionType.editEvent:
        return VisirIconType.edit;
      case AgentActionType.deleteEvent:
        return VisirIconType.trash;
      case AgentActionType.responseCalendarInvitation:
        return VisirIconType.check;
      case AgentActionType.optimizeSchedule:
        return VisirIconType.calendarAfter;

      // Mail actions
      case AgentActionType.reply:
        return VisirIconType.reply;
      case AgentActionType.forward:
        return VisirIconType.forward;
      case AgentActionType.send:
        return VisirIconType.send;

      // Project actions
      case AgentActionType.createProject:
        return VisirIconType.project;
      case AgentActionType.linkToProject:
        return VisirIconType.outlink;
    }
  }
}

/// MCP 함수 이름을 AgentActionType으로 변환합니다.
/// 기존 코드와의 호환성을 위해 제공됩니다.
AgentActionType? mcpFunctionToAgentActionType(String mcpFunctionName) {
  switch (mcpFunctionName) {
    case 'createTask':
      return AgentActionType.createTask;
    case 'updateTask':
      return AgentActionType.updateTask;
    case 'deleteTask':
      return AgentActionType.deleteTask;
    case 'toggleTaskStatus':
      return AgentActionType.toggleTaskStatus;
    case 'assignProject':
      return AgentActionType.assignProject;
    case 'setPriority':
      return AgentActionType.setPriority;
    case 'addTags':
      return AgentActionType.addTags;
    case 'removeTags':
      return AgentActionType.removeTags;
    case 'setDueDate':
      return AgentActionType.setDueDate;
    case 'createEvent':
      return AgentActionType.createEvent;
    case 'updateEvent':
      return AgentActionType.editEvent;
    case 'deleteEvent':
      return AgentActionType.deleteEvent;
    case 'responseCalendarInvitation':
      return AgentActionType.responseCalendarInvitation;
    case 'optimizeSchedule':
      return AgentActionType.optimizeSchedule;
    case 'replyMail':
      return AgentActionType.reply;
    case 'forwardMail':
      return AgentActionType.forward;
    case 'sendMail':
      return AgentActionType.send;
    case 'createProject':
      return AgentActionType.createProject;
    case 'linkToProject':
      return AgentActionType.linkToProject;
    default:
      return null;
  }
}

/// MCP 함수 이름을 VisirIconType으로 매핑합니다.
VisirIconType _getIconForMcpFunction(String functionName) {
  switch (functionName) {
    // Task Actions
    case 'createTask':
      return VisirIconType.task;
    case 'updateTask':
      return VisirIconType.edit;
    case 'deleteTask':
      return VisirIconType.trash;
    case 'assignProject':
      return VisirIconType.project;
    case 'setPriority':
      return VisirIconType.star;
    case 'addTags':
    case 'removeTags':
      return VisirIconType.star;
    case 'setDueDate':
      return VisirIconType.calendar;
    case 'toggleTaskStatus':
      return VisirIconType.check;
    case 'reschedule':
      return VisirIconType.calendar;
    case 'getPreviousContext':
      return VisirIconType.brain;
    case 'convertBraindumpToTask':
      return VisirIconType.task;
    case 'markDoneAndReply':
      return VisirIconType.check;
    case 'setRecurrence':
    case 'removeRecurrence':
      return VisirIconType.repeat;

    // Calendar Actions
    case 'createEvent':
      return VisirIconType.calendar;
    case 'updateEvent':
      return VisirIconType.edit;
    case 'deleteEvent':
      return VisirIconType.trash;
    case 'responseCalendarInvitation':
      return VisirIconType.check;
    case 'optimizeSchedule':
      return VisirIconType.calendarAfter;

    // Mail Actions
    case 'sendMail':
      return VisirIconType.send;
    case 'replyMail':
      return VisirIconType.reply;
    case 'forwardMail':
      return VisirIconType.forward;
    case 'markMailAsRead':
      return VisirIconType.show;
    case 'markMailAsUnread':
      return VisirIconType.hide;
    case 'archiveMail':
      return VisirIconType.archive;
    case 'deleteMail':
      return VisirIconType.trash;

    default:
      return VisirIconType.task;
  }
}

/// MCP 함수 이름을 사용자 친화적인 제목으로 변환합니다.
String _getTitleForMcpFunction(BuildContext context, String functionName) {
  switch (functionName) {
    // Task Actions
    case 'createTask':
      return context.tr.create_task;
    case 'updateTask':
      return context.tr.task_edited;
    case 'deleteTask':
      return context.tr.task_deleted;
    case 'toggleTaskStatus':
      return context.tr.task_done;
    case 'reschedule':
      return 'Reschedule'; // TODO: 번역 키 추가 필요
    case 'setDueDate':
      return 'Set Due Date'; // TODO: 번역 키 추가 필요
    case 'getPreviousContext':
      return 'View Previous Context'; // TODO: 번역 키 추가 필요
    case 'convertBraindumpToTask':
      return 'Convert to Task'; // TODO: 번역 키 추가 필요
    case 'markDoneAndReply':
      return 'Mark Done & Reply'; // TODO: 번역 키 추가 필요
    case 'setRecurrence':
      return 'Edit Recurrence'; // TODO: 번역 키 추가 필요
    case 'removeRecurrence':
      return 'Remove Recurrence'; // TODO: 번역 키 추가 필요

    // Calendar Actions
    case 'createEvent':
      return context.tr.command_create_event('').replaceAll(' {title}', '');
    case 'updateEvent':
      return context.tr.event_edited;
    case 'deleteEvent':
      return context.tr.event_deleted;
    case 'responseCalendarInvitation':
      return context.tr.event_created; // TODO: 적절한 번역 키로 변경 필요

    // Mail Actions
    case 'sendMail':
      return context.tr.mail_send;
    case 'replyMail':
      return context.tr.mail_reply;
    case 'forwardMail':
      return context.tr.mail_forward;
    case 'markMailAsRead':
      return context.tr.mail_detail_tooltip_mark_as_read;
    case 'markMailAsUnread':
      return context.tr.mail_detail_tooltip_mark_as_unread;
    case 'archiveMail':
      return context.tr.mail_detail_tooltip_archive;
    case 'deleteMail':
      return context.tr.mail_detail_tooltip_delete;

    default:
      return functionName;
  }
}

/// InboxSuggestionReason과 urgency를 기반으로 적절한 MCP 함수를 추천합니다.
List<String> _getRecommendedMcpFunctions(InboxSuggestionEntity suggestion, InboxEntity inbox) {
  final functions = <String>[];

  // Urgent/Important 항목에 대한 즉시 처리 액션
  final taskRelevantReasons = {
    InboxSuggestionReason.task_assignment,
    InboxSuggestionReason.meeting_followup,
    InboxSuggestionReason.task_status_update,
    InboxSuggestionReason.document_review,
    InboxSuggestionReason.code_review,
    InboxSuggestionReason.approval_request,
  };

  // Reason 기반 액션 추천
  switch (suggestion.reason) {
    case InboxSuggestionReason.meeting_invitation:
      functions.add('createEvent');
      break;

    case InboxSuggestionReason.task_assignment:
      functions.add('createTask');
      break;

    case InboxSuggestionReason.scheduling_request:
      functions.add('createEvent');
      break;

    case InboxSuggestionReason.approval_request:
      // 승인 요청은 urgent/important인 경우 createTask로 추천
      if (suggestion.urgency == InboxSuggestionUrgency.urgent || suggestion.urgency == InboxSuggestionUrgency.important) {
        if (taskRelevantReasons.contains(suggestion.reason)) {
          functions.add('createTask');
        }
      }
      break;

    default:
      // Urgent/Important 항목에 대한 즉시 처리 액션
      if ((suggestion.urgency == InboxSuggestionUrgency.urgent || suggestion.urgency == InboxSuggestionUrgency.important) && taskRelevantReasons.contains(suggestion.reason)) {
        functions.add('createTask');
      }
      break;
  }

  return functions;
}

class McpActionSuggestion {
  final String mcpFunctionName;
  final String? itemName;
  final String actionName;
  final VisirIconType icon;
  final InboxEntity? inbox;
  final TaskEntity? task;
  final EventEntity? event;
  final VoidCallback onTap;

  McpActionSuggestion({required this.mcpFunctionName, this.itemName, required this.actionName, required this.icon, this.inbox, this.task, this.event, required this.onTap});
}

class AgentActionSuggestionsWidget extends ConsumerWidget {
  final List<InboxEntity> inboxes;
  final TaskEntity? upNextTask;
  final EventEntity? upNextEvent;
  final InboxEntity? droppedInbox;
  final TaskEntity? droppedTask;
  final EventEntity? droppedEvent;
  final bool hasTaggedItems;
  final Function(String mcpFunctionName, {InboxEntity? inbox, TaskEntity? task, EventEntity? event})? onActionTap;
  final Function(String title, String prompt)? onCustomPrompt;
  bool isRow;

  AgentActionSuggestionsWidget({
    super.key,
    required this.inboxes,
    this.upNextTask,
    this.upNextEvent,
    this.droppedInbox,
    this.droppedTask,
    this.droppedEvent,
    this.hasTaggedItems = false,
    this.onActionTap,
    this.onCustomPrompt,
    this.isRow = true,
  });

  /// 드롭된 아이템의 속성에 따라 suggested action을 생성합니다.
  List<McpActionSuggestion> _generateSuggestionsForDroppedItem(BuildContext context, WidgetRef ref) {
    final suggestions = <McpActionSuggestion>[];

    // Task의 경우 (linkedEvent == null인 경우만 task로 인지)
    if (droppedTask != null && droppedTask!.linkedEvent == null) {
      // status == done이거나 linkedMails/linkedMessages가 있는 경우 (중복 방지)
      if (droppedTask!.status == TaskStatus.done || droppedTask!.linkedMails.isNotEmpty || droppedTask!.linkedMessages.isNotEmpty) {
        suggestions.add(
          McpActionSuggestion(
            mcpFunctionName: 'getPreviousContext',
            itemName: hasTaggedItems ? null : droppedTask!.title,
            actionName: _getTitleForMcpFunction(context, 'getPreviousContext'),
            icon: _getIconForMcpFunction('getPreviousContext'),
            task: droppedTask,
            onTap: () => onActionTap?.call('getPreviousContext', task: droppedTask!),
          ),
        );
      }

      // status == braindump인 경우
      if (droppedTask!.status == TaskStatus.braindump) {
        suggestions.add(
          McpActionSuggestion(
            mcpFunctionName: 'convertBraindumpToTask',
            itemName: hasTaggedItems ? null : droppedTask!.title,
            actionName: _getTitleForMcpFunction(context, 'convertBraindumpToTask'),
            icon: _getIconForMcpFunction('convertBraindumpToTask'),
            task: droppedTask,
            onTap: () => onActionTap?.call('convertBraindumpToTask', task: droppedTask!),
          ),
        );
      }

      // isOverdue인 경우
      if (droppedTask!.isOverdue) {
        suggestions.add(
          McpActionSuggestion(
            mcpFunctionName: 'reschedule',
            itemName: hasTaggedItems ? null : droppedTask!.title,
            actionName: _getTitleForMcpFunction(context, 'reschedule'),
            icon: _getIconForMcpFunction('reschedule'),
            task: droppedTask,
            onTap: () => onActionTap?.call('reschedule', task: droppedTask!),
          ),
        );
      }

      // isUnscheduled인 경우
      if (droppedTask!.isUnscheduled) {
        suggestions.add(
          McpActionSuggestion(
            mcpFunctionName: 'setDueDate',
            itemName: hasTaggedItems ? null : droppedTask!.title,
            actionName: _getTitleForMcpFunction(context, 'setDueDate'),
            icon: _getIconForMcpFunction('setDueDate'),
            task: droppedTask,
            onTap: () => onActionTap?.call('setDueDate', task: droppedTask!),
          ),
        );
      }

      // 조합 액션: status == none && linkedMails/linkedMessages가 있는 경우
      if (droppedTask!.status == TaskStatus.none && (droppedTask!.linkedMails.isNotEmpty || droppedTask!.linkedMessages.isNotEmpty)) {
        suggestions.add(
          McpActionSuggestion(
            mcpFunctionName: 'markDoneAndReply',
            itemName: hasTaggedItems ? null : droppedTask!.title,
            actionName: _getTitleForMcpFunction(context, 'markDoneAndReply'),
            icon: _getIconForMcpFunction('markDoneAndReply'),
            task: droppedTask,
            onTap: () => onActionTap?.call('markDoneAndReply', task: droppedTask!),
          ),
        );
      }
    }

    // Event의 경우 (linkedEvent != null인 경우 event로 인지)
    if (droppedEvent != null) {
      // linkedMails 또는 linkedMessages가 있는 경우 (task에서 가져온 경우)
      if (droppedTask != null && (droppedTask!.linkedMails.isNotEmpty || droppedTask!.linkedMessages.isNotEmpty)) {
        suggestions.add(
          McpActionSuggestion(
            mcpFunctionName: 'getPreviousContext',
            itemName: hasTaggedItems ? null : droppedEvent!.title,
            actionName: _getTitleForMcpFunction(context, 'getPreviousContext'),
            icon: _getIconForMcpFunction('getPreviousContext'),
            event: droppedEvent,
            onTap: () => onActionTap?.call('getPreviousContext', event: droppedEvent!),
          ),
        );
      }

      // isRequest인 경우
      if (droppedEvent!.isRequest) {
        suggestions.add(
          McpActionSuggestion(
            mcpFunctionName: 'responseCalendarInvitation',
            itemName: hasTaggedItems ? null : droppedEvent!.title,
            actionName: _getTitleForMcpFunction(context, 'responseCalendarInvitation'),
            icon: _getIconForMcpFunction('responseCalendarInvitation'),
            event: droppedEvent,
            onTap: () => onActionTap?.call('responseCalendarInvitation', event: droppedEvent!),
          ),
        );
      }

      // isDeclined인 경우
      if (droppedEvent!.isDeclined) {
        suggestions.add(
          McpActionSuggestion(
            mcpFunctionName: 'responseCalendarInvitation',
            itemName: hasTaggedItems ? null : droppedEvent!.title,
            actionName: _getTitleForMcpFunction(context, 'responseCalendarInvitation'),
            icon: _getIconForMcpFunction('responseCalendarInvitation'),
            event: droppedEvent,
            onTap: () => onActionTap?.call('responseCalendarInvitation', event: droppedEvent!),
          ),
        );
      }

      // isMaybe인 경우
      if (droppedEvent!.isMaybe) {
        suggestions.add(
          McpActionSuggestion(
            mcpFunctionName: 'responseCalendarInvitation',
            itemName: hasTaggedItems ? null : droppedEvent!.title,
            actionName: _getTitleForMcpFunction(context, 'responseCalendarInvitation'),
            icon: _getIconForMcpFunction('responseCalendarInvitation'),
            event: droppedEvent,
            onTap: () => onActionTap?.call('responseCalendarInvitation', event: droppedEvent!),
          ),
        );
      }

      // rrule이 있는 경우
      if (droppedEvent!.rrule != null) {
        suggestions.add(
          McpActionSuggestion(
            mcpFunctionName: 'setRecurrence',
            itemName: hasTaggedItems ? null : droppedEvent!.title,
            actionName: _getTitleForMcpFunction(context, 'setRecurrence'),
            icon: _getIconForMcpFunction('setRecurrence'),
            event: droppedEvent,
            onTap: () => onActionTap?.call('setRecurrence', event: droppedEvent!),
          ),
        );
        suggestions.add(
          McpActionSuggestion(
            mcpFunctionName: 'removeRecurrence',
            itemName: hasTaggedItems ? null : droppedEvent!.title,
            actionName: _getTitleForMcpFunction(context, 'removeRecurrence'),
            icon: _getIconForMcpFunction('removeRecurrence'),
            event: droppedEvent,
            onTap: () => onActionTap?.call('removeRecurrence', event: droppedEvent!),
          ),
        );
      }

      // startDate가 과거인 경우
      if (droppedEvent!.startDate.isBefore(DateTime.now())) {
        suggestions.add(
          McpActionSuggestion(
            mcpFunctionName: 'reschedule',
            itemName: hasTaggedItems ? null : droppedEvent!.title,
            actionName: _getTitleForMcpFunction(context, 'reschedule'),
            icon: _getIconForMcpFunction('reschedule'),
            event: droppedEvent,
            onTap: () => onActionTap?.call('reschedule', event: droppedEvent!),
          ),
        );
      }
    }

    // Inbox의 경우
    if (droppedInbox != null) {
      // linkedMail 또는 linkedMessage가 있는 경우
      if (droppedInbox!.linkedMail != null || droppedInbox!.linkedMessage != null) {
        suggestions.add(
          McpActionSuggestion(
            mcpFunctionName: 'getPreviousContext',
            itemName: hasTaggedItems ? null : (droppedInbox!.suggestion?.summary ?? droppedInbox!.decryptedTitle),
            actionName: _getTitleForMcpFunction(context, 'getPreviousContext'),
            icon: _getIconForMcpFunction('getPreviousContext'),
            inbox: droppedInbox,
            onTap: () => onActionTap?.call('getPreviousContext', inbox: droppedInbox!),
          ),
        );
      }

      final suggestion = droppedInbox!.suggestion;
      if (suggestion != null) {
        // suggestion.reason == meeting_invitation인 경우
        if (suggestion.reason == InboxSuggestionReason.meeting_invitation) {
          suggestions.add(
            McpActionSuggestion(
              mcpFunctionName: 'createEvent',
              itemName: hasTaggedItems ? null : suggestion.summary,
              actionName: _getTitleForMcpFunction(context, 'createEvent'),
              icon: _getIconForMcpFunction('createEvent'),
              inbox: droppedInbox,
              onTap: () => onActionTap?.call('createEvent', inbox: droppedInbox!),
            ),
          );
        }

        // suggestion.reason == task_assignment인 경우
        if (suggestion.reason == InboxSuggestionReason.task_assignment) {
          suggestions.add(
            McpActionSuggestion(
              mcpFunctionName: 'createTask',
              itemName: hasTaggedItems ? null : suggestion.summary,
              actionName: _getTitleForMcpFunction(context, 'createTask'),
              icon: _getIconForMcpFunction('createTask'),
              inbox: droppedInbox,
              onTap: () => onActionTap?.call('createTask', inbox: droppedInbox!),
            ),
          );
        }

        // suggestion.reason == scheduling_request인 경우
        if (suggestion.reason == InboxSuggestionReason.scheduling_request) {
          suggestions.add(
            McpActionSuggestion(
              mcpFunctionName: 'createEvent',
              itemName: hasTaggedItems ? null : suggestion.summary,
              actionName: _getTitleForMcpFunction(context, 'createEvent'),
              icon: _getIconForMcpFunction('createEvent'),
              inbox: droppedInbox,
              onTap: () => onActionTap?.call('createEvent', inbox: droppedInbox!),
            ),
          );
        }

        // suggestion.reason == question인 경우
        if (suggestion.reason == InboxSuggestionReason.question) {
          if (droppedInbox!.linkedMail != null) {
            suggestions.add(
              McpActionSuggestion(
                mcpFunctionName: 'replyMail',
                itemName: hasTaggedItems ? null : suggestion.summary,
                actionName: _getTitleForMcpFunction(context, 'replyMail'),
                icon: _getIconForMcpFunction('replyMail'),
                inbox: droppedInbox,
                onTap: () => onActionTap?.call('replyMail', inbox: droppedInbox!),
              ),
            );
          } else if (droppedInbox!.linkedMessage != null) {
            suggestions.add(
              McpActionSuggestion(
                mcpFunctionName: 'replyMessage',
                itemName: hasTaggedItems ? null : suggestion.summary,
                actionName: _getTitleForMcpFunction(context, 'replyMessage'),
                icon: _getIconForMcpFunction('replyMessage'),
                inbox: droppedInbox,
                onTap: () => onActionTap?.call('replyMessage', inbox: droppedInbox!),
              ),
            );
          }
        }
      }

      // linkedMail이 있는 경우
      if (droppedInbox!.linkedMail != null) {
        suggestions.add(
          McpActionSuggestion(
            mcpFunctionName: 'replyMail',
            itemName: hasTaggedItems ? null : (droppedInbox!.suggestion?.summary ?? droppedInbox!.decryptedTitle),
            actionName: _getTitleForMcpFunction(context, 'replyMail'),
            icon: _getIconForMcpFunction('replyMail'),
            inbox: droppedInbox,
            onTap: () => onActionTap?.call('replyMail', inbox: droppedInbox!),
          ),
        );
        suggestions.add(
          McpActionSuggestion(
            mcpFunctionName: 'forwardMail',
            itemName: hasTaggedItems ? null : (droppedInbox!.suggestion?.summary ?? droppedInbox!.decryptedTitle),
            actionName: _getTitleForMcpFunction(context, 'forwardMail'),
            icon: _getIconForMcpFunction('forwardMail'),
            inbox: droppedInbox,
            onTap: () => onActionTap?.call('forwardMail', inbox: droppedInbox!),
          ),
        );
      }

      // linkedMessage가 있는 경우
      if (droppedInbox!.linkedMessage != null) {
        suggestions.add(
          McpActionSuggestion(
            mcpFunctionName: 'replyMessage',
            itemName: hasTaggedItems ? null : (droppedInbox!.suggestion?.summary ?? droppedInbox!.decryptedTitle),
            actionName: _getTitleForMcpFunction(context, 'replyMessage'),
            icon: _getIconForMcpFunction('replyMessage'),
            inbox: droppedInbox,
            onTap: () => onActionTap?.call('replyMessage', inbox: droppedInbox!),
          ),
        );
      }
    }

    return suggestions;
  }

  List<McpActionSuggestion> _generateSuggestions(BuildContext context, WidgetRef ref) {
    final suggestions = <McpActionSuggestion>[];

    // 드롭된 아이템 기반 suggested action 생성 (우선순위 높음)
    if (droppedInbox != null || droppedTask != null || droppedEvent != null) {
      final droppedSuggestions = _generateSuggestionsForDroppedItem(context, ref);
      suggestions.addAll(droppedSuggestions);
    }

    // 태그된 아이템이 있으면 기존 inbox list 기반 suggested action은 표시하지 않음
    if (hasTaggedItems) {
      return suggestions;
    }

    // Inbox 기반 액션 추천
    for (final inbox in inboxes) {
      final suggestion = inbox.suggestion;
      if (suggestion == null) continue;
      // if (inbox.isRead == true) continue;
      // if (inbox.linkedTask != null) continue;

      // MCP 함수 추천
      final recommendedFunctions = _getRecommendedMcpFunctions(suggestion, inbox);

      for (final functionName in recommendedFunctions) {
        final summary = suggestion.summary ?? '';
        String? itemName;

        // 질문의 경우 보낸 사람 정보 포함
        if (suggestion.reason == InboxSuggestionReason.question) {
          final senderName = suggestion.sender_name;
          if (summary.isNotEmpty) {
            if (senderName != null && senderName.isNotEmpty) {
              itemName = '$summary ($senderName)';
            } else {
              itemName = summary;
            }
          } else if (senderName != null && senderName.isNotEmpty) {
            itemName = senderName;
          }
        } else {
          itemName = summary.isNotEmpty ? summary : null;
        }

        suggestions.add(
          McpActionSuggestion(
            mcpFunctionName: functionName,
            itemName: itemName,
            actionName: _getTitleForMcpFunction(context, functionName),
            icon: _getIconForMcpFunction(functionName),
            inbox: inbox,
            onTap: () => onActionTap?.call(functionName, inbox: inbox),
          ),
        );
      }
    }

    // 중복 제거 및 최대 5개로 제한
    final uniqueSuggestions = <String, McpActionSuggestion>{};
    for (final suggestion in suggestions) {
      final key = '${suggestion.mcpFunctionName}_${suggestion.inbox?.id ?? suggestion.task?.id ?? suggestion.event?.eventId}';
      if (!uniqueSuggestions.containsKey(key)) {
        uniqueSuggestions[key] = suggestion;
      }
    }

    return uniqueSuggestions.values.take(5).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = _generateSuggestions(context, ref);

    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    if (!isRow) {
      return SelectionWidget(
        onSelect: (selection) {
          selection.onTap();
          Navigator.of(Utils.mainContext).maybePop();
        },
        items: suggestions,
        getTitleSpan: (suggestion) => TextSpan(
          children: [
            TextSpan(text: suggestion.actionName, style: context.bodyMedium?.textColor(context.onSurface).textBold),
            if (suggestion.itemName != null) ...[
              TextSpan(text: '\n', style: context.bodyMedium?.textColor(context.onSurface)),
              TextSpan(text: suggestion.itemName ?? '', style: context.bodySmall?.textColor(context.onSurface)),
            ],
          ],
        ),
      );
    }

    // 태그 높이 계산 (padding + icon + text + spacing)
    // const tagHeight = 6.0 + 6.0 + 12.0 + 6.0; // vertical padding + icon height + text height + spacing

    // 모바일에서는 가로 스크롤이므로 한 줄만 필요, 데스크톱에서는 여러 줄 가능
    // final maxHeight = tagHeight;

    // Helper function to get digit key for index (1-10)
    LogicalKeyboardKey _getDigitKeyForIndex(int index) {
      switch (index) {
        case 0:
          return LogicalKeyboardKey.digit1;
        case 1:
          return LogicalKeyboardKey.digit2;
        case 2:
          return LogicalKeyboardKey.digit3;
        case 3:
          return LogicalKeyboardKey.digit4;
        case 4:
          return LogicalKeyboardKey.digit5;
        case 5:
          return LogicalKeyboardKey.digit6;
        case 6:
          return LogicalKeyboardKey.digit7;
        case 7:
          return LogicalKeyboardKey.digit8;
        case 8:
          return LogicalKeyboardKey.digit9;
        case 9:
          return LogicalKeyboardKey.digit0;
        default:
          return LogicalKeyboardKey.digit1;
      }
    }

    final suggestionWidgets = suggestions.asMap().entries.map((entry) {
      final index = entry.key;
      final suggestion = entry.value;

      // Create keyboard shortcut for Option + (1-10)
      final digitKey = _getDigitKeyForIndex(index);

      return IntrinsicWidth(
        child: VisirButton(
          type: VisirButtonAnimationType.scaleAndOpacity,
          style: VisirButtonStyle(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            backgroundColor: context.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.outline.withValues(alpha: 0.2), width: 1),
          ),
          options: VisirButtonOptions(
            bypassTextField: true,
            shortcuts: [
              VisirButtonKeyboardShortcut(
                keys: [LogicalKeyboardKey.alt, digitKey],
                message: '',
                onTrigger: () {
                  suggestion.onTap();
                  return true;
                },
              ),
            ],
          ),
          onTap: suggestion.onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              VisirIcon(type: suggestion.icon, size: 12, color: context.onSurface, isSelected: true),
              const SizedBox(width: 6),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: [
                      if (suggestion.itemName != null) ...[
                        TextSpan(text: suggestion.itemName, style: context.bodySmall?.textColor(context.onSurface)),
                        TextSpan(text: ' · ', style: context.bodySmall?.textColor(context.onSurface)),
                      ],
                      TextSpan(text: suggestion.actionName, style: context.bodySmall?.textColor(context.onSurface).textBold),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.only(top: 8),
      width: double.maxFinite,
      constraints: null,
      child: Row(
        children: [
          // PopupMenu(
          //   type: ContextMenuActionType.tap,
          //   location: PopupMenuLocation.right,
          //   backgroundColor: Colors.transparent,
          //   forceShiftOffset: forceShiftOffsetForMenu,
          //   style: VisirButtonStyle(
          //     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          //     backgroundColor: context.surface.withValues(alpha: 0.7),
          //     borderRadius: BorderRadius.circular(16),
          //     margin: EdgeInsets.symmetric(horizontal: 12),
          //     border: Border.all(color: context.outline.withValues(alpha: 0.2), width: 1),
          //   ),
          //   popup: CustomActionPromptAddWidget(
          //     onSave: (title, prompt) {
          //       if (title.isNotEmpty || prompt.isNotEmpty) {
          //         onCustomPrompt?.call(title, prompt);
          //       }
          //     },
          //   ),
          //   hideShadow: true,
          //   child: VisirIcon(type: VisirIconType.add, size: 12, color: context.onSurface, isSelected: true),
          // ),
          // Container(
          //   width: 2,
          //   height: 24,
          //   decoration: BoxDecoration(color: context.outline, borderRadius: BorderRadius.circular(12)),
          // ),
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 12, right: 12),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [...suggestionWidgets.map((widget) => Padding(padding: const EdgeInsets.only(right: 6), child: widget))],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
