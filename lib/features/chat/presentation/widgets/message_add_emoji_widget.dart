import 'package:Visir/config/providers.dart';
import 'package:Visir/features/chat/actions.dart';
import 'package:Visir/features/common/provider.dart';
import 'package:Visir/features/chat/application/chat_channel_list_controller.dart';
import 'package:Visir/features/chat/domain/entities/emoji_category_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_channel_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_emoji_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_entity.dart';
import 'package:Visir/features/chat/domain/entities/message_reaction_entity.dart';
import 'package:Visir/features/common/presentation/utils/extensions/platform_extension.dart';
import 'package:Visir/features/common/presentation/utils/extensions/ui_extension.dart';
import 'package:Visir/features/common/presentation/utils/utils.dart';
import 'package:Visir/features/common/presentation/widgets/proxy_network_image.dart';
import 'package:Visir/features/common/presentation/widgets/visir_button.dart';
import 'package:Visir/features/common/presentation/widgets/visir_icon.dart';
import 'package:Visir/features/preference/application/local_pref_controller.dart';
import 'package:Visir/features/preference/domain/entities/oauth_entity.dart';
import 'package:emoji_extension/emoji_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MessageAddEmojiWidget extends ConsumerStatefulWidget {
  final MessageChannelEntity channel;
  final MessageEntity message;
  final OAuthEntity? oauth;

  final MessageEntity? parentMessage;

  bool get isReply => parentMessage != null;

  final TabType tabType;

  const MessageAddEmojiWidget({required this.channel, required this.message, required this.tabType, required this.oauth, this.parentMessage});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessageAddEmojiWidgetState();
}

class _MessageAddEmojiWidgetState extends ConsumerState<MessageAddEmojiWidget> {
  List<MessageReactionEntity> get reactions => widget.message.reactions;

  bool get isMobileView => PlatformX.isMobileView;

  late TextEditingController searchController;

  ValueNotifier<int> currentEmojiCategoryIndexNotifier = ValueNotifier(0);

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  late List<EmojiCategoryEntity> emojiCategories;

  List<Emoji> get availableEmojis => emojiCategories.map((e) => e.emojis).toList().expand((e) => e ?? []).whereType<Emoji>().toList();

  List<MessageEmojiEntity> customEmojis = [];

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController(text: null);
    itemPositionsListener.itemPositions.addListener(() {
      currentEmojiCategoryIndexNotifier.value = itemPositionsListener.itemPositions.value.first.index;
    });

