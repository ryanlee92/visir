import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons_full.dart';

enum InboxSuggestionUrgency { urgent, important, action_required, need_review, none }

enum InboxSuggestionDateType { task, event }

enum InboxSuggestionReason {
  meeting_invitation,
  meeting_followup,
  meeting_notes,
  task_assignment,
  task_status_update,
  scheduling_request,
  scheduling_confirmation,
  document_review,
  code_review,
  approval_request,
  question,
  information_sharing,
  announcement,
  system_notification,
  cold_contact,
  customer_contact,
  other,
}

extension InboxSuggestionReasonExtension on InboxSuggestionReason {
  String get title {
    final context = Utils.mainContext.mounted ? Utils.mainContext : null;
    if (context == null) return '';

    final localizations = AppLocalizations.of(context);
    if (localizations == null) return '';

    switch (this) {
      case InboxSuggestionReason.meeting_invitation:
        return localizations.ai_suggestion_reason_meeting_invitation;
      case InboxSuggestionReason.meeting_followup:
        return localizations.ai_suggestion_reason_meeting_followup;
      case InboxSuggestionReason.meeting_notes:
        return localizations.ai_suggestion_reason_meeting_notes;
      case InboxSuggestionReason.task_assignment:
        return localizations.ai_suggestion_reason_task_assignment;
      case InboxSuggestionReason.task_status_update:
        return localizations.ai_suggestion_reason_task_status_update;
      case InboxSuggestionReason.scheduling_request:
        return localizations.ai_suggestion_reason_scheduling_request;
      case InboxSuggestionReason.scheduling_confirmation:
        return localizations.ai_suggestion_reason_scheduling_confirmation;
      case InboxSuggestionReason.document_review:
        return localizations.ai_suggestion_reason_document_review;
      case InboxSuggestionReason.code_review:
        return localizations.ai_suggestion_reason_code_review;
      case InboxSuggestionReason.approval_request:
        return localizations.ai_suggestion_reason_approval_request;
      case InboxSuggestionReason.question:
        return localizations.ai_suggestion_reason_question;
      case InboxSuggestionReason.information_sharing:
        return localizations.ai_suggestion_reason_information_sharing;
      case InboxSuggestionReason.announcement:
        return localizations.ai_suggestion_reason_announcement;
      case InboxSuggestionReason.system_notification:
        return localizations.ai_suggestion_reason_system_notification;
      case InboxSuggestionReason.cold_contact:
        return localizations.ai_suggestion_reason_cold_contact;
      case InboxSuggestionReason.customer_contact:
        return localizations.ai_suggestion_reason_customer_contact;
      case InboxSuggestionReason.other:
        return localizations.ai_suggestion_reason_other;
    }
  }

  /// Returns the HugeIcon icon for this reason.
  dynamic get icon {
    switch (this) {
      case InboxSuggestionReason.meeting_invitation:
        return HugeIcons.solidRoundedCalendar03;
      case InboxSuggestionReason.meeting_followup:
        return HugeIcons.solidRoundedArrowRight01;
      case InboxSuggestionReason.meeting_notes:
        return HugeIcons.solidRoundedLicense;
      case InboxSuggestionReason.task_assignment:
        return HugeIcons.solidRoundedCheckmarkCircle01;
      case InboxSuggestionReason.task_status_update:
        return HugeIcons.solidRoundedRefresh;
      case InboxSuggestionReason.scheduling_request:
        return HugeIcons.solidRoundedCalendarAdd01;
      case InboxSuggestionReason.scheduling_confirmation:
        return HugeIcons.solidRoundedCheckmarkCircle02;
      case InboxSuggestionReason.document_review:
        return HugeIcons.solidRoundedDocumentAttachment;
      case InboxSuggestionReason.code_review:
        return HugeIcons.solidRoundedSourceCode;
      case InboxSuggestionReason.approval_request:
        return HugeIcons.solidRoundedCheckmarkSquare02;
      case InboxSuggestionReason.question:
        return HugeIcons.solidRoundedHelpCircle;
      case InboxSuggestionReason.information_sharing:
        return HugeIcons.solidRoundedShare05;
      case InboxSuggestionReason.announcement:
        return HugeIcons.solidRoundedNotificationSquare;
      case InboxSuggestionReason.system_notification:
        return HugeIcons.solidRoundedNotification01;
      case InboxSuggestionReason.cold_contact:
        return HugeIcons.solidRoundedUser;
      case InboxSuggestionReason.customer_contact:
        return HugeIcons.solidRoundedUserGroup;
      case InboxSuggestionReason.other:
        return HugeIcons.solidRoundedMoreHorizontalCircle02;
    }
  }

