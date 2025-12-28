// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mail_signature_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MailSignatureEntity _$MailSignatureEntityFromJson(Map<String, dynamic> json) =>
    _MailSignatureEntity(
      number: (json['number'] as num).toInt(),
      signature: json['signature'] as String,
    );

Map<String, dynamic> _$MailSignatureEntityToJson(
  _MailSignatureEntity instance,
) => <String, dynamic>{
  'number': instance.number,
  'signature': instance.signature,
};
