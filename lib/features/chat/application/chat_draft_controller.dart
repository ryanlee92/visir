import 'dart:async';
import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/chat/domain/entities/chat_draft_entity.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_draft_controller.g.dart';

@riverpod
class ChatDraftController extends _$ChatDraftController {
  late bool isSignedIn;
  late bool initialDraftSetted;

  @override
  ChatDraftEntity? build({required String teamId, required String channelId, String? threadId}) {
    isSignedIn = ref.watch(authControllerProvider.select((v) => v.requireValue.isSignedIn));
    if (ref.read(shouldUseMockDataProvider)) return null;
    initialDraftSetted = false;
    ref.watch((chatDraftControllerInternalProvider(teamId, channelId, threadId, isSignedIn)).future).then((value) {
      if (initialDraftSetted) return;
      initialDraftSetted = true;
      updateState(value);
    });
    return null;
  }

  Timer? draftTimer;
  void setDraft(ChatDraftEntity? draft) {
    if (timer == null) ref.read(chatDraftControllerInternalProvider(teamId, channelId, threadId, isSignedIn).notifier).setDraft(draft);
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: kControllerDebouncMillisecond), () {
      ref.read(chatDraftControllerInternalProvider(teamId, channelId, threadId, isSignedIn).notifier).setDraft(draft);
      timer = null;
    });
  }

  Timer? timer;
  void updateState(ChatDraftEntity? data) {
    if (timer == null) state = data;
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: kControllerDebouncMillisecond), () {
      state = data;
      timer = null;
    });
  }
}

@riverpod
class ChatDraftControllerInternal extends _$ChatDraftControllerInternal {
  @override
  Future<ChatDraftEntity?> build(String teamId, String channelId, String? threadId, bool isSignedIn) async {
    if (!ref.watch(shouldUseMockDataProvider)) {
      await persist(
        ref.watch(storageProvider.future),
        key: 'chat_draft_${isSignedIn}_${teamId}_${channelId}_${threadId}',
        encode: (ChatDraftEntity? state) => state == null ? '' : jsonEncode(state.toJson()),
        decode: (String encoded) {
          if (ref.watch(shouldUseMockDataProvider)) return null;
          final trimmed = encoded.trim();
          if (trimmed.isEmpty || trimmed == 'null') {
            return null;
          }
          return ChatDraftEntity.fromJson(jsonDecode(trimmed) as Map<String, dynamic>);
        },
        options: Utils.storageOptions,
      ).future;
    }
    return state.value;
  }

  void setDraft(ChatDraftEntity? draft) {
    state = AsyncValue.data(draft);
  }
}
