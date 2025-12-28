import 'dart:io';

import 'package:Visir/dependency/toasty_box/model/toast_model.dart';
import 'package:Visir/features/auth/application/auth_controller.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/feedback/domain/entities/feedback_entity.dart';
import 'package:Visir/features/feedback/infrastructure/repositories/feedback_repository.dart';
import 'package:Visir/features/feedback/providers.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'feedback_controller.g.dart';

@riverpod
class FeedbackController extends _$FeedbackController {
  late FeedbackRepository _repository;

  @override
  AsyncValue<void> build() {
    _repository = ref.watch(feedbackRepositoryProvider);
    return AsyncData(null);
  }

  Future<void> upsertUserFeedback({required String description, required List<File> files}) async {
    final user = ref.read(authControllerProvider).requireValue;
    if (!user.isSignedIn) return;

    List<String> filePaths = [];
    String feedbackId = Uuid().v4();

    if (files.isNotEmpty) {
      final fileUploadResult = await _repository.uploadFiles(files: files, userId: user.id, feedbackId: feedbackId);
      fileUploadResult.fold(
        (l) {
          Utils.showToast(
            ToastModel(
              message: TextSpan(text: Utils.mainContext.tr.feedback_sent_wrong),
              buttons: [],
            ),
          );
          return;
        },
        (r) {
          filePaths = r;
          return;
        },
      );
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    final newFeedback = FeedbackEntity(
      id: feedbackId,
      authorId: user.id,
      description: description,
      createdAt: DateTime.now(),
      fileUrls: filePaths,
      version: 'v$version+$buildNumber',
      isAutoReport: false,
      platform: PlatformX.name,
      osVersion: PlatformX.version,
    );

    final result = await _repository.insertFeedback(feedback: newFeedback);
    result.fold(
      (l) {
        Utils.showToast(
          ToastModel(
            message: TextSpan(text: Utils.mainContext.tr.feedback_sent_wrong),
            buttons: [],
          ),
        );
        return;
      },
      (r) {
        Utils.showToast(
          ToastModel(
            message: TextSpan(text: Utils.mainContext.tr.feedback_sent_successfully),
            buttons: [],
          ),
        );
      },
    );
  }

  Future<void> upsertAutoFeedback({required String errorMessage}) async {
    final user = ref.read(authControllerProvider).requireValue;
    if (!user.isSignedIn) return;

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    final newFeedback = FeedbackEntity(
      id: Uuid().v4(),
      authorId: user.id,
      description: '',
      createdAt: DateTime.now(),
      fileUrls: [],
      version: 'v$version+$buildNumber',
      isAutoReport: true,
      errorMessage: errorMessage,
      platform: PlatformX.name,
      osVersion: PlatformX.version,
    );

    await _repository.insertFeedback(feedback: newFeedback);
  }
}
