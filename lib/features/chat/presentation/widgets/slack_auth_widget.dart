import 'dart:async';
import 'dart:convert';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/master_detail_flow/master_detail_flow.dart';
import 'package:Visir/dependency/modal_bottom_sheet/src/utils/modal_scroll_controller.dart';
import 'package:Visir/features/chat/presentation/widgets/slack_url_viewer.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';

class SlackAuthWidget extends StatefulWidget {
  SlackAuthWidget({super.key});

  @override
  State<SlackAuthWidget> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<SlackAuthWidget> {
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scrollController ??= ModalScrollController.ofSyncGroup(context)?.addAndGet() ?? ScrollController();
    return LayoutBuilder(
      builder: (context, constraints) {
        return DetailsItem(
          appbarColor: Colors.white,
          bodyColor: Colors.white,
          scrollController: _scrollController,
          scrollPhysics: Utils.getScrollPhysicsForBottomSheet(context, _scrollController),
          children: [
            SlackUrlViewer(
              url: Constants.slackAuthUrl,
              isMobileView: PlatformX.isMobileView,
              initialWidth: constraints.maxWidth,
              initialHeight: constraints.maxHeight,
              isDarkTheme: false,
              close: false,
              userAgent: 'Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
              onReceivedData: (magicToken, teamId, userId, cookies) {
                Utils.mainContext.pop({'magicToken': magicToken, 'teamId': teamId, 'userId': userId, 'cookies': cookies});
              },
            ),
          ],
        );
      },
    );
  }
}

class SlackAuthBrowser extends InAppBrowser {
  SlackAuthBrowser({super.webViewEnvironment, required this.onReceivedData, required this.onClose, required this.onFailed});

  final void Function(String? magicToken, String teamId, String userId, List<Cookie> cookies, String? apiToken, SlackAuthBrowser browser) onReceivedData;
  final void Function() onClose;
  final void Function(SlackAuthBrowser browser) onFailed;

  CookieManager cookieManager = CookieManager.instance(webViewEnvironment: webViewEnvironment);

  String? magicToken;
  List<Cookie>? cookies;
  String? teamId;
  String? userId;
  String? apiToken;

  WebUri? url;
  bool isDone = false;

  void onDone() {
    if (isDone) return;
    if (teamId == null || userId == null || cookies == null || apiToken == null) return;
    isDone = true;
    onReceivedData(magicToken, teamId!, userId!, cookies!, apiToken, this);
  }

  @override
  Future onBrowserCreated() async {
    handle();
  }

  String checkerString = 'slack.com/ssb/redirect';

  @override
  FutureOr<NavigationActionPolicy?>? shouldOverrideUrlLoading(NavigationAction navigationAction) {
    final url = navigationAction.request.url;
    if (url?.scheme == 'slack') {
      return NavigationActionPolicy.CANCEL;
    }

    if (url.toString().contains(checkerString) == true) {
      this.url = url;
      onTimePassed();
    }
    return NavigationActionPolicy.ALLOW;
  }

  @override
  Future onLoadStart(url) async {
    if (url.toString().contains(checkerString) == true) {
      this.url = url;
      onTimePassed();
    }
    handle();
  }

  void onTimePassed() {
    Future.delayed(Duration(milliseconds: 5000)).then((value) {
      if (isDone) return;
      isDone = true;
      onFailed(this);
    });
  }

  void handle() {
    if (isDone) return;

    final controller = this.webViewController;
    if (controller != null) {
      controller.evaluateJavascript(source: 'JSON.stringify(boot_data)').then((bootDataString) {
        if (bootDataString != null) {
          final bootData = jsonDecode(bootDataString);
          if (bootData['team_id'] != null) {
            teamId = bootData['team_id'];
          }
          if (bootData['user_id'] != null) {
            userId = bootData['user_id'];
          }
          if (bootData['api_token'] != null) {
            apiToken = bootData['api_token'];
          }
        }

        onDone();
      });

      if (url != null) {
        cookieManager.getCookies(url: url!, webViewController: controller).then((_cookies) {
          final cookie = _cookies.where((d) => d.name == 'd').firstOrNull;
          if (cookie != null) this.cookies = _cookies;
          onDone();
        });
      }
    }

    Future.delayed(Duration(milliseconds: 100)).then((value) {
      handle();
    });
  }

  @override
  void onReceivedError(WebResourceRequest request, WebResourceError error) {
    if (request.url.toString().contains(checkerString) == true) {
      url = request.url;
      onTimePassed();
    }
    handle();
  }

  @override
  void onExit() {
    onClose();
  }
}
