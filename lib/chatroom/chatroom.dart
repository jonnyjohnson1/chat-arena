import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat/chatroom/widgets/message_field/message_field.dart';
import 'package:chat/chatroom/widgets/message_list_view.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/models/event_channel_model.dart';
import 'package:chat/models/messages.dart' as uiMessage;
import 'package:chat/models/model_loaded_states.dart';
import 'package:chat/services/conversation_database.dart';
import 'package:chat/services/tools.dart';
import 'package:provider/provider.dart';
// import 'package:file_selector/file_selector.dart';

import '../services/ios_platform_interface.dart';
import '../services/ios_system_resources.dart';

class ChatRoomPage extends StatefulWidget {
  Conversation? conversation;
  final onCreateNewConversation;
  final onNewText;
  // final UserData userData;
  final ValueNotifier<ModelLoadedState>? modelLoadedState;

  ChatRoomPage(
      {required this.conversation,
      this.onCreateNewConversation,
      this.modelLoadedState,
      this.onNewText,
      Key? key})
      : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  // late DialogFlowtter dialogFlowtter;

  final ScrollController _listViewController = ScrollController();

  late List<uiMessage.Message> messages = [];

  List<Map<String, dynamic>> dialogFlowMessages = [];
  // late SwiftFunctionsInterface swiftFunctions;
  ValueNotifier<bool> isGenerating = ValueNotifier(false);

  bool isIphone = false;

  bool isLoading = true;

