import 'package:Visir/features/mail/domain/entities/mail_entity.dart';

class MailUserEntity {
  final String email;
  final String? name;
  final MailEntityType? type;

  MailUserEntity({required this.email, this.name, this.type});

  MailUserEntity copyWith() {
    return MailUserEntity(
      email: email,
      name: name,
      type: type,
    );
  }

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    if (other is MailUserEntity) {
      return this.email == other.email && this.name == other.name && this.type == other.type;
    }
    
    return false;
  }
}
