import 'dart:convert';

import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/mail/domain/entities/mail_file_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_user_entity.dart';
import 'package:Visir/features/mail/infrastructure/models/outlook_mail_message.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/gmail/v1.dart' as Gmail;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:microsoft_graph_api/models/models.dart' as Ms;

enum MailEntityType { google, microsoft }

extension MailEntityTypeX on MailEntityType {
  DatasourceType get datasourceType {
    switch (this) {
      case MailEntityType.google:
        return DatasourceType.google;
      case MailEntityType.microsoft:
        return DatasourceType.microsoft;
    }
  }

  String get title {
    switch (this) {
      case MailEntityType.google:
        return 'Gmail';
      case MailEntityType.microsoft:
        return 'Outlook';
    }
  }

  String get icon {
    switch (this) {
      case MailEntityType.google:
        return '${(kDebugMode && kIsWeb) ? "" : "assets/"}logos/logo_gmail.png';
      case MailEntityType.microsoft:
        return '${(kDebugMode && kIsWeb) ? "" : "assets/"}logos/logo_outlook.png';
    }
  }

  OAuthType get oAuthType {
    switch (this) {
      case MailEntityType.google:
        return OAuthType.google;
      case MailEntityType.microsoft:
        return OAuthType.microsoft;
    }
  }

  static MailEntityType fromOAuthType(OAuthType type) {
    switch (type) {
      case OAuthType.google:
        return MailEntityType.google;
      case OAuthType.microsoft:
        return MailEntityType.microsoft;
      case OAuthType.apple:
        throw UnimplementedError();
      case OAuthType.slack:
        throw UnimplementedError();
      case OAuthType.discord:
        throw UnimplementedError();
    }
  }
}

class TempMailEntity {
  final String id;
  final String hostEmail;
  final List<String> labelIds;

  TempMailEntity({required this.id, required this.hostEmail, required this.labelIds});
}

class MailEntity {
  // for gmail
  final Gmail.Message? _gmailMessage;
  final List<Gmail.Message>? _gmailThreads;

  final OutlookMailMessage? _msMessage;
  final List<OutlookMailMessage>? _msThreads;
  String? _pageToken;

  bool get isSignedIn => Utils.ref.read(isSignedInProvider);

  // common
  final MailEntityType type;
  final String hostEmail;
  final String? _draftId;
  final String? _draftSubject;
  final String? _draftHtml;

  final DateTime? _localUpdatedAt;

  String? get draftSubject => _draftSubject;

  MailEntity.fromGmail({
    Gmail.Message? message,
    List<Gmail.Message>? thread,
    required this.hostEmail,
    String? pageToken,
    String? draftId,
    DateTime? localUpdatedAt,
  }) : _gmailMessage = message,
       _gmailThreads = thread,
       _msMessage = null,
       _msThreads = null,
       _pageToken = pageToken,
       _draftId = draftId,
       _draftSubject = null,
       _draftHtml = null,
       _localUpdatedAt = localUpdatedAt,
       type = MailEntityType.google;

  MailEntity.fromOutlook({
    OutlookMailMessage? message,
    List<OutlookMailMessage>? thread,
    required this.hostEmail,
    String? pageToken,
    String? draftId,
    DateTime? localUpdatedAt,
  }) : _msMessage = message,
       _msThreads = thread,
       _gmailMessage = null,
       _gmailThreads = null,
       _pageToken = pageToken,
       _draftId = draftId,
       _draftSubject = null,
       _draftHtml = null,
       _localUpdatedAt = localUpdatedAt,
       type = MailEntityType.microsoft;

  Gmail.Message? get gmailMessage => _gmailMessage;

  Map<String, dynamic> toJson() {
    final data = {
      '_gmailMessage': _gmailMessage?.toMap(),
      '_gmailThreads': _gmailThreads?.map((e) => e.toMap()).toList(),
      '_msMessage': _msMessage?.toJson(),
      '_msThreads': _msThreads?.map((e) => e.toJson()).toList(),
      '_pageToken': _pageToken,
      "_draftId": _draftId,
      'type': type.name,
      'hostEmail': hostEmail,
    };
    return data;
  }

