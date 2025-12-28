import 'package:file_picker/file_picker.dart';

class MessageUploadingTempFileEntity {
  final PlatformFile file;
  final bool onProcess;
  final String? uploadUrl;
  final String? fileId;
  final bool? ok;

  MessageUploadingTempFileEntity({required this.file, required this.onProcess, required this.uploadUrl, required this.fileId, required this.ok});
}
