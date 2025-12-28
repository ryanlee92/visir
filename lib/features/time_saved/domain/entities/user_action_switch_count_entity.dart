import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/time_saved/domain/entities/user_action_entity.dart';

class UserActionSwitchCountEntity {
  final int count;
  final UserActionEntity prevAction;
  final UserActionEntity nextAction;
  final double totalLowFocusDuration;

  UserActionSwitchCountEntity({required this.count, required this.prevAction, required this.nextAction, required this.totalLowFocusDuration});

  UserActionSwitchCountEntity copyWith({int? count, UserActionEntity? prevAction, UserActionEntity? nextAction, double? totalLowFocusDuration}) {
    return UserActionSwitchCountEntity(
      count: count ?? this.count,
      prevAction: prevAction ?? this.prevAction,
      nextAction: nextAction ?? this.nextAction,
      totalLowFocusDuration: totalLowFocusDuration ?? this.totalLowFocusDuration,
    );
  }

  String get id => '${prevAction.typeWithIdentifier}_${nextAction.typeWithIdentifier}';

  bool get isCalendar => prevAction.type == UserActionType.calendar || nextAction.type == UserActionType.calendar;

  Map<String, dynamic> toJson() => {
    'count': count,
    'prev_action': prevAction.toJson(),
    'next_action': nextAction.toJson(),
    'total_low_focus_duration': totalLowFocusDuration,
  };

  factory UserActionSwitchCountEntity.fromJson(Map<String, dynamic> json) {
    return UserActionSwitchCountEntity(
      totalLowFocusDuration: json['total_low_focus_duration'],
      count: json['count'],
      prevAction: UserActionEntity.fromJson(json['prev_action']),
      nextAction: UserActionEntity.fromJson(json['next_action']),
    );
  }
}

extension ListUserActionSwitchCountEntityX on List<UserActionSwitchCountEntity> {
  double get totalLowFocusDuration =>
      this.length > 1 ? this.fold(0.0, (sum, e) => sum + e.totalLowFocusDuration / 3600) : (this.firstOrNull?.totalLowFocusDuration ?? 0) / 3600;

  double get totalProductivityLoss => totalLowFocusDuration * Constants.appSwitchingProductivityLossRate;

  double get directlyWastedTime => this.length > 1
      ? this.fold(0.0, (sum, e) => sum + e.count * Constants.timerPerAppSwitchingInSeconds / 3600)
      : (this.firstOrNull?.count ?? 0) * Constants.timerPerAppSwitchingInSeconds / 3600;

  double get totalWastedTime => totalProductivityLoss + directlyWastedTime;

  int get totalCount => this.length > 1 ? this.fold(0, (sum, e) => sum + e.count) : this.firstOrNull?.count ?? 0;
}
