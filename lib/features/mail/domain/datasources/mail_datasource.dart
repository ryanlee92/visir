import 'dart:async';
import 'dart:typed_data';

import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_fetch_result_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';

abstract class MailDatasource {
  Future<OAuthEntity?> integrate();

  Future<Map<String, List<MailLabelEntity>>> fetchLabelLists({required OAuthEntity oauth});

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
  });

  Future<List<MailEntity>> fetchThreads({required OAuthEntity oauth, required String threadId, String? email, required String labelId});

  Future<MailEntity?> fetchAddedMails({required OAuthEntity oauth, required String historyId, required String email, Map<String, String?>? pageToken});

  Future<Map<String, Uint8List?>> getAttachments({
    required String email,
    required String messageId,
    required OAuthEntity oauth,
    required List<String> attachmentIds,
  });

  Future<void> read({required List<MailEntity> mails, required OAuthEntity oauth});

  Future<void> unread({required List<MailEntity> mails, required OAuthEntity oauth});

  Future<void> star({required List<MailEntity> mails, required OAuthEntity oauth});

  Future<void> unstar({required List<MailEntity> mails, required OAuthEntity oauth});

  Future<void> important({required List<MailEntity> mails, required OAuthEntity oauth});

  Future<void> unimportant({required List<MailEntity> mails, required OAuthEntity oauth});

  Future<void> trash({required List<MailEntity> mails, required OAuthEntity oauth});

  Future<void> untrash({required List<MailEntity> mails, required OAuthEntity oauth});

  Future<void> spam({required List<MailEntity> mails, required OAuthEntity oauth});

  Future<void> unspam({required List<MailEntity> mails, required OAuthEntity oauth});

  Future<void> archive({required List<MailEntity> mails, required OAuthEntity oauth});

  Future<void> unarchive({required List<MailEntity> mails, required OAuthEntity oauth});

  Future<bool> delete({required List<MailEntity> mails, required OAuthEntity oauth});

  Future<List<String>> fetchSignature({required OAuthEntity oauth});

  Future<MailEntity?> send({required MailEntity mail, required OAuthEntity oauth});

  Future<MailEntity?> draft({required MailEntity mail, required OAuthEntity oauth});

  Future<void> deleteLabels({required String labelId, required OAuthEntity oauth});

  Future<Map<String, String>> attachMailChangeListener({required OAuthEntity oauth, required UserEntity user});

  Future<void> detachMailChangeListener({required OAuthEntity oauth});

  Future<bool> undraft({required MailEntity mail, required OAuthEntity oauth});

  Future<void> batchModify({required OAuthEntity oauth, List<String>? addLabels, List<String>? removeLabels, required List<String> messageIds});
}
