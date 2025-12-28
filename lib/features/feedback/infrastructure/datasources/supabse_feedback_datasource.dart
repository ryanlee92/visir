import 'dart:io';

import 'package:Visir/features/feedback/domain/datasources/feedback_datasource.dart';
import 'package:Visir/features/feedback/domain/entities/feedback_entity.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SupabseFeedbackDatasource implements FeedbackDatasource {
  SupabaseClient get client => Supabase.instance.client;

  String fileBucketName = 'feedback_attachment';

  String feedbackDatabaseTable = 'feedbacks';

  @override
  Future<void> uploadFeedback({required FeedbackEntity feedback}) async {
    await client.from(feedbackDatabaseTable).upsert(feedback.toJson());
  }

  @override
  Future<List<String>> uploadFiles({required List<File> files, required String userId, required String feedbackId}) async {
    List<String> paths = [];
    List<Future> futures = [];

    files.forEach((file) {
      futures.add(client.storage
          .from(fileBucketName)
          .upload(
            '/${userId}/${feedbackId}/${Uuid().v4()}${path.extension(file.path)}',
            file,
            fileOptions: const FileOptions(upsert: true),
          )
          .then((result) {
        paths.add(result);
      }));
    });

    await Future.wait(futures);

    List<String> urls = [];
    paths.forEach((path) {
      urls.add(client.storage.from(fileBucketName).getPublicUrl(path).replaceFirst('/$fileBucketName', ''));
    });
    return urls;
  }
}