  MailEntity({
    required MailEntityType mailType,
    required MailUserEntity from,
    required String? messageId,
    required String? threadId,
    required String? draftId,
    required MimeMessage? mimeMessage,
    required String? subject,
    String? draftHtml,
  }) : type = mailType,
       hostEmail = from.email,
       _draftId = draftId,
       _draftHtml = draftHtml,
       _gmailThreads = null,
       _localUpdatedAt = null,
       _draftSubject = subject,
       _gmailMessage = mailType == MailEntityType.google
           ? Gmail.Message(
               id: messageId,
               threadId: threadId,
               raw: mimeMessage != null ? utf8.fuse(base64).encode(mimeMessage.renderMessage()) : null,
               payload: Gmail.MessagePart(
                 headers: [Gmail.MessagePartHeader(name: 'Subject', value: mimeMessage?.getHeaderValue('subject') ?? subject)],
               ),
             )
           : null,
       _msMessage = mailType == MailEntityType.microsoft
           ? OutlookMailMessage(
               id: messageId,
               subject: subject,
               from: Ms.Recipient(
                 emailAddress: Ms.EmailAddress(address: from.email, name: from.name),
               ),
               body: Ms.ItemBody(content: mimeMessage?.decodeTextHtmlPart(), contentType: 'html'),
               attachments: ((mimeMessage?.hasAttachments() ?? false) || (mimeMessage?.hasInlineParts() ?? false))
                   ? [
                       if (mimeMessage?.hasAttachments() ?? false)
                         ...mimeMessage!
                             .findContentInfo(disposition: ContentDisposition.attachment)
                             .map(
                               (e) => Ms.Attachment(
                                 id: e.fetchId,
                                 name: e.fileName,
                                 contentType: e.contentType?.value,
                                 size: e.size,
                                 isInline: false,
                                 contentId: e.cid?.replaceAll('<', '').replaceAll('>', ''),
                                 contentBytes: (mimeMessage.getPart(e.fetchId)?.mimeData as TextMimeData?)?.text,
                               ),
                             )
                             .toList(),
                       if (mimeMessage?.hasInlineParts() ?? false)
                         ...mimeMessage!.findContentInfo(disposition: ContentDisposition.inline).map((e) {
                           return Ms.Attachment(
                             id: e.fetchId,
                             name: e.fileName,
                             contentType: e.contentType?.value,
                             size: e.size,
                             isInline: true,
                             contentId: e.cid?.replaceAll('<', '').replaceAll('>', ''),
                             contentBytes: (mimeMessage.getPart(e.fetchId)?.mimeData as TextMimeData?)?.text,
                           );
                         }).toList(),
                     ]
                   : null,
               hasAttachments: ((mimeMessage?.hasAttachments() ?? false) || (mimeMessage?.hasInlineParts() ?? false)),
               toRecipients: mimeMessage?.to?.map((e) => Ms.Recipient(emailAddress: Ms.EmailAddress(address: e.email))).toList() ?? [],
               ccRecipients: mimeMessage?.cc?.map((e) => Ms.Recipient(emailAddress: Ms.EmailAddress(address: e.email))).toList() ?? [],
               bccRecipients: mimeMessage?.bcc?.map((e) => Ms.Recipient(emailAddress: Ms.EmailAddress(address: e.email))).toList() ?? [],
             )
           : null,
       _msThreads = null;

  OutlookMailMessage? get msMessage => _msMessage;

  factory MailEntity.fromJson(Map<String, dynamic> json) {
    MailEntityType mailType = MailEntityType.values.firstWhere((e) => e.name == json['type'], orElse: () => MailEntityType.google);

    if (mailType == MailEntityType.google) {
      return MailEntity.fromGmail(
        message: json['_gmailMessage'] == null ? null : Gmail.Message.fromJson(json['_gmailMessage']),
        thread: (json['_gmailThreads'] ?? []).map((e) => Gmail.Message.fromJson(e)).whereType<Gmail.Message>().toList(),
        hostEmail: json['hostEmail'],
        pageToken: json['_pageToken'],
        draftId: json['_draftId'],
      );
    } else if (mailType == MailEntityType.microsoft) {
      return MailEntity.fromOutlook(
        message: json['_msMessage'] == null ? null : OutlookMailMessage.fromJson(json['_msMessage']),
        thread: (json['_msThreads'] ?? []).map((e) => OutlookMailMessage.fromJson(e)).whereType<OutlookMailMessage>().toList(),
        hostEmail: json['hostEmail'],
        pageToken: json['_pageToken'],
        draftId: json['_draftId'],
      );
    }

    throw UnimplementedError();
  }

  DateTime? get localUpdatedAt => _localUpdatedAt;

  String? get html {
    switch (type) {
      case MailEntityType.google:
        if (_draftHtml != null) {
          return _draftHtml;
        }

        if (_gmailMessage?.payload?.headers?.length == 1 && _gmailMessage?.raw != null) {
          final decodedBytes = base64.decode(_gmailMessage!.raw!);
          final decodedString = utf8.decode(decodedBytes);
          final message = MimeMessage.parseFromText(decodedString);
          final html = message.decodeTextHtmlPart();
          if (html == null) return null;
          return html;
        }

        String list = '';
        if (_gmailMessage?.payload?.body?.data != null) {
          list += utf8.decode(_gmailMessage!.payload!.body!.dataAsBytes);
        }
        if (_gmailMessage?.payload?.parts != null) {
          list += addParts(_gmailMessage!.payload!.parts!, list);
        }

        if (list.isNotEmpty) {
          return list;
        }

        return '';
      case MailEntityType.microsoft:
        return _msMessage?.body?.content;
    }
  }

  String? get pageToken {
    switch (type) {
      case MailEntityType.google:
        return _pageToken;
      case MailEntityType.microsoft:
        return _pageToken;
    }
  }

  String? get id {
    switch (type) {
      case MailEntityType.google:
        return _gmailMessage?.id;
      case MailEntityType.microsoft:
        return _msMessage?.id;
    }
  }

  String? get threadId {
    switch (type) {
      case MailEntityType.google:
        return _gmailMessage?.threadId ?? _gmailThreads?.firstOrNull?.threadId;
      case MailEntityType.microsoft:
        return _msMessage?.conversationId ?? _msThreads?.firstOrNull?.conversationId ?? _msMessage?.id;
    }
  }

  String? get uniqueId {
    switch (type) {
      case MailEntityType.google:
        return _draftId ?? _gmailMessage?.threadId ?? _gmailMessage!.id!;
      case MailEntityType.microsoft:
        return _draftId ?? _msMessage?.conversationId ?? _msMessage?.id;
    }
  }

  String? get deliveredTo {
    switch (type) {
      case MailEntityType.google:
        return _gmailMessage?.payload?.headers?.where((element) => element.name?.toLowerCase() == 'delivered-to').firstOrNull?.value;
      case MailEntityType.microsoft:
        return _msMessage?.toRecipients?.map((e) => e.emailAddress?.address).join(',');
    }
  }

