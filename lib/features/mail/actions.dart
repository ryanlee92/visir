import 'dart:convert';
import 'dart:typed_data';

import 'package:Visir/config/providers.dart';
import 'package:Visir/dependency/toasty_box/model/toast_model.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/inbox/application/inbox_controller.dart';
import 'package:Visir/features/mail/application/mail_draft_list_controller.dart';
import 'package:Visir/features/mail/application/mail_label_list_controller.dart';
import 'package:Visir/features/mail/application/mail_list_controller.dart';
import 'package:Visir/features/mail/application/mail_thread_list_controller.dart';
import 'package:Visir/features/mail/domain/entities/mail_entity.dart';
import 'package:Visir/features/mail/domain/entities/mail_label_entity.dart';
import 'package:Visir/features/mail/providers.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/gmail/v1.dart' as Gmail;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:html_unescape/html_unescape.dart';

class MailAction {
  static Future<void> openDraft({required MailEntity mail, bool? fromDraftBanner}) async {
    if (mail.draftId == null) return;

    Utils.showMailEditScreen(
      from: mail.from,
      to: mail.to,
      cc: mail.cc,
      bcc: mail.bcc,
      subject: mail.subject,
      bodyHtml: mail.html,
      attachments: mail.getAttachments(),
      prevMessageId: mail.id,
      threadId: mail.threadId,
      draftId: mail.draftId,
      fromDraftBanner: fromDraftBanner,
    );
    MailAction.removeDraftFromPreview(mail: mail);
  }

