// ignore_for_file: invalid_annotation_target

import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'mail_fetch_result_entity.freezed.dart';
part 'mail_fetch_result_entity.g.dart';

@freezed
abstract class MailFetchResultEntity with _$MailFetchResultEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MailFetchResultEntity({
    required List<MailEntity> messages,
    required bool hasMore,
    String? nextPageToken,
    bool? hasRecent,
    bool? isRateLimited,
  }) = _MailFetchResultEntity;

  /// Serialization
  factory MailFetchResultEntity.fromJson(Map<String, dynamic> json) => _$MailFetchResultEntityFromJson(json);
}

extension MailFetchResultEntityX on MailFetchResultEntity {
  MailFetchResultEntity copyWith({List<MailEntity>? messages, bool? hasMore, String? nextPageToken, bool? hasRecent, bool? isRateLimited}) =>
      MailFetchResultEntity(
        messages: messages ?? this.messages,
        hasMore: hasMore ?? this.hasMore,
        nextPageToken: nextPageToken ?? this.nextPageToken,
        hasRecent: hasRecent ?? this.hasRecent,
        isRateLimited: isRateLimited ?? this.isRateLimited,
      );
}
