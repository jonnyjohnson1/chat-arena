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

import '../../../../models/messages.dart';

class DebateGamePage extends StatefulWidget {
  Conversation? conversation; // Remove final keyword
  final ValueNotifier<List<Conversation>> conversations;

  DebateGamePage({Key? key, this.conversation, required this.conversations}) : super(key: key);

  @override
  State<DebateGamePage> createState() => _DebateGamePageState();
}

class _DebateGamePageState extends State<DebateGamePage> {
  // Flag to indicate if the page is still loading data
  bool isLoading = true;

  // List to store all messages in the debate
  late List<Message> messages = [];

  // WebSocket service for real-time communication
  late DebateAuthWebSocketService _webSocketService;

  // Default model configuration for the debate
  ModelConfig selectedModel = ModelConfig(
      model: const LanguageModel(model: 'dolphin-llama3', name: "dolphin-llama3", size: 21314),
      temperature: 0.06,
      numGenerations: 1
  );

  // Notifiers for various app-wide states
  late ValueNotifier<DisplayConfigData> displayConfigData;
  late ValueNotifier<Conversation?> currentSelectedConversation;
  late ValueNotifier<User> userModel;

  // Notifier to indicate if a message is being generated
  ValueNotifier<bool> isGenerating = ValueNotifier(false);

  // Variables to track generation progress and performance
  String generatedChat = "";
  double toksPerSec = 0.0;
  double completionTime = 0.0;
  int currentIdx = 0;

