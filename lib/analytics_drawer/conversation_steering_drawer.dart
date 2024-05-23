import 'package:chat/models/conversation.dart';
import 'package:chat/models/display_configs.dart';
import 'package:chat/models/event_channel_model.dart';
import 'package:chat/models/llm.dart';
import 'package:chat/models/messages.dart';
import 'package:chat/services/conversation_database.dart';
import 'package:chat/services/local_llm_interface.dart';
import 'package:chat/services/tools.dart';
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

class _ConvSteeringDrawerState extends State<ConvSteeringDrawer> {
  bool didInit = false;

  late ValueNotifier<DisplayConfigData> displayConfigData;
  late ValueNotifier<Conversation?> currentSelectedConversation;
  bool isLoading = true;

  late ValueNotifier<List<uiMessage.Message>> messages;

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
        print(e);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
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

  void sendMessagetoModel(
    String text,
    List<Message> metaMessages,
  ) async {
    String metaMessageConvId = metaMessages.isEmpty
        ? Tools().getRandomString(12)
        : metaMessages.first.id;

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
      // start generation
      isGenerating.value = true;
    });

    assert(actualConversation != null);

    debugPrint("[ Submitting: $text ]"); // General debug print
    final newChatBotMsgId = Tools().getRandomString(32);

    LocalLLMInterface().newChatMetaMessage(
        text,
        metaMessages,
        actualConversation!,
        metaMessageConvId,
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
        : Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 3,
                        ),
                        SizedBox(
                          width: 290,
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              TextField(
                                controller: queryController,
                                keyboardType: TextInputType.text,
                                minLines: 3,
                                maxLines: 3,
                                focusNode: _focusNode,
                                onSubmitted: (String text) {
                                  if (text.trim() != "") {
                                    sendMessagetoModel(
                                        text.trim(), messages.value);
                                    queryController.clear();
                                    _focusNode.requestFocus();
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: "Steer the conversation...",
                                  hintStyle:
                                      const TextStyle(color: Colors.black38),
                                  filled: true,
                                  // hoverColor: Colors.grey.withOpacity(.5),
                                  focusColor: Colors.grey.withOpacity(.5),
                                  fillColor:
                                      Theme.of(context).colorScheme.surface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                                cursorColor: Colors.black38,
                                style: const TextStyle(color: Colors.black87),
                                textAlignVertical: TextAlignVertical.center,
                                autocorrect: true,
                              ),
                              InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text(
                                          "Tips!—Get more from the conversation"),
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
                                child: const Icon(
                                  Icons.info_outline,
                                  color: Colors.black87,
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        SizedBox(
                          width: 290,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  onPressed: () async {
                                    if (queryController.text.trim() != "") {
                                      sendMessagetoModel(
                                          queryController.text.trim(),
                                          messages.value);
                                    }
                                  },
                                  child: const Text("Submit")),
                              const SizedBox(
                                width: 2,
                              ),
                              InkWell(
                                onTap: () {},
                                child: const Icon(
                                  Icons.refresh,
                                  color: Colors.black87,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // DISPLAY THE CONVERSATION STEERING CONVERSATION HERE
                        // Display only the last AI message, and display it streaming
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ValueListenableBuilder<List<Message>>(
                              valueListenable: messages,
                              builder: (context, messagesList, _) {
                                print(
                                    "NEW MESSAGE ADDED TO UI: NEW LENGTH ${messagesList.length}");
                                if (messagesList.isEmpty) return Container();
                                print(messagesList.last
                                    .message); // switch this to the last Bot Message
                                return ValueListenableBuilder<String>(
                                    valueListenable: messagesList.last.message!,
                                    builder: (context, messageText, _) {
                                      print("RESPONSE: $messageText");
                                      return SelectionArea(
                                          child: Text(messageText));
                                    });
                              }),
                        ),
                        // DISPLAY A LIST OF NEXT THINGS TO SAY (INSERT THEM INTO THE CONVERSATION TEXTFIELD ON TAP)
                      ],
                    ),
                  ),
                ),
                Row(children: [
                  InkWell(
                      onTap: null,
                      // () {
                      //   widget.onTap();
                      // },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 18.0),
                        child: SizedBox(
                          height: 45,
                          child: Row(
                            children: [
                              const Icon(Icons.view_module_outlined),
                              const SizedBox(
                                width: 5,
                              ),
                              Text("Conversation Steering",
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                            ],
                          ),
                        ),
                      )),
                  Expanded(child: Container()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(value ? "On" : "Off"),
                      const SizedBox(
                        width: 15,
                      ),
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
                                ? Color.fromARGB(255, 122, 11, 158)
                                : Color.fromARGB(255, 193, 193, 193),
                            borderRadius: BorderRadius.circular(30),
                            shape: BoxShape.rectangle,
                            boxShadow: [
                              BoxShadow(
                                color: value
                                    ? const Color.fromARGB(255, 222, 222, 222)
                                    : const Color.fromARGB(255, 213, 213, 213),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(
                                    0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          spinColor: (value) => value
                              ? const Color.fromARGB(255, 125, 73, 182)
                              : const Color.fromARGB(255, 125, 73, 182),
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
                      const SizedBox(
                        width: 8,
                      ),
                    ],
                  )
                ]),
              ]);
  }
}
