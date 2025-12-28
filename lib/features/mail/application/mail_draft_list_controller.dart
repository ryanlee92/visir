import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'mail_draft_list_controller.g.dart';

@riverpod
class MailDraftListController extends _$MailDraftListController {
  @override
  AsyncValue<List<MailEntity>> build() {
    return AsyncValue.data([]);
  }

  void add(MailEntity draft) {
    state = AsyncData([draft, ...(state.value ?? [])]);
  }

  void remove(MailEntity draft) {
    state = AsyncData([...(state.value ?? [])..removeWhere((d) => d.uniqueId == draft.uniqueId)]);
  }

  void clear() {
    state = AsyncData([]);
  }

  void replace(MailEntity draft, MailEntity newDraft) {
    if (state.value?.contains(draft) == true) {
      final index = state.value!.indexOf(draft);
      state = AsyncData([
        ...(state.value ?? [])..replaceRange(index, index + 1, [newDraft]),
      ]);
    }
  }
}
