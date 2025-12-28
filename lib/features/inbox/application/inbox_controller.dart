import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/inbox/application/inbox_agent_list_controller.dart';
import 'package:Visir/features/inbox/application/inbox_list_controller.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_fetch_list_entity.dart';
import 'package:Visir/features/inbox/providers.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inbox_controller.g.dart';

@riverpod
class InboxController extends _$InboxController {
  @override
  InboxFetchListEntity? build() {
    if (ref.watch(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.agent))) {
      return ref.watch(inboxAgentListControllerProvider);
    } else {
      return ref.watch(inboxListControllerProvider);
    }
  }

  Future<void> refresh() async {
    if (ref.watch(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.agent))) {
      return ref.read(inboxAgentListControllerProvider.notifier).refresh();
    } else {
      return ref.read(inboxListControllerProvider.notifier).refresh();
    }
  }

  void upsertMailInboxLocally(List<MailEntity> mails) {
    if (ref.watch(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.agent))) {
      ref.read(inboxAgentListControllerProvider.notifier).upsertMailInboxLocally(mails);
    } else {
      ref.read(inboxListControllerProvider.notifier).upsertMailInboxLocally(mails);
    }
  }

  void removeMailInboxLocally(String mailId) {
    if (ref.watch(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.agent))) {
      ref.read(inboxAgentListControllerProvider.notifier).removeMailInboxLocally(mailId);
    } else {
      ref.read(inboxListControllerProvider.notifier).removeMailInboxLocally(mailId);
    }
  }

  void readMailLocally(List<String> threadIds) {
    if (ref.watch(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.agent))) {
      ref.read(inboxAgentListControllerProvider.notifier).readMailLocally(threadIds);
    } else {
      ref.read(inboxListControllerProvider.notifier).readMailLocally(threadIds);
    }
  }

  void removeMailLocally(List<String> threadIds) {
    if (ref.watch(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.agent))) {
      ref.read(inboxAgentListControllerProvider.notifier).removeMailLocally(threadIds);
    } else {
      ref.read(inboxListControllerProvider.notifier).removeMailLocally(threadIds);
    }
  }

  void unreadMailLocally(List<String> threadIds) {
    if (ref.watch(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.agent))) {
      ref.read(inboxAgentListControllerProvider.notifier).unreadMailLocally(threadIds);
    } else {
      ref.read(inboxListControllerProvider.notifier).unreadMailLocally(threadIds);
    }
  }

  void pinMailLocally(List<String> threadIds) {
    if (ref.watch(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.agent))) {
      ref.read(inboxAgentListControllerProvider.notifier).pinMailLocally(threadIds);
    } else {
      ref.read(inboxListControllerProvider.notifier).pinMailLocally(threadIds);
    }
  }

  void unpinMailLocally(List<String> threadIds) {
    if (ref.watch(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.agent))) {
      ref.read(inboxAgentListControllerProvider.notifier).unpinMailLocally(threadIds);
    } else {
      ref.read(inboxListControllerProvider.notifier).unpinMailLocally(threadIds);
    }
  }

  void upsertMessageInboxLocally(MessageEntity message, MessageChannelEntity channel) {
    if (ref.watch(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.agent))) {
      ref.read(inboxAgentListControllerProvider.notifier).upsertMessageInboxLocally(message, channel);
    } else {
      ref.read(inboxListControllerProvider.notifier).upsertMessageInboxLocally(message, channel);
    }
  }

  void removeMessageInboxLocally(String messageId) {
    if (ref.watch(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.agent))) {
      ref.read(inboxAgentListControllerProvider.notifier).removeMessageInboxLocally(messageId);
    } else {
      ref.read(inboxListControllerProvider.notifier).removeMessageInboxLocally(messageId);
    }
  }

  void updateIsSearchDone(bool isSearchDone) {
    if (ref.watch(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.agent))) {
      ref.read(inboxAgentListControllerProvider.notifier).updateIsSearchDone(isSearchDone);
    } else {
      ref.read(inboxListControllerProvider.notifier).updateIsSearchDone(isSearchDone);
    }
  }

  Future<void> loadMore() async {
    if (ref.watch(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.agent))) {
      // ref.read(inboxAgentListControllerProvider.notifier).loadMore();
      return;
    } else {
      return ref.read(inboxListControllerProvider.notifier).loadMore();
    }
  }

  void loadRecent() {
    if (ref.watch(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.agent))) {
      // ref.read(inboxAgentListControllerProvider.notifier).loadRecent();
    } else {
      ref.read(inboxListControllerProvider.notifier).loadRecent();
    }
  }

  List<InboxEntity> get availableInboxes {
    if (ref.watch(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.agent))) {
      return ref.read(inboxAgentListControllerProvider.notifier).availableInboxes;
    } else {
      return ref.read(inboxListControllerProvider.notifier).availableInboxes;
    }
  }

  ValueNotifier<bool> get isSearchDoneListenable {
    if (ref.watch(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.agent))) {
      return ref.read(inboxAgentListControllerProvider.notifier).isSearchDoneListenable;
    } else {
      return ref.read(inboxListControllerProvider.notifier).isSearchDoneListenable;
    }
  }

  bool isAbleToLoadMore() {
    if (ref.watch(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.agent))) {
      return ref.read(inboxAgentListControllerProvider.notifier).isAbleToLoadMore();
    } else {
      return ref.read(inboxListControllerProvider.notifier).isAbleToLoadMore();
    }
  }

  void clear() {
    if (ref.watch(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.agent))) {
      ref.read(inboxAgentListControllerProvider.notifier).clear();
    } else {
      ref.read(inboxListControllerProvider.notifier).clear();
    }
  }

  Future<void> search({required String query}) async {
    if (ref.watch(currentInboxScreenTypeProvider.select((v) => v == InboxScreenType.agent))) {
      // Agent controller doesn't have search method
      return;
    } else {
      return ref.read(inboxListControllerProvider.notifier).search(query: query);
    }
  }
}
