import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final Map<String, WebSocketChannel> activeConnections = {};

String generateConnectionKey(String userId, String workspaceId) => '$userId|$workspaceId';

Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);

  await for (HttpRequest req in server) {
    if (req.method == 'POST' && req.uri.path == '/connect') {
      final body = await utf8.decoder.bind(req).join();
      final data = jsonDecode(body);
      final userId = data['userId'];
      final workspaceId = data['workspaceId'];

      final Map<String, dynamic>? rawHeaders = (data['authorizationHeaders'] as Map?)?.cast<String, dynamic>();

      final Map<String, String>? authorizationHeaders = rawHeaders?.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );

      if (authorizationHeaders == null) {
        req.response
          ..statusCode = HttpStatus.badRequest
          ..write('Missing authorization headers')
          ..close();
        return;
      }

      await connectSlack(userId, workspaceId, authorizationHeaders);

      req.response
        ..statusCode = HttpStatus.ok
        ..write('Connecting to Slack for $userId@$workspaceId')
        ..close();
    } else {
      req.response
        ..statusCode = HttpStatus.notFound
        ..write('Not Found')
        ..close();
    }
  }
}

Future<void> connectSlack(String userId, String workspaceId, Map<String, String> authorizationHeaders) async {
  final connectionKey = generateConnectionKey(userId, workspaceId);

  if (activeConnections.containsKey(connectionKey)) {
    return;
  }

  final rtmResp = await http.post(
    Uri.parse('https://slack.com/api/rtm.connect'),
    headers: {
      ...authorizationHeaders,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
  );

  final rtmData = jsonDecode(rtmResp.body);
  if (rtmData['ok'] != true) {
    await updateFirestoreStatus(userId, workspaceId, 'error');
    return;
  }

  final wsUrl = rtmData['url'];
  // final channel = WebSocketChannel.connect(Uri.parse(wsUrl));

  final socket = await WebSocket.connect(
    wsUrl,
    headers: {
      ...authorizationHeaders,
      'Origin': 'https://api.slack.com',
    },
  );

  final channel = IOWebSocketChannel(socket);

  activeConnections[connectionKey] = channel;

  channel.stream.listen(
    (message) {
      publishToPubSub('slack-notification', {"event": message, "rtm": true});
    },
    onDone: () async {
      activeConnections.remove(connectionKey);
      await updateFirestoreStatus(userId, workspaceId, 'disconnected');
    },
    onError: (error) async {
      activeConnections.remove(connectionKey);
      await updateFirestoreStatus(userId, workspaceId, 'error');
    },
  );

  await updateFirestoreStatus(userId, workspaceId, 'connected');
}

Future<void> updateFirestoreStatus(String userId, String workspaceId, String status) async {
  final projectId = Platform.environment['PROJECT_ID'];
  final firestoreUrl = 'https://firestore.googleapis.com/v1/projects/$projectId/databases/taskeyfirestore/documents/slackconnection/${userId}_$workspaceId';

  final fields = {
    "status": {"stringValue": status},
    "updatedAt": {"timestampValue": DateTime.now().toUtc().toIso8601String()},
  };

  if (status == 'connected') {
    fields["connectedAt"] = {"timestampValue": DateTime.now().toUtc().toIso8601String()};
  }

  await http.patch(
    Uri.parse(firestoreUrl),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"fields": fields}),
  );
}

Future<void> publishToPubSub(String topicName, Map<String, dynamic> message) async {
  final projectId = Platform.environment['PROJECT_ID'];
  final url = 'https://pubsub.googleapis.com/v1/projects/$projectId/topics/$topicName:publish';

  // Metadata server를 통해 인증 토큰 가져오기
  final metadataResp = await http.get(
    Uri.parse('http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token'),
    headers: {'Metadata-Flavor': 'Google'},
  );

  if (metadataResp.statusCode != 200) {
    throw Exception('Failed to get access token from metadata server');
  }

  final accessToken = jsonDecode(metadataResp.body)['access_token'];

  // 메시지를 JSON → Base64 변환
  final jsonString = jsonEncode(message);
  final base64Data = base64Encode(utf8.encode(jsonString));

  // PubSub publish
  final resp = await http.post(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      "messages": [
        {
          "data": base64Data,
        }
      ]
    }),
  );

  if (resp.statusCode != 200) {
    throw Exception('Failed to publish to PubSub: ${resp.body}');
  }
}
