import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_file_entity.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';

enum MessageFileEntityType {
  slack,
}

class MessageFileEntity {
  //for slack
  final SlackMessageFileEntity? _slackMessageFile;

  SlackMessageFileEntity? get slackFile => _slackMessageFile;

  //common
  final MessageFileEntityType type;

  MessageFileEntity.fromSlack({SlackMessageFileEntity? file})
      : _slackMessageFile = file,
        type = MessageFileEntityType.slack;

  factory MessageFileEntity.fromJson(Map<String, dynamic> json) {
    MessageFileEntityType messageReactionType = MessageFileEntityType.values.firstWhere(
      (e) => e.name == json['messageFileType'],
      orElse: () => MessageFileEntityType.slack,
    );

    if (messageReactionType == MessageFileEntityType.slack) {
      return MessageFileEntity.fromSlack(
        file: SlackMessageFileEntity.fromJson(json['_slackMessageFile']),
      );
    }

    return MessageFileEntity.fromSlack(
      file: SlackMessageFileEntity.fromJson(json['_slackMessageFile']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "messageFileType": type.name,
      "_slackMessageFile": _slackMessageFile?.toJson(),
    };
  }

  String? get id {
    switch (type) {
      case MessageFileEntityType.slack:
        return _slackMessageFile?.id;
    }
  }

  String? get name {
    switch (type) {
      case MessageFileEntityType.slack:
        return _slackMessageFile?.name;
    }
  }

  String? get filetype {
    switch (type) {
      case MessageFileEntityType.slack:
        return _slackMessageFile?.filetype?.isNotEmpty == true ? _slackMessageFile!.filetype : null;
    }
  }

  bool get isImage {
    switch (type) {
      case MessageFileEntityType.slack:
        final path = name?.contains('.') == true ? name : _slackMessageFile?.urlPrivate;
        if (_slackMessageFile?.mimetype?.isNotEmpty == true) return _slackMessageFile!.mimetype!.contains('image');

        bool hasExtension = false;
        [
          'apng',
          'png',
          'avif',
          'gif',
          'jpg',
          'jpeg',
          'jfif',
          'pjpeg',
          'pjp',
          'svg',
          'webp',
          'bmp',
          'ico',
          'cur',
        ].forEach((e) {
          if (filetype != null && filetype!.toLowerCase().contains(e.toLowerCase())) {
            hasExtension = filetype!.toLowerCase().contains(e.toLowerCase());
          } else if (path?.toLowerCase().contains('.${e.toLowerCase()}') ?? false) {
            hasExtension = path?.toLowerCase().contains('.${e.toLowerCase()}') ?? false;
          }
        });
        return hasExtension;
    }
  }

  bool get isVideo {
    switch (type) {
      case MessageFileEntityType.slack:
        final path = name?.contains('.') == true ? name : _slackMessageFile?.urlPrivate;
        if (_slackMessageFile?.mimetype?.isNotEmpty == true) return _slackMessageFile!.mimetype!.contains('video');
        bool hasExtension = false;
        [
          'webm',
          'mkv',
          'flv',
          'vob',
          'ogv',
          'ogg',
          'rrc',
          'gifv',
          'mng',
          'mov',
          'avi',
          'qt',
          'wmv',
          'yuv',
          'rm',
          'asf',
          'amv',
          'mp4',
          'm4p',
          'm4v',
          'mpg',
          'mp2',
          'mpeg',
          'mpe',
          'mpv',
          'm4v',
          'svi',
          '3gp',
          '3g2',
          'mxf',
          'roq',
          'nsv',
          'flv',
          'f4v',
          'f4p',
          'f4a',
          'f4b',
          'mod',
        ].forEach((e) {
          if (filetype != null && filetype!.toLowerCase().contains(e.toLowerCase())) {
            hasExtension = filetype!.toLowerCase().contains(e.toLowerCase());
          } else if (path?.toLowerCase().contains('.${e.toLowerCase()}') ?? false) {
            hasExtension = path?.toLowerCase().contains('.${e.toLowerCase()}') ?? false;
          }
        });
        return hasExtension;
    }
  }

  bool get isAudio {
    switch (type) {
      case MessageFileEntityType.slack:
        final path = name?.contains('.') == true ? name : _slackMessageFile?.urlPrivate;
        if (_slackMessageFile?.mimetype?.isNotEmpty == true) return _slackMessageFile!.mimetype!.contains('audio');
        bool hasExtension = false;
        [
          "wav",
          "bwf",
          "raw",
          "aiff",
          "flac",
          "m4a",
          "pac",
          "tta",
          "wv",
          "ast",
          "aac",
          "mp3",
          "amr",
          "s3m",
          "3gp",
          "act",
          "au",
          "dct",
          "dss",
          "gsm",
          "m4p",
          "mmf",
          "mpc",
          "ogg",
          "oga",
          "opus",
          "ra",
          "sln",
          "vox"
        ].forEach((e) {
          if (filetype != null && filetype!.toLowerCase().contains(e.toLowerCase())) {
            hasExtension = filetype!.toLowerCase().contains(e.toLowerCase());
          } else if (path?.toLowerCase().contains('.${e.toLowerCase()}') ?? false) {
            hasExtension = path?.toLowerCase().contains('.${e.toLowerCase()}') ?? false;
          }
        });
        return hasExtension;
    }
  }

  String? get downloadUrl {
    switch (type) {
      case MessageFileEntityType.slack:
        return _slackMessageFile?.urlPrivateDownload;
    }
  }

  int? get width360 {
    switch (type) {
      case MessageFileEntityType.slack:
        return _slackMessageFile?.thumb_360_w;
    }
  }

  int? get height360 {
    switch (type) {
      case MessageFileEntityType.slack:
        return _slackMessageFile?.thumb_360_h;
    }
  }

  int? get width {
    switch (type) {
      case MessageFileEntityType.slack:
        return _slackMessageFile?.original_w ?? _slackMessageFile?.thumb_video_w;
    }
  }

  int? get height {
    switch (type) {
      case MessageFileEntityType.slack:
        return _slackMessageFile?.original_h ?? _slackMessageFile?.thumb_video_h;
    }
  }

  String? get imageSource {
    switch (type) {
      case MessageFileEntityType.slack:
        return _slackMessageFile?.thumb_video ?? _slackMessageFile?.urlPrivateDownload;
    }
  }
}

extension PlatformFileX on PlatformFile {
  bool get isImage {
    if (!PlatformX.isWeb) {
      return lookupMimeType(this.name)?.contains('image') ?? false;
    }

    bool hasExtension = false;
    [
      'apng',
      'png',
      'avif',
      'gif',
      'jpg',
      'jpeg',
      'jfif',
      'pjpeg',
      'pjp',
      'svg',
      'webp',
      'bmp',
      'ico',
      'cur',
    ].forEach((e) {
      if (name.toLowerCase().contains('.${e.toLowerCase()}')) {
        hasExtension = name.toLowerCase().contains('.${e.toLowerCase()}');
      }
    });
    return hasExtension;
  }

