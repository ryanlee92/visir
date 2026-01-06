import 'dart:convert';

import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/list_extension.dart';
import 'package:Visir/features/common/presentation/utils/microsoft_api_handler.dart';
import 'package:Visir/features/mail/application/mail_label_list_controller.dart';
import 'package:Visir/features/mail/domain/datasources/mail_datasource.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_fetch_result_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/mail/infrastructure/models/outlook_mail_label.dart';
import 'package:Visir/features/mail/infrastructure/models/outlook_mail_message.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;
import 'package:microsoft_graph_api/microsoft_graph_api.dart';

final kMailFetchCount = 40;

class MicrosoftMailDatasource implements MailDatasource {
  MicrosoftMailDatasource();

  final _dio = Dio();

  static List<String> scopes = ['openid', 'profile', 'offline_access', 'User.Read', 'Mail.ReadWrite', 'Mail.Send', 'Contacts.Read'];

  @override
  Future<OAuthEntity?> integrate() async {
    final oauth = await MicrosoftApiHandler.integrate(scopes, 'mail');
    return oauth;
  }

  Future<Map<String, dynamic>> searchMessages({String? query, String? filter, required List<String> folderIds, String? nextPageToken, required String token}) async {
    try {
      final result = await searchMessagesForFolder(query: query, filter: filter, folderId: folderIds.firstOrNull, nextPageToken: nextPageToken, token: token);
      return result;
    } catch (e) {
      return {'messages': [], 'nextPageToken': null};
    }
  }

