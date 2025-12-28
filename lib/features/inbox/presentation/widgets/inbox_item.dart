import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/contextmenu/src/ContextMenuArea.dart' show ContextMenuActionType;
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/calendar/presentation/widgets/calendar_simple_create_widget.dart';
import 'package:Visir/features/calendar/presentation/widgets/mobile_calendar_edit_widget.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_emoji_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/date_time_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/auth_image_view.dart';
import 'package:Visir/features/common/presentation/widgets/multi_finger_gesture_detector.dart';
import 'package:Visir/features/common/presentation/widgets/popup_menu.dart' show PopupMenu, PopupMenuLocation, forceShiftOffsetForMenu;
import 'package:Visir/features/common/presentation/widgets/popup_menu_container.dart';
import 'package:Visir/features/common/presentation/widgets/proxy_network_image.dart';
import 'package:Visir/features/common/presentation/widgets/showcase_wrapper.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/common/presentation/widgets/visir_list_item.dart';
import 'package:Visir/features/inbox/application/inbox_controller.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_suggestion_entity.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:Visir/features/task/presentation/widgets/mobile_task_edit_widget.dart';
import 'package:Visir/features/task/presentation/widgets/mobile_task_or_event_switcher_widget.dart';
import 'package:Visir/features/task/presentation/widgets/simple_task_or_event_switcher_widget.dart';
import 'package:Visir/features/task/presentation/widgets/task_simple_create_widget.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class InboxItem extends ConsumerStatefulWidget {
  final TabType tabType;
  final InboxEntity inbox;
  final List<InboxEntity>? inboxGroup;
  final bool isFirst;
  final List<MessageChannelEntity> channels;
  final List<MessageMemberEntity> members;
  final List<MessageGroupEntity> groups;
  final List<MessageEmojiEntity> emojis;
  final bool isSelected;
  final bool isSearch;
  final bool isSuggestion;
  final String? searchQuery;
  final bool isShowcase;

  final void Function()? onRemoveCreateShadow;
  final void Function()? onSaved;
  final void Function(String? title)? onTitleChanged;
  final void Function(Color? color)? onColorChanged;
  final void Function(DateTime startTime, DateTime endTime, bool isAllDay)? onTimeChanged;
  final void Function(bool isTask)? updateIsTask;
  final void Function(DateTime startTime, DateTime endTime, bool isAllDay)? onShowCreateShadow;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onTwoFingerDragSelect;
  final VoidCallback? onTwoFingerDragDisselect;
  final void Function(TapDownDetails)? onTapDown;
  final void Function(TapUpDetails)? onTapUp;
  final VoidCallback? onTapCancel;
  final MultiFingerGestureController? multiFingerGestureController;
  final VisirButtonOptions? buttonOptions;

  const InboxItem({
    Key? key,
    required this.tabType,
    required this.inbox,
    this.inboxGroup,
    required this.isFirst,
    required this.channels,
    required this.members,
    required this.groups,
    required this.emojis,
    required this.isSelected,
    required this.isSearch,
    required this.searchQuery,
    required this.isSuggestion,
    required this.isShowcase,
    this.onShowCreateShadow,
    this.onRemoveCreateShadow,
    this.onSaved,
    this.onTitleChanged,
    this.onColorChanged,
    this.onTimeChanged,
    this.updateIsTask,
    this.onTap,
    this.onLongPress,
    this.onTwoFingerDragSelect,
    this.onTwoFingerDragDisselect,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.multiFingerGestureController,
    this.buttonOptions,
  }) : super(key: key);

  @override
  _InboxItemState createState() => _InboxItemState();
}

class _InboxItemState extends ConsumerState<InboxItem> {
  String get searchQuery => widget.searchQuery ?? '';

  bool get isMobileView => PlatformX.isMobileView;

  GlobalKey key = GlobalKey();

  bool get isDarkMode => context.isDarkMode;

  final DateFormat _timeFormat = DateFormat('h:mm a');

