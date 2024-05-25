import 'dart:io';

import 'package:chat/chatroom/chatroom.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/models/conversation_analytics.dart';
import 'package:chat/models/custom_file.dart';
import 'package:chat/models/display_configs.dart';
import 'package:chat/models/event_channel_model.dart';
import 'package:chat/models/llm.dart';
import 'package:chat/services/conversation_database.dart';
import 'package:chat/services/local_llm_interface.dart';
import 'package:chat/services/tools.dart';
import 'package:flutter/material.dart';
import 'package:chat/models/messages.dart' as uiMessage;
import 'package:provider/provider.dart';

late final dynamic
    llmInterface; // Can be LocalLLMInterface or DebateLLMInterface

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
      // set the current conversation value to the loaded conversation
      currentSelectedConversation.value = widget.conversation;
      currentSelectedConversation.notifyListeners();
    } else {
      // CREATES A NEW CONVERSATION
      // This is the quickstart path, where the chat box is open on start up
      // we direct people directly into a Chat game
      // create an official conversation ID and add to the conversations list
      widget.conversation = Conversation(
        id: Tools().getRandomString(12),
        lastMessage: "",
        gameType: GameType.chat,
        time: DateTime.now(),
        primaryModel: selectedModel.model.name,
        title: "Chat",
      );
      await ConversationDatabase.instance.create(widget.conversation!);
      widget.conversations.value.insert(0, widget.conversation!);
      widget.conversations.notifyListeners();
      currentSelectedConversation.value = widget.conversation;
      currentSelectedConversation.notifyListeners();
    }
    setState(() {
      isLoading = false;
    });
  }

  late ValueNotifier<DisplayConfigData> displayConfigData;
  late ValueNotifier<Conversation?> currentSelectedConversation;

  @override
  void initState() {
    super.initState();
    currentSelectedConversation =
        Provider.of<ValueNotifier<Conversation?>>(context, listen: false);
    displayConfigData =
        Provider.of<ValueNotifier<DisplayConfigData>>(context, listen: false);
    initData();
    debugPrint("\t[ Chat :: GamePage initState ]");
    // llmInterface = LocalLLMInterface()
  }

  String generatedChat = "";
  double toksPerSec = 0.0;
  double completionTime = 0.0;
  int currentIdx = 0;
  ValueNotifier<bool> isGenerating = ValueNotifier(false);

  // handles the chat response
  generationCallback(Map<String, dynamic>? event) async {
    if (event != null) {
      double completionTime = 0.0;

      EventGenerationResponse response = EventGenerationResponse.fromMap(event);

      generatedChat = response.generation;
      if (response.isCompleted) {
        debugPrint("\t\t[ chat completed ]");
        // end token is received
        isGenerating.value = false;
        messages[currentIdx].isGenerating = false;
        completionTime = response.completionTime;
        messages[currentIdx].completionTime = completionTime;
        isGenerating.notifyListeners();

        setState(() {});
        // add the final message to the database
        ConversationDatabase.instance.createMessage(messages[currentIdx]);

        // Run all the post conversation analyses here
        // run sidebar calculations if config says so
        if (displayConfigData.value.showSidebarBaseAnalytics) {
          ConversationData? data = await LocalLLMInterface()
              .getChatAnalysis(widget.conversation!.id);
          // return analysis to the Conversation object
          widget.conversation!.conversationAnalytics.value = data;
          widget.conversation!.conversationAnalytics.notifyListeners();

          // get an image depiction of the conversation
          if (displayConfigData.value.calcImageGen) {
            ImageFile? imageFile = await LocalLLMInterface()
                .getConvToImage(widget.conversation!.id);
            if (imageFile != null) {
              // append to the conversation list of images conv_to_image parameter (the display will only show the last one)
              widget.conversation!.convToImagesList.value.add(imageFile);
              widget.conversation!.convToImagesList.notifyListeners();
            }
          }
        }
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

  // handles the analysis from the chat response
  // this includes: in-line values- token and text classification
  // and returns the response for both the initial user message and the chatbot's message
  analysisCallBackFunction(dynamic userMessage, dynamic chatBotMessage) async {
    if (userMessage.isNotEmpty) {
      String userMsgId = userMessage.keys.first;
      int idx = messages
          .indexWhere((uiMessage.Message element) => element.id == userMsgId);
      // Set the message's analytics value
      messages[idx].baseAnalytics.value = userMessage[userMsgId];
      messages[idx].baseAnalytics.notifyListeners();
    }
    if (chatBotMessage.isNotEmpty) {
      String botMsgId = chatBotMessage.keys.first;
      int idx = messages
          .indexWhere((uiMessage.Message element) => element.id == botMsgId);
      // Set the message's analytics value
      messages[idx].baseAnalytics.value = chatBotMessage[botMsgId];
      messages[idx].baseAnalytics.notifyListeners();
    }
  }

  void sendMessagetoModel(String text) async {
    debugPrint("[ Submitting: $text ]"); // General debug print
    final newChatBotMsgId = Tools().getRandomString(32);
    LocalLLMInterface().newChatMessage(
        text,
        messages,
        widget.conversation!.id,
        newChatBotMsgId,
        selectedModel,
        displayConfigData.value,
        generationCallback,
        analysisCallBackFunction);

    debugPrint("[ Message Submitted: $text ]");
    currentIdx = messages.length;
    // // Submit text to generator here
    uiMessage.Message message = uiMessage.Message(
        id: newChatBotMsgId,
        conversationID: widget.conversation!.id,
        message: ValueNotifier(""),
        documentID: '',
        name: 'ChatBot',
        senderID: 'assistant',
        status: '',
        timestamp: DateTime.now(),
        type: uiMessage.MessageType.text);
    messages.add(message);
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
            onNewMessage: (Conversation? conv, String text,
                List<ImageFile> images) async {
              // if (widget.conversation == null) {
              //   // CREATES A NEW CONVERSATION
              //   // This is the quickstart path, where the chat box is open on start up
              //   // we direct people directly into a Chat game
              //   // create an official conversation ID and add to the conversations list
              //   widget.conversation = Conversation(
              //     id: Tools().getRandomString(12),
              //     lastMessage: text,
              //     gameType: GameType.chat,
              //     time: DateTime.now(),
              //     primaryModel: selectedModel.model.name,
              //     title: "Chat",
              //   );
              //   await ConversationDatabase.instance
              //       .create(widget.conversation!);
              //   widget.conversations.value.insert(0, widget.conversation!);
              //   widget.conversations.notifyListeners();
              // }
              if (text.trim() != "") {
                uiMessage.Message message = uiMessage.Message(
                    id: Tools().getRandomString(12),
                    conversationID: widget.conversation!.id,
                    message: ValueNotifier(text),
                    images: images,
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
              await ConversationDatabase.instance.update(widget.conversation!);
              int idx = widget.conversations.value.indexWhere(
                  (element) => element.id == widget.conversation!.id);
              widget.conversations.value[idx] = widget.conversation!;
              widget.conversations.value.sort((a, b) {
                return b.time!.compareTo(a.time!);
              });
              widget.conversations.notifyListeners();
            },
          );
  }
}
