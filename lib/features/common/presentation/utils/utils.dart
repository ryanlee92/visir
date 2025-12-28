import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:Visir/dependency/toasty_box/model/toast_model.dart';
import 'package:Visir/dependency/toasty_box/toast_enums.dart';
import 'package:Visir/dependency/toasty_box/toast_item.dart';
import 'package:Visir/dependency/toasty_box/toast_service.dart';
import 'package:Visir/dependency/xen_popup_card/xen_popup_card.dart';
import 'package:Visir/features/calendar/domain/entities/event_entity.dart';
import 'package:Visir/features/chat/domain/entities/emoji_category_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_emoji_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_group_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_member_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_tag_entity.dart';
import 'package:Visir/features/common/domain/failures/failure.dart';
import 'package:Visir/features/common/presentation/utils/constants.dart';
import 'package:Visir/features/common/presentation/utils/extensions/color_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/log_event.dart';
import 'package:Visir/features/common/presentation/widgets/bottom_dialog_option.dart';
import 'package:Visir/features/common/presentation/widgets/bottom_sheet_scroll_physics.dart';
import 'package:Visir/features/common/presentation/widgets/mobile_confirm_popup.dart';
import 'package:Visir/features/common/presentation/widgets/mobile_scaffold.dart';
import 'package:Visir/features/common/presentation/widgets/recurrence_edit_confirm_popup.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/feedback/application/feedback_controller.dart';
import 'package:Visir/features/inbox/domain/entities/inbox_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_file_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_user_entity.dart';
import 'package:Visir/features/mail/presentation/screens/mail_edit_screen.dart';
import 'package:Visir/features/mail/presentation/screens/mail_input_screen.dart';
import 'package:Visir/features/preference/presentation/screens/preference_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:crypto/crypto.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:emoji_extension/emoji_extension.dart' hide Color;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart' hide Group;
import 'package:go_router/go_router.dart';
import 'package:home_widget/home_widget.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as image;
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_compress/video_compress.dart';

class Utils {
  static FocusNode mainFocus = FocusNode();

  static GlobalKey<PreferenceScreenState> preferenceScreenKey = GlobalKey();

  static Size windowSize = Size.zero;

  static late BuildContext mainContext;
  static bool _mainContextInitialized = false;
  static Map<TabType, BuildContext?> mobileTabContexts = {};
  static late WidgetRef _ref;
  static bool initialized = false;

  static void setMainContext(BuildContext context, {bool force = false, WidgetRef? ref}) {
    if (!_mainContextInitialized || force) {
      mainContext = context;
      _mainContextInitialized = true;
    }
    if (ref != null) {
      _ref = ref;
      initialized = true;
    }
  }

  static ThemeMode themeMode = ThemeMode.system;
  static late ThemeData lightTheme;
  static late ThemeData darkTheme;
  static late AudioPlayer player;

  static WidgetRef get ref => _ref;
  static set ref(WidgetRef value) {
    _ref = value;
    initialized = true;
  }

  static Size get linkedPopupSize => Size(480, MediaQuery.of(mainContext).size.height - Constants.desktopTitleBarHeight - 24);

