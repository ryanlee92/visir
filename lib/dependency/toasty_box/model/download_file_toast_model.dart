import 'package:Visir/dependency/toasty_box/model/toast_model.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadFileToastModel extends ToastModel {
  final bool isSuccess;
  final String path;
  final String? directoryPath;
  final String? downloadUrl;

  DownloadFileToastModel({
    required this.isSuccess,
    required this.path,
    required this.directoryPath,
    required this.downloadUrl,
  }) : super(
          message: TextSpan(
            children: [
              TextSpan(
                  text: isSuccess ? Utils.mainContext.tr.chat_toast_downloaded : Utils.mainContext.tr.chat_toast_download_failed,
                  style: Utils.mainContext.bodyLarge?.textBold),
              TextSpan(text: ' ${directoryPath == null ? path.split('/').lastOrNull : directoryPath}'),
            ],
            style: Utils.mainContext.bodyLarge,
          ),
          buttons: isSuccess
              ? [
                  ToastButton(
                      text: Utils.mainContext.tr.chat_toast_show_in_folder,
                      color: Utils.mainContext.surfaceVariant,
                      textColor: Utils.mainContext.onSurface,
                      onTap: (item) {
                        final separator = PlatformX.isWindows ? '\\' : '/';
                        List<String> list = path.split(separator);
                        list.removeLast();
                        final folderPath = list.join(separator);
                        OpenFile.open(directoryPath ?? folderPath);
                      }),
                  ToastButton(
                    text: Utils.mainContext.tr.chat_toast_open,
                    color: Utils.mainContext.primary,
                    textColor: Utils.mainContext.onPrimary,
                    onTap: (item) {
                      OpenFile.open(path);
                    },
                  ),
                ]
              : [
                  if (downloadUrl != null)
                    ToastButton(
                      text: Utils.mainContext.tr.chat_toast_download_from_link,
                      color: Utils.mainContext.primary,
                      textColor: Utils.mainContext.onPrimary,
                      onTap: (item) {
                        launchUrl(Uri.parse(downloadUrl));
                      },
                    )
                ],
        );

  String get name {
    return path.split('/').last;
  }

  String get folderPath {
    if (directoryPath != null) return directoryPath!;
    List<String> list = path.split('/');
    list.removeLast();
    return list.join('/');
  }
}
