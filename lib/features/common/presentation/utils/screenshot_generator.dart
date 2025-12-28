import 'dart:typed_data';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/toasty_box/model/toast_model.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:super_clipboard/super_clipboard.dart';

class ScreenshotGenerator {
  final ScreenshotController controller;
  final BuildContext context;

  ScreenshotGenerator({required this.controller, required this.context});

  /// 스크린샷을 캡처합니다.
  ///
  /// [pixelRatio]는 이미지의 해상도를 결정합니다. 기본값은 2.0입니다.
  /// [delay]는 캡처 전 대기 시간입니다. 기본값은 100ms입니다.
  Future<Uint8List?> capture({double pixelRatio = 2.0, Duration delay = const Duration(milliseconds: 100)}) async {
    try {
      return await controller.capture(delay: delay, pixelRatio: pixelRatio);
    } catch (e) {
      debugPrint('스크린샷 캡처 실패: $e');
      return null;
    }
  }

  /// 스크린샷을 파일로 저장합니다.
  ///
  /// [fileName]이 제공되지 않으면 타임스탬프 기반 파일명을 생성합니다.
  /// [theme]은 파일명에 포함될 테마 정보입니다 (예: 'light', 'dark').
  Future<bool> saveToFile({String? fileName, String? theme, double pixelRatio = 2.0, Duration delay = const Duration(milliseconds: 100)}) async {
    final imageData = await capture(pixelRatio: pixelRatio, delay: delay);
    if (imageData == null) {
      Utils.showToast(
        ToastModel(
          message: TextSpan(text: '스크린샷 캡처에 실패했습니다.'),
          buttons: [],
        ),
      );
      return false;
    }

    final now = DateTime.now();
    final timestamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';

    final defaultFileName = fileName ?? 'taskey-screenshot-$timestamp${theme != null ? '-$theme' : ''}';
    final finalFileName = defaultFileName.endsWith('.png') ? defaultFileName : '$defaultFileName.png';

    try {
      final success = await downloadBytes(bytes: [imageData], names: [finalFileName], context: context, extensions: ['png']);

      if (success) {
        Utils.showToast(
          ToastModel(
            message: TextSpan(text: '스크린샷이 저장되었습니다: $finalFileName'),
            buttons: [],
          ),
        );
      }

      return success;
    } catch (e) {
      debugPrint('스크린샷 저장 실패: $e');
      Utils.showToast(
        ToastModel(
          message: TextSpan(text: '스크린샷 저장에 실패했습니다.'),
          buttons: [],
        ),
      );
      return false;
    }
  }

  /// 스크린샷을 클립보드에 복사합니다.
  Future<bool> copyToClipboard({double pixelRatio = 2.0, Duration delay = const Duration(milliseconds: 100)}) async {
    final imageData = await capture(pixelRatio: pixelRatio, delay: delay);
    if (imageData == null) {
      Utils.showToast(
        ToastModel(
          message: TextSpan(text: '스크린샷 캡처에 실패했습니다.'),
          buttons: [],
        ),
      );
      return false;
    }

    try {
      final clipboard = SystemClipboard.instance;
      if (clipboard == null) {
        Utils.showToast(
          ToastModel(
            message: TextSpan(text: '클립보드에 접근할 수 없습니다.'),
            buttons: [],
          ),
        );
        return false;
      }

      final item = DataWriterItem();
      item.add(Formats.png(imageData));
      await clipboard.write([item]);

      Utils.showToast(
        ToastModel(
          message: TextSpan(text: Utils.mainContext.tr.image_copied_to_clipboard),
          buttons: [],
        ),
      );

      return true;
    } catch (e) {
      debugPrint('클립보드 복사 실패: $e');
      Utils.showToast(
        ToastModel(
          message: TextSpan(text: '클립보드 복사에 실패했습니다.'),
          buttons: [],
        ),
      );
      return false;
    }
  }

  /// 스크린샷을 저장하거나 클립보드에 복사합니다.
  ///
  /// [saveToFile]이 true이면 파일로 저장하고, false이면 클립보드에 복사합니다.
  Future<bool> captureAndSave({bool saveToFile = true, String? fileName, String? theme, double pixelRatio = 2.0, Duration delay = const Duration(milliseconds: 100)}) async {
    if (saveToFile) {
      return await this.saveToFile(fileName: fileName, theme: theme, pixelRatio: pixelRatio, delay: delay);
    } else {
      return await copyToClipboard(pixelRatio: pixelRatio, delay: delay);
    }
  }
}
