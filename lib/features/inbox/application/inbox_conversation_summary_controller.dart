import 'dart:async';
import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/calendar/application/calendar_event_list_controller.dart';
import 'package:Visir/features/calendar/domain/entities/calendar_entity.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/calendar/providers.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/task/application/calendar_task_list_controller.dart';
import 'package:Visir/features/task/application/project_list_controller.dart';
import 'package:Visir/features/task/domain/entities/task_entity.dart';
import 'package:collection/collection.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/providers.dart';
import 'package:Visir/features/inbox/application/inbox_config_controller.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/infrastructure/repositories/inbox_repository.dart';
import 'package:Visir/features/common/domain/entities/linked_item_entity.dart';
import 'package:Visir/features/inbox/providers.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/mail/providers.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:Visir/features/common/domain/failures/failure.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inbox_conversation_summary_controller.g.dart';

@riverpod
class InboxConversationSummary extends _$InboxConversationSummary {
  static String get stringKey => 'inbox_conversation_summary';

  @override
  Future<String?> build(String? taskId, String? eventId) async {
    if (ref.watch(shouldUseMockDataProvider)) {
      // Mock data for "Align requirements and target date" task
      if (taskId == '04ddee1f-9505-4cb1-8f9b-2461e5a95a75') {
        return 'Harper reported a CSV import bug that was blocking progress. The team discussed requirements and decided to prioritize core features over nice-to-haves to meet the target deadline. Concrete payload examples were shared to clarify implementation details and avoid ambiguity. Testing will begin with a small subset to validate the approach before full implementation.';
      }
      return null;
    }

    final userId = ref.watch(authControllerProvider.select((v) => v.requireValue.id));

    // Watch task/event to detect changes in linkedMail/linkedMessage
    final task = ref.watch(
      calendarTaskListControllerProvider(tabType: TabType.home).select((v) => v.tasksOnView.firstWhereOrNull((t) => (t.isEvent ? t.eventId : t.id) == taskId)),
    );
    final event = ref.watch(calendarEventListControllerProvider(tabType: TabType.home).select((v) => v.eventsOnView.firstWhereOrNull((e) => e.uniqueId == eventId)));

    // If task/event doesn't exist, return null immediately
    if (task == null && event == null) {
      return null;
    }

    await persist(
      ref.watch(storageProvider.future),
      key: 'inbox_conversation_summary:$taskId:$eventId',
      encode: (String? state) => state ?? '',
      decode: (String encoded) => encoded.isEmpty ? null : encoded,
      options: StorageOptions(destroyKey: userId),
    ).future;

    // Step 1: Check local cache first
    if (state.hasValue && state.value != null && state.value!.isNotEmpty) {
      return state.value;
    }

    // Step 2: Try Supabase cache if local cache miss
    final supabaseDatasource = ref.watch(supabaseInboxDatasourceProvider);
    if (taskId != null || eventId != null) {
      try {
        final supabaseSummary = await supabaseDatasource.fetchConversationSummaryFromCache(userId: userId, taskId: taskId, eventId: eventId);
        if (supabaseSummary != null && supabaseSummary.isNotEmpty) {
          // Save to local cache for next time
          state = AsyncData(supabaseSummary);
          return supabaseSummary;
        }
      } catch (e) {
        // Continue to AI generation
      }
    }

    // Step 3: Generate with AI if both caches miss
    final throttleKey = 'inbox_conversation_summary:$taskId:$eventId';
    String? result;
    final completer = Completer<String?>();

    EasyDebounce.debounce(throttleKey, const Duration(seconds: 1), () async {
      try {
        result = await _inboxConversationSummary(ref, taskId, eventId);
        if (!completer.isCompleted) {
          completer.complete(result);
        }
      } catch (e) {
        if (!completer.isCompleted) {
          completer.completeError(e);
        }
      }
    });

    return await completer.future;
  }
}

