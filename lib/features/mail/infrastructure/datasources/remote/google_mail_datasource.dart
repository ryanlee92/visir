import 'dart:convert';
import 'dart:typed_data';

import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/google_api_handler.dart';
import 'package:Visir/features/mail/domain/datasources/mail_datasource.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_fetch_result_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/gmail/v1.dart' as Gmail;
import 'package:googleapis/people/v1.dart' as GooglePeople;

final kMailFetchCount = 40;

class GoogleMailDatasource implements MailDatasource {
  GoogleMailDatasource();

  static List<String> scopes = [
    Gmail.GmailApi.mailGoogleComScope,
    GooglePeople.PeopleServiceApi.contactsOtherReadonlyScope,
    GooglePeople.PeopleServiceApi.userinfoProfileScope,
    GooglePeople.PeopleServiceApi.userinfoEmailScope,
  ];

  @override
  Future<OAuthEntity?> integrate() async {
    final oauth = await GoogleApiHandler.integrate(scopes, 'mail');
    return oauth;
  }

  @override
  Future<Map<String, List<MailLabelEntity>>> fetchLabelLists({required OAuthEntity oauth}) async {
    Map<String, List<MailLabelEntity>> labels = {};
    final result = await fetchLabelForOAuth(oauth: oauth);
    List<MailLabelEntity> details = result;
    labels[oauth.email] = details;
    return labels;
  }

