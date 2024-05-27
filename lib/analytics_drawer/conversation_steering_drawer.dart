import 'package:chat/models/conversation.dart';
import 'package:chat/models/display_configs.dart';
import 'package:chat/models/event_channel_model.dart';
import 'package:chat/models/llm.dart';
import 'package:chat/models/messages.dart';
import 'package:chat/services/conversation_database.dart';
import 'package:chat/services/local_llm_interface.dart';
import 'package:chat/services/tools.dart';
import 'package:chat/shared/model_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:load_switch/load_switch.dart';
import 'package:provider/provider.dart';
import 'package:chat/models/messages.dart' as uiMessage;

class ConvSteeringDrawer extends StatefulWidget {
  final onTap;
  const ConvSteeringDrawer({this.onTap, super.key});

  @override
  State<ConvSteeringDrawer> createState() => _ConvSteeringDrawerState();
}

class _ConvSteeringDrawerState extends State<ConvSteeringDrawer>
    with SingleTickerProviderStateMixin {
  bool didInit = false;

  late ValueNotifier<DisplayConfigData> displayConfigData;
  late ValueNotifier<Conversation?> currentSelectedConversation;
  late ValueNotifier<List<uiMessage.Message>> messages;
  late TabController _tabController;
  int pathIndex = 0;

  ModelConfig selectedModel = ModelConfig(
      model: const LanguageModel(
          model: 'dolphin-llama3', name: "dolphin-llama3", size: 21314),
      temperature: 0.06,
      numGenerations: 1);

  Future<void> initData() async {
    if (currentSelectedConversation.value != null) {
      try {
        // Load the meta conversation data form the conversation data class
        messages = currentSelectedConversation.value!.metaConvMessages;
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      messages = ValueNotifier([]);
    }
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        pathIndex = _tabController.index;
      });
    });

    displayConfigData =
        Provider.of<ValueNotifier<DisplayConfigData>>(context, listen: false);
    currentSelectedConversation =
        Provider.of<ValueNotifier<Conversation?>>(context, listen: false);

    Future.delayed(const Duration(milliseconds: 90),
        () => mounted ? setState((() => didInit = true)) : null);
    initData();
    debugPrint("\t[ Chat :: ConvSteeringPage initState ]");
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    queryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool value = true;
  bool computeFollowUpChatOptions = false;

  Future<bool> _getFuture() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return !value;
  }

  TextEditingController queryController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // handles the chat response

  String generatedChat = "";
  double toksPerSec = 0.0;
  double completionTime = 0.0;
  int currentIdx = 0;
  ValueNotifier<bool> isGenerating = ValueNotifier(false);

  generationCallback(Map<String, dynamic>? event) async {
    if (event != null) {
      double completionTime = 0.0;

      EventGenerationResponse response = EventGenerationResponse.fromMap(event);

      generatedChat = response.generation;
      if (response.isCompleted) {
        debugPrint("\t\t[ chat completed ]");
        // end token is received
        isGenerating.value = false;
        messages.value[currentIdx].isGenerating = false;
        completionTime = response.completionTime;
        messages.value[currentIdx].completionTime = completionTime;
        isGenerating.notifyListeners();

        setState(() {});
        // add the final message to the database
        ConversationDatabase.instance.createMessage(messages.value[currentIdx]);

        // Run follow-up functions
        if (computeFollowUpChatOptions) {}
      } else {
        toksPerSec = response.toksPerSec;
        while (generatedChat.startsWith("\n")) {
          generatedChat = generatedChat.substring(2);
        }
        completionTime = response.completionTime;
        try {
          messages.value[currentIdx].message!.value = generatedChat;
          messages.value[currentIdx].completionTime = completionTime;
          messages.value[currentIdx].isGenerating = true;
          messages.value[currentIdx].toksPerSec = toksPerSec;

          // Notify the value listeners
          messages.value[currentIdx].message!.notifyListeners();
        } catch (e) {
          print(
              "Error updating message with the latest result: ${e.toString()}");
          print("The generation was: $generatedChat");
        }
        // setState(() {});
      }
    }
  }

  // handles the analysis from the chat response
  // this includes: in-line values- token and text classification
  // and returns the response for both the initial user message and the chatbot's message
  analysisCallBackFunction(dynamic userMessage, dynamic chatBotMessage) async {
    // NOTHING ON THIS YET
  }

  String? metaMessageConvId;

  void sendMessagetoModel(
    String text,
    List<Message> metaMessages,
  ) async {
    // if no conversation is selected yet
    // if (currentSelectedConversation.value == null) {
    //   currentSelectedConversation.value = Conversation(
    //     id: Tools().getRandomString(12),
    //     lastMessage: text,
    //     gameType: GameType.chat,
    //     time: DateTime.now(),
    //     primaryModel: selectedModel.model.name,
    //     title: "Chat",
    //   );
    //   // currentSelectedConversation.notifyListeners();
    // }

    // Add the user message to the conversation
    uiMessage.Message message = uiMessage.Message(
        id: Tools().getRandomString(12),
        conversationID: metaMessageConvId,
        message: ValueNotifier(queryController.text),
        documentID: '',
        name: 'User',
        senderID: '',
        status: '',
        timestamp: DateTime.now(),
        type: uiMessage.MessageType.text);

    messages.value.add(message);
    messages.notifyListeners();

    // Get conversationID of the present conversation
    List<Message>? actualConversation;
    String convId = currentSelectedConversation.value!.id;

    // Load the actual conversation to send to the database
    try {
      actualConversation =
          await ConversationDatabase.instance.readAllMessages(convId);
    } catch (e) {
      print(e);
    }

    setState(() {
      isGenerating.value = true;
    });

    assert(actualConversation != null);

    debugPrint("[ Submitting: $text ]"); // General debug print
    final newChatBotMsgId = Tools().getRandomString(32);

    LocalLLMInterface().newChatMetaMessage(
        text,
        metaMessages,
        actualConversation!,
        metaMessageConvId!,
        newChatBotMsgId,
        selectedModel,
        displayConfigData.value,
        generationCallback,
        analysisCallBackFunction);

    debugPrint("[ Message Submitted: $text ]");
    currentIdx = metaMessages.length;
    // Submit text to generator here
    uiMessage.Message botMessage = uiMessage.Message(
        id: newChatBotMsgId,
        conversationID: metaMessageConvId,
        message: ValueNotifier(""),
        documentID: '',
        name: 'ChatBot',
        senderID: 'assistant',
        status: '',
        timestamp: DateTime.now(),
        type: uiMessage.MessageType.text);
    messages.value.add(botMessage);
    messages.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return !didInit
        ? Container()
        : ValueListenableBuilder<Conversation?>(
            valueListenable: currentSelectedConversation,
            builder: (context, conversation, _) {
              initData(); // Initialize data when a new conversation is selected
              metaMessageConvId = messages.value.isEmpty
                  ? Tools().getRandomString(12)
                  : messages.value.first.id;
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          buildQueryInput(context),
                          const SizedBox(height: 4),
                          buildModelSelector(context),
                          buildResponseBox(),
                          buildTabBar(),
                          buildTabContent(),
                        ],
                      ),
                    ),
                  ),
                  buildFooter(context),
                ],
              );
            },
          );
  }

  ValueNotifier<bool> isExpanded = ValueNotifier<bool>(false);

  Widget buildResponseBox() {
    return ValueListenableBuilder<bool>(
      valueListenable: isExpanded,
      builder: (context, expanded, _) {
        return Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              constraints: expanded
                  ? null
                  : const BoxConstraints(
                      minHeight: 150,
                      maxHeight: 150,
                    ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 5, 16, 0),
                child: ValueListenableBuilder<List<Message>>(
                  valueListenable: messages,
                  builder: (context, messagesList, _) {
                    if (messagesList.isEmpty) return Container();
                    return ValueListenableBuilder<String>(
                      valueListenable: messagesList.last.message!,
                      builder: (context, messageText, _) {
                        return SelectableText(messageText);
                      },
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 3.0),
              child: IconButton(
                icon: Icon(
                  expanded ? CupertinoIcons.minus_rectangle : Icons.fit_screen,
                  size: 20,
                ),
                color: const Color.fromARGB(255, 122, 11, 158),
                onPressed: () {
                  isExpanded.value = !isExpanded.value;
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildQueryInput(BuildContext context) {
    return SizedBox(
      width: 290,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          TextField(
            controller: queryController,
            keyboardType: TextInputType.text,
            minLines: 4,
            maxLines: 4,
            focusNode: _focusNode,
            onSubmitted: (String text) {
              if (text.trim().isNotEmpty) {
                sendMessagetoModel(text.trim(), messages.value);
                queryController.clear();
                _focusNode.requestFocus();
              }
            },
            decoration: InputDecoration(
              hintText: "Steer the conversation...",
              hintStyle: const TextStyle(color: Colors.black38),
              filled: true,
              focusColor: Colors.grey.withOpacity(.5),
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            cursorColor: Colors.black38,
            style: const TextStyle(color: Colors.black87, fontSize: 14),
            textAlignVertical: TextAlignVertical.center,
            autocorrect: true,
          ),
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Tips!—Get more from the conversation"),
                  content: const Text(
                      "Discuss what you are trying to achieve—be it trying to respond with certain emotion like lightheartedness, depth, caring, lovingness, anger or you want steer the conversation towards a particular outcome such as getting some kind of information, or receiving support for something you care about."),
                  actions: [
                    InkWell(
                      child: const Text("OK"),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            },
            child: const Icon(Icons.info_outline, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget buildModelSelector(BuildContext context) {
    return SizedBox(
      width: 290,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ModelSelector(
            initModel: selectedModel.model,
            onSelectedModelChange: (LanguageModel model) {
              selectedModel.model = model;
            },
          ),
          Row(
            children: [
              TextButton(
                onPressed: () async {
                  if (queryController.text.trim().isNotEmpty) {
                    sendMessagetoModel(
                        queryController.text.trim(), messages.value);
                  }
                },
                child: const Text("Submit"),
              ),
              const SizedBox(width: 2),
              InkWell(
                onTap: () {},
                child:
                    const Icon(Icons.refresh, color: Colors.black87, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: "Steer"),
        Tab(text: "Catch Up"),
      ],
    );
  }

  Widget buildTabContent() {
    return IndexedStack(
      index: pathIndex,
      children: [
        buildSteerTab(),
        buildCatchUpTab(),
      ],
    );
  }

  Widget buildCatchUpTab() {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        ElevatedButton(
          onPressed: () async {
            LocalLLMInterface().getNextMessageOptions(
              currentSelectedConversation.value!.id,
              messages.value,
              selectedModel.model.model,
            );
          },
          child: const Text("Summarize"),
        ),
        ElevatedButton(
          onPressed: () async {
            LocalLLMInterface().getNextMessageOptions(
              currentSelectedConversation.value!.id,
              messages.value,
              selectedModel.model.model,
            );
          },
          child: const Text("Get Topics"),
        ),
      ],
    );
  }

  Widget buildSteerTab() {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        ElevatedButton(
          onPressed: () async {
            LocalLLMInterface().getNextMessageOptions(
              currentSelectedConversation.value!.id,
              messages.value,
              selectedModel.model.model,
            );
          },
          child: const Text("Gen Options"),
        ),
      ],
    );
  }

  Widget buildFooter(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: null,
          child: Padding(
            padding: const EdgeInsets.only(left: 18.0),
            child: SizedBox(
              height: 45,
              child: Row(
                children: [
                  const Icon(Icons.view_module_outlined),
                  const SizedBox(width: 5),
                  Text(
                    "Conversation Steering",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(child: Container()),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(value ? "On" : "Off"),
            const SizedBox(width: 15),
            SizedBox(
              width: 42,
              child: LoadSwitch(
                height: 23,
                width: 38,
                value: value,
                future: _getFuture,
                style: SpinStyle.material,
                switchDecoration: (value, isActive) => BoxDecoration(
                  color: value
                      ? const Color.fromARGB(255, 122, 11, 158)
                      : const Color.fromARGB(255, 193, 193, 193),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: value
                          ? const Color.fromARGB(255, 222, 222, 222)
                          : const Color.fromARGB(255, 213, 213, 213),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                spinColor: (value) => const Color.fromARGB(255, 125, 73, 182),
                onChange: (v) {
                  value = v;
                  print('Value changed to $v');
                  setState(() {});
                },
                onTap: (v) {
                  print('Tapping while value is $v');
                },
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ],
    );
  }
}