  /// Returns the color for this reason's icon.
  Color get iconColor {
    switch (this) {
      // High priority - urgent colors
      case InboxSuggestionReason.meeting_invitation:
        return Utils.mainContext.error; // Red for urgent
      case InboxSuggestionReason.scheduling_request:
        return Utils.mainContext.error; // Red for urgent
      case InboxSuggestionReason.approval_request:
        return Utils.mainContext.primary; // Blue for action required
      case InboxSuggestionReason.customer_contact:
        return Utils.mainContext.primary; // Blue for important
      case InboxSuggestionReason.question:
        return Utils.mainContext.primary; // Blue for action required
      case InboxSuggestionReason.task_assignment:
        return Utils.mainContext.primaryContainer; // Purple for important
      case InboxSuggestionReason.code_review:
        return Utils.mainContext.tertiary; // Teal for review
      case InboxSuggestionReason.document_review:
        return Utils.mainContext.tertiary; // Teal for review
      // Medium priority
      case InboxSuggestionReason.scheduling_confirmation:
        return Utils.mainContext.tertiary; // Teal for review
      case InboxSuggestionReason.meeting_followup:
        return Utils.mainContext.tertiary; // Teal for review
      // Lower priority - informational
      case InboxSuggestionReason.task_status_update:
        return Utils.mainContext.onSurfaceVariant; // Gray for informational
      case InboxSuggestionReason.meeting_notes:
        return Utils.mainContext.onSurfaceVariant; // Gray for informational
      case InboxSuggestionReason.information_sharing:
        return Utils.mainContext.onSurfaceVariant; // Gray for informational
      case InboxSuggestionReason.announcement:
        return Utils.mainContext.onSurfaceVariant; // Gray for informational
      case InboxSuggestionReason.system_notification:
        return Utils.mainContext.onSurfaceVariant; // Gray for informational
      case InboxSuggestionReason.cold_contact:
        return Utils.mainContext.onSurfaceVariant; // Gray for low priority
      case InboxSuggestionReason.other:
        return Utils.mainContext.onSurfaceVariant; // Gray for other
    }
  }

  /// Returns the weight/priority of this reason.
  /// Lower values indicate higher priority (should not be missed).
  /// Higher values indicate lower priority (can be deferred).
  int get weight {
    switch (this) {
      // Highest priority - must respond/act
      case InboxSuggestionReason.meeting_invitation:
        return 0; // Meeting invitations require response
      case InboxSuggestionReason.scheduling_request:
        return 1; // Scheduling requests require response
      case InboxSuggestionReason.approval_request:
        return 2; // Approval requests require action
      case InboxSuggestionReason.customer_contact:
        return 3; // Customer inquiries require response
      case InboxSuggestionReason.question:
        return 4; // Questions require answers
      case InboxSuggestionReason.task_assignment:
        return 5; // Task assignments need acknowledgment
      case InboxSuggestionReason.code_review:
        return 6; // Code reviews need attention
      case InboxSuggestionReason.document_review:
        return 7; // Document reviews need attention

      // Medium priority - should review
      case InboxSuggestionReason.scheduling_confirmation:
        return 8; // Scheduling confirmations should be reviewed
      case InboxSuggestionReason.meeting_followup:
        return 9; // Meeting follow-ups should be reviewed

      // Lower priority - informational
      case InboxSuggestionReason.task_status_update:
        return 10; // Task status updates are informational
      case InboxSuggestionReason.meeting_notes:
        return 11; // Meeting notes are informational
      case InboxSuggestionReason.information_sharing:
        return 12; // Information sharing is informational
      case InboxSuggestionReason.announcement:
        return 13; // Announcements are informational
      case InboxSuggestionReason.system_notification:
        return 14; // System notifications are informational
      case InboxSuggestionReason.cold_contact:
        return 15; // Cold contacts are low priority
      case InboxSuggestionReason.other:
        return 16; // Other items are lowest priority
    }
  }
}