  @override
  void initState() {
    super.initState();

    // Initialize providers
    currentSelectedConversation = Provider.of<ValueNotifier<Conversation?>>(context, listen: false);
    displayConfigData = Provider.of<ValueNotifier<DisplayConfigData>>(context, listen: false);
    userModel = Provider.of<ValueNotifier<User>>(context, listen: false);

    // Initialize WebSocket service
    _webSocketService = DebateAuthWebSocketService('0.0.0.0:13341');

    // Load initial data and set up WebSocket
    initData();
    _initializeWebSocket();

    debugPrint("\t[ Debate :: GamePage initState ]");

    // If no topic is set, prompt for one after a short delay
    if (widget.conversation?.gameModel == null || widget.conversation!.gameModel.topic.isEmpty) {
      Future.delayed(const Duration(milliseconds: 400), () async {
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

  Future<void> _addNewAccounts() async {
    // This could be populated from a form in your UI
    Map<String, String> newAccounts = {
      'newUser1': 'password1',
      'newUser2': 'password2',
    };

    bool success = await _webSocketService.adminAddAccounts(newAccounts);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New accounts added successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add new accounts')),
      );
    }
  }

  // Initialize data by loading messages from the database
  Future<void> initData() async {
    debugPrint("[ init data ]");
    if (widget.conversation != null) {
      try {
        messages = await ConversationDatabase.instance.readAllMessages(widget.conversation!.id);
      } catch (e) {
        print(e);
      }
      currentSelectedConversation.value = widget.conversation;
      currentSelectedConversation.notifyListeners();
    }
    setState(() {
      isLoading = false;
    });
  }

  // Initialize WebSocket connection
  Future<void> _initializeWebSocket() async {
    bool loggedIn = await _webSocketService.login(userModel.value.username, 'password'); // Replace with actual password handling
    if (loggedIn) {
      bool sessionCreated = await _webSocketService.createOrJoinSession();
      if (sessionCreated) {
        bool connected = await _webSocketService.connectWebSocket();
        if (connected) {
          _listenToWebSocketMessages();
          debugPrint("\t[ WebSocket connected successfully ]");
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

  // Listen for incoming WebSocket messages
  void _listenToWebSocketMessages() {
    _webSocketService.messages.listen((message) {
      final data = json.decode(message);
      _handleWebSocketMessage(data);
    });
  }

  // Handle different types of WebSocket messages
  void _handleWebSocketMessage(Map<String, dynamic> data) {
    try {
      debugPrint('\t[ Received WebSocket message: ${json.encode(data)} ]');

      switch (data['status']) {
        case 'message_processed':
          debugPrint('\t\t[ Message processed: ${data['message_id']} ]');
          // Handle initial message processing
          // Example: Update UI to show message was received by server
          setState(() {
            // Find the message in the messages list and update its status
            int index = messages.indexWhere((m) => m.id == data['message_id']);
            if (index != -1) {
              // Assuming you have a method to update the message status
              //@note:@todo:@next:
              // messages[index].updateStatus('Processed');
            }
          });
          break;

        case 'initial_clusters':
          debugPrint('Received initial clusters: ${data['clusters']}');
          // Handle initial cluster data
          // Example: Display initial argument clusters
          _displayClusters(data['clusters'], isInitial: true);
          break;

        case 'updated_clusters':
          debugPrint('Received updated clusters: ${data['clusters']}');
          // Handle updated cluster data
          // Example: Update displayed argument clusters
          _displayClusters(data['clusters'], isInitial: false);
          break;

        case 'wepcc_result':
          debugPrint('Received WEPCC result for cluster: ${data['cluster_id']}');
          debugPrint('WEPCC details: ${data['wepcc_result']}');
          // Handle WEPCC (Warrant, Evidence, Persuasiveness, Claim, Counterclaim) result
          // Example: Update UI with WEPCC analysis
          _updateWEPCCAnalysis(data['cluster_id'], data['wepcc_result']);
          break;

        case 'final_results':
          debugPrint('Received final debate results');
          debugPrint('Aggregated scores: ${data['aggregated_scores']}');
          debugPrint('Addressed clusters: ${data['addressed_clusters']}');
          debugPrint('Unaddressed clusters: ${data['unaddressed_clusters']}');

          // Convert cluster IDs to strings
          Map<String, List<List<dynamic>>> addressedClusters = {};
          Map<String, List<List<dynamic>>> unaddressedClusters = {};

          data['addressed_clusters'].forEach((userId, clusters) {
            addressedClusters[userId] = (clusters as List<dynamic>).map((cluster) =>
            [cluster[0].toString(), cluster[1]]).toList();
          });

          data['unaddressed_clusters'].forEach((userId, clusters) {
            unaddressedClusters[userId] = (clusters as List<dynamic>).map((cluster) =>
            [cluster[0].toString(), cluster[1]]).toList();
          });

          _displayFinalResults(
              data['aggregated_scores'],
              addressedClusters,
              unaddressedClusters,
              data['results']
          );
          break;

        default:
          debugPrint('Unknown message type received: ${data['status']}');
      }
    } catch (e, stackTrace) {
      debugPrint('Error handling WebSocket message: $e');
      debugPrint('Stack trace: $stackTrace');
      // Optionally, you could show an error message to the user here
    }

    // Update UI based on received data
    setState(() {
      // Update relevant state variables based on the received data
      // This will trigger a rebuild of the widget tree
    });
  }

// Helper methods (implement these based on your UI requirements)

  void _displayClusters(Map<String, dynamic> clusters, {required bool isInitial}) {
    // Implement logic to display clusters in your UI
    print('${isInitial ? "Initial" : "Updated"} clusters displayed');
  }

  void _updateWEPCCAnalysis(String clusterId, Map<String, dynamic> wepccResult) {
    // Implement logic to update UI with WEPCC analysis
    print('WEPCC analysis updated for cluster $clusterId');
  }

  void _displayFinalResults(
      Map<String, dynamic> aggregatedScores,
      Map<String, dynamic> addressedClusters,
      Map<String, dynamic> unaddressedClusters,
      List<dynamic> results
      ) {
    // Implement logic to display final debate results
    debugPrint('Final debate results displayed');
    debugPrint('Aggregated scores: $aggregatedScores');
    debugPrint('Addressed clusters: $addressedClusters');
    debugPrint('Unaddressed clusters: $unaddressedClusters');
    debugPrint('Results: $results');

    // Update UI components to show the final results
    // For example:
    // setState(() {
    //   finalScores = aggregatedScores;
    //   finalAddressedClusters = addressedClusters;
    //   finalUnaddressedClusters = unaddressedClusters;
    //   finalResults = results;
    // });
  }


  // Callback function to handle chat generation progress and completion
  void generationCallback(Map<String, dynamic>? event) async {
    if (event != null) {
      EventGenerationResponse response = EventGenerationResponse.fromMap(event);

      generatedChat = response.generation;
      if (response.isCompleted) {
        debugPrint("\t\t[ chat completed ]");
        isGenerating.value = false;
        messages[currentIdx].isGenerating = false;
        completionTime = response.completionTime;
        messages[currentIdx].completionTime = completionTime;
        isGenerating.notifyListeners();

        setState(() {});

        // Save the final message to the database
        await ConversationDatabase.instance.createMessage(messages[currentIdx]);

        // Perform post-conversation analyses if enabled
        if (displayConfigData.value.showSidebarBaseAnalytics) {
          await _performPostConversationAnalyses();
        }
      } else {
        // Update generation progress
        toksPerSec = response.toksPerSec;
        completionTime = response.completionTime;
        _updateMessageWithGenerationProgress();
      }
    }
  }

  // Perform post-conversation analyses
  Future<void> _performPostConversationAnalyses() async {
    ConversationData? data = await LocalLLMInterface(displayConfigData.value.apiConfig)
        .getChatAnalysis(widget.conversation!.id);
    widget.conversation!.conversationAnalytics.value = data;
    widget.conversation!.conversationAnalytics.notifyListeners();

    if (displayConfigData.value.calcImageGen) {
      ImageFile? imageFile = await LocalLLMInterface(displayConfigData.value.apiConfig)
          .getConvToImage(widget.conversation!.id);
      if (imageFile != null) {
        widget.conversation!.convToImagesList.value.add(imageFile);
        widget.conversation!.convToImagesList.notifyListeners();
      }
    }
  }

  // Update message with generation progress
  void _updateMessageWithGenerationProgress() {
    try {
      messages[currentIdx].message!.value = generatedChat;
      messages[currentIdx].completionTime = completionTime;
      messages[currentIdx].isGenerating = true;
      messages[currentIdx].toksPerSec = toksPerSec;
      messages[currentIdx].message!.notifyListeners();
    } catch (e) {
      print("Error updating message with the latest result: ${e.toString()}");
    }
  }

  // Callback function to handle message analysis results
  void analysisCallBackFunction(dynamic userMessage, dynamic chatBotMessage) async {
    if (userMessage.isNotEmpty) {
      _updateMessageAnalytics(userMessage, isUserMessage: true);
    }
    if (chatBotMessage.isNotEmpty) {
      _updateMessageAnalytics(chatBotMessage, isUserMessage: false);
    }
  }

  // Update message analytics
  void _updateMessageAnalytics(dynamic messageData, {required bool isUserMessage}) {
    String msgId = messageData.keys.first;
    int idx = messages.indexWhere((element) => element.id == msgId);
    messages[idx].baseAnalytics.value = messageData[msgId];
    messages[idx].baseAnalytics.notifyListeners();
  }

  // Send a message to the model for processing
  void sendMessagetoModel(String text) async {
    debugPrint("[ Submitting: $text ]");
    final newChatBotMsgId = const Uuid().v4();

    // Send message via WebSocket
    _webSocketService.sendMessage(text, userModel.value.uid);

    // Create a new message object for the chatbot's response
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

    // Process the message using LocalLLMInterface (this might be replaced with WebSocket handling in the future)
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

  // Get the topic text for display
  String getTopicText(Conversation? conversation) {
    if (conversation?.gameModel != null) {
      return conversation!.gameModel.topic ?? "";
    }
    return "insert topic";
  }

  // Show error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }


  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : ChatRoomPage(
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
    );
  }

  // Handle new message from user
  Future<void> _handleNewMessage(Conversation? conv, String text, List<ImageFile> images) async {
    if (widget.conversation == null) {
      await _createNewConversation(text);
    }
    if (text.trim().isNotEmpty) {
      await _addNewMessage(text, images);
    }
    await _updateConversationState();
  }

// Replace the _createNewConversation method with this:
  Future<void> _createNewConversation(String text) async {
    Conversation newConversation = Conversation(
      id: const Uuid().v4(),
      lastMessage: text,
      gameType: GameType.chat,
      time: DateTime.now(),
      primaryModel: selectedModel.model.name,
      title: "Chat",
    );
    await ConversationDatabase.instance.create(newConversation);
    widget.conversations.value.insert(0, newConversation);
    widget.conversations.notifyListeners();
    currentSelectedConversation.value = newConversation;
    currentSelectedConversation.notifyListeners();

    // Update the local conversation reference
    setState(() {
      widget.conversation = newConversation;
    });
  }

  // Add a new message to the conversation
  Future<void> _addNewMessage(String text, List<ImageFile> images) async {
    Message message = Message(
        id: const Uuid().v4(),
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
    sendMessagetoModel(text);
  }

  // Update the conversation state
  Future<void> _updateConversationState() async {
    await ConversationDatabase.instance.update(widget.conversation!);
    int idx = widget.conversations.value.indexWhere((element) => element.id == widget.conversation!.id);
    widget.conversations.value[idx] = widget.conversation!;
    widget.conversations.value.sort((a, b) => b.time!.compareTo(a.time!));
    widget.conversations.notifyListeners();
  }

  @override
  void dispose() {
    _webSocketService.close();
    super.dispose();
  }

  Future<void> _showAddAccountsDialog() async {
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
              },
            ),
          ],
        );
      },
    );
  }
}