import 'dart:math';

import 'package:chat/chatroom/chatroom.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/models/conversation_analytics.dart';
import 'package:chat/models/custom_file.dart';
import 'package:chat/models/display_configs.dart';
import 'package:chat/models/game_models/debate.dart';
import 'package:chat/models/llm.dart';
import 'package:chat/pages/home_scaffold/games/p2pchat/chat_status_row.dart';
import 'package:chat/services/conversation_database.dart';
import 'package:chat/services/local_llm_interface.dart';
import 'package:chat/services/message_processor.dart';
import 'package:chat/services/tools.dart';
import 'package:chat/services/websocket_chat_client.dart';
import 'package:chat/shared/string_conversion.dart';
import 'package:flutter/material.dart';
import 'package:chat/models/messages.dart' as uiMessage;
import 'package:provider/provider.dart';
import 'package:chat/models/user.dart';

late final dynamic
    llmInterface; // Can be LocalLLMInterface or DebateLLMInterface

class P2PChatGamePage extends StatefulWidget {
  Conversation? conversation;
  ValueNotifier<List<Conversation>> conversations;
  P2PChatGamePage({this.conversation, required this.conversations, super.key});

  @override
  State<P2PChatGamePage> createState() => _P2PChatGamePageState();
}

class _P2PChatGamePageState extends State<P2PChatGamePage> {
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
        print("ERROR INITING DATA FOR DATABASE");
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
  WebSocketChatClient client = WebSocketChatClient(url: 'ws://127.0.0.1:13349');

  bool clientIsConnected = false;
  late MessageProcessor messageProcessor;