extension InboxSuggestionUrgencyExtension on InboxSuggestionUrgency {
  Color get color {
    switch (this) {
      case InboxSuggestionUrgency.urgent:
        return Utils.mainContext.error;
      case InboxSuggestionUrgency.important:
        return Utils.mainContext.primaryContainer;
      case InboxSuggestionUrgency.action_required:
        return Utils.mainContext.primary;
      case InboxSuggestionUrgency.need_review:
        return Utils.mainContext.tertiary;
      case InboxSuggestionUrgency.none:
        return Colors.transparent;
    }
  }

  Color get textColor {
    switch (this) {
      case InboxSuggestionUrgency.urgent:
        return Utils.mainContext.onError;
      case InboxSuggestionUrgency.important:
        return Utils.mainContext.onPrimaryContainer;
      case InboxSuggestionUrgency.action_required:
        return Utils.mainContext.onPrimary;
      case InboxSuggestionUrgency.need_review:
        return Utils.mainContext.onTertiary;
      case InboxSuggestionUrgency.none:
        return Utils.mainContext.onTertiary;
    }
  }

  String get title {
    final context = Utils.mainContext.mounted ? Utils.mainContext : null;
    if (context == null) return '';

    final localizations = AppLocalizations.of(context);
    if (localizations == null) return '';

    switch (this) {
      case InboxSuggestionUrgency.urgent:
        return localizations.ai_suggestion_urgency_urgent;
      case InboxSuggestionUrgency.important:
        return localizations.ai_suggestion_urgency_important;
      case InboxSuggestionUrgency.action_required:
        return localizations.ai_suggestion_urgency_action_required;
      case InboxSuggestionUrgency.need_review:
        return localizations.ai_suggestion_urgency_need_review;
      case InboxSuggestionUrgency.none:
        return '';
    }
  }

  int get priority {
    switch (this) {
      case InboxSuggestionUrgency.urgent:
        return 0;
      case InboxSuggestionUrgency.important:
        return 1;
      case InboxSuggestionUrgency.action_required:
        return 2;
      case InboxSuggestionUrgency.need_review:
        return 3;
      case InboxSuggestionUrgency.none:
        return 4;
    }
  }
}

class InboxSuggestionEntity {
  final String id;
  final String? summary;
  final InboxSuggestionUrgency urgency;
  final InboxSuggestionReason reason;
  final InboxSuggestionDateType? date_type;
  final String? reasoned_body;
  final String? conversation_summary; // Summary of conversation content
  final DateTime? target_date;
  final int? duration;
  final bool? is_asap;
  final bool? is_date_only;
  final String? project_id;
  final int? estimated_effort; // in minutes
  final String? sender_name;
  final int? priority_score; // 0-100
  final bool isEncrypted; // 암호화 여부 플래그

  InboxSuggestionEntity({
    required this.id,
    this.summary,
    required this.urgency,
    required this.reason,
    this.reasoned_body,
    this.conversation_summary,
    this.target_date,
    this.date_type,
    this.duration,
    this.is_asap,
    this.is_date_only,
    this.project_id,
    this.estimated_effort,
    this.sender_name,
    this.priority_score,
    this.isEncrypted = false, // 기본값은 false (기존 데이터 호환)
  });

