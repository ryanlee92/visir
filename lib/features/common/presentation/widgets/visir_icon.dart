import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons_full.dart';

enum VisirIconType {
  home,
  chat,
  mail,
  calendar,
  inbox,
  task,
  today,
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
  month,
  networkUnavailable,
  login,
  logout,
  arrowUp,
  arrowDown,
  arrowRight,
  arrowLeft,
  check,
  taskCheck,
  close,
  caution,
  videoCall,
  videoCallOff,
  add,
  closeWithCircle,
  checkWithCircle,
  helpWithCircle,
  unknownWithCircle,
  listSetting,
  clock,
  copy,
  trash,
  location,
  description,
  attendee,
  notification,
  notificationOff,
  share,
  chatDm,
  chatGroupDm,
  chatChannel,
  photo,
  file,
  inboxIn,
  enter,
  send,
  integration,
  control,
  search,
  emoji,
  more,
  thread,
  edit,
  pause,
  play,
  download,
  show,
  hide,
  soundOff,
  soundOn,
  refresh,
  list,
  profile,
  linkedTask,
  pin,
  archive,
  spam,
  reply,
  replyAll,
  forward,
  outlink,
  addWithCircle,
  subtractWithCircle,
  subscription,
  privacy,
  settings,
  trophy,
  sidebar,
  repeat,
  infoWithCircle,
  pinOff,
  archiveOff,
  spamOff,
  trashOff,
  formatBold,
  formatItalic,
  formatStrikethrough,
  formatInlineCode,
  formatListNumbers,
  formatListBullets,
  formatCodeBlock,
  formatQuote,
  formatSize,
  formatColor,
  formatAlignLeft,
  formatAlignRight,
  formatAlignCenter,
  formatAlignJustify,
  formatUnderline,
  signature,
  formatIndentIncrease,
  formatIndentDecrease,
  calendarBefore,
  calendarAfter,
  agent,
  manual,
  dark,
  light,
  terms,
  subtract,
  emptyCircle,
  dollar,
  converted,
  hideSidebar,
  showSidebar,
  badgeOn,
  badgeOff,
  launchAtStartupOn,
  launchAtStartupOff,
  checkBadge,
  openBrowser,
  project,
  rocket,
  target,
  flag,
  star,
  heart,
  diamond,
  crown,
  medal,
  fire,
  flash,
  leaf,
  globe,
  briefcase,
  book,
  bulb,
  puzzle,
  convert,
  brain,
  google,
  apple,
  bookmark,
  at,
}

