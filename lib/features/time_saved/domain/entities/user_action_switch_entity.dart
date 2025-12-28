// ignore_for_file: invalid_annotation_target

import 'package:Visir/features/time_saved/domain/entities/user_action_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_action_switch_entity.freezed.dart';
part 'user_action_switch_entity.g.dart';

@freezed
abstract class UserActionSwitchEntity with _$UserActionSwitchEntity {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserActionSwitchEntity({
    required String id,
    required String userId,
    required DateTime createdAt,
    required UserActionEntity prevAction,
    required UserActionEntity nextAction,
  }) = _UserActionSwitchEntity;

  /// Serialization
  factory UserActionSwitchEntity.fromJson(Map<String, dynamic> json) => _$UserActionSwitchEntityFromJson(json);
}

extension UserActionSwitchEntityX on UserActionSwitchEntity {
  bool get isTypeSwitched => prevAction.type != nextAction.type;

  bool get isTypeWithIdentifierSwitched => prevAction.typeWithIdentifier != nextAction.typeWithIdentifier;

  bool get isError => prevAction.isError || nextAction.isError;
}
