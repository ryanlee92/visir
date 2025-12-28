import 'package:Visir/dependency/modal_bottom_sheet/src/utils/modal_scroll_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/date_time_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_search_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_app_bar.dart';
import 'package:Visir/features/common/presentation/widgets/visir_empty_widget.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart';
import 'package:Visir/features/common/presentation/widgets/selection_widget.dart';
import 'package:Visir/features/common/presentation/widgets/wave_refresh_header.dart';
import 'package:Visir/features/common/presentation/widgets/wave_refresh_footer.dart';
import 'package:Visir/features/inbox/application/agent_action_controller.dart';
import 'package:Visir/features/inbox/application/agent_chat_history_controller.dart';
import 'package:Visir/features/inbox/presentation/widgets/inbox_action_suggestions_widget.dart';
import 'package:Visir/features/inbox/providers.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:Visir/features/task/domain/entities/project_entity.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';

class AgentChatHistoryWidget extends ConsumerStatefulWidget {
  final String? projectId;
  final Function(String sessionId)? onHistorySelected;

  const AgentChatHistoryWidget({super.key, this.projectId, this.onHistorySelected});

  @override
  ConsumerState<AgentChatHistoryWidget> createState() => _AgentChatHistoryWidgetState();
}

class _AgentChatHistoryWidgetState extends ConsumerState<AgentChatHistoryWidget> {
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController ??= ModalScrollController.ofSyncGroup(context)?.addAndGet() ?? ScrollController();
  }

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void dispose() {
    _scrollController?.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historiesAsync = ref.watch(agentChatHistoryControllerProvider);
    final projects = ref.watch(projectListControllerProvider);

    return historiesAsync.when(
      data: (histories) {
        if (histories.isEmpty) {
          return VisirEmptyWidget(message: context.tr.no_history);
        }

        return SmartRefresher(
          controller: _refreshController,
          enablePullDown: false,
          enablePullUp: true,
          physics: Utils.getScrollPhysicsForBottomSheet(context, _scrollController),
          footer: WaveRefreshFooter(),
          onLoading: () async {
            try {
              final beforeCount = histories.length;
              await ref.read(agentChatHistoryControllerProvider.notifier).loadMore();
              // 상태가 업데이트되기를 기다림
              await Future.delayed(const Duration(milliseconds: 100));
              final afterState = ref.read(agentChatHistoryControllerProvider);
              final afterHistories = afterState.value ?? [];

              // 새 항목이 추가되지 않았으면 더 이상 없음
              if (afterHistories.length <= beforeCount) {
                _refreshController.loadNoData();
              } else {
                _refreshController.loadComplete();
              }
            } catch (e) {
              _refreshController.loadFailed();
            }
          },
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: histories.length,
            itemBuilder: (context, index) {
              final history = histories[index];
              final historyProjectId = history.projectId;
              final project = historyProjectId != null ? projects.firstWhereOrNull((p) => p.uniqueId == historyProjectId) : null;

              final firstMessage = history.messages.firstOrNull;

              // actionType이 있고 conversationSummary가 없으면 타이틀 생성
              String? previewText = history.conversationSummary;
              if (previewText == null || previewText.isEmpty) {
                if (history.actionType != null) {
                  try {
                    final actionType = AgentActionType.values.firstWhere((e) => e.name == history.actionType);
                    String displayText;
                    switch (actionType) {
                      case AgentActionType.createTask:
                        displayText = context.tr.create_task;
                        break;
                      case AgentActionType.createEvent:
                        displayText = context.tr.command_create_event('').replaceAll(' {title}', '');
                        break;
                      case AgentActionType.reply:
                        displayText = context.tr.mail_reply;
                        break;
                      case AgentActionType.forward:
                        displayText = context.tr.mail_forward;
                        break;
                      case AgentActionType.send:
                        displayText = context.tr.mail_send;
                        break;
                      default:
                        displayText = actionType.name;
                        break;
                    }

                    // 첫 메시지에서 task/event 정보 추출 시도
                    String? itemName;
                    if (firstMessage != null) {
                      final content = firstMessage.content;
                      // <inapp_task> 태그에서 title 추출 시도
                      final taskMatch = RegExp(r'<inapp_task>.*?"title"\s*:\s*"([^"]+)"', dotAll: true).firstMatch(content);
                      if (taskMatch != null) {
                        itemName = taskMatch.group(1);
                      } else {
                        // 일반적인 패턴에서 제목 추출 시도
                        final summaryMatch = RegExp(r'summary["\s:]+([^<\n]+)', caseSensitive: false).firstMatch(content);
                        if (summaryMatch != null) {
                          itemName = summaryMatch.group(1)?.trim();
                        }
                      }
                    }

                    if (itemName != null && itemName.isNotEmpty) {
                      previewText = '$displayText · $itemName';
                      if (previewText.length > 50) {
                        previewText = '${previewText.substring(0, 47)}...';
                      }
                    } else {
                      previewText = displayText;
                    }
                  } catch (e) {
                    // actionType 파싱 실패 시 기본 처리
                    previewText = firstMessage != null
                        ? firstMessage.content.substring(0, firstMessage.content.length > 50 ? 50 : firstMessage.content.length)
                        : context.tr.chat_history_conversation_start;
                  }
                } else {
                  previewText = firstMessage != null
                      ? firstMessage.content.substring(0, firstMessage.content.length > 50 ? 50 : firstMessage.content.length)
                      : context.tr.chat_history_conversation_start;
                }
              }

              return VisirButton(
                type: VisirButtonAnimationType.scaleAndOpacity,
                style: VisirButtonStyle(padding: const EdgeInsets.all(12), borderRadius: BorderRadius.circular(0)),
                onTap: () {
                  if (widget.onHistorySelected != null) {
                    widget.onHistorySelected!(history.id);
                  } else {
                    // 기본 동작: 대화 재개
                    ref.read(agentActionControllerProvider.notifier).resumeChatFromHistory(history.id);
                  }

                  // 팝업 닫기
                  Navigator.of(Utils.mainContext).maybePop();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (project != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                            decoration: BoxDecoration(color: project.color, borderRadius: BorderRadius.circular(4)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                VisirIcon(type: project.icon ?? VisirIconType.project, size: 12, color: Colors.white, isSelected: true),
                                const SizedBox(width: 4),
                                Text(project.name, style: context.bodySmall?.copyWith(color: Colors.white)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Expanded(
                          child: Text(
                            previewText,
                            style: context.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: context.onSurface),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(history.updatedAt.forceDateTimeString, style: context.bodySmall?.copyWith(color: context.onSurfaceVariant)),
                        const SizedBox(width: 8),
                        Text('•', style: context.bodySmall?.copyWith(color: context.onSurfaceVariant)),
                        const SizedBox(width: 8),
                        Text(context.tr.chat_history_messages_count(history.messages.length), style: context.bodySmall?.copyWith(color: context.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(context.tr.chat_history_load_error, style: context.bodyMedium?.copyWith(color: context.error)),
        ),
      ),
    );
  }
}

/// 히스토리 PopupMenu를 반환하는 위젯
class AgentChatHistoryPopupMenu extends ConsumerStatefulWidget {
  final String? projectId;

  const AgentChatHistoryPopupMenu({super.key, this.projectId});

  @override
  ConsumerState<AgentChatHistoryPopupMenu> createState() => _AgentChatHistoryPopupMenuState();
}

class _AgentChatHistoryPopupMenuState extends ConsumerState<AgentChatHistoryPopupMenu> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
      decoration: BoxDecoration(color: PlatformX.isMobileView ? context.background : context.surface, borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // AppBar 영역
          Container(
            height: VisirAppBar.height,
            child: Row(
              children: [
                Expanded(
                  child: VisirSearchBar(
                    alwaysOn: true,
                    hintText: context.tr.chat_history_search_hint,
                    textEditingController: _searchController,
                    onSubmitted: (text) async {},
                    onChanged: (text) {
                      ref.read(agentChatHistorySearchQueryProvider.notifier).setSearchQuery(text);
                    },
                    onClose: () {
                      _searchController.clear();
                      ref.read(agentChatHistorySearchQueryProvider.notifier).setSearchQuery('');
                    },
                  ),
                ),
                const SizedBox(width: 6),
                _buildProjectFilterButton(ref, context).getButton(context: context),
                _buildSortOptionButton(ref, context).getButton(context: context),
                const SizedBox(width: 6),
              ],
            ),
          ),
          Divider(height: 1, color: context.outline),
          // 히스토리 목록
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: AgentChatHistoryWidget(
                onHistorySelected: (sessionId) {
                  ref.read(agentActionControllerProvider.notifier).resumeChatFromHistory(sessionId);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

VisirAppBarButton _buildProjectFilterButton(WidgetRef ref, BuildContext context) {
  final projects = ref.watch(projectListControllerProvider);
  final selectedProjectId = ref.watch(agentChatHistoryFilterProvider);
  final selectedProject = selectedProjectId != null ? projects.firstWhereOrNull((p) => p.uniqueId == selectedProjectId) : null;
  final sortedProjects = projects.sortedProjectWithDepth;

  return VisirAppBarButton(
    popupWidth: 200,
    popupLocation: PopupMenuLocation.bottom,
    backgroundColor: context.surface,
    border: Border.all(color: context.outline),
    popup: Builder(
      builder: (context) {
        return SelectionWidget<String?>(
          current: selectedProjectId,
          items: [null, ...sortedProjects.map((e) => e.project.uniqueId)],
          getTitle: (id) {
            if (id == null) return context.tr.chat_history_filter_all;
            final project = projects.firstWhereOrNull((p) => p.uniqueId == id);
            return project?.name ?? context.tr.chat_history_filter_unknown;
          },
          getChild: (id) {
            if (id == null) {
              return Row(
                children: [
                  const SizedBox(width: 10),
                  VisirIcon(type: VisirIconType.project, size: 14, isSelected: true),
                  const SizedBox(width: 8),
                  Text(context.tr.chat_history_filter_all, style: context.bodyMedium),
                ],
              );
            }
            final project = projects.firstWhereOrNull((p) => p.uniqueId == id);
            if (project == null) return const SizedBox.shrink();
            final projectDepth = sortedProjects.firstWhereOrNull((e) => e.project.uniqueId == id)?.depth ?? 0;
            return Row(
              children: [
                SizedBox(width: 10 + projectDepth * 12),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(color: project.color, borderRadius: BorderRadius.circular(6)),
                  alignment: Alignment.center,
                  child: project.icon == null ? null : VisirIcon(type: project.icon!, size: 12, color: Colors.white, isSelected: true),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(project.name, style: context.bodyMedium, overflow: TextOverflow.ellipsis),
                ),
              ],
            );
          },
          onSelect: (id) {
            ref.read(agentChatHistoryFilterProvider.notifier).setFilter(id);
          },
        );
      },
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (selectedProject != null)
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: selectedProject.color, borderRadius: BorderRadius.circular(6)),
            alignment: Alignment.center,
            child: selectedProject.icon == null ? null : VisirIcon(type: selectedProject.icon!, size: 12, color: Colors.white, isSelected: true),
          )
        else
          VisirIcon(type: VisirIconType.project, size: 14, isSelected: true),
        const SizedBox(width: 6),
        Text(
          selectedProjectId == null ? context.tr.chat_history_filter_all : selectedProject?.name ?? context.tr.chat_history_filter_unknown,
          style: context.bodyMedium,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

VisirAppBarButton _buildSortOptionButton(WidgetRef ref, BuildContext context) {
  final sortType = ref.watch(agentChatHistorySortProvider);

  String getSortLabel(AgentChatHistorySortType type, BuildContext context) {
    switch (type) {
      case AgentChatHistorySortType.updatedAtDesc:
        return context.tr.chat_history_sort_updated_desc;
      case AgentChatHistorySortType.updatedAtAsc:
        return context.tr.chat_history_sort_updated_asc;
      case AgentChatHistorySortType.messageCountDesc:
        return context.tr.chat_history_sort_message_count_desc;
      case AgentChatHistorySortType.messageCountAsc:
        return context.tr.chat_history_sort_message_count_asc;
    }
  }

  VisirIconType getSortIcon(AgentChatHistorySortType type) {
    switch (type) {
      case AgentChatHistorySortType.updatedAtDesc:
      case AgentChatHistorySortType.updatedAtAsc:
        return VisirIconType.clock;
      case AgentChatHistorySortType.messageCountDesc:
      case AgentChatHistorySortType.messageCountAsc:
        return VisirIconType.chat;
    }
  }

  return VisirAppBarButton(
    popupWidth: 180,
    popupLocation: PopupMenuLocation.bottom,
    backgroundColor: context.surface,
    border: Border.all(color: context.outline),
    popup: Builder(
      builder: (context) {
        return SelectionWidget<AgentChatHistorySortType>(
          current: sortType,
          items: AgentChatHistorySortType.values,
          getTitle: (type) => getSortLabel(type, context),
          getChild: (type) {
            return Row(
              children: [
                VisirIcon(type: getSortIcon(type), size: 14, isSelected: true),
                const SizedBox(width: 8),
                Text(getSortLabel(type, context), style: context.bodyMedium),
              ],
            );
          },
          onSelect: (type) {
            ref.read(agentChatHistorySortProvider.notifier).setSortType(type);
          },
        );
      },
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        VisirIcon(type: getSortIcon(sortType), size: 14, isSelected: true),
        const SizedBox(width: 6),
        Text(getSortLabel(sortType, context), style: context.bodyMedium),
      ],
    ),
  );
}
