import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/mail/infrastructure/models/outlook_mail_label.dart';
import 'package:flutter/cupertino.dart';
import 'package:googleapis/gmail/v1.dart';

List<String> mailPrefExcludeLabelIds = [
  ...CommonMailLabels.values.map((l) => l.id).toList(),
  'CHAT',
  'IMPORTANT',
  'FORUMS',
  'CATEGORY_FORUMS',
  'CATEGORY_UPDATES',
  'CATEGORY_PERSONAL',
  'CATEGORY_PROMOTIONS',
  'CATEGORY_SOCIAL',
  'Label_1',
];

enum CommonMailLabels { inbox, pinned, unread, draft, archive, sent, spam, trash, all }

extension CommonMailLabelsX on CommonMailLabels {
  String get id {
    switch (this) {
      case CommonMailLabels.inbox:
        return 'INBOX';
      case CommonMailLabels.pinned:
        return 'STARRED';
      case CommonMailLabels.unread:
        return 'UNREAD';
      case CommonMailLabels.draft:
        return 'DRAFT';
      case CommonMailLabels.archive:
        return 'ARCHIVE';
      case CommonMailLabels.sent:
        return 'SENT';
      case CommonMailLabels.spam:
        return 'SPAM';
      case CommonMailLabels.trash:
        return 'TRASH';
      case CommonMailLabels.all:
        return 'ALL';
    }
  }

  String get msId {
    switch (this) {
      case CommonMailLabels.inbox:
        return 'inbox';
      case CommonMailLabels.draft:
        return 'drafts';
      case CommonMailLabels.archive:
        return 'archive';
      case CommonMailLabels.sent:
        return 'sentitems';
      case CommonMailLabels.spam:
        return 'junkemail';
      case CommonMailLabels.trash:
        return 'deleteditems';
      default:
        return id;
    }
  }

  String getTitle(BuildContext context) {
    switch (this) {
      case CommonMailLabels.inbox:
        return context.tr.mail_label_inbox;
      case CommonMailLabels.pinned:
        return context.tr.mail_label_pinned;
      case CommonMailLabels.unread:
        return context.tr.mail_label_unread;
      case CommonMailLabels.draft:
        return context.tr.mail_label_draft;
      case CommonMailLabels.archive:
        return context.tr.mail_label_archive;
      case CommonMailLabels.sent:
        return context.tr.mail_label_sent;
      case CommonMailLabels.spam:
        return context.tr.mail_label_spam;
      case CommonMailLabels.trash:
        return context.tr.mail_label_trash;
      case CommonMailLabels.all:
        return context.tr.mail_label_all;
    }
  }
}

class MailLabelEntity {
  late Label? _googleLabel;
  late OutlookMailLabel? _msLabel;

  MailLabelEntity({Label? googleLabel, OutlookMailLabel? msLabel}) : _googleLabel = googleLabel, _msLabel = msLabel;

  Map<String, dynamic> toJson() {
    return {'_googleLabel': _googleLabel?.toMap(), '_msLabel': _msLabel?.toJson()};
  }

  factory MailLabelEntity.fromJson(Map<String, dynamic> json) {
    return MailLabelEntity(
      googleLabel: json['_googleLabel'] != null ? Label.fromJson(json['_googleLabel']) : null,
      msLabel: json['_msLabel'] != null ? OutlookMailLabel.fromJson(json['_msLabel']) : null,
    );
  }

  String? get id {
    if (_googleLabel != null) return _googleLabel?.id;
    if (_msLabel != null) {
      switch (_msLabel?.wellKnownName) {
        case 'inbox':
          return CommonMailLabels.inbox.id;
        case 'archive':
          return CommonMailLabels.archive.id;
        case 'deleteditems':
          return CommonMailLabels.trash.id;
        case 'drafts':
          return CommonMailLabels.draft.id;
        case 'sentitems':
          return CommonMailLabels.sent.id;
        case 'junkemail':
          return CommonMailLabels.spam.id;
        default:
          return _msLabel?.id;
      }
    }
    return null;
  }

  String? get rawId {
    if (_googleLabel != null) return _googleLabel?.id;
    if (_msLabel != null) return _msLabel?.id;
    return null;
  }

  String? get searchId {
    if (_googleLabel != null) return _googleLabel?.id;
    if (_msLabel != null) return _msLabel?.wellKnownName ?? _msLabel?.id;
    return null;
  }

  String? get folderId {
    if (_googleLabel != null) return _googleLabel?.id;
    if (_msLabel != null) return _msLabel?.id;
    return null;
  }