  Future<List<MailLabelEntity>> fetchLabelForOAuth({required OAuthEntity oauth}) async {
    final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);
    try {
      final value = await Gmail.GmailApi(client).users.labels.list('me');
      final result = value.labels ?? [];
      final batchResult = await GoogleApiHandler.batchRequest(
        'gmail/v1',
        result.map((e) => BatchRequest(method: 'GET', path: '/gmail/v1/users/me/labels/${e.id}', contentType: 'application/http', contentId: e.id!)).toList(),
        client,
      );

      final googleLabels = batchResult
          .map((e) {
            try {
              if (e['id'] == null) return null;
              return Gmail.Label.fromJson(e);
            } catch (e) {
              return null;
            }
          })
          .whereType<Gmail.Label>()
          .toList();

      final labelDetails = googleLabels.map((e) => MailLabelEntity(googleLabel: e)).toList();
      return labelDetails;
    } catch (e) {
      GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
      throw e;
    }
  }

  @override
  Future<List<String>> fetchSignature({required OAuthEntity oauth}) async {
    List<String> list = [];

    try {
      final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);
      final sendAs = await Gmail.GmailApi(client).users.settings.sendAs.list('me');
      final value = sendAs.sendAs?.map((e) => e.signature?.isNotEmpty == true ? e.signature : null).whereType<String>().toList();

      list.addAll(value ?? []);
    } catch (e) {
      GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
      throw e;
    }
    return list;
  }

  @override
  Future<Map<String, MailFetchResultEntity>> fetchMailLists({
    required OAuthEntity oauth,
    required UserEntity user,
    required bool isInbox,
    String? labelId,
    Map<String, String?>? pageToken,
    String? email,
    String? q,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    Map<String, MailFetchResultEntity> messages = {};

    String? query = q ?? '';
    if (startDate != null) {
      query += ' after:${(startDate.millisecondsSinceEpoch / 1000).floor()}';
    }
    if (endDate != null) {
      query += ' before:${(endDate.millisecondsSinceEpoch / 1000).floor()}';
    }
    query = query.trim();

    if (query.isEmpty) query = null;

    final result = await fetchMailListsForOAuth(
      oauth: oauth,
      labelIds: labelId != null
          ? labelId == CommonMailLabels.all.id
                ? null
                : labelId == CommonMailLabels.unread.id
                ? [labelId, CommonMailLabels.inbox.id]
                : [labelId]
          : isInbox && (user.userMailInboxFilterTypes[oauth.email] == MailInboxFilterType.all || user.userMailInboxFilterTypes[oauth.email] == null)
          ? [CommonMailLabels.inbox.id]
          : isInbox && user.userMailInboxFilterTypes[oauth.email] == MailInboxFilterType.withSpecificLables
          ? user.userMilInboxFilterLabelIds[oauth.email]
          : null,
      pageToken: pageToken,
      email: email,
      q: q,
      startDate: startDate,
      endDate: endDate,
    );

    messages[oauth.email] = result;
    return messages;
  }

  Future<MailFetchResultEntity> fetchMailListsForOAuth({
    required OAuthEntity oauth,
    List<String>? labelIds,
    Map<String, String?>? pageToken,
    String? email,
    String? q,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    String? query = q ?? '';
    if (startDate != null) {
      query += ' after:${(startDate.millisecondsSinceEpoch / 1000).floor()}';
    }
    if (endDate != null) {
      query += ' before:${(endDate.millisecondsSinceEpoch / 1000).floor()}';
    }
    query = query.trim();

    if (query.isEmpty) query = null;

    if (email == null || email == oauth.email) {
      if (pageToken != null && pageToken[oauth.email] == null) return MailFetchResultEntity(hasMore: false, messages: []);
      List<MailEntity> data;
      String? nextPageToken;
      final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);

      if (labelIds?.length == 1 && labelIds?.first == CommonMailLabels.draft.id) {
        try {
          final draftValues = await Gmail.GmailApi(
            client,
          ).users.drafts.list('me', includeSpamTrash: false, maxResults: kMailFetchCount, pageToken: pageToken?[oauth.email], q: query);

          final draftResult = draftValues.drafts ?? [];
          nextPageToken = draftValues.nextPageToken;

          List<String> draftIds = draftResult.map((e) => e.id!).toList().unique((e) => e);

          final batchResult = await GoogleApiHandler.batchRequest(
            'gmail/v1',
            draftIds
                .map((e) => BatchRequest(method: 'GET', path: '/gmail/v1/users/me/drafts/$e?format=full', contentType: 'application/http', contentId: e))
                .toList(),
            client,
          );

          final draftDetails = batchResult
              .map((e) {
                try {
                  return Gmail.Draft.fromJson(e);
                } catch (e) {
                  return null;
                }
              })
              .whereType<Gmail.Draft>()
              .toList();

          data = draftDetails
              .map((e) {
                if (e.message == null) return null;
                return MailEntity.fromGmail(
                  message: e.message,
                  thread: [e.message!],
                  hostEmail: oauth.email,
                  pageToken: draftValues.nextPageToken,
                  draftId: e.id,
                );
              })
              .whereType<MailEntity>()
              .toList();
        } catch (e) {
          GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
          throw e;
        }
      } else {
        if (labelIds?.length == 1 && labelIds?.first == CommonMailLabels.unread.id) {
          labelIds = [CommonMailLabels.unread.id, CommonMailLabels.inbox.id];
        }

        try {
          final value = await Gmail.GmailApi(
            client,
          ).users.threads.list('me', includeSpamTrash: false, maxResults: kMailFetchCount, labelIds: labelIds, pageToken: pageToken?[oauth.email], q: query);

          final result = value.threads ?? [];
          nextPageToken = value.nextPageToken;

          final messages = result.where((e) => e.id != null).toList().unique((e) => e.id);

          final batchResult = await GoogleApiHandler.batchRequest(
            'gmail/v1',
            messages
                .map(
                  (e) => BatchRequest(method: 'GET', path: '/gmail/v1/users/me/threads/${e.id}?format=full', contentType: 'application/http', contentId: e.id!),
                )
                .toList(),
            client,
          );

          final messagesDetail = batchResult
              .map((e) {
                try {
                  return Gmail.Thread.fromJson(e);
                } catch (e) {
                  return null;
                }
              })
              .whereType<Gmail.Thread>()
              .toList();

          data = messagesDetail
              .map((e) {
                if (e.messages?.isNotEmpty != true) return null;
                final anchorMessage = e.messages?.where((e) {
                  if (labelIds != null) return labelIds.where((l) => e.labelIds?.contains(l) != true).isEmpty;
                  return true;
                }).lastOrNull;
                if (anchorMessage == null) return null;
                return MailEntity.fromGmail(message: anchorMessage, thread: e.messages, hostEmail: oauth.email, pageToken: value.nextPageToken);
              })
              .whereType<MailEntity>()
              .toList();
        } catch (e) {
          GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
          return MailFetchResultEntity(hasMore: nextPageToken != null, messages: [], nextPageToken: nextPageToken, isRateLimited: true);
        }
      }
      return MailFetchResultEntity(hasMore: nextPageToken != null, messages: data, nextPageToken: nextPageToken);
    }

    return MailFetchResultEntity(hasMore: false, messages: []);
  }

  @override
  Future<MailEntity?> fetchAddedMails({required OAuthEntity oauth, required String historyId, required String email, Map<String, String?>? pageToken}) async {
    try {
      final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);
      final histories = await Gmail.GmailApi(client).users.history.list('me', startHistoryId: historyId, pageToken: pageToken?[oauth.email]);
      Gmail.HistoryMessageAdded? messageAdded;

      for (Gmail.History h in histories.history ?? []) {
        for (Gmail.HistoryMessageAdded message in h.messagesAdded ?? []) {
          messageAdded = message;
        }
      }

      if (messageAdded?.message?.id == null) return null;
      final gmail = await Gmail.GmailApi(client).users.messages.get('me', messageAdded!.message!.id!, format: 'full');
      final mail = MailEntity.fromGmail(message: gmail, hostEmail: email);
      return mail;
    } catch (e) {
      GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
      throw e;
    }
  }

  @override
  Future<List<MailEntity>> fetchThreads({required OAuthEntity oauth, required String threadId, required String labelId, String? email}) async {
    try {
      final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);
      final value = await Gmail.GmailApi(client).users.threads.get('me', threadId, format: 'full');
      return value.messages?.map((e) => MailEntity.fromGmail(message: e, hostEmail: oauth.email)).toList() ?? [];
    } catch (e) {
      GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
      throw e;
    }
  }

  @override
  Future<Map<String, Uint8List?>> getAttachments({
    required String email,
    required String messageId,
    required OAuthEntity oauth,
    required List<String> attachmentIds,
  }) async {
    try {
      final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);
      final batchResult = await GoogleApiHandler.batchRequest(
        'gmail/v1',
        attachmentIds
            .map(
              (e) => BatchRequest(method: 'GET', path: '/gmail/v1/users/me/messages/$messageId/attachments/$e', contentType: 'application/http', contentId: e),
            )
            .toList(),
        client,
      );

      final attachments = batchResult
          .map((e) {
            try {
              return Gmail.MessagePartBody.fromJson(e);
            } catch (e) {
              return null;
            }
          })
          .whereType<Gmail.MessagePartBody>()
          .toList();

      return Map.fromEntries(attachments.mapIndexed((index, e) => MapEntry(attachmentIds[index], e.data == null ? null : base64Decode(e.data!))));
    } catch (e) {
      GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
      throw e;
    }
  }

  @override
  Future<void> read({required List<MailEntity> mails, required OAuthEntity oauth}) async {
    final emailMails = mails.where((e) => e.hostEmail == oauth.email).toList();
    if (emailMails.isNotEmpty) {
      try {
        final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);
        if (emailMails.length == 1) {
          await Gmail.GmailApi(client).users.messages.modify(Gmail.ModifyMessageRequest(removeLabelIds: ['UNREAD']), 'me', emailMails.first.id!);
        } else {
          await Gmail.GmailApi(client).users.messages.batchModify(
            Gmail.BatchModifyMessagesRequest(ids: emailMails.map((e) => e.id).whereType<String>().toList(), removeLabelIds: ['UNREAD']),
            'me',
          );
        }
      } catch (e) {
        GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }
  }

  @override
  Future<void> unread({required List<MailEntity> mails, required OAuthEntity oauth}) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    final emailMails = groupedMails[oauth.email];
    if (emailMails?.isNotEmpty == true) {
      try {
        final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);
        if (emailMails!.length == 1) {
          await Gmail.GmailApi(client).users.messages.modify(Gmail.ModifyMessageRequest(addLabelIds: ['UNREAD']), 'me', emailMails.first.id!);
        } else {
          await Gmail.GmailApi(client).users.messages.batchModify(
            Gmail.BatchModifyMessagesRequest(ids: emailMails.map((e) => e.id).whereType<String>().toList(), addLabelIds: ['UNREAD']),
            'me',
          );
        }
      } catch (e) {
        GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }
  }

  @override
  Future<void> star({required List<MailEntity> mails, required OAuthEntity oauth}) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    final emailMails = groupedMails[oauth.email];
    if (emailMails?.isNotEmpty == true) {
      try {
        final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);
        if (emailMails!.length == 1) {
          await Gmail.GmailApi(client).users.messages.modify(Gmail.ModifyMessageRequest(addLabelIds: ['STARRED']), 'me', emailMails.first.id!);
        } else {
          await Gmail.GmailApi(client).users.messages.batchModify(
            Gmail.BatchModifyMessagesRequest(ids: emailMails.map((e) => e.id).whereType<String>().toList(), addLabelIds: ['STARRED']),
            'me',
          );
        }
      } catch (e) {
        GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }
  }

  @override
  Future<void> unstar({required List<MailEntity> mails, required OAuthEntity oauth}) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    final emailMails = groupedMails[oauth.email];
    if (emailMails?.isNotEmpty == true) {
      try {
        final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);
        if (emailMails!.length == 1) {
          await Gmail.GmailApi(client).users.messages.modify(Gmail.ModifyMessageRequest(removeLabelIds: ['STARRED']), 'me', emailMails.first.id!);
        } else {
          await Gmail.GmailApi(client).users.messages.batchModify(
            Gmail.BatchModifyMessagesRequest(ids: emailMails.map((e) => e.id).whereType<String>().toList(), removeLabelIds: ['STARRED']),
            'me',
          );
        }
      } catch (e) {
        GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }
  }

  @override
  Future<void> important({required List<MailEntity> mails, required OAuthEntity oauth}) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    final emailMails = groupedMails[oauth.email];
    if (emailMails?.isNotEmpty == true) {
      try {
        final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);
        if (emailMails!.length == 1) {
          await Gmail.GmailApi(client).users.messages.modify(Gmail.ModifyMessageRequest(addLabelIds: ['IMPORTANT']), 'me', emailMails.first.id!);
        } else {
          await Gmail.GmailApi(client).users.messages.batchModify(
            Gmail.BatchModifyMessagesRequest(ids: emailMails.map((e) => e.id).whereType<String>().toList(), addLabelIds: ['IMPORTANT']),
            'me',
          );
        }
      } catch (e) {
        GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }
  }

  @override
  Future<void> unimportant({required List<MailEntity> mails, required OAuthEntity oauth}) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    final emailMails = groupedMails[oauth.email];
    if (emailMails?.isNotEmpty == true) {
      try {
        final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);
        if (emailMails!.length == 1) {
          await Gmail.GmailApi(client).users.messages.modify(Gmail.ModifyMessageRequest(removeLabelIds: ['IMPORTANT']), 'me', emailMails.first.id!);
        } else {
          await Gmail.GmailApi(client).users.messages.batchModify(
            Gmail.BatchModifyMessagesRequest(ids: emailMails.map((e) => e.id).whereType<String>().toList(), removeLabelIds: ['IMPORTANT']),
            'me',
          );
        }
      } catch (e) {
        GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }
  }

  @override
  Future<void> trash({required List<MailEntity> mails, required OAuthEntity oauth}) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    final emailMails = groupedMails[oauth.email];
    if (emailMails?.isNotEmpty == true) {
      try {
        final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);
        if (emailMails!.length == 1) {
          await Gmail.GmailApi(client).users.threads.trash('me', emailMails.first.threadId!);
        } else {
          await Gmail.GmailApi(client).users.messages.batchModify(
            Gmail.BatchModifyMessagesRequest(ids: emailMails.map((e) => e.id).whereType<String>().toList(), addLabelIds: ['TRASH']),
            'me',
          );
        }
      } catch (e) {
        GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }
  }

  @override
  Future<void> untrash({required List<MailEntity> mails, required OAuthEntity oauth}) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    final emailMails = groupedMails[oauth.email];
    if (emailMails?.isNotEmpty == true) {
      try {
        final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);
        if (emailMails!.length == 1) {
          await Gmail.GmailApi(client).users.threads.untrash('me', emailMails.first.threadId!);
        } else {
          await Gmail.GmailApi(client).users.messages.batchModify(
            Gmail.BatchModifyMessagesRequest(ids: emailMails.map((e) => e.id).whereType<String>().toList(), removeLabelIds: ['TRASH']),
            'me',
          );
        }
      } catch (e) {
        GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }
  }

  @override
  Future<void> spam({required List<MailEntity> mails, required OAuthEntity oauth}) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    final emailMails = groupedMails[oauth.email];
    if (emailMails?.isNotEmpty == true) {
      try {
        final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);
        if (emailMails!.length == 1) {
          await Gmail.GmailApi(
            client,
          ).users.threads.modify(Gmail.ModifyThreadRequest(addLabelIds: ['SPAM'], removeLabelIds: ['INBOX']), 'me', emailMails.first.threadId!);
        } else {
          await Gmail.GmailApi(client).users.messages.batchModify(
            Gmail.BatchModifyMessagesRequest(ids: emailMails.map((e) => e.id).whereType<String>().toList(), addLabelIds: ['SPAM'], removeLabelIds: ['INBOX']),
            'me',
          );
        }
      } catch (e) {
        GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }
  }

  @override
  Future<void> unspam({required List<MailEntity> mails, required OAuthEntity oauth}) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    final emailMails = groupedMails[oauth.email];
    if (emailMails?.isNotEmpty == true) {
      try {
        final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);
        if (emailMails!.length == 1) {
          await Gmail.GmailApi(
            client,
          ).users.threads.modify(Gmail.ModifyThreadRequest(removeLabelIds: ['SPAM'], addLabelIds: ['INBOX']), 'me', emailMails.first.threadId!);
        } else {
          await Gmail.GmailApi(client).users.messages.batchModify(
            Gmail.BatchModifyMessagesRequest(ids: emailMails.map((e) => e.id).whereType<String>().toList(), removeLabelIds: ['SPAM'], addLabelIds: ['INBOX']),
            'me',
          );
        }
      } catch (e) {
        GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }
  }

  @override
  Future<void> archive({required List<MailEntity> mails, required OAuthEntity oauth}) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    final emailMails = groupedMails[oauth.email];
    if (emailMails?.isNotEmpty == true) {
      try {
        final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);
        if (emailMails!.length == 1) {
          await Gmail.GmailApi(client).users.messages.modify(Gmail.ModifyMessageRequest(removeLabelIds: ['INBOX']), 'me', emailMails.first.id!);
        } else {
          await Gmail.GmailApi(client).users.messages.batchModify(
            Gmail.BatchModifyMessagesRequest(ids: emailMails.map((e) => e.id).whereType<String>().toList(), removeLabelIds: ['INBOX']),
            'me',
          );
        }
      } catch (e) {
        GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }
  }

  @override
  Future<void> unarchive({required List<MailEntity> mails, required OAuthEntity oauth}) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    final emailMails = groupedMails[oauth.email];
    if (emailMails?.isNotEmpty == true) {
      try {
        final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);
        if (emailMails!.length == 1) {
          await Gmail.GmailApi(client).users.messages.modify(Gmail.ModifyMessageRequest(addLabelIds: ['INBOX']), 'me', emailMails.first.id!);
        } else {
          await Gmail.GmailApi(client).users.messages.batchModify(
            Gmail.BatchModifyMessagesRequest(ids: emailMails.map((e) => e.id).whereType<String>().toList(), addLabelIds: ['INBOX']),
            'me',
          );
        }
      } catch (e) {
        GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }
  }

  @override
  Future<bool> delete({required List<MailEntity> mails, required OAuthEntity oauth}) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    final emailMails = groupedMails[oauth.email];
    if (emailMails?.isNotEmpty == true) {
      try {
        final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);
        if (emailMails!.length == 1) {
          await Gmail.GmailApi(client).users.threads.delete('me', emailMails.first.threadId!);
        } else {
          await Gmail.GmailApi(
            client,
          ).users.messages.batchDelete(Gmail.BatchDeleteMessagesRequest(ids: emailMails.map((e) => e.id).whereType<String>().toList()), 'me');
        }
        return true;
      } catch (e) {
        GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }

    return false;
  }

  @override
  Future<MailEntity?> send({required MailEntity mail, required OAuthEntity oauth}) async {
    if (mail.hostEmail == oauth.email) {
      try {
        final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);
        if (mail.isDraft) {
          final value = await Gmail.GmailApi(client).users.drafts.send(Gmail.Draft(id: mail.draftId, message: mail.gmailMessage!), 'me');
          if (value.id == null) return null;
          final message = await Gmail.GmailApi(client).users.messages.get('me', value.id!, format: 'full');
          return MailEntity.fromGmail(message: message, hostEmail: oauth.email);
        } else {
          final value = await Gmail.GmailApi(client).users.messages.send(mail.gmailMessage!, 'me');
          if (value.id == null) return null;
          final message = await Gmail.GmailApi(client).users.messages.get('me', value.id!, format: 'full');
          return MailEntity.fromGmail(message: message, hostEmail: oauth.email);
        }
      } catch (e) {
        GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }
    return null;
  }

  @override
  Future<MailEntity?> draft({required MailEntity mail, required OAuthEntity oauth}) async {
    if (mail.hostEmail != oauth.email) return null;
    if (mail.draftId != null) {
      try {
        final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);
        if (mail.draftId != null) {
          final value = await Gmail.GmailApi(client).users.drafts.update(Gmail.Draft(message: mail.gmailMessage!), 'me', mail.draftId!);
          if (value.id == null) return null;
          final draft = await Gmail.GmailApi(client).users.drafts.get('me', value.id!, format: 'full');
          return MailEntity.fromGmail(message: draft.message, hostEmail: oauth.email, draftId: draft.id);
        } else {
          final value = await Gmail.GmailApi(client).users.drafts.create(Gmail.Draft(message: mail.gmailMessage!), 'me');
          if (value.id == null) return null;
          final draft = await Gmail.GmailApi(client).users.drafts.get('me', value.id!, format: 'full');
          return MailEntity.fromGmail(message: draft.message, hostEmail: oauth.email, draftId: draft.id);
        }
      } catch (e) {
        GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }

    return null;
  }

  @override
  Future<bool> undraft({required MailEntity mail, required OAuthEntity oauth}) async {
    if (mail.hostEmail != oauth.email) return false;
    try {
      final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);
      await Gmail.GmailApi(client).users.drafts.delete('me', mail.draftId!);
      return true;
    } catch (e) {
      GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
      throw e;
    }
  }

  @override
  Future<void> deleteLabels({required String labelId, required OAuthEntity oauth}) async {
    try {
      final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);
      final messageIds = await getMessageIds(oauth: oauth, labelId: labelId, pageToken: null);
      if (messageIds.isEmpty) return;
      await Gmail.GmailApi(client).users.messages.batchDelete(Gmail.BatchDeleteMessagesRequest(ids: messageIds), 'me');
    } catch (e) {
      GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
      throw e;
    }
  }

  @override
  Future<void> batchModify({List<String>? addLabels, List<String>? removeLabels, required List<String> messageIds, required OAuthEntity oauth}) async {
    try {
      final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);
      await Gmail.GmailApi(
        client,
      ).users.messages.batchModify(Gmail.BatchModifyMessagesRequest(ids: messageIds, addLabelIds: addLabels, removeLabelIds: removeLabels), 'me');
    } catch (e) {
      GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
      throw e;
    }
  }

  Future<List<String>> getMessageIds({required OAuthEntity oauth, required String labelId, String? pageToken}) async {
    List<String> messageIds = [];
    try {
      final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);
      final value = await Gmail.GmailApi(client).users.messages.list('me', includeSpamTrash: true, maxResults: 500, labelIds: [labelId], pageToken: pageToken);
      final ids = value.messages?.map((e) => e.id).whereType<String>().toList() ?? [];
      messageIds.addAll(ids);

      if (value.nextPageToken != null) {
        final pageIds = await getMessageIds(oauth: oauth, labelId: labelId, pageToken: value.nextPageToken!);
        messageIds.addAll(pageIds);
      }

      return messageIds;
    } catch (e) {
      GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
      throw e;
    }
  }

  @override
  Future<Map<String, String>> attachMailChangeListener({required OAuthEntity oauth, required UserEntity user}) async {
    await detachMailChangeListener(oauth: oauth);
    final googleHistoryIds = await watchMails(oauth: oauth, user: user);
    return googleHistoryIds;
  }

  @override
  Future<void> detachMailChangeListener({required OAuthEntity oauth}) async {
    await unwatchMails(oauth: oauth);
  }

  Future<Map<String, String>> watchMails({required OAuthEntity oauth, required UserEntity user}) async {
    final response = await watchMail(oauth, oauth.email);
    Map<String, String> gmailHistoryIdsForListener = {};
    if (response?.historyId != null) {
      gmailHistoryIdsForListener[oauth.email] = response!.historyId.toString();
    }
    return gmailHistoryIdsForListener;
  }

  Future<Gmail.WatchResponse?> watchMail(OAuthEntity oauth, String email) async {
    try {
      final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);
      Gmail.WatchResponse value = await Gmail.GmailApi(
        client,
      ).users.watch(Gmail.WatchRequest(topicName: 'projects/fillin-cd65f/topics/taskey-gmail-pubsub'), 'me');
      return value;
    } catch (e) {
      GoogleApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
      return null;
    }
  }

  Future<void> unwatchMails({required OAuthEntity oauth}) async {
    // final client = await GoogleApiHandler.getClient(oauth: oauth, scope: scopes, isMail: true);
    // await Gmail.GmailApi(client).users.stop('me');
    return;
  }
}