  @override
  void initState() {
    super.initState();
    messageProcessor = MessageProcessor();
    currentSelectedConversation =
        Provider.of<ValueNotifier<Conversation?>>(context, listen: false);
    displayConfigData =
        Provider.of<ValueNotifier<DisplayConfigData>>(context, listen: false);
    userModel = Provider.of<ValueNotifier<User>>(context, listen: false);
    initData();
    debugPrint("\t[ P2PChat :: GamePage initState ]");

    if (widget.conversation!.gameModel == null ||
        widget.conversation!.gameModel.serverHostAddress.isEmpty) {
      Future.delayed(const Duration(milliseconds: 400), () async {
        P2PChatGame gameSettings = await getP2PChatSettings(context);
        widget.conversation!.gameModel = gameSettings;
        print(
            "${gameSettings.serverHostAddress} IS :: ${gameSettings.serverHostAddress.runtimeType}");
        String url = gameSettings.serverHostAddress!.isNotEmpty
            ? makeWebSocketAddress(gameSettings.serverHostAddress!)
            : 'ws://127.0.0.1:13349';
        print("[ using url $url to connect to server ]");
        client.url = url;

        // here we must create a conversation id on init so the server has a reference to it
        if (widget.conversation == null) {
          widget.conversation = Conversation(
            id: Tools().getRandomString(12),
            lastMessage: "",
            gameType: GameType.p2pchat,
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
        Map<String, dynamic> data = {
          "message_type": "create_server", // OPTIONS: user, ai, server
          // "conversation_id": widget.conversation!.id, // I don't think we need this. This conversation Id will be used to save the user's data. THe session ID will be used so users can reference the same conversation.
          "num_participants": gameSettings.maxParticipants,
          "host_name": gameSettings.username,
          "user_id": userModel.value.uid,
          "created_at": DateTime.now().toIso8601String(),
          "username": gameSettings.username,
        };

        print("\t[ connecting to :: url ${client.url} ]");
        client.connect(data, listenerCallback, websocketDisconnectListener,
            websocketErrorListener);
        setState(() {
          clientIsConnected =
              true; // set client to connected. If it fails to connect, one of the listeners will trigger, and its function will set the bool val to false
        });
      });
    } else {
      // this path is the join chat option
      print('\t[ joining server ]');
      P2PChatGame gameSettings = widget.conversation!.gameModel;

      String url = gameSettings.serverHostAddress != null
          ? makeWebSocketAddress(gameSettings.serverHostAddress!)
          : 'ws://127.0.0.1:13349';
      print("[ using url $url to connect to server ]");
      client.url = url;
      if (gameSettings.initState != null) {
        if (gameSettings.initState == P2PServerInitState.join) {
          Map<String, dynamic> data = {
            "message_type": "join_server",
            "host_name": gameSettings.username,
            "user_id": userModel.value.uid,
            'session_id': gameSettings.sessionID,
            "created_at": DateTime.now().toIso8601String(),
            "username": gameSettings.username,
          };

          client.connect(data, listenerCallback, websocketDisconnectListener,
              websocketErrorListener); // replace 'username' with the actual username
          setState(() {
            clientIsConnected =
                true; // set slient to connected. If it fails to connect, one of the listeners will trigger, and its function will set the bool val to false
          });
        }
      }
    }
  }

  String sessionId = "";

  // Future<Map<String, dynamic>> processMessage(
  //     uiMessage.Message message, Conversation conversation) async {
  //   // Simulate sending message to the backend and getting a response
  //   await Future.delayed(const Duration(seconds: 1));
  //   print(
  //       "[ sending message to analytics function :: ${message.message!.value}]");
  //   return {'processedData': 'Processed: ${message.message!.value}'};
  // }

  void sendMessageForProcessing(MessageProcessor processor,
      uiMessage.Message message, Conversation conversation) async {
    // process single message analytics
    processor.addProcess(QueueProcess(
      function: LocalLLMInterface(displayConfigData.value.apiConfig)
          .getMessageAnalytics,
      args: {'message': message, 'conversation': conversation},
    ));

    // proces the whole chat analytics
    // Run all the post conversation analyses here
    // run sidebar calculations if config says so
    print("SHOWING SIDEBAR ANALYTICS");
    if (displayConfigData.value.showSidebarBaseAnalytics) {
      print("GET CHAT ANALYSIS");
      await Future.delayed(const Duration(seconds: 3), () async {
        print("EXECUTING");
        ConversationData? data =
            await LocalLLMInterface(displayConfigData.value.apiConfig)
                .getChatAnalysis(widget.conversation!.id);
        // return analysis to the Conversation object
        widget.conversation!.conversationAnalytics.value = data;
        widget.conversation!.conversationAnalytics.notifyListeners();
      });

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
  }

  void _processServerMessage(Map<String, dynamic> listenerMessage) {
    final newChatBotMsgId = Tools().getRandomString(32);
    uiMessage.Message message = uiMessage.Message(
        id: newChatBotMsgId,
        conversationID: widget.conversation!.id,
        message: ValueNotifier(listenerMessage["message"]),
        documentID: '',
        name: "Server",
        senderID: "Server",
        status: '',
        timestamp: DateTime.parse(listenerMessage["timestamp"]),
        type: uiMessage.MessageType.server);
    messages.add(message);
    print("[ added server message to messages ]");
    sessionId = listenerMessage['session_id'];
    setState(() {});
  }

  void _processUserMessage(Map<String, dynamic> listenerMessage) {
    final newChatBotMsgId = Tools().getRandomString(32);
    String messageId = listenerMessage['message_id'];
    String username = listenerMessage["content"]["username"];
    String text = listenerMessage["content"]["text"];
    String senderID = listenerMessage["content"]["user_id"];
    DateTime timestamp = DateTime.parse(listenerMessage["timestamp"]);
    uiMessage.Message message = uiMessage.Message(
        id: messageId,
        conversationID: widget.conversation!.id,
        message: ValueNotifier(text),
        documentID: '',
        name: username,
        senderID: senderID,
        status: '',
        timestamp: timestamp,
        type: uiMessage.MessageType.text);
    messages.add(message);
    print("added user message to messages");
    setState(() {});
    // send received user's message for processing
    sendMessageForProcessing(messageProcessor, message, widget.conversation!);
  }

  listenerCallback(Map<String, dynamic> listenerMessage) {
    // message received over broadcast
    print('[ ChatGamePage :: Received: $listenerMessage ]');
    String messageType = listenerMessage["message_type"];
    if (messageType == "server") {
      _processServerMessage(listenerMessage);
    } else if (messageType == "user") {
      _processUserMessage(listenerMessage);
    }
  }

  sendMessage(uiMessage.Message message, Conversation conversation) {
    // format into send object
    P2PChatGame gameModel = conversation.gameModel;
    // write into json schema
    Map<String, dynamic> data = {
      "message_id": message.id,
      "message_type": "user", // OPTIONS: user, ai, server
      "num_participants": 1,
      "content": {
        "user_id": message.senderID,
        "session_id": sessionId,
        "username": gameModel.username,
        "text": message.message!.value
      },
      "timestamp": DateTime.now().toIso8601String(),
      "metadata": {
        "priority": "", // e.g., normal, high
        "tags": []
      },
      "attachments": [
        {"file_name": null, "file_type": null, "url": null}
      ]
    };
    client.sendMessage(data);
    // send user message for processing
    sendMessageForProcessing(messageProcessor, message, widget.conversation!);
  }

  websocketDisconnectListener(String message) {
    print(
        '[ Received message in ChatGamePage :: WebSocket connection closed. ]');
    clientIsConnected = false;
    setState(() {});
  }

  websocketErrorListener(String message) {
    print(
        '[ Received message in ChatGamePage :: WebSocket connection closed. ]');
    clientIsConnected = false;
    setState(() {});
  }

  Future<P2PChatGame> getP2PChatSettings(BuildContext context) async {
    TextEditingController usernameController = TextEditingController();
    TextEditingController serverHostAddressController = TextEditingController();
    TextEditingController maxParticipantsController = TextEditingController();
    debugPrint("\t[ P2PChat :: Get Chat Settings ]");

    P2PChatGame? p2pChatGameSettings;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter Server Host or Start Host Chat"),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Username field
                TextField(
                  maxLines: 1,
                  controller: usernameController,
                  decoration: const InputDecoration(hintText: "Enter username"),
                ),
                const SizedBox(height: 20),
                // Manual entry section
                Text(
                  "Manual Entry",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextField(
                  maxLines: 1,
                  controller: serverHostAddressController,
                  decoration: const InputDecoration(
                      hintText: "Enter server host address"),
                ),
                const SizedBox(height: 20),
                TextField(
                  maxLines: 1,
                  controller: maxParticipantsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      hintText: "Enter max number of participants"),
                ),
                const Divider(
                    height: 40, thickness: 1.5), // Divider between sections
                // Start Host Chat section
                Text(
                  "Or",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    String username = usernameController.text.isEmpty
                        ? "Anon${generateRandom4Digits()}"
                        : usernameController.text;
                    p2pChatGameSettings = await startHostChat(username);
                    if (p2pChatGameSettings != null) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text("Start Host Chat"),
                ),
              ],
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

    String username = usernameController.text.isEmpty
        ? "Anon${generateRandom4Digits()}"
        : usernameController.text;

    debugPrint("\t\t[ Username: $username ]");
    debugPrint(
        "\t\t[ Server Host Address: ${serverHostAddressController.text} ]");
    debugPrint("\t\t[ Max Participants: ${maxParticipantsController.text} ]");

    return P2PChatGame(
        username: username,
        serverHostAddress: serverHostAddressController.text,
        maxParticipants: int.tryParse(maxParticipantsController.text) ?? 0,
        initState: P2PServerInitState.create);
  }

  String generateRandom4Digits() {
    var random = Random();
    return (random.nextInt(9000) + 1000).toString(); // Ensures a 4-digit number
  }

  Future<P2PChatGame> startHostChat(String username) async {
    // Implement your logic to start the host chat and return the server host address.
    // For now, let's assume it returns a dummy address after some delay.
    await Future.delayed(const Duration(seconds: 2));
    return P2PChatGame(
        serverHostAddress: "http://127.0.0.1:13349",
        maxParticipants: 5,
        username: username);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container()
        : Column(
            children: [
              ChatStatusRow(
                sessionId: sessionId,
                isConnected: clientIsConnected,
                userCount: 1,
                onReconnect: () {},
                onStartChat: () {},
              ),
              Expanded(
                child: ChatRoomPage(
                  key: widget.conversation != null
                      ? Key(widget.conversation!.id)
                      : Key(DateTime.now().toIso8601String()),
                  messages: messages,
                  conversation: widget.conversation,
                  showModelSelectButton: false,
                  // selectedModelConfig: selectedModel,
                  // onSelectedModelChange: (LanguageModel? newValue) {
                  //   selectedModel.model = newValue!;
                  // },
                  showTopTitle: false,
                  isGenerating: null,
                  onNewMessage: (Conversation? conv, String text,
                      List<ImageFile> images) async {
                    if (text.trim() != "") {
                      uiMessage.Message message = uiMessage.Message(
                          id: Tools().getRandomString(12),
                          conversationID: widget.conversation!.id,
                          message: ValueNotifier(text),
                          images: images,
                          documentID: '',
                          name: widget.conversation!.gameModel!.username,
                          senderID: userModel.value.uid,
                          status: '',
                          timestamp: DateTime.now(),
                          type: uiMessage.MessageType.text);
                      messages.add(message);
                      setState(() {});
                      await ConversationDatabase.instance
                          .createMessage(message);

                      widget.conversation!.lastMessage = text;
                      widget.conversation!.time = DateTime.now();

                      // Send a message to the server
                      sendMessage(
                        message,
                        widget.conversation!,
                      );
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
