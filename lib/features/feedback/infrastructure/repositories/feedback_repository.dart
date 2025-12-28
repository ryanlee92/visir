import 'dart:io';

import 'package:Visir/features/common/domain/failures/failure.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/feedback/domain/datasources/feedback_datasource.dart';
import 'package:Visir/features/feedback/domain/entities/feedback_entity.dart';
import 'package:fpdart/fpdart.dart';

class FeedbackRepository {
  final FeedbackDatasource datasource;

  FeedbackRepository({required this.datasource});

  Future<Either<Failure, void>> insertFeedback({required FeedbackEntity feedback}) async {
    try {
      final result = await datasource.uploadFeedback(feedback: feedback);
      return right(result);
    } catch (e) {
      return left(Failure.badRequest(StackTrace.current, e.toString()));
    }
  }

  Future<Either<Failure, List<String>>> uploadFiles({required List<File> files, required String userId, required String feedbackId}) async {
    try {
      final result = await datasource.uploadFiles(files: files, userId: userId, feedbackId: feedbackId);
      return right(result);
    } catch (e) {
      return Utils.debugLeft(e);
    }
  }
}