  Future<Map<String, dynamic>> searchMessagesForFolder({String? query, String? filter, String? folderId, String? nextPageToken, required String token}) async {
    try {
      String url;

      if (folderId != null) {
        url = 'https://graph.microsoft.com/v1.0/me/mailFolders/$folderId/messages';
      } else {
        url = 'https://graph.microsoft.com/v1.0/me/messages';
      }

      final queryParams = {if (query != null) '\$search': '"${query}"', if (filter != null) '\$filter': filter, '\$expand': 'attachments', '\$orderby': 'receivedDateTime desc'};

      url = nextPageToken ?? '${url}?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          // 'ConsistencyLevel': 'eventual',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newNextPageToken = data['@odata.nextLink'];

        final List<dynamic> messageList = data['value'];
        return {'messages': messageList.map((messageJson) => OutlookMailMessage.fromJson(messageJson)).toList(), 'nextPageToken': newNextPageToken};
      } else {
        return {'messages': [], 'nextPageToken': null};
      }
    } catch (e) {
      return {'messages': [], 'nextPageToken': null};
    }
  }

  @override
  Future<Map<String, List<MailLabelEntity>>> fetchLabelLists({required OAuthEntity oauth}) async {
    Map<String, List<MailLabelEntity>> labels = {};
    List<MailLabelEntity> details = await fetchLabelForOAuth(oauth: oauth);
    labels[oauth.email] = details;
    return labels;
  }

  Future<List<MailLabelEntity>> fetchLabelForOAuth({required OAuthEntity oauth}) async {
    final clientId = await MicrosoftApiHandler.getClientId();
    final accessToken = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, clientId: clientId, isMail: true);
    List<OutlookMailLabel> labels = [];

    final wellKnownNames = [
      'inbox',
      'archive',
      'deleteditems',
      'drafts',
      'sentitems',
      'junkemail',
      'clutter',
      'conflicts',
      'conversationhistory',
      'localfailures',
      'msgfolderroot',
      'outbox',
      'recoverableitemsdeletions',
      'scheduled',
      'searchfolders',
      'serverfailures',
      'syncissues',
    ];

    try {
      final msClient = MSGraphAPI(accessToken.data);
      final folders = await msClient.mail.getMailFolders();

      if (folders.isNotEmpty) {
        labels.addAll(folders.map((folder) => OutlookMailLabel.fromJson(folder.toJson())).toList());
      }

      final batchResDataValue = await MicrosoftApiHandler.batchRequest(
        requests: wellKnownNames.mapIndexed((i, e) => {'id': e, 'method': 'GET', 'url': '/me/mailFolders/$e'}).toList(),
        accessToken: accessToken,
      );

      for (int i = 0; i < batchResDataValue.length; i++) {
        final response = batchResDataValue[i];
        if (response == null) continue;
        final wellKnownName = response['id'];
        if (response['status'] == 200 && response['body'] != null) {
          final outlookLabel = OutlookMailLabel.fromJson({...response['body'], 'wellKnownName': wellKnownName});
          labels.removeWhere((e) => e.id == outlookLabel.id);
          labels.add(outlookLabel);
        }
      }
    } on DioException catch (error, stackTrace) {
      debugPrintStack(stackTrace: stackTrace);
    } catch (error, stackTrace) {
      debugPrintStack(stackTrace: stackTrace);
    }

    final labelDetails = labels.map((e) => MailLabelEntity(msLabel: e)).toList();
    wellKnownNames.removeWhere((e) => labels.any((element) => element.wellKnownName == e));

    return [
      ...labelDetails,
      // ...wellKnownNames.map((e) => MailLabelEntity(msLabel: OutlookMailLabel(id: e, displayName: e, wellKnownName: e))),
      MailLabelEntity(msLabel: OutlookMailLabel(id: CommonMailLabels.unread.id, displayName: null)),
      MailLabelEntity(msLabel: OutlookMailLabel(id: CommonMailLabels.pinned.id, displayName: null)),
    ]..sort((a, b) => a.id?.compareTo(b.id ?? '') ?? 0);
  }

  @override
  Future<List<String>> fetchSignature({required OAuthEntity oauth}) async {
    // not supported on graph api
    return [];
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
      labelIds: labelId != null
          ? labelId == CommonMailLabels.all.id
                ? null
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
      oauth: oauth,
    );

    messages[oauth.email] = result;
    return messages;
  }

  Future<MailFetchResultEntity> fetchMailListsForOAuth({
    List<String>? labelIds,
    Map<String, String?>? pageToken,
    String? email,
    String? q,
    DateTime? startDate,
    DateTime? endDate,
    required OAuthEntity oauth,
  }) async {
    List<String> filters = [];

    if (startDate != null) {
      filters.add('ReceivedDateTime ge ${startDate.toUtc().toIso8601String()}');
    }

    if (endDate != null) {
      filters.add('ReceivedDateTime lt ${endDate.toUtc().toIso8601String()}');
    }

    String? query = q;
    String? filter = filters.isNotEmpty ? '${filters.join(' and ')}' : null;

    if (query?.isNotEmpty != true) query = null;

    if (email == null || email == oauth.email) {
      if (pageToken != null && pageToken[oauth.email] == null) return MailFetchResultEntity(hasMore: false, messages: []);
      ;

      final clientId = await MicrosoftApiHandler.getClientId();
      List<MailEntity> data;
      String? nextPageToken = pageToken?[oauth.email] != null ? pageToken![oauth.email] : null;
      final accessToken = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, clientId: clientId, isMail: true);

      if (labelIds?.length == 1 && labelIds?.first == CommonMailLabels.draft.id) {
        try {
          final value = await searchMessages(folderIds: ['drafts'], query: query, nextPageToken: nextPageToken, filter: filter, token: accessToken.data);
          final draftValues = (value['messages'] as List<OutlookMailMessage>).where((e) => e.id != null).toList().unique((e) => e.id);
          nextPageToken = value['nextPageToken'];
          data = draftValues
              .map((e) {
                e = e.copyWith(labelIds: [CommonMailLabels.draft.id]);
                return MailEntity.fromOutlook(message: e, thread: [e], hostEmail: oauth.email, pageToken: nextPageToken, draftId: e.id);
              })
              .whereType<MailEntity>()
              .toList();
        } catch (e) {
          MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
          throw e;
        }
      } else {
        if (labelIds?.length == 1 && labelIds?.first == CommonMailLabels.unread.id) {
          labelIds = [CommonMailLabels.inbox.id];
          filter = '${filter?.isNotEmpty == true ? '$filter and ' : ''} isRead eq false';
        }

        if (labelIds?.length == 1 && labelIds?.first == CommonMailLabels.pinned.id) {
          labelIds = [CommonMailLabels.inbox.id];
          filter = '${filter?.isNotEmpty == true ? '$filter and ' : ''} flag/flagStatus eq \'flagged\'';
        }

        try {
          final folderIds = MailLabelListController.labels.keys.isEmpty
              ? labelIds?.map((e) => CommonMailLabels.values.where((i) => i.id == e).firstOrNull?.msId ?? e).toList()
              : labelIds?.map((labelId) => MailLabelListController.labels[oauth.email]?.firstWhereOrNull((e) => e.id == labelId)?.searchId).whereType<String>().toList();

          final value = await searchMessages(folderIds: folderIds ?? [], query: query, nextPageToken: nextPageToken, filter: filter, token: accessToken.data);

          nextPageToken = value['nextPageToken'];
          final messages = (value['messages'] as List<OutlookMailMessage>)
              .where((e) => e.id != null)
              .map(
                (e) => e.copyWith(
                  labelIds: [...labelIds ?? [], if (e.isRead == false) CommonMailLabels.unread.id, if (e.followupFlag?.flagStatus == 'flagged') CommonMailLabels.pinned.id],
                ),
              )
              .toList()
              .unique((e) => e.id);

          if (messages.isEmpty) {
            return MailFetchResultEntity(hasMore: false, messages: []);
          }

          final response = await MicrosoftApiHandler.batchRequest(
            requests: messages.mapIndexed((i, e) => {'id': e.id, 'method': 'GET', 'url': '/me/messages?\$filter=conversationId eq \'${e.conversationId!}\'&\$top=100'}).toList(),
            accessToken: accessToken,
          );

          data = response
              .map((e) {
                final messageId = e['id'];
                final anchorMessage = messages.firstWhereOrNull((e) => e.id == messageId);

                if (anchorMessage == null) return null;
                if (e['status'] != 200 || e['body'] == null) return null;

                List<OutlookMailMessage> list = (e['body']['value'] as List)
                    .map((e) {
                      OutlookMailMessage message = OutlookMailMessage.fromJson(e);
                      message = message.copyWith(
                        labelIds: [
                          ...labelIds ?? [],
                          if (message.isRead == false) CommonMailLabels.unread.id,
                          if (message.followupFlag?.flagStatus == 'flagged') CommonMailLabels.pinned.id,
                        ],
                      );
                      return message;
                    })
                    .whereType<OutlookMailMessage>()
                    .toList();

                return MailEntity.fromOutlook(message: anchorMessage, thread: list, hostEmail: oauth.email, pageToken: nextPageToken);
              })
              .whereType<MailEntity>()
              .toList();
        } catch (e) {
          MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
          return MailFetchResultEntity(hasMore: nextPageToken != null, messages: [], nextPageToken: nextPageToken, isRateLimited: true);
        }
      }

      return MailFetchResultEntity(hasMore: nextPageToken != null, messages: data, nextPageToken: nextPageToken);
    }

    return MailFetchResultEntity(hasMore: false, messages: []);
  }

  @override
  Future<MailEntity?> fetchAddedMails({required OAuthEntity oauth, required String historyId, required String email, Map<String, String?>? pageToken}) async {
    // only for gmail
    return null;
  }

  @override
  Future<List<MailEntity>> fetchThreads({required OAuthEntity oauth, required String threadId, required String labelId, String? email}) async {
    if (email == null || email == oauth.email) {
      final clientId = await MicrosoftApiHandler.getClientId();
      final accessToken = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, clientId: clientId, isMail: true);

      final res = await http.get(
        Uri.parse('https://graph.microsoft.com/v1.0/me/messages?\$filter=conversationId eq \'${threadId}\'&\$top=1000&\$expand=attachments'),
        headers: {'Authorization': 'Bearer ${accessToken.data}'},
      );

      List<OutlookMailMessage> list = json
          .decode(res.body)['value']
          .map((e) {
            OutlookMailMessage message = OutlookMailMessage.fromJson(e);
            message = message.copyWith(
              labelIds: [labelId, if (message.isRead == false) CommonMailLabels.unread.id, if (message.followupFlag?.flagStatus == 'flagged') CommonMailLabels.pinned.id],
            );
            return message;
          })
          .whereType<OutlookMailMessage>()
          .toList();

      return list.map((e) => MailEntity.fromOutlook(message: e, hostEmail: oauth.email)).toList();
    }
    return [];
  }

  Future<MailEntity?> getMail({required OAuthEntity oauth, required AccessToken token, required String email, required String messageId}) async {
    final response = await http.get(Uri.parse('https://graph.microsoft.com/v1.0/me/messages/$messageId?\$expand=attachments'), headers: {'Authorization': 'Bearer ${token.data}'});
    final data = json.decode(response.body);
    OutlookMailMessage mail = OutlookMailMessage.fromJson(data);

    final labelId =
        (MailLabelListController.labels.keys.isEmpty
            ? CommonMailLabels.values.where((i) => i.msId == mail.parentFolderId).firstOrNull?.id
            : MailLabelListController.labels[email]?.firstWhereOrNull((e) => e.folderId == mail.parentFolderId)?.id) ??
        mail.parentFolderId ??
        CommonMailLabels.inbox.id;

    mail = mail.copyWith(labelIds: [labelId, if (mail.isRead == false) CommonMailLabels.unread.id, if (mail.followupFlag?.flagStatus == 'flagged') CommonMailLabels.pinned.id]);

    final threads = mail.conversationId == null
        ? [MailEntity.fromOutlook(message: mail, hostEmail: email)]
        : await fetchThreads(oauth: oauth, email: email, labelId: labelId, threadId: mail.conversationId!);
    final msThreads = threads.map((e) => e.msMessage).whereType<OutlookMailMessage>().toList();

    return MailEntity.fromOutlook(
      message: mail,
      hostEmail: email,
      draftId: labelId == CommonMailLabels.draft.id ? mail.id : null,
      thread: msThreads.isNotEmpty ? msThreads : [mail],
    );
  }

  @override
  Future<Map<String, Uint8List?>> getAttachments({required OAuthEntity oauth, required String email, required String messageId, required List<String> attachmentIds}) async {
    if (email == oauth.email) {
      final clientId = await MicrosoftApiHandler.getClientId();
      final accessToken = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, clientId: clientId, isMail: true);
      try {
        final msClient = MSGraphAPI(accessToken.data);
        final attachments = await msClient.mail.getAttachments(messageId);

        return Map.fromEntries(attachments.map((e) => MapEntry(e.id ?? '', e.contentBytes == null ? null : Uint8List.fromList(base64Decode(e.contentBytes!)))));
      } catch (e) {
        MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }
    return {};
  }

  @override
  Future<void> read({required List<MailEntity> mails, required OAuthEntity oauth}) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);

    final emailMails = groupedMails[oauth.email];
    if (emailMails?.isNotEmpty == true) {
      final clientId = await MicrosoftApiHandler.getClientId();
      final accessToken = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, clientId: clientId, isMail: true);
      final msClient = MSGraphAPI(accessToken.data);
      try {
        if (emailMails!.length == 1) {
          await msClient.mail.markAsRead(emailMails.first.id!, true);
        } else {
          await MicrosoftApiHandler.batchRequest(
            requests: emailMails
                .map(
                  (e) => {
                    'id': e.id,
                    'method': 'PATCH',
                    'url': 'https://graph.microsoft.com/v1.0/me/messages/${e.id!}',
                    'body': {'isRead': true},
                    'headers': {'Content-Type': 'application/json'},
                  },
                )
                .toList(),
            accessToken: accessToken,
          );
        }
      } catch (e) {
        MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }

    return null;
  }

  @override
  Future<void> unread({required List<MailEntity> mails, required OAuthEntity oauth}) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    final emailMails = groupedMails[oauth.email];
    if (emailMails?.isNotEmpty == true) {
      final accessToken = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, isMail: true);
      final msClient = MSGraphAPI(accessToken.data);
      try {
        if (emailMails!.length == 1) {
          await msClient.mail.markAsRead(emailMails.first.id!, false);
        } else {
          await MicrosoftApiHandler.batchRequest(
            requests: emailMails
                .map(
                  (e) => {
                    'id': e.id,
                    'method': 'PATCH',
                    'url': 'https://graph.microsoft.com/v1.0/me/messages/${e.id!}',
                    'body': {'isRead': false},
                    'headers': {'Content-Type': 'application/json'},
                  },
                )
                .toList(),
            accessToken: accessToken,
          );
        }
      } catch (e) {
        MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }
  }

  @override
  Future<void> star({required List<MailEntity> mails, required OAuthEntity oauth}) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);

    final emailMails = groupedMails[oauth.email];
    if (emailMails?.isNotEmpty == true) {
      final clientId = await MicrosoftApiHandler.getClientId();
      final accessToken = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, clientId: clientId, isMail: true);
      final msClient = MSGraphAPI(accessToken.data);
      try {
        if (emailMails!.length == 1) {
          await msClient.mail.setFlag(emailMails.first.id!, 'flagged');
        } else {
          await MicrosoftApiHandler.batchRequest(
            requests: emailMails
                .map(
                  (e) => {
                    'id': e.id,
                    'method': 'PATCH',
                    'url': 'https://graph.microsoft.com/v1.0/me/messages/${e.id!}',
                    'body': {
                      'flag': {'flagStatus': 'flagged'},
                    },
                    'headers': {'Content-Type': 'application/json'},
                  },
                )
                .toList(),
            accessToken: accessToken,
          );
        }
      } catch (e) {
        MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }
  }

  @override
  Future<void> unstar({required List<MailEntity> mails, required OAuthEntity oauth}) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);

    final emailMails = groupedMails[oauth.email];
    if (emailMails?.isNotEmpty == true) {
      final clientId = await MicrosoftApiHandler.getClientId();
      final accessToken = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, clientId: clientId, isMail: true);
      final msClient = MSGraphAPI(accessToken.data);
      try {
        if (emailMails!.length == 1) {
          await msClient.mail.setFlag(emailMails.first.id!, 'notFlagged');
        } else {
          await MicrosoftApiHandler.batchRequest(
            requests: emailMails
                .map(
                  (e) => {
                    'id': e.id,
                    'method': 'PATCH',
                    'url': 'https://graph.microsoft.com/v1.0/me/messages/${e.id!}',
                    'body': {
                      'flag': {'flagStatus': 'notFlagged'},
                    },
                    'headers': {'Content-Type': 'application/json'},
                  },
                )
                .toList(),
            accessToken: accessToken,
          );
        }
      } catch (e) {
        MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }
  }

  @override
  Future<void> important({required List<MailEntity> mails, required OAuthEntity oauth}) async {
    // not work on outlook mail
    throw UnimplementedError();
  }

  @override
  Future<void> unimportant({required List<MailEntity> mails, required OAuthEntity oauth}) async {
    // not work on outlook mail
    throw UnimplementedError();
  }

  @override
  Future<void> trash({required List<MailEntity> mails, required OAuthEntity oauth}) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);
    final emailMails = groupedMails[oauth.email];
    if (emailMails?.isNotEmpty == true) {
      final clientId = await MicrosoftApiHandler.getClientId();
      final accessToken = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, clientId: clientId, isMail: true);
      try {
        if (emailMails!.length == 1) {
          await _dio.post(
            'https://graph.microsoft.com/v1.0/me/messages/${emailMails.first.id!}/move',
            data: {'destinationId': 'deleteditems'},
            options: Options(headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${accessToken.data}'}),
          );
        } else {
          await MicrosoftApiHandler.batchRequest(
            requests: emailMails
                .map(
                  (e) => {
                    'id': e.id,
                    'method': 'POST',
                    'url': '/me/messages/${e.id!}/move',
                    'body': {'destinationId': 'deleteditems'},
                    'headers': {'Content-Type': 'application/json', 'Authorization': 'Bearer ${accessToken.data}'},
                  },
                )
                .toList(),
            accessToken: accessToken,
          );
        }
      } catch (e) {
        MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }
  }

  @override
  Future<void> untrash({required List<MailEntity> mails, required OAuthEntity oauth}) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);

    final emailMails = groupedMails[oauth.email];
    if (emailMails?.isNotEmpty == true) {
      final clientId = await MicrosoftApiHandler.getClientId();
      final accessToken = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, clientId: clientId, isMail: true);

      try {
        if (emailMails!.length == 1) {
          await _dio.post(
            'https://graph.microsoft.com/v1.0/me/messages/${emailMails.first.id!}/move',
            data: {'destinationId': 'inbox'},
            options: Options(headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${accessToken.data}'}),
          );
        } else {
          await MicrosoftApiHandler.batchRequest(
            requests: emailMails
                .map(
                  (e) => {
                    'id': e.id,
                    'method': 'POST',
                    'url': '/me/messages/${e.id!}/move',
                    'body': {'destinationId': 'inbox'},
                    'headers': {'Content-Type': 'application/json', 'Authorization': 'Bearer ${accessToken.data}'},
                  },
                )
                .toList(),
            accessToken: accessToken,
          );
        }
      } catch (e) {
        MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }
  }

  @override
  Future<void> spam({required List<MailEntity> mails, required OAuthEntity oauth}) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);

    final emailMails = groupedMails[oauth.email];
    if (emailMails?.isNotEmpty == true) {
      final clientId = await MicrosoftApiHandler.getClientId();
      final accessToken = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, clientId: clientId, isMail: true);
      try {
        if (emailMails!.length == 1) {
          await _dio.post(
            'https://graph.microsoft.com/v1.0/me/messages/${emailMails.first.id!}/move',
            data: {'destinationId': 'junkemail'},
            options: Options(headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${accessToken.data}'}),
          );
        } else {
          await MicrosoftApiHandler.batchRequest(
            requests: emailMails
                .map(
                  (e) => {
                    'id': e.id,
                    'method': 'POST',
                    'url': '/me/messages/${e.id!}/move',
                    'body': {'destinationId': 'junkemail'},
                    'headers': {'Content-Type': 'application/json', 'Authorization': 'Bearer ${accessToken.data}'},
                  },
                )
                .toList(),
            accessToken: accessToken,
          );
        }
      } catch (e) {
        MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }
  }

  @override
  Future<void> unspam({required List<MailEntity> mails, required OAuthEntity oauth}) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);

    final emailMails = groupedMails[oauth.email];
    if (emailMails?.isNotEmpty == true) {
      final clientId = await MicrosoftApiHandler.getClientId();
      final accessToken = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, clientId: clientId, isMail: true);

      try {
        if (emailMails!.length == 1) {
          await _dio.post(
            'https://graph.microsoft.com/v1.0/me/messages/${emailMails.first.id!}/move',
            data: {'destinationId': 'inbox'},
            options: Options(headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${accessToken.data}'}),
          );
        } else {
          await MicrosoftApiHandler.batchRequest(
            requests: emailMails
                .map(
                  (e) => {
                    'id': e.id,
                    'method': 'POST',
                    'url': '/me/messages/${e.id!}/move',
                    'body': {'destinationId': 'inbox'},
                    'headers': {'Content-Type': 'application/json', 'Authorization': 'Bearer ${accessToken.data}'},
                  },
                )
                .toList(),
            accessToken: accessToken,
          );
        }
      } catch (e) {
        MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }
  }

  @override
  Future<void> archive({required List<MailEntity> mails, required OAuthEntity oauth}) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);

    final emailMails = groupedMails[oauth.email];
    if (emailMails?.isNotEmpty == true) {
      final clientId = await MicrosoftApiHandler.getClientId();
      final accessToken = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, clientId: clientId, isMail: true);
      try {
        if (emailMails!.length == 1) {
          await _dio.post(
            'https://graph.microsoft.com/v1.0/me/messages/${emailMails.first.id!}/move',
            data: {'destinationId': 'archive'},
            options: Options(headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${accessToken.data}'}),
          );
        } else {
          await MicrosoftApiHandler.batchRequest(
            requests: emailMails
                .map(
                  (e) => {
                    'id': e.id,
                    'method': 'POST',
                    'url': '/me/messages/${e.id!}/move',
                    'body': {'destinationId': 'archive'},
                    'headers': {'Content-Type': 'application/json', 'Authorization': 'Bearer ${accessToken.data}'},
                  },
                )
                .toList(),
            accessToken: accessToken,
          );
        }
      } catch (e) {
        MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }
  }

  @override
  Future<void> unarchive({required List<MailEntity> mails, required OAuthEntity oauth}) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);

    final emailMails = groupedMails[oauth.email];
    if (emailMails?.isNotEmpty == true) {
      final clientId = await MicrosoftApiHandler.getClientId();
      final accessToken = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, clientId: clientId, isMail: true);
      try {
        if (emailMails!.length == 1) {
          await _dio.post(
            'https://graph.microsoft.com/v1.0/me/messages/${emailMails.first.id!}/move',
            data: {'destinationId': 'inbox'},
            options: Options(headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${accessToken.data}'}),
          );
        } else {
          await MicrosoftApiHandler.batchRequest(
            requests: emailMails
                .map(
                  (e) => {
                    'id': e.id,
                    'method': 'POST',
                    'url': '/me/messages/${e.id!}/move',
                    'body': {'destinationId': 'inbox'},
                    'headers': {'Content-Type': 'application/json', 'Authorization': 'Bearer ${accessToken.data}'},
                  },
                )
                .toList(),
            accessToken: accessToken,
          );
        }
      } catch (e) {
        MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }
  }

  @override
  Future<bool> delete({required List<MailEntity> mails, required OAuthEntity oauth}) async {
    final groupedMails = groupBy(mails, (e) => e.hostEmail);

    final emailMails = groupedMails[oauth.email];
    if (emailMails?.isNotEmpty == true) {
      final clientId = await MicrosoftApiHandler.getClientId();
      final accessToken = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, clientId: clientId, isMail: true);
      final msClient = MSGraphAPI(accessToken.data);
      try {
        if (emailMails!.length == 1) {
          await msClient.mail.deleteMessage(emailMails.first.id!);
        } else {
          await MicrosoftApiHandler.batchRequest(
            requests: emailMails.map((e) => {'id': e.id, 'method': 'POST', 'url': '/me/messages/${e.id!}/permanentDelete'}).toList(),
            accessToken: accessToken,
          );
        }
      } catch (e) {
        MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }

    return false;
  }

  @override
  Future<MailEntity?> send({required MailEntity mail, required OAuthEntity oauth}) async {
    final messageMap = {
      'subject': mail.subject ?? '',
      'body': {'contentType': 'html', 'content': mail.html},
      if (mail.from != null)
        'from': {
          'emailAddress': {'address': mail.from?.email, 'name': mail.from?.name},
        },
      if (mail.to.isNotEmpty)
        'toRecipients': mail.to
            .map(
              (e) => {
                'emailAddress': {'address': e.email, 'name': e.name},
              },
            )
            .toList(),
      if (mail.cc.isNotEmpty)
        'ccRecipients': mail.cc
            .map(
              (e) => {
                'emailAddress': {'address': e.email, 'name': e.name},
              },
            )
            .toList(),
      if (mail.bcc.isNotEmpty)
        'bccRecipients': mail.bcc
            .map(
              (e) => {
                'emailAddress': {'address': e.email, 'name': e.name},
              },
            )
            .toList(),
      if (mail.msMessage?.attachments?.isNotEmpty == true)
        'attachments': mail.msMessage?.attachments
            ?.map((e) => {"@odata.type": "#microsoft.graph.fileAttachment", ...(e.toJson()..removeWhere((key, value) => value == null))})
            .toList(),
    };

    if (mail.hostEmail == oauth.email) {
      final clientId = await MicrosoftApiHandler.getClientId();
      final accessToken = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, clientId: clientId, isMail: true);
      final msClient = MSGraphAPI(accessToken.data);
      try {
        if (mail.isDraft) {
          final updateResult = await msClient.mail.updateMessage(mail.draftId!, messageMap);
          if (!updateResult) return null;
          final sendResult = await msClient.mail.sendDraft(mail.draftId!);
          if (!sendResult) return null;
          final messageResponse = await _dio.get(
            'https://graph.microsoft.com/v1.0/me/messages/${mail.draftId}',
            options: Options(headers: {'Authorization': 'Bearer ${accessToken.data}'}),
          );

          return MailEntity.fromOutlook(
            message: OutlookMailMessage.fromJson(messageResponse.data).copyWith(labelIds: [CommonMailLabels.sent.id]),
            hostEmail: oauth.email,
          );
        } else {
          final response = await _dio.post(
            'https://graph.microsoft.com/v1.0/me/messages',
            options: Options(headers: {'Authorization': 'Bearer ${accessToken.data}', 'Content-Type': 'application/json'}),
            data: messageMap,
          );
          if (response.statusCode != 201) return null;
          final messageId = response.data['id'];
          final sendResult = await msClient.mail.sendDraft(messageId);
          if (!sendResult) return null;

          final messageResponse = await _dio.get(
            'https://graph.microsoft.com/v1.0/me/messages/${messageId}',
            options: Options(headers: {'Authorization': 'Bearer ${accessToken.data}'}),
          );

          return MailEntity.fromOutlook(
            message: OutlookMailMessage.fromJson(messageResponse.data).copyWith(labelIds: [CommonMailLabels.sent.id]),
            hostEmail: oauth.email,
          );
        }
      } catch (e) {
        MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }
    return null;
  }

  @override
  Future<MailEntity?> draft({required MailEntity mail, required OAuthEntity oauth}) async {
    final messageMap = {
      if (mail.subject != null) 'subject': mail.subject,
      if (mail.html != null) 'body': {'contentType': 'html', 'content': mail.html},
      if (mail.from != null)
        'from': {
          'emailAddress': {'address': mail.from?.email, 'name': mail.from?.name},
        },
      if (mail.to.isNotEmpty)
        'toRecipients': mail.to
            .map(
              (e) => {
                'emailAddress': {'address': e.email, 'name': e.name},
              },
            )
            .toList(),
      if (mail.cc.isNotEmpty)
        'ccRecipients': mail.cc
            .map(
              (e) => {
                'emailAddress': {'address': e.email, 'name': e.name},
              },
            )
            .toList(),
      if (mail.bcc.isNotEmpty)
        'bccRecipients': mail.bcc
            .map(
              (e) => {
                'emailAddress': {'address': e.email, 'name': e.name},
              },
            )
            .toList(),
      if (mail.msMessage?.attachments?.isNotEmpty == true)
        'attachments': mail.msMessage?.attachments
            ?.map((e) => {"@odata.type": "#microsoft.graph.fileAttachment", ...(e.toJson()..removeWhere((key, value) => value == null))})
            .toList(),
    };

    if (mail.hostEmail == oauth.email) {
      final clientId = await MicrosoftApiHandler.getClientId();
      final accessToken = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, clientId: clientId, isMail: true);

      try {
        if (mail.draftId != null) {
          final updateResult = await _dio.patch(
            'https://graph.microsoft.com/v1.0/me/messages/${mail.draftId}',
            options: Options(headers: {'Authorization': 'Bearer ${accessToken.data}', 'Content-Type': 'application/json'}),
            data: messageMap,
          );
          if (updateResult.statusCode != 200) return null;
          final messageResponse = await _dio.get(
            'https://graph.microsoft.com/v1.0/me/messages/${mail.draftId}',
            options: Options(headers: {'Authorization': 'Bearer ${accessToken.data}'}),
          );
          final message = OutlookMailMessage.fromJson(messageResponse.data).copyWith(labelIds: [CommonMailLabels.draft.id]);
          return MailEntity.fromOutlook(message: message, hostEmail: oauth.email, draftId: message.id);
        } else {
          final response = await _dio.post(
            'https://graph.microsoft.com/v1.0/me/messages',
            options: Options(headers: {'Authorization': 'Bearer ${accessToken.data}', 'Content-Type': 'application/json'}),
            data: messageMap,
          );
          final message = OutlookMailMessage.fromJson(response.data).copyWith(labelIds: [CommonMailLabels.draft.id]);
          return MailEntity.fromOutlook(message: message, hostEmail: oauth.email, draftId: message.id);
        }
      } catch (e) {
        MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }

    return null;
  }

  @override
  Future<bool> undraft({required MailEntity mail, required OAuthEntity oauth}) async {
    if (mail.hostEmail == oauth.email) {
      final clientId = await MicrosoftApiHandler.getClientId();
      final accessToken = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, clientId: clientId, isMail: true);
      final msClient = MSGraphAPI(accessToken.data);
      try {
        await msClient.mail.deleteMessage(mail.draftId!);
        return true;
      } catch (e) {
        MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
        throw e;
      }
    }

    return false;
  }

  @override
  Future<void> deleteLabels({required String labelId, required OAuthEntity oauth}) async {
    final accessToken = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, isMail: true);
    try {
      final messageIds = await getMessageIds(oauth: oauth, folderId: labelId, pageToken: null);
      if (messageIds.isEmpty) return;

      await MicrosoftApiHandler.batchRequest(requests: messageIds.mapIndexed((i, e) => {'id': e, 'method': 'DELETE', 'url': '/me/messages/$e'}).toList(), accessToken: accessToken);
    } catch (e) {
      MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
      throw e;
    }
  }

  @override
  Future<void> batchModify({required OAuthEntity oauth, List<String>? addLabels, List<String>? removeLabels, required List<String> messageIds}) async {
    final accessToken = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, isMail: true);
    try {
      final requests = messageIds
          .mapIndexed((i, e) {
            List result = [];
            bool isUpdate =
                addLabels?.contains(CommonMailLabels.unread.id) == true ||
                removeLabels?.contains(CommonMailLabels.unread.id) == true ||
                addLabels?.contains(CommonMailLabels.pinned.id) == true ||
                removeLabels?.contains(CommonMailLabels.pinned.id) == true;
            if (isUpdate) {
              result.add({
                'id': e,
                'method': 'PATCH',
                'url': '/me/messages/$e',
                'body': {
                  if (addLabels?.contains(CommonMailLabels.unread.id) == true) 'isRead': false,
                  if (removeLabels?.contains(CommonMailLabels.unread.id) == true) 'isRead': true,
                  if (addLabels?.contains(CommonMailLabels.pinned.id) == true) 'flag/flagStatus': 'flagged',
                  if (removeLabels?.contains(CommonMailLabels.pinned.id) == true) 'flag/flagStatus': 'notFlagged',
                },
                'headers': {'Content-Type': 'application/json'},
              });
            }

            bool moveToInbox =
                addLabels?.contains(CommonMailLabels.inbox.id) == true ||
                removeLabels?.contains(CommonMailLabels.trash.id) == true ||
                removeLabels?.contains(CommonMailLabels.spam.id) == true ||
                removeLabels?.contains(CommonMailLabels.archive.id) == true;

            bool moveToTrash = addLabels?.contains(CommonMailLabels.trash.id) == true;
            bool moveToSpam = addLabels?.contains(CommonMailLabels.spam.id) == true;
            bool moveToArchive = addLabels?.contains(CommonMailLabels.archive.id) == true;

            if (moveToInbox || moveToTrash || moveToSpam || moveToArchive) {
              result.add({
                'id': e,
                'method': 'POST',
                'url': '/me/messages/$e/move',
                'body': {
                  if (moveToInbox) 'destinationId': 'inbox',
                  if (moveToTrash) 'destinationId': 'trash',
                  if (moveToSpam) 'destinationId': 'spam',
                  if (moveToArchive) 'destinationId': 'archive',
                },
                'headers': {'Content-Type': 'application/json', 'Authorization': 'Bearer ${accessToken.data}'},
              });
            }

            return result;
          })
          .expand((e) => e)
          .toList();

      await MicrosoftApiHandler.batchRequest(requests: requests, accessToken: accessToken);
    } catch (e) {
      MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
      throw e;
    }
  }

  Future<List<String>> getMessageIds({required OAuthEntity oauth, required String folderId, String? pageToken}) async {
    List<String> messageIds = [];
    try {
      final accessToken = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, isMail: true);

      final queryParams = {'\$select': 'id'};

      final response = await http.get(
        Uri.parse(
          'https://graph.microsoft.com/v1.0/me/mailFolders/$folderId/messages?${Uri.encodeQueryComponent(queryParams.entries.map((e) => '${e.key}=${e.value}').join('&'))}',
        ),
        headers: {'Authorization': 'Bearer ${accessToken.data}', 'ConsistencyLevel': 'eventual'},
      );

      final fetchResult = response.statusCode == 200 ? json.decode(response.body) : null;

      final data = json.decode(response.body);
      final nextPageToken = data['@odata.nextLink'];

      if (fetchResult != null) messageIds.addAll(fetchResult['value'].map((messageJson) => messageJson['id'].toString()).toList());
      if (nextPageToken != null) {
        final pageIds = await getMessageIds(oauth: oauth, folderId: folderId, pageToken: nextPageToken);
        messageIds.addAll(pageIds);
      }

      return messageIds;
    } catch (e) {
      MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
      throw e;
    }
  }

  @override
  Future<Map<String, String>> attachMailChangeListener({required OAuthEntity oauth, required UserEntity user}) async {
    await detachMailChangeListener(oauth: oauth);
    final microsoftHistoryIds = await watchMails(oauth: oauth, user: user);
    return microsoftHistoryIds;
  }

  @override
  Future<void> detachMailChangeListener({required OAuthEntity oauth}) async {
    await unwatchMails(oauth: oauth);
  }

  Future<Map<String, String>> watchMails({required OAuthEntity oauth, required UserEntity user}) async {
    final token = await MicrosoftApiHandler.getToken(oauth: oauth, scope: scopes, isMail: true);
    final result = await watchMail(oauth, token, oauth.email);
    return {oauth.email: result ?? ''};
  }

  Future<String?> watchMail(OAuthEntity oauth, AccessToken accessToken, String email) async {
    try {
      final listResponse = await http.get(
        Uri.parse('https://graph.microsoft.com/v1.0/subscriptions'),
        headers: {'Authorization': 'Bearer ${accessToken.data}', 'Content-Type': 'application/json'},
      );

      final data = jsonDecode(listResponse.body);
      final subscriptions = List<Map<String, dynamic>>.from(data['value']);
      final targetResource = 'me/messages';

      final filtered = subscriptions.where((s) => s['resource'] == targetResource).toList();

      List<dynamic> subscriptionIds = filtered.map((e) => {'id': e['id'], 'email': e['notificationQueryOptions']}).toList();

      final rightSubscriptionId = subscriptionIds.firstWhereOrNull((e) => e['email'] == email);

      if (subscriptionIds.isNotEmpty) {
        final removeSubscriptionIds = [...subscriptionIds]..removeWhere((e) => e['id'] == rightSubscriptionId?['id']);
        if (removeSubscriptionIds.isNotEmpty) {
          removeSubscriptionIds.forEach((e) async {
            await http.delete(Uri.parse('https://graph.microsoft.com/v1.0/subscriptions/${e['id']}'), headers: {'Authorization': 'Bearer ${accessToken.data}'});
          });
        }
      }

      if (rightSubscriptionId != null) {
        await http.patch(Uri.parse('https://graph.microsoft.com/v1.0/subscriptions/${rightSubscriptionId['id']}'), headers: {'Authorization': 'Bearer ${accessToken.data}'});

        return rightSubscriptionId['id'];
      } else {
        final response = await http.post(
          Uri.parse('https://graph.microsoft.com/v1.0/subscriptions'),
          body: jsonEncode({
            "changeType": "created,updated,deleted",
            "notificationUrl": "https://handleoutlookmailnotification-37eiuas3wa-uc.a.run.app",
            "resource": targetResource,
            "expirationDateTime": DateTime.now().add(Duration(minutes: 10070)).toUtc().toIso8601String(),
            "notificationQueryOptions": oauth.email,
            "clientState": oauth.email,
          }),
          headers: {'Authorization': 'Bearer ${accessToken.data}', 'Content-Type': 'application/json'},
        );
        final subscriptionId = json.decode(response.body)['id'];
        return subscriptionId;
      }
    } catch (e) {
      MicrosoftApiHandler.checkAuthNotWork(oauth, e.toString(), isMail: true);
      return null;
    }
  }

  Future<void> unwatchMails({required OAuthEntity oauth}) async {}

  Future<void> unwatchMail(OAuthEntity oauth, String email) async {}
}