  String? get received {
    switch (type) {
      case MailEntityType.google:
        return date?.toIso8601String();
      case MailEntityType.microsoft:
        return date?.toIso8601String();
    }
  }

  List<MailUserEntity> get to {
    switch (type) {
      case MailEntityType.google:
        if (_gmailMessage?.payload?.headers?.length == 1 && _gmailMessage?.raw != null) {
          final decodedBytes = base64.decode(_gmailMessage!.raw!);
          final decodedString = utf8.decode(decodedBytes);
          final message = MimeMessage.parseFromText(decodedString);
          final address = message.to;
          if (address == null) return [];
          return address.map((e) => MailUserEntity(email: e.email, name: e.personalName)).toList();
        }
        String? value = _gmailMessage?.payload?.headers?.where((element) => element.name?.toLowerCase() == 'to').firstOrNull?.value;
        List<String> mails = value?.split(',').toList() ?? [];
        return mails
            .map((s) {
              final email = extractEmailsFromString(s).firstOrNull;
              if (email == null) return null;
              final name = s.replaceAll('<${email}>', '').replaceAll('"', '').trimRight();
              return MailUserEntity(email: email.trim(), name: name.trim());
            })
            .whereType<MailUserEntity>()
            .toList();
      case MailEntityType.microsoft:
        return _msMessage?.toRecipients?.map((e) => MailUserEntity(email: e.emailAddress?.address ?? '', name: e.emailAddress?.name ?? '')).toList() ?? [];
    }
  }

  List<MailUserEntity> get cc {
    switch (type) {
      case MailEntityType.google:
        String? value = _gmailMessage?.payload?.headers?.where((element) => element.name?.toLowerCase() == 'cc').firstOrNull?.value;
        List<String> mails = value?.split(',').toList() ?? [];
        return mails
            .map((s) {
              if (_gmailMessage?.payload?.headers?.length == 1 && _gmailMessage?.raw != null) {
                final decodedBytes = base64.decode(_gmailMessage!.raw!);
                final decodedString = utf8.decode(decodedBytes);
                final message = MimeMessage.parseFromText(decodedString);
                final address = message.cc;
                if (address == null) return null;
                return address.map((e) => MailUserEntity(email: e.email, name: e.personalName)).toList();
              }
              final email = extractEmailsFromString(s).firstOrNull;
              if (email == null) return null;
              final name = s.replaceAll('<${email}>', '').replaceAll('"', '').trimRight();
              return MailUserEntity(email: email.trim(), name: name.trim());
            })
            .whereType<MailUserEntity>()
            .toList();
      case MailEntityType.microsoft:
        return _msMessage?.ccRecipients?.map((e) => MailUserEntity(email: e.emailAddress?.address ?? '', name: e.emailAddress?.name ?? '')).toList() ?? [];
    }
  }

  List<MailUserEntity> get bcc {
    switch (type) {
      case MailEntityType.google:
        String? value = _gmailMessage?.payload?.headers?.where((element) => element.name?.toLowerCase() == 'bcc').firstOrNull?.value;
        List<String> mails = value?.split(',').toList() ?? [];
        return mails
            .map((s) {
              if (_gmailMessage?.payload?.headers?.length == 1 && _gmailMessage?.raw != null) {
                final decodedBytes = base64.decode(_gmailMessage!.raw!);
                final decodedString = utf8.decode(decodedBytes);
                final message = MimeMessage.parseFromText(decodedString);
                final address = message.bcc;
                if (address == null) return null;
                return address.map((e) => MailUserEntity(email: e.email, name: e.personalName)).toList();
              }
              final email = extractEmailsFromString(s).firstOrNull;
              if (email == null) return null;
              final name = s.replaceAll('<${email}>', '').replaceAll('"', '').trimRight();
              return MailUserEntity(email: email.trim(), name: name.trim());
            })
            .whereType<MailUserEntity>()
            .toList();
      case MailEntityType.microsoft:
        return _msMessage?.bccRecipients?.map((e) => MailUserEntity(email: e.emailAddress?.address ?? '', name: e.emailAddress?.name ?? '')).toList() ?? [];
    }
  }

  MailUserEntity? get from {
    switch (type) {
      case MailEntityType.google:
        if (_gmailMessage?.payload?.headers?.length == 1 && _gmailMessage?.raw != null) {
          final decodedBytes = base64.decode(_gmailMessage!.raw!);
          final decodedString = utf8.decode(decodedBytes);
          final message = MimeMessage.parseFromText(decodedString);
          final address = message.from?.firstOrNull;
          if (address == null) return null;
          return MailUserEntity(email: address.email, name: address.personalName);
        }
        String? value = _gmailMessage?.payload?.headers?.where((element) => element.name?.toLowerCase() == 'from').firstOrNull?.value;
        if (value == null) return null;
        final email = extractEmailsFromString(value).firstOrNull;
        if (email == null) return null;
        final name = value.replaceAll('<${email}>', '').replaceAll('"', '').trimRight();
        return MailUserEntity(email: email, name: name.isEmpty ? null : name, type: type);
      case MailEntityType.microsoft:
        return MailUserEntity(email: _msMessage?.from?.emailAddress?.address ?? '', name: _msMessage?.from?.emailAddress?.name ?? '');
    }
  }