@riverpod
Future<String?> _inboxConversationSummary(Ref ref, String? taskId, String? eventId) async {
  final repository = ref.watch(inboxRepositoryProvider);
  final userId = ref.read(authControllerProvider).requireValue.id;

  final task = ref.watch(calendarTaskListControllerProvider(tabType: TabType.home).select((v) => v.tasksOnView.firstWhereOrNull((t) => (t.isEvent ? t.eventId : t.id) == taskId)));
  final event = ref.watch(calendarEventListControllerProvider(tabType: TabType.home).select((v) => v.eventsOnView.firstWhereOrNull((e) => e.uniqueId == eventId)));

  if (task == null && event == null) {
    ref.read(loadingStatusProvider.notifier).update(InboxConversationSummary.stringKey, LoadingState.success);
    return null;
  }

  final linkedMail = task?.linkedMails.firstOrNull;
  final linkedMessage = task?.linkedMessages.firstOrNull;

  // Search for related content and generate summary
  final result = await _searchAndGenerateContext(
    ref,
    task,
    event,
    repository,
    userId: userId,
    taskId: taskId,
    eventId: eventId,
    linkedMail: linkedMail,
    linkedMessage: linkedMessage,
  );

  return result;
}

/// Retry helper with exponential backoff for Either types
/// Retries when Left(Failure) is returned, succeeds when Right(T) is returned
Future<Either<Failure, T>> _retryEitherWithBackoff<T>(Future<Either<Failure, T>> Function() operation, {int maxRetries = 3}) async {
  int attempt = 0;
  while (attempt < maxRetries) {
    final result = await operation();

    // If Right (success), return immediately
    if (result.isRight()) {
      return result;
    }

    // If Left (failure), retry
    attempt++;
    if (attempt >= maxRetries) {
      // Return the last failure after max retries
      return result;
    }

    // Exponential backoff: 1s, 2s, 4s
    await Future.delayed(Duration(seconds: 1 << (attempt - 1)));
  }

  // Should not reach here, but return the last result if we do
  return await operation();
}

