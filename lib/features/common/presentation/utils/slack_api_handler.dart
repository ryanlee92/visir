import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/toasty_box/model/toast_model.dart';
import 'package:Visir/features/chat/domain/entities/message_team_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_member_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_message_team_entity.dart';
import 'package:Visir/features/chat/presentation/widgets/slack_auth_widget.dart';
import 'package:Visir/features/common/infrastructure/entities/environment.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:Visir/flavors.dart';
import 'package:app_links/app_links.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:screen_retriever/screen_retriever.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SlackApiHandler {
  final lazyLoadingCount = 50;

  static String teamInfoUrl = "https://slack.com/api/team.info";
  static String userInfoUrl = "https://slack.com/api/users.info";
  static String usersListUrl = "https://slack.com/api/users.list";
  static String usersConversationsUrl = "https://slack.com/api/users.conversations";
  static String conversationsInfoUrl = "https://slack.com/api/conversations.info";
  static String emojiListUrl = "https://slack.com/api/emoji.list";
  static String usergroupsListUrl = "https://slack.com/api/usergroups.list";
  static String conversationHistoryUrl = "https://slack.com/api/conversations.history";
  static String chatPostMessageUrl = "https://slack.com/api/chat.postMessage";
  static String chatDeleteMessageUrl = "https://slack.com/api/chat.delete";
  static String conversationsRepliesUrl = "https://slack.com/api/conversations.replies";
  static String reactionsAddUrl = "https://slack.com/api/reactions.add";
  static String reactionsGetUrl = "https://slack.com/api/reactions.get";
  static String filesGetUploadUrlExternalUrl = "https://slack.com/api/files.getUploadURLExternal";
  static String reactionsRemoveUrl = "https://slack.com/api/reactions.remove";
  static String filesCompleteUploadExternalUrl = "https://slack.com/api/files.completeUploadExternal";
  static String conversationsMembersUrl = "https://slack.com/api/conversations.members";
  static String conversationsMarkUrl = "https://slack.com/api/conversations.mark";
  static String usersInfoUrl = "https://slack.com/api/users.info";
  static String botsInfoUrl = "https://slack.com/api/bots.info";
  static String searchMessagesUrl = "https://slack.com/api/search.messages";
  static String messagePermalinkUrl = "https://slack.com/api/chat.getPermalink";
  static String gatewayFunction = "slack_api_gateway";

  static List<String> scopes = [
    'channels:history',
    'channels:read',
    'chat:write',
    'emoji:read',
    'files:read',
    'files:write',
    'groups:history',
    'groups:read',
    'im:history',
    'im:read',
    'mpim:history',
    'mpim:read',
    'reactions:read',
    'reactions:write',
    'team:read',
    'usergroups:read',
    'users.profile:read',
    'users:read',
    'users:read.email',
    'channels:write',
    'groups:write',
    'im:write',
    'mpim:write',
    'search:read',
  ];

  static Map<String, String> urlEncodedHeader = {'Content-Type': 'application/x-www-form-urlencoded'};
  static Map<String, String> jsonHeader = {'Content-Type': 'application/json'};
  static Map<String, String> multipartFormDataHeader = {"Content-type": "multipart/form-data"};

  static String rateLimitErrorString = 'rateLimited';

  static Map<String, String> slackHeader = {
    'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
    'accept-language': 'en-US,en;q=0.9',
    'cache-control': 'max-age=0',
    'pragma': 'no-cache',
    'sec-ch-ua': '"Chromium";v="117", "Not;A=Brand";v="8"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"macOS"',
    'sec-fetch-dest': 'document',
    'sec-fetch-mode': 'navigate',
    'sec-fetch-site': 'none',
    'sec-fetch-user': '?1',
    'upgrade-insecure-requests': '1',
    'User-Agent': 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
  };

  static Future<String> fetchHTML(String url, String cookieHeader) async {
    final response = await http.get(Uri.parse(url), headers: {...slackHeader, 'cookie': 'd=${cookieHeader}'});
    return response.body;
  }

  static Future<String> getFirstTeamURLOld(String cookieHeader) async {
    // texts.Sentry.captureMessage('using getFirstTeamURLOld'); // Implement Sentry if needed
    final html = await fetchHTML('https://app.slack.com/', cookieHeader);
    final match = RegExp(r'TD\.boot_data\.team_url = (.+?);').firstMatch(html);
    final domain = match?.group(1);
    if (domain != null) return json.decode(domain); // 'https://texts-co.slack.com/'
    throw Exception('Could not find team URL');
  }

  static Future<String> getFirstTeamURL(String cookieHeader) async {
    Dio dio = Dio();
    final res = await dio.head('https://my.slack.com/', options: Options(headers: {...slackHeader, 'cookie': 'd=${cookieHeader}'}));
    final location = res.headers['location'];
    if (location != null && location != 'https://slack.com/') return location.first;
    return getFirstTeamURLOld(cookieHeader);
  }

  static Future<String> getClientTokenOld(String? teamUrl, String cookieHeader) async {
    final teamURL = teamUrl ?? await getFirstTeamURL(cookieHeader);
    for (final pathname in ['customize/emoji', 'home']) {
      final html = await fetchHTML('$teamURL$pathname', cookieHeader);
      final match = RegExp(r'"api_token":"(.+?)"').firstMatch(html);
      final token = match?.group(1);
      if (token != null) return token;
    }
    throw Exception('Unable to find API token');
  }

  static Future<Map<String, dynamic>> getConfig(String cookieHeader) async {
    final html = await fetchHTML('https://app.slack.com/auth?app=client', cookieHeader);
    final match = RegExp(r'JSON\.stringify\((\{.*?\})\)').firstMatch(html);
    final jsonStr = match?.group(1);
    final config = json.decode(jsonStr!);
    return config;
  }

  static Future<String> getClientToken(String? teamUrl, String cookieHeader) async {
    final teamURL = teamUrl ?? await getFirstTeamURL(cookieHeader);
    final config = await getConfig(cookieHeader);
    for (final team in config['teams'].values) {
      if (team['url'] == teamURL) return team['token'] ?? team['enterprise_api_token'];
    }
    return getClientTokenOld(teamUrl, cookieHeader);
  }

  static Future<void> unintegrate(OAuthEntity oauth) async {}

  static Future<OAuthEntity?> handleSlackTokenWithCookie({required String teamId, required String userId, required List<Cookie> cookies, String? apiToken, String? mToken}) async {
    final cookie = cookies.where((d) => d.name == 'd').firstOrNull;
    if (cookie == null) return null;

    String? token = apiToken;
    String cookieValue = cookie.value;
    if (apiToken == null) {
      final magicToken = 'z-app-${teamId}-${mToken}';
      final magicResult = await http.get(Uri.parse('https:/un/app.slack.com/api/auth.loginMagicBulk?magic_tokens=${magicToken}&ssb=1'), headers: {'cookie': 'd=${cookieValue}'});
      String teamUrl = jsonDecode(magicResult.body)['token_results']?[magicToken]?['team']?['url'] ?? jsonDecode(magicResult.body)['token_results']?[magicToken]?['auth_redir'];

      teamUrl = teamUrl.split('?').first;
      token = await getClientToken(teamUrl, cookieValue);
    }

    final responses = await Future.wait([
      proxyCall(
        method: 'GET',
        oauth: null,
        url: userInfoUrl,
        headers: {...urlEncodedHeader, 'Authorization': 'Bearer ${token}', 'cookie': 'd=${cookieValue}'},
        body: {'user': userId},
        files: null,
      ),
      proxyCall(method: 'POST', oauth: null, url: teamInfoUrl, headers: {...jsonHeader, 'Authorization': 'Bearer ${token}', 'cookie': 'd=${cookieValue}'}, body: null, files: null),
    ]);

    final userData = responses[0];
    final me = SlackMessageMemberEntity.fromJson(jsonDecode(userData)['user']);
    final teamData = responses[1];
    final team = MessageTeamEntity.fromSlack(team: SlackMessageTeamEntity.fromJson(jsonDecode(teamData)['team']));

    final notificationImage = await Utils.getNotificationImage(imageUrl: team.largeIconUrl ?? team.smallIconUrl, providerPath: "assets/logos/logo_slack.png");

    String? notificationProfileUrl;
    if (notificationImage != null) {
      await Supabase.instance.client.storage
          .from('notification_profile')
          .uploadBinary('slack/${team.id ?? 'unknown'}.png', notificationImage, fileOptions: const FileOptions(upsert: true));
      notificationProfileUrl = await Supabase.instance.client.storage.from('notification_profile').getPublicUrl('slack/${team.id ?? 'unknown'}.png');
    }

    return OAuthEntity(
      email: me.profile!.email!,
      accessToken: {'access_token': token, 'cookie': cookieValue},
      notificationUrl: notificationProfileUrl,
      refreshToken: '',
      type: OAuthType.slack,
      team: team,
    );
  }

  static StreamSubscription? onGetCodeStream;
  static Future<Map<String, String?>> getCode({required Environment env}) async {
    Completer<Map<String, String?>> completer = Completer<Map<String, String?>>();

    final callbackUrlScheme =
        'https://azukhxinzrivjforwnsc.supabase.co/functions/v1/${PlatformX.isWeb
            ? kDebugMode
                  ? 'slack_auth_web_debug'
                  : 'slack_auth_web'
            : PlatformX.isWindows
            ? 'redirect_slack'
            : 'slack_auth'}';

    if (PlatformX.isWindows) {
      final appLinks = AppLinks();
      onGetCodeStream?.cancel();
      onGetCodeStream = appLinks.uriLinkStream.listen((uri) {
        if (uri.toString().contains('com.wavetogether.fillin://slack')) {
          String? email = uri.queryParameters['email'];
          String? token = uri.queryParameters['token'];
          try {
            if (email != null && token != null) {
              onGetCodeStream?.cancel();
              completer.complete({'email': email, 'token': token});
            }
          } catch (e) {}
        }
      });
    }

    final url = Uri.https('slack.com', '/oauth/v2/authorize', {
      'response_type': 'code',
      'client_id': env.slackClientId,
      'user_scope': scopes.join(','),
      'redirect_uri': callbackUrlScheme,
    });

    FlutterWebAuth2.authenticate(
          url: url.toString(),
          callbackUrlScheme: PlatformX.isWindows ? 'com.wavetogether.fillin' : 'com.wavetogether.fillin.slack',
          options: FlutterWebAuth2Options(intentFlags: ephemeralIntentFlags, useWebview: false),
        )
        .catchError((e) {
          if (PlatformX.isWindows) return e.toString();
          onGetCodeStream?.cancel();
          completer.completeError(e);
          return e.toString();
        })
        .then((result) {
          if (PlatformX.isWindows) return;
          Uri uri = Uri.parse(result);
          String? email = uri.queryParameters['email'];
          String? token = uri.queryParameters['token'];
          try {
            if (email != null && token != null) {
              onGetCodeStream?.cancel();
              completer.complete({'email': email, 'token': token});
            }
          } catch (e) {}
        });

    return completer.future;
  }

  static Future<void> integrate({required void Function(OAuthEntity?) onResult, bool? forceAppAuth}) async {
    final useSlackAppToIntegrateData = await Supabase.instance.client.from('global_config').select().eq('id', 'use_slack_app_to_integrate').single();
    bool useSlackAppToIntegrate = useSlackAppToIntegrateData['bool_value'];
    // if (PlatformX.isWindows) {
    //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    //   final windowsInfo = await deviceInfo.windowsInfo;
    //   final winVersion = int.tryParse(windowsInfo.productName.replaceAll(new RegExp(r"\D"), "")) ?? 0;
    //   final forceAppAuth = winVersion < 11;
    //   if (forceAppAuth) {
    //     useSlackAppToIntegrate = true;
    //   }
    // }

    if (!useSlackAppToIntegrate && !PlatformX.isWeb && forceAppAuth != true) {
      // steal token from slack
      bool isClosed = false;
      Size? popupWindowSize;
      Size? _primaryDisplaySize;
      if (PlatformX.isDesktop) {
        if (PlatformX.isWindows) {
          _primaryDisplaySize = Utils.mainContext.size!;
        } else {
          final _primaryDisplay = await screenRetriever.getPrimaryDisplay();
          _primaryDisplaySize = _primaryDisplay.size;
        }

        popupWindowSize = Size(min(600, _primaryDisplaySize.width * 0.5), min(800, _primaryDisplaySize.height * 0.8));
      }
      final browser = SlackAuthBrowser(
        webViewEnvironment: webViewEnvironment,
        onReceivedData: (magicToken, teamId, userId, cookie, apiToken, browser) async {
          if (isClosed) return;
          isClosed = true;
          browser.close();
          final oauth = await handleSlackTokenWithCookie(mToken: magicToken, teamId: teamId, userId: userId, cookies: cookie, apiToken: apiToken);
          onResult(oauth);
        },
        onClose: () {
          if (isClosed) return;
          onResult(null);
        },
        onFailed: (browser) {
          if (isClosed) return;
          isClosed = true;
          browser.close();
          integrate(onResult: onResult, forceAppAuth: true);
        },
      );

      final settings = InAppBrowserClassSettings(
        browserSettings: InAppBrowserSettings(
          hideUrlBar: true,
          hideToolbarBottom: true,
          hideToolbarTop: true,
          hideDefaultMenuItems: true,
          toolbarTopBackgroundColor: Colors.white,
          presentationStyle: PlatformX.isDesktop ? ModalPresentationStyle.AUTOMATIC : ModalPresentationStyle.PAGE_SHEET,
          windowType: PlatformX.isDesktop ? WindowType.CHILD : null,
          windowFrame: PlatformX.isDesktop
              ? InAppWebViewRect(
                  x: max(0, _primaryDisplaySize!.width / 2 - popupWindowSize!.width / 2),
                  y: max(0, _primaryDisplaySize.height / 2 - popupWindowSize.height / 2),
                  width: popupWindowSize.width,
                  height: popupWindowSize.height,
                )
              : null,
        ),
        webViewSettings: InAppWebViewSettings(
          userAgent: 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
          isInspectable: kDebugMode,
          useShouldOverrideUrlLoading: true,
          // incognito: true,
        ),
      );
      browser.openUrlRequest(
        urlRequest: URLRequest(url: WebUri(Constants.slackAuthUrl)),
        settings: settings,
      );
      browser.show();
    } else {
      // get token from slack app
      final configFile = await rootBundle.loadString('assets/config/${F.envFileName}');
      final env = Environment.fromJson(json.decode(configFile) as Map<String, dynamic>);
      final result = await getCode(env: env);
      onGetCodeStream?.cancel();

      String? email = result['email'];
      String? token = result['token'];

      if (email == null || token == null) return;

      final teamData = await proxyCall(method: 'POST', oauth: null, url: teamInfoUrl, headers: {...jsonHeader, 'Authorization': 'Bearer ${token}'}, body: null, files: null);

      final team = MessageTeamEntity.fromSlack(team: SlackMessageTeamEntity.fromJson(jsonDecode(teamData)['team']));

      final notificationImage = await Utils.getNotificationImage(imageUrl: team.largeIconUrl ?? team.smallIconUrl, providerPath: "assets/logos/logo_slack.png");

      String? notificationProfileUrl;
      if (notificationImage != null) {
        await Supabase.instance.client.storage
            .from('notification_profile')
            .uploadBinary('slack/${team.id ?? 'unknown'}.png', notificationImage, fileOptions: const FileOptions(upsert: true));
        notificationProfileUrl = await Supabase.instance.client.storage.from('notification_profile').getPublicUrl('slack/${team.id ?? 'unknown'}.png');
      }

      onResult(OAuthEntity(email: email, accessToken: {'access_token': token}, notificationUrl: notificationProfileUrl, refreshToken: '', type: OAuthType.slack, team: team));
    }
  }

  static bool checkAuthNotWork(OAuthEntity oauth, bool ok, String? error) {
    if (!ok) {
      switch (error) {
        case 'invalid_auth':
        case 'not_allowed_token_type':
        case 'not_authed':
        case 'token_expired':
        case 'token_revoked':
          final pref = Utils.ref.read(localPrefControllerProvider).value!;
          final messengerOAuths = pref.messengerOAuths ?? [];
          final newMessengerOAuth = messengerOAuths
              .map((e) => e.email == oauth.email && e.type == oauth.type && e.teamId == oauth.teamId ? e.copyWith(needReAuth: true) : e)
              .toList();
          Utils.ref.read(localPrefControllerProvider.notifier).set(messengerOAuths: newMessengerOAuth);
          return true;
      }
    }

    if (oauth.needReAuth == true) {
      final pref = Utils.ref.read(localPrefControllerProvider).value!;
      final messengerOAuths = pref.messengerOAuths ?? [];
      final newMessengerOAuth = messengerOAuths.map((e) => e.email == oauth.email && e.type == oauth.type && e.teamId == oauth.teamId ? e.copyWith(needReAuth: false) : e).toList();
      Utils.ref.read(localPrefControllerProvider.notifier).set(messengerOAuths: newMessengerOAuth);
    }
    return false;
  }

  static void showErrorMessageToastIfNeeded(bool ok, String? error) {
    if (ok || error == null) return;

    String? message;

    switch (error) {
      case 'cant_delete_message':
      case 'cant_update_message':
        message = Utils.mainContext.tr.error_message_dont_have_permission;
        break;
    }

    if (message == null) return;

    Utils.showToast(
      ToastModel(
        message: TextSpan(text: message),
        buttons: [],
      ),
    );
  }
}