  static Future<void> saveDarft({required MailEntity mail, required bool minimize}) async {
    final mailListController = Utils.ref.read(mailListControllerProvider.notifier);
    final mailDraftListController = Utils.ref.read(mailDraftListControllerProvider.notifier);
    final mailLabelListController = Utils.ref.read(mailLabelListControllerProvider.notifier);

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      if (minimize) mailDraftListController.add(mail);
      if (mail.draftId == null) mailLabelListController.addDraft(mail.hostEmail);
      final result = await mailListController.draft(mail: mail);

      if (result == null) {
        if (minimize) mailDraftListController.remove(mail);
        if (mail.draftId == null) mailLabelListController.removeDraft(mail.hostEmail);
      } else {
        if (minimize) mailDraftListController.replace(mail, result);
      }
    });
  }

  static Future<void> removeDarft({required MailEntity mail}) async {
    final mailListController = Utils.ref.read(mailListControllerProvider.notifier);
    final mailLabelListController = Utils.ref.read(mailLabelListControllerProvider.notifier);

    mailLabelListController.removeDraft(mail.hostEmail);
    final result = await mailListController.undraft(mail: mail);
    if (result == true) {
      return;
    }

    mailLabelListController.addDraft(mail.hostEmail);
  }

  static Future<void> removeDraftFromPreview({required MailEntity mail}) async {
    final mailDraftListController = Utils.ref.read(mailDraftListControllerProvider.notifier);
    mailDraftListController.remove(mail);
  }

  static Future<void> sendMail({required MailEntity mail, required MimeMessage mimeMessage}) async {
    final mailListController = Utils.ref.read(mailListControllerProvider.notifier);

    mailListController.send(mail: mail).then((result) {
      if (result != null) {
        [...TabType.values].forEach((type) {
          if (Utils.ref.exists(mailThreadListControllerProvider(tabType: type))) {
            Utils.ref.read(mailThreadListControllerProvider(tabType: type).notifier).addMailLocal(result);
          }
        });
      }

      if (result == null) {
        Utils.showToast(
          ToastModel(
            message: TextSpan(text: Utils.mainContext.tr.failed_to_send_mail),
            buttons: [
              ToastButton(
                color: Utils.mainContext.error,
                textColor: Utils.mainContext.onError,
                text: Utils.mainContext.tr.retry_to_send_mail,
                onTap: (item) {
                  Utils.showMailEditScreen(
                    from: mail.from,
                    to: mail.to,
                    cc: mail.cc,
                    bcc: mail.bcc,
                    subject: mail.subject,
                    bodyHtml: mail.html,
                    threadId: mail.threadId,
                    draftId: mail.draftId,
                    fromDraftBanner: false,
                  );
                },
              ),
            ],
          ),
        );
      }
    });

    Utils.showToast(
      ToastModel(
        message: TextSpan(text: Utils.mainContext.tr.mail_sent),
        buttons: [
          ToastButton(
            color: Utils.mainContext.primary,
            textColor: Utils.mainContext.onPrimary,
            text: Utils.mainContext.tr.mail_toast_undo,
            onTap: (item) {
              mailListController.undoSend(mail.id!);
            },
          ),
        ],
      ),
    );
  }

  static Future<void> read({required List<MailEntity> mails, required TabType tabType, int? unreadCount}) async {
    final restTabType = [...TabType.values]..removeWhere((element) => element == tabType);

    final mailListController = Utils.ref.read(mailListControllerProvider.notifier);
    final mailLabelListController = Utils.ref.read(mailLabelListControllerProvider.notifier);

    final threadIds = mails.map((e) => e.threadId).whereType<String>().toList();
    mailLabelListController.readInbox(mails, unreadCount: unreadCount);
    Utils.ref.read(inboxControllerProvider.notifier).readMailLocally(threadIds);
    restTabType.forEach((type) {
      if (Utils.ref.exists(mailThreadListControllerProvider(tabType: type))) {
        Utils.ref.read(mailThreadListControllerProvider(tabType: type).notifier).read(threadIds: threadIds, targetTab: tabType);
      }
    });

    final result = await mailListController.readThreads(mails: mails);

    if (result) return;
    mailLabelListController.unreadInbox(mails);
    Utils.ref.read(inboxControllerProvider.notifier).unreadMailLocally(threadIds);
    restTabType.forEach((type) {
      if (Utils.ref.exists(mailThreadListControllerProvider(tabType: type))) {
        Utils.ref.read(mailThreadListControllerProvider(tabType: type).notifier).unread(threadIds: threadIds, targetTab: tabType);
      }
    });
  }

  static Future<void> unread({required List<MailEntity> mails, required TabType tabType}) async {
    final restTabType = [...TabType.values]..removeWhere((element) => element == tabType);

    final mailListController = Utils.ref.read(mailListControllerProvider.notifier);
    final mailLabelListController = Utils.ref.read(mailLabelListControllerProvider.notifier);

    final threadIds = mails.map((e) => e.threadId).whereType<String>().toList();

    mailLabelListController.unreadInbox(mails);
    Utils.ref.read(inboxControllerProvider.notifier).unreadMailLocally(threadIds);

    restTabType.forEach((type) {
      if (Utils.ref.exists(mailThreadListControllerProvider(tabType: type))) {
        Utils.ref.read(mailThreadListControllerProvider(tabType: type).notifier).unread(threadIds: threadIds, targetTab: tabType);
      }
    });

    final result = await mailListController.unreadThreads(mails: mails);

    if (result) return;

    mailLabelListController.readInbox(mails);
    Utils.ref.read(inboxControllerProvider.notifier).readMailLocally(threadIds);

    restTabType.forEach((type) {
      if (Utils.ref.exists(mailThreadListControllerProvider(tabType: type))) {
        Utils.ref.read(mailThreadListControllerProvider(tabType: type).notifier).unread(threadIds: threadIds, targetTab: tabType);
      }
    });
  }

  static Future<void> pin({required List<MailEntity> mails, required TabType tabType}) async {
    final restTabType = [...TabType.values]..removeWhere((element) => element == tabType);

    final mailListController = Utils.ref.read(mailListControllerProvider.notifier);
    final mailLabelListController = Utils.ref.read(mailLabelListControllerProvider.notifier);

    final threadIds = mails.map((e) => e.threadId).whereType<String>().toList();

    mailLabelListController.pinLabel(mails);
    Utils.ref.read(inboxControllerProvider.notifier).pinMailLocally(threadIds);
    restTabType.forEach((type) {
      if (Utils.ref.exists(mailThreadListControllerProvider(tabType: type))) {
        Utils.ref.read(mailThreadListControllerProvider(tabType: type).notifier).pin(threadIds: threadIds, targetTab: tabType);
      }
    });

    final result = await mailListController.pinThreads(mails: mails);

    if (result) return;

    mailLabelListController.unpinLabel(mails);
    Utils.ref.read(inboxControllerProvider.notifier).unpinMailLocally(threadIds);

    restTabType.forEach((type) {
      if (Utils.ref.exists(mailThreadListControllerProvider(tabType: type))) {
        Utils.ref.read(mailThreadListControllerProvider(tabType: type).notifier).unpin(threadIds: threadIds, targetTab: tabType);
      }
    });
  }

  static Future<void> unpin({required List<MailEntity> mails, required TabType tabType}) async {
    final restTabType = [...TabType.values]..removeWhere((element) => element == tabType);

    final mailListController = Utils.ref.read(mailListControllerProvider.notifier);
    final mailLabelListController = Utils.ref.read(mailLabelListControllerProvider.notifier);

    final threadIds = mails.map((e) => e.threadId).whereType<String>().toList();

    mailLabelListController.unpinLabel(mails);
    Utils.ref.read(inboxControllerProvider.notifier).unpinMailLocally(threadIds);

    restTabType.forEach((type) {
      if (Utils.ref.exists(mailThreadListControllerProvider(tabType: type))) {
        Utils.ref.read(mailThreadListControllerProvider(tabType: type).notifier).unpin(threadIds: threadIds, targetTab: tabType);
      }
    });

    final result = await mailListController.unpinThreads(mails: mails);

    if (result) return;

    Utils.ref.read(inboxControllerProvider.notifier).pinMailLocally(threadIds);
    mailLabelListController.pinLabel(mails);

    restTabType.forEach((type) {
      if (Utils.ref.exists(mailThreadListControllerProvider(tabType: type))) {
        Utils.ref.read(mailThreadListControllerProvider(tabType: type).notifier).pin(threadIds: threadIds, targetTab: tabType);
      }
    });
  }

  static Future<void> trash({required List<MailEntity> mails, required TabType tabType}) async {
    final restTabType = [...TabType.values]..removeWhere((element) => element == tabType);

    final mailListController = Utils.ref.read(mailListControllerProvider.notifier);
    final mailLabelListController = Utils.ref.read(mailLabelListControllerProvider.notifier);

    final threadIds = mails.map((e) => e.threadId).whereType<String>().toList();

    mailLabelListController.readInbox(mails);
    restTabType.forEach((type) {
      if (Utils.ref.exists(mailThreadListControllerProvider(tabType: type))) {
        Utils.ref.read(mailThreadListControllerProvider(tabType: type).notifier).trash(threadIds: threadIds, targetTab: tabType);
      }
    });

    Utils.ref.read(inboxControllerProvider.notifier).removeMailLocally(threadIds);

    final result = await mailListController.trashThreads(mails: mails);
    if (result) {
      Utils.showToast(
        ToastModel(
          message: TextSpan(text: mails.length == 1 ? Utils.mainContext.tr.mail_toast_trash : Utils.mainContext.tr.mail_toast_trashs(mails.length)),
          buttons: [
            ToastButton(
              color: Utils.mainContext.primary,
              textColor: Utils.mainContext.onPrimary,
              text: Utils.mainContext.tr.mail_toast_undo,
              onTap: (item) => untrash(mails: mails, tabType: tabType),
            ),
          ],
        ),
      );
      return;
    }

    Utils.ref.read(inboxControllerProvider.notifier).upsertMailInboxLocally(mails);

    mailLabelListController.unreadInbox(mails);
    restTabType.forEach((type) {
      if (Utils.ref.exists(mailThreadListControllerProvider(tabType: type))) {
        Utils.ref.read(mailThreadListControllerProvider(tabType: type).notifier).untrash(threadIds: threadIds, targetTab: tabType);
      }
    });
  }

  static Future<void> untrash({required List<MailEntity> mails, required TabType tabType}) async {
    final restTabType = [...TabType.values]..removeWhere((element) => element == tabType);

    final mailListController = Utils.ref.read(mailListControllerProvider.notifier);
    final mailLabelListController = Utils.ref.read(mailLabelListControllerProvider.notifier);

    final threadIds = mails.map((e) => e.threadId).whereType<String>().toList();

    mailLabelListController.unreadInbox(mails);

    restTabType.forEach((type) {
      if (Utils.ref.exists(mailThreadListControllerProvider(tabType: type))) {
        Utils.ref.read(mailThreadListControllerProvider(tabType: type).notifier).untrash(threadIds: threadIds, targetTab: tabType);
      }
    });

    final result = await mailListController.untrashThreads(mails: mails);

    if (result) return;

    mailLabelListController.readInbox(mails);

    restTabType.forEach((type) {
      if (Utils.ref.exists(mailThreadListControllerProvider(tabType: type))) {
        Utils.ref.read(mailThreadListControllerProvider(tabType: type).notifier).trash(threadIds: threadIds, targetTab: tabType);
      }
    });
  }

  static Future<void> archive({required List<MailEntity> mails, required TabType tabType}) async {
    final restTabType = [...TabType.values]..removeWhere((element) => element == tabType);

    final mailListController = Utils.ref.read(mailListControllerProvider.notifier);
    final mailLabelListController = Utils.ref.read(mailLabelListControllerProvider.notifier);

    final threadIds = mails.map((e) => e.threadId).whereType<String>().toList();

    mailLabelListController.readInbox(mails);
    restTabType.forEach((type) {
      if (Utils.ref.exists(mailThreadListControllerProvider(tabType: type))) {
        Utils.ref.read(mailThreadListControllerProvider(tabType: type).notifier).archive(threadIds: threadIds, targetTab: tabType);
      }
    });

    final result = await mailListController.archiveThreads(mails: mails);

    if (result) {
      Utils.showToast(
        ToastModel(
          message: TextSpan(text: Utils.mainContext.tr.mail_toast_archive),
          buttons: [
            ToastButton(
              color: Utils.mainContext.primary,
              textColor: Utils.mainContext.onPrimary,
              text: Utils.mainContext.tr.mail_toast_undo,
              onTap: (item) {
                unarchive(mails: mails, tabType: tabType);
              },
            ),
          ],
        ),
      );
      return;
    }

    mailLabelListController.unreadInbox(mails);
    restTabType.forEach((type) {
      if (Utils.ref.exists(mailThreadListControllerProvider(tabType: type))) {
        Utils.ref.read(mailThreadListControllerProvider(tabType: type).notifier).unarchive(threadIds: threadIds, targetTab: tabType);
      }
    });
  }

  static Future<void> unarchive({required List<MailEntity> mails, required TabType tabType}) async {
    final restTabType = [...TabType.values]..removeWhere((element) => element == tabType);

    final mailListController = Utils.ref.read(mailListControllerProvider.notifier);
    final mailLabelListController = Utils.ref.read(mailLabelListControllerProvider.notifier);

    final threadIds = mails.map((e) => e.threadId).whereType<String>().toList();

    mailLabelListController.unreadInbox(mails);
    restTabType.forEach((type) {
      if (Utils.ref.exists(mailThreadListControllerProvider(tabType: type))) {
        Utils.ref.read(mailThreadListControllerProvider(tabType: type).notifier).unarchive(threadIds: threadIds, targetTab: tabType);
      }
    });

    final result = await mailListController.unarchiveThreads(mails: mails);

    if (result) return;

    mailListController.archiveThreads(mails: mails);
    mailLabelListController.readInbox(mails);
    restTabType.forEach((type) {
      if (Utils.ref.exists(mailThreadListControllerProvider(tabType: type))) {
        Utils.ref.read(mailThreadListControllerProvider(tabType: type).notifier).archive(threadIds: threadIds, targetTab: tabType);
      }
    });
  }

  static Future<void> spam({required List<MailEntity> mails, required TabType tabType}) async {
    final restTabType = [...TabType.values]..removeWhere((element) => element == tabType);

    final mailListController = Utils.ref.read(mailListControllerProvider.notifier);
    final mailLabelListController = Utils.ref.read(mailLabelListControllerProvider.notifier);

    final threadIds = mails.map((e) => e.threadId).whereType<String>().toList();

    mailLabelListController.readInbox(mails);
    mailLabelListController.spamLabel(mails);

    restTabType.forEach((type) {
      if (Utils.ref.exists(mailThreadListControllerProvider(tabType: type))) {
        Utils.ref.read(mailThreadListControllerProvider(tabType: type).notifier).spam(threadIds: threadIds, targetTab: tabType);
      }
    });

    final result = await mailListController.spamThreads(mails: mails);

    if (result) {
      Utils.showToast(
        ToastModel(
          message: TextSpan(text: Utils.mainContext.tr.mail_toast_spam),
          buttons: [
            ToastButton(
              color: Utils.mainContext.primary,
              textColor: Utils.mainContext.onPrimary,
              text: Utils.mainContext.tr.mail_toast_undo,
              onTap: (item) {
                unspam(mails: mails, tabType: tabType);
              },
            ),
          ],
        ),
      );
      return;
    }
    mailLabelListController.unreadInbox(mails);
    mailLabelListController.unspamLabel(mails);

    restTabType.forEach((type) {
      if (Utils.ref.exists(mailThreadListControllerProvider(tabType: type))) {
        Utils.ref.read(mailThreadListControllerProvider(tabType: type).notifier).unspam(threadIds: threadIds, targetTab: tabType);
      }
    });
  }

  static Future<void> unspam({required List<MailEntity> mails, required TabType tabType}) async {
    final restTabType = [...TabType.values]..removeWhere((element) => element == tabType);

    final mailListController = Utils.ref.read(mailListControllerProvider.notifier);
    final mailLabelListController = Utils.ref.read(mailLabelListControllerProvider.notifier);

    final threadIds = mails.map((e) => e.threadId).whereType<String>().toList();

    mailLabelListController.unreadInbox(mails);
    mailLabelListController.unspamLabel(mails);
    restTabType.forEach((type) {
      if (Utils.ref.exists(mailThreadListControllerProvider(tabType: type))) {
        Utils.ref.read(mailThreadListControllerProvider(tabType: type).notifier).unspam(threadIds: threadIds, targetTab: tabType);
      }
    });

    final result = await mailListController.unspamThreads(mails: mails);
    if (result) return;

    mailListController.spamThreads(mails: mails);
    mailLabelListController.readInbox(mails);
    mailLabelListController.spamLabel(mails);
    restTabType.forEach((type) {
      if (Utils.ref.exists(mailThreadListControllerProvider(tabType: type))) {
        Utils.ref.read(mailThreadListControllerProvider(tabType: type).notifier).spam(threadIds: threadIds, targetTab: tabType);
      }
    });
  }

  static Future<void> delete({required List<MailEntity> mails, required TabType tabType}) async {
    final restTabType = [...TabType.values]..removeWhere((element) => element == tabType);

    final mailListController = Utils.ref.read(mailListControllerProvider.notifier);
    final mailLabelListController = Utils.ref.read(mailLabelListControllerProvider.notifier);

    final threadIds = mails.map((e) => e.threadId).whereType<String>().toList();

    mailLabelListController.readInbox(mails);
    mailLabelListController.removeMailLocal(
      mails.map((e) => TempMailEntity(id: e.id ?? e.draftId!, labelIds: e.labelIds ?? [], hostEmail: e.hostEmail)).toList(),
    );

    restTabType.forEach((type) {
      if (Utils.ref.exists(mailThreadListControllerProvider(tabType: type))) {
        Utils.ref.read(mailThreadListControllerProvider(tabType: type).notifier).delete(threadIds: threadIds, targetTab: tabType);
      }
    });

    final result = await mailListController.deleteThreads(mails: mails);

    if (result) return;

    // mailListController.spamThreads(mail: mail);
    // if (mail.isUnread && !mail.isArchive) mailLabelListController.readInbox(mail.hostEmail);
    // mailLabelListController.spamLabel(mail.hostEmail, mail.isUnread);
  }

  static Future<void> deleteAll({required String labelId, required TabType tabType}) async {
    String? hostMail = Utils.ref.read(mailConditionProvider(TabType.mail).select((v) => v.email));
    await Utils.ref.read(mailListControllerProvider.notifier).deleteAllMailsInLabel(labelId: labelId);
    if (labelId == CommonMailLabels.draft.id) Utils.ref.read(mailDraftListControllerProvider.notifier).clear();
    Utils.ref.read(mailLabelListControllerProvider.notifier).clearLabel(hostMail, labelId);
  }
}