/// Search for related content in integrated datasources
/// Always performs search, and includes linkedMail/linkedMessage if provided
Future<String?> _searchAndGenerateContext(
  Ref ref,
  TaskEntity? task,
  EventEntity? event,
  InboxRepository repository, {
  required String userId,
  String? taskId,
  String? eventId,
  LinkedMailEntity? linkedMail,
  LinkedMessageEntity? linkedMessage,
}) async {
  ref.read(loadingStatusProvider.notifier).update(InboxConversationSummary.stringKey, LoadingState.loading);

  try {
    // Extract search keywords using OpenAI through repository
    String? taskProjectName;
    String? calendarName;

    if (task != null && task.projectId != null) {
      taskProjectName = ref.read(projectListControllerProvider).firstWhereOrNull((p) => p.uniqueId == task.projectId)?.name;
    } else if (event != null) {
      // For events, use calendar name instead of project
      calendarName = event.calendarName;
    }

    final keywordsResult = await repository.extractSearchKeywords(
      taskTitle: event?.title ?? task?.title ?? '',
      taskDescription: event?.description ?? task?.description ?? '',
      taskProjectName: taskProjectName,
      calendarName: calendarName,
      model: 'gpt-4o-mini', // 기본 모델 사용
    );

    final keywords = keywordsResult.fold((failure) => null, (keywords) => keywords);
    if (keywords == null || keywords.isEmpty) {
      ref.read(loadingStatusProvider.notifier).update(InboxConversationSummary.stringKey, LoadingState.success);
      return '';
    }

    // Get all integrated OAuth accounts
    final mailOAuths = ref.read(localPrefControllerProvider.select((v) => v.value?.mailOAuths)) ?? [];
    final messengerOAuths = ref.read(localPrefControllerProvider.select((v) => v.value?.messengerOAuths)) ?? [];
    final calendarOAuths = ref.read(localPrefControllerProvider.select((v) => v.value?.calendarOAuths)) ?? [];

    // Search in each datasource
    List<InboxEntity> searchResults = [];
    final Set<String> processedThreadIds = {}; // Track processed threadIds to avoid duplicates

    // Process linkedMail/linkedMessage first if provided
    if (linkedMail != null && linkedMail.threadId.isNotEmpty) {
      final threadKey = '${linkedMail.threadId}_${linkedMail.hostMail}';
      if (!processedThreadIds.contains(threadKey)) {
        processedThreadIds.add(threadKey);

        final mailRepository = ref.watch(mailRepositoryProvider);
        final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.mailOAuths)) ?? [];
        final oauth = oauths.firstWhereOrNull((o) => o.email == linkedMail.hostMail);

        if (oauth != null) {
          final threadResult = await mailRepository.fetchThreads(
            oauth: oauth,
            type: linkedMail.type,
            threadId: linkedMail.threadId,
            labelId: CommonMailLabels.inbox.id,
            email: linkedMail.hostMail,
          );

          await threadResult.fold(
            (failure) async {
              // Failed to fetch thread
            },
            (threadMails) async {
              // Convert all thread mails to InboxEntity
              final configs = ref.read(inboxConfigListControllerProvider);
              for (final mail in threadMails) {
                final config = configs?.configs.firstWhereOrNull((c) => c.id == InboxEntity.getInboxIdFromMail(mail));
                searchResults.add(InboxEntity.fromMail(mail, config));
              }
            },
          );
        }
      }
    } else if (linkedMessage != null) {
      // Use threadId if available, otherwise use messageId
      final threadId = linkedMessage.threadId.isNotEmpty && linkedMessage.threadId != linkedMessage.messageId ? linkedMessage.threadId : linkedMessage.messageId;
      final threadKey = '${threadId}_${linkedMessage.teamId}_${linkedMessage.channelId}';

      if (!processedThreadIds.contains(threadKey)) {
        processedThreadIds.add(threadKey);

        final chatRepository = ref.watch(chatRepositoryProvider);
        final channels = ref.read(chatChannelListControllerProvider).values.expand((e) => e.channels).toList();
        final channel = channels.firstWhereOrNull((c) => c.id == linkedMessage.channelId && c.teamId == linkedMessage.teamId);

        if (channel != null) {
          final oauths = ref.read(localPrefControllerProvider.select((v) => v.value?.messengerOAuths)) ?? [];
          final oauth = oauths.firstWhereOrNull((o) => o.team?.id == linkedMessage.teamId);

          if (oauth != null) {
            final threadResult = await chatRepository.fetchReplies(oauth: oauth, channel: channel, parentMessageId: threadId);

            await threadResult.fold(
              (failure) async {
                // Failed to fetch thread replies
              },
              (threadData) async {
                // Convert all thread messages to InboxEntity
                final _channels = ref.read(chatChannelListControllerProvider).values.expand((e) => e.channels).toList();
                final _members = ref.read(chatChannelListControllerProvider).values.expand((e) => e.members).toList();
                final _groups = ref.read(chatChannelListControllerProvider).values.expand((e) => e.groups).toList();
                final configs = ref.read(inboxConfigListControllerProvider);

                for (final message in threadData.messages) {
                  final msgChannel = _channels.firstWhereOrNull((c) => c.id == message.channelId && c.teamId == message.teamId);
                  final member = _members.firstWhereOrNull((m) => m.id == message.userId);
                  if (msgChannel != null && member != null && message.teamId != null && message.channelId != null && message.userId != null) {
                    final config = configs?.configs.firstWhereOrNull((c) => c.id == InboxEntity.getInboxIdFromChat(message));
                    searchResults.add(InboxEntity.fromChat(message, config, msgChannel, member, _channels, _members, _groups));
                  }
                }
              },
            );
          }
        }
      }
    }

    // Search in mail (Gmail, Outlook Mail)
    // For mail providers, combine all keywords into a single query (space-separated)
    // This works better for Gmail/Outlook search syntax
    final mailQuery = keywords.join(' ');
    if (mailQuery.isNotEmpty && !ref.read(shouldUseMockDataProvider)) {
      for (final oauth in mailOAuths) {
        final mailRepository = ref.watch(mailRepositoryProvider);
        final user = ref.read(authControllerProvider).requireValue;

        // Retry with backoff on failure
        final mailResult = await _retryEitherWithBackoff(() async {
          return await mailRepository.fetchMailsForLabel(
            oauth: oauth,
            user: user,
            isInbox: false,
            labelId: null,
            email: null,
            pageToken: null,
            q: mailQuery,
            startDate:
                event?.startDate.subtract(const Duration(days: 30)) ?? task?.startDate.subtract(const Duration(days: 30)) ?? DateTime.now().subtract(const Duration(days: 30)),
            endDate: event?.endDate ?? task?.endDate ?? DateTime.now(),
          );
        });

        await mailResult.fold(
          (failure) async {
            // Mail search failed, skip this OAuth account
          },
          (mails) async {
            // Group mails by threadId
            final Map<String, MailEntity> threadMap = {}; // threadId -> representative mail

            for (final mailList in mails.values) {
              for (final mail in mailList.messages) {
                if (mail.threadId == null || mail.threadId!.isEmpty) continue;

                final threadKey = '${mail.threadId}_${oauth.email}';

                // Check if this threadId already exists (by threadId, not messageId)
                if (processedThreadIds.contains(threadKey)) continue;

                // Keep the most recent mail from each thread as representative
                if (!threadMap.containsKey(threadKey) || (mail.date != null && threadMap[threadKey]!.date != null && mail.date!.isAfter(threadMap[threadKey]!.date!))) {
                  threadMap[threadKey] = mail;
                }
              }
            }

            // Fetch full thread for each unique threadId
            for (final entry in threadMap.entries) {
              final threadKey = entry.key;
              final representativeMail = entry.value;

              if (processedThreadIds.contains(threadKey)) continue;
              processedThreadIds.add(threadKey);

              // Fetch full thread
              final threadResult = await mailRepository.fetchThreads(
                oauth: oauth,
                type: representativeMail.type,
                threadId: representativeMail.threadId!,
                labelId: CommonMailLabels.inbox.id,
                email: oauth.email,
              );

              await threadResult.fold(
                (failure) async {
                  // Failed to fetch thread, skip this thread
                },
                (threadMails) async {
                  // Convert all thread mails to InboxEntity
                  final configs = ref.read(inboxConfigListControllerProvider);
                  for (final mail in threadMails) {
                    final config = configs?.configs.firstWhereOrNull((c) => c.id == InboxEntity.getInboxIdFromMail(mail));
                    searchResults.add(InboxEntity.fromMail(mail, config));
                  }
                },
              );
            }
          },
        );
      }
    }

    // Search in chat (Slack)
    // For Slack, combine all keywords into a single query (space-separated)
    // Slack search treats space-separated keywords as OR by default, but combining them
    // reduces API calls and provides broader search results
    final chatQuery = keywords.join(' ');
    if (chatQuery.isNotEmpty && !ref.read(shouldUseMockDataProvider)) {
      for (final oauth in messengerOAuths) {
        final chatRepository = ref.watch(chatRepositoryProvider);
        final channels = ref.read(chatChannelListControllerProvider).values.expand((e) => e.channels).toList();
        final user = ref.read(authControllerProvider).requireValue;

        // Retry with backoff on failure
        final chatResult = await _retryEitherWithBackoff(() async {
          return await chatRepository.searchMessage(oauth: oauth, user: user, q: chatQuery, pageToken: null, channels: channels, sortType: SearchSortType.relevant);
        });

        await chatResult.fold(
          (failure) async {
            // Chat search failed, skip this OAuth account
          },
          (result) async {
            // Group messages by threadId
            final Map<String, MessageEntity> threadMap = {}; // threadKey -> representative message

            for (final message in result.messages) {
              // Use threadId if available, otherwise use messageId as threadId
              final threadId = message.threadId?.isNotEmpty == true && message.threadId != message.id ? message.threadId! : message.id;
              final threadKey = '${threadId}_${message.teamId}_${message.channelId}';

              // Check if this threadId already exists (by threadId, not messageId)
              if (processedThreadIds.contains(threadKey)) continue;

              // Keep the most recent message from each thread as representative
              if (!threadMap.containsKey(threadKey) ||
                  (message.createdAt != null && threadMap[threadKey]!.createdAt != null && message.createdAt!.isAfter(threadMap[threadKey]!.createdAt!))) {
                threadMap[threadKey] = message;
              }
            }

            // Fetch full thread for each unique threadId
            for (final entry in threadMap.entries) {
              final threadKey = entry.key;
              final representativeMessage = entry.value;

              if (processedThreadIds.contains(threadKey)) continue;
              processedThreadIds.add(threadKey);

              final _channels = ref.read(chatChannelListControllerProvider).values.expand((e) => e.channels).toList();
              final channel = _channels.firstWhereOrNull((c) => c.id == representativeMessage.channelId && c.teamId == representativeMessage.teamId);

              if (channel == null) continue;

              // Use threadId if available, otherwise use messageId
              final parentMessageId = representativeMessage.threadId?.isNotEmpty == true && representativeMessage.threadId != representativeMessage.id
                  ? representativeMessage.threadId!
                  : representativeMessage.id;

              if (parentMessageId == null) continue;

              // Fetch full thread
              final threadResult = await chatRepository.fetchReplies(oauth: oauth, channel: channel, parentMessageId: parentMessageId);

              await threadResult.fold(
                (failure) async {
                  // Failed to fetch thread replies, skip this thread
                },
                (threadData) async {
                  // Convert all thread messages to InboxEntity
                  final _members = ref.read(chatChannelListControllerProvider).values.expand((e) => e.members).toList();
                  final _groups = ref.read(chatChannelListControllerProvider).values.expand((e) => e.groups).toList();
                  final configs = ref.read(inboxConfigListControllerProvider);

                  for (final message in threadData.messages) {
                    final member = _members.firstWhereOrNull((m) => m.id == message.userId);
                    if (member != null && message.teamId != null && message.channelId != null && message.userId != null) {
                      final config = configs?.configs.firstWhereOrNull((c) => c.id == InboxEntity.getInboxIdFromChat(message));
                      searchResults.add(InboxEntity.fromChat(message, config, channel, member, _channels, _members, _groups));
                    }
                  }
                },
              );
            }
          },
        );
      }
    }

    // Search in calendar (Google Calendar, Outlook Calendar)
    // Combine all keywords into a single query (space-separated) for better search results
    List<EventEntity> eventEntities = [];
    final calendarQuery = keywords.join(' ');
    if (calendarQuery.isNotEmpty && !ref.read(shouldUseMockDataProvider)) {
      for (final oauth in calendarOAuths) {
        final calendarRepository = ref.watch(calendarRepositoryProvider);
        final calendarListResult = await calendarRepository.fetchCalendarLists(oauth: oauth);

        await calendarListResult.fold(
          (failure) async {
            // Calendar list fetch failed, skip this OAuth account
          },
          (calendarMap) async {
            final calendars = calendarMap.values
                .expand((e) => e)
                .where((c) => c.email == oauth.email && c.type != null && c.type!.datasourceType == oauth.type.datasourceType)
                .toList();
            if (calendars.isEmpty) return;

            // Retry with backoff on failure
            final eventResult = await _retryEitherWithBackoff(() async {
              return await calendarRepository.searchEventLists(query: calendarQuery, oauth: oauth, calendars: calendars, nextPageTokens: null);
            });

            await eventResult.fold(
              (failure) async {
                // Calendar search failed, skip this OAuth account
              },
              (result) async {
                // Collect all events from the result, excluding the current event
                for (final eventList in result.events.values) {
                  for (final foundEvent in eventList) {
                    // Exclude the current event if it exists
                    if (event == null || foundEvent.uniqueId != event.uniqueId) {
                      eventEntities.add(foundEvent);
                    }
                  }
                }
              },
            );
          },
        );
      }
    }

    // Limit total results to avoid overwhelming the context
    searchResults = searchResults.take(20).toList();

    if (searchResults.isEmpty && eventEntities.isEmpty) {
      ref.read(loadingStatusProvider.notifier).update(InboxConversationSummary.stringKey, LoadingState.success);
      return null;
    }

    // Create a virtual inbox from search results for summary generation
    // Prefer linkedMail/linkedMessage if provided, otherwise use first search result
    final firstLinkedInbox = searchResults.firstWhereOrNull((i) => i.linkedMail != null || i.linkedMessage != null);

    // Create inbox from linkedMail/linkedMessage if provided, otherwise use first search result
    InboxEntity? baseInbox;
    if (linkedMail != null) {
      baseInbox = InboxEntity(id: InboxEntity.getInboxIdFromLinkedMail(linkedMail), title: linkedMail.title, description: null, linkedMail: linkedMail);
    } else if (linkedMessage != null) {
      baseInbox = InboxEntity(id: InboxEntity.getInboxIdFromLinkedChat(linkedMessage), title: linkedMessage.userName, description: null, linkedMessage: linkedMessage);
    }

    final virtualInbox =
        baseInbox ??
        InboxEntity(
          id: 'search_${event?.uniqueId ?? task?.id}',
          title: event?.title ?? task?.title ?? 'Untitled',
          description: event?.description ?? task?.description,
          linkedMail: firstLinkedInbox?.linkedMail,
          linkedMessage: firstLinkedInbox?.linkedMessage,
        );

    // Generate summary from search results
    final summaryResult = await repository.fetchConversationSummary(
      inbox: virtualInbox,
      allInboxes: searchResults,
      eventEntities: eventEntities,
      userId: userId,
      taskId: taskId,
      eventId: eventId,
    );

    ref.read(loadingStatusProvider.notifier).update(InboxConversationSummary.stringKey, LoadingState.success);
    return summaryResult.fold((failure) => null, (summary) => summary);
  } catch (e) {
    ref.read(loadingStatusProvider.notifier).update(InboxConversationSummary.stringKey, LoadingState.error);
    return null;
  }
}
