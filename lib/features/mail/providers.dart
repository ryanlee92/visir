import 'package:Visir/config/providers.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/mail/infrastructure/datasources/remote/google_mail_datasource.dart';
import 'package:Visir/features/mail/infrastructure/datasources/remote/microsoft_mail_datasource.dart';
import 'package:Visir/features/mail/infrastructure/repositories/mail_repository.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@riverpod
GoogleMailDatasource googleMailDatasource(Ref ref) {
  return GoogleMailDatasource();
}

@riverpod
MicrosoftMailDatasource microsoftMailDatasource(Ref ref) {
  return MicrosoftMailDatasource();
}

@riverpod
MailRepository mailRepository(Ref ref) {
  return MailRepository(
    datasources: {DatasourceType.google: ref.watch(googleMailDatasourceProvider), DatasourceType.microsoft: ref.watch(microsoftMailDatasourceProvider)},
  );
}

class MailListCondition {
  String label;
  String? email;
  String? query;
  String? threadId;
  String? threadEmail;
  MailEntityType? type;
  List<MailEntity>? threads;

  MailListCondition({required this.label, required this.email, required this.query, this.threadId, this.threadEmail, this.type, this.threads});

  MailListCondition setEmail(String? email) {
    this.email = email;
    return this.copyWith();
  }

  MailListCondition setQuery(String? query) {
    this.query = query;
    return this.copyWith();
  }

  MailListCondition setLabel(String label) {
    this.label = label;
    return this.copyWith();
  }

  MailListCondition setLabelAndEmail(String label, String? email) {
    this.label = label;
    this.email = email;
    this.threadId = null;
    this.threadEmail = null;
    this.type = null;
    this.threads = null;
    this.query = null;
    return this.copyWith();
  }

  MailListCondition openThread(String label, String? email, String threadId, String threadEmail, MailEntityType type, List<MailEntity>? threads) {
    this.label = label;
    this.email = email;
    this.threadId = threadId;
    this.threadEmail = threadEmail;
    this.type = type;
    this.threads = threads;
    return this.copyWith();
  }

  MailListCondition openJustThread(String threadId, String threadEmail, MailEntityType type, List<MailEntity> threads) {
    this.threadId = threadId;
    this.threadEmail = threadEmail;
    this.type = type;
    this.threads = threads;
    return this.copyWith();
  }

  MailListCondition copyWith() {
    return MailListCondition(label: label, email: email, query: query, threadId: threadId, threadEmail: threadEmail, type: type, threads: threads);
  }
}

@Riverpod(keepAlive: true)
class MailCondition extends _$MailCondition {
  @override
  MailListCondition build(TabType tabType) {
    return MailListCondition(label: CommonMailLabels.inbox.id, email: null, query: null);
  }

  void setEmail(String? email) {
    state = state.setEmail(email);
  }

  void setQuery(String? query) {
    state = state.setQuery(query);
  }

  void setLabel(String label) {
    state = state.setLabel(label);
  }

  void setLabelAndEmail(String label, String? email) {
    state = state.setLabelAndEmail(label, email);
  }

  void openThread({
    required String label,
    required String? email,
    required String threadId,
    required String threadEmail,
    required MailEntityType type,
    List<MailEntity>? threads,
  }) {
    state = state.openThread(label, email, threadId, threadEmail, type, threads);
  }

  void openJustThread({required String threadId, required String threadEmail, required MailEntityType type, required List<MailEntity> threads}) {
    state = state.openJustThread(threadId, threadEmail, type, threads);
  }
}