  Future<void> initData() async {
    isIphone = await SystemResources().isIphone();
    // load all messages from database
    if (widget.conversation != null) {
      try {
        messages = await ConversationDatabase.instance
            .readAllMessages(widget.conversation!.id);
      } catch (e) {
        print(e);
      }
      try {
        print("TODO here");
        // var result = await swiftFunctions.loadMessagesIntoModel(messages);
      } catch (e) {
        print("error loading messages: ${e.toString()}");
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // swiftFunctions =
    //     Provider.of<SwiftFunctionsInterface>(context, listen: false);
    // DialogFlowtter.fromFile().then((instance) => dialogFlowtter = instance);
    initData();
  }

  String generatedChat = "";
  double progress = 0.0;
  double toksPerSec = 0.0;
  double completionTime = 0.0;
  int currentIdx = 0;

  generationCallback(Object? event) {
    if (event != null) {
      completionTime = 0.0;
      progress = 0.0;
      // Convert Object? event to JSON string
      String jsonString = jsonEncode(event);
      // Decode JSON string into Map<String, dynamic>
      Map<String, dynamic> eventMap = jsonDecode(jsonString);

      EventGenerationResponse response =
          EventGenerationResponse.fromMap(eventMap);

      generatedChat = response.generation;
      if (generatedChat == "<!!COMPLETE!!>") {
        // end token is received
        isGenerating.value = false;
        messages[currentIdx].isGenerating = false;
        isGenerating.notifyListeners();
        // add the final message to the database
        ConversationDatabase.instance.createMessage(messages[currentIdx]);
      } else {
        progress = response.progress;
        toksPerSec = response.toksPerSec;
        while (generatedChat.startsWith("\n")) {
          generatedChat = generatedChat.substring(2);
        }
        completionTime = response.completionTime;
        try {
          messages[currentIdx].message = generatedChat;
          messages[currentIdx].completionTime = completionTime;
          messages[currentIdx].isGenerating = true;
          messages[currentIdx].toksPerSec = toksPerSec;
        } catch (e) {
          print(
              "Error updating message with the latest result: ${e.toString()}");
          print("The generation was: $generatedChat");
        }
        setState(() {});
      }
    } else {
      // return null event generation
      // return const EventGenerationResponse(generation: "", progress: 0.0);
    }
  }

  void sendMessagetoModel(String text) async {
    print("Submitting: $text to chat model");
    currentIdx = messages.length;
    // swiftFunctions.initGenerationStream(text, generationCallback);
    if (text.isEmpty) return;
    // Submit text to generator here
    uiMessage.Message _message = uiMessage.Message(
        id: Tools().getRandomString(12),
        conversationID: widget.conversation!.id,
        message: "",
        documentID: '',
        name: 'ChatBot',
        senderID: 'bot13451234',
        status: '',
        timestamp: DateTime.now(),
        type: uiMessage.MessageType.text);
    messages.add(_message);
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<File> selectedImages = []; // List of selected image
  final picker = ImagePicker(); // Instance of Image picker

  Future removeImage(int index) async {
    setState(() {
      {
        selectedImages.removeAt(index);
      }
    });
  }

  Future getImages() async {
    List<XFile> files = [];
    if (Platform.isAndroid || Platform.isIOS) {
      print("Platform is mobile platform");
      // Android-specific code
      files = await picker.pickMultiImage(
          imageQuality: 100, // To set quality of images
          maxHeight:
              1000, // To set maxheight of images that you want in your app
          maxWidth:
              1000); // To set maxheight of images that you want in your app
    } else if (Platform.isMacOS) {
      // print("Platform is macOS");
      // // iOS-specific code
      // const XTypeGroup jpgsTypeGroup = XTypeGroup(
      //   label: 'JPEGs',
      //   extensions: <String>['jpg', 'jpeg'],
      // );
      // const XTypeGroup pngTypeGroup = XTypeGroup(
      //   label: 'PNGs',
      //   extensions: <String>['png'],
      // );
      // files = await openFiles(acceptedTypeGroups: <XTypeGroup>[
      //   jpgsTypeGroup,
      //   pngTypeGroup,
      // ]);
    }

    // if atleast 1 images is selected it will add
    // all images in selectedImages
    // variable so that we can easily show them in UI
    if (files.isNotEmpty) {
      for (var i = 0; i < files.length; i++) {
        selectedImages.add(File(files[i].path));
      }
      setState(
        () {},
      );
    } else {
      // If no image is selected it will show a
      // snackbar saying nothing is selected
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Nothing is selected')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _chatroomPageUI();
  }

  Widget _chatroomPageUI() {
    return isLoading
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  child: isLoading
                      ? Container()
                      : Stack(
                          children: [
                            MessageListView(
                              this,
                              _listViewController,
                              messages,
                            ),
                            if (selectedImages.isNotEmpty)
                              Container(
                                height: 75,
                                constraints:
                                    const BoxConstraints(maxWidth: 800),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.all(0),
                                        itemCount: selectedImages.length,
                                        shrinkWrap: true,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          // TO show selected file
                                          return Stack(
                                            alignment: Alignment.topRight,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    top: 15, right: 12),
                                                child: Center(
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: kIsWeb
                                                        ? Image.network(
                                                            selectedImages[
                                                                    index]
                                                                .path)
                                                        : Image.file(
                                                            selectedImages[
                                                                index]),
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                splashRadius: 11,
                                                constraints:
                                                    const BoxConstraints(),
                                                padding:
                                                    const EdgeInsets.all(0),
                                                icon: const Icon(Icons.close),
                                                iconSize: 21,
                                                onPressed: () async {
                                                  await removeImage(index);
                                                },
                                              ),
                                            ],
                                          );
                                          // If you are making the web app then you have to
                                          // use image provider as network image or in
                                          // android or iOS it will as file only
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Positioned(
                              right: 10,
                              bottom: 0,
                              child: ElevatedButton(
                                  style: ButtonStyle(
                                    minimumSize:
                                        MaterialStateProperty.resolveWith(
                                      (states) {
                                        return Size.zero;
                                      },
                                    ),
                                    padding: MaterialStateProperty.resolveWith<
                                        EdgeInsetsGeometry>(
                                      (Set<MaterialState> states) {
                                        return const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 3);
                                      },
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (messages.isNotEmpty) {
                                      setState(() {
                                        messages.clear();
                                        // delete from the messages table
                                        ConversationDatabase.instance
                                            .deleteMessageByConvId(
                                                widget.conversation!.id);
                                        // update the lastMessage
                                        widget.conversation!.lastMessage =
                                            "Start a chat ->";
                                        widget.conversation!.time =
                                            DateTime.now();
                                        widget.onNewText(widget
                                            .conversation); // pass back to main to update states
                                      });
                                      if (widget.modelLoadedState!.value ==
                                          ModelLoadedState.isLoaded) {
                                        setState(() {
                                          print("TODO here");
                                          // swiftFunctions.resetChat();
                                        });
                                      }
                                    }
                                  },
                                  child: const Text("Reset Chat")),
                            )
                          ],
                        )),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
                child: Container(
                  height: 1,
                  color: Colors.grey[200],
                ),
              ),
              Container(
                color: Colors.white,
                child: MessageField(
                  isGenerating: isGenerating,
                  onPause: () async {
                    // the pause doesn't work in the current way it is implemented
                    // swiftFunctions.stopStream();
                    isGenerating.value = false;
                  },
                  onSubmit: (String text) async {
                    print("onSubmit");
                    if (widget.conversation == null) {
                      // create an official conversation ID and add to the conversations list
                      widget.conversation = Conversation(
                        id: Tools().getRandomString(12),
                        lastMessage: text,
                        time: DateTime.now(),
                        primaryModel: "Llama 2",
                        title: "New Chat",
                      );
                      widget.onCreateNewConversation(widget.conversation);
                    }
                    if (text.trim() != "") {
                      uiMessage.Message message = uiMessage.Message(
                          id: Tools().getRandomString(12),
                          conversationID: widget.conversation!.id,
                          message: text,
                          documentID: '',
                          name: 'User',
                          senderID: '',
                          status: '',
                          timestamp: DateTime.now(),
                          type: uiMessage.MessageType.text);
                      messages.add(message);
                      await ConversationDatabase.instance
                          .createMessage(message);

                      widget.conversation!.lastMessage = text;
                      widget.conversation!.time = DateTime.now();
                      widget.onNewText(widget
                          .conversation); // pass back to main to update states
                      setState(() {
                        isGenerating.value = true;
                      });
                      if (widget.modelLoadedState!.value ==
                          ModelLoadedState.isLoaded) {
                        sendMessagetoModel(message.message!);
                      }
                      setState(() {});
                    }
                  },
                  onLoadImage: () async {
                    // await getImages();
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles();
                    print(result!.files.single.path!);

                    if (result != null) {
                      File file = File(result.files.single.path!);
                    } else {
                      // User canceled the picker
                    }
                  },
                ),
              ),
            ],
          );
  }
}
