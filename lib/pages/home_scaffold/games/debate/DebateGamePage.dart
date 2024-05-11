// DebateGamePage.dart

import 'package:chat/chatroom/chatroom.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/models/game_models/debate.dart';
import 'package:chat/services/conversation_database.dart';
import 'package:flutter/material.dart';

class DebateGamePage extends StatefulWidget {
  Conversation? conversation;
  ValueNotifier<List<Conversation>> conversations;
  DebateGamePage({this.conversation, required this.conversations, super.key});

  @override
  State<DebateGamePage> createState() => _DebateGamePageState();
}

class _DebateGamePageState extends State<DebateGamePage> {
  ChatRoomPage? chatRoomPage;

  @override
  void initState() {
    debugPrint("\t[ Debate :: GamePage initState ]");

    if (widget.conversation!.gameModel == null ||
        widget.conversation!.gameModel.topic.isEmpty) {
      Future.delayed(const Duration(milliseconds: 400), () async {
        String topic = await getGameSettings(context);
        if (topic.isNotEmpty) {
          widget.conversation!.gameModel = DebateGame(topic: topic);
          setState(() {});
        }
      });
    }
    super.initState();
  }

  Future<String> getGameSettings(BuildContext context) async {
    TextEditingController topicController = TextEditingController();
    debugPrint("\t[ Debate :: Get Game Settings ]");

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Say Something Contentious 😏"),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: TextField(
              maxLines: 6,
              minLines: 1,
              controller: topicController,
              decoration: const InputDecoration(hintText: "Enter topic"),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );

    // Now you can use _topicController.text to get the entered topic
    debugPrint("\t\t[ Debate Topic: ${topicController.text} ]");

    return topicController.text;
  }

  String getTopicText(Conversation? conversation) {
    if (conversation != null) {
      if (conversation.gameModel != null) {
        return conversation.gameModel.topic ?? "";
      }
    }
    return "insert topic";
  }

  @override
  Widget build(BuildContext context) {
    chatRoomPage = ChatRoomPage(
      gameType: GameType.debate,
      key: widget.conversation != null
          ? Key(widget.conversation!.id)
          : Key(DateTime.now().toIso8601String()),
      conversation: widget.conversation,
      showModelSelectButton: false,
      showTopTitle: true,
      topTitleHeading: "Topic:",
      topTitleText: getTopicText(widget.conversation),
      onCreateNewConversation: (Conversation conv) async {
        debugPrint("\t[ Debate Create New Conversation ]");
        await ConversationDatabase.instance.create(conv);
        widget.conversations.value.insert(0, conv);
        widget.conversations.notifyListeners();
      },
      onNewText: (Conversation lastMessageUpdate) async {
        // update the lastMessage sent
        await ConversationDatabase.instance.update(lastMessageUpdate);
        int idx = widget.conversations.value
            .indexWhere((element) => element.id == lastMessageUpdate.id);
        widget.conversations.value[idx] = lastMessageUpdate;
        widget.conversations.value.sort((a, b) {
          return b.time!.compareTo(a.time!);
        });
        widget.conversations.notifyListeners();
      },
    );

    return chatRoomPage!;
  }
}
