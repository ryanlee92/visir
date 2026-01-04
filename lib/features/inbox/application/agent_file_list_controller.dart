import 'package:Visir/config/providers.dart';
import 'package:Visir/features/chat/domain/entities/state/message_uploading_temp_file_entity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'agent_file_list_controller.g.dart';

@riverpod
class AgentFileListController extends _$AgentFileListController {
  bool get isUploading => state.any((e) => e.onProcess);

  @override
  List<MessageUploadingTempFileEntity> build({required TabType tabType}) {
    return [];
  }

  Future<void> addFile({required PlatformFile file}) async {
    // 이미 추가된 파일인지 확인
    if (state.where((e) => e.file.identifier == file.identifier).toList().isNotEmpty) return;

    // 파일을 임시 목록에 추가 (업로드 URL은 나중에 필요시 처리)
    state = List.from(state)
      ..add(MessageUploadingTempFileEntity(
        file: file,
        onProcess: false,
        uploadUrl: null,
        fileId: null,
        ok: true, // agent chat에서는 파일을 바로 사용 가능한 것으로 표시
      ));
  }

  void removeTemporaryFile({required PlatformFile file}) {
    List<MessageUploadingTempFileEntity> oldData = List.from(state);
    oldData.removeWhere((e) {
      return e.file.identifier == file.identifier;
    });
    state = oldData;
  }

  void clear() {
    state = [];
  }
}

