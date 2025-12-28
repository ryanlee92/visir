// ignore_for_file: invalid_annotation_target

import 'package:Visir/features/time_saved/domain/entities/user_action_switch_count_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'total_user_action_entity.freezed.dart';
part 'total_user_action_entity.g.dart';

@freezed
abstract class TotalUserActionEntity with _$TotalUserActionEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory TotalUserActionEntity({required List<UserActionSwitchCountEntity> userActions}) = _TotalUserActionEntity;

  /// Serialization
  factory TotalUserActionEntity.fromJson(Map<String, dynamic> json) => _$TotalUserActionEntityFromJson(json);
}