  factory InboxSuggestionEntity.fromJson(Map<String, dynamic> json, {bool? local}) {
    final isEncrypted = json['is_encrypted'] as bool? ?? false;
    // 암호화된 데이터 자동 감지: base64로 디코딩하면 "Salted__"로 시작함
    bool isEncryptedData(String? value) {
      if (value == null || value.isEmpty) return false;
      try {
        final decoded = base64Decode(value);
        return decoded.length >= 8 && String.fromCharCodes(decoded.take(8)) == 'Salted__';
      } catch (e) {
        return false;
      }
    }

    // local이 true여도 이미 암호화된 데이터가 저장되어 있을 수 있으므로 항상 확인
    // 실제 데이터가 암호화되어 있으면 복호화 시도
    String? decryptField(String? value) {
      if (value == null || value.isEmpty) return value;
      // 암호화된 데이터인지 확인하고 복호화
      if (isEncryptedData(value)) {
        try {
          return Utils.decryptAESCryptoJS(value, aesKey);
        } catch (e) {
          return value; // 복호화 실패 시 원본 반환
        }
      }
      return value;
    }

    final suggestion = InboxSuggestionEntity(
      id: json['id'],
      summary: decryptField(json['summary'] as String?),
      date_type: InboxSuggestionDateType.values.firstWhere((e) => e.name == json['date_type']),
      urgency: InboxSuggestionUrgency.values.firstWhere((e) => e.name == json['urgency']),
      reason: InboxSuggestionReason.values.firstWhere((e) => e.name == json['reason']),
      reasoned_body: decryptField(json['reasoned_body'] as String?),
      conversation_summary: decryptField(json['conversation_summary'] as String?),
      is_asap: json['is_asap'],
      duration: json['duration'],
      is_date_only: json['is_date_only'],
      project_id: json['project_id'],
      estimated_effort: json['estimated_effort'],
      sender_name: decryptField(json['sender_name'] as String?),
      priority_score: json['priority_score'],
      isEncrypted: isEncrypted,
      target_date: json['target_date'] == null
          ? null
          : json['target_date'] == 'ASAP'
          ? DateTime(1000)
          : DateTime.tryParse(json['is_date_only'] != true ? json['target_date'] : '${json['target_date']}T00:00:00')?.toLocal(),
    );
    return suggestion;
  }

  Map<String, dynamic> toJson({bool? local}) {
    String? encryptField(String? value) {
      if (value == null || value.isEmpty) return value;
      if (local == true) return value; // 로컬 저장소는 평문
      return Utils.encryptAESCryptoJS(value, aesKey);
    }

    return {
      'id': id,
      'summary': encryptField(summary),
      'urgency': urgency.name,
      'reason': reason.name,
      'date_type': date_type?.name,
      'duration': duration,
      'reasoned_body': encryptField(reasoned_body),
      'conversation_summary': encryptField(conversation_summary),
      'target_date': target_date?.toIso8601String(),
      'is_asap': is_asap,
      'is_date_only': is_date_only,
      'project_id': project_id,
      'estimated_effort': estimated_effort,
      'sender_name': encryptField(sender_name),
      'priority_score': priority_score,
      'is_encrypted': local != true, // 로컬이 아니면 암호화됨
    };
  }