  Widget inboxGroupWidget({required InboxProvider p, bool isUnread = false}) {
    TextStyle? style = context.context.bodyMedium?.textColor(context.inverseSurface);
    int maxLines = 1;

    return Text.rich(
      TextSpan(
        style: style,
        children: Utils.highlightSearchQuery(defaultStyle: style, text: p.name, searchQuery: searchQuery),
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget descriptionWidget(TextStyle? style) {
    int maxLines = (widget.isSearch && widget.inbox.linkedMessage != null) ? 4 : 2;
    String text = widget.inbox.description ?? '';
    if (widget.isSuggestion) {
      final reasonedBody = (widget.inbox.suggestion?.reasoned_body ?? '').replaceAll(RegExp(r'\s+'), '  ').trim();
      final substringLength = 30;
      if (text.contains(reasonedBody)) {
        final preText = text.split(reasonedBody).first;
        final postText = text.split(reasonedBody).last;
        return Text.rich(
          TextSpan(
            text: preText.length > substringLength ? '...${preText.substring(preText.length - substringLength)}' : preText,
            children: [
              TextSpan(
                text: reasonedBody,
                style: TextStyle(backgroundColor: context.tertiary.withValues(alpha: context.isDarkMode ? 0.4 : 0.25)),
              ),
              TextSpan(text: postText.length > substringLength ? '${postText.substring(0, substringLength)}...' : postText),
            ],
          ),
          maxLines: 3,
          style: style,
        );
      }
    }

    return Text.rich(
      TextSpan(text: text, style: style),
      maxLines: maxLines,
    );
  }

  List<Widget> tagWidget(double verticalPadding, double horizontalPadding) {
    final reason = widget.inbox.suggestion?.urgency;
    final isAsap = widget.inbox.suggestion?.isASAP ?? false;
    final targetDate = widget.inbox.suggestion?.target_date;
    final isAllDay = widget.inbox.suggestion?.isAllDay ?? false;
    final duration = widget.inbox.suggestion?.duration;
    final isEvent = widget.inbox.suggestion?.date_type == InboxSuggestionDateType.event;

    final dateString = targetDate != null ? getDateString(date: targetDate, forceDate: true) : '';
    final timeString = targetDate != null
        ? targetDate.minute == 0
              ? DateFormat('h a').format(targetDate)
              : DateFormat('h:mm a').format(targetDate)
        : '';

    final linkedTasks = widget.inbox.linkedTask?.tasks ?? [];
    final tagPadding = EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding);

    final tags = [
      if (widget.isSuggestion && reason != null && reason != InboxSuggestionUrgency.none)
        Builder(
          builder: (context) {
            // urgency 문자열을 미리 저장 (context를 사용하여 로컬라이제이션 가져오기)
            final urgencyTitle = reason.title.isNotEmpty 
                ? reason.title 
                : (reason == InboxSuggestionUrgency.urgent 
                    ? context.tr.ai_suggestion_urgency_urgent
                    : reason == InboxSuggestionUrgency.important
                        ? context.tr.ai_suggestion_urgency_important
                        : reason == InboxSuggestionUrgency.action_required
                            ? context.tr.ai_suggestion_urgency_action_required
                            : reason == InboxSuggestionUrgency.need_review
                                ? context.tr.ai_suggestion_urgency_need_review
                                : '');
            
            // urgencyTitle이 비어있으면 태그를 표시하지 않음
            if (urgencyTitle.isEmpty) return const SizedBox.shrink();
            
            return PopupMenu(
              type: ContextMenuActionType.tap,
              location: PopupMenuLocation.right,
              backgroundColor: Colors.transparent,
              hideShadow: true,
              width: 300,
              forceShiftOffset: forceShiftOffsetForMenu,
              borderRadius: 12,
              beforePopup: () {
                final user = ref.read(authControllerProvider).requireValue;
                final date = targetDate ?? (!isAsap ? DateUtils.dateOnly(DateTime.now()) : DateTime.now().roundUp(delta: Duration(minutes: 15)));
                final endDate = isAllDay ? date : date.add(Duration(minutes: duration ?? user.userTaskDefaultDurationInMinutes));
                widget.onShowCreateShadow?.call(date, endDate, isAllDay);
              },
              popup: Builder(
                builder: (context) {
                  final date = targetDate ?? (!isAsap ? DateUtils.dateOnly(DateTime.now()) : DateTime.now().roundUp(delta: Duration(minutes: 15)));
                  final user = ref.read(authControllerProvider).requireValue;
                  return SimpleTaskOrEventSwithcerWidget(
                    tabType: widget.tabType,
                    isEvent: isEvent,
                    startDate: date,
                    endDate: isAllDay ? date : date.add(Duration(minutes: duration ?? user.userTaskDefaultDurationInMinutes)),
                    isAllDay: isAllDay,
                    selectedDate: DateUtils.dateOnly(date),
                    onRemoveCreateShadow: widget.onRemoveCreateShadow,
                    onTitleChanged: widget.onTitleChanged,
                    onColorChanged: widget.onColorChanged,
                    onSaved: widget.onSaved,
                    onTimeChanged: widget.onTimeChanged,
                    updateIsTask: widget.updateIsTask,
                    titleHintText: widget.inbox.suggestion?.summary ?? widget.inbox.title,
                    description: widget.inbox.description,
                    originalTaskMail: widget.inbox.linkedMail,
                    originalTaskMessage: widget.inbox.linkedMessage,
                    calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxSuggestion,
                    suggestedProjectId: widget.inbox.suggestion?.project_id,
                  );
                },
              ),
              popupBuilderOnMobileView: (scr) {
                final date = targetDate ?? (!isAsap ? DateUtils.dateOnly(DateTime.now()) : DateTime.now().roundUp(delta: Duration(minutes: 15)));
                final user = ref.read(authControllerProvider).requireValue;
                return MobileTaskOrEventSwitcherWidget(
                  isEvent: isEvent,
                  isAllDay: isAllDay,
                  startDate: date,
                  endDate: isAllDay ? date : date.add(Duration(minutes: duration ?? user.userTaskDefaultDurationInMinutes)),
                  selectedDate: DateUtils.dateOnly(date),
                  tabType: widget.tabType,
                  titleHintText: widget.inbox.suggestion?.summary ?? widget.inbox.title,
                  description: widget.inbox.description,
                  originalTaskMail: widget.inbox.linkedMail,
                  originalTaskMessage: widget.inbox.linkedMessage,
                  calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxSuggestion,
                  suggestedProjectId: widget.inbox.suggestion?.project_id,
                );
              },
              style: VisirButtonStyle(padding: tagPadding, backgroundColor: reason.color, borderRadius: BorderRadius.circular(6)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VisirIcon(type: isEvent ? VisirIconType.calendar : VisirIconType.task, size: 12, color: reason.textColor, isSelected: true),
                  SizedBox(width: 4),
                  Text(urgencyTitle, style: context.bodySmall?.textColor(reason.textColor)),
                ],
              ),
            );
          },
        ),
      if (targetDate != null && widget.isSuggestion)
        PopupMenu(
          type: ContextMenuActionType.tap,
          location: PopupMenuLocation.right,
          backgroundColor: Colors.transparent,
          hideShadow: true,
          width: 300,
          forceShiftOffset: forceShiftOffsetForMenu,
          borderRadius: 12,
          beforePopup: () {
            final user = ref.read(authControllerProvider).requireValue;
            final date = targetDate;
            final endDate = isAllDay ? date : date.add(Duration(minutes: duration ?? user.userTaskDefaultDurationInMinutes));
            widget.onShowCreateShadow?.call(date, endDate, isAllDay);
          },
          popup: Builder(
            builder: (context) {
              final date = targetDate;
              final user = ref.read(authControllerProvider).requireValue;
              return SimpleTaskOrEventSwithcerWidget(
                tabType: widget.tabType,
                isEvent: isEvent,
                startDate: date,
                endDate: isAllDay ? date : date.add(Duration(minutes: duration ?? user.userTaskDefaultDurationInMinutes)),
                isAllDay: isAllDay,
                selectedDate: DateUtils.dateOnly(date),
                onRemoveCreateShadow: widget.onRemoveCreateShadow,
                onTitleChanged: widget.onTitleChanged,
                onColorChanged: widget.onColorChanged,
                onSaved: widget.onSaved,
                onTimeChanged: widget.onTimeChanged,
                updateIsTask: widget.updateIsTask,
                titleHintText: widget.inbox.suggestion?.summary ?? widget.inbox.title,
                description: widget.inbox.description,
                originalTaskMail: widget.inbox.linkedMail,
                originalTaskMessage: widget.inbox.linkedMessage,
                calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxSuggestion,
                suggestedProjectId: widget.inbox.suggestion?.project_id,
              );
            },
          ),
          popupBuilderOnMobileView: (scr) {
            final date = targetDate;
            final user = ref.read(authControllerProvider).requireValue;
            return MobileTaskOrEventSwitcherWidget(
              isEvent: isEvent,
              isAllDay: isAllDay,
              startDate: date,
              endDate: isAllDay ? date : date.add(Duration(minutes: duration ?? user.userTaskDefaultDurationInMinutes)),
              selectedDate: DateUtils.dateOnly(date),
              tabType: widget.tabType,
              titleHintText: widget.inbox.suggestion?.summary ?? widget.inbox.title,
              description: widget.inbox.description,
              originalTaskMail: widget.inbox.linkedMail,
              originalTaskMessage: widget.inbox.linkedMessage,
              calendarTaskEditSourceType: CalendarTaskEditSourceType.inboxSuggestion,
              suggestedProjectId: widget.inbox.suggestion?.project_id,
            );
          },
          style: VisirButtonStyle(padding: tagPadding, backgroundColor: isAsap ? context.error : context.surface, borderRadius: BorderRadius.circular(6)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              VisirIcon(type: VisirIconType.clock, size: 12, color: isAsap ? context.onError : context.onSurface, isSelected: true),
              SizedBox(width: 4),
              Text(
                isAsap
                    ? context.tr.ai_suggestion_due_asap
                    : isAllDay
                    ? dateString
                    : '${dateString}, ${timeString}${duration != null ? ', ${context.tr.ai_suggestion_duration(duration)} slot' : ''}',
                style: context.bodySmall?.textColor(isAsap ? context.onError : context.onSurface),
              ),
            ],
          ),
        ),
      if (linkedTasks.isNotEmpty)
        IntrinsicWidth(
          child: PopupMenu(
            type: ContextMenuActionType.tap,
            location: PopupMenuLocation.right,
            backgroundColor: linkedTasks.length == 1 ? Colors.transparent : null,
            hideShadow: linkedTasks.length == 1 ? true : null,
            width: 300,
            forceShiftOffset: linkedTasks.length == 1 ? Offset(0, -28) : null,
            borderRadius: 12,
            mobileUseBottomSheet: true,
            mobiileBottomSheetTitle: context.tr.linked_task_evnet,
            popup: LinkedTasksPopup(tasks: linkedTasks, tabType: widget.tabType),
            popupBuilderOnMobileView: (scr) => LinkedTasksPopup(tasks: linkedTasks, tabType: widget.tabType, scrollController: scr),
            style: VisirButtonStyle(padding: tagPadding, backgroundColor: context.surface, borderRadius: BorderRadius.circular(6)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                VisirIcon(type: VisirIconType.linkedTask, size: 12, color: context.onSurface, isSelected: true),
                SizedBox(width: 4),
                Text(linkedTasks.length.toString(), style: context.bodySmall?.textColor(context.onSurface)),
              ],
            ),
          ),
        ),
    ];

