import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/presentation/widgets/inbox_action_suggestions_widget.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';

class AgentActionContext {
  final AgentActionType actionType;
  final InboxEntity? inbox;
  final TaskEntity? task;
  final EventEntity? event;
  final String? contextInfo; // 액션에 필요한 컨텍스트 정보 (예: 메일 snippet)

  AgentActionContext({
    required this.actionType,
    this.inbox,
    this.task,
    this.event,
    this.contextInfo,
  });

  bool get isEmpty => inbox == null && task == null && event == null;
}

