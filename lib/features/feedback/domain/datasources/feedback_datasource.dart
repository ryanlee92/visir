import 'dart:io';

import 'package:Visir/features/feedback/domain/entities/feedback_entity.dart';

abstract class FeedbackDatasource {
  Future<void> uploadFeedback({required FeedbackEntity feedback});

  Future<List<String>> uploadFiles({required List<File> files, required String userId, required String feedbackId});
}
