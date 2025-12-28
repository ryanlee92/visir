import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:googleapis/calendar/v3.dart' as GoogleCalendar;
import 'package:microsoft_graph_api/models/models.dart';

part 'event_attachment_entity.freezed.dart';
part 'event_attachment_entity.g.dart';

@freezed
abstract class EventAttachmentEntity with _$EventAttachmentEntity {
  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory EventAttachmentEntity({
    String? fileId,
    String? fileUrl,
    String? iconLink,
    String? mimeType,
    String? title,
    int? size,
    bool? isInline,
  }) = _EventAttachmentEntity;

  /// Serialization
  factory EventAttachmentEntity.fromJson(Map<String, dynamic> json) => _$EventAttachmentEntityFromJson(json);
}

extension EventAttachmentEntityX on EventAttachmentEntity {
  GoogleCalendar.EventAttachment toGoogleEntity() {
    return GoogleCalendar.EventAttachment(
      fileId: fileId,
      fileUrl: fileUrl,
      iconLink: iconLink,
      mimeType: mimeType,
      title: title,
    );
  }

  static EventAttachmentEntity fromGoogleEntity(GoogleCalendar.EventAttachment eventAttachment) {
    return EventAttachmentEntity(
      fileId: eventAttachment.fileId,
      fileUrl: eventAttachment.fileUrl,
      iconLink: eventAttachment.iconLink,
      mimeType: eventAttachment.mimeType,
      title: eventAttachment.title,
    );
  }

  Attachment toMsEntity() {
    return Attachment(
      id: fileId,
      name: title,
      contentType: mimeType,
      size: size,
      isInline: isInline,
    );
  }

  static EventAttachmentEntity fromMsEntity(Attachment eventAttachment) {
    return EventAttachmentEntity(
      fileId: eventAttachment.id,
      mimeType: eventAttachment.contentType,
      title: eventAttachment.name,
      size: eventAttachment.size,
      isInline: eventAttachment.isInline,
    );
  }
}