class GmailHelper {
  static Gmail.MessagePart gmailPayloadFromMimeMessage(MimeMessage mimeMessage) {
    final unescape = HtmlUnescape();

    Gmail.MessagePart partToGmailPayload(MimePart part) {
      // 1) headers
      final headers = <Gmail.MessagePartHeader>[for (final h in (part.headers ?? const <Header>[])) Gmail.MessagePartHeader(name: h.name, value: h.value)];

      // 2) body (텍스트/바이너리 구분 처리)
      Uint8List _safeContentBytes(MimePart p) {
        final mt = (p.mediaType.text).toLowerCase();

        // ---- 텍스트 계열: 먼저 decodeContentText()로 전송 인코딩 해제 ----
        if (mt.startsWith('text/')) {
          try {
            final text = p.decodeContentText(); // qp/base64 + charset 처리
            if (text != null && text.isNotEmpty) {
              String out = text;

              // text/html 이고, 내용이 엔티티로 이스케이프된 HTML이라면 언이스케이프
              final looksEscapedHtml =
                  mt.startsWith('text/html') && out.contains('&lt;') && out.contains('&gt;') && !out.contains('<'); // 실제 태그가 전혀 없고 엔티티만 있을 때

              if (looksEscapedHtml) {
                out = unescape.convert(out);
              }

              return Uint8List.fromList(utf8.encode(out));
            }
          } catch (_) {
            // 아래 바이너리/폴백으로 진행
          }
        }

        // ---- 바이너리/그 외: decodeContentBinary() 시도 ----
        try {
          final b = p.decodeContentBinary();
          if (b != null && b.isNotEmpty) {
            return Uint8List.fromList(b);
          }
        } catch (_) {}

        // 최종 폴백 없음
        return Uint8List(0);
      }

      final contentBytes = _safeContentBytes(part);

      // 표준 base64(패딩 포함)로 저장 -> 네 쪽 dataAsBytes(base64.decode)와 완전 호환
      final body = Gmail.MessagePartBody(size: contentBytes.length, data: contentBytes.isEmpty ? null : base64.encode(contentBytes));

      // 3) filename / mimeType
      final filename = part.decodeFileName() ?? '';
      final mediaType = part.mediaType;
      final mimeType = (mediaType.text.isNotEmpty) ? mediaType.text : (mediaType.toString());

      // 4) children
      final children = <Gmail.MessagePart>[for (final c in (part.parts ?? const <MimePart>[])) partToGmailPayload(c)];

      return Gmail.MessagePart(
        partId: part.hashCode.toString(),
        mimeType: mimeType,
        filename: filename,
        headers: headers,
        body: body,
        parts: children.isEmpty ? null : children,
      );
    }

    return partToGmailPayload(mimeMessage);
  }
}

