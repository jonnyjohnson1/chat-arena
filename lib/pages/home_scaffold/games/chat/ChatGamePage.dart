import 'package:chat/chatroom/chatroom.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/services/conversation_database.dart';
import 'package:flutter/material.dart';

class ChatGamePage extends StatefulWidget {
  Conversation? conversation;
  ValueNotifier<List<Conversation>> conversations;
  ChatGamePage({this.conversation, required this.conversations, super.key});

  @override
  State<ChatGamePage> createState() => _ChatGamePageState();
}

class _ChatGamePageState extends State<ChatGamePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChatRoomPage(
      key: widget.conversation != null
          ? Key(widget.conversation!.id)
          : Key(DateTime.now().toIso8601String()),
      conversation: widget.conversation,
      showModelSelectButton: true,
      showTopTitle: false,
      onCreateNewConversation: (Conversation conv) async {
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
  }
}
