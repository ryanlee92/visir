// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedback_entity.freezed.dart';
part 'feedback_entity.g.dart';

@freezed
abstract class FeedbackEntity with _$FeedbackEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory FeedbackEntity({
    required String id,
    required String? authorId,
    required String description,
    required DateTime createdAt,
    required List<String> fileUrls,
    required String version,
    required bool isAutoReport,
    required String platform,
    required String osVersion,
    String? errorMessage,
  }) = _FeedbackEntity;

  /// Serialization
  factory FeedbackEntity.fromJson(Map<String, dynamic> json) => _$FeedbackEntityFromJson(json);
}
