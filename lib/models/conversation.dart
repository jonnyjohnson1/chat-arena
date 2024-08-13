import 'package:chat/models/conversation_analytics.dart';
import 'package:chat/models/conversation_summary.dart';
import 'package:chat/models/custom_file.dart';
import 'package:chat/models/messages.dart';
import 'package:chat/theming/theming_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const String tableConversations = 'conversations';

class ConversationFields {
  static const List<String> values = [
    id,
    title,
    lastMessage,
    primaryModel,
    time,
    gameType
  ];

  static const String id = '_id';
  static const String title = 'title';
  static const String lastMessage = 'lastMessage';
  static const String image = 'image';
  static const String primaryModel = 'primaryModel';
  static const String time = 'time';
  static const String gameType = 'gameType';
}

enum GameType { chat, debate, p2pchat, play }

class Conversation {
  String? title;
  String? lastMessage;
  String? image;
  DateTime? time;
  String? primaryModel;
  String id;
  GameType? gameType;
  dynamic gameModel;
  Map<String, dynamic>? gameSettings;
  ValueNotifier<ConversationData?> conversationAnalytics;
  ValueNotifier<List<ImageFile>> convToImagesList;
  ValueNotifier<List<Message>> metaConvMessages;
  ValueNotifier<List<ConversationSummary>> convSummaryMessages;
  Map<String, dynamic>? gameAnalytics;

  Conversation(
      {this.title,
      this.lastMessage,
      this.image,
      this.primaryModel,
      this.time,
      this.gameType,
      this.gameModel,
      this.gameSettings,
      this.gameAnalytics,
      required this.id})
      : conversationAnalytics = ValueNotifier<ConversationData?>(null),
        convToImagesList = ValueNotifier<List<ImageFile>>([]),
        metaConvMessages = ValueNotifier<List<Message>>([]),
        convSummaryMessages = ValueNotifier<List<ConversationSummary>>([]);

  // Convert the Conversation instance to a Map
  Map<String, dynamic> toMap() {
    return {
      ConversationFields.id: id,
      ConversationFields.title: title,
      ConversationFields.lastMessage: lastMessage,
      ConversationFields.image: image,
      ConversationFields.time: time?.toIso8601String(),
      ConversationFields.primaryModel: primaryModel,
      ConversationFields.gameType: gameTypeToString(gameType)
    };
  }

  // Create a Conversation instance from a Map
  factory Conversation.fromMap(Map<String, dynamic> map) {
    GameType gameType = GameType.chat; // sets chat as default
    if (map['gameType'] == 'chat') {
      gameType = GameType.chat;
    } else if (map['gameType'] == 'debate') {
      gameType = GameType.debate;
    } else if (map['gameType'] == 'p2pchat') {
      gameType = GameType.p2pchat;
    }

    return Conversation(
      title: map['title'],
      lastMessage: map['lastMessage'],
      image: map['image'],
      time: map['time'] != null ? DateTime.parse(map['time']) : null,
      primaryModel: map['primaryModel'],
      id: map['_id'],
      gameType: gameType,
    );
  }

  static Conversation fromJson(Map<String, Object?> json) {
    GameType gameType = GameType.chat; // sets chat as default
    if (json[ConversationFields.gameType] == 'chat') {
      gameType = GameType.chat;
    } else if (json[ConversationFields.gameType] == 'debate') {
      gameType = GameType.debate;
    } else if (json[ConversationFields.gameType] == 'p2pchat') {
      gameType = GameType.p2pchat;
    }
    return Conversation(
        id: json[ConversationFields.id] as String,
        title: json[ConversationFields.title] as String?,
        lastMessage: json[ConversationFields.lastMessage] as String?,
        image: json[ConversationFields.image] as String?,
        time: json[ConversationFields.time] != null
            ? DateTime.parse(json[ConversationFields.time] as String)
            : null,
        primaryModel: json[ConversationFields.primaryModel] as String?,
        gameType: gameType);
  }

  // String toJson() => json.encode(toMap());

  // factory Conversation.fromJson(String source) =>
  //     Conversation.fromMap(json.decode(source));

  @override
  String toString() =>
      'Conversation(id: $id, time: $time, title: $title, lastMessage: $lastMessage)';

  String gameTypeToString(GameType? gameType) {
    switch (gameType) {
      case GameType.chat:
        return 'chat';
      case GameType.debate:
        return 'debate';
      case GameType.p2pchat:
        return 'p2pchat';
      default:
        return '';
    }
  }

  Icon gameTypeToIcon(GameType? gameType, {double? size}) {
    switch (gameType) {
      case GameType.chat:
        return Icon(CupertinoIcons.chat_bubble_text_fill,
            size: size, color: debateIconColor);
      case GameType.debate:
        return Icon(CupertinoIcons.group_solid,
            size: size, color: chatBubbleColor);
      case GameType.p2pchat:
        return Icon(CupertinoIcons.person_2_fill,
            size: size, color: personIconColor);
      default:
        return Icon(Icons.help_outline);
    }
  }

  GameType? stringToGameType(String? gameTypeString) {
    switch (gameTypeString) {
      case 'chat':
        return GameType.chat;
      case 'debate':
        return GameType.debate;
      case 'p2pchat':
        return GameType.p2pchat;
      default:
        return null;
    }
  }
}
