import 'dart:async';
import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/features/common/domain/entities/connection_entity.dart';
import 'package:Visir/features/common/infrastructure/entities/environment.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/preference/application/connection_list_controller.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:googleapis/people/v1.dart' as GooglePeople;
import 'package:googleapis/people/v1.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class GoogleApiHandler {
  static String redirectUrl(String type) => PlatformX.isWeb
      ? kDebugMode
            ? 'http://localhost:7357/redirect.html'
            : 'https://visir.pro/redirect.html'
      : PlatformX.isWindows
      ? type == 'mail'
            ? 'https://azukhxinzrivjforwnsc.supabase.co/functions/v1/redirect_gmail'
            : type == 'calendar'
            ? 'https://azukhxinzrivjforwnsc.supabase.co/functions/v1/redirect_gcal'
            : 'https://azukhxinzrivjforwnsc.supabase.co/functions/v1/redirect_gcal'
      : 'com.wavetogether.fillin://auth';

  static Future<ClientId> getClientId() async {
    final configFile = await rootBundle.loadString('assets/config/config.json');
    final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);
    final clientId = PlatformX.isAppAuthSupported
        ? PlatformX.isAndroid
              ? env.googleClientIdAndroid
              : env.googleClientIdIOS
        : PlatformX.isWeb
        ? env.googleClientIdWeb
        : PlatformX.isWindows
        ? env.googleClientIdWeb // Windows는 Desktop Client ID 사용
        : env.googleClientIdWeb;

    final clientSecret = PlatformX.isAppAuthSupported
        ? PlatformX.isAndroid
              ? ''
              : ''
        : PlatformX.isWeb
        ? (googleCliendSecretWeb.isNotEmpty ? googleCliendSecretWeb : env.googleCliendSecretWeb)
        : PlatformX.isWindows
        ? (googleCliendSecretWeb.isNotEmpty ? googleCliendSecretWeb : env.googleCliendSecretDesktop) // Windows는 Desktop Secret 사용 (function에서 받아옴)
        : (googleCliendSecretWeb.isNotEmpty ? googleCliendSecretWeb : env.googleCliendSecretWeb);

    return ClientId(clientId, clientSecret);
  }

  static StreamSubscription? onGetCodeStream;
  static Future<Map<String, String?>> getCode({
    required ClientId clientId,
    required Environment env,
    required List<String> scope,
    required String callbackUrl,
    required String redirectUrl,
    required String type,
  }) async {
    debugPrint('[GoogleApiHandler.getCode] Starting - type: $type, redirectUrl: $redirectUrl, isWindows: ${PlatformX.isWindows}');
    Completer<Map<String, String?>> completer = Completer<Map<String, String?>>();

    if (PlatformX.isWindows) {
      debugPrint('[GoogleApiHandler.getCode] Windows platform - setting up AppLinks listener');
      final appLinks = AppLinks();
      onGetCodeStream?.cancel();
      onGetCodeStream = appLinks.uriLinkStream.listen((uri) {
        debugPrint('[GoogleApiHandler.getCode] Received URI: ${uri.toString()}');
        if (uri.toString().contains('com.wavetogether.fillin://google')) {
          String? code = uri.queryParameters['code'];
          debugPrint('[GoogleApiHandler.getCode] Code from URI: $code');
          try {
            if (code != null) {
              debugPrint('[GoogleApiHandler.getCode] Completing with code and redirect: $redirectUrl');
              onGetCodeStream?.cancel();
              completer.complete({'code': code, 'redirect': redirectUrl});
            } else {
              debugPrint('[GoogleApiHandler.getCode] ERROR: Code is null in URI');
            }
          } catch (e) {
            debugPrint('[GoogleApiHandler.getCode] ERROR in Windows listener: $e');
          }
        }
      });
    } else {}

    final oauthParams = <String, String>{
      'response_type': 'code',
      'client_id': clientId.identifier,
      'access_type': 'offline',
      'prompt': 'consent',
      'scope': scope.join(' '),
      'redirect_uri': PlatformX.isWindows || PlatformX.isWeb ? redirectUrl : '${callbackUrl}:/',
    };
    
    // audience 파라미터는 Windows/Web에서만 사용 (일부 경우에만 필요)
    if (PlatformX.isWindows || PlatformX.isWeb) {
      oauthParams['audience'] = PlatformX.isWindows ? env.googleClientIdDesktop : env.googleClientIdWeb;
    }
    
    final url = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', oauthParams);

    debugPrint('[GoogleApiHandler.getCode] OAuth URL: ${url.toString()}');
    debugPrint('[GoogleApiHandler.getCode] OAuth params: ${oauthParams.map((k, v) => MapEntry(k, k == 'client_id' ? v : (k == 'redirect_uri' ? v : '***')))}');
    debugPrint('[GoogleApiHandler.getCode] callbackUrlScheme: ${PlatformX.isWindows || PlatformX.isWeb ? redirectUrl : callbackUrl}');

    FlutterWebAuth2.authenticate(
          url: url.toString(),
          callbackUrlScheme: PlatformX.isWindows || PlatformX.isWeb ? redirectUrl : callbackUrl,
          options: FlutterWebAuth2Options(intentFlags: ephemeralIntentFlags, useWebview: false),
        )
        .catchError((error) {
          debugPrint('[GoogleApiHandler.getCode] FlutterWebAuth2 error: $error');
          if (PlatformX.isWindows) {
            debugPrint('[GoogleApiHandler.getCode] Windows platform - returning error string');
            return error.toString();
          }
          completer.completeError(error);
          return error.toString();
        })
        .then((result) {
          debugPrint('[GoogleApiHandler.getCode] FlutterWebAuth2 result: $result');
          if (PlatformX.isWindows) {
            debugPrint('[GoogleApiHandler.getCode] Windows platform - skipping result processing');
            return;
          }
          final code = Uri.parse(result).queryParameters['code'];
          debugPrint('[GoogleApiHandler.getCode] Extracted code: $code');
          try {
            if (code == null) {
              debugPrint('[GoogleApiHandler.getCode] ERROR: Code is null in result');
              completer.completeError('Code is null');
              return;
            } else {
              final redirect = PlatformX.isWeb ? redirectUrl : '${callbackUrl}:/';
              debugPrint('[GoogleApiHandler.getCode] Completing with code and redirect: $redirect');
              completer.complete({'code': code, 'redirect': redirect});
            }
          } catch (e) {
            debugPrint('[GoogleApiHandler.getCode] ERROR processing result: $e');
          }
        });

    return completer.future;
  }

  static Future<OAuthEntity?> integrate(List<String> scope, String type) async {
    debugPrint('[GoogleApiHandler.integrate] Starting integration - type: $type, scope: $scope');
    AccessToken? accessToken;
    String? refreshToken;
    String? serverCode;
    String? email;
    String? imageUrl;
    String? name;

    final clientId = await getClientId();
    debugPrint('[GoogleApiHandler.integrate] ClientId: ${clientId.identifier}');
    final secret = clientId.secret;
    debugPrint('[GoogleApiHandler.integrate] ClientSecret: ${secret != null && secret.isNotEmpty ? 'present (${secret.length} chars)' : 'EMPTY or NULL'}');
    debugPrint('[GoogleApiHandler.integrate] Platform: Windows=${PlatformX.isWindows}, Web=${PlatformX.isWeb}');
    debugPrint('[GoogleApiHandler.integrate] Using Desktop Client ID: ${PlatformX.isWindows}');
    debugPrint('[GoogleApiHandler.integrate] Desktop Secret from function: ${googleCliendSecretDesktop.isNotEmpty ? 'present (${googleCliendSecretDesktop.length} chars)' : 'EMPTY'}');

    final configFile = await rootBundle.loadString('assets/config/config.json');
    final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);
    final callbackUrl = clientId.identifier.split('.').reversed.join('.');
    final callDatetime = DateTime.now();

    final redirectUrl = GoogleApiHandler.redirectUrl(type);
    debugPrint('[GoogleApiHandler.integrate] RedirectUrl: $redirectUrl, callbackUrl: $callbackUrl');

    final result = await getCode(clientId: clientId, env: env, scope: scope, callbackUrl: callbackUrl, type: type, redirectUrl: redirectUrl);
    debugPrint('[GoogleApiHandler.integrate] getCode result: $result');

    final code = result['code'];
    final redirect = result['redirect'];
    debugPrint('[GoogleApiHandler.integrate] Code: $code, Redirect: $redirect');
    
    if (code == null) {
      debugPrint('[GoogleApiHandler.integrate] ERROR: Code is null!');
      return null;
    }
    if (redirect == null) {
      debugPrint('[GoogleApiHandler.integrate] ERROR: Redirect is null!');
      return null;
    }

    final tokenUrl = Uri.https('oauth2.googleapis.com', 'token');
    debugPrint('[GoogleApiHandler.integrate] Requesting token with code: $code, redirect_uri: $redirect');
    debugPrint('[GoogleApiHandler.integrate] Token request details:');
    debugPrint('  - client_id: ${clientId.identifier}');
    debugPrint('  - client_secret: ${clientId.secret != null && clientId.secret!.isNotEmpty ? 'present (${clientId.secret!.length} chars)' : 'NULL or EMPTY'}');
    debugPrint('  - redirect_uri: $redirect');
    debugPrint('  - grant_type: authorization_code');
    debugPrint('  - code length: ${code.length}');
    
    final tokenRequestBody = {
      'client_id': clientId.identifier,
      'client_secret': clientId.secret ?? '',
      'redirect_uri': redirect,
      'grant_type': 'authorization_code',
      'code': code,
    };
    debugPrint('[GoogleApiHandler.integrate] Token request body: ${tokenRequestBody.map((k, v) => MapEntry(k, k == 'client_secret' ? (v.isNotEmpty ? '***' : 'EMPTY') : v))}');
    
    final response = await http.post(
      tokenUrl,
      body: tokenRequestBody,
    );

    debugPrint('[GoogleApiHandler.integrate] Token response status: ${response.statusCode}');
    debugPrint('[GoogleApiHandler.integrate] Token response body: ${response.body}');
    
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    debugPrint('[GoogleApiHandler.integrate] Parsed response body: $responseBody');
    
    final tokenType = responseBody['token_type'] as String?;
    final accessTokenStr = responseBody['access_token'] as String?;
    final expiresIn = responseBody['expires_in'] as int?;
    final refreshTokenStr = responseBody['refresh_token'] as String?;
    
    debugPrint('[GoogleApiHandler.integrate] token_type: $tokenType, access_token: ${accessTokenStr != null ? 'present' : 'null'}, expires_in: $expiresIn, refresh_token: ${refreshTokenStr != null ? 'present' : 'null'}');
    
    if (tokenType == null || accessTokenStr == null || expiresIn == null) {
      debugPrint('[GoogleApiHandler.integrate] ERROR: Missing required token fields');
      return null;
    }
    
    accessToken = AccessToken(
      tokenType,
      accessTokenStr,
      callDatetime.add(Duration(seconds: expiresIn)).toUtc(),
    );
    refreshToken = refreshTokenStr;
    
    if (refreshToken == null) {
      debugPrint('[GoogleApiHandler.integrate] WARNING: refresh_token is null');
    }
    final rawServerCode = responseBody['server_code'] as String?;
    debugPrint('[GoogleApiHandler.integrate] server_code: ${rawServerCode != null ? 'present' : 'null'}');

    if (rawServerCode != null) {
      try {
        debugPrint('[GoogleApiHandler.integrate] Requesting server tokens with server_code');
        final tokenRes = await Supabase.instance.client.functions.invoke('get_google_server_tokens', body: {'server_code': rawServerCode});
        serverCode = jsonEncode(tokenRes.data);
        debugPrint('[GoogleApiHandler.integrate] Server tokens received');
      } catch (e) {
        debugPrint('[GoogleApiHandler.integrate] ERROR getting server tokens: $e');
      }
    }

    AccessCredentials _newCredentials = AccessCredentials(accessToken, refreshToken ?? '', scope);
    final baseClient = http.Client();

    final client = authenticatedClient(baseClient, _newCredentials);
    debugPrint('[GoogleApiHandler.integrate] Fetching user info from People API');

    final value = await PeopleServiceApi(client).people.get('people/me', personFields: 'emailAddresses,names,photos');
    email = value.emailAddresses?.first.value;
    imageUrl = value.photos?.first.url;
    name = value.names?.first.displayName;
    debugPrint('[GoogleApiHandler.integrate] User info - email: $email, name: $name, imageUrl: ${imageUrl != null ? 'present' : 'null'}');

    final notificationImage = await Utils.getNotificationImage(imageUrl: imageUrl, providerPath: type == 'mail' ? "assets/logos/logo_gmail.png" : "assets/logos/logo_gcal.png");

    String? notificationProfileUrl;
    if (notificationImage != null) {
      await Supabase.instance.client.storage
          .from('notification_profile')
          .uploadBinary('${type == 'mail' ? 'gmail' : 'gcal'}/${email ?? 'unknown'}.png', notificationImage, fileOptions: const FileOptions(upsert: true));
      notificationProfileUrl = await Supabase.instance.client.storage.from('notification_profile').getPublicUrl('${type == 'mail' ? 'gmail' : 'gcal'}/${email ?? 'unknown'}.png');
    }

    if (email != null) {
      debugPrint('[GoogleApiHandler.integrate] Creating OAuthEntity with email: $email');
      final oauth = OAuthEntity(
        email: email,
        name: name,
        imageUrl: imageUrl,
        notificationUrl: notificationProfileUrl,
        accessToken: accessToken.toJson(),
        refreshToken: refreshToken ?? '',
        serverCode: serverCode,
        type: OAuthType.google,
      );
      debugPrint('[GoogleApiHandler.integrate] Integration successful!');
      return oauth;
    }

    debugPrint('[GoogleApiHandler.integrate] ERROR: Email is null, returning null');
    return null;
  }

  static Map<String, http.Client> clients = {};

  static Future<http.Client> getClient({required OAuthEntity oauth, required List<String> scope, ClientId? clientId, bool? isMail, bool? isCalendar}) async {
    final accessToken = AccessToken.fromJson(oauth.accessToken);
    final refreshToken = oauth.refreshToken;

    AccessCredentials _newCredentials = AccessCredentials(accessToken, refreshToken, scope);
    final baseClient = http.Client();

    final _clientId = clientId ?? await getClientId();
    final clientKey =
        '${isMail == true
            ? 'mail'
            : isCalendar == true
            ? 'calendar'
            : ''}_${oauth.email}_${oauth.type}';

    try {
      if (accessToken.hasExpired) {
        _newCredentials = await refreshCredentials(_clientId, _newCredentials, baseClient);

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
      } else {
        final prevClient = clients[clientKey];
        if (prevClient != null) return prevClient;
      }

      clients[clientKey]?.close();
      final client = authenticatedClient(baseClient, _newCredentials);
      clients[clientKey] = client;
      return client;
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

  static Future<void> getConnections(WidgetRef ref) async {
    final mailOAuths = List<OAuthEntity>.from(ref.read(localPrefControllerProvider.select((v) => v.value?.mailOAuths ?? []))).where((e) => e.type == OAuthType.google).toList();

    final calendarOAuths = List<OAuthEntity>.from(
      ref.read(localPrefControllerProvider.select((v) => v.value?.calendarOAuths ?? [])),
    ).where((e) => e.type == OAuthType.google).toList();

    final googleConnectionSyncToken = ref.read(localPrefControllerProvider.select((v) => v.value?.googleConnectionSyncToken)) ?? {};

    calendarOAuths.removeWhere((e) => mailOAuths.any((m) => m.email == e.email));

    for (final oauth in mailOAuths) {
      await getConnectionsForOAuth(ref: ref, oauth: oauth, syncToken: googleConnectionSyncToken[oauth.email], isMail: true);
    }

    for (final oauth in calendarOAuths) {
      await getConnectionsForOAuth(ref: ref, oauth: oauth, syncToken: googleConnectionSyncToken[oauth.email], isCalendar: true);
    }
  }

  static Future<List<ConnectionEntity>> getConnectionsForOAuth({
    required WidgetRef ref,
    required OAuthEntity oauth,
    String? syncToken,
    String? nextPageToken,
    bool? isMail,
    bool? isCalendar,
  }) async {
    final googleConnectionSyncToken = {...(Utils.ref.read(localPrefControllerProvider.select((v) => v.value?.googleConnectionSyncToken)) ?? {})};

    List<ConnectionEntity> list = [];
    final client = await GoogleApiHandler.getClient(oauth: oauth, scope: [GooglePeople.PeopleServiceApi.contactsReadonlyScope], isMail: isMail, isCalendar: isCalendar);

    final result = await PeopleServiceApi(client).otherContacts.list(readMask: 'emailAddresses,names', pageToken: nextPageToken, syncToken: syncToken, pageSize: 1000);

    list.addAll(
      result.otherContacts
              ?.map((e) => ConnectionEntity(email: e.emailAddresses?.firstOrNull?.value, name: e.emailAddresses?.firstOrNull?.displayName ?? e.names?.firstOrNull?.displayName))
              .where((e) => e.email != null)
              .toList() ??
          [],
    );

    if (result.nextPageToken != null) {
      final addResult = await getConnectionsForOAuth(ref: ref, oauth: oauth, syncToken: syncToken, nextPageToken: result.nextPageToken, isMail: isMail, isCalendar: isCalendar);
      list.addAll(addResult);
    }

    if (list.isNotEmpty) {
      googleConnectionSyncToken[oauth.email] = result.nextSyncToken;
      Utils.ref.read(localPrefControllerProvider.notifier).set(googleConnectionSyncToken: googleConnectionSyncToken);
      Utils.ref.read(connectionListControllerProvider.notifier).set(provider: oauth.uniqueId, connectionList: list);
      return list;
    }

    return [];
  }

  static String repairBrokenUtf8(String input) {
    final bytes = input.runes.map((r) => r & 0xFF).toList(); // 잘못 디코딩된 UTF-8을 원복
    return utf8.decode(bytes, allowMalformed: true);
  }

  static List<Map<String, dynamic>> extractJsonObjectsWithContentId(String input) {
    input = repairBrokenUtf8(input);
    final results = <Map<String, dynamic>>[];

    // 각 MIME part로 분리
    final parts = input.split(RegExp(r'--batch_[^\r\n]+')).where((p) => p.trim().isNotEmpty).toList();

    for (final part in parts) {
      try {
        final lines = part.split(RegExp(r'\r?\n'));

        // Content-ID 추출
        final contentIdLine = lines.firstWhere((line) => line.toLowerCase().startsWith('content-id:'), orElse: () => '');

        final contentIdMatch = RegExp(r'<([^>]+)>').firstMatch(contentIdLine);
        final contentId = contentIdMatch?.group(1) ?? 'unknown';

        final responseHeader = part.split('{')[0];
        final body = json.decode(part.substring(responseHeader.length));
        results.add({...body, 'contentId': contentId});
      } catch (e) {}
    }

    return results;
  }

  static Future<List<Map<String, dynamic>>> batchRequest(String endpoint, List<BatchRequest> requests, http.Client client) async {
    final results = <Map<String, dynamic>>[];
    final chunkSize = 100;

    for (int i = 0; i < requests.length; i += chunkSize) {
      final end = (i + chunkSize < requests.length) ? i + chunkSize : requests.length;
      final chunk = requests.sublist(i, end);

      try {
        final chunkResult = await _batchRequest(endpoint, chunk, client);
        results.addAll(chunkResult);
      } catch (e) {}

      // (선택적) 지연을 추가하여 rate limit 우회
      await Future.delayed(Duration(milliseconds: 100));
    }

    return results;
  }

  static Future<List<Map<String, dynamic>>> _batchRequest(String endpoint, List<BatchRequest> requests, http.Client client) async {
    final boundary = 'batch_boundary';

    final batchBodyRawList =
        requests
            .map(
              (e) => [
                '--$boundary',
                'Content-Type: ${e.contentType}',
                'Content-ID: <request-${e.contentId}>',
                if (e.contentTransferEncoding != null) 'Content-Transfer-Encoding: ${e.contentTransferEncoding}',
                '',
                '${e.method} ${e.path}',
                if (e.body != null) '',
                if (e.body != null) '${json.encode(e.body)}',
                '',
              ],
            )
            .expand((e) => e)
            .toList()
          ..add('--$boundary--');

    final batchBody = batchBodyRawList.join('\r\n');
    final totalContentLength = utf8.encode(batchBody).length;

    final response = await http.post(
      Uri.parse('https://gmail.googleapis.com/batch/${endpoint}'),
      headers: {
        'Authorization': 'Bearer ${(client as AuthClient).credentials.accessToken.data}',
        'Host': 'www.googleapis.com',
        'Content-Type': 'multipart/mixed; boundary=$boundary',
        'Content-Length': totalContentLength.toString(),
      },
      body: batchBody,
    );

    final batchResult = extractJsonObjectsWithContentId(response.body);
    return batchResult;
  }
}

extension PersonX on Person {
  Map<String, dynamic> toJsonX() => {
    if (emailAddresses != null) 'emailAddresses': emailAddresses!.map((e) => e.toJson()..remove('metadata')).toList(),
    if (names != null) 'names': names!.map((e) => e.toJson()..remove('metadata')).toList(),
  };
}

class BatchRequest {
  final String method;
  final String path;
  final Map<String, dynamic>? body;
  final String contentType;
  final String contentId;
  final String? contentTransferEncoding;

  BatchRequest({required this.method, required this.path, this.body, required this.contentType, required this.contentId, this.contentTransferEncoding});
}
