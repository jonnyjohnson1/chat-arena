import 'dart:io';

import 'package:chat/chatroom/chatroom.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/models/conversation_analytics.dart';
import 'package:chat/models/custom_file.dart';
import 'package:chat/models/demo_controller.dart';
import 'package:chat/models/display_configs.dart';
import 'package:chat/models/event_channel_model.dart';
import 'package:chat/models/llm.dart';
import 'package:chat/models/scripts.dart';
import 'package:chat/models/user.dart';
import 'package:chat/services/conversation_database.dart';
import 'package:chat/services/local_llm_interface.dart';
import 'package:chat/services/message_processor.dart';
import 'package:chat/services/tools.dart';
import 'package:flutter/material.dart';
import 'package:chat/models/messages.dart' as uiMessage;
import 'package:provider/provider.dart';
import 'dart:math';

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
  late ValueNotifier<DemoController> demoController;
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
      // widget.conversation = Conversation(
      //   id: Tools().getRandomString(12),
      //   lastMessage: "",
      //   gameType: GameType.chat,
      //   time: DateTime.now(),
      //   primaryModel: selectedModel.model.name,
      //   title: "Chat",
      // );
      // await ConversationDatabase.instance.create(widget.conversation!);
      // widget.conversations.value.insert(0, widget.conversation!);
      // widget.conversations.notifyListeners();
      // currentSelectedConversation.value = widget.conversation;
      // currentSelectedConversation.notifyListeners();
    }
    setState(() {
      isLoading = false;
    });
  }

  late ValueNotifier<DisplayConfigData> displayConfigData;
  late ValueNotifier<Conversation?> currentSelectedConversation;
  late ValueNotifier<User> userModel;
  late ValueNotifier<Scripts?> scripts;
  late ValueNotifier<Script?> selectedScript;
  late MessageProcessor? messageProcessor;
  ValueNotifier<bool> isProcessing = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    currentSelectedConversation =
        Provider.of<ValueNotifier<Conversation?>>(context, listen: false);
    displayConfigData =
        Provider.of<ValueNotifier<DisplayConfigData>>(context, listen: false);
    demoController =
        Provider.of<ValueNotifier<DemoController>>(context, listen: false);

    userModel = Provider.of<ValueNotifier<User>>(context, listen: false);
    scripts = Provider.of<ValueNotifier<Scripts?>>(context, listen: false);
    selectedScript =
        Provider.of<ValueNotifier<Script?>>(context, listen: false);
    messageProcessor = Provider.of<MessageProcessor>(context, listen: false);
    // Listen to completion status changes
    if (messageProcessor != null) {
      messageProcessor!.completionStatus.listen((completed) async {
        print("IsCompleted: ${messageProcessor!.isCompleted()}");
        if (completed) {
          if (demoController.value.autoPlay) {
            print("\t[ ChatGamePage :: Processing completed :: auto-playing ]");
          }
        } else {
          // Do something when processing is still ongoing
          // print("Processing in progress.");
        }
      });
    }
    messageProcessor!.processDemoCompleteFunction = () async {
      if (demoController.value.autoPlay) {
        await _handleProcessCompleted();
      }
    };

    debugPrint("\t[ Chat :: GamePage initState ]");
    initData();
  }

  Future<void> _handleProcessCompleted() async {
    if (demoController.value.autoPlay) {
      // Update UI or perform actions when a process completes}
      DemoController demoCont = demoController.value;
      Script? script = selectedScript.value;
      if (script != null) {
        if (demoCont.index < script.script.length) {
          await Future.delayed(
              Duration(
                  milliseconds: demoCont.autoPlay
                      ? demoCont.durBetweenMessages
                      : 80), () async {
            demoCont.state = DemoState.next;
            demoController.notifyListeners();
            // simulate looping through the messages here
            await Future.delayed(
                Duration(milliseconds: demoCont.autoPlay ? 650 : 80), () async {
              demoCont.index += 1;
              demoCont.state = DemoState.pause;
              demoController.notifyListeners();
            });
          });
        }
      }
    }
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

        // Run the individual chat message analysis here
        if (displayConfigData.value.calcMsgMermaidChart) {
          String message = messages[currentIdx - 1].message!.value;
          if (message.split(" ").length >=
              6) // run_mermaid_check // if tokens > 6
          {
            print("mermaid chart here");
            await LocalLLMInterface(displayConfigData.value.apiConfig)
                .genMermaidChart(messages[currentIdx - 1],
                    widget.conversation!.id, selectedModel,
                    fullConversation: false);

            print("got");
            // LocalLLMInterface(displayConfigData.value.apiConfig)
            //     .genMermaidChartWS(messages[currentIdx - 1],
            //         widget.conversation!.id, selectedModel,
            //         fullConversation: false);
          }
        }

        // Run all the post conversation analyses here
        // run sidebar calculations if config says so
        if (displayConfigData.value.showSidebarBaseAnalytics) {
          ConversationData? data =
              await LocalLLMInterface(displayConfigData.value.apiConfig)
                  .getChatAnalysis(widget.conversation!.id);
          // return analysis to the Conversation object
          widget.conversation!.conversationAnalytics.value = data;
          widget.conversation!.conversationAnalytics.notifyListeners();

          // get an image depiction of the conversation
          if (displayConfigData.value.calcImageGen) {
            ImageFile? imageFile =
                await LocalLLMInterface(displayConfigData.value.apiConfig)
                    .getConvToImage(widget.conversation!.id);
            if (imageFile != null) {
              // append to the conversation list of images conv_to_image parameter (the display will only show the last one)
              widget.conversation!.convToImagesList.value.add(imageFile);
              widget.conversation!.convToImagesList.notifyListeners();
            }
          }
        }
      } else {
        // This branch handles all the streaming updates
        // debugPrint(generatedChat);
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
    LocalLLMInterface(displayConfigData.value.apiConfig).newChatMessage(
        text,
        messages,
        widget.conversation!.id,
        newChatBotMsgId,
        selectedModel,
        displayConfigData.value,
        userModel.value,
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

  Future<void> processDemoMessage(
      ScriptContent content, Conversation conversation) async {
    // make message
    demoController.value.state = DemoState.generating;
    displayConfigData.notifyListeners();
    final newMessageId = Tools().getRandomString(32);
    DateTime timestamp =
        DateTime.now(); //DateTime.parse(listenerMessage["timestamp"]);
    String messageText = content.data.content;
    String name = content.data.userId;
    String senderID =
        selectedScript.value!.cast[content.role] ?? Tools().getRandomString(6);
    if (name == selectedScript.value!.startingRole) {
      // set the senderID to the user's to put the user in this person's shoes
      senderID = userModel.value.uid;
    }

    print("ID:  ${conversation.id}");
    late uiMessage.Message message;

    if (!demoController.value.isTypeWritten) {
      message = uiMessage.Message(
          id: newMessageId,
          conversationID: conversation.id,
          message: ValueNotifier(messageText),
          documentID: '',
          name: name,
          senderID: senderID,
          status: '',
          timestamp: timestamp,
          isDemo: true,
          type: uiMessage.MessageType.text);
      messages.add(message);
    } else {
      message = uiMessage.Message(
          id: newMessageId,
          conversationID: conversation.id,
          message: ValueNotifier(""),
          documentID: '',
          name: name,
          senderID: senderID,
          status: '',
          timestamp: timestamp,
          isGenerating: true,
          isDemo: true,
          type: uiMessage.MessageType.text);
      messages.add(message);

      //option to emulate streaming text here
      print("added user message to messages");
      if (mounted) {
        setState(() {});
      }
      // emulate streaming here
      // streaming_rate = slow, med, fast
      int delay = 0;
      if (true) // medium
      {
        delay = (105 / sqrt(1 + messageText.length))
            .floor(); // Exponentially decreasing delay based on increased text length
      } else {
        // really fast!
        delay = (105 / 1 + messageText.length)
            .floor(); // Exponentially decreasing delay based on increased text length
      }
      for (int i = 0; i <= messageText.length; i++) {
        await Future.delayed(Duration(milliseconds: delay), () {
          messages.last.message!.value = messageText.substring(0, i);
          messages.last.message!.notifyListeners();
        });
      }

      messages.last.isGenerating = false;
    }

    //option to emulate streaming text here
    print("added user message to messages");
    await ConversationDatabase.instance
        .createMessage(message); // save to database
    if (mounted) {
      setState(() {});
    }
    // send received user's message for processing
    sendMessageForProcessing(messageProcessor!, message, widget.conversation!);
    widget.conversation!.lastMessage = messageText;
    widget.conversation!.time = DateTime.now();
    // conversation;
  }

  void sendMessageForProcessing(MessageProcessor processor,
      uiMessage.Message message, Conversation conversation) async {
    // process single message analytics

    processor.addProcess(QueueProcess(
      function: LocalLLMInterface(displayConfigData.value.apiConfig)
          .getMessageAnalytics,
      args: {
        'message': message,
        'conversation': conversation,
        'user_name': message.name,
        'role': "user"
      },
    ));

    if (displayConfigData.value.calcMsgMermaidChart) {
      processor.addProcess(QueueProcess(
        function: () async {
          await LocalLLMInterface(displayConfigData.value.apiConfig)
              .genMermaidChart(message, widget.conversation!.id, selectedModel,
                  fullConversation: false);
        },
      ));
    }

    // process the whole chat analytics
    // Run all the post conversation analyses here
    // run sidebar calculations if config says so
    if (displayConfigData.value.showSidebarBaseAnalytics) {
      processor.addProcess(QueueProcess(
        function: () async {
          await Future.delayed(const Duration(seconds: 2), () async {
            ConversationData? data =
                await LocalLLMInterface(displayConfigData.value.apiConfig)
                    .getChatAnalysis(widget.conversation!.id);
            // return analysis to the Conversation object
            widget.conversation!.conversationAnalytics.value = data;
            widget.conversation!.conversationAnalytics.notifyListeners();
          });
          demoController.value.state = DemoState.pause;
          displayConfigData.notifyListeners();
        },
      ));
    }

// get an image depiction of the conversation
    if (displayConfigData.value.calcImageGen) {
      processor.addProcess(QueueProcess(
        function: () async {
          ImageFile? imageFile =
              await LocalLLMInterface(displayConfigData.value.apiConfig)
                  .getConvToImage(widget.conversation!.id);
          if (imageFile != null) {
            // append to the conversation list of images conv_to_image parameter (the display will only show the last one)
            widget.conversation!.convToImagesList.value.add(imageFile);
            widget.conversation!.convToImagesList.notifyListeners();
          }
        },
      ));
    }

    demoController.value.state = DemoState.pause;
    displayConfigData.notifyListeners();
  }

  Future<void> createNewConversation(String text, GameType gameType) async {
    widget.conversation = Conversation(
      id: Tools().getRandomString(12),
      lastMessage: text,
      gameType: gameType,
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

  @override
  void dispose() {
    demoController.value.index = 0;
    // demoController.value.state = DemoState.pause;
    displayConfigData.value.demoMode = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container()
        : Column(
            children: [
              // Play and Pause buttons
              ValueListenableBuilder(
                  valueListenable: selectedScript,
                  builder: (ctx, val, _) {
                    return ValueListenableBuilder(
                        valueListenable: displayConfigData,
                        builder: (context, displayConfig, _) {
                          if (displayConfig.demoMode) {
                            return ValueListenableBuilder(
                                valueListenable: demoController,
                                builder: (context, demoCont, _) {
                                  if (selectedScript.value != null) {
                                    if (demoCont.state == DemoState.next) {
                                      String messageText = selectedScript.value!
                                          .script[demoCont.index].data.content;
                                      Future(() async {
                                        if (widget.conversation == null) {
                                          await createNewConversation(
                                              messageText, GameType.chat);
                                        }
                                        ScriptContent scriptContent =
                                            selectedScript
                                                .value!.script[demoCont.index];
                                        //send to demo
                                        await processDemoMessage(scriptContent,
                                            widget.conversation!);
                                        // if auto-play is on, we can increment to the next value here
                                      });
                                    }
                                  }
                                  return Container();
                                });
                          } else {
                            return Container();
                          }
                        });
                  }),
              Expanded(
                child: ChatRoomPage(
                  key: widget.conversation != null
                      ? Key(widget.conversation!.id)
                      : Key(DateTime.now().toIso8601String()),
                  messages: messages,
                  conversation: widget.conversation,
                  showGeneratingText: true,
                  showModelSelectButton: true,
                  selectedModelConfig: selectedModel,
                  onSelectedModelChange: (LanguageModel? newValue) {
                    selectedModel.model = newValue!;
                  },
                  showTopTitle: false,
                  isGenerating: isGenerating,
                  onResetDemoChat: () async {
                    print("reset demo here");
                    demoController.value.index =
                        0; // reset controller index to zero
                    messages.clear(); // empty messages link
                    // reset the conversation history
                    await ConversationDatabase.instance.delete(
                        widget.conversation!.id); // delete the conversation
                    setState(() {});
                  },
                  onNewMessage: (Conversation? conv, String text,
                      List<ImageFile> images) async {
                    if (widget.conversation == null) {
                      await createNewConversation(text, GameType.chat);
                    }
                    if (text.trim() != "") {
                      uiMessage.Message message = uiMessage.Message(
                          id: Tools().getRandomString(12),
                          conversationID: widget.conversation!.id,
                          message: ValueNotifier(text),
                          images: images,
                          documentID: '',
                          name: 'User',
                          senderID: userModel.value.uid,
                          status: '',
                          timestamp: DateTime.now(),
                          type: uiMessage.MessageType.text);
                      messages.add(message);

                      await ConversationDatabase.instance
                          .createMessage(message);

                      widget.conversation!.lastMessage = text;
                      widget.conversation!.time = DateTime.now();

                      setState(() {
                        isGenerating.value = true;
                      });
                      sendMessagetoModel(message.message!.value);
                      setState(() {});
                    }

                    // update the lastMessage sent
                    await ConversationDatabase.instance
                        .update(widget.conversation!);
                    int idx = widget.conversations.value.indexWhere(
                        (element) => element.id == widget.conversation!.id);
                    widget.conversations.value[idx] = widget.conversation!;
                    widget.conversations.value.sort((a, b) {
                      return b.time!.compareTo(a.time!);
                    });
                    widget.conversations.notifyListeners();
                  },
                ),
              ),
            ],
          );
  }
}