extension VisirIconTypeX on VisirIconType {
  List<List<dynamic>> getIcon(bool isSelected) {
    switch (this) {
      case VisirIconType.home:
        return isSelected ? HugeIcons.solidRoundedHome03 : HugeIcons.strokeRoundedHome03;
      case VisirIconType.chat:
        return isSelected ? HugeIcons.solidRoundedChatting01 : HugeIcons.strokeRoundedChatting01;
      case VisirIconType.mail:
        return isSelected ? HugeIcons.solidRoundedMail01 : HugeIcons.strokeRoundedMail01;
      case VisirIconType.calendar:
        return isSelected ? HugeIcons.solidRoundedCalendar03 : HugeIcons.strokeRoundedCalendar03;
      case VisirIconType.inbox:
        return isSelected ? HugeIcons.solidRoundedInbox : HugeIcons.strokeRoundedInbox;
      case VisirIconType.task:
        return isSelected ? HugeIcons.solidRoundedCheckmarkCircle01 : HugeIcons.strokeRoundedCheckmarkCircle01;
      case VisirIconType.today:
        return isSelected ? HugeIcons.solidRoundedClock03 : HugeIcons.strokeRoundedClock03;
      case VisirIconType.one:
        return isSelected ? HugeIcons.solidRoundedOneSquare : HugeIcons.strokeRoundedOneSquare;
      case VisirIconType.two:
        return isSelected ? HugeIcons.solidRoundedTwoSquare : HugeIcons.strokeRoundedTwoSquare;
      case VisirIconType.three:
        return isSelected ? HugeIcons.solidRoundedThreeSquare : HugeIcons.strokeRoundedThreeSquare;
      case VisirIconType.four:
        return isSelected ? HugeIcons.solidRoundedFourSquare : HugeIcons.strokeRoundedFourSquare;
      case VisirIconType.five:
        return isSelected ? HugeIcons.solidRoundedFiveSquare : HugeIcons.strokeRoundedFiveSquare;
      case VisirIconType.six:
        return isSelected ? HugeIcons.solidRoundedSixSquare : HugeIcons.strokeRoundedSixSquare;
      case VisirIconType.seven:
        return isSelected ? HugeIcons.solidRoundedSevenSquare : HugeIcons.strokeRoundedSevenSquare;
      case VisirIconType.month:
        return isSelected ? HugeIcons.solidRoundedCalendar02 : HugeIcons.strokeRoundedCalendar02;
      case VisirIconType.networkUnavailable:
        return isSelected ? HugeIcons.solidRoundedWifiDisconnected01 : HugeIcons.strokeRoundedWifiDisconnected01;
      case VisirIconType.login:
        return isSelected ? HugeIcons.solidRoundedLogin01 : HugeIcons.strokeRoundedLogin01;
      case VisirIconType.logout:
        return isSelected ? HugeIcons.solidRoundedLogout01 : HugeIcons.strokeRoundedLogout01;
      case VisirIconType.arrowUp:
        return isSelected ? HugeIcons.solidRoundedArrowUp01 : HugeIcons.strokeRoundedArrowUp01;
      case VisirIconType.arrowDown:
        return isSelected ? HugeIcons.solidRoundedArrowDown01 : HugeIcons.strokeRoundedArrowDown01;
      case VisirIconType.arrowRight:
        return isSelected ? HugeIcons.solidRoundedArrowRight01 : HugeIcons.strokeRoundedArrowRight01;
      case VisirIconType.arrowLeft:
        return isSelected ? HugeIcons.solidRoundedArrowLeft01 : HugeIcons.strokeRoundedArrowLeft01;
      case VisirIconType.taskCheck:
        return isSelected ? HugeIcons.solidRoundedTick01 : HugeIcons.strokeRoundedTick01;
      case VisirIconType.check:
        return isSelected ? HugeIcons.solidRoundedTick02 : HugeIcons.strokeRoundedTick02;
      case VisirIconType.close:
        return isSelected ? HugeIcons.solidRoundedCancel01 : HugeIcons.strokeRoundedCancel01;
      case VisirIconType.videoCall:
        return isSelected ? HugeIcons.solidRoundedVideo02 : HugeIcons.strokeRoundedVideo02;
      case VisirIconType.videoCallOff:
        return isSelected ? HugeIcons.solidRoundedVideoOff : HugeIcons.strokeRoundedVideoOff;
      case VisirIconType.add:
        return isSelected ? HugeIcons.solidRoundedPlusSign : HugeIcons.strokeRoundedPlusSign;
      case VisirIconType.closeWithCircle:
        return isSelected ? HugeIcons.solidRoundedCancelCircle : HugeIcons.strokeRoundedCancelCircle;
      case VisirIconType.listSetting:
        return isSelected ? HugeIcons.solidRoundedListSetting : HugeIcons.strokeRoundedListSetting;
      case VisirIconType.clock:
        return isSelected ? HugeIcons.solidRoundedClock01 : HugeIcons.strokeRoundedClock01;
      case VisirIconType.copy:
        return isSelected ? HugeIcons.solidRoundedCopy01 : HugeIcons.strokeRoundedCopy01;
      case VisirIconType.trash:
        return isSelected ? HugeIcons.solidRoundedDelete02 : HugeIcons.strokeRoundedDelete02;
      case VisirIconType.location:
        return isSelected ? HugeIcons.solidRoundedLocation06 : HugeIcons.strokeRoundedLocation06;
      case VisirIconType.description:
        return isSelected ? HugeIcons.solidRoundedLicense : HugeIcons.strokeRoundedLicense;
      case VisirIconType.attendee:
        return isSelected ? HugeIcons.solidRoundedUserGroup : HugeIcons.strokeRoundedUserGroup;
      case VisirIconType.checkWithCircle:
        return isSelected ? HugeIcons.solidRoundedCheckmarkCircle02 : HugeIcons.strokeRoundedCheckmarkCircle02;
      case VisirIconType.helpWithCircle:
        return isSelected ? HugeIcons.solidRoundedHelpCircle : HugeIcons.strokeRoundedHelpCircle;
      case VisirIconType.unknownWithCircle:
        return isSelected ? HugeIcons.solidRoundedMoreHorizontalCircle02 : HugeIcons.strokeRoundedMoreHorizontalCircle02;
      case VisirIconType.notification:
        return isSelected ? HugeIcons.solidRoundedNotification01 : HugeIcons.strokeRoundedNotification01;
      case VisirIconType.notificationOff:
        return isSelected ? HugeIcons.solidRoundedNotificationOff01 : HugeIcons.strokeRoundedNotificationOff01;
      case VisirIconType.share:
        return isSelected ? HugeIcons.solidRoundedShare05 : HugeIcons.strokeRoundedShare05;
      case VisirIconType.profile:
        return isSelected ? HugeIcons.solidRoundedUser : HugeIcons.strokeRoundedUser;
      case VisirIconType.chatChannel:
        return isSelected ? HugeIcons.solidRoundedGrid : HugeIcons.strokeRoundedGrid;
      case VisirIconType.chatDm:
        return isSelected ? HugeIcons.solidRoundedBubbleChat : HugeIcons.strokeRoundedBubbleChat;
      case VisirIconType.chatGroupDm:
        return isSelected ? HugeIcons.solidRoundedMessageMultiple02 : HugeIcons.strokeRoundedMessageMultiple02;
      case VisirIconType.photo:
        return isSelected ? HugeIcons.solidRoundedImage02 : HugeIcons.strokeRoundedImage02;
      case VisirIconType.file:
        return isSelected ? HugeIcons.solidRoundedDocumentAttachment : HugeIcons.strokeRoundedDocumentAttachment;
      case VisirIconType.inboxIn:
        return isSelected ? HugeIcons.solidRoundedInboxDownload : HugeIcons.strokeRoundedInboxDownload;
      case VisirIconType.enter:
        return isSelected ? HugeIcons.solidRoundedLoginSquare01 : HugeIcons.strokeRoundedLoginSquare01;
      case VisirIconType.send:
        return isSelected ? HugeIcons.solidRoundedSent : HugeIcons.strokeRoundedSent;
      case VisirIconType.caution:
        return isSelected ? HugeIcons.solidRoundedAlert02 : HugeIcons.strokeRoundedAlert02;
      case VisirIconType.integration:
        return isSelected ? HugeIcons.solidRoundedLink01 : HugeIcons.strokeRoundedLink01;
      case VisirIconType.control:
        return HugeIcons.solidRoundedSettings04;
      case VisirIconType.search:
        return isSelected ? HugeIcons.solidRoundedSearch01 : HugeIcons.strokeRoundedSearch01;
      case VisirIconType.emoji:
        return isSelected ? HugeIcons.solidRoundedHappy01 : HugeIcons.strokeRoundedHappy01;
      case VisirIconType.more:
        return isSelected ? HugeIcons.solidRoundedMoreHorizontal : HugeIcons.strokeRoundedMoreHorizontal;
      case VisirIconType.thread:
        return isSelected ? HugeIcons.solidRoundedSquareArrowMoveLeftUp : HugeIcons.strokeRoundedSquareArrowMoveLeftUp;
      case VisirIconType.edit:
        return isSelected ? HugeIcons.solidRoundedEdit03 : HugeIcons.strokeRoundedEdit03;
      case VisirIconType.pause:
        return isSelected ? HugeIcons.solidRoundedPause : HugeIcons.strokeRoundedPause;
      case VisirIconType.play:
        return isSelected ? HugeIcons.solidRoundedPlay : HugeIcons.strokeRoundedPlay;
      case VisirIconType.download:
        return isSelected ? HugeIcons.solidRoundedDownload04 : HugeIcons.strokeRoundedDownload04;
      case VisirIconType.show:
        return isSelected ? HugeIcons.solidRoundedView : HugeIcons.strokeRoundedView;
      case VisirIconType.hide:
        return isSelected ? HugeIcons.solidRoundedViewOffSlash : HugeIcons.strokeRoundedViewOffSlash;
      case VisirIconType.soundOff:
        return isSelected ? HugeIcons.solidRoundedVolumeOff : HugeIcons.strokeRoundedVolumeOff;
      case VisirIconType.soundOn:
        return isSelected ? HugeIcons.solidRoundedVolumeHigh : HugeIcons.strokeRoundedVolumeHigh;
      case VisirIconType.refresh:
        return isSelected ? HugeIcons.solidRoundedRefresh : HugeIcons.strokeRoundedRefresh;
      case VisirIconType.list:
        return isSelected ? HugeIcons.solidRoundedMenu07 : HugeIcons.strokeRoundedMenu07;
      case VisirIconType.linkedTask:
        return isSelected ? HugeIcons.solidRoundedBookmarkCheck02 : HugeIcons.strokeRoundedBookmarkCheck02;
      case VisirIconType.pin:
        return isSelected ? HugeIcons.solidRoundedPin : HugeIcons.strokeRoundedPin;
      case VisirIconType.archive:
        return isSelected ? HugeIcons.solidRoundedArchive02 : HugeIcons.strokeRoundedArchive02;
      case VisirIconType.spam:
        return isSelected ? HugeIcons.solidRoundedSpam : HugeIcons.strokeRoundedSpam;
      case VisirIconType.reply:
        return isSelected ? HugeIcons.solidRoundedMailReply01 : HugeIcons.strokeRoundedMailReply01;
      case VisirIconType.replyAll:
        return isSelected ? HugeIcons.solidRoundedMailReplyAll01 : HugeIcons.strokeRoundedMailReplyAll01;
      case VisirIconType.forward:
        return isSelected ? HugeIcons.solidRoundedMailSend01 : HugeIcons.strokeRoundedMailSend01;
      case VisirIconType.outlink:
        return isSelected ? HugeIcons.solidRoundedPencilEdit02 : HugeIcons.strokeRoundedPencilEdit02;
      case VisirIconType.addWithCircle:
        return isSelected ? HugeIcons.solidRoundedAddCircle : HugeIcons.strokeRoundedAddCircle;
      case VisirIconType.subtractWithCircle:
        return isSelected ? HugeIcons.solidRoundedRemoveCircle : HugeIcons.strokeRoundedRemoveCircle;
      case VisirIconType.subscription:
        return isSelected ? HugeIcons.solidRoundedCreditCard : HugeIcons.strokeRoundedCreditCard;
      case VisirIconType.privacy:
        return isSelected ? HugeIcons.solidRoundedUserLock01 : HugeIcons.strokeRoundedUserLock01;
      case VisirIconType.settings:
        return isSelected ? HugeIcons.solidRoundedSettings01 : HugeIcons.strokeRoundedSettings01;
      case VisirIconType.trophy:
        return isSelected ? HugeIcons.solidRoundedChampion : HugeIcons.strokeRoundedChampion;
      case VisirIconType.sidebar:
        return isSelected ? HugeIcons.solidRoundedSidebarLeft01 : HugeIcons.strokeRoundedSidebarLeft01;
      case VisirIconType.repeat:
        return isSelected ? HugeIcons.solidRoundedRepeat : HugeIcons.strokeRoundedRepeat;
      case VisirIconType.infoWithCircle:
        return isSelected ? HugeIcons.solidRoundedInformationCircle : HugeIcons.strokeRoundedInformationCircle;
      case VisirIconType.pinOff:
        return isSelected ? HugeIcons.solidRoundedPinOff : HugeIcons.strokeRoundedPinOff;
      case VisirIconType.archiveOff:
        return isSelected ? HugeIcons.solidRoundedInbox : HugeIcons.strokeRoundedInbox;
      case VisirIconType.spamOff:
        return isSelected ? HugeIcons.solidRoundedInbox : HugeIcons.strokeRoundedInbox;
      case VisirIconType.trashOff:
        return isSelected ? HugeIcons.solidRoundedDeletePutBack : HugeIcons.strokeRoundedDeletePutBack;
      case VisirIconType.formatBold:
        return isSelected ? HugeIcons.solidRoundedTextBold : HugeIcons.strokeRoundedTextBold;
      case VisirIconType.formatItalic:
        return isSelected ? HugeIcons.solidRoundedTextItalic : HugeIcons.strokeRoundedTextItalic;
      case VisirIconType.formatStrikethrough:
        return isSelected ? HugeIcons.solidRoundedTextStrikethrough : HugeIcons.strokeRoundedTextStrikethrough;
      case VisirIconType.formatInlineCode:
        return isSelected ? HugeIcons.solidRoundedSourceCode : HugeIcons.strokeRoundedSourceCode;
      case VisirIconType.formatListNumbers:
        return isSelected ? HugeIcons.solidRoundedLeftToRightListNumber : HugeIcons.strokeRoundedLeftToRightListNumber;
      case VisirIconType.formatListBullets:
        return isSelected ? HugeIcons.solidRoundedLeftToRightListBullet : HugeIcons.strokeRoundedLeftToRightListBullet;
      case VisirIconType.formatCodeBlock:
        return isSelected ? HugeIcons.solidRoundedCodeSquare : HugeIcons.strokeRoundedCodeSquare;
      case VisirIconType.formatQuote:
        return isSelected ? HugeIcons.solidRoundedQuoteDown : HugeIcons.strokeRoundedQuoteDown;
      case VisirIconType.formatSize:
        return isSelected ? HugeIcons.solidRoundedTextSmallcaps : HugeIcons.strokeRoundedTextSmallcaps;
      case VisirIconType.formatColor:
        return isSelected ? HugeIcons.solidRoundedTextColor : HugeIcons.strokeRoundedTextColor;
      case VisirIconType.formatAlignLeft:
        return isSelected ? HugeIcons.solidRoundedTextAlignLeft : HugeIcons.strokeRoundedTextAlignLeft;
      case VisirIconType.formatAlignRight:
        return isSelected ? HugeIcons.solidRoundedTextAlignRight : HugeIcons.strokeRoundedTextAlignRight;
      case VisirIconType.formatAlignCenter:
        return isSelected ? HugeIcons.solidRoundedTextAlignCenter : HugeIcons.strokeRoundedTextAlignCenter;
      case VisirIconType.formatAlignJustify:
        return isSelected ? HugeIcons.solidRoundedTextAlignJustifyCenter : HugeIcons.strokeRoundedTextAlignJustifyCenter;
      case VisirIconType.signature:
        return isSelected ? HugeIcons.solidRoundedSignature : HugeIcons.strokeRoundedSignature;
      case VisirIconType.formatUnderline:
        return isSelected ? HugeIcons.solidRoundedTextUnderline : HugeIcons.strokeRoundedTextUnderline;
      case VisirIconType.formatIndentIncrease:
        return isSelected ? HugeIcons.solidRoundedTextIndentMore : HugeIcons.strokeRoundedTextIndentMore;
      case VisirIconType.formatIndentDecrease:
        return isSelected ? HugeIcons.solidRoundedTextIndentLess : HugeIcons.strokeRoundedTextIndentLess;
      case VisirIconType.calendarBefore:
        return isSelected ? HugeIcons.solidRoundedArrowLeftDouble : HugeIcons.strokeRoundedArrowLeftDouble;
      case VisirIconType.calendarAfter:
        return isSelected ? HugeIcons.solidRoundedArrowRightDouble : HugeIcons.strokeRoundedArrowRightDouble;
      case VisirIconType.agent:
        return isSelected ? HugeIcons.solidRoundedAiMagic : HugeIcons.strokeRoundedAiMagic;
      case VisirIconType.manual:
        return isSelected ? HugeIcons.solidRoundedRotateRight02 : HugeIcons.strokeRoundedRotateRight02;
      case VisirIconType.dark:
        return isSelected ? HugeIcons.solidRoundedMoon02 : HugeIcons.strokeRoundedMoon02;
      case VisirIconType.light:
        return isSelected ? HugeIcons.solidRoundedSun02 : HugeIcons.strokeRoundedSun02;
      case VisirIconType.terms:
        return isSelected ? HugeIcons.solidRoundedDocumentValidation : HugeIcons.strokeRoundedDocumentValidation;
      case VisirIconType.subtract:
        return isSelected ? HugeIcons.solidRoundedMinusSign : HugeIcons.strokeRoundedMinusSign;
      case VisirIconType.emptyCircle:
        return isSelected ? HugeIcons.solidRoundedDashedLineCircle : HugeIcons.strokeRoundedDashedLineCircle;
      case VisirIconType.dollar:
        return isSelected ? HugeIcons.solidRoundedSaveMoneyDollar : HugeIcons.strokeRoundedSaveMoneyDollar;
      case VisirIconType.converted:
        return isSelected ? HugeIcons.solidRoundedArrowRight04 : HugeIcons.strokeRoundedArrowRight04;
      case VisirIconType.hideSidebar:
        return isSelected ? HugeIcons.solidRoundedArrowRight05 : HugeIcons.strokeRoundedArrowRight05;
      case VisirIconType.showSidebar:
        return isSelected ? HugeIcons.solidRoundedArrowLeft05 : HugeIcons.strokeRoundedArrowLeft05;
      case VisirIconType.badgeOn:
        return isSelected ? HugeIcons.solidRoundedNotificationSquare : HugeIcons.strokeRoundedNotificationSquare;
      case VisirIconType.badgeOff:
        return isSelected ? HugeIcons.solidRoundedEqualSignSquare : HugeIcons.strokeRoundedEqualSignSquare;
      case VisirIconType.launchAtStartupOn:
        return isSelected ? HugeIcons.solidRoundedLaptopCheck : HugeIcons.strokeRoundedLaptopCheck;
      case VisirIconType.launchAtStartupOff:
        return isSelected ? HugeIcons.solidRoundedLaptopRemove : HugeIcons.strokeRoundedLaptopRemove;
      case VisirIconType.checkBadge:
        return isSelected ? HugeIcons.solidRoundedCheckmarkBadge02 : HugeIcons.strokeRoundedCheckmarkBadge02;
      case VisirIconType.openBrowser:
        return isSelected ? HugeIcons.solidRoundedLinkCircle : HugeIcons.strokeRoundedLinkCircle;
      case VisirIconType.project:
        return isSelected ? HugeIcons.solidRoundedFolder01 : HugeIcons.strokeRoundedFolder01;
      case VisirIconType.rocket:
        return isSelected ? HugeIcons.solidRoundedRocket01 : HugeIcons.strokeRoundedRocket01;
      case VisirIconType.target:
        return isSelected ? HugeIcons.solidRoundedTarget01 : HugeIcons.strokeRoundedTarget01;
      case VisirIconType.flag:
        return isSelected ? HugeIcons.solidRoundedFlag01 : HugeIcons.strokeRoundedFlag01;
      case VisirIconType.star:
        return isSelected ? HugeIcons.solidRoundedStar : HugeIcons.strokeRoundedStar;
      case VisirIconType.heart:
        return isSelected ? HugeIcons.solidRoundedFavourite : HugeIcons.strokeRoundedFavourite;
      case VisirIconType.diamond:
        return isSelected ? HugeIcons.solidRoundedDiamond01 : HugeIcons.strokeRoundedDiamond01;
      case VisirIconType.crown:
        return isSelected ? HugeIcons.solidRoundedCrown : HugeIcons.strokeRoundedCrown;
      case VisirIconType.medal:
        return isSelected ? HugeIcons.solidRoundedMedalFirstPlace : HugeIcons.strokeRoundedMedalFirstPlace;
      case VisirIconType.fire:
        return isSelected ? HugeIcons.solidRoundedFire : HugeIcons.strokeRoundedFire;
      case VisirIconType.flash:
        return isSelected ? HugeIcons.solidRoundedFlash : HugeIcons.strokeRoundedFlash;
      case VisirIconType.leaf:
        return isSelected ? HugeIcons.solidRoundedLeaf01 : HugeIcons.strokeRoundedLeaf01;
      case VisirIconType.globe:
        return isSelected ? HugeIcons.solidRoundedGlobe02 : HugeIcons.strokeRoundedGlobe02;
      case VisirIconType.briefcase:
        return isSelected ? HugeIcons.solidRoundedBriefcase01 : HugeIcons.strokeRoundedBriefcase01;
      case VisirIconType.book:
        return isSelected ? HugeIcons.solidRoundedBook01 : HugeIcons.strokeRoundedBook01;
      case VisirIconType.bulb:
        return isSelected ? HugeIcons.solidRoundedBulb : HugeIcons.strokeRoundedBulb;
      case VisirIconType.puzzle:
        return isSelected ? HugeIcons.solidRoundedPuzzle : HugeIcons.strokeRoundedPuzzle;
      case VisirIconType.convert:
        return isSelected ? HugeIcons.solidRoundedArrowRight04 : HugeIcons.strokeRoundedArrowRight04;
      case VisirIconType.brain:
        return isSelected ? HugeIcons.solidRoundedBrain : HugeIcons.strokeRoundedBrain;
      case VisirIconType.google:
        // Google 브랜드 로고는 Image.asset으로 처리되므로 여기서는 사용되지 않음
        return HugeIcons.strokeRoundedGlobe02;
      case VisirIconType.apple:
        // Apple 브랜드 로고는 Image.asset으로 처리되므로 여기서는 사용되지 않음
        return HugeIcons.strokeRoundedApple;
      case VisirIconType.bookmark:
        return isSelected ? HugeIcons.solidRoundedBookBookmark02 : HugeIcons.strokeRoundedBookBookmark02;
      case VisirIconType.at:
        return isSelected ? HugeIcons.solidRoundedAt : HugeIcons.strokeRoundedAt;
    }
  }
}

class VisirIcon extends StatelessWidget {
  final VisirIconType type;
  final double size;
  final Color? color;
  final bool? isSelected;

  static Color disabledColor(BuildContext context) => context.isDarkMode ? context.inverseSurface : context.surfaceTint;

  const VisirIcon({super.key, required this.type, this.color, required this.size, this.isSelected});

  @override
  Widget build(BuildContext context) {
    return HugeIcon(
      icon: type.getIcon(isSelected == null ? false : isSelected!),
      color: color ?? (isSelected != false ? context.outlineVariant : disabledColor(context)),
      size: size,
      strokeWidth: type == VisirIconType.taskCheck ? 5 : null,
    );
  }
}