  List<MailUserEntity> get threadFrom {
    switch (type) {
      case MailEntityType.google:
        final mails =
            _gmailThreads?.map((t) => t.payload?.headers?.where((element) => element.name?.toLowerCase() == 'from').firstOrNull?.value).toList() ?? [];

        final result = mails
            .map((value) {
              if (value == null) return null;
              final email = extractEmailsFromString(value).firstOrNull;
              if (email == null) return null;
              final name = value.replaceAll('<${email}>', '').replaceAll('"', '').trimRight();
              return MailUserEntity(email: email, name: name.isEmpty ? null : name);
            })
            .whereType<MailUserEntity>()
            .toList();
        return result;
      case MailEntityType.microsoft:
        return _msThreads?.map((t) => MailUserEntity(email: t.from?.emailAddress?.address ?? '', name: t.from?.emailAddress?.name ?? '')).toList() ?? [];
    }
  }

  int get threadCount {
    switch (type) {
      case MailEntityType.google:
        return _gmailThreads?.length ?? 0;
      case MailEntityType.microsoft:
        return _msThreads?.length ?? 0;
    }
  }

  DateTime? get threadLastDate {
    switch (type) {
      case MailEntityType.google:
        final rs = _gmailMessage?.payload?.headers?.where((element) => element.name?.toLowerCase() == 'received').firstOrNull?.value;
        final r = rs?.split(';').lastOrNull?.trim();
        DateTime? receivedDate = DateCodec.decodeDate(r);
        if (receivedDate == null && r != null) {
          try {
            receivedDate = DateTime.parse(r);
          } catch (e) {}
        }

        if (receivedDate != null) return receivedDate;

        final d = _gmailMessage?.payload?.headers?.where((element) => element.name?.toLowerCase() == 'date').firstOrNull?.value;
        DateTime? threadDate = DateCodec.decodeDate(d);
        if (threadDate == null && d != null) {
          try {
            threadDate = DateTime.parse(d);
          } catch (e) {}
        }

        if (!isSignedIn) {
          if (threadDate == null) return null;
          final newDate = threadDate.add(mailDateOffset);
          if (newDate.isAfter(DateTime.now())) return DateTime.now();
          return newDate;
        }
        return threadDate;
      case MailEntityType.microsoft:
        final threadDate = _msThreads?.map((t) => t.receivedDateTime).whereType<DateTime>().toList().lastOrNull;
        if (!isSignedIn) {
          if (threadDate == null) return null;
          final newDate = threadDate.add(mailDateOffset);
          if (newDate.isAfter(DateTime.now())) return DateTime.now();
          return newDate;
        }
        return threadDate;
    }
  }

  DateTime? get threadLastDateIncludeSelf {
    switch (type) {
      case MailEntityType.google:
        final rs = _gmailMessage?.payload?.headers?.where((element) => element.name?.toLowerCase() == 'received').firstOrNull?.value;
        final r = rs?.split(';').lastOrNull?.trim();
        DateTime? receivedDate = DateCodec.decodeDate(r);
        if (receivedDate == null && r != null) {
          try {
            receivedDate = DateTime.parse(r);
          } catch (e) {}
        }

        if (receivedDate != null) return receivedDate;

        final d = _gmailMessage?.payload?.headers?.where((element) => element.name?.toLowerCase() == 'date').firstOrNull?.value;
        DateTime? threadDate = DateCodec.decodeDate(d);
        if (threadDate == null && d != null) {
          try {
            threadDate = DateTime.parse(d);
          } catch (e) {}
        }
        if (!isSignedIn) {
          if (threadDate == null) return null;
          final newDate = threadDate.add(mailDateOffset);
          if (newDate.isAfter(DateTime.now())) return DateTime.now();
          return newDate;
        }
        return threadDate;
      case MailEntityType.microsoft:
        final threadDate = _msThreads?.map((t) => t.receivedDateTime).whereType<DateTime>().toList().lastOrNull;
        if (!isSignedIn) {
          if (threadDate == null) return null;
          final newDate = threadDate.add(mailDateOffset);
          if (newDate.isAfter(DateTime.now())) return DateTime.now();
          return newDate;
        }
        return threadDate;
    }
  }

  String? get subject {
    switch (type) {
      case MailEntityType.google:
        return _gmailThreads?.firstOrNull?.payload?.headers?.where((element) => element.name?.toLowerCase() == 'subject').firstOrNull?.value ??
            _gmailMessage?.payload?.headers?.where((element) => element.name?.toLowerCase() == 'subject').firstOrNull?.value;
      case MailEntityType.microsoft:
        return _msMessage?.subject;
    }
  }

  DateTime? get date {
    switch (type) {
      case MailEntityType.google:
        final receivedString = _gmailMessage?.payload?.headers?.where((element) => element.name?.toLowerCase() == 'received').firstOrNull?.value;
        final receivedDateString = receivedString?.split(';').lastOrNull?.trim();
        DateTime? receivedDate = DateCodec.decodeDate(receivedDateString);
        if (receivedDate == null && receivedDateString != null) {
          try {
            receivedDate = DateTime.parse(receivedDateString);
          } catch (e) {}
        }

        if (receivedDate != null) return receivedDate;

        final dateString = _gmailMessage?.payload?.headers?.where((element) => element.name?.toLowerCase() == 'date').firstOrNull?.value;
        DateTime? date = DateCodec.decodeDate(dateString);
        if (date == null && dateString != null) {
          try {
            date = DateTime.parse(dateString);
          } catch (e) {}
        }

        if (!isSignedIn) {
          if (date == null) return null;
          final newDate = date.add(mailDateOffset);
          if (newDate.isAfter(DateTime.now())) return DateTime.now();
          return newDate;
        }
        return date;
      case MailEntityType.microsoft:
        final date = _msMessage?.receivedDateTime;
        if (!isSignedIn) {
          if (date == null) return null;
          final newDate = date.add(mailDateOffset);
          if (newDate.isAfter(DateTime.now())) return DateTime.now();
          return newDate;
        }
        return date;
    }
  }

