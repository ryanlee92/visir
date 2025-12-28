import 'package:Visir/features/chat/domain/entities/message_reaction_entity.dart';
import 'package:Visir/features/chat/domain/entities/slack/slack_search_message_entity.dart';
import 'package:flutter/foundation.dart';

enum SearchMessageEntityType {
  slack,
}

extension SearchMessageEntityTypeX on SearchMessageEntityType {
  String get icon {
    switch (this) {
      case SearchMessageEntityType.slack:
        return '${(kDebugMode && kIsWeb) ? "" : "assets/"}logos/logo_slack.png';
    }
  }
}

class SearchMessageEntity {
  //for slack
  final SlackSearchMessageEntity? _slackMessage;

  //common
  final SearchMessageEntityType type;

  SlackSearchMessageEntity? get slackMessage => _slackMessage;

  SearchMessageEntity.fromSlack({required SlackSearchMessageEntity message})
      : _slackMessage = message,
        type = SearchMessageEntityType.slack;

  factory SearchMessageEntity.fromJson(Map<String, dynamic> json) {
    SearchMessageEntityType messageType = SearchMessageEntityType.values.firstWhere(
          (e) => e.name == json['type'],
      orElse: () => SearchMessageEntityType.slack,
    );

    switch (messageType) {
      case SearchMessageEntityType.slack:
        return SearchMessageEntity.fromSlack(
          message: SlackSearchMessageEntity.fromJson(json['_slackMessage']),
        );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type.name,
      "_slackMessage": _slackMessage?.toJson(),
    };
  }

  SearchMessageEntity copyWith({
    List<MessageReactionEntity>? reactions,
    int? replyCount,
    String? latestReply,
    int? replyUsersCount,
    List<String>? replyUsers,
  }) {
    switch (type) {
      case SearchMessageEntityType.slack:
        return SearchMessageEntity.fromSlack(
          message: _slackMessage!,
        );
    }
  }

  // int? get replyUsersCount {
  //   switch (type) {
  //     case SearchMessageEntityType.slack:
  //       return _slackMessage?.replyUsersCount;
  //   }
  // }

  String? get id {
    switch (type) {
      case SearchMessageEntityType.slack:
        return _slackMessage?.ts;
    }
  }

  String? get text {
    switch (type) {
      case SearchMessageEntityType.slack:
        return _slackMessage?.text;
    }
  }

  String? get userId {
    switch (type) {
      case SearchMessageEntityType.slack:
        return _slackMessage?.user;
    }
  }

  String? get team {
    switch (type) {
      case SearchMessageEntityType.slack:
        return _slackMessage?.team;
    }
  }

  DateTime? get createdAt {
    switch (type) {
      case SearchMessageEntityType.slack:
        return _slackMessage?.ts == null ? null : DateTime.fromMicrosecondsSinceEpoch((double.tryParse(_slackMessage!.ts!)! * 1000000).toInt());
    }
  }
}
