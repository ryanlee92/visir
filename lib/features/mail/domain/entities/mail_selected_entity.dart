import 'package:Visir/features/mail/domain/entities/mail_entity.dart';

class MailSelectedEntity {
  String label;
  String? hostEmail;
  String? threadId;
  String? threadEmail;
  MailEntityType? type;
  List<MailEntity>? threads;

  MailSelectedEntity({
    required this.label,
    required this.hostEmail,
    this.threadId,
    this.threadEmail,
    this.type,
    this.threads,
  });

  operator ==(Object other) {
    return other is MailSelectedEntity &&
        other.label == label &&
        other.hostEmail == hostEmail &&
        other.threadId == threadId &&
        other.threadEmail == threadEmail &&
        other.type == type &&
        other.threads == threads;
  }
}