    return tags;
  }

  String getDateString({required DateTime date, bool? forceDate}) {
    if (DateUtils.isSameDay(DateTime.now(), date) && forceDate != true) return DateFormat.jm().format(date);
    if (DateUtils.isSameDay(DateTime.now(), date) && forceDate == true) return context.tr.today;
    if (DateUtils.isSameDay(DateTime.now().subtract(Duration(days: 1)), date)) return context.tr.yesterday;
    if (DateUtils.isSameDay(DateTime.now().add(Duration(days: 1)), date)) return context.tr.tomorrow;
    if (date.isBefore(DateUtils.dateOnly(DateTime.now().add(Duration(days: 7)))) && date.isAfter(DateUtils.dateOnly(DateTime.now()))) return DateFormat.E().format(date);
    if (date.year == DateTime.now().year) return DateFormat.MMMd().format(date);
    return DateFormat.yMMMd().format(date);
  }

  @override
  Widget build(BuildContext context) {
    String description = widget.inbox.description ?? '';

    final lastDateString = getDateString(
      date: widget.isSuggestion ? widget.inbox.inboxDatetime.toLocal() : widget.inboxGroup?.lastOrNull?.inboxDatetime.toLocal() ?? DateTime.now(),
    );
    final firstDateString = getDateString(
      date: widget.isSuggestion ? widget.inbox.inboxDatetime.toLocal() : widget.inboxGroup?.firstOrNull?.inboxDatetime.toLocal() ?? DateTime.now(),
    );

    final lastTimeString = _timeFormat.format(
      widget.isSuggestion ? widget.inbox.inboxDatetime.toLocal() : widget.inboxGroup?.lastOrNull?.inboxDatetime.toLocal() ?? DateTime.now(),
    );
    final firstTimeString = _timeFormat.format(
      widget.isSuggestion ? widget.inbox.inboxDatetime.toLocal() : widget.inboxGroup?.firstOrNull?.inboxDatetime.toLocal() ?? DateTime.now(),
    );

    final isUnread = widget.inbox.getIsUnread(widget.channels);

    final child = VisirListItem(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTwoFingerDragSelect: widget.onTwoFingerDragSelect,
      onTwoFingerDragDisselect: widget.onTwoFingerDragDisselect,
      onTapDown: widget.onTapDown,
      onTapUp: widget.onTapUp,
      onTapCancel: widget.onTapCancel,
      multiFingerGestureController: widget.multiFingerGestureController,
      buttonOptions: widget.buttonOptions,
      isSelected: PlatformX.isMobileView ? false : widget.isSelected,
      sectionBuilder: (height, style, verticalPadding, horizontalPadding) {
        final suggestedProject = widget.inbox.suggestion?.project_id == null
            ? null
            : ref.read(projectListControllerProvider.select((v) => v.firstWhereOrNull((e) => e.isPointedProjectId(widget.inbox.suggestion?.project_id))));
        final mergedInboxIds = widget.inbox.mergedInboxIds;
        final hasMergedInboxes = mergedInboxIds != null && mergedInboxIds.isNotEmpty;

        return TextSpan(
          children: [
            ...(widget.inbox.providers.isNotEmpty ? widget.inbox.providers : [])
                .map((p) {
                  return [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Padding(
                        padding: EdgeInsets.only(right: horizontalPadding),
                        child: p.avatarUrl != null
                            ? Transform.translate(
                                offset: Offset(0, 1),
                                child: ProxyNetworkImage(imageUrl: p.avatarUrl!, width: height + 2, height: height + 2, fit: BoxFit.cover),
                              )
                            : Image.asset(p.icon, width: height, height: height),
                      ),
                    ),
                    TextSpan(
                      style: style,
                      children: Utils.highlightSearchQuery(defaultStyle: style, text: p.name, searchQuery: searchQuery),
                    ),
                  ];
                })
                .expand((e) => e)
                .toList(),
            if (hasMergedInboxes) ...[
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.only(left: horizontalPadding, right: horizontalPadding),
                  child: PopupMenu(
                    type: ContextMenuActionType.tap,
                    location: PopupMenuLocation.right,
                    backgroundColor: Colors.transparent,
                    hideShadow: true,
                    width: 300,
                    forceShiftOffset: forceShiftOffsetForMenu,
                    borderRadius: 12,
                    popup: Builder(
                      builder: (context) {
                        final allInboxes = ref.read(inboxControllerProvider)?.inboxes ?? [];
                        final mergedInboxes = mergedInboxIds.map((id) => allInboxes.firstWhereOrNull((i) => i.id == id)).whereType<InboxEntity>().toList();
                        return _MergedInboxesPopup(
                          inboxes: mergedInboxes,
                          tabType: widget.tabType,
                          channels: widget.channels,
                          members: widget.members,
                          groups: widget.groups,
                          emojis: widget.emojis,
                          searchQuery: searchQuery,
                        );
                      },
                    ),
                    popupBuilderOnMobileView: (scr) {
                      final allInboxes = ref.read(inboxControllerProvider)?.inboxes ?? [];
                      final mergedInboxes = mergedInboxIds.map((id) => allInboxes.firstWhereOrNull((i) => i.id == id)).whereType<InboxEntity>().toList();
                      return _MergedInboxesPopup(
                        inboxes: mergedInboxes,
                        tabType: widget.tabType,
                        channels: widget.channels,
                        members: widget.members,
                        groups: widget.groups,
                        emojis: widget.emojis,
                        searchQuery: searchQuery,
                        scrollController: scr,
                      );
                    },
                    style: VisirButtonStyle(padding: EdgeInsets.zero, backgroundColor: Colors.transparent, borderRadius: BorderRadius.circular(4)),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: context.primary, borderRadius: BorderRadius.circular(10)),
                      child: Text(mergedInboxIds.length.toString(), style: context.bodySmall?.textColor(context.onPrimary).textBold),
                    ),
                  ),
                ),
              ),
            ],
            if (suggestedProject != null) ...[
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Padding(
                  padding: EdgeInsets.only(right: horizontalPadding, left: horizontalPadding),
                  child: VisirIcon(type: VisirIconType.convert, size: 14, isSelected: true),
                ),
              ),

              TextSpan(
                style: style,
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Container(
                      margin: EdgeInsets.only(right: horizontalPadding),
                      width: style!.fontSize! * style.height!,
                      height: style.fontSize! * style.height!,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: suggestedProject.color!),
                      alignment: Alignment.center,
                      child: suggestedProject.icon == null ? null : VisirIcon(type: suggestedProject.icon!, size: style.fontSize! * style.height! * 2 / 3, color: Colors.white, isSelected: true),
                    ),
                  ),
                  TextSpan(text: suggestedProject.name, style: style),
                ],
              ),
            ],
          ],
        );
      },
      sectionTrailingBuilder: (height, style, verticalPadding, horizontalPadding) {
        return TextSpan(
          children: [
            if (isUnread)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Container(
                  margin: EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(color: context.primary, borderRadius: BorderRadius.circular(3)),
                  width: 6,
                  height: 6,
                ),
              ),
            TextSpan(
              text: widget.isSearch
                  ? lastDateString == firstDateString
                        ? lastDateString
                        : '${lastDateString} – ${firstDateString}'
                  : lastTimeString == firstTimeString
                  ? lastTimeString
                  : '${lastTimeString} – ${firstTimeString}',
            ),
          ],
        );
      },
      titleBuilder: (height, style, verticalPadding, horizontalPadding) {
        bool isMail = widget.inbox.linkedMail != null;
        return TextSpan(
          style: style,
          children: [
            if (!widget.isSearch && widget.inbox.isThread)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Container(
                  width: height,
                  height: height,
                  margin: EdgeInsets.only(right: horizontalPadding),
                  decoration: BoxDecoration(color: context.context.surfaceVariant, borderRadius: BorderRadius.circular(6)),
                ),
              ),
            if (widget.inbox.linkedMessage != null && widget.inbox.linkedMessage!.isDm != true)
              TextSpan(
                text: '${widget.inbox.linkedMessage!.userName}  ',
                style: style!.textBold.textColor(widget.inbox.linkedMessage!.isMe == true ? context.primary : context.secondary),
              ),
            ...Utils.markdownTextToTextSpan(
              widget.inbox.title,
              channelId: isMail ? null : widget.inbox.linkedMessage?.channelId,
              members: isMail ? [] : widget.members,
              groups: isMail ? [] : widget.groups,
              emojis: isMail ? [] : widget.emojis,
              channels: isMail ? [] : widget.channels,
            ),
          ],
        );
      },
      detailsBuilder: (height, style, verticalPadding, horizontalPadding) {
        final _tags = tagWidget(verticalPadding, horizontalPadding);

        if (!((widget.isSearch || widget.isSuggestion) && description.isNotEmpty) && _tags.isEmpty) return null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((widget.isSearch || widget.isSuggestion) && description.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: verticalPadding),
                child: descriptionWidget(style),
              ),
            Wrap(spacing: horizontalPadding, runSpacing: horizontalPadding, children: _tags),
          ],
        );
      },
    );

    if (widget.isShowcase) {
      return ShowcaseWrapper(showcaseKey: inboxItemShowcaseKeyString, targetBorderRadius: BorderRadius.circular(4), child: child);
    }

    return child;
  }
}