  static void initiateAudioplayer() {
    if (PlatformX.isAndroid) return;
    if (PlatformX.isWindows) return;
    if (PlatformX.isLinux) return;
    if (PlatformX.isWeb) return;

    player = AudioPlayer();

    AudioPlayer.global.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          audioFocus: AndroidAudioFocus.none,
          audioMode: AndroidAudioMode.normal, // 다른 소리를 방해하지 않음
          usageType: AndroidUsageType.notification, // 알림 사운드 용도
          contentType: AndroidContentType.sonification,
        ),
        iOS: AudioContextIOS(category: AVAudioSessionCategory.playback, options: {AVAudioSessionOptions.interruptSpokenAudioAndMixWithOthers}),
      ),
    );
  }

  static void playTaskDoneSound() async {
    if (PlatformX.isAndroid) return;

    await player.play(AssetSource('sounds/task_complete.mp3'), mode: PlayerMode.lowLatency);
    await Future.delayed(Duration(milliseconds: 340));
    await player.stop();
    await player.release();
  }

  static Future<T?> showPopupDialog<T>({
    BuildContext? context,
    required Widget child,
    final Size? size,
    final double? padding,
    final bool? isMedia,
    final bool? forcePopup,
    final bool? isFlexibleHeightPopup,
    final bool? disableEscapeClose,
    final bool? barrierDismissible,
    final Color? backgroundColor,
    final Color? barrierColor,
  }) async {
    bool _isMedia = isMedia ?? false;
    bool _forcePopup = forcePopup ?? false;
    bool _isFlexibleHeightPopup = isFlexibleHeightPopup ?? false;
    if (PlatformX.isDesktopView || _forcePopup) {
      return showDialog<T>(
        context: context ?? mainContext,
        barrierDismissible: barrierDismissible ?? true,
        barrierColor: barrierColor,
        builder: (ctx) => XenPopupCard(
          borderRadius: 0,
          maxSize: size,
          disableEscapeClose: disableEscapeClose,
          cardBgColor: Colors.transparent,
          padding: padding,
          isMedia: _isMedia,
          isFlexibleHeightPopup: _isFlexibleHeightPopup,
          body: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: (MediaQueryData.fromView(View.of(mainContext)).size.height <= (size?.height ?? 560)) ? 16 : 0,
                horizontal: (MediaQueryData.fromView(View.of(mainContext)).size.width <= (size?.width ?? 640)) ? 16 : 0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_isMedia ? 0 : 12),
                child: Navigator(
                  onGenerateRoute: (_) => CupertinoPageRoute(
                    fullscreenDialog: true,
                    builder: (ctx) => Container(color: backgroundColor ?? (_isMedia ? Colors.transparent : ctx.background), child: child),
                    settings: RouteSettings(name: child.toString()),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      print('######## mainContext: $mainContext');
      return CupertinoScaffold.showCupertinoModalBottomSheet<T>(
        context: mainContext,
        duration: kThemeAnimationDuration,
        builder: (context) => CupertinoScaffold(
          topRadius: Radius.circular(20),
          overlayStyle: context.brightness == Brightness.dark
              ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
              : SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
          body: Stack(
            children: [
              Positioned.fill(
                child: Builder(
                  builder: (context) {
                    modalScrollController = ModalScrollController.of(context);
                    return SingleChildScrollView(controller: modalScrollController, child: Container(height: 100000));
                  },
                ),
              ),
              Positioned.fill(
                child: Navigator(
                  onDidRemovePage: (_) {},
                  observers: [ModalPopupNavigatorObserver()],
                  onGenerateRoute: (page) => CupertinoPageRoute(
                    builder: (ctx) {
                      return Material(color: ctx.background, child: child);
                    },
                    settings: RouteSettings(name: child.toString()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ).then((v) {
        modalScrollController?.dispose();
        modalScrollController = null;
        return null;
      });
    }
  }

  static RenderBox? findRenderBoxByValueKey(ValueKey key) {
    RenderBox? target;

    void visitor(Element element) {
      if (element.widget.key == key) {
        final box = element.renderObject;
        if (box is RenderBox) target = box;
      }
      element.visitChildElements(visitor);
    }

    mainContext.visitChildElements(visitor);
    return target;
  }

  static void closeCommandBar() {
    if (PlatformX.isDesktopView) {
      Navigator.maybePop(mainContext);
      // closeCommandBarOnNavigator();
    } else {
      // Navigator.maybePop(mainContext);
    }
  }

  static void showMailEditScreen({
    String? viewTitle,
    MailUserEntity? from,
    List<MailUserEntity>? to,
    List<MailUserEntity>? cc,
    List<MailUserEntity>? bcc,
    String? subject,
    String? bodyHtml,
    List<MailFileEntity>? attachments,
    List<MailFileEntity>? inlineImage,
    String? prevMessageId,
    String? threadId,
    String? draftId,
    bool? fromDraftBanner,
  }) {
    mailEditScreenVisibleNotifier.value = true;

    final mailEditScreen = () => MailEditScreen(
      key: mailEditScreenKey,
      viewTitle: viewTitle,
      from: from,
      to: to,
      cc: cc,
      bcc: bcc,
      subject: subject,
      bodyHtml: bodyHtml,
      attachments: attachments,
      inlineImage: inlineImage,
      prevMessageId: prevMessageId,
      threadId: threadId,
      draftId: draftId,
      fromDraftBanner: fromDraftBanner,
    );

    if (PlatformX.isDesktopView) {
      mailInputDraftEditListener.value = mailEditScreen();
      showMailEditScreenOnNavigator();
    } else {
      Utils.showPopupDialog(
        disableEscapeClose: true,
        child: ValueListenableBuilder(
          valueListenable: mailEditScreenVisibleNotifier,
          builder: (context, value, child) {
            if (!value) return SizedBox.shrink();
            return mailEditScreen();
          },
        ),
        size: Size(640, 1080),
        padding: 24,
      ).then((value) {
        mailEditScreenVisibleNotifier.value = false;
      });
    }
  }

  static void closeMailEditScreen() {
    if (PlatformX.isDesktopView) {
      closeMailEditScreenOnNavigator();
      mailInputDraftEditListener.value = null;
      mailEditScreenVisibleNotifier.value = false;
    } else {
      Navigator.maybePop(mainContext).then((value) {
        mailEditScreenVisibleNotifier.value = false;
      });
    }
  }

  static void replyMail({required MailEntity mail, required MailUserEntity me}) {
    final fromMe = mail.from?.email == mail.hostEmail;
    Utils.showMailEditScreen(
      viewTitle: Utils.mainContext.tr.mail_reply_to(mail.from?.name ?? ''),
      from: me,
      to: fromMe
          ? mail.to
          : mail.from == null
          ? []
          : [mail.from!],
      cc: fromMe ? mail.cc : [],
      bcc: fromMe ? mail.bcc : [],
      subject: 'Re: ${mail.subject}',
      bodyHtml:
          '''
        <br><br>
      <div class="gmail_quote">
      <div dir="ltr" class="gmail_attr">On ${DateFormat.yMMMEd().add_Hm().format(mail.date!)}, ${mail.from?.name} ${'&lt;' + (mail.from?.email ?? '') + '&gt;'} wrote:<br></div>
      <blockquote class="gmail_quote" style="margin: 0px 0px 0px 0.8ex; border-left: 1px solid rgb(204, 204, 204); padding-left: 1ex;">
      <div style="margin: 0px; padding: 0px;">
      ${mail.html}
      </div>
      </blockquote>
      </div>
      ''',
      attachments: mail.getAttachments().where((a) {
        return (mail.html ?? '').contains('cid:${a.cid}');
      }).toList(),
      prevMessageId: mail.id,
      threadId: mail.threadId,
      draftId: mail.draftId,
    );
  }

  static void replyAllMail({required MailEntity mail, required MailUserEntity me}) {
    final toWithoutMe = mail.to.where((u) => u.email != mail.hostEmail).toList();
    final ccWithoutMe = mail.cc.where((u) => u.email != mail.hostEmail).toList();
    final fromMe = mail.from?.email == mail.hostEmail;

    Utils.showMailEditScreen(
      viewTitle: Utils.mainContext.tr.mail_reply_to(mail.from?.name ?? ''),
      from: me,
      to: [
        if (!fromMe) ...(mail.from == null ? [] : [mail.from!]),
        ...toWithoutMe,
      ],
      cc: ccWithoutMe,
      bcc: [],
      subject: 'Re: ${mail.subject}',
      bodyHtml:
          '''
        <br><br>
      <div class="gmail_quote">
      <div dir="ltr" class="gmail_attr">On ${DateFormat.yMMMEd().add_Hm().format(mail.date!)}, ${mail.from?.name} ${'&lt;' + (mail.from?.email ?? '') + '&gt;'} wrote:<br></div>
      <blockquote class="gmail_quote" style="margin: 0px 0px 0px 0.8ex; border-left: 1px solid rgb(204, 204, 204); padding-left: 1ex;">
      <div style="margin: 0px; padding: 0px;">
      ${mail.html}
      </div>
      </blockquote>
      </div>
      ''',
      attachments: mail.getAttachments().where((a) {
        return (mail.html ?? '').contains('cid:${a.cid}');
      }).toList(),
      prevMessageId: mail.id,
      threadId: mail.threadId,
      draftId: mail.draftId,
    );
  }

  static void forwardMail({required MailEntity mail, required MailUserEntity me}) {
    Utils.showMailEditScreen(
      viewTitle: Utils.mainContext.tr.mail_forward,
      from: me,
      to: [],
      cc: [],
      bcc: [],
      subject: 'Fwd: ${mail.subject}',
      bodyHtml:
          '''
            <br><br>
          <div class="gmail_quote">
              <div>---------- Forwarded message ---------</div>
              <div>From: ${mail.from?.name} ${'&lt;' + (mail.from?.email ?? '') + '&gt;'}</div>
              <div>Date: ${DateFormat.yMMMEd().add_Hm().format(mail.date!)}</div>
              <div>Subject: ${mail.subject}</div>
              <div>To: ${mail.to.map((e) => '${e.name} ${'&lt;' + e.email + '&gt;'}').join(', ')}</div>
              <br><br>
              ${mail.html}
          </div>
      ''',
      attachments: mail.getAttachments(),
      prevMessageId: mail.id,
      threadId: mail.threadId,
      draftId: mail.draftId,
    );
  }

  static Future<T?> showMobileConfirmPopup<T>({
    required String title,
    required String description,
    required Future<void> Function() onPressConfirm,
    String? cancelString,
    String? confirmString,
    bool? isWarning,
    Future<void> Function()? onPressCancel,
    bool? hideCancelButton,
    VoidCallback? afterPressConfirm,
  }) async {
    return showPopupDialog(
      forcePopup: true,
      isFlexibleHeightPopup: true,
      size: Size(320, 0),
      child: MobileConfirmPopup(
        title: title,
        description: description,
        cancelString: cancelString ?? mainContext.tr.cancel,
        confirmString: confirmString ?? mainContext.tr.ok,
        isWarning: isWarning ?? false,
        onPressConfirm: onPressConfirm,
        onPressCancel: onPressCancel,
        hideCancelButton: hideCancelButton ?? false,
        afterPressConfirm: afterPressConfirm,
      ),
    );
  }

  static String fromGoogleRRule(String rrule, DateTime startDate) {
    final list = rrule.split(';');

    // if (recurrence?.contains('RRULE:FREQ=MONTHLY') == true) {
    //   if (!recurrence!.contains('BYDAY') && !recurrence.contains('BYMONTHDAY')) {
    //     recurrence = '${recurrence};BYMONTHDAY=${(e.start?.date?.day ?? e.start?.dateTime?.day ?? 1)}';
    //   }
    // }
    //
    // if (recurrence?.contains('RRULE:FREQ=YEARLY') == true) {
    //   if (!recurrence!.contains('BYDAY') && !recurrence.contains('BYMONTHDAY')) {
    //     recurrence =
    //     '${recurrence};BYMONTH=${(e.start?.date?.month ?? e.start?.dateTime?.month ?? 1)};BYMONTHDAY=${(e.start?.date?.day ?? e.start?.dateTime?.day ?? 1)}';
    //   }
    // }

    if (rrule.contains('FREQ=MONTHLY')) {
      final resultList = [];
      String? weekDay;
      String? number;

      if (!rrule.contains('BYDAY') && !rrule.contains('BYMONTHDAY')) {
        return '${rrule};BYMONTHDAY=${startDate.day}';
      }

      list.forEach((element) {
        final key = element.split('=')[0];
        final value = element.split('=')[1];
        if (key == 'BYDAY') {
          // number가 음수도 포함할 수 있도록 정규식 수정
          final match = RegExp(r'^(-?\d+)?([A-Z]+)$').firstMatch(value);
          number = match?.group(1) ?? '';
          weekDay = match?.group(2) ?? '';
        } else {
          resultList.add(element);
        }

        if (weekDay != null && number != null) {
          if (number!.isEmpty) {
            resultList.add('BYDAY=$weekDay');
          } else {
            resultList.add('BYDAY=$weekDay;BYSETPOS=$number');
          }

          weekDay = null;
          number = null;
        }
      });

      return resultList.join(';');
    } else if (rrule.contains('FREQ=YEARLY')) {
      if (!rrule.contains('BYDAY') && !rrule.contains('BYMONTHDAY')) {
        final reuslt = '${rrule};BYMONTH=${startDate.month};BYMONTHDAY=${startDate.day}';
        return reuslt;
      }
    }
    return rrule;
  }

  static String toGoogleRRule(String rrule) {
    final list = rrule.split(';');
    if (rrule.contains('FREQ=MONTHLY')) {
      final resultList = [];
      String? weekDay;
      String? number;

      list.forEach((element) {
        final key = element.split('=')[0];
        final value = element.split('=')[1];
        if (key == 'BYDAY') {
          weekDay = value;
        } else if (key == 'BYSETPOS') {
          number = value;
        } else {
          resultList.add(element);
        }

        if (weekDay != null && number != null) {
          resultList.add('BYDAY=$number$weekDay');
          weekDay = null;
          number = null;
        }
      });

      return resultList.join(';');
    } else if (rrule.contains('FREQ=YEARLY')) {}

    return rrule;
  }

  static String generateBase32HexStringFromTimestamp() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNumber = Random().nextInt(99999);
    return '$timestamp$randomNumber';
  }

  static String encryptAESCryptoJS(String plainText, String passphrase) {
    try {
      final salt = genRandomWithNonZero(8);
      var keyndIV = deriveKeyAndIV(passphrase, salt);
      final key = encrypt.Key(keyndIV.item1);
      final iv = encrypt.IV(keyndIV.item2);

      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: "PKCS7"));
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      Uint8List encryptedBytesWithSalt = Uint8List.fromList(createUint8ListFromString("Salted__") + salt + encrypted.bytes);
      return base64.encode(encryptedBytesWithSalt);
    } catch (error) {
      throw error;
    }
  }

  static String decryptAESCryptoJS(String encrypted, String passphrase) {
    try {
      Uint8List encryptedBytesWithSalt = base64.decode(encrypted);

      Uint8List encryptedBytes = encryptedBytesWithSalt.sublist(16, encryptedBytesWithSalt.length);
      final salt = encryptedBytesWithSalt.sublist(8, 16);
      var keyndIV = deriveKeyAndIV(passphrase, salt);
      final key = encrypt.Key(keyndIV.item1);
      final iv = encrypt.IV(keyndIV.item2);

      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: "PKCS7"));
      final decrypted = encrypter.decrypt64(base64.encode(encryptedBytes), iv: iv);
      return decrypted;
    } catch (error) {
      throw error;
    }
  }

  static Tuple2<Uint8List, Uint8List> deriveKeyAndIV(String passphrase, Uint8List salt) {
    var password = createUint8ListFromString(passphrase);
    Uint8List concatenatedHashes = Uint8List(0);
    Uint8List currentHash = Uint8List(0);
    bool enoughBytesForKey = false;
    Uint8List preHash = Uint8List(0);

    while (!enoughBytesForKey) {
      if (currentHash.length > 0)
        preHash = Uint8List.fromList(currentHash + password + salt);
      else
        preHash = Uint8List.fromList(password + salt);

      currentHash = Uint8List.fromList(md5.convert(preHash).bytes);
      concatenatedHashes = Uint8List.fromList(concatenatedHashes + currentHash);
      if (concatenatedHashes.length >= 48) enoughBytesForKey = true;
    }

    var keyBtyes = concatenatedHashes.sublist(0, 32);
    var ivBtyes = concatenatedHashes.sublist(32, 48);
    return new Tuple2(keyBtyes, ivBtyes);
  }

  static Uint8List createUint8ListFromString(String s) {
    var ret = new Uint8List(s.length);
    for (var i = 0; i < s.length; i++) {
      ret[i] = s.codeUnitAt(i);
    }
    return ret;
  }

  static Uint8List genRandomWithNonZero(int seedLength) {
    final random = Random.secure();
    const int randomMax = 245;
    final Uint8List uint8list = Uint8List(seedLength);
    for (int i = 0; i < seedLength; i++) {
      uint8list[i] = random.nextInt(randomMax) + 1;
    }
    return uint8list;
  }

  static String durtaionFormatter(Duration d) {
    var seconds = d.inSeconds;
    final days = seconds ~/ Duration.secondsPerDay;
    seconds -= days * Duration.secondsPerDay;
    final hours = seconds ~/ Duration.secondsPerHour;
    seconds -= hours * Duration.secondsPerHour;
    final minutes = seconds ~/ Duration.secondsPerMinute;
    seconds -= minutes * Duration.secondsPerMinute;

    final List<String> tokens = [];

    if (tokens.isNotEmpty || hours != 0) {
      tokens.add('${hours}');
    }
    tokens.add('${minutes > 9 ? minutes.toString().padLeft(2, '0') : minutes}');
    tokens.add('${seconds.toString().padLeft(2, '0')}');

    return tokens.join(':');
  }

  static String numberFormatter(double number, {int fractionDigits = 1}) {
    try {
      if (number >= 1000000) {
        return '${(number / 1000000).toStringAsFixed(fractionDigits)}M';
      } else if (number >= 1000) {
        return '${(number / 1000).toStringAsFixed(fractionDigits)}K';
      } else {
        return number == number.toInt() ? number.toInt().toString() : number.toStringAsFixed(fractionDigits);
      }
    } catch (e) {
      return '0';
    }
  }

  static showBottomDialog({required TextSpan title, required Widget body}) {
    return showModalBottomSheet(
      context: mainContext,
      backgroundColor: Colors.transparent,
      barrierLabel: MaterialLocalizations.of(mainContext).modalBarrierDismissLabel,
      isScrollControlled: true,
      builder: (context) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.pop(),
          child: Container(
            width: double.maxFinite,
            height: double.maxFinite,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(color: context.surface, borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text.rich(title, style: context.titleLarge?.textColor(context.outlineVariant).appFont(context).textBold),
                            ),
                            Container(
                              constraints: BoxConstraints(maxHeight: min(context.height * 0.5, 360)),
                              child: SingleChildScrollView(child: body, padding: EdgeInsets.only(bottom: 16)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static showToast(ToastModel toast) {
    ToastService.showWidgetToast(
      mainContext,
      isClosable: true,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      length: ToastLength.medium,
      expandedHeight: 74,
      width: 280,
      slideCurve: Curves.easeInOut,
      positionCurve: Curves.easeInOut,
      dismissDirection: DismissDirection.up,
      builder: (index) {
        return ToastItem(item: toast, onTapClose: () => ToastService.hideToast(index));
      },
    );
  }

  static showRateLimitedToast({required RateLimitType type}) {
    showToast(
      ToastModel(
        message: TextSpan(text: type.getTitle(mainContext)),
        buttons: [],
      ),
    );
  }

  static Future<bool> launchUrlExternal({required String? url}) async {
    if (url == null) return false;
    bool canLaunch = await canLaunchUrl(Uri.parse(url));

    if (canLaunch) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> launchMailto({required String to, required String subject, required String body}) async {
    final Uri emailLaunchUri = Uri(scheme: 'mailto', path: to, query: encodeQueryParameters(<String, String>{'subject': subject, 'body': body}));

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
      return true;
    } else {
      return false;
    }
  }

  static String? encodeQueryParameters(Map<String, String> params) {
    return params.entries.map((MapEntry<String, String> e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
  }

  static String getRootDomainFromUrl({required String url}) {
    return url.replaceAll('https://', '').replaceAll('http://', '').replaceAll('www.', '');
  }

  static Future<void> launchSlackCommunity() async {
    launchUrlExternal(url: 'https://taskeycommunity.slack.com/join/shared_invite/zt-2z7hrn4k1-RHpVGZb1JZm_HwD2hZyjqw#/shared-invite/email');
    logAnalyticsEvent(eventName: 'join_community');
  }

  static List<TextSpan> highlightSearchQuery({required TextStyle? defaultStyle, required String text, required String searchQuery}) {
    Color highlightColor = Color(0xffffeb3b);

    if (searchQuery.isEmpty) {
      return [TextSpan(text: text, style: defaultStyle)];
    }

    final searchRegex = RegExp(RegExp.escape(searchQuery), caseSensitive: false);
    final matches = searchRegex.allMatches(text);

    List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start), style: defaultStyle));
      }

      spans.add(TextSpan(text: match.group(0), style: defaultStyle?.textColor(highlightColor)));

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: defaultStyle));
    }

    return spans;
  }

  static String getOrdinalSuffix(int day) {
    if (!(day >= 1 && day <= 31)) {
      throw ArgumentError('Invalid day of the month');
    }
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  // 링크와 코드 블럭을 처리하기 위한 정규표현식
  static RegExp combinedRegex = RegExp(
    r'\*<((?:https?:\/\/[^\s|>]+))(?:\|([^>]*))?>\*' + // 링크 굵게
        r'|((?:https?:\/\/[^\s|>]+))\s*(?:\|([^>]*)\s*)?>' + // 링크
        r'|`<([^|>]+)\|([^>]+)>`' + // 코드 블럭
        r'|:([^:\s]+):\s*' + // 이모지
        r'|~(.*?)~' + // 취소선
        r'|_(.*?)_' + // 이탤릭
        r'|\*(.*?)\*' + // 굵게
        r'|<@([^>]+)>' + // 멘션
        r'|<!date\^(\d+)\^{([^>]+)}\|([^>]+)>' + // 날짜
        r'|`([^`]+)`' + // 마크 다운
        r'|<#([^>]+)\|>', //채널 멘션
    dotAll: true,
  );

  static Future<Uint8List?> getNotificationImage({required String? imageUrl, Uint8List? imageBytes, required String providerPath}) async {
    final providerLogo = await assetImageToFilePath(providerPath);
    if (imageUrl == null && imageBytes == null) {
      return providerLogo;
    }
    try {
      final profileImage = imageBytes ?? await networkImageToFilePath(imageUrl!);
      if (profileImage == null) {
        return providerLogo;
      } else {
        image.Image profileIcon = image.decodeImage(profileImage)!;
        image.Image profile = image.Image(width: profileIcon.width, height: profileIcon.height, numChannels: 4, backgroundColor: image.ColorUint8.rgba(0, 0, 0, 0));
        image.compositeImage(profile, profileIcon);
        profile = image.copyResizeCropSquare(profile, size: 1024, radius: 340, antialias: true, interpolation: image.Interpolation.linear);

        image.Image whiteImage = image.fill(
          image.Image(width: 420, height: 420, numChannels: 4, backgroundColor: image.ColorUint8.rgba(0, 0, 0, 0)),
          color: image.ColorUint8.rgba(255, 255, 255, 255),
        );
        image.Image providerIcon = image.decodeImage(providerLogo)!;

        whiteImage = image.copyResizeCropSquare(whiteImage, size: 420, radius: 210, antialias: true, interpolation: image.Interpolation.linear);

        providerIcon = image.copyResizeCropSquare(providerIcon, size: 260, radius: 0, antialias: true, interpolation: image.Interpolation.linear);

        final providerWithBackgroundImage = image.Image(width: whiteImage.width, height: whiteImage.height, numChannels: 4, backgroundColor: image.ColorUint8.rgba(0, 0, 0, 0));
        image.compositeImage(providerWithBackgroundImage, whiteImage);
        image.compositeImage(providerWithBackgroundImage, providerIcon, center: true);

        final mergedImage = image.Image(width: 1024, height: 1024, numChannels: 4, backgroundColor: image.ColorUint8.rgba(0, 0, 0, 0));

        image.compositeImage(mergedImage, profile, dstX: 0, dstY: 0, dstW: (profile.width * 0.9).floor(), dstH: (profile.height * 0.9).floor());

        image.compositeImage(
          mergedImage,
          providerWithBackgroundImage,
          dstX: (profile.width * 4 / 7).floor(),
          dstY: (profile.height * 5 / 9).floor(),
          dstW: (profile.width * 3 / 7).floor(),
          dstH: (profile.height * 3 / 7).floor(),
        );

        return image.encodePng(mergedImage);
      }
    } catch (e) {
      return providerLogo;
    }
  }

  static Future<Uint8List> assetImageToFilePath(String asset) async {
    final ByteData byteData = await rootBundle.load(asset);
    return byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);
  }

  static Future<Uint8List?> networkImageToFilePath(String imageUrl) async {
    try {
      final http.Response response = await http.get(Uri.parse(imageUrl));
      return response.bodyBytes;
    } catch (e) {
      return null;
    }
  }

  static void focusApp({FocusNode? focusNode, bool? doNotFocus, bool? forceReset}) {
    if (forceReset != true) {
      if (((HardwareKeyboard.instance.logicalKeysPressed.length == 1 || HardwareKeyboard.instance.logicalKeysPressed.length == 2) &&
          (HardwareKeyboard.instance.isAltPressed ||
              HardwareKeyboard.instance.isControlPressed ||
              HardwareKeyboard.instance.isMetaPressed ||
              HardwareKeyboard.instance.isShiftPressed)))
        return;

      if (FocusManager.instance.primaryFocus != mainFocus && !PlatformX.isWindows) {
        if ((FocusManager.instance.primaryFocus?.hasFocus == true && FocusManager.instance.primaryFocus?.children.isNotEmpty != true)) {
          return;
        }
      }
    }

    VoidCallback resetData = () {
      // ignore: invalid_use_of_visible_for_testing_member, deprecated_member_use
      ServicesBinding.instance.keyEventManager.clearState();
      // ignore: invalid_use_of_visible_for_testing_member
      ServicesBinding.instance.keyboard.clearState();
      // HardwareKeyboard.instance.syncKeyboardState();
      keyboardResetNotifier.value = Random().nextInt(100000);

      if (doNotFocus == true) return;

      (focusNode ?? FocusManager.instance.primaryFocus ?? mainFocus).requestFocus();
    };

    if (forceReset == true) {
      EasyThrottle.cancel('keyboard_reattach');
      resetData();
    }

    EasyThrottle.throttle('keyboard_reattach', Duration(milliseconds: 250), () {
      resetData();
    });
  }

  static Future<void> reportAutoFeedback({required String errorMessage}) async {
    if (!initialized) return;
    if (Utils.ref.context.mounted != true) return;
    await Utils.ref.read(feedbackControllerProvider.notifier).upsertAutoFeedback(errorMessage: errorMessage);
  }

  static Future<bool> isAppleSilicon() async {
    if (!PlatformX.isMacOS) return false;

    final result = await Process.run('sysctl', ['-n', 'machdep.cpu.brand_string']);
    final output = result.stdout.toString().toLowerCase();

    if (output.contains('intel')) {
      return false;
    } else {
      return true;
    }
  }

  static Future<PlatformFile> compressOnlyVideoFileInMobile({required PlatformFile originalFile}) async {
    List<String> videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'flv', 'wmv'];
    String? inputPath = originalFile.path; // 동영상 경로 가져오기
    String? fileExtension = inputPath?.split('.').last.toLowerCase();
    bool isVideo = videoExtensions.contains(fileExtension);

    if (!PlatformX.isMobile || !isVideo) {
      final bytes = originalFile.bytes ?? (await File(originalFile.path!).readAsBytes());
      return PlatformFile(
        name: originalFile.name,
        path: originalFile.path,
        size: originalFile.size,
        bytes: bytes,
        identifier: originalFile.identifier ?? originalFile.path ?? originalFile.name,
      );
    }

    if (inputPath != null) {
      final MediaInfo? compressedVideo = await VideoCompress.compressVideo(
        inputPath,
        quality: VideoQuality.Res1280x720Quality, // 화질 선택
        deleteOrigin: false, // 원본 유지
        includeAudio: true,
      );

      if (compressedVideo != null && compressedVideo.path != null) {
        File compressedFile = File(compressedVideo.path!);
        int fileSize = await compressedFile.length();
        Uint8List bytes = await compressedFile.readAsBytes();

        PlatformFile platformFile = PlatformFile(
          name: inputPath.split('/').last, // 원본 파일 이름 유지
          path: compressedVideo.path,
          size: fileSize,
          bytes: bytes,
          identifier: originalFile.identifier ?? originalFile.path ?? originalFile.name,
        );

        return platformFile;
      }
    }

    final bytes = originalFile.bytes ?? (await File(originalFile.path!).readAsBytes());
    return PlatformFile(
      name: originalFile.name,
      path: originalFile.path,
      size: originalFile.size,
      bytes: bytes,
      identifier: originalFile.identifier ?? originalFile.path ?? originalFile.name,
    );
  }

  static showFileDownloadBottomDialogInAndroid({
    required BuildContext context,
    required List<Uint8List> bytes,
    required List<String> names,
    required List<String?>? extensions,
  }) async {
    Utils.showBottomDialog(
      title: TextSpan(text: context.tr.file_options),
      body: Column(
        children: [
          BottomDialogOption(
            icon: VisirIconType.download,
            title: context.tr.file_options_download,
            onTap: () async {
              if (bytes.length == 1) {
                final byte = bytes.first;
                final name = names.first;
                final extension = extensions?.first;
                String? outputFile = await FilePicker.platform.saveFile(fileName: name, bytes: byte);

                if (outputFile == null) return;
                File file = File(outputFile.contains('.') || extension == null ? outputFile : '${outputFile}.${extension}');
                await file.create(recursive: true);
                await file.writeAsBytes(byte);
              } else {
                final directoryPath = await FilePicker.platform.getDirectoryPath();
                if (directoryPath == null) return;
                await Future.wait(
                  bytes.map((byte) async {
                    final name = names[bytes.indexOf(byte)];
                    final extension = extensions?[bytes.indexOf(byte)];
                    String? outputFile = '${directoryPath}/${name.contains('.') || extension == null ? name : '${name}.${extension}'}';

                    File file = File(outputFile.contains('.') || extension == null ? outputFile : '${outputFile}.${extension}');
                    await file.create(recursive: true);
                    await file.writeAsBytes(byte);
                    return true;
                  }),
                );
              }
            },
          ),
          BottomDialogOption(
            icon: VisirIconType.share,
            title: context.tr.file_options_share,
            onTap: () async {
              final files = bytes
                  .map(
                    (e) => XFile.fromData(
                      e,
                      mimeType: lookupMimeType('', headerBytes: e),
                      name: names[bytes.indexOf(e)],
                    ),
                  )
                  .toList();
              await Share.shareXFiles(files, fileNameOverrides: names);
            },
          ),
        ],
      ),
    );
  }

  static List<EmojiCategoryEntity> getEmojiCategories(List<MessageEmojiEntity> emojis) {
    final context = mainContext;
    return [
      EmojiCategoryEntity(name: context.tr.chat_emoji_category_frequently_used, icon: Icons.watch_later, emojis: []),
      EmojiCategoryEntity(name: context.tr.chat_emoji_category_custom, icon: Icons.edit, customEmojis: emojis),
      EmojiCategoryEntity(
        name: context.tr.chat_emoji_category_smiley_and_people,
        icon: Icons.emoji_emotions,
        emojis: [
          ...Emojis.byGroup(Group.smileysAndEmotion).where((e) => e.slackShortcode != null && e.status == Status.fullyQualified).toList(),
          ...Emojis.byGroup(Group.peopleAndBody).where((e) => e.slackShortcode != null && !e.hasSkinTone && e.status == Status.fullyQualified).toList(),
        ],
      ),
      EmojiCategoryEntity(
        name: context.tr.chat_emoji_category_animals_and_nature,
        icon: Icons.pets,
        emojis: Emojis.byGroup(Group.animalsAndNature).where((e) => e.slackShortcode != null).toList(),
      ),
      EmojiCategoryEntity(
        name: context.tr.chat_emoji_category_food_and_drink,
        icon: Icons.lunch_dining,
        emojis: Emojis.byGroup(Group.foodAndDrink).where((e) => e.slackShortcode != null).toList(),
      ),
      EmojiCategoryEntity(
        name: context.tr.chat_emoji_category_travel_and_places,
        icon: Icons.flight,
        emojis: Emojis.byGroup(Group.travelAndPlaces).where((e) => e.slackShortcode != null).toList(),
      ),
      EmojiCategoryEntity(
        name: context.tr.chat_emoji_category_activities,
        icon: Icons.sports_basketball,
        emojis: Emojis.byGroup(Group.activities).where((e) => e.slackShortcode != null).toList(),
      ),
      EmojiCategoryEntity(
        name: context.tr.chat_emoji_category_objects,
        icon: Icons.photo_camera,
        emojis: Emojis.byGroup(Group.objects).where((e) => e.slackShortcode != null).toList(),
      ),
      EmojiCategoryEntity(name: context.tr.chat_emoji_category_symbols, icon: Icons.star, emojis: Emojis.byGroup(Group.symbols).where((e) => e.slackShortcode != null).toList()),
      EmojiCategoryEntity(name: context.tr.chat_emoji_category_flags, icon: Icons.flag, emojis: Emojis.byGroup(Group.flags).where((e) => e.slackShortcode != null).toList()),
    ];
  }

  static List<InlineSpan> markdownTextToTextSpan(
    String text, {
    String? channelId,
    required List<MessageMemberEntity> members,
    required List<MessageGroupEntity> groups,
    required List<MessageChannelEntity> channels,
    required List<MessageEmojiEntity> emojis,
  }) {
    if (text.isEmpty) return [TextSpan(text: '')];

    final List<InlineSpan> spans = [];
    final RegExp boldRegex = RegExp(r'\*\*(.*?)\*\*');
    final RegExp italicRegex = RegExp(r'\*(.*?)\*');
    final RegExp codeRegex = RegExp(r'`(.*?)`');
    final RegExp linkRegex = RegExp(r'\[(.*?)\]\((.*?)\)');
    final RegExp mentionRegex = RegExp(r'@([^@\n]+)|\u200b\u0040([^]*?)\u200b|\u200b\u0023([^]*?)\u200b', unicode: true);
    final RegExp italicStrikethroughRegex = RegExp(r'~_(.*?)_~');

    String remainingText = text;

    // Process italic strikethrough text
    final italicStrikethroughMatches = italicStrikethroughRegex.allMatches(remainingText);
    int italicStrikethroughOffset = 0;
    for (final match in italicStrikethroughMatches) {
      if (match.start > italicStrikethroughOffset) {
        spans.add(TextSpan(text: remainingText.substring(italicStrikethroughOffset, match.start)));
      }
      spans.add(
        TextSpan(
          children: markdownTextToTextSpan(match.group(1)!, channelId: channelId, members: members, groups: groups, channels: channels, emojis: emojis),
          style: const TextStyle(decoration: TextDecoration.lineThrough, fontStyle: FontStyle.italic),
        ),
      );
      italicStrikethroughOffset = match.end;
    }
    if (italicStrikethroughOffset < remainingText.length) {
      remainingText = remainingText.substring(italicStrikethroughOffset);
    } else {
      remainingText = '';
    }

    // Process links
    final linkMatches = linkRegex.allMatches(remainingText);
    int linkOffset = 0;
    for (final match in linkMatches) {
      if (match.start > linkOffset) {
        spans.add(TextSpan(text: remainingText.substring(linkOffset, match.start)));
      }

      final linkText = match.group(1)!;
      final linkUrl = match.group(2)!;

      spans.add(
        WidgetSpan(
          child: IntrinsicWidth(
            child: VisirButton(
              style: VisirButtonStyle(alignment: Alignment.topLeft, cursor: WidgetStateMouseCursor.clickable, hoverColor: Colors.transparent),
              behavior: HitTestBehavior.opaque,
              type: VisirButtonAnimationType.scaleAndOpacity,
              onTap: () => launchUrl(Uri.parse(linkUrl), mode: LaunchMode.externalApplication),
              builder: (isHover) => Text.rich(
                TextSpan(
                  children: markdownTextToTextSpan(linkText, channelId: channelId, members: members, groups: groups, channels: channels, emojis: emojis),
                ),
                style: TextStyle(color: mainContext.primary),
                textScaler: TextScaler.noScaling,
              ),
            ),
          ),
        ),
      );

      linkOffset = match.end;
    }
    if (linkOffset < remainingText.length) {
      remainingText = remainingText.substring(linkOffset);
    } else {
      remainingText = '';
    }

    // Process bold text
    final boldMatches = boldRegex.allMatches(remainingText);
    int boldOffset = 0;
    for (final match in boldMatches) {
      if (match.start > boldOffset) {
        spans.add(TextSpan(text: remainingText.substring(boldOffset, match.start)));
      }
      spans.add(
        TextSpan(
          children: markdownTextToTextSpan(match.group(1)!, channelId: channelId, members: members, groups: groups, channels: channels, emojis: emojis),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
      boldOffset = match.end;
    }
    if (boldOffset < remainingText.length) {
      remainingText = remainingText.substring(boldOffset);
    } else {
      remainingText = '';
    }

    // Process italic text
    final italicMatches = italicRegex.allMatches(remainingText);
    int italicOffset = 0;
    for (final match in italicMatches) {
      if (match.start > italicOffset) {
        spans.add(TextSpan(text: remainingText.substring(italicOffset, match.start)));
      }
      spans.add(
        TextSpan(
          children: markdownTextToTextSpan(match.group(1)!, channelId: channelId, members: members, groups: groups, channels: channels, emojis: emojis),
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
      );
      italicOffset = match.end;
    }
    if (italicOffset < remainingText.length) {
      remainingText = remainingText.substring(italicOffset);
    } else {
      remainingText = '';
    }

    // Process code text
    final codeMatches = codeRegex.allMatches(remainingText);
    int codeOffset = 0;
    for (final match in codeMatches) {
      if (match.start > codeOffset) {
        spans.add(TextSpan(text: remainingText.substring(codeOffset, match.start)));
      }
      spans.add(
        WidgetSpan(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(color: mainContext.surfaceVariant, borderRadius: BorderRadius.circular(4)),
            child: Text.rich(
              TextSpan(
                children: markdownTextToTextSpan(match.group(1)!, channelId: channelId, members: members, groups: groups, channels: channels, emojis: emojis),
                style: TextStyle(color: Colors.orange),
              ),
              textScaler: TextScaler.noScaling,
            ),
          ),
        ),
      );
      codeOffset = match.end;
    }
    if (codeOffset < remainingText.length) {
      remainingText = remainingText.substring(codeOffset);
    } else {
      remainingText = '';
    }

    int tagOffset = 0;

    final broadcastChannelTag = MessageTagEntity(type: MessageTagEntityType.broadcastChannel);
    final broadcastHereTag = MessageTagEntity(type: MessageTagEntityType.broadcastHere);
    final mentionMatches = mentionRegex.allMatches(remainingText);
    final channel = channels.firstWhereOrNull((e) => e.id == channelId);
    for (final match in mentionMatches) {
      if (match.start > tagOffset) {
        spans.add(TextSpan(text: remainingText.substring(tagOffset, match.start)));
      }

      final piece = remainingText.substring(match.start, match.end);

      bool isTag = mentionRegex.hasMatch(piece);
      String tagName = isTag ? piece.replaceAll('@', '').replaceAll('\u200b', '') : '';
      MessageMemberEntity? targetMembers = members.where((e) => e.displayName != null && tagName.startsWith(e.displayName!)).firstOrNull;
      MessageGroupEntity? targetGroups = groups.where((e) => e.displayName != null && tagName.startsWith(e.displayName!)).firstOrNull;
      MessageChannelEntity? targetChannel = channels.where((e) => e.name != null && tagName.startsWith(e.name!)).firstOrNull;

      bool isMe = targetMembers?.id == channel?.meId;
      bool isMyGroup = targetGroups?.users?.contains(channel?.meId) ?? false;
      bool isBroadcastChannel = tagName == broadcastChannelTag.displayName;
      bool isBroadcastHere = tagName == broadcastHereTag.displayName;

      if (targetMembers != null) {
        final name = '@${targetMembers.displayName!}';
        final leftovers = piece.replaceAll(name, '');
        spans.add(
          TextSpan(
            text: name,
            style: TextStyle(color: isMe ? mainContext.primary : mainContext.secondary),
          ),
        );
        if (leftovers.isNotEmpty) spans.add(TextSpan(text: leftovers));
      } else if (targetGroups != null) {
        final name = '@${targetGroups.displayName!}';
        final leftovers = piece.replaceAll(name, '');
        spans.add(
          TextSpan(
            text: name,
            style: TextStyle(color: isMyGroup ? mainContext.primary : mainContext.secondary),
          ),
        );
        if (leftovers.isNotEmpty) spans.add(TextSpan(text: leftovers));
      } else if (targetChannel != null) {
        final name = '#${targetChannel.name!}';
        final leftovers = piece.replaceAll(name, '');
        spans.add(
          TextSpan(
            text: name,
            style: TextStyle(color: mainContext.secondary),
          ),
        );
        if (leftovers.isNotEmpty) spans.add(TextSpan(text: leftovers));
      } else if (isBroadcastHere) {
        final name = '@${broadcastHereTag.displayName}';
        final leftovers = piece.replaceAll(name, '');
        spans.add(
          TextSpan(
            text: name,
            style: TextStyle(color: mainContext.secondary),
          ),
        );
        if (leftovers.isNotEmpty) spans.add(TextSpan(text: leftovers));
      } else if (isBroadcastChannel) {
        final name = '@${broadcastChannelTag.displayName}';
        final leftovers = piece.replaceAll(name, '');
        spans.add(
          TextSpan(
            text: name,
            style: TextStyle(color: mainContext.secondary),
          ),
        );
        if (leftovers.isNotEmpty) spans.add(TextSpan(text: leftovers));
      } else {
        spans.add(TextSpan(text: piece));
      }

      tagOffset = match.end;
    }

    if (tagOffset < text.length) {
      remainingText = remainingText.substring(tagOffset);
    } else {
      remainingText = '';
    }

    // Add any remaining text
    if (remainingText.isNotEmpty) {
      spans.add(TextSpan(text: remainingText));
    }

    return spans;
  }

  static Future<dynamic> showRecurrenceEditConfirmPopup({required bool isTask}) {
    if (PlatformX.isMobileView) {
      return Utils.showBottomDialog(
        title: TextSpan(text: isTask ? mainContext.tr.edit_recurring_task : mainContext.tr.edit_recurring_event),
        body: RecurrenceEditConfirmPopup(isTask: isTask),
      );
    } else {
      return Utils.showPopupDialog(
        forcePopup: true,
        isFlexibleHeightPopup: true,
        size: Size(320, 0),
        child: RecurrenceEditConfirmPopup(isTask: isTask),
      );
    }
  }

  static Future<void> clearWidgetData() async {
    if (!PlatformX.isMobile) return;

    await HomeWidget.saveWidgetData<String>('userEmail', '');
    await HomeWidget.saveWidgetData<String>('themeMode', '');
    await HomeWidget.saveWidgetData<String>('dateGroupedAppointments', '');
    await HomeWidget.saveWidgetData<String>('inboxes', '');
    await HomeWidget.saveWidgetData<String>('inboxUpdatedAt', '');

    await updateWidgetCore();
  }

  static void updateWidgetData({required String userEmail, ThemeMode? themeMode, List<Map<String, dynamic>>? appointments, List<InboxEntity>? inboxes}) async {
    if (!PlatformX.isMobile) return;
    await HomeWidget.saveWidgetData<String>('userEmail', userEmail);

    if (themeMode != null) {
      await HomeWidget.saveWidgetData<String>('themeMode', themeMode.name);
    }

    if (appointments != null) {
      appointments.sort((a, b) => (a['startAtMs'] as int).compareTo(b['startAtMs'] as int));

      final Map<String, dynamic> dateGroupedAppointments = {};
      final today = DateUtils.dateOnly(DateTime.now());

      // 월 단위 달력 위젯을 위해 최소 6주(42일) 데이터 필요
      // 이전 달의 마지막 주 일부부터 다음 달의 일부까지 포함하도록 계산
      final currentMonthStart = DateTime(today.year, today.month, 1);
      final calendarStartDate = currentMonthStart.subtract(Duration(days: 7)); // 이전 달의 마지막 주 일부 포함
      final nextMonthStart = DateTime(today.year, today.month + 1, 1);
      final calendarEndDate = nextMonthStart.add(Duration(days: 14)); // 다음 달의 일부까지 포함
      final daysToGenerate = calendarEndDate.difference(calendarStartDate).inDays;

      for (int i = 0; i < daysToGenerate; i++) {
        final date = calendarStartDate.add(Duration(days: i));
        final dateString = date.toIso8601String();
        dateGroupedAppointments[dateString] = {'appointments': [], 'eventAlldayCount': 0, 'taskAlldayCount': 0};
      }

      for (var appointment in appointments) {
        final startAt = appointment['startAtMs'] as int;
        final endAt = appointment['endAtMs'] as int;
        final isEvent = appointment['isEvent'] as bool? ?? false;
        final isAllday = appointment['isAllDay'] as bool? ?? false;
        final isDone = appointment['isDone'] as bool? ?? false;

        final startDate = DateUtils.dateOnly(DateTime.fromMillisecondsSinceEpoch(startAt));
        final endDate = DateUtils.dateOnly(DateTime.fromMillisecondsSinceEpoch(endAt));

        // Check if appointment spans multiple days
        final isMultiDay = endDate.difference(startDate).inHours >= 24;

        if (isMultiDay) {
          // Add appointment to all days it spans
          var currentDate = startDate;
          while (!currentDate.isAfter(endDate)) {
            final dateString = currentDate.toIso8601String();
            if (dateGroupedAppointments.containsKey(dateString) && !isDone) {
              if (isEvent) {
                dateGroupedAppointments[dateString]['eventAlldayCount']++;
              } else {
                dateGroupedAppointments[dateString]['taskAlldayCount']++;
              }

              // Create a copy of the appointment and set isAllDay to true
              final appointmentCopy = Map<String, dynamic>.from(appointment);
              appointmentCopy['isAllDay'] = true;
              dateGroupedAppointments[dateString]['appointments'].add(appointmentCopy);
            }
            currentDate = currentDate.add(const Duration(days: 1));
          }
        } else {
          // Single day appointment
          final dateString = startDate.toIso8601String();
          if (dateGroupedAppointments.containsKey(dateString) && !isDone) {
            if (isAllday) {
              if (isEvent) {
                dateGroupedAppointments[dateString]['eventAlldayCount']++;
              } else {
                dateGroupedAppointments[dateString]['taskAlldayCount']++;
              }
            }

            dateGroupedAppointments[dateString]['appointments'].add(appointment);
          }
        }
      }

      final jsonString = jsonEncode(dateGroupedAppointments);
      await HomeWidget.saveWidgetData<String>('dateGroupedAppointments', jsonString);
    }

    if (inboxes != null) {
      final jsonString = jsonEncode(
        inboxes.map((inbox) {
          final data = inbox.toJson(local: true);
          final provider = inbox.providers.firstOrNull;
          if (provider != null) {
            data['providerIcon'] = provider.icon;
            data['providerName'] = provider.name;
          }
          data['timeString'] = DateFormat('h:mm a').format(inbox.inboxDatetime.toLocal());
          final linkedMessage = inbox.linkedMessage;
          final isChannel = linkedMessage?.isChannel ?? false;
          final messageUserName = linkedMessage?.userName;
          if (messageUserName != null && isChannel) {
            data['messageUserName'] = messageUserName;
          }
          return data;
        }).toList(),
      );
      List<Future> futures = [HomeWidget.saveWidgetData<String>('inboxes', jsonString), HomeWidget.saveWidgetData<String>('inboxUpdatedAt', DateTime.now().toIso8601String())];
      await Future.wait(futures);
    }

    await updateWidgetCore();
  }

  static Future<void> insertInboxWidgetDataFromNotification({required RemoteMessage message}) async {
    if (!PlatformX.isMobile) return;

    final data = message.data;

    String? messageType = data['type'];

    if (messageType == 'task' || messageType == 'event') {
      String? action = data['action'];
      if (messageType == null || action == null) return;
      final parsedData = data['data'] is String ? jsonDecode(data['data']) : data['data'];
      editAppointmentWidgetData(type: messageType, action: action, data: parsedData);
    } else {
      final notification = message.notification;

      String? messageTitle = notification?.title;
      String? messageBody = notification?.body;

      if (messageType == null || messageTitle == null || messageBody == null) return;

      Map<String, dynamic> inboxData = {};

      inboxData['providerName'] = messageTitle;
      inboxData['timeString'] = DateFormat('h:mm a').format(DateTime.now());

      if (messageType.contains('slack')) {
        inboxData['title'] = messageBody;
        inboxData['id'] = 'message_slack_${data['team_id']}_${data['event_id']}';
        inboxData['providerIcon'] = MessageEntityType.slack.icon;

        if (messageBody.contains(':')) {
          String title = messageBody;
          int colonIndex = messageBody.indexOf(':');
          if (colonIndex != -1) {
            title = messageBody.substring(colonIndex + 1).trim();
          }
          inboxData['title'] = title;
          inboxData['messageUserName'] = messageBody.substring(0, colonIndex).trim();
        }
      } else if (messageType.contains('gmail')) {
        inboxData['title'] = messageBody.split('\n').first.trim();
        inboxData['id'] = 'mail_google_${data['email']}_${data['messageId']}';
        inboxData['providerIcon'] = MailEntityType.google.icon;
      }

      final inboxUpdatedAt = await HomeWidget.getWidgetData<String>('inboxUpdatedAt');
      final inboxUpdatedAtDateTime = inboxUpdatedAt != null ? DateTime.parse(inboxUpdatedAt) : null;

      HomeWidget.getWidgetData<String>('inboxes').then((value) async {
        final inboxes = jsonDecode(value ?? '[]');

        final today = DateTime.now();
        final isPastDate = inboxUpdatedAtDateTime != null && DateUtils.isSameDay(inboxUpdatedAtDateTime, today) == false;

        List<Future> futures = [HomeWidget.saveWidgetData<String>('inboxUpdatedAt', DateTime.now().toIso8601String())];

        if (isPastDate) {
          // 오늘보다 과거 날짜면 리스트 리셋
          futures.add(HomeWidget.saveWidgetData<String>('inboxes', jsonEncode([inboxData])));
        } else {
          // 오늘 날짜면 리스트에 추가
          inboxes.insert(0, inboxData);
          futures.add(HomeWidget.saveWidgetData<String>('inboxes', jsonEncode(inboxes)));
        }

        await Future.wait(futures);

        await updateWidgetCore();
      });
    }
  }

  static List<Map<String, dynamic>> sortWidgetAppointmentsData(List<dynamic> appointments) {
    List<Map<String, dynamic>> sortedAppointments = appointments.where((item) => item is Map<String, dynamic>).map((item) => item as Map<String, dynamic>).toList();

    sortedAppointments.sort((a, b) {
      // 1. allDay 항목을 우선 정렬
      if (a['isAllDay'] != b['isAllDay']) {
        return a['isAllDay'] ? -1 : 1;
      }

      // 2. allDay 항목들끼리는 event를 우선 정렬
      if (a['isAllDay'] && b['isAllDay']) {
        if (a['isEvent'] != b['isEvent']) {
          return a['isEvent'] ? -1 : 1;
        }

        // event가 아닌 경우 (task인 경우) createdAt이 오래된 순서대로
        if (!a['isEvent'] && !b['isEvent']) {
          final createdAtA = a['createdAt'] ?? 0;
          final createdAtB = b['createdAt'] ?? 0;
          return createdAtA.compareTo(createdAtB);
        }
      }

      // 3. 시작 시간 기준 정렬 (오름차순)
      if (a['startAtMs'] != b['startAtMs']) {
        return a['startAtMs'].compareTo(b['startAtMs']);
      }

      // 4. 시작 시간이 같은 경우 isEvent가 true인 것을 우선
      if (a['isEvent'] != b['isEvent']) {
        return a['isEvent'] ? -1 : 1;
      }

      // 5. isEvent가 false인 경우 createdAt이 빠른 것을 우선
      if (!a['isEvent'] && !b['isEvent']) {
        final createdAtA = a['createdAt'] ?? 0;
        final createdAtB = b['createdAt'] ?? 0;
        return createdAtA.compareTo(createdAtB);
      }

      return 0;
    });
    return sortedAppointments;
  }

  static Future<void> editAppointmentWidgetData({required String type, required String action, required dynamic data}) async {
    try {
      if (!PlatformX.isMobile) return;
      if (['task', 'event'].contains(type) == false) return;

      final dateGroupedAppointmentsData = await HomeWidget.getWidgetData<String>('dateGroupedAppointments');
      final dateGroupedAppointments = jsonDecode(dateGroupedAppointmentsData ?? '[]');

      String? id;
      EventEntity? event;

      if (type == 'task') {
        id = data['id'];
      } else if (type == 'event') {
        event = EventEntity.fromJson(data);
        id = event.uniqueId;
      }

      switch (action) {
        case 'save':
        case 'insert':
        case 'update':
          final rrule = event?.rrule ?? data['rrule'];
          if (rrule == null) {
            dateGroupedAppointments.forEach((key, value) {
              final appointments = (value['appointments'] as List).map((item) => item as Map<String, dynamic>).toList();
              final eventAlldayCount = value['eventAlldayCount'] as int;
              final taskAlldayCount = value['taskAlldayCount'] as int;

              // 해당 taskId를 가진 appointment 찾기
              final foundIndex = appointments.indexWhere((appointment) => appointment['id'] == id || appointment['recurringTaskId'] == id);

              // 기존 데이터가 있으면 삭제
              if (foundIndex != -1) {
                final oldAppointment = appointments[foundIndex];

                // allDay 카운트 수정
                if (oldAppointment['isAllDay'] == true) {
                  if (oldAppointment['type'] == 'event') {
                    value['eventAlldayCount'] = max(0, eventAlldayCount - 1);
                  } else if (oldAppointment['type'] == 'task') {
                    value['taskAlldayCount'] = max(0, taskAlldayCount - 1);
                  }
                }

                appointments.removeAt(foundIndex);
              }

              if (event != null) {
                // event인 경우
                final startAt = event.startDate;
                final endAt = event.endDate;
                final keyDate = DateTime.parse(key).toLocal();

                if (startAt.year == keyDate.year && startAt.month == keyDate.month && startAt.day == keyDate.day) {
                  // 데이터 형식 변환
                  final formattedData = {
                    'id': event.uniqueId,
                    'title': event.title,
                    'colorInt': Color(int.parse(event.calendar.backgroundColor.replaceAll('#', '0xFF'))).value,
                    'startAtMs': startAt.millisecondsSinceEpoch,
                    'endAtMs': endAt.millisecondsSinceEpoch,
                    'isAllDay': event.isAllDay,
                    'isDone': false,
                    'recurringTaskId': event.recurringEventId,
                    'isEvent': true,
                  };

                  appointments.add(formattedData);

                  // 정렬 적용
                  value['appointments'] = sortWidgetAppointmentsData(appointments);

                  // allDay인 경우 카운트 증가
                  if (event.isAllDay) {
                    value['eventAlldayCount'] = eventAlldayCount + 1;
                  }
                }
              } else {
                // task인 경우
                final startAtStr = data['start_at'] as String?;
                if (startAtStr == null) return;

                final taskDate = DateTime.parse(startAtStr).toLocal();
                final keyDate = DateTime.parse(key).toLocal();

                if (taskDate.year == keyDate.year && taskDate.month == keyDate.month && taskDate.day == keyDate.day) {
                  // 데이터 형식 변환
                  final formattedData = {
                    'id': data['id'],
                    'title': data['title'],
                    'colorInt': Color(int.parse(data['background_color'].replaceAll('#', '0xFF'))).value,
                    'startAtMs': DateTime.parse(data['start_at']).millisecondsSinceEpoch,
                    'endAtMs': DateTime.parse(data['end_at']).millisecondsSinceEpoch,
                    'isAllDay': data['is_all_day'],
                    'isDone': data['status'] == 'done',
                    'recurringTaskId': data['recurring_task_id'],
                    'isEvent': false,
                    'createdAt': DateTime.parse(data['created_at']).millisecondsSinceEpoch,
                  };

                  appointments.add(formattedData);

                  // 정렬 적용
                  value['appointments'] = sortWidgetAppointmentsData(appointments);

                  // allDay인 경우 카운트 증가
                  if (data['is_all_day'] == true) {
                    value['taskAlldayCount'] = taskAlldayCount + 1;
                  }
                }
              }
            });

            // 업데이트된 데이터 저장
            await HomeWidget.saveWidgetData<String>('dateGroupedAppointments', jsonEncode(dateGroupedAppointments));
            await updateWidgetCore();
          }
          break;
        case 'delete':
          if (id == null) return;

          dateGroupedAppointments.forEach((key, value) {
            final appointments = value['appointments'] as List;
            final eventAlldayCount = value['eventAlldayCount'] as int;
            final taskAlldayCount = value['taskAlldayCount'] as int;

            // 해당 taskId를 가진 appointment 찾기
            final foundAppointment = appointments.firstWhere((appointment) => appointment['id'] == id || appointment['recurringTaskId'] == id, orElse: () => null);

            if (foundAppointment != null) {
              // allDay 이벤트인 경우 카운트 수정
              if (foundAppointment['isAllDay'] == true) {
                if (foundAppointment['type'] == 'event') {
                  value['eventAlldayCount'] = max(0, eventAlldayCount - 1);
                } else if (foundAppointment['type'] == 'task') {
                  value['taskAlldayCount'] = max(0, taskAlldayCount - 1);
                }
              }

              // 데이터 삭제
              appointments.removeWhere((appointment) => appointment['id'] == id || appointment['recurringTaskId'] == id);
            }
          });

          // 업데이트된 데이터 저장
          await HomeWidget.saveWidgetData<String>('dateGroupedAppointments', jsonEncode(dateGroupedAppointments));
          await updateWidgetCore();

          break;
      }
    } catch (e) {
      return;
    }
  }

  static Future<void> updateWidgetCore() async {
    if (!PlatformX.isMobile) return;

    List<Future> futures = [
      HomeWidget.updateWidget(
        name: 'UpcomingWidgetProvider',
        iOSName: 'UpcomingWidget',
        androidName: 'UpcomingWidgetProvider',
        qualifiedAndroidName: 'com.wavetogether.fillin.UpcomingWidgetProvider',
      ),
      HomeWidget.updateWidget(
        name: 'TaskWidgetProvider',
        iOSName: 'TaskWidget',
        androidName: 'TaskWidgetProvider',
        qualifiedAndroidName: 'com.wavetogether.fillin.TaskWidgetProvider',
      ),
      HomeWidget.updateWidget(
        name: 'InboxWidgetProvider',
        iOSName: 'InboxWidget',
        androidName: 'InboxWidgetProvider',
        qualifiedAndroidName: 'com.wavetogether.fillin.InboxWidgetProvider',
      ),
      HomeWidget.updateWidget(
        name: 'CalendarMonthWidgetProvider',
        iOSName: 'CalendarMonthWidget',
        androidName: 'CalendarMonthWidgetProvider',
        qualifiedAndroidName: 'com.wavetogether.fillin.CalendarMonthWidgetProvider',
      ),
      if (PlatformX.isIOS) HomeWidget.updateWidget(iOSName: 'TodayWidget'),
    ];

    await Future.wait(futures);
  }

  static void handleHomeWidgetClick(Uri? uri) {
    if (!PlatformX.isMobile) return;
    if (uri == null) return;

    final host = uri.host.toLowerCase();
    final queryParameters = uri.queryParameters;

    if (host == 'movetodate') {
      final date = queryParameters['date'];
      if (date != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(mainContext).popUntil((route) => route.isFirst);
          tabNotifier.value = TabType.calendar;
          Constants.inboxCalendarScreenKey.currentState?.moveCalendar(targetDate: DateUtils.dateOnly(DateTime.parse(date)));
        });
      }
    } else if (host == 'switchtab') {
      final tab = queryParameters['tab'];
      if (tab != null) {
        Navigator.popUntil(mainContext, (route) => route.isFirst);
        final tabType = [...TabType.values].firstWhereOrNull((e) => e.name == tab);
        if (tabType != null) {
          tabNotifier.value = tabType;
        }
      }
    } else if (host == 'openinboxitem') {
      final inboxId = queryParameters['id'];
      if (inboxId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(mainContext).popUntil((route) => route.isFirst);
          tabNotifier.value = TabType.home;
          Constants.inboxListScreenKey.currentState?.closeDetails();
          Constants.inboxListScreenKey.currentState?.moveToDate(DateUtils.dateOnly(DateTime.now())).then((_) {
            Constants.inboxListScreenKey.currentState?.selectInboxFromId(inboxId);
            Constants.inboxListScreenKey.currentState?.openInbox();
          });
        });
      }
    }
  }

  static Either<Failure, R> debugLeft<L, R>(Object error, {bool showErrorToast = false}) {
    Logger().e(error, stackTrace: StackTrace.current);
    Utils.reportAutoFeedback(errorMessage: 'debugLeft: ${error.toString()}: ${StackTrace.current}');
    if (showErrorToast) {
      showToast(
        ToastModel(
          message: TextSpan(text: error.toString()),
          buttons: [],
        ),
      );
    }
    return left(Failure.badRequest(StackTrace.current, error.toString()));
  }

  static String getColorString(BuildContext context, String? colorString) {
    if (colorString == null) return '';
    if (ColorX.fromHex(colorString) == Colors.red.shade500) return context.tr.mail_pref_account_color_red;
    if (ColorX.fromHex(colorString) == Colors.deepOrange.shade500) return context.tr.mail_pref_account_color_deep_orange;
    if (ColorX.fromHex(colorString) == Colors.orange.shade500) return context.tr.mail_pref_account_color_orange;
    if (ColorX.fromHex(colorString) == Colors.yellow.shade500) return context.tr.mail_pref_account_color_yellow;
    if (ColorX.fromHex(colorString) == Colors.lightGreen.shade500) return context.tr.mail_pref_account_color_light_green;
    if (ColorX.fromHex(colorString) == Colors.green.shade500) return context.tr.mail_pref_account_color_green;
    if (ColorX.fromHex(colorString) == Colors.teal.shade500) return context.tr.mail_pref_account_color_teal;
    if (ColorX.fromHex(colorString) == Colors.lightBlue.shade500) return context.tr.mail_pref_account_color_light_blue;
    if (ColorX.fromHex(colorString) == Colors.indigo.shade500) return context.tr.mail_pref_account_color_indigo;
    if (ColorX.fromHex(colorString) == Colors.deepPurple.shade500) return context.tr.mail_pref_account_color_deep_purple;
    if (ColorX.fromHex(colorString) == Colors.purple.shade500) return context.tr.mail_pref_account_color_purple;
    if (ColorX.fromHex(colorString) == Colors.brown.shade500) return context.tr.mail_pref_account_color_brown;
    return '';
  }

  static String getTimeString(BuildContext context, int? minute) {
    if (minute == 15) return '15 ${context.tr.minutes.toLowerCase()}';
    if (minute == 30) return '30 ${context.tr.minutes.toLowerCase()}';
    if (minute == 45) return '45 ${context.tr.minutes.toLowerCase()}';
    if (minute == 60) return '1 ${context.tr.hour.toLowerCase()}';
    if (minute == 90) return '1 ${context.tr.hour.toLowerCase()} 30 ${context.tr.minutes.toLowerCase()}';
    if (minute == 120) return '2 ${context.tr.hours.toLowerCase()}';
    return '';
  }

  static ScrollPhysics getScrollPhysicsForBottomSheet(BuildContext context, ScrollController? scrollController) {
    if ((ModalScrollController.ofSyncGroup(context) != null)) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        scrollController?.position.isScrollingNotifier.addListener(() {
          final position = scrollController.position;
          if (!position.isScrollingNotifier.value) {
            ModalBottomSheet.isDismissible = true;
          } else {
            if (position.pixels <= 0) {
              ModalBottomSheet.isDismissible = true;
            } else {
              ModalBottomSheet.isDismissible = false;
            }
          }
        });
      });

      return BottomSheetScrollPhysics();
    }
    return VisirBouncingScrollPhysics();
  }

  static Future<bool> isLatestVersionInMobile() async {
    if (!PlatformX.isMobile) return true;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final packageName = packageInfo.packageName;

      String? latestVersion;

      if (PlatformX.isIOS) {
        final url = 'https://itunes.apple.com/lookup?bundleId=$packageName';
        final response = await http.get(Uri.parse(url));
        final json = jsonDecode(response.body);
        if (json['resultCount'] > 0) {
          latestVersion = json['results'][0]['version'];
        }
      } else if (PlatformX.isAndroid) {
        final url = 'https://play.google.com/store/apps/details?id=$packageName&hl=en';
        final response = await http.get(Uri.parse(url));
        final regex = RegExp(r'\[\[\["([0-9.]+)"\]');
        final match = regex.firstMatch(response.body);
        latestVersion = match?.group(1);
      } else {
        // 웹, 데스크탑은 최신이라고 간주
        return true;
      }

      if (latestVersion == null) return true;

      // 버전 비교
      final currentParts = currentVersion.split('.').map(int.tryParse).whereType<int>().toList();
      final latestParts = latestVersion.split('.').map(int.tryParse).whereType<int>().toList();
      final length = [currentParts.length, latestParts.length].reduce((a, b) => a > b ? a : b);

      for (int i = 0; i < length; i++) {
        final c = (i < currentParts.length) ? currentParts[i] : 0;
        final l = (i < latestParts.length) ? latestParts[i] : 0;
        if (c < l) return false; // 업데이트 필요
        if (c > l) return true; // 최신
      }

      return true; // 동일한 버전
    } catch (e) {
      return true; // 오류 발생 시 업데이트 필요 없다고 처리
    }
  }

  static Future<void> openStorePage() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final packageName = packageInfo.packageName;

    String url;

    if (PlatformX.isAndroid) {
      url = 'https://play.google.com/store/apps/details?id=$packageName';
    } else if (PlatformX.isIOS) {
      const appStoreId = '6471948579';
      url = 'https://apps.apple.com/app/id$appStoreId';
    } else {
      return;
    }

    await launchUrlExternal(url: url);
  }

  static String textTrimmer(String? text) {
    if (text == null) return '';
    return text.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF\u00A0\u1680\u2000-\u200A\u202F\u205F\u3000\s]+'), ' ').trim();
  }
}

