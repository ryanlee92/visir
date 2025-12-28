import 'dart:async';
import 'dart:typed_data';

import 'package:Visir/features/auth/domain/entities/user_entity.dart';
import 'package:Visir/features/common/domain/failures/failure.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/mail/domain/datasources/mail_datasource.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_fetch_result_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:collection/collection.dart';
import 'package:fpdart/src/either.dart';

class MailRepository {
  final Map<DatasourceType, MailDatasource> datasources;

  MailRepository({required this.datasources});

  Future<Either<Failure, OAuthEntity>> integrate({required OAuthType type}) async {
    try {
      final oauth = await datasources[type.datasourceType]?.integrate();
      return right(oauth!);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, Map<String, Uint8List?>>> fetchAttachments({
    required String email,
    required String messageId,
    required OAuthEntity oauth,
    required List<String> attachmentIds,
  }) async {
    try {
      final result = await datasources[oauth.type.datasourceType]?.getAttachments(email: email, messageId: messageId, oauth: oauth, attachmentIds: attachmentIds);
      return right(result ?? {});
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, Map<String, List<MailLabelEntity>>>> fetchLabels({required OAuthEntity oauth}) async {
    try {
      final datasource = datasources[oauth.type.datasourceType];
      if (datasource == null) {
        return right({});
      }
      final list = await datasource.fetchLabelLists(oauth: oauth);
      return right(list);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, List<String>>> fetchSignature({required OAuthEntity oauth}) async {
    try {
      final list = await datasources[oauth.type.datasourceType]?.fetchSignature(oauth: oauth);
      return right(list ?? []);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, Map<String, MailFetchResultEntity>>> fetchMailsForLabel({
    required OAuthEntity oauth,
    required UserEntity user,
    required bool isInbox,
    String? labelId,
    String? email,
    Map<String, String?>? pageToken,
    String? q,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final list = await datasources[oauth.type.datasourceType]?.fetchMailLists(
        oauth: oauth,
        isInbox: isInbox,
        labelId: labelId,
        user: user,
        pageToken: pageToken,
        email: email,
        q: q,
        startDate: startDate,
        endDate: endDate,
      );
      return right(list ?? {});
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, MailEntity?>> fetchAddedMails({required OAuthEntity oauth, required String historyId, required String email}) async {
    try {
      final result = await datasources[oauth.type.datasourceType]?.fetchAddedMails(oauth: oauth, historyId: historyId, email: email);
      return right(result);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, List<MailEntity>>> fetchThreads({
    required OAuthEntity oauth,
    required MailEntityType type,
    required String threadId,
    required String labelId,
    String? email,
    bool? fetchLocal,
  }) async {
    try {
      final result = await datasources[type.datasourceType]?.fetchThreads(oauth: oauth, threadId: threadId, labelId: labelId, email: email);
      return right(result!);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, void>> read({required OAuthEntity oauth, required List<MailEntity> mails}) async {
    try {
      final groupedMails = groupBy(mails, (e) => e.type);
      groupedMails.forEach((key, value) async {
        await datasources[key.datasourceType]?.read(oauth: oauth, mails: value);
      });
      return right(null);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, void>> important({required OAuthEntity oauth, required List<MailEntity> mails}) async {
    try {
      final groupedMails = groupBy(mails, (e) => e.type);
      groupedMails.forEach((key, value) async {
        await datasources[key.datasourceType]?.important(oauth: oauth, mails: value);
      });
      return right(null);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, void>> pin({required OAuthEntity oauth, required List<MailEntity> mails}) async {
    try {
      final groupedMails = groupBy(mails, (e) => e.type);
      groupedMails.forEach((key, value) async {
        await datasources[key.datasourceType]?.star(oauth: oauth, mails: value);
      });
      return right(null);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, void>> unpin({required OAuthEntity oauth, required List<MailEntity> mails}) async {
    try {
      final groupedMails = groupBy(mails, (e) => e.type);
      groupedMails.forEach((key, value) async {
        await datasources[key.datasourceType]?.unstar(oauth: oauth, mails: value);
      });
      return right(null);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, void>> trash({required OAuthEntity oauth, required List<MailEntity> mails}) async {
    try {
      final groupedMails = groupBy(mails, (e) => e.type);
      groupedMails.forEach((key, value) async {
        await datasources[key.datasourceType]?.trash(oauth: oauth, mails: value);
      });
      return right(null);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, void>> unimportant({required OAuthEntity oauth, required List<MailEntity> mails}) async {
    try {
      final groupedMails = groupBy(mails, (e) => e.type);
      groupedMails.forEach((key, value) async {
        await datasources[key.datasourceType]?.unimportant(oauth: oauth, mails: value);
      });
      return right(null);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, void>> unread({required OAuthEntity oauth, required List<MailEntity> mails}) async {
    try {
      final groupedMails = groupBy(mails, (e) => e.type);
      groupedMails.forEach((key, value) async {
        await datasources[key.datasourceType]?.unread(oauth: oauth, mails: value);
      });
      return right(null);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, void>> untrash({required OAuthEntity oauth, required List<MailEntity> mails}) async {
    try {
      final groupedMails = groupBy(mails, (e) => e.type);
      groupedMails.forEach((key, value) async {
        await datasources[key.datasourceType]?.untrash(oauth: oauth, mails: value);
      });
      return right(null);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, void>> spam({required OAuthEntity oauth, required List<MailEntity> mails}) async {
    try {
      final groupedMails = groupBy(mails, (e) => e.type);
      groupedMails.forEach((key, value) async {
        await datasources[key.datasourceType]?.spam(oauth: oauth, mails: value);
      });
      return right(null);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, void>> unspam({required OAuthEntity oauth, required List<MailEntity> mails}) async {
    try {
      final groupedMails = groupBy(mails, (e) => e.type);
      groupedMails.forEach((key, value) async {
        await datasources[key.datasourceType]?.unspam(oauth: oauth, mails: value);
      });
      return right(null);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, void>> archive({required OAuthEntity oauth, required List<MailEntity> mails}) async {
    try {
      final groupedMails = groupBy(mails, (e) => e.type);
      groupedMails.forEach((key, value) async {
        await datasources[key.datasourceType]?.archive(oauth: oauth, mails: value);
      });
      return right(null);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, void>> unarchive({required OAuthEntity oauth, required List<MailEntity> mails}) async {
    try {
      final groupedMails = groupBy(mails, (e) => e.type);
      groupedMails.forEach((key, value) async {
        await datasources[key.datasourceType]?.unarchive(oauth: oauth, mails: value);
      });
      return right(null);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, bool>> delete({required OAuthEntity oauth, required List<MailEntity> mails}) async {
    try {
      final groupedMails = groupBy(mails, (e) => e.type);
      final results = await Future.wait(
        groupedMails.entries.map((entry) async {
          return await datasources[entry.key.datasourceType]?.delete(oauth: oauth, mails: entry.value) ?? false;
        }),
      );
      return right(results.any((result) => result));
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, MailEntity?>> send({required MailEntity mail, required OAuthEntity oauth}) async {
    try {
      final value = await datasources[mail.type.datasourceType]?.send(oauth: oauth, mail: mail);
      return right(value!);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, MailEntity?>> draft({required MailEntity mail, required OAuthEntity oauth}) async {
    try {
      final value = await datasources[mail.type.datasourceType]?.draft(oauth: oauth, mail: mail);
      return right(value!);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, bool>> undraft({required MailEntity mail, required OAuthEntity oauth}) async {
    try {
      final value = await datasources[mail.type.datasourceType]?.undraft(oauth: oauth, mail: mail);
      return right(value!);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, bool>> deleteAllMailsInLabel({required OAuthEntity oauth, required String labelId}) async {
    try {
      await datasources[oauth.type.datasourceType]?.deleteLabels(oauth: oauth, labelId: labelId);
      return right(true);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, bool>> modifyMails({required OAuthEntity oauth, List<String>? addLabels, List<String>? removeLabels, required List<String> messageIds}) async {
    try {
      await datasources[oauth.type.datasourceType]?.batchModify(oauth: oauth, addLabels: addLabels, removeLabels: removeLabels, messageIds: messageIds);
      return right(true);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<Either<Failure, Map<String, String>>> attachMailChangeListener({required UserEntity user, required OAuthEntity oauth}) async {
    try {
      final list = await datasources[oauth.type.datasourceType]?.attachMailChangeListener(user: user, oauth: oauth);
      return right(list ?? {});
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }

  Future<void> detachMailChangeListener({required OAuthEntity oauth}) async {
    try {
      await datasources[oauth.type.datasourceType]?.detachMailChangeListener(oauth: oauth);
    } catch (e) {
      Utils.debugLeft(e);
    }
  }
}
