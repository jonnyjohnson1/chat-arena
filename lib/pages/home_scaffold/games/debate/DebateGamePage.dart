// DebateGamePage.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:chat/chatroom/chatroom.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/models/conversation_analytics.dart';
import 'package:chat/models/custom_file.dart';
import 'package:chat/models/display_configs.dart';
import 'package:chat/models/event_channel_model.dart';
import 'package:chat/models/game_models/debate.dart';
import 'package:chat/models/llm.dart';
import 'package:chat/models/user.dart';
import 'package:chat/pages/home_scaffold/games/debate/debate_game_settings.dart';
import 'package:chat/services/conversation_database.dart';
import 'package:chat/services/local_llm_interface.dart';
import 'package:chat/services/debate_auth_websocket_service.dart';
import 'package:chat/models/messages.dart';
import 'package:chat/models/messages.dart' as uiMessage;

class DebateGamePage extends StatefulWidget {
  Conversation? conversation;
  final ValueNotifier<List<Conversation>> conversations;

  DebateGamePage({Key? key, this.conversation, required this.conversations}) : super(key: key);

  @override
  State<DebateGamePage> createState() => _DebateGamePageState();
}

class _DebateGamePageState extends State<DebateGamePage> {
  bool isLoading = true;
  late List<Message> messages = [];
  late DebateAuthWebSocketService _webSocketService;
  ModelConfig selectedModel = ModelConfig(
      model: const LanguageModel(model: 'dolphin-llama3', name: "dolphin-llama3", size: 21314),
      temperature: 0.06,
      numGenerations: 1
  );

  late ValueNotifier<DisplayConfigData> displayConfigData;
  late ValueNotifier<Conversation?> currentSelectedConversation;
  late ValueNotifier<User> userModel;
  ValueNotifier<bool> isGenerating = ValueNotifier(false);

  String generatedChat = "";
  double toksPerSec = 0.0;
  double completionTime = 0.0;
  int currentIdx = 0;

  @override
  void initState() {
    super.initState();
    debugPrint('\t[ DebateGamePage :: initState ]');

    currentSelectedConversation = Provider.of<ValueNotifier<Conversation?>>(context, listen: false);
    displayConfigData = Provider.of<ValueNotifier<DisplayConfigData>>(context, listen: false);
    userModel = Provider.of<ValueNotifier<User>>(context, listen: false);

    _webSocketService = DebateAuthWebSocketService('0.0.0.0:13341');

    initData();
    _initializeWebSocket();

    if (widget.conversation?.gameModel == null || widget.conversation!.gameModel.topic.isEmpty) {
      Future.delayed(const Duration(milliseconds: 400), () async {
        debugPrint('\t\t[ Fetching debate game settings ]');
        Map<String, dynamic> debateGameSettings = await getGameSettings(context);
        String topic = debateGameSettings['topic'];
        if (topic.isNotEmpty) {
          setState(() {
            widget.conversation!.gameModel = DebateGame(topic: topic);
          });
        }
      });
    }
  }