  String? get timezone {
    switch (type) {
      case MailEntityType.google:
        // Try to extract timezone from Date header
        final dateString = _gmailMessage?.payload?.headers?.where((element) => element.name?.toLowerCase() == 'date').firstOrNull?.value;
        if (dateString != null) {
          // Look for timezone offset like "+0900" or "-0500"
          final timezoneMatch = RegExp(r'([+-])(\d{2})(\d{2})').firstMatch(dateString);
          if (timezoneMatch != null) {
            final sign = timezoneMatch.group(1);
            final hours = timezoneMatch.group(2);
            final minutes = timezoneMatch.group(3);
            return '$sign$hours:$minutes';
          }
        }
        return null;
      case MailEntityType.microsoft:
        // Extract timezone from receivedDateTime
        final receivedDateTime = _msMessage?.receivedDateTime;
        if (receivedDateTime != null) {
          final offset = receivedDateTime.timeZoneOffset;
          final hours = offset.inHours;
          final minutes = offset.inMinutes.remainder(60).abs();
          final sign = hours >= 0 ? '+' : '-';
          final hoursAbs = hours.abs();
          return '$sign${hoursAbs.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
        }
        return null;
    }
  }

  String? getDateString(BuildContext context) {
    switch (type) {
      case MailEntityType.google:
        if (date == null) return null;
        if (DateUtils.isSameDay(DateTime.now(), date!)) return DateFormat.jm().format(date!);
        if (DateUtils.isSameDay(DateTime.now().subtract(Duration(days: 1)), date!)) return context.tr.yesterday;
        if (date!.year == DateTime.now().year) return DateFormat.MMMd().format(date!);
        return DateFormat.yMMMd().format(date!);
      case MailEntityType.microsoft:
        if (date == null) return null;
        if (DateUtils.isSameDay(DateTime.now(), date!)) return DateFormat.jm().format(date!);
        if (DateUtils.isSameDay(DateTime.now().subtract(Duration(days: 1)), date!)) return context.tr.yesterday;
        if (date!.year == DateTime.now().year) return DateFormat.MMMd().format(date!);
        return DateFormat.yMMMd().format(date!);
    }
  }

  String? get threadDateString {
    final date = this.date ?? DateTime.now();
    switch (type) {
      case MailEntityType.google:
        final time = DateFormat('E, MMM d, h:mm a').format(date);
        if (DateTime.now().difference(date).inMinutes < 60) return '${time} (${DateTime.now().difference(date).inMinutes} minutes ago)';
        if (DateTime.now().difference(date).inHours < 24) return '${time} (${DateTime.now().difference(date).inHours} hours ago)';
        if (DateTime.now().difference(date).inDays < 7) return '${time} (${DateTime.now().difference(date).inDays} days ago)';
        return time;
      case MailEntityType.microsoft:
        final time = DateFormat('E, MMM d, h:mm a').format(date);
        if (DateTime.now().difference(date).inMinutes < 60) return '${time} (${DateTime.now().difference(date).inMinutes} minutes ago)';
        if (DateTime.now().difference(date).inHours < 24) return '${time} (${DateTime.now().difference(date).inHours} hours ago)';
        if (DateTime.now().difference(date).inDays < 7) return '${time} (${DateTime.now().difference(date).inDays} days ago)';
        return time;
    }
  }

  List<MailEntity>? get threads {
    switch (type) {
      case MailEntityType.google:
        return _gmailThreads?.map((t) => MailEntity.fromGmail(message: t, hostEmail: hostEmail)).toList();
      case MailEntityType.microsoft:
        return _msThreads?.map((t) => MailEntity.fromOutlook(message: t, hostEmail: hostEmail)).toList();
    }
  }

  String? get label {
    switch (type) {
      case MailEntityType.google:
        return _gmailMessage?.payload?.headers?.where((element) => element.name?.toLowerCase() == 'label').firstOrNull?.value;
      case MailEntityType.microsoft:
        return _msMessage?.id;
    }
  }

  String? get signature {
    switch (type) {
      case MailEntityType.google:
        return _gmailMessage?.payload?.headers?.where((element) => element.name?.toLowerCase() == 'signature').firstOrNull?.value;
      case MailEntityType.microsoft:
        return _msMessage?.id;
    }
  }

  String? get contentType {
    switch (type) {
      case MailEntityType.google:
        return _gmailMessage?.payload?.headers?.where((element) => element.name?.toLowerCase() == 'content-type').firstOrNull?.value;
      case MailEntityType.microsoft:
        return _msMessage?.id;
    }
  }

  String? get mimeType {
    switch (type) {
      case MailEntityType.google:
        return _gmailMessage?.payload?.mimeType;
      case MailEntityType.microsoft:
        return _msMessage?.id;
    }
  }

  String? get snippet {
    if (html?.isNotEmpty == true) {
      try {
        final text = _extractSnippetFromHtml(html!);
        if (text != null && text.isNotEmpty) {
          return text;
        }
      } catch (e) {
        // If parsing fails, fall back to default snippet
      }
    }

    switch (type) {
      case MailEntityType.google:
        final snippet = _gmailMessage?.snippet;
        if (snippet == null) return null;
        final unescaped = HtmlUnescape().convert(snippet);
        var normalized = _normalizeWhitespace(unescaped);
        if (normalized.isEmpty) return null;
        const maxLength = 400;
        if (normalized.length > maxLength) {
          normalized = normalized.substring(0, maxLength).trimRight();
        }
        return normalized;
      case MailEntityType.microsoft:
        final preview = _msMessage?.bodyPreview;
        if (preview == null) return null;
        var normalized = _normalizeWhitespace(preview);
        if (normalized.isEmpty) return null;
        const maxLength = 400;
        if (normalized.length > maxLength) {
          normalized = normalized.substring(0, maxLength).trimRight();
        }
        return normalized;
    }
  }

