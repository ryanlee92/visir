import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/common/domain/entities/connection_entity.dart';
import 'package:Visir/features/common/infrastructure/entities/environment.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/preference/application/connection_list_controller.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:app_links/app_links.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;
import 'package:microsoft_graph_api/microsoft_graph_api.dart';
import 'package:microsoft_graph_api/models/contact/contact_model.dart';
import 'package:microsoft_graph_api/models/user/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class MicrosoftApiHandler {
  static String redirectUrl(String type) => PlatformX.isWeb
      ? kDebugMode
            ? 'http://localhost:7357/redirect.html'
            : 'https://visir.pro/redirect.html'
      : PlatformX.isWindows
      ? type == 'mail'
            ? 'https://azukhxinzrivjforwnsc.supabase.co/functions/v1/redirect_microsoft_mail'
            : type == 'calendar'
            ? 'https://azukhxinzrivjforwnsc.supabase.co/functions/v1/redirect_microsoft_calendar'
            : 'https://azukhxinzrivjforwnsc.supabase.co/functions/v1/redirect_microsoft_calendar'
      : 'com.wavetogether.fillin://auth';

  static Future<ClientId> getClientId() async {
    final configFile = await rootBundle.loadString('assets/config/config.json');
    final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);
    final clientId = env.microsoftClientId;
    final clientSecret = microsoftClientSecret.isNotEmpty ? microsoftClientSecret : env.microsoftClientSecret;
    return ClientId(clientId, clientSecret);
  }

  static Future<List<dynamic>> batchRequest({required List<dynamic> requests, required AccessToken accessToken}) async {
    final List<dynamic> allResults = [];
    const chunkSize = 10;
    const maxAttempts = 4;

    for (var i = 0; i < requests.length; i += chunkSize) {
      final chunk = requests.sublist(i, min(i + chunkSize, requests.length)).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      var attempt = 0;
      var pending = List<Map<String, dynamic>>.from(chunk);
      final chunkResults = <dynamic>[];

      while (pending.isNotEmpty) {
        final batchRes = await http.post(
          Uri.parse('https://graph.microsoft.com/v1.0/\$batch'),
          body: jsonEncode({'requests': pending}),
          headers: {'Authorization': 'Bearer ${accessToken.data}', 'Content-Type': 'application/json'},
        );

        final batchResData = json.decode(batchRes.body) as Map<String, dynamic>;
        final responses = List<Map<String, dynamic>>.from(batchResData['responses'] ?? <dynamic>[]);

        final pendingById = {for (final req in pending) req['id'].toString(): req};
        final throttledResponses = <Map<String, dynamic>>[];

        for (final response in responses) {
          final responseId = response['id']?.toString();
          if (_isBatchThrottledResponse(response)) {
            if (responseId != null && pendingById.containsKey(responseId)) {
              throttledResponses.add(response);
            }
            continue;
          }

          chunkResults.add(response);
          pendingById.remove(responseId);
        }

        final retryRequests = <Map<String, dynamic>>[];
        for (final throttled in throttledResponses) {
          final responseId = throttled['id']?.toString();
          if (responseId != null && pendingById.containsKey(responseId)) {
            retryRequests.add(Map<String, dynamic>.from(pendingById[responseId]!));
            pendingById.remove(responseId);
          }
        }

        // Add any other non-throttled responses (e.g. hard errors) to results
        for (final remaining in pendingById.entries) {
          final originalResponse = responses.firstWhere(
            (element) => element['id']?.toString() == remaining.key,
            orElse: () => {
              'id': remaining.key,
              'status': 500,
              'body': {
                'error': {'message': 'Unknown batch response'},
              },
            },
          );
          chunkResults.add(originalResponse);
        }

        if (retryRequests.isEmpty) {
          pending = [];
        } else {
          attempt++;
          if (attempt >= maxAttempts) {
            // Give up and surface the throttled responses as errors
            for (final throttled in throttledResponses) {
              chunkResults.add(throttled);
            }
            pending = [];
          } else {
            final waitSeconds = _resolveBatchRetryAfterSeconds(batchRes.headers, throttledResponses, attempt);
            await Future.delayed(Duration(seconds: waitSeconds));
            pending = retryRequests;
          }
        }
      }

      allResults.addAll(chunkResults);
    }

    final successfulResults = allResults.where(_isBatchSuccessfulResponse).toList();
    return successfulResults;
  }

  static bool _isBatchThrottledResponse(Map<String, dynamic> response) {
    final status = response['status'];
    if (status == 429) return true;

    final body = response['body'];
    if (body is Map<String, dynamic>) {
      final error = body['error'];
      if (error is Map<String, dynamic>) {
        final code = error['code'];
        final message = error['message'];
        if (code is String && code.toLowerCase().contains('throttle')) return true;
        if (message is String && message.toLowerCase().contains('throttle')) return true;
      }
    }

    return false;
  }

  static bool _isBatchSuccessfulResponse(dynamic response) {
    if (response is Map<String, dynamic>) {
      final status = response['status'];
      if (status is int && status >= 200 && status < 300) return true;
    }
    return false;
  }

  static int _resolveBatchRetryAfterSeconds(Map<String, String> headers, List<Map<String, dynamic>> responses, int attempt) {
    final headerSeconds = int.tryParse(headers['retry-after'] ?? '');
    if (headerSeconds != null && headerSeconds > 0) return min(headerSeconds, 60);

    for (final response in responses) {
      final body = response['body'];
      if (body is Map<String, dynamic>) {
        final error = body['error'];
        if (error is Map<String, dynamic>) {
          final retryAfter = error['retryAfter'] ?? (error['innerError'] is Map<String, dynamic> ? (error['innerError'] as Map<String, dynamic>)['retryAfter'] : null);
          if (retryAfter is int && retryAfter > 0) return min(retryAfter, 60);
          if (retryAfter is String) {
            final parsed = int.tryParse(retryAfter);
            if (parsed != null && parsed > 0) return min(parsed, 60);
          }
        }
      }
    }

    return min(5 * pow(2, attempt - 1).toInt(), 60);
  }

  static StreamSubscription? onGetCodeStream;
  static Future<Map<String, String?>> getCode({
    required ClientId clientId,
    required Environment env,
    required List<String> scope,
    required String type,
    required String redirectUrl,
  }) async {
    Completer<Map<String, String?>> completer = Completer<Map<String, String?>>();

    if (PlatformX.isWindows) {
      final appLinks = AppLinks();
      onGetCodeStream?.cancel();
      onGetCodeStream = appLinks.uriLinkStream.listen((uri) {
        if (uri.toString().contains('com.wavetogether.fillin://outlook')) {
          String? code = uri.queryParameters['code'];
          try {
            if (code != null) {
              onGetCodeStream?.cancel();
              completer.complete({'code': code, 'redirect': redirectUrl});
            }
          } catch (e) {}
        }
      });
    }

    String _generateRandomString() {
      var r = Random.secure();
      var chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
      final codeVerifier = Iterable.generate(20, (_) => chars[r.nextInt(chars.length)]).join();
      return codeVerifier;
    }

    String createCodeChallenge(String codeVerifier) {
      final bytes = utf8.encode(codeVerifier);
      final digest = sha256.convert(bytes);
      return base64Url.encode(digest.bytes).replaceAll('=', '');
    }

    final state = _generateRandomString();
    final codeVerifier = _generateRandomString();
    final codeChallenge = createCodeChallenge(codeVerifier);

    final url = Uri.https('login.microsoftonline.com', '/common/oauth2/v2.0/authorize', {
      'client_id': clientId.identifier,
      'response_type': 'code',
      'redirect_uri': redirectUrl,
      'response_mode': 'query',
      'scope': scope.join(' '),
      if (PlatformX.isWeb) 'state': state,
      if (PlatformX.isWeb) 'code_challenge': codeChallenge,
      if (PlatformX.isWeb) 'code_challenge_method': 'S256',
    });

    FlutterWebAuth2.authenticate(
          url: url.toString(),
          callbackUrlScheme: 'com.wavetogether.fillin',
          options: FlutterWebAuth2Options(intentFlags: ephemeralIntentFlags, useWebview: false),
        )
        .catchError((error) {
          if (PlatformX.isWindows) return error.toString();
          completer.completeError(error);
          return error.toString();
        })
        .then((result) {
          if (PlatformX.isWindows) return;
          if (PlatformX.isWeb) result = result.replaceAll('redirect.html#', 'redirect.html?');
          final queryParams = Uri.parse(result).queryParameters;
          final code = queryParams['code'];

          try {
            if (code == null) {
              completer.completeError('Code is null');
              return;
            } else {
              completer.complete({
                'code': code,
                'redirect': PlatformX.isWeb ? redirectUrl : '${redirectUrl}:/',
                'state': state,
                'code_challenge': codeChallenge,
                'code_verifier': codeVerifier,
              });
            }
          } catch (e) {}
        });

    return completer.future;
  }

  static Future<OAuthEntity?> integrate(List<String> scope, String type) async {
    AccessToken? accessToken;
    String? refreshToken;
    String? serverCode;
    String? email;
    String? imageUrl;
    String? name;

    final clientId = await getClientId();

    final configFile = await rootBundle.loadString('assets/config/config.json');
    final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);

    final redirectUrl = MicrosoftApiHandler.redirectUrl(type);

    final result = await getCode(clientId: clientId, env: env, scope: scope, type: type, redirectUrl: redirectUrl);
    final code = result['code'];
    final codeVerifier = result['code_verifier'];

    final tokenUrl = Uri.https('login.microsoftonline.com', '/common/oauth2/v2.0/token');
    final callDatetime = DateTime.now();
    final response = await http.post(
      tokenUrl,
      body: {
        'client_id': clientId.identifier,
        'scope': scope.join(' '),
        'code': code,
        'redirect_uri': redirectUrl,
        'grant_type': 'authorization_code',
        if (PlatformX.isWeb) 'code_verifier': codeVerifier,
      },
    );

    accessToken = AccessToken(
      jsonDecode(response.body)['token_type'] as String,
      jsonDecode(response.body)['access_token'],
      callDatetime.add(Duration(seconds: jsonDecode(response.body)['expires_in'] as int)).toUtc(),
    );
    refreshToken = jsonDecode(response.body)['refresh_token'] as String;

    serverCode = jsonEncode({'accessToken': accessToken.toJson(), 'refreshToken': refreshToken});

    MSGraphAPI graphAPI = MSGraphAPI(accessToken.data);
    final user = await graphAPI.me.fetchUserInfo();

    email = user.mail;
    name = user.displayName;
    imageUrl = 'https://azukhxinzrivjforwnsc.supabase.co/storage/v1/object/public/logo/microsoft_default.png';

    final bytes = await graphAPI.me.fetchUserProfileImage('360x360');

    final notificationImage = await Utils.getNotificationImage(imageUrl: imageUrl, imageBytes: bytes, providerPath: "assets/logos/logo_outlook.png");

    String? notificationProfileUrl;
    if (notificationImage != null) {
      await Supabase.instance.client.storage
          .from('notification_profile')
          .uploadBinary('outlook/${email ?? 'unknown'}.png', notificationImage, fileOptions: const FileOptions(upsert: true));
      notificationProfileUrl = await Supabase.instance.client.storage.from('notification_profile').getPublicUrl('outlook/${email ?? 'unknown'}.png');
    }

    if (email != null) {
      final oauth = OAuthEntity(
        email: email,
        name: name,
        imageUrl: imageUrl,
        notificationUrl: notificationProfileUrl,
        accessToken: accessToken.toJson(),
        refreshToken: refreshToken,
        serverCode: serverCode,
        type: OAuthType.microsoft,
      );
      return oauth;
    }

    return null;
  }

  static Future<AccessToken> getToken({required OAuthEntity oauth, required List<String> scope, ClientId? clientId, bool? isMail, bool? isCalendar}) async {
    final accessToken = AccessToken.fromJson(oauth.accessToken);
    final refreshToken = oauth.refreshToken;

    AccessCredentials _newCredentials = AccessCredentials(accessToken, refreshToken, scope);

    final _clientId = clientId ?? await getClientId();

    try {
      if (accessToken.hasExpired) {
        final callDatetime = DateTime.now();
        final response = await http.post(
          Uri.parse('https://login.microsoftonline.com/common/oauth2/v2.0/token'),
          body: {
            'client_id': _clientId.identifier,
            'grant_type': 'refresh_token',
            'refresh_token': refreshToken,
            'scope': scope.join(' '),
            if (PlatformX.isWeb) 'client_secret': _clientId.secret,
          },
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final newAccessToken = AccessToken(data['token_type'] as String, data['access_token'], callDatetime.add(Duration(seconds: data['expires_in'] as int)).toUtc());
          final newRefreshToken = data['refresh_token'] as String;
          _newCredentials = AccessCredentials(newAccessToken, newRefreshToken, scope);
        } else {}
      }

      final pref = Utils.ref.read(localPrefControllerProvider).value!;
      final oauths = isMail == true
          ? pref.mailOAuths ?? List<OAuthEntity>.from([])
          : isCalendar == true
          ? pref.calendarOAuths ?? List<OAuthEntity>.from([])
          : List<OAuthEntity>.from([]);

      final newOAuths = oauths
          .map(
            (e) => e.email == oauth.email && e.type == oauth.type
                ? e.copyWith(accessToken: _newCredentials.accessToken.toJson(), refreshToken: _newCredentials.refreshToken ?? e.refreshToken, needReAuth: false)
                : e,
          )
          .toList();

      if (isMail == true) {
        Utils.ref.read(localPrefControllerProvider.notifier).set(mailOAuths: newOAuths);
      }

      if (isCalendar == true) {
        Utils.ref.read(localPrefControllerProvider.notifier).set(calendarOAuths: newOAuths);
      }

      return _newCredentials.accessToken;
    } catch (e) {
      checkAuthNotWork(oauth, e.toString(), isMail: isMail, isCalendar: isCalendar);
      throw e;
    }
  }

  static bool checkAuthNotWork(OAuthEntity oauth, String error, {bool? isMail, bool? isCalendar}) {
    if (error.toLowerCase().contains('token') || error.toLowerCase().contains('auth') || error.toLowerCase().contains('invalid_grant')) {
      final pref = Utils.ref.read(localPrefControllerProvider).value!;
      final oauths = isMail == true
          ? pref.mailOAuths ?? List<OAuthEntity>.from([])
          : isCalendar == true
          ? pref.calendarOAuths ?? List<OAuthEntity>.from([])
          : List<OAuthEntity>.from([]);
      final newOAuths = oauths.map((e) => e.email == oauth.email && e.type == oauth.type && e.teamId == oauth.teamId ? e.copyWith(needReAuth: true) : e).toList();

      if (isMail == true) {
        Utils.ref.read(localPrefControllerProvider.notifier).set(mailOAuths: newOAuths);
      }

      if (isCalendar == true) {
        Utils.ref.read(localPrefControllerProvider.notifier).set(calendarOAuths: newOAuths);
      }

      return true;
    }

    if (oauth.needReAuth == true) {
      final pref = Utils.ref.read(localPrefControllerProvider).value!;
      final oauths = isMail == true
          ? pref.mailOAuths ?? []
          : isCalendar == true
          ? pref.calendarOAuths ?? []
          : [] as List<OAuthEntity>;
      final newOAuths = oauths.map((e) => e.email == oauth.email && e.type == oauth.type && e.teamId == oauth.teamId ? e.copyWith(needReAuth: false) : e).toList();

      if (isMail == true) {
        Utils.ref.read(localPrefControllerProvider.notifier).set(mailOAuths: newOAuths);
      }

      if (isCalendar == true) {
        Utils.ref.read(localPrefControllerProvider.notifier).set(calendarOAuths: newOAuths);
      }
    }
    return false;
  }

  static Future<List<Contact>> _fetchContactsWithRetry({required MSGraphAPI graphAPI, required OAuthEntity oauth, bool? isMail, bool? isCalendar, int maxAttempts = 3}) async {
    var attempt = 0;

    while (true) {
      try {
        return await graphAPI.contacts.listContacts();
      } on DioException catch (error) {
        final statusCode = error.response?.statusCode;

        if (statusCode == 401 || statusCode == 403) {
          checkAuthNotWork(oauth, error.message ?? 'Microsoft Graph auth error', isMail: isMail, isCalendar: isCalendar);
        }

        if (statusCode == 429 && attempt < maxAttempts - 1) {
          final waitSeconds = _resolveRetryAfterSeconds(error, attempt);
          debugPrint('Microsoft contacts rate limited. Retrying in ${waitSeconds}s (attempt ${attempt + 1}/$maxAttempts)');
          await Future.delayed(Duration(seconds: waitSeconds));
          attempt++;
          continue;
        }

        rethrow;
      }
    }
  }

  static int _resolveRetryAfterSeconds(DioException error, int attempt) {
    final headerValue = error.response?.headers.value('Retry-After');
    final headerSeconds = int.tryParse(headerValue ?? '');
    if (headerSeconds != null && headerSeconds > 0) return headerSeconds;

    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final retryAfter =
          data['retryAfter'] ??
          (data['error'] is Map<String, dynamic>
              ? (data['error'] as Map<String, dynamic>)['retryAfter'] ??
                    ((data['error'] as Map<String, dynamic>)['innerError'] is Map<String, dynamic>
                        ? ((data['error'] as Map<String, dynamic>)['innerError'] as Map<String, dynamic>)['retryAfter']
                        : null)
              : null);
      if (retryAfter is int && retryAfter > 0) return retryAfter;
      if (retryAfter is String) {
        final parsed = int.tryParse(retryAfter);
        if (parsed != null && parsed > 0) return parsed;
      }
    }

    final fallback = pow(2, attempt + 1).toInt();
    return fallback.clamp(1, 60);
  }

  static Future<void> getConnections(WidgetRef ref) async {
    final mailOAuths = List<OAuthEntity>.from(
      Utils.ref.read(localPrefControllerProvider.select((v) => v.value?.mailOAuths ?? [])),
    ).where((e) => e.type == OAuthType.microsoft).toList();
    final calendarOAuths = List<OAuthEntity>.from(
      Utils.ref.read(localPrefControllerProvider.select((v) => v.value?.calendarOAuths ?? [])),
    ).where((e) => e.type == OAuthType.microsoft).toList();

    calendarOAuths.removeWhere((e) => mailOAuths.any((m) => m.email == e.email));

    for (final oauth in mailOAuths) {
      await getConnectionsForOAuth(ref: ref, oauth: oauth, isMail: true);
    }

    for (final oauth in calendarOAuths) {
      await getConnectionsForOAuth(ref: ref, oauth: oauth, isCalendar: true);
    }
  }

  static Future<List<ConnectionEntity>> getConnectionsForOAuth({required WidgetRef ref, required OAuthEntity oauth, String? nextPageToken, bool? isMail, bool? isCalendar}) async {
    final accessToken = await getToken(oauth: oauth, scope: [], isMail: isMail, isCalendar: isCalendar);
    MSGraphAPI graphAPI = MSGraphAPI(accessToken.data);
    try {
      final list = await _fetchContactsWithRetry(graphAPI: graphAPI, oauth: oauth, isMail: isMail, isCalendar: isCalendar);

      if (list.isNotEmpty) {
        final result = list.map((e) => ConnectionEntity(email: e.emailAddresses?.firstOrNull?.address, name: e.displayName)).where((e) => e.email != null).toList();
        Utils.ref.read(connectionListControllerProvider.notifier).set(provider: oauth.uniqueId, connectionList: result);
        return result;
      }
    } on DioException catch (error, stackTrace) {
      debugPrint('Failed to fetch Microsoft contacts: ${error.message}');
      debugPrintStack(stackTrace: stackTrace);
    } catch (error, stackTrace) {
      debugPrint('Failed to fetch Microsoft contacts: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    return [];
  }
}

extension UserX on User {
  Map<String, dynamic> toJson() => {
    'id': id,
    'mail': mail,
    'displayName': displayName,
    'givenName': givenName,
    'surname': surname,
    'jobTitle': jobTitle,
    'mobilePhone': mobilePhone,
    'officeLocation': officeLocation,
    'preferredLanguage': preferredLanguage,
  };
}

extension ContactX on Contact {
  Map<String, dynamic> toJson() => {
    'assistantName': assistantName,
    'birthday': birthday?.toIso8601String(),
    'businessAddress': businessAddress?.toJson(),
    'businessHomePage': businessHomePage,
    'businessPhones': businessPhones,
    'categories': categories,
    'changeKey': changeKey,
    'children': children,
    'companyName': companyName,
    'createdDateTime': createdDateTime?.toIso8601String(),
    'department': department,
    'displayName': displayName,
    'emailAddresses': emailAddresses == null ? null : (emailAddresses as List<dynamic>).map((e) => e.toJson()).toList(),
    'fileAs': fileAs,
    'generation': generation,
    'givenName': givenName,
    'homeAddress': homeAddress?.toJson(),
    'homePhones': homePhones,
    'id': id,
    'imAddresses': imAddresses,
    'initials': initials,
    'jobTitle': jobTitle,
    'lastModifiedDateTime': lastModifiedDateTime?.toIso8601String(),
    'manager': manager,
    'middleName': middleName,
    'mobilePhone': mobilePhone,
    'nickName': nickName,
    'officeLocation': officeLocation,
    'otherAddress': otherAddress?.toJson(),
    'parentFolderId': parentFolderId,
    'personalNotes': personalNotes,
    'profession': profession,
    'spouseName': spouseName,
    'surname': surname,
    'title': title,
    'yomiCompanyName': yomiCompanyName,
    'yomiGivenName': yomiGivenName,
    'yomiSurname': yomiSurname,
  };
}