  Future<void> initData() async {
    debugPrint('\t[ DebateGamePage :: initData ]');
    if (widget.conversation != null) {
      try {
        messages = await ConversationDatabase.instance.readAllMessages(widget.conversation!.id);
        debugPrint('\t\t[ Loaded ${messages.length} messages ]');
      } catch (e) {
        debugPrint('\t\t[ Error loading messages: $e ]');
      }
      currentSelectedConversation.value = widget.conversation;
      currentSelectedConversation.notifyListeners();
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _initializeWebSocket() async {
    debugPrint('\t[ DebateGamePage :: _initializeWebSocket ]');
    bool loggedIn = await _webSocketService.login(userModel.value.username, 'password');
    if (loggedIn) {
      debugPrint('\t\t[ WebSocket login successful ]');
      bool sessionCreated = await _webSocketService.createOrJoinSession();
      if (sessionCreated) {
        debugPrint('\t\t[ WebSocket session created ]');
        bool connected = await _webSocketService.connectWebSocket();
        if (connected) {
          _listenToWebSocketMessages();
          debugPrint('\t\t[ WebSocket connected successfully ]');
        } else {
          _showError('Failed to connect to WebSocket');
        }
      } else {
        _showError('Failed to create or join session');
      }
    } else {
      _showError('Login failed');
    }
  }

  void _listenToWebSocketMessages() {
    debugPrint('\t[ DebateGamePage :: _listenToWebSocketMessages ]');
    _webSocketService.messages.listen((message) {
      final data = json.decode(message);
      _handleWebSocketMessage(data);
    });
  }

  void _handleWebSocketMessage(Map<String, dynamic> data) {
    debugPrint('\t[ DebateGamePage :: _handleWebSocketMessage ]');
    debugPrint('\t\t[ Received message type: ${data['status']} ]');

    try {
      switch (data['status']) {
        case 'message_processed':
          _handleMessageProcessed(data);
          break;
        case 'initial_clusters':
          _handleInitialClusters(data);
          break;
        case 'updated_clusters':
          _handleUpdatedClusters(data);
          break;
        case 'wepcc_result':
          _handleWEPCCResult(data);
          break;
        case 'final_results':
          _handleFinalResults(data);
          break;
        default:
          debugPrint('\t\t[ Unknown message type received: ${data['status']} ]');
      }

      // Notify listeners after each update
      currentSelectedConversation.notifyListeners();

    } catch (e, stackTrace) {
      debugPrint('\t\t[ Error handling WebSocket message: $e ]');
      debugPrint('\t\t[ Stack trace: $stackTrace ]');
    }
  }

  void _handleMessageProcessed(Map<String, dynamic> data) {
    debugPrint('\t[ DebateGamePage :: _handleMessageProcessed ]');
    String? userMessageId = data['user_message_id'] as String?;
    String? serviceId = data['service_id'] as String?;
    if (userMessageId != null) {
      int index = messages.indexWhere((m) => m.id == userMessageId);
      if (index != -1) {
        debugPrint('\t\t[ Message processed: $userMessageId ]');
        // Update message status if needed
        setState(() {
          messages[index].status = 'Integrating';

          if (serviceId != null) {
            messages[index].serviceId = serviceId;
          }
        });
      } else {
        debugPrint('\t\t[ Message not found: $userMessageId ]');
      }
    } else {
      debugPrint('\t\t[ Invalid message_id received ]');
    }
  }

  void _handleInitialClusters(Map<String, dynamic> data) {
    debugPrint('\t[ DebateGamePage :: _handleInitialClusters ]');
    if (data['clusters'] != null) {
      widget.conversation?.debateData.initialClusters = data['clusters'];
      _updateMermaidChart(data['clusters']);
      debugPrint('\t\t[ Initial clusters processed ]');
    } else {
      debugPrint('\t\t[ No initial clusters data received ]');
    }
  }

  void _handleUpdatedClusters(Map<String, dynamic> data) {
    debugPrint('\t[ DebateGamePage :: _handleUpdatedClusters ]');
    if (data['clusters'] != null) {
      widget.conversation?.debateData.updatedClusters = data['clusters'];
      _updateMermaidChart(data['clusters']);
      debugPrint('\t\t[ Updated clusters processed ]');
    } else {
      debugPrint('\t\t[ No updated clusters data received ]');
    }
  }

  void _handleWEPCCResult(Map<String, dynamic> data) {
    debugPrint('\t[ DebateGamePage :: _handleWEPCCResult ]');
    try {
      // Use dynamic type for initial assignment to allow for different types
      dynamic rawClusterId = data['cluster_id'];
      String clusterId;

      // Convert the clusterId to String, regardless of its original type
      if (rawClusterId is int) {
        clusterId = rawClusterId.toString();
      } else if (rawClusterId is String) {
        clusterId = rawClusterId;
      } else {
        throw FormatException('Invalid cluster_id type: ${rawClusterId.runtimeType}');
      }

      Map<String, dynamic>? wepccResult = data['wepcc_result'] as Map<String, dynamic>?;

      if (wepccResult != null) {
        widget.conversation?.debateData.wepccResults[clusterId] = wepccResult;
        debugPrint('\t\t[ WEPCC result processed for cluster: $clusterId ]');
      } else {
        debugPrint('\t\t[ Warning: Null WEPCC result received for cluster: $clusterId ]');
      }
    } catch (e, stackTrace) {
      debugPrint('\t\t[ Error handling WEPCC result: $e ]');
      debugPrint('\t\t[ Stack trace: $stackTrace ]');
      // You might want to add some error recovery logic here
    }
  }

  void _handleFinalResults(Map<String, dynamic> data) {
    debugPrint('\t[ DebateGamePage :: _handleFinalResults ]');

    if (data['aggregated_scores'] != null) {
      widget.conversation?.debateData.aggregatedScores = Map<String, dynamic>.from(data['aggregated_scores']);
    }

    if (data['addressed_clusters'] != null) {
      widget.conversation?.debateData.addressedClusters = (data['addressed_clusters'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
              key,
              (value as List<dynamic>).map((item) => [item[0].toString(), item[1]]).toList()
          )
      );
    }

    if (data['unaddressed_clusters'] != null) {
      widget.conversation?.debateData.unaddressedClusters = (data['unaddressed_clusters'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
              key,
              (value as List<dynamic>).map((item) => [item[0].toString(), item[1]]).toList()
          )
      );
    }

    if (data['results'] != null) {
      widget.conversation?.debateData.results = List<dynamic>.from(data['results']);
    }

    _updateMermaidChart(data);

    debugPrint('\t\t[ Final results processed and stored ]');
  }

  void _updateMermaidChart(Map<String, dynamic> data) {
    debugPrint('\t[ DebateGamePage :: _updateMermaidChart ]');
    String mermaidSyntax = _generateMermaidSyntax(data);
    widget.conversation?.debateData.mermaidChartData = mermaidSyntax;
    debugPrint('\t\t[ Mermaid chart data updated ]');
  }

  String _generateMermaidSyntax(Map<String, dynamic> data) {
    debugPrint('\t[ DebateGamePage :: _generateMermaidSyntax ]');
    StringBuffer syntax = StringBuffer('graph TD;\n');

    // Example implementation - adjust based on your specific data structure
    data['clusters']?.forEach((clusterId, clusterData) {
      syntax.writeln('  $clusterId[Cluster $clusterId]');
      clusterData['claims']?.forEach((claim) {
        syntax.writeln('  $clusterId --> ${claim['id']}[${claim['content']}]');
      });
    });

    debugPrint('\t\t[ Mermaid syntax generated ]');
    return syntax.toString();
  }

  void sendMessageToModel(String text, String userMessageId) async {
    debugPrint('\t[ DebateGamePage :: sendMessageToModel ]');
    final newChatBotMsgId = const Uuid().v4();

    _webSocketService.sendMessage(text, userMessageId, userModel.value.uid);

    Message message = Message(
        id: newChatBotMsgId,
        conversationID: widget.conversation!.id,
        message: ValueNotifier(""),
        documentID: '',
        name: 'ChatBot',
        senderID: 'assistant',
        status: '',
        timestamp: DateTime.now(),
        type: MessageType.text
    );

    setState(() {
      messages.add(message);
      currentIdx = messages.length - 1;
      isGenerating.value = true;
    });

    debugPrint('\t\t[ Message sent to model: $text ]');

    // Note: The actual message processing is now handled by the WebSocket
    // We keep this call for any local processing that might still be needed
    LocalLLMInterface(displayConfigData.value.apiConfig).newChatMessage(
        text,
        messages,
        widget.conversation!.id,
        newChatBotMsgId,
        selectedModel,
        displayConfigData.value,
        userModel.value,
        generationCallback,
        analysisCallBackFunction
    );
  }

  void generationCallback(Map<String, dynamic>? event) async {
    // Implementation remains the same
    // debugPrint('\t[ DebateGamePage :: generationCallback ]');
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

  void analysisCallBackFunction(dynamic userMessage, dynamic chatBotMessage) async {
    // Implementation remains the same
    debugPrint('\t[ DebateGamePage :: analysisCallBackFunction ]');
    // Add your implementation here
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

  String getTopicText(Conversation? conversation) {
    if (conversation?.gameModel != null) {
      return conversation!.gameModel.topic ?? "";
    }
    return "insert topic";
  }

  void _showError(String message) {
    debugPrint('\t[ DebateGamePage :: _showError: $message ]');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
      children: [
        Expanded(
          child: ChatRoomPage(
            key: widget.conversation != null
                ? Key(widget.conversation!.id)
                : Key(DateTime.now().toIso8601String()),
            messages: messages,
            isGenerating: isGenerating,
            conversation: widget.conversation,
            showGeneratingText: true,
            showModelSelectButton: true,
            selectedModelConfig: selectedModel,
            onSelectedModelChange: (LanguageModel? newValue) {
              selectedModel.model = newValue!;
            },
            showTopTitle: true,
            topTitleHeading: "Topic:",
            topTitleText: getTopicText(widget.conversation),
            onNewMessage: _handleNewMessage,
          ),
        ),
        // You can add a brief summary of debate status here if needed
      ],
    );
  }

  Future<void> _handleNewMessage(Conversation? conv, String text, List<ImageFile> images) async {
    debugPrint('\t[ DebateGamePage :: _handleNewMessage ]');
    if (widget.conversation == null) {
      await _createNewConversation(text);
    }
    if (text.trim().isNotEmpty) {
      await _addNewMessage(text, images);
    }
    await _updateConversationState();
  }

  Future<void> _createNewConversation(String text) async {
    debugPrint('\t[ DebateGamePage :: _createNewConversation ]');
    Conversation newConversation = Conversation(
      id: const Uuid().v4(),
      lastMessage: text,
      gameType: GameType.debate,
      time: DateTime.now(),
      primaryModel: selectedModel.model.name,
      title: "Debate",
    );
    await ConversationDatabase.instance.create(newConversation);
    widget.conversations.value.insert(0, newConversation);
    widget.conversations.notifyListeners();
    currentSelectedConversation.value = newConversation;
    currentSelectedConversation.notifyListeners();

    setState(() {
      widget.conversation = newConversation;
    });
    debugPrint('\t\t[ New conversation created: ${newConversation.id} ]');
  }

  Future<void> _addNewMessage(String text, List<ImageFile> images) async {
    debugPrint('\t[ DebateGamePage :: _addNewMessage ]');
    String userMessageId = const Uuid().v4();

    Message message = Message(
        id: userMessageId,
        conversationID: widget.conversation!.id,
        message: ValueNotifier(text),
        images: images,
        documentID: '',
        name: 'User',
        senderID: userModel.value.uid,
        status: '',
        timestamp: DateTime.now(),
        type: MessageType.text
    );
    messages.add(message);
    await ConversationDatabase.instance.createMessage(message);
    widget.conversation!.lastMessage = text;
    widget.conversation!.time = DateTime.now();
    setState(() {
      isGenerating.value = true;
    });
    sendMessageToModel(text, userMessageId);
    debugPrint('\t\t[ New message added: ${message.id} ]');
  }

  Future<void> _updateConversationState() async {
    debugPrint('\t[ DebateGamePage :: _updateConversationState ]');
    await ConversationDatabase.instance.update(widget.conversation!);
    int idx = widget.conversations.value.indexWhere((element) => element.id == widget.conversation!.id);
    widget.conversations.value[idx] = widget.conversation!;
    widget.conversations.value.sort((a, b) => b.time!.compareTo(a.time!));
    widget.conversations.notifyListeners();
    debugPrint('\t\t[ Conversation state updated ]');
  }

  @override
  void dispose() {
    debugPrint('\t[ DebateGamePage :: dispose ]');
    _webSocketService.close();
    super.dispose();
  }

  Future<void> _showAddAccountsDialog() async {
    debugPrint('\t[ DebateGamePage :: _showAddAccountsDialog ]');
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Account'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(hintText: "Username"),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(hintText: "Password"),
                  obscureText: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () async {
                Navigator.of(context).pop();
                Map<String, String> newAccounts = {
                  usernameController.text: passwordController.text,
                };
                await _webSocketService.adminAddAccounts(newAccounts);
                debugPrint('\t\t[ New account added: ${usernameController.text} ]');
              },
            ),
          ],
        );
      },
    );
  }

  void _resetDebateState() {
    debugPrint('\t[ DebateGamePage :: _resetDebateState ]');
    widget.conversation?.debateData.reset();
    // Notify listeners that the debate state has been reset
    currentSelectedConversation.notifyListeners();
    debugPrint('\t\t[ Debate state reset ]');
  }

  void _startNewGeneration() {
    debugPrint('\t[ DebateGamePage :: _startNewGeneration ]');
    _resetDebateState();
    // Additional logic for starting a new generation
    // This might involve sending a message to the server to indicate a new generation
    // _webSocketService.sendMessage("NEW_GENERATION", userModel.value.uid);
    debugPrint('\t\t[ New generation started ]');
  }
}