  /// 줄바꿈을 살린 snippet을 반환합니다. (AI 액션용)
  String? get snippetWithLineBreaks {
    if (html?.isNotEmpty == true) {
      try {
        final text = _extractSnippetFromHtmlWithLineBreaks(html!);
        if (text != null && text.isNotEmpty) {
          return text;
        }
      } catch (e) {
        // If parsing fails, fall back to default snippet
      }
    }

    switch (type) {
      case MailEntityType.google:
        final snippet = _gmailMessage?.snippet;
        if (snippet == null) return null;
        final unescaped = HtmlUnescape().convert(snippet);
        // 줄바꿈을 살리되, 연속된 공백은 정규화
        var text = unescaped.replaceAll(RegExp(r'[\u00A0\u1680\u2000-\u200D\u202F\u205F\u2060\u3000]'), ' ');
        text = text.replaceAll(RegExp(r'[ \t]+'), ' '); // 탭과 연속된 공백을 하나로
        text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n'); // 연속된 줄바꿈을 최대 2개로
        if (text.trim().isEmpty) return null;
        const maxLength = 2000; // AI 액션용이므로 더 긴 텍스트 허용
        if (text.length > maxLength) {
          text = text.substring(0, maxLength).trimRight();
        }
        return text;
      case MailEntityType.microsoft:
        final preview = _msMessage?.bodyPreview;
        if (preview == null) return null;
        // 줄바꿈을 살리되, 연속된 공백은 정규화
        var text = preview.replaceAll(RegExp(r'[\u00A0\u1680\u2000-\u200D\u202F\u205F\u2060\u3000]'), ' ');
        text = text.replaceAll(RegExp(r'[ \t]+'), ' '); // 탭과 연속된 공백을 하나로
        text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n'); // 연속된 줄바꿈을 최대 2개로
        if (text.trim().isEmpty) return null;
        const maxLength = 2000; // AI 액션용이므로 더 긴 텍스트 허용
        if (text.length > maxLength) {
          text = text.substring(0, maxLength).trimRight();
        }
        return text;
    }
  }

  String? _extractSnippetFromHtml(String rawHtml) {
    try {
      final document = html_parser.parse(rawHtml);
      final root = document.body ?? document.documentElement;
      if (root == null) return null;

      // Remove nodes that should not contribute to snippet text.
      for (final selector in <String>['script', 'style', 'noscript', 'template', 'meta', 'link', 'title', 'svg', 'head']) {
        root.querySelectorAll(selector).forEach((element) => element.remove());
      }
      root.querySelectorAll('[hidden], [aria-hidden="true"]').forEach((element) => element.remove());

      // Replace <br> tags with placeholder
      root.querySelectorAll('br').forEach((element) {
        element.replaceWith(dom.Text('\n'));
      });

      String text = root.text;
      if (text.trim().isEmpty) {
        return null;
      }

      text = HtmlUnescape().convert(text);
      text = _normalizeWhitespace(text);

      if (text.isEmpty) return null;

      const maxLength = 400;
      if (text.length > maxLength) {
        text = text.substring(0, maxLength).trimRight();
      }
      return text;
    } catch (_) {
      return null;
    }
  }

  /// 줄바꿈을 살린 snippet을 HTML에서 추출합니다. (AI 액션용)
  String? _extractSnippetFromHtmlWithLineBreaks(String rawHtml) {
    try {
      final document = html_parser.parse(rawHtml);
      final root = document.body ?? document.documentElement;
      if (root == null) return null;

      // Remove nodes that should not contribute to snippet text.
      for (final selector in <String>['script', 'style', 'noscript', 'template', 'meta', 'link', 'title', 'svg', 'head']) {
        root.querySelectorAll(selector).forEach((element) => element.remove());
      }
      root.querySelectorAll('[hidden], [aria-hidden="true"]').forEach((element) => element.remove());

      // Replace block-level elements and <br> tags with newlines
      root.querySelectorAll('br').forEach((element) {
        element.replaceWith(dom.Text('\n'));
      });
      root.querySelectorAll('p, div, li').forEach((element) {
        element.append(dom.Text('\n'));
      });

      String text = root.text;
      if (text.trim().isEmpty) {
        return null;
      }

      text = HtmlUnescape().convert(text);
      // 줄바꿈은 살리되, 연속된 공백은 정규화
      text = text.replaceAll(RegExp(r'[\u00A0\u1680\u2000-\u200D\u202F\u205F\u2060\u3000]'), ' ');
      text = text.replaceAll(RegExp(r'[ \t]+'), ' '); // 탭과 연속된 공백을 하나로
      text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n'); // 연속된 줄바꿈을 최대 2개로
      text = text.trim();

      if (text.isEmpty) return null;

      const maxLength = 2000; // AI 액션용이므로 더 긴 텍스트 허용
      if (text.length > maxLength) {
        text = text.substring(0, maxLength).trimRight();
      }
      return text;
    } catch (_) {
      return null;
    }
  }

