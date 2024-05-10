import 'package:chat/chatroom/chatroom.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/models/event_channel_model.dart';
import 'package:chat/models/llm.dart';
import 'package:chat/services/conversation_database.dart';
import 'package:chat/services/local_llm_interface.dart';
import 'package:chat/services/tools.dart';
import 'package:flutter/material.dart';
import 'package:chat/models/messages.dart' as uiMessage;

class ChatGamePage extends StatefulWidget {
  Conversation? conversation;
  ValueNotifier<List<Conversation>> conversations;
  ChatGamePage({this.conversation, required this.conversations, super.key});

  @override
  State<ChatGamePage> createState() => _ChatGamePageState();
}

class _ChatGamePageState extends State<ChatGamePage> {
  bool isLoading = true;
  late List<uiMessage.Message> messages = [];

  ModelConfig selectedModel = ModelConfig(
      model: const LanguageModel(
          model: 'dolphin-llama3', name: "dolphin-llama3", size: 21314),
      temperature: 0.06,
      numGenerations: 1);

  Future<void> initData() async {
    if (widget.conversation != null) {
      try {
        messages = await ConversationDatabase.instance
            .readAllMessages(widget.conversation!.id);
      } catch (e) {
        print(e);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  String generatedChat = "";
  double progress = 0.0;
  double toksPerSec = 0.0;
  double completionTime = 0.0;
  int currentIdx = 0;
  ValueNotifier<bool> isGenerating = ValueNotifier(false);

  generationCallback(Map<String, dynamic>? event) {
    if (event != null) {
      double completionTime = 0.0;
      double progress = 0.0;

      EventGenerationResponse response = EventGenerationResponse.fromMap(event);

      generatedChat = response.generation;
      if (response.isCompleted) {
        print("chat completed");
        // end token is received
        isGenerating.value = false;
        messages[currentIdx].isGenerating = false;
        completionTime = response.completionTime;
        messages[currentIdx].completionTime = completionTime;
        isGenerating.notifyListeners();

        setState(() {});
        // add the final message to the database
        ConversationDatabase.instance.createMessage(messages[currentIdx]);
      } else {
        toksPerSec = response.toksPerSec;
        while (generatedChat.startsWith("\n")) {
          generatedChat = generatedChat.substring(2);
        }
        completionTime = response.completionTime;
        try {
          messages[currentIdx].message!.value = generatedChat;
          messages[currentIdx].completionTime = completionTime;
          messages[currentIdx].isGenerating = true;
          messages[currentIdx].toksPerSec = toksPerSec;

          // Notify the value listeners
          messages[currentIdx].message!.notifyListeners();
        } catch (e) {
          print(
              "Error updating message with the latest result: ${e.toString()}");
          print("The generation was: $generatedChat");
        }
        // setState(() {});
      }
    } else {
      // return null event generation
      // return const EventGenerationResponse(generation: "", progress: 0.0);
    }
  }

  void sendMessagetoModel(String text) async {
    print("Submitting: $text to chat model");
    currentIdx = messages.length;
    // // Submit text to generator here
    LocalLLMInterface()
        .newMessage(text, messages, selectedModel, generationCallback);
    uiMessage.Message _message = uiMessage.Message(
        id: Tools().getRandomString(12),
        conversationID: widget.conversation!.id,
        message: ValueNotifier(""),
        documentID: '',
        name: 'ChatBot',
        senderID: 'bot13451234',
        status: '',
        timestamp: DateTime.now(),
        type: uiMessage.MessageType.text);
    messages.add(_message);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container()
        : ChatRoomPage(
            key: widget.conversation != null
                ? Key(widget.conversation!.id)
                : Key(DateTime.now().toIso8601String()),
            messages: messages,
            conversation: widget.conversation,
            showModelSelectButton: true,
            selectedModelConfig: selectedModel,
            onSelectedModelChange: (LanguageModel? newValue) {
              selectedModel.model = newValue!;
            },
            showTopTitle: false,
            isGenerating: isGenerating,
            onNewMessage: (Conversation lastMessageUpdate, String text) async {
              if (widget.conversation == null) {
                // CREATES A NEW CONVERSATION
                // This is the quickstart path, where the chat box is open on start up
                // we direct people directly into a Chat game
                // create an official conversation ID and add to the conversations list
                widget.conversation = Conversation(
                  id: Tools().getRandomString(12),
                  lastMessage: text,
                  gameType: GameType.chat,
                  time: DateTime.now(),
                  primaryModel: selectedModel.model.name,
                  title: "Chat",
                );
                await ConversationDatabase.instance
                    .create(widget.conversation!);
                widget.conversations.value.insert(0, widget.conversation!);
                widget.conversations.notifyListeners();
              }
              if (text.trim() != "") {
                uiMessage.Message message = uiMessage.Message(
                    id: Tools().getRandomString(12),
                    conversationID: widget.conversation!.id,
                    message: ValueNotifier(text),
                    documentID: '',
                    name: 'User',
                    senderID: '',
                    status: '',
                    timestamp: DateTime.now(),
                    type: uiMessage.MessageType.text);
                messages.add(message);
                await ConversationDatabase.instance.createMessage(message);

                widget.conversation!.lastMessage = text;
                widget.conversation!.time = DateTime.now();

                setState(() {
                  isGenerating.value = true;
                });
                sendMessagetoModel(message.message!.value);
                setState(() {});
              }
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