  InboxSuggestionEntity copyWith({
    String? id,
    String? summary,
    InboxSuggestionUrgency? urgency,
    InboxSuggestionReason? reason,
    String? reasoned_body,
    String? conversation_summary,
    DateTime? target_date,
    InboxSuggestionDateType? date_type,
    int? duration,
    bool? is_asap,
    bool? is_date_only,
    String? project_id,
    int? estimated_effort,
    String? sender_name,
    int? priority_score,
    bool? isEncrypted,
  }) {
    return InboxSuggestionEntity(
      id: id ?? this.id,
      summary: summary ?? this.summary,
      urgency: urgency ?? this.urgency,
      reason: reason ?? this.reason,
      reasoned_body: reasoned_body ?? this.reasoned_body,
      conversation_summary: conversation_summary ?? this.conversation_summary,
      target_date: target_date ?? this.target_date,
      date_type: date_type ?? this.date_type,
      duration: duration ?? this.duration,
      is_asap: is_asap ?? this.is_asap,
      is_date_only: is_date_only ?? this.is_date_only,
      project_id: project_id ?? this.project_id,
      estimated_effort: estimated_effort ?? this.estimated_effort,
      sender_name: sender_name ?? this.sender_name,
      priority_score: priority_score ?? this.priority_score,
      isEncrypted: isEncrypted ?? this.isEncrypted,
    );
  }

  bool get isASAP => is_asap == true;
  bool get isAllDay => is_date_only == true;

  // summary가 암호화되어 있을 수 있으므로 복호화하여 반환
  String? get decryptedSummary {
    if (summary == null || summary!.isEmpty) return summary;
    // 암호화된 데이터 자동 감지
    // CryptoJS로 암호화된 데이터는 base64로 인코딩되어 있고, 디코딩하면 "Salted__"로 시작함
    bool isEncryptedData(String value) {
      if (value.isEmpty) return false;
      // base64 문자열 형식 확인 (길이가 충분하고 base64 문자만 포함)
      if (value.length < 16) return false; // 암호화된 데이터는 최소 길이가 있음
      // base64 디코딩 시도
      try {
        final decoded = base64Decode(value);
        if (decoded.length >= 8) {
          final header = String.fromCharCodes(decoded.take(8));
          return header == 'Salted__';
        }
      } catch (e) {
        // base64 디코딩 실패 시 평문으로 간주
        return false;
      }
      return false;
    }

    if (isEncryptedData(summary!)) {
      try {
        String decrypted = Utils.decryptAESCryptoJS(summary!, aesKey);

        // 복호화된 결과가 여전히 암호화된 형식인지 확인 (중첩 암호화 처리)
        // base64 디코딩을 시도하지 않고, 길이와 시작 문자열만 확인
        bool isStillEncrypted = decrypted.length >= 16 && decrypted.startsWith('U2FsdGVkX1') && (decrypted.length % 4 == 0 || decrypted.length % 4 == 1); // base64 길이 패턴

        if (isStillEncrypted) {
          try {
            // 실제로 base64 디코딩이 가능한지 확인
            final testDecoded = base64Decode(decrypted);
            if (testDecoded.length >= 8 && String.fromCharCodes(testDecoded.take(8)) == 'Salted__') {
              decrypted = Utils.decryptAESCryptoJS(decrypted, aesKey);
            }
          } catch (e) {
            // base64 디코딩 실패 = 평문이므로 첫 번째 복호화 결과 반환
          }
        }

        return decrypted;
      } catch (e) {
        return summary; // 복호화 실패 시 원본 반환
      }
    }
    return summary;
  }
}

class InboxSuggestionFetchListEntity {
  List<InboxSuggestionEntity> suggestions;
  int? sequence;

  InboxSuggestionFetchListEntity({required this.suggestions, this.sequence});

  factory InboxSuggestionFetchListEntity.fromJson(Map<String, dynamic> json, {bool? local}) {
    return InboxSuggestionFetchListEntity(
      suggestions: (json['suggestions'] as List?)?.map((e) => InboxSuggestionEntity.fromJson(e as Map<String, dynamic>, local: local)).toList() ?? [],
      sequence: json['sequence'],
    );
  }

  Map<String, dynamic> toJson({bool? local}) {
    return {'suggestions': suggestions.map((e) => e.toJson(local: local)).toList(), 'sequence': sequence};
  }
}
