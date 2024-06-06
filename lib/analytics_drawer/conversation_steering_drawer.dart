import 'package:chat/models/conversation.dart';
import 'package:chat/models/conversation_settings.dart';
import 'package:chat/models/conversation_summary.dart';
import 'package:chat/models/display_configs.dart';
import 'package:chat/models/event_channel_model.dart';
import 'package:chat/models/llm.dart';
import 'package:chat/models/messages.dart';
import 'package:chat/models/suggestion_model.dart';
import 'package:chat/services/conversation_database.dart';
import 'package:chat/services/local_llm_interface.dart';
import 'package:chat/services/suggestions_query.dart';
import 'package:chat/services/tools.dart';
import 'package:chat/shared/chip_widget.dart';
import 'package:chat/shared/conv_steering_selector.dart';
import 'package:chat/shared/conversation_settings.dart';
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
  late ValueNotifier<List<ConversationSummary>> summaryMessages;
  late TabController _tabController;
  int pathIndex = 0;

  Map<String, List<Suggestion>> suggestionsMap = {};

  ModelConfig selectedModel = ModelConfig(
      model: const LanguageModel(
          model: 'dolphin-llama3', name: "dolphin-llama3", size: 21314),
      temperature: 0.06,
      numGenerations: 1);

  initSuggestionsData() async {
    suggestionsMap = await getSuggestionsMap() ?? {};
    setState(() {});
  }

  Future<void> initData() async {
    if (currentSelectedConversation.value != null) {
      try {
        // Load the meta conversation data form the conversation data class
        messages = currentSelectedConversation.value!.metaConvMessages;
        summaryMessages =
            currentSelectedConversation.value!.convSummaryMessages;
      } catch (e) {
        debugPrint(e.toString());
      }
    } else {
      messages = ValueNotifier([]);
      summaryMessages = ValueNotifier([]);
    }
  }

  late ValueNotifier<bool> isGeneratingSumm;
  late ValueNotifier<bool> isGenerating;

  @override
  void initState() {
    isGeneratingSumm = ValueNotifier(false);
    isGenerating = ValueNotifier(false);

    initSuggestionsData();

    _tabController = TabController(length: 3, vsync: this);
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

  // handles the meta chat response

  String generatedChat = "";
  double toksPerSec = 0.0;
  double completionTime = 0.0;
  int currentIdx = 0;

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

    LocalLLMInterface(displayConfigData.value.apiConfig).newChatMetaMessage(
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
                          buildGenerationSuggestions(context),
                          const SizedBox(height: 8),
                          buildQueryInput(context),
                          const SizedBox(height: 4),
                          buildModelSelector(context),
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

  ValueNotifier<bool> isExpanded = ValueNotifier<bool>(true);
  Widget buildSummaryResponseBox(ConversationSummary summary) {
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
                  padding: const EdgeInsets.fromLTRB(16, 15, 16, 0),
                  child: ValueListenableBuilder<String>(
                    valueListenable: summary.summary!.message!,
                    builder: (context, messageText, _) {
                      return Align(
                          alignment: Alignment.centerLeft,
                          child: SelectableText(messageText));
                    },
                  )),
            ),
            // This is an expansion toggle used in a prior UI version
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.only(right: 3.0),
            //       child: IconButton(
            //         icon: Icon(
            //           expanded
            //               ? CupertinoIcons.minus_rectangle
            //               : Icons.fit_screen,
            //           size: 20,
            //         ),
            //         color: const Color.fromARGB(255, 122, 11, 158),
            //         onPressed: () {
            //           isExpanded.value = !isExpanded.value;
            //         },
            //       ),
            //     ),
            //   ],
            // ),
          ],
        );
      },
    );
  }

  Widget buildResponseBox(ValueNotifier<List<Message>> messages) {
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
                padding: const EdgeInsets.fromLTRB(16, 15, 16, 0),
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
            // This is an expansion toggle used in a prior UI version
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.end,
            //   children: [
            //     Padding(
            //       padding: const EdgeInsets.only(right: 3.0),
            //       child: IconButton(
            //         icon: Icon(
            //           expanded
            //               ? CupertinoIcons.minus_rectangle
            //               : Icons.fit_screen,
            //           size: 20,
            //         ),
            //         color: const Color.fromARGB(255, 122, 11, 158),
            //         onPressed: () {
            //           isExpanded.value = !isExpanded.value;
            //         },
            //       ),
            //     ),
            //   ],
            // ),
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
            style: const TextStyle(
                color: Colors.black87, fontSize: 14, height: 1.3),
            textAlignVertical: TextAlignVertical.center,
            autocorrect: true,
          ),
          InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child:
                          const Text("Tips!—Get more from the conversation")),
                  content: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: const Text(
                        "Discuss what you are trying to achieve—be it trying to respond with certain emotion like lightheartedness, depth, caring, lovingness, anger or you want steer the conversation towards a particular outcome such as getting some kind of information, or receiving support for something you care about."),
                  ),
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
            child: const Icon(
              Icons.info_outline,
              color: Colors.black87,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  String chipHover = "relationship";
  ValueNotifier<String> selectedKey = ValueNotifier("relationship");
  Widget buildGenerationSuggestions(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 4,
        ),
        SizedBox(
          width: 290,
          child: Row(
            children: [
              const Text(
                "Starters:",
                style: TextStyle(fontSize: 10),
              ),
              Expanded(
                  child: Wrap(
                spacing: 3.0,
                runSpacing: 2.0,
                children: suggestionsMap.keys.map((key) {
                  bool isHoveringChip = chipHover == key;
                  bool isSelected = selectedKey.value == key;
                  return InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(14)),
                    onTap: () {
                      setState(() {
                        selectedKey.value = key;
                        selectedKey.notifyListeners();
                      });
                    },
                    child: MouseRegion(
                      onEnter: (_) => setState(() {
                        chipHover = key;
                      }),
                      onExit: (_) => setState(() {
                        chipHover = "-1";
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6.0, vertical: 2.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: isHoveringChip || isSelected
                                ? const Color.fromARGB(255, 122, 11, 158)
                                : Colors.grey,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (suggestionsMap[key]!.isNotEmpty)
                              Text(
                                suggestionsMap[key]!.first.emoji != null
                                    ? "${suggestionsMap[key]!.first.emoji} "
                                    : "",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isHoveringChip || isSelected
                                      ? const Color.fromARGB(255, 122, 11, 158)
                                      : Colors.black87,
                                ),
                              ),
                            Text(
                              key,
                              style: TextStyle(
                                fontSize: 10,
                                color: isHoveringChip || isSelected
                                    ? const Color.fromARGB(255, 122, 11, 158)
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ))
            ],
          ),
        ),
        ValueListenableBuilder<String>(
            valueListenable: selectedKey,
            builder: (context, selectkey, _) {
              // print("rebuilding");
              // print(selectkey);
              List<Suggestion> suggestions = suggestionsMap[selectkey] ?? [];
              Suggestion initSuggest = suggestions[0];
              return SizedBox(
                width: 290,
                child: ConversationSteeringSuggestor(
                  key: Key(selectkey),
                  initModel: initSuggest,
                  list: suggestions,
                  onSelectedModelChange: (Suggestion suggestion) {
                    queryController.text = suggestion.suggestion;

                    // selectedModel.model = model;
                  },
                ),
              );
            }),
      ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(
            child: Stack(alignment: Alignment.centerRight, children: [
              const Center(child: Text("Chat")),
              ValueListenableBuilder(
                  valueListenable: isGenerating,
                  builder: (_, isGen, widget) {
                    return isGen
                        ? const Padding(
                            padding: EdgeInsets.all(0),
                            child: CupertinoActivityIndicator(
                              radius: 8,
                            ),
                          )
                        : Container();
                  }),
            ]),
          ),
          const Tab(text: "Steer"),
          Tab(
            child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerRight,
                children: [
                  const Center(child: Text("Catch Up")),
                  ValueListenableBuilder(
                      valueListenable: isGeneratingSumm,
                      builder: (_, isGen, widget) {
                        return isGen
                            ? Positioned(
                                right: -16,
                                child: const Padding(
                                  padding: EdgeInsets.all(0),
                                  child: CupertinoActivityIndicator(
                                    radius: 8,
                                  ),
                                ),
                              )
                            : Container();
                      }),
                ]),
          ),
        ],
      ),
    );
  }

  Widget buildTabContent() {
    return IndexedStack(
      index: pathIndex,
      children: [
        buildChatTab(),
        buildSteerTab(),
        buildCatchUpTab(),
      ],
    );
  }

  Widget buildChatTab() {
    return buildResponseBox(messages);
  }

  final List<String> _currencies = [
    "People",
    "Personalities",
    "Knowledge",
    "the information unsaid",
    "list implications of actions",
    "Struggles",
    "Emotions"
  ];

  String _currentSelectedValue = "Food";
  final TextEditingController _textController = TextEditingController();
  final LayerLink _layerLink = LayerLink();

  void _showDropdownMenu(BuildContext context) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final button = context.findRenderObject() as RenderBox;
    final position = button.localToGlobal(Offset.zero, ancestor: overlay);

    final selectedValue = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy,
          position.dx + button.size.width, position.dy + button.size.height),
      items: _currencies.map((String value) {
        return PopupMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );

    if (selectedValue != null) {
      setState(() {
        _currentSelectedValue = selectedValue;
        _textController.text = selectedValue;
      });
    }
  }

  // handles the meta chat response

  String generatedSummaryChat = "";
  double summToksPerSec = 0.0;
  double summCompletionTime = 0.0;
  int currentSummIdx = 0;

  summaryCallbackFunction(Map<String, dynamic>? event) async {
    if (event != null) {
      EventGenerationResponse response = EventGenerationResponse.fromMap(event);

      generatedSummaryChat = response.generation;
      if (response.isCompleted) {
        debugPrint("\t\t[ chat completed ]");
        // end token is received
        isGeneratingSumm.value = false;
        summaryMessages.value[currentSummIdx].summary!.isGenerating = false;
        summCompletionTime = response.completionTime;
        summaryMessages.value[currentSummIdx].summary!.completionTime =
            summCompletionTime;
        isGeneratingSumm.notifyListeners();
        setState(() {});
        // add the final message to the database
        // ConversationDatabase.instance
        //     .createMessage(summaryMessages.value[currentSummIdx]);

        // Run follow-up functions
        if (computeFollowUpChatOptions) {}
      } else {
        summToksPerSec = response.toksPerSec;
        while (generatedSummaryChat.startsWith("\n")) {
          generatedSummaryChat = generatedSummaryChat.substring(2);
        }
        summCompletionTime = response.completionTime;
        try {
          summaryMessages.value[currentSummIdx].summary!.message!.value =
              generatedSummaryChat;
          summaryMessages.value[currentSummIdx].summary!.completionTime =
              summCompletionTime;
          summaryMessages.value[currentSummIdx].summary!.isGenerating = true;
          summaryMessages.value[currentSummIdx].summary!.toksPerSec =
              summToksPerSec;

          // Notify the value listeners
          summaryMessages.value[currentSummIdx].summary!.message!
              .notifyListeners();
        } catch (e) {
          print(
              "Error updating message with the latest result: ${e.toString()}");
          print("The generation was: $generatedChat");
        }
        // setState(() {});
      }
    }
  }

  String? convSummaryConvId;

  void generateConversationSummary() async {
    // TODO Add the user info to the ConversationSummaryModel
    // uiMessage.Message message = uiMessage.Message(
    //     id: Tools().getRandomString(12),
    //     conversationID: metaMessageConvId,
    //     message: ValueNotifier(queryController.text),
    //     documentID: '',
    //     name: 'User',
    //     senderID: '',
    //     status: '',
    //     timestamp: DateTime.now(),
    //     type: uiMessage.MessageType.text);

    // summaryMessages.value.add(message);
    // summaryMessages.notifyListeners();

    setState(() {
      isGeneratingSumm.value = true;
    });

    debugPrint(
        "[ Submitting: focal-point ${_textController.text} ]"); // General debug print
    final newChatBotMsgId = Tools().getRandomString(32);
    currentSummIdx = summaryMessages.value.length;
    LocalLLMInterface(displayConfigData.value.apiConfig).genChatSummary(
      _textController.text,
      currentSelectedConversation.value!.id,
      selectedModel,
      summaryCallbackFunction,
    );
    // Create message object
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
    summaryMessages.value.add(ConversationSummary(
        id: Tools().getRandomString(12),
        summary: botMessage,
        focalPoint: _textController.text));
    selectedSummaryIndex.value = currentSummIdx;
    selectedSummaryIndex.notifyListeners();
    summaryMessages.notifyListeners();
  }

  ValueNotifier<int> selectedSummaryIndex = ValueNotifier<int>(0);
  ScrollController scrollSummaryController = ScrollController();
  Widget buildCatchUpTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
                  ),
                ),
                onPressed: () async {
                  generateConversationSummary();
                },
                child: const Text(
                  "Summarize",
                  style: TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              SizedBox(
                  height: 38,
                  width: 150,
                  child: FormField<String>(
                    builder: (FormFieldState<String> state) {
                      return InputDecorator(
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.fromLTRB(10, 0, 6, 0),
                          errorStyle: const TextStyle(
                              color: Colors.redAccent, fontSize: 12.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        isEmpty: _currentSelectedValue == null ||
                            _currentSelectedValue.isEmpty,
                        child: CompositedTransformTarget(
                          link: _layerLink,
                          child: Builder(builder: (formCtx) {
                            return Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _textController,
                                    onChanged: (String newValue) {
                                      setState(() {
                                        _currentSelectedValue = newValue;
                                        state.didChange(newValue);
                                      });
                                    },
                                    style: const TextStyle(fontSize: 13),
                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Enter a focus...',
                                        hintStyle: TextStyle(fontSize: 13)),
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20)),
                                      onTap: () => _showDropdownMenu(formCtx),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: Center(
                                              child: Transform.rotate(
                                                angle: -90 *
                                                    3.1415926535897932 /
                                                    180,
                                                child: const Icon(
                                                  Icons.chevron_left,
                                                  size: 18,
                                                ),
                                              ),
                                            )),
                                      )),
                                ),
                              ],
                            );
                          }),
                        ),
                      );
                    },
                  ))
            ],
          ),
          ValueListenableBuilder<List<ConversationSummary>>(
              valueListenable: summaryMessages,
              builder: (context, summaries, _) {
                return ValueListenableBuilder<int>(
                    valueListenable: selectedSummaryIndex,
                    builder: (context, idx, _) {
                      if (summaries.isEmpty) return Container();
                      List<Widget> tabs =
                          List.generate(summaries.length, (index) {
                        return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Tooltip(
                              waitDuration: const Duration(milliseconds: 250),
                              key: UniqueKey(),
                              message: summaries[index].focalPoint,
                              preferBelow: false,
                              child: CustomChip(
                                index: index,
                                isSelected: selectedSummaryIndex.value == index,
                                onTap: () {
                                  selectedSummaryIndex.value = index;
                                },
                              ),
                            ));
                      });
                      return Column(
                        children: [
                          const SizedBox(height: 8),
                          SingleChildScrollView(
                            controller: scrollSummaryController,
                            scrollDirection: Axis.horizontal,
                            child: Scrollbar(
                              controller: scrollSummaryController,
                              thickness: 8,
                              child: Row(children: tabs),
                            ),
                          ),
                          buildSummaryResponseBox(summaries[idx]),
                        ],
                      );
                    });
              })
        ],
      ),
    );
  }

  ValueNotifier<List<ConversationOptionsResponse>> suggestedNextStepIdeas =
      ValueNotifier([]);
  ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);
  ScrollController scrollController = ScrollController();
  ValueNotifier<bool> showSettings = ValueNotifier(false);
  ConversationVoiceSettings _settings = ConversationVoiceSettings(
    attention: "inclusive",
    tone: "friendly",
    distance: "cordial",
    pace: "leisurely",
    depth: "insightful",
    engagement: "engaging",
    messageLength: "brief",
  );
  Widget buildSteerTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                ConversationVoiceSettings submitSettings =
                    ConversationVoiceSettings.fromJson(_settings.toJson());
                debugPrint("\t\t[ generating conversation options ]");
                String? nextStepResponse =
                    await LocalLLMInterface(displayConfigData.value.apiConfig)
                        .getNextMessageOptions(
                            currentSelectedConversation.value!.id,
                            messages.value,
                            selectedModel.model.model,
                            submitSettings);
                if (nextStepResponse != null) {
                  if (nextStepResponse.trim().isNotEmpty) {
                    suggestedNextStepIdeas.value.add(
                        ConversationOptionsResponse(
                            text: nextStepResponse, settings: submitSettings));
                    suggestedNextStepIdeas.notifyListeners();
                    selectedIndex.value =
                        suggestedNextStepIdeas.value.length - 1;
                    selectedIndex.notifyListeners();
                  }
                }
              },
              child: const Text("Generate"),
            ),
            const SizedBox(
              width: 12,
            ),
            ValueListenableBuilder(
              valueListenable: showSettings,
              builder: (context, value, child) {
                final theme = Theme.of(context);
                final colorScheme = theme.colorScheme;
                final highlightColor = colorScheme.primary.withOpacity(0.2);
                final iconColor = colorScheme.primary;
                return InkWell(
                  onTap: () {
                    showSettings.value = !showSettings.value;
                    showSettings.notifyListeners();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: value ? highlightColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      CupertinoIcons.slider_horizontal_3,
                      color: value ? iconColor : Colors.black,
                    ),
                  ),
                );
              },
            )
          ],
        ),
        ValueListenableBuilder<bool>(
            valueListenable: showSettings,
            builder: (context, show, _) {
              if (!show) return Container();
              return Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  constraints: const BoxConstraints(maxWidth: 290),
                  child: ConversationSettingsPage(
                    initSettings: _settings,
                    onChange: ((ConversationVoiceSettings updatedSettings) {
                      _settings = updatedSettings;
                    }),
                  ));
            }),
        const SizedBox(height: 10),
        ValueListenableBuilder<List<ConversationOptionsResponse>>(
            valueListenable: suggestedNextStepIdeas,
            builder: (context, nextsteps, _) {
              return ValueListenableBuilder<int>(
                valueListenable: selectedIndex,
                builder: (context, value, _) {
                  if (suggestedNextStepIdeas.value.isEmpty) return Container();

                  List<Widget> tabs = List.generate(
                      suggestedNextStepIdeas.value.length, (index) {
                    return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Tooltip(
                          waitDuration: const Duration(milliseconds: 250),
                          key: UniqueKey(),
                          message: suggestedNextStepIdeas.value[index].settings
                              .toString(),
                          preferBelow: false,
                          child: CustomChip(
                            index: index,
                            isSelected: selectedIndex.value == index,
                            onTap: () {
                              selectedIndex.value = index;
                            },
                          ),
                        ));
                  });
                  tabs.insert(
                      0,
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(14)),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title:
                                      const Text('Conversation Voice Settings'),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Attention: ${_settings.attention}'),
                                      Text('Tone: ${_settings.tone}'),
                                      Text('Distance: ${_settings.distance}'),
                                      Text('Pace: ${_settings.pace}'),
                                      Text('Depth: ${_settings.depth}'),
                                      Text(
                                          'Engagement: ${_settings.engagement}'),
                                      Text(
                                          'Message Length: ${_settings.messageLength}'),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Close'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.topRight,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 14,
                                ),
                                Positioned(
                                  top: -2,
                                  right: -2,
                                  child: Icon(
                                    Icons.settings,
                                    size: 9,
                                  ),
                                ),
                              ]),
                        ),
                      ));
                  return Column(
                    children: [
                      SingleChildScrollView(
                        controller: scrollController,
                        scrollDirection: Axis.horizontal,
                        child: Scrollbar(
                          controller: scrollController,
                          thickness: 8,
                          child: Row(children: tabs),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SelectableText(
                          suggestedNextStepIdeas.value[value].text,
                          // context,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  );
                },
              );
            }),
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
                    "Steering",
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