  String _normalizeWhitespace(String? value) {
    if (value == null) return '';
    return value.replaceAll(RegExp(r'[\u00A0\u1680\u2000-\u200D\u202F\u205F\u2060\u3000]'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  List<MailFileEntity> getAttachments() {
    switch (type) {
      case MailEntityType.google:
        return addAttachments(_gmailMessage?.payload?.parts ?? []);
      case MailEntityType.microsoft:
        return _msMessage?.attachments
                ?.map((e) => MailFileEntity(id: e.id ?? '', cid: e.contentId ?? '', name: e.name ?? '', mimeType: e.contentType ?? '', data: null))
                .toList() ??
            [];
    }
  }

  List<MailFileEntity> addAttachments(List<Gmail.MessagePart> parts) {
    List<MailFileEntity> result = [];
    parts.forEach((e) {
      if (e.body?.attachmentId != null) {
        final cid = e.headers?.where((h) => h.name?.toLowerCase() == 'content-id').firstOrNull?.value ?? '';

        result.add(
          MailFileEntity(
            id: e.body!.attachmentId!,
            cid: cid.replaceAll('<', '').replaceAll('>', ''),
            name: e.filename ?? '',
            data: null,
            mimeType: e.mimeType ?? '',
          ),
        );
      }

      if (e.parts != null) result = [...result, ...addAttachments(e.parts!)];
    });

    return result;
  }

  bool get isSent {
    switch (type) {
      case MailEntityType.google:
        return _gmailMessage?.labelIds?.contains(CommonMailLabels.sent.id) == true;
      case MailEntityType.microsoft:
        return _msMessage?.labelIds?.contains(CommonMailLabels.sent.id) == true;
    }
  }

  bool get isUnread {
    switch (type) {
      case MailEntityType.google:
        return _gmailMessage?.labelIds?.contains(CommonMailLabels.unread.id) == true ||
            _gmailThreads?.where((e) => e.labelIds?.contains(CommonMailLabels.unread.id) == true).isNotEmpty == true;
      case MailEntityType.microsoft:
        return _msMessage?.labelIds?.contains(CommonMailLabels.unread.id) == true ||
            _msThreads?.where((e) => e.labelIds?.contains(CommonMailLabels.unread.id) == true).isNotEmpty == true;
    }
  }

  bool get isPinned {
    switch (type) {
      case MailEntityType.google:
        return _gmailMessage?.labelIds?.contains(CommonMailLabels.pinned.id) == true ||
            _gmailThreads?.where((e) => e.labelIds?.contains(CommonMailLabels.pinned.id) == true).isNotEmpty == true;
      case MailEntityType.microsoft:
        return _msMessage?.labelIds?.contains(CommonMailLabels.pinned.id) == true ||
            _msThreads?.where((e) => e.labelIds?.contains(CommonMailLabels.pinned.id) == true).isNotEmpty == true;
    }
  }

  bool get isTrash {
    switch (type) {
      case MailEntityType.google:
        return _gmailMessage?.labelIds?.contains(CommonMailLabels.trash.id) == true;
      case MailEntityType.microsoft:
        return _msMessage?.labelIds?.contains(CommonMailLabels.trash.id) == true;
    }
  }

  bool get isArchive {
    switch (type) {
      case MailEntityType.google:
        return _gmailMessage?.labelIds?.contains(CommonMailLabels.inbox.id) == false &&
            _gmailMessage?.labelIds?.contains(CommonMailLabels.spam.id) == false &&
            _gmailMessage?.labelIds?.contains(CommonMailLabels.trash.id) == false;
      case MailEntityType.microsoft:
        return _msMessage?.labelIds?.contains(CommonMailLabels.inbox.id) == false &&
            _msMessage?.labelIds?.contains(CommonMailLabels.spam.id) == false &&
            _msMessage?.labelIds?.contains(CommonMailLabels.trash.id) == false;
    }
  }

  bool get isSpam {
    switch (type) {
      case MailEntityType.google:
        return _gmailMessage?.labelIds?.contains(CommonMailLabels.spam.id) == true;
      case MailEntityType.microsoft:
        return _msMessage?.labelIds?.contains(CommonMailLabels.spam.id) == true;
    }
  }

  bool get isDraft {
    switch (type) {
      case MailEntityType.google:
        return _gmailMessage?.labelIds?.contains(CommonMailLabels.draft.id) == true;
      case MailEntityType.microsoft:
        return _msMessage?.labelIds?.contains(CommonMailLabels.draft.id) == true;
    }
  }

  String? get draftId {
    return _draftId;
  }

  List<String>? get labelIds {
    switch (type) {
      case MailEntityType.google:
        return _gmailMessage?.labelIds;
      case MailEntityType.microsoft:
        return _msMessage?.labelIds;
    }
  }

  String? get link {
    switch (type) {
      case MailEntityType.google:
        return 'https://mail.google.com/mail/u/0/#inbox/${_gmailMessage?.id}';
      case MailEntityType.microsoft:
        return 'https://outlook.office.com/mail/u/0/#inbox/${_msMessage?.id}';
    }
  }

  String addParts(List<Gmail.MessagePart> parts, String list) {
    final noHtml = parts.where((e) => e.mimeType == 'text/html').isEmpty;
    parts.forEach((element) {
      if (element.body?.data != null) {
        if (element.mimeType == 'text/html') {
          list += utf8.decode(element.body!.dataAsBytes);
        }

        if (noHtml && element.mimeType == 'text/plain') {
          list += utf8.decode(element.body!.dataAsBytes);
        }
      }

      if (element.parts != null) list += addParts(element.parts!, list);
    });

    return list;
  }

  MailEntity copyWith({
    bool? isUnread,
    bool? isPinned,
    bool? isArchive,
    bool? isSpam,
    bool? isTrash,
    List<String>? labelIds,
    DateTime? localUpdatedAt,
    List<MailEntity>? threads,
    String? draftId,
  }) {
    if (type == MailEntityType.google) {
      final labels = labelIds ?? this.labelIds ?? [];

      if (isUnread == true && !labels.contains('UNREAD')) labels.add('UNREAD');
      if (isUnread == false && labels.contains('UNREAD')) labels.remove('UNREAD');

      if (isPinned == true && !labels.contains('STARRED')) labels.add('STARRED');
      if (isPinned == false && labels.contains('STARRED')) labels.remove('STARRED');

      if (isArchive == true && labels.contains('INBOX')) labels.remove('INBOX');
      if (isArchive == false && !labels.contains('INBOX')) labels.add('INBOX');

      if (isSpam == true && !labels.contains('SPAM')) labels.add('SPAM');
      if (isSpam == false && labels.contains('SPAM')) labels.remove('SPAM');

      if (isTrash == true && !labels.contains('TRASH')) labels.add('TRASH');
      if (isTrash == false && labels.contains('TRASH')) labels.remove('TRASH');

      return MailEntity.fromGmail(
        message: _gmailMessage?.copyWith(labelIds: labels),
        thread:
            threads?.map((e) => e._gmailMessage).whereType<Gmail.Message>().toList() ??
            _gmailThreads?.map((e) {
              if (e.id == _gmailMessage?.id) return e.copyWith(labelIds: labels);
              return e;
            }).toList(),
        hostEmail: hostEmail,
        pageToken: pageToken ?? _pageToken,
        draftId: draftId ?? _draftId,
        localUpdatedAt: localUpdatedAt ?? _localUpdatedAt,
      );
    } else if (type == MailEntityType.microsoft) {
      final labels = labelIds ?? this.labelIds ?? [];

      if (isUnread == true && !labels.contains('UNREAD')) labels.add('UNREAD');
      if (isUnread == false && labels.contains('UNREAD')) labels.remove('UNREAD');

      if (isPinned == true && !labels.contains('STARRED')) labels.add('STARRED');
      if (isPinned == false && labels.contains('STARRED')) labels.remove('STARRED');

      if (isArchive == true && labels.contains('INBOX')) labels.remove('INBOX');
      if (isArchive == false && !labels.contains('INBOX')) labels.add('INBOX');

      if (isSpam == true && !labels.contains('SPAM')) labels.add('SPAM');
      if (isSpam == false && labels.contains('SPAM')) labels.remove('SPAM');

      if (isTrash == true && !labels.contains('TRASH')) labels.add('TRASH');
      if (isTrash == false && labels.contains('TRASH')) labels.remove('TRASH');

      return MailEntity.fromOutlook(
        message: _msMessage?.copyWith(labelIds: labels),
        thread:
            threads?.map((e) => e._msMessage).whereType<OutlookMailMessage>().toList() ??
            _msThreads?.map((e) {
              if (e.id == _msMessage?.id) return e.copyWith(labelIds: labels);
              return e;
            }).toList(),
        hostEmail: hostEmail,
        pageToken: pageToken ?? _pageToken,
        draftId: draftId ?? _draftId,
        localUpdatedAt: localUpdatedAt ?? _localUpdatedAt,
      );
    }

    return this;
  }
}

extension MessageX on Gmail.Message {
  Gmail.Message copyWith({
    String? historyId,
    String? id,
    String? internalDate,
    List<String>? labelIds,
    Gmail.MessagePart? payload,
    String? raw,
    int? sizeEstimate,
    String? snippet,
    String? threadId,
  }) {
    return Gmail.Message(
      historyId: historyId ?? this.historyId,
      id: id ?? this.id,
      internalDate: internalDate ?? this.internalDate,
      labelIds: labelIds ?? this.labelIds,
      payload: payload ?? this.payload,
      raw: raw ?? this.raw,
      sizeEstimate: sizeEstimate ?? this.sizeEstimate,
      snippet: snippet ?? this.snippet,
      threadId: threadId ?? this.threadId,
    );
  }

  toMap() {
    return {...this.toJson(), if (this.payload != null) 'payload': payload?.toMap()};
  }
}

extension MessagePartX on Gmail.MessagePart {
  toMap() {
    return {
      ...this.toJson(),
      if (this.body != null) 'body': body?.toJson(),
      if (this.headers != null) 'headers': headers?.map((e) => e.toJson()).toList(),
      if (this.parts != null) 'parts': parts?.map((e) => e.toMap()).toList(),
    };
  }

  copyWith({
    Gmail.MessagePartBody? body,
    String? filename,
    List<Gmail.MessagePartHeader>? headers,
    String? mimeType,
    String? partId,
    List<Gmail.MessagePart>? parts,
  }) {
    return Gmail.MessagePart(
      body: body ?? this.body,
      filename: filename ?? this.filename,
      headers: headers ?? this.headers,
      mimeType: mimeType ?? this.mimeType,
      partId: partId ?? this.partId,
      parts: parts ?? this.parts,
    );
  }
}

List<String> extractEmailsFromString(String string) {
  final emailPattern = RegExp(r'\b[\w\.-]+@[\w\.-]+\.\w{2,8}\b', caseSensitive: false, multiLine: true);
  final matches = emailPattern.allMatches(string);
  final List<String> emails = [];
  for (final Match match in matches) {
    emails.add(string.substring(match.start, match.end));
  }

  return emails;
}
