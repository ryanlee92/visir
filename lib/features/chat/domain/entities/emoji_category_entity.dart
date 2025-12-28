import 'package:Visir/features/chat/domain/entities/message_emoji_entity.dart';
import 'package:emoji_extension/emoji_extension.dart';
import 'package:flutter/material.dart';

class EmojiCategoryEntity {
  IconData icon;
  String name;
  List<Emoji>? emojis;
  List<MessageEmojiEntity>? customEmojis;

  EmojiCategoryEntity({required this.icon, required this.name, this.emojis, this.customEmojis});
}