  String? get name {
    if (_googleLabel?.name != null) {
      switch (_googleLabel?.id) {
        case 'INBOX':
          return 'Inbox';
        case 'STARRED':
          return 'Starred';
        case 'UNREAD':
          return 'Unread';
        case 'DRAFT':
          return 'Draft';
        case 'SENT':
          return 'Sent';
        case 'SPAM':
          return 'Spam';
        case 'TRASH':
          return 'Trash';
        case 'CHAT':
          return 'Chat';
        case 'IMPORTANT':
          return 'Important';
        case 'CATEGORY_FORUMS':
          return 'Forums';
        case 'CATEGORY_UPDATES':
          return 'Updates';
        case 'CATEGORY_PROMOTIONS':
          return 'Promotions';
        case 'CATEGORY_SOCIAL':
          return 'Social';
        case 'CATEGORY_PERSONAL':
          return 'Personal';
        default:
          return _googleLabel?.name;
      }
    }

    if (_msLabel != null) {
      // id로 CommonMailLabels 확인 (displayName이 null일 수 있음)
      switch (_msLabel?.id) {
        case 'UNREAD':
          return CommonMailLabels.unread.name;
        case 'STARRED':
          return CommonMailLabels.pinned.name;
        default:
          break;
      }
      
      // wellKnownName으로 확인
      switch (_msLabel?.wellKnownName) {
        case 'inbox':
          return CommonMailLabels.inbox.name;
        case 'archive':
          return CommonMailLabels.archive.name;
        case 'deleteditems':
          return CommonMailLabels.trash.name;
        case 'drafts':
          return CommonMailLabels.draft.name;
        case 'sentitems':
          return CommonMailLabels.sent.name;
        case 'junkemail':
          return CommonMailLabels.spam.name;
        case 'clutter':
          return 'Clutter';
        case 'conflicts':
          return 'Conflicts';
        case 'conversationhistory':
          return 'Conversation History';
        case 'localfailures':
          return 'Local Failures';
        case 'msgfolderroot':
          return 'Msg Folder Root';
        case 'outbox':
          return 'Outbox';
        case 'recoverableitemsdeletions':
          return 'Recoverable Items Deletions';
        case 'scheduled':
          return 'Scheduled';
        case 'searchfolders':
          return 'Search Folders';
        case 'serverfailures':
          return 'Server Failures';
        case 'syncissues':
          return 'Sync Issues';
        default:
          return _msLabel?.displayName;
      }
    }

    return null;
  }

  String? get wellKnownName {
    if (_msLabel != null) return _msLabel?.wellKnownName;
    return null;
  }

  Color getColor(BuildContext context) {
    if (_googleLabel != null) {
      return _googleLabel?.color?.backgroundColor != null ? ColorX.fromHex(_googleLabel!.color!.backgroundColor!) : context.onBackground;
    } else if (_msLabel != null) {
      return context.onBackground;
    }

    return context.onBackground;
  }

  int get unread {
    if (_googleLabel != null) {
      return _googleLabel?.messagesUnread ?? 0;
    } else if (_msLabel != null) {
      return _msLabel?.unreadItemCount ?? 0;
    }

    return 0;
  }

  int get total {
    if (_googleLabel != null) {
      return _googleLabel?.messagesTotal ?? 0;
    } else if (_msLabel != null) {
      return _msLabel?.totalItemCount ?? 0;
    }

    return 0;
  }

  MailLabelEntity copyWith({int? messagesUnread, int? messagesTotal, String? wellKnownName}) {
    return MailLabelEntity(
      googleLabel: _googleLabel?.copyWith(messagesUnread: messagesUnread, messagesTotal: messagesTotal),
      msLabel: _msLabel?.copyWith(totalItemCount: messagesTotal, unreadItemCount: messagesUnread, wellKnownName: wellKnownName),
    );
  }
}

extension LabelX on Label {
  toMap() {
    return {...this.toJson(), if (color != null) 'color': color?.toJson()};
  }

  Label copyWith({String? id, String? name, int? threadsUnread, int? threadsTotal, int? messagesTotal, int? messagesUnread, LabelColor? color}) {
    return Label(
      id: this.id,
      name: this.name,
      messagesTotal: messagesTotal ?? this.messagesTotal,
      messagesUnread: messagesUnread ?? this.messagesUnread,
      threadsTotal: this.threadsTotal,
      threadsUnread: this.threadsUnread,
      color: this.color,
    );
  }
}