class LinkedTasksPopup extends ConsumerWidget {
  final List<TaskEntity> tasks;
  final TabType tabType;
  final ScrollController? scrollController;

  const LinkedTasksPopup({required this.tasks, required this.tabType, this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tasks.length == 1) {
      final t = tasks.first;
      if (PlatformX.isMobileView) {
        return t.isEvent
            ? MobileTaskEditWidget(tabType: tabType, task: t, selectedDate: t.editedStartTime ?? t.startDate, calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal)
            : MobileCalendarEditWidget(
                tabType: tabType,
                selectedDate: t.linkedEvent!.editedStartTime ?? t.linkedEvent!.startDate,
                event: t.linkedEvent!,
                linkedMails: t.linkedMails,
                linkedMessages: t.linkedMessages,
                calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
              );
      } else {
        return t.isEvent
            ? CalenderSimpleCreateWidget(
                tabType: TabType.home,
                selectedDate: t.linkedEvent!.editedStartTime ?? t.linkedEvent!.startDate,
                event: t.linkedEvent!,
                linkedMails: t.linkedMails,
                linkedMessages: t.linkedMessages,
                calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
              )
            : TaskSimpleCreateWidget(
                tabType: TabType.home,
                selectedDate: t.editedStartTime ?? t.startDate,
                task: t,
                calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
              );
      }
    }

    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: tasks.map((t) {
        final project =
            ref.read(projectListControllerProvider).firstWhereOrNull((e) => e.uniqueId == t.projectId) ?? ref.read(projectListControllerProvider).firstWhere((e) => e.isDefault);
        final isEvent = t.isEvent;
        final titleStyle = context.bodyLarge?.textColor(context.outlineVariant);
        final descStyle = context.bodyMedium?.textColor(context.onInverseSurface);
        final description = t.description ?? '';
        final tagBg = isEvent
            ? ColorX.fromHex(t.linkedEvent!.calendar.backgroundColor).withValues(alpha: 0.35)
            : project.color?.withValues(alpha: 0.35) ?? context.primary.withValues(alpha: 0.35);
        final tagIconColor = context.shadow;
        final calendarIcon = isEvent ? (t.linkedEvent!.calendarType == CalendarEntityType.google ? 'assets/logos/logo_gcal.png' : 'assets/logos/logo_outlook.png') : null;
        final identifier = isEvent ? t.linkedEvent!.calendarName : 'Task';
        final pref = ref.read(localPrefControllerProvider).value;
        OAuthEntity? oauth;
        if (isEvent && pref?.calendarOAuths != null) {
          final calendarEmail = t.linkedEvent?.calendar.email;
          final calendarType = t.linkedEvent?.calendarType;
          final _oauth = pref!.calendarOAuths!.firstWhere((o) => o.email == calendarEmail && o.type.calendarType == calendarType, orElse: () => pref.calendarOAuths!.first);
          oauth = _oauth;
        }

        final iconSize = 12.0;

        final tagChild = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: titleStyle),
            if (description.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: descStyle),
              ),
            SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Container(
                  decoration: BoxDecoration(color: tagBg, borderRadius: BorderRadius.circular(4)),
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isEvent)
                        (oauth != null ? AuthImageView(oauth: oauth, size: iconSize) : Image.asset(calendarIcon!, width: iconSize, height: iconSize))
                      else
                        VisirIcon(type: VisirIconType.task, size: iconSize, color: tagIconColor),
                      SizedBox(width: 4),
                      Text(identifier, style: context.bodyMedium?.textColor(tagIconColor)),
                    ],
                  ),
                ),
                Builder(
                  builder: (context) {
                    final start = t.isEvent ? t.linkedEvent!.startDate : (t.editedStartTime ?? t.startDate).toLocal();
                    final end = t.isEvent ? t.linkedEvent!.endDate : (t.editedEndTime ?? t.endDate).toLocal();
                    final isAllDay = t.isEvent ? t.linkedEvent!.isAllDay : t.isAllDay;
                    final now = DateTime.now();
                    String _startFormat(bool allDay, DateTime dt) {
                      if (dt.year != now.year) {
                        return allDay ? DateFormat('y MMM d').format(dt) : DateFormat('y MMM d, h:mm a').format(dt);
                      } else {
                        return allDay ? DateFormat.MMMd().format(dt) : DateFormat('MMM d, h:mm a').format(dt);
                      }
                    }

                    final startStr = _startFormat(isAllDay, start);
                    final dur = end.difference(start);
                    final d = dur.inDays;
                    final h = dur.inHours % 24;
                    final m = dur.inMinutes % 60;
                    final parts = <String>[];
                    if (d > 0) parts.add('${d}d');
                    if (h > 0) parts.add('${h}h');
                    if (m > 0) parts.add('${m}m');
                    final timeLabel = parts.isEmpty ? startStr : '$startStr, ${parts.join(' ')}';
                    final timeBg = context.context.surfaceVariant;
                    return Container(
                      decoration: BoxDecoration(color: timeBg, borderRadius: BorderRadius.circular(4)),
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          VisirIcon(type: VisirIconType.clock, size: iconSize, color: context.shadow),
                          SizedBox(width: 4),
                          Text(timeLabel, style: context.bodyMedium?.textColor(context.shadow)),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        );

        if (PlatformX.isMobileView) {
          return VisirButton(
            type: VisirButtonAnimationType.scaleAndOpacity,
            style: VisirButtonStyle(
              cursor: SystemMouseCursors.click,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              borderRadius: BorderRadius.zero,
              hoverColor: context.surface,
              width: double.infinity,
              alignment: Alignment.centerLeft,
            ),
            onTap: () {
              Utils.showPopupDialog(
                child: !isEvent
                    ? MobileTaskEditWidget(
                        tabType: tabType,
                        task: t,
                        selectedDate: t.editedStartTime ?? t.startDate,
                        calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
                      )
                    : MobileCalendarEditWidget(
                        tabType: tabType,
                        selectedDate: t.linkedEvent!.editedStartTime ?? t.linkedEvent!.startDate,
                        event: t.linkedEvent!,
                        linkedMails: t.linkedMails,
                        linkedMessages: t.linkedMessages,
                        calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
                      ),
              );
            },
            child: tagChild,
          );
        }

        return PopupMenu(
          type: ContextMenuActionType.tap,
          location: PopupMenuLocation.right,
          width: 300,
          borderRadius: 12,
          forceShiftOffset: forceShiftOffsetForMenu,
          backgroundColor: Colors.transparent,
          hideShadow: true,
          popup: isEvent
              ? CalenderSimpleCreateWidget(
                  tabType: TabType.home,
                  selectedDate: t.linkedEvent!.editedStartTime ?? t.linkedEvent!.startDate,
                  event: t.linkedEvent!,
                  linkedMails: t.linkedMails,
                  linkedMessages: t.linkedMessages,
                  calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
                )
              : TaskSimpleCreateWidget(
                  tabType: TabType.home,
                  selectedDate: t.editedStartTime ?? t.startDate,
                  task: t,
                  calendarTaskEditSourceType: CalendarTaskEditSourceType.editOriginal,
                ),
          style: VisirButtonStyle(
            cursor: SystemMouseCursors.click,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            borderRadius: BorderRadius.zero,
            hoverColor: context.surface,
            width: double.infinity,
            alignment: Alignment.centerLeft,
          ),
          child: tagChild,
        );
      }).toList(),
    );

    if (PlatformX.isMobileView) {
      return child;
    }

    return PopupMenuContainer(
      horizontalPadding: 0,
      child: SingleChildScrollView(controller: scrollController, child: child),
    );
  }
}