  bool get isVideo {
    if (!PlatformX.isWeb) {
      return lookupMimeType(this.name)?.contains('video') ?? false;
    }

    bool hasExtension = false;
    [
      'webm',
      'mkv',
      'flv',
      'vob',
      'ogv',
      'ogg',
      'rrc',
      'gifv',
      'mng',
      'mov',
      'avi',
      'qt',
      'wmv',
      'yuv',
      'rm',
      'asf',
      'amv',
      'mp4',
      'm4p',
      'm4v',
      'mpg',
      'mp2',
      'mpeg',
      'mpe',
      'mpv',
      'm4v',
      'svi',
      '3gp',
      '3g2',
      'mxf',
      'roq',
      'nsv',
      'flv',
      'f4v',
      'f4p',
      'f4a',
      'f4b',
      'mod',
    ].forEach((e) {
      if (name.toLowerCase().contains('.${e.toLowerCase()}')) {
        hasExtension = name.toLowerCase().contains('.${e.toLowerCase()}');
      }
    });
    return hasExtension;
  }

  bool get isAudio {
    if (!PlatformX.isWeb) {
      return lookupMimeType(this.name)?.contains('audio') ?? false;
    }

    bool hasExtension = false;
    [
      "wav",
      "bwf",
      "raw",
      "aiff",
      "flac",
      "m4a",
      "pac",
      "tta",
      "wv",
      "ast",
      "aac",
      "mp3",
      "amr",
      "s3m",
      "3gp",
      "act",
      "au",
      "dct",
      "dss",
      "gsm",
      "m4p",
      "mmf",
      "mpc",
      "ogg",
      "oga",
      "opus",
      "ra",
      "sln",
      "vox"
    ].forEach((e) {
      if (name.toLowerCase().contains('.${e.toLowerCase()}')) {
        hasExtension = name.toLowerCase().contains('.${e.toLowerCase()}');
      }
    });
    return hasExtension;
  }
}