class HtmlSnippet {
  /// HTML에서 사람 친화적인 스니펫을 뽑는다.
  /// - 인용/서명/히스토리/스크립트/스타일 제거
  /// - 엔티티 언이스케이프
  /// - 공백/개행 정규화
  /// - 최대 길이(maxLen)로 깔끔히 자르기(문장 경계 우선)
  static String extract(String html, {int maxLen = 180, bool keepLineBreaks = false}) {
    if (html.trim().isEmpty) return '';

    // 1) DOM 파싱
    final doc = html_parser.parse(html);

    // 2) 노이즈 제거: 스크립트/스타일/헤더/푸터/네비/양식/광고 및 Gmail 특유의 인용
    for (final selector in [
      'script',
      'style',
      'noscript',
      'template',
      'header',
      'footer',
      'nav',
      'form',
      'iframe',
      '.gmail_quote', // Gmail 인용 블록
      '.gmail_attr', // "On Fri ... wrote:" 메타
      'blockquote', // 과감히 인용은 전부 제거(필요시 완화)
      '.yahoo_quoted', // Yahoo
      '.moz-cite-prefix', // Thunderbird
      '.gmail_signature', // Gmail 서명
      '.signature', // 일반 서명
    ]) {
      doc.querySelectorAll(selector).forEach((e) => e.remove());
    }

    // 3) 가시 텍스트만 남기고, <br> / <p>는 개행으로 유지
    //    (keepLineBreaks=false면 마지막에 공백 1칸으로 축약)
    _replaceWithNewline(doc, ['br', 'p', 'div', 'li']);

    // 4) 엔티티 언이스케이프 후 텍스트 추출
    final unescape = HtmlUnescape();
    var text = unescape.convert(doc.body?.text ?? doc.text ?? '');

    // 5) 이메일 히스토리 패턴 날리기 (가벼운 휴리스틱)
    final historyPatterns = <RegExp>[
      RegExp(r'^On .* wrote:\s*$', caseSensitive: false, multiLine: true),
      RegExp(r'^From: .*\s*$', caseSensitive: false, multiLine: true),
      RegExp(r'^Sent: .*\s*$', caseSensitive: false, multiLine: true),
      RegExp(r'^To: .*\s*$', caseSensitive: false, multiLine: true),
      RegExp(r'^Subject: .*\s*$', caseSensitive: false, multiLine: true),
      RegExp(r'^>.*$', multiLine: true), // 인용 접두부
    ];
    for (final re in historyPatterns) {
      text = text.replaceAll(re, '');
    }

    // 6) 공백 정규화
    text = text.replaceAll('\u200B', ''); // zero-width
    text = text.replaceAll(RegExp(r'[ \t]+'), ' ');
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();

    if (!keepLineBreaks) {
      text = text.replaceAll(RegExp(r'\s*\n\s*'), ' ').trim();
    }

    // 7) 앞부분에서 “의미 있는” 라인/문장 선택
    final candidate = _firstMeaningfulChunk(text);

    // 8) 길이 제한 내로 자르기(문장 경계 우선 → 단어 경계 → 말줄임)
    return _smartTruncate(candidate, maxLen);
  }