enum RateLimitType { slack, gmail, gcalendar }

extension RateLimitTypeX on RateLimitType {
  String getTitle(BuildContext context) {
    switch (this) {
      case RateLimitType.slack:
        return context.tr.message_slack_api_limit_reached;
      case RateLimitType.gcalendar:
        return context.tr.calendar_google_api_limit_reached;
      case RateLimitType.gmail:
        return context.tr.mail_google_api_limit_reached;
    }
  }
}

class ConsistentUnderlineText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const ConsistentUnderlineText({required this.text, required this.style, super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: UnderlinePainter(text, style),
        child: Text(text, style: style),
      ),
    );
  }
}

class UnderlinePainter extends CustomPainter {
  final String text;
  final TextStyle style;

  UnderlinePainter(this.text, this.style);

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.left,
    )..layout(maxWidth: size.width);

    final underlineHeight = style.fontSize! * 0.05; // 밑줄 높이 조절
    final paint = Paint()..color = style.color!;

    for (var line in textPainter.computeLineMetrics()) {
      final underlineY = line.baseline + underlineHeight;

      canvas.drawRect(Rect.fromLTWH(0, underlineY, line.width, underlineHeight), paint);
    }

    textPainter.paint(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ModalPopupNavigatorObserver extends NavigatorObserver {
  Map<String, double?> scrollOffsets = {};

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute?.navigator?.context != null) {
      scrollOffsets[previousRoute!.settings.name ?? ''] = ModalScrollController.of(previousRoute.navigator!.context)?.offset;
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute?.navigator?.context != null) {
      ModalScrollController.of(previousRoute!.navigator!.context)?.jumpTo(scrollOffsets[previousRoute.settings.name ?? ''] ?? 0);
    }
  }
}
