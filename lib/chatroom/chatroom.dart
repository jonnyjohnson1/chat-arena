import 'dart:io';

import 'package:chat/models/llm.dart';
import 'package:chat/services/static_queries.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat/chatroom/widgets/message_field/message_field.dart';
import 'package:chat/chatroom/widgets/message_list_view.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/models/event_channel_model.dart';
import 'package:chat/models/messages.dart' as uiMessage;
// import 'package:chat/services/conversation_database.dart';
import 'package:chat/services/tools.dart';
// import 'package:file_selector/file_selector.dart';

class ChatRoomPage extends StatefulWidget {
  Conversation? conversation;
  final onNewMessage;
  bool showModelSelectButton;
  bool showTopTitle;
  ModelConfig? selectedModelConfig;
  final Function? onSelectedModelChange;
  String topTitleHeading;
  String topTitleText;
  ValueNotifier<bool>? isGenerating;
  List<uiMessage.Message> messages;

  ChatRoomPage(
      {required this.conversation,
      required this.messages,
      this.selectedModelConfig,
      this.onSelectedModelChange,
      this.isGenerating,
      this.onNewMessage,
      this.showModelSelectButton = true,
      this.showTopTitle = true,
      this.topTitleHeading = "Topic:",
      this.topTitleText = "",
      Key? key})
      : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final ScrollController _listViewController = ScrollController();
  List<Map<String, dynamic>> dialogFlowMessages = [];

  bool isIphone = false;
  ModelConfig? selectedModel;

  @override
  void initState() {
    if (widget.showModelSelectButton) {
      assert(widget.selectedModelConfig != null &&
          widget.onSelectedModelChange != null);
      selectedModel = widget.selectedModelConfig;
    }

    super.initState();
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
      print("Platform is macOS");
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
      // If no image is selected it will show a snackbar saying nothing is selected
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Nothing is selected')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _chatroomPageUI(context);
  }

  Widget _chatroomPageUI(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (widget.showTopTitle)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 3, top: 3),
            child: Row(
              children: [
                Text(widget.topTitleHeading),
                const SizedBox(
                  width: 4,
                ),
                Text(widget.topTitleText)
              ],
            ),
          ),
        Expanded(
            child: Stack(
          children: [
            MessageListView(
              this,
              _listViewController,
              widget.messages,
            ),

            // images container
            if (selectedImages.isNotEmpty)
              Container(
                height: 75,
                constraints: const BoxConstraints(maxWidth: 800),
                child: Row(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(0),
                        itemCount: selectedImages.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          // TO show selected file
                          return Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.only(top: 15, right: 12),
                                child: Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: kIsWeb
                                        ? Image.network(
                                            selectedImages[index].path)
                                        : Image.file(selectedImages[index]),
                                  ),
                                ),
                              ),
                              IconButton(
                                splashRadius: 11,
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(0),
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
            // model selector button
            if (widget.showModelSelectButton)
              Positioned(
                bottom: 0,
                left: 10,
                child: FutureBuilder(
                    future: getModels(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      return snapshot.hasData
                          ? Material(
                              color: Colors.white,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                width: 135,
                                height: 35,
                                child: DropdownButton<LanguageModel>(
                                  hint: Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Center(
                                      child: Text(
                                          selectedModel!.model.name ??
                                              'make a selection',
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                  alignment: Alignment.center,
                                  underline: Container(),
                                  isDense: true,
                                  elevation: 4,
                                  padding: EdgeInsets.zero,
                                  itemHeight: null,
                                  isExpanded: true,
                                  items: snapshot.data
                                      .map<DropdownMenuItem<LanguageModel>>(
                                          (item) {
                                    return DropdownMenuItem<LanguageModel>(
                                      value: item,
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        width: 170,
                                        child: Row(
                                          children: [
                                            Expanded(
                                                child: Text(
                                              item.name,
                                              overflow: TextOverflow.ellipsis,
                                              // style: TextStyle(
                                              //     fontSize:
                                              //         16)),
                                            )),
                                            if (item.size != null)
                                              Text(" (${sizeToGB(item.size)})",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style:
                                                      TextStyle(fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (LanguageModel? newValue) {
                                    setState(() {
                                      selectedModel!.model = newValue!;
                                    });
                                    widget.onSelectedModelChange!(newValue);
                                  },
                                ),
                              ),
                            )
                          : const Center(
                              child: Text('Loading...'),
                            );
                    }),
              ),

            // reset chat button
            // Positioned(
            //   right: 10,
            //   bottom: 0,
            //   child: ElevatedButton(
            //       style: ButtonStyle(
            //         minimumSize:
            //             MaterialStateProperty.resolveWith(
            //           (states) {
            //             return Size.zero;
            //           },
            //         ),
            //         padding: MaterialStateProperty.resolveWith<
            //             EdgeInsetsGeometry>(
            //           (Set<MaterialState> states) {
            //             return const EdgeInsets.symmetric(
            //                 horizontal: 6, vertical: 3);
            //           },
            //         ),
            //       ),
            //       onPressed: () async {
            //         if (messages.isNotEmpty) {
            //           setState(() {
            //             messages.clear();
            //             // delete from the messages table
            //             ConversationDatabase.instance
            //                 .deleteMessageByConvId(
            //                     widget.conversation!.id);
            //             // update the lastMessage
            //             widget.conversation!.lastMessage =
            //                 "Start a chat ->";
            //             widget.conversation!.time =
            //                 DateTime.now();
            //             widget.onNewText(widget
            //                 .conversation); // pass back to main to update states
            //           });
            //         }
            //       },
            //       child: const Text("Reset Chat")),
            // )
          ],
        )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
        Container(
          color: Colors.white,
          child: MessageField(
            isGenerating: widget.isGenerating,
            onPause: () async {
              // the pause doesn't work in the current way it is implemented
              // swiftFunctions.stopStream();
              widget.isGenerating!.value = false;
            },
            onSubmit: (String text) async {
              widget.onNewMessage(widget.conversation,
                  text); // pass back to main to update states
            },
            onLoadImage: () async {
              // await getImages();
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              print(result!.files.single.path!);

              if (result != null) {
                File file = File(result.files.single.path!);
              } else {
                // User canceled the picker
              }
            },
          ),
        ),
        // bottom padding
        const SizedBox(
          height: 7,
        )
      ],
    );
  }
}