  /// 의미 없는 짧은 줄/잡음을 거르고 첫 의미 있는 덩어리를 고른다.
  static String _firstMeaningfulChunk(String input) {
    // 먼저 빈 줄 기준으로 단락 split
    final paragraphs = input.split(RegExp(r'\n{2,}')).map((s) => s.trim());
    for (final p in paragraphs) {
      if (p.isEmpty) continue;
      // 너무 짧은 잡문/잔여물 제외
      if (p.length < 3) continue;
      // "—"만 있는 라인 같은 잡음 제외
      if (RegExp(r'^[-–—•]+$').hasMatch(p)) continue;
      // 바로 문장 단위로 첫 문단 반환
      return p;
    }
    // 전부 실패하면 원문
    return input.trim();
  }

  /// 태그들을 개행으로 치환(텍스트 추출에 도움)
  static void _replaceWithNewline(dom.Document doc, List<String> tagNames) {
    for (final tag in tagNames) {
      for (final e in doc.querySelectorAll(tag)) {
        e.append(dom.Text('\n'));
      }
    }
  }

  /// 길이 제한 내에서 최대한 자연스럽게 자르기
  static String _smartTruncate(String s, int maxLen) {
    if (s.length <= maxLen) return s;

    // 1) 문장 경계 우선 (., !, ?, …)
    final sentenceEnd = RegExp(r'(?<=\.|!|\?|…)\s');
    final sentences = s.split(sentenceEnd).map((e) => e.trim()).toList();
    var acc = '';
    for (final sent in sentences) {
      final next = acc.isEmpty ? sent : '$acc $sent';
      if (next.length > maxLen) break;
      acc = next;
    }
    if (acc.isNotEmpty && acc.length >= maxLen * 0.6) return acc;

    // 2) 단어 경계
    final words = s.split(RegExp(r'\s+'));
    acc = '';
    for (final w in words) {
      final next = acc.isEmpty ? w : '$acc $w';
      if (next.length > maxLen) break;
      acc = next;
    }
    if (acc.isNotEmpty && acc.length >= maxLen * 0.5) return '$acc…';

    // 3) 최후: 하드컷
    return s.substring(0, maxLen - 1).trimRight() + '…';
  }
}
