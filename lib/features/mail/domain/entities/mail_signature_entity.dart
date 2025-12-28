import 'package:freezed_annotation/freezed_annotation.dart';

part 'mail_signature_entity.freezed.dart';
part 'mail_signature_entity.g.dart';

@freezed
abstract class MailSignatureEntity with _$MailSignatureEntity {
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)

  /// Factory Constructor
  const factory MailSignatureEntity({
    required int number,
    required String signature,
  }) = _MailSignatureEntity;

  factory MailSignatureEntity.fromJson(Map<String, dynamic> json) => _$MailSignatureEntityFromJson(json);
}