class _MergedInboxesPopup extends ConsumerWidget {
  final List<InboxEntity> inboxes;
  final TabType tabType;
  final List<MessageChannelEntity> channels;
  final List<MessageMemberEntity> members;
  final List<MessageGroupEntity> groups;
  final List<MessageEmojiEntity> emojis;
  final String searchQuery;
  final ScrollController? scrollController;

  const _MergedInboxesPopup({
    required this.inboxes,
    required this.tabType,
    required this.channels,
    required this.members,
    required this.groups,
    required this.emojis,
    required this.searchQuery,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (inboxes.isEmpty) {
      return Container(
        padding: EdgeInsets.all(12),
        child: Text('No merged inboxes', style: context.bodyMedium?.textColor(context.outline)),
      );
    }

    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: inboxes.asMap().entries.map((entry) {
        final index = entry.key;
        final inbox = entry.value;
        return InboxItem(
          key: ValueKey(inbox.id),
          tabType: tabType,
          inbox: inbox,
          inboxGroup: [inbox],
          isFirst: index == 0,
          channels: channels,
          members: members,
          groups: groups,
          emojis: emojis,
          isSelected: false,
          isSearch: false,
          isSuggestion: false,
          searchQuery: searchQuery,
          isShowcase: false,
        );
      }).toList(),
    );

    if (PlatformX.isMobileView) {
      return child;
    }

    return PopupMenuContainer(
      horizontalPadding: 0,
      child: SingleChildScrollView(controller: scrollController, child: child),
    );
  }
}
