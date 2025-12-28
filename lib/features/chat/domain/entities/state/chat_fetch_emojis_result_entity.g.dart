// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_fetch_emojis_result_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatFetchEmojisResultEntity _$ChatFetchEmojisResultEntityFromJson(
  Map<String, dynamic> json,
) => _ChatFetchEmojisResultEntity(
  emojis: (json['emojis'] as List<dynamic>)
      .map((e) => MessageEmojiEntity.fromJson(e as Map<String, dynamic>))
      .toList(),
  sequence: (json['sequence'] as num).toInt(),
);

Map<String, dynamic> _$ChatFetchEmojisResultEntityToJson(
  _ChatFetchEmojisResultEntity instance,
) => <String, dynamic>{
  'emojis': instance.emojis.map((e) => e.toJson()).toList(),
  'sequence': instance.sequence,
};