    emojiCategories = Utils.getEmojiCategories([]);
  }

  @override
  void dispose() {
    searchController.dispose();
    currentEmojiCategoryIndexNotifier.dispose();
    super.dispose();
  }

  bool isUserReacted(String name) {
    MessageReactionEntity? reaction = reactions.firstWhereOrNull((e) => e.name == name);
    return reaction?.users.contains(widget.channel.meId) ?? false;
  }

  Future<void> addEmoji(Emoji e) async {
    String emojiName = e.slackShortcode?.substring(1, e.slackShortcode!.length - 1) ?? '';

    context.pop();

    if (!isUserReacted(emojiName)) {
      if (widget.isReply) {
        MessageAction.addReplyReaction(
          tabType: widget.tabType,
          message: widget.message,
          emoji: emojiName,
          userId: widget.channel.meId,
          channel: widget.channel,
          parent: widget.parentMessage!,
        );
      } else {
        MessageAction.addReaction(tabType: widget.tabType, message: widget.message, emoji: emojiName, userId: widget.channel.meId, channel: widget.channel);
      }
    }
  }

  Future<void> addCustomEmoji(MessageEmojiEntity e) async {
    context.pop();

    if (!isUserReacted(e.name ?? '')) {
      if (widget.isReply) {
        MessageAction.addReplyReaction(
          tabType: widget.tabType,
          message: widget.message,
          emoji: e.name!,
          userId: widget.channel.meId,
          channel: widget.channel,
          parent: widget.parentMessage!,
        );
      } else {
        MessageAction.addReaction(tabType: widget.tabType, message: widget.message, emoji: e.name!, userId: widget.channel.meId, channel: widget.channel);
      }
    }
  }

  Widget categoryButton({required EmojiCategoryEntity category, required int index}) {
    return ValueListenableBuilder<int>(
      valueListenable: currentEmojiCategoryIndexNotifier,
      builder: (context, value, child) {
        bool isCurrent = (index == value && searchController.text.isEmpty);
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Material(
            color: Colors.transparent,
            child: VisirButton(
              type: VisirButtonAnimationType.scaleAndOpacity,
              style: VisirButtonStyle(cursor: WidgetStateMouseCursor.clickable, padding: const EdgeInsets.all(4)),
              onTap: () {
                if (searchController.text.isEmpty) {
                  itemScrollController.scrollTo(index: index, duration: Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
                }
              },
              child: Icon(category.icon, size: 20, color: isCurrent ? context.outlineVariant : context.surfaceTint),
            ),
          ),
        );
      },
    );
  }

  Widget EmojiButton({required Future<void> Function() onTap, required Widget child}) {
    return VisirButton(
      type: VisirButtonAnimationType.scaleAndOpacity,
      style: VisirButtonStyle(
        cursor: WidgetStateMouseCursor.clickable,
        borderRadius: BorderRadius.circular(6),
        height: 32,
        width: 32,
        padding: EdgeInsets.symmetric(horizontal: PlatformX.isWindows ? 0 : 4, vertical: PlatformX.isWindows ? 2 : 4),
      ),
      onTap: onTap,
      child: Container(child: child),
    );
  }

  Widget categoryEmojiList({required EmojiCategoryEntity category, required List<String> frequentlyUsedEmojiIds, required bool isMobileView}) {
    List<Widget> emojiButtons = [];

    if (frequentlyUsedEmojiIds.isEmpty) {
      if (category.emojis != null) {
        emojiButtons.addAll(
          category.emojis!
              .map(
                (e) => EmojiButton(
                  onTap: () async {
                    addEmoji(e);
                  },
                  child: Text(e.value, style: context.headlineMedium?.copyWith(height: 1).textColor(context.outlineVariant)),
                ),
              )
              .toList(),
        );
      }
      if (category.customEmojis != null) {
        emojiButtons.addAll(
          category.customEmojis!.map((e) {
            bool isAlias = e.isAlias;
            MessageEmojiEntity? originalCustomEmoji = isAlias ? category.customEmojis?.firstWhereOrNull((emoji) => emoji.name == e.aliasOriginalName) : null;
            Emoji? originalEmoji = isAlias ? Emojis.getOneOrNull(e.aliasOriginalName ?? '') : null;

            return EmojiButton(
              onTap: () => addCustomEmoji(e),
              child: originalEmoji == null
                  ? ProxyNetworkImage(
                      imageUrl: isAlias ? originalCustomEmoji?.url ?? '' : e.url ?? '',
                      oauth: widget.oauth,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, object) {
                        return const SizedBox.shrink();
                      },
                    )
                  : Text(originalEmoji.value, style: context.headlineMedium?.copyWith(height: 1).textColor(context.outlineVariant)),
            );
          }).toList(),
        );
      }
    } else {
      emojiButtons.addAll(
        frequentlyUsedEmojiIds.map((id) {
          if (customEmojis.map((e) => e.name).toList().contains(id)) {
            final _emoji = customEmojis.where((e) => e.name == id).firstOrNull;
            if (_emoji == null) return const SizedBox.shrink();

            bool isAlias = _emoji.isAlias;
            MessageEmojiEntity? originalCustomEmoji = isAlias ? customEmojis.firstWhereOrNull((emoji) => emoji.name == _emoji.aliasOriginalName) : null;
            Emoji? originalEmoji = isAlias ? Emojis.getOneOrNull(_emoji.aliasOriginalName ?? '') : null;

            return EmojiButton(
              onTap: () => addCustomEmoji(_emoji),
              child: originalEmoji == null
                  ? ProxyNetworkImage(
                      imageUrl: isAlias ? originalCustomEmoji?.url ?? '' : _emoji.url ?? '',
                      oauth: widget.oauth,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, object) => const SizedBox.shrink(),
                    )
                  : Text(originalEmoji.value, style: context.headlineMedium?.copyWith(height: 1).textColor(context.outlineVariant)),
            );
          } else {
            final _emoji = Emojis.getOneOrNull(id);
            if (_emoji == null) return const SizedBox.shrink();
            return EmojiButton(
              onTap: () => addEmoji(_emoji),
              child: Text(_emoji.value, style: context.headlineMedium?.copyWith(height: 1).textColor(context.outlineVariant)),
            );
          }
        }).toList(),
      );
    }

    return emojiButtons.isEmpty
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              const SizedBox(height: 12),
              Text(category.name, style: context.bodyLarge?.textBold.textColor(context.outlineVariant)),
              const SizedBox(height: 8),
              GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 9, mainAxisSpacing: 6, crossAxisSpacing: 6),
                itemCount: emojiButtons.length,
                shrinkWrap: true,
                itemBuilder: (context, index) => emojiButtons[index],
                padding: EdgeInsets.zero,
              ),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    List<String> frequentlyUsedEmojiIds = ref.watch(frequentlyUsedEmojiIdsProvider);
    double widgetWidth = isMobileView ? MediaQuery.of(context).size.width : 358;
    customEmojis = ref.read(chatChannelListControllerProvider.select((v) => v[widget.channel.teamId]?.emojis ?? []));
    emojiCategories = Utils.getEmojiCategories(customEmojis);

    return Material(
      child: Container(
        width: widgetWidth,
        height: 420,
        decoration: ShapeDecoration(
          color: context.surface,
          shape: RoundedRectangleBorder(
            borderRadius: isMobileView ? BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)) : BorderRadius.circular(12),
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                if (isMobileView)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: ShapeDecoration(
                        color: context.surfaceVariant,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.50)),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Container(
                    height: 28,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: emojiCategories.map((e) => categoryButton(category: e, index: emojiCategories.indexOf(e))).toList(),
                    ),
                  ),
                ),
                Container(
                  width: widgetWidth,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 0.5, strokeAlign: BorderSide.strokeAlignCenter, color: context.surface),
                    ),
                  ),
                ),
                SizedBox(height: 32 + 12 - 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    width: double.maxFinite,
                    child: searchController.text.isEmpty
                        ? ScrollablePositionedList.builder(
                            shrinkWrap: true,
                            itemCount: emojiCategories.length,
                            itemScrollController: itemScrollController,
                            itemPositionsListener: itemPositionsListener,
                            itemBuilder: (context, index) {
                              return categoryEmojiList(
                                category: emojiCategories[index],
                                frequentlyUsedEmojiIds: index == 0 ? frequentlyUsedEmojiIds : [],
                                isMobileView: isMobileView,
                              );
                            },
                          )
                        : SingleChildScrollView(
                            child: categoryEmojiList(
                              category: EmojiCategoryEntity(
                                icon: Icons.search,
                                name: context.tr.chat_emoji_search_result,
                                emojis: availableEmojis.where((e) => e.name.toLowerCase().contains(searchController.text.toLowerCase())).toList(),
                                customEmojis: customEmojis.where((e) => (e.name ?? '').toLowerCase().contains(searchController.text.toLowerCase())).toList(),
                              ),
                              frequentlyUsedEmojiIds: [],
                              isMobileView: isMobileView,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            Transform.translate(
              offset: Offset(12, 44 + 12),
              child: SizedBox(
                height: 32,
                width: MediaQueryData.fromView(View.of(context)).size.width - 24,
                child: TextFormField(
                  controller: searchController,
                  style: context.bodyLarge?.textColor(context.outlineVariant),
                  textAlignVertical: TextAlignVertical.center,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(width: 0, style: BorderStyle.none),
                    ),
                    hintText: context.tr.chat_search_emoji,
                    hintStyle: context.bodyLarge?.textColor(context.surfaceTint),
                    contentPadding: EdgeInsets.zero,
                    isCollapsed: true,
                    fillColor: context.surfaceVariant,
                    hoverColor: Colors.transparent,
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
                      child: VisirIcon(type: VisirIconType.search, size: 14, isSelected: searchController.text.isNotEmpty),
                    ),
                    prefixIconConstraints: BoxConstraints(minWidth: 56, maxWidth: 56),
                    suffixIcon: searchController.text.isEmpty
                        ? null
                        : IntrinsicWidth(
                            child: VisirButton(
                              type: VisirButtonAnimationType.scaleAndOpacity,
                              onTap: () {
                                searchController.clear();
                                setState(() {});
                              },
                              style: VisirButtonStyle(padding: const EdgeInsets.all(6), hoverColor: Colors.transparent),
                              child: VisirIcon(type: VisirIconType.closeWithCircle, size: 14, color: context.outlineVariant),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
