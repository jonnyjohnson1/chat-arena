// chatroom.dart

import 'dart:io';
import 'package:chat/models/custom_file.dart';
import 'package:chat/models/display_configs.dart';
import 'package:chat/models/llm.dart';
import 'package:chat/services/static_queries.dart';
import 'package:chat/services/tools.dart';
import 'package:chat/shared/image_viewer.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat/chatroom/widgets/message_field/message_field.dart';
import 'package:chat/chatroom/widgets/message_list_view.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/models/messages.dart' as uiMessage;

import 'package:chat/services/web_specific_queries.dart';
import 'package:provider/provider.dart';

class ChatRoomPage extends StatefulWidget {
  Conversation? conversation;
  final Function? onNewMessage;
  bool showModelSelectButton;
  bool showTopTitle;
  ModelConfig? selectedModelConfig;
  final Function? onSelectedModelChange;
  String topTitleHeading;
  String topTitleText;
  ValueNotifier<bool>? isGenerating;
  bool showGeneratingText;
  List<uiMessage.Message> messages;

  ChatRoomPage(
      {required this.conversation,
      required this.messages,
      this.selectedModelConfig,
      this.onSelectedModelChange,
      this.isGenerating,
      this.onNewMessage,
      this.showGeneratingText = true,
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

  bool isIphone = false;
  ModelConfig? selectedModel;
  late ValueNotifier<DisplayConfigData> displayConfigData;

  @override
  void initState() {
    displayConfigData =
        Provider.of<ValueNotifier<DisplayConfigData>>(context, listen: false);
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

  List<ImageFile> selectedImages = []; // List of selected image
  final picker = ImagePicker(); // Instance of Image picker

  Future removeImage(int index) async {
    setState(() {
      {
        selectedImages.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _chatroomPageUI(context);
  }

  bool hasImage = false;
  File? image;

  Future<void> getImageWeb() async {
    if (kIsWeb) {
      try {
        List<ImageFile>? images = await getLocalFilePaths();
        if (images == null) return;
        setState(() {
          selectedImages.addAll(images);
        });
      } catch (e) {
        print(e);
      }
    }
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
            MultiProvider(
              providers: [Provider.value(value: widget.showGeneratingText)],
              child: MessageListView(
                this,
                _listViewController,
                widget.messages,
              ),
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
            color: selectedImages.isNotEmpty
                ? Colors.grey
                : const Color.fromARGB(0, 238, 238, 238),
          ),
        ),
        Column(
          children: [
            // messagefield attachments
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // model selector button
                if (widget.showModelSelectButton)
                  FutureBuilder(
                      future: getModels(displayConfigData.value.apiConfig),
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
                                  height: 28,
                                  child: DropdownButton<LanguageModel>(
                                    hint: Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: Center(
                                        child: Text(
                                          selectedModel!.model.name ??
                                              'make a selection',
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12),
                                        ),
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
                                        child: SizedBox(
                                          width: 170,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: Text(
                                                item.name,
                                                style: const TextStyle(
                                                    fontSize: 14),
                                                overflow: TextOverflow.ellipsis,
                                                // style: TextStyle(
                                                //     fontSize:
                                                //         16)),
                                              )),
                                              if (item.size != null)
                                                Text(
                                                    " (${sizeToGB(item.size)})",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        fontSize: 11)),
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
                const SizedBox(
                  width: 10,
                ),
                if (selectedImages.isNotEmpty)
                  Container(
                    height: 75,
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(0),
                      itemCount: selectedImages.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        // TO show selected file
                        return InkWell(
                          onTap: () async {
                            await launchImageViewer(
                                context,
                                kIsWeb
                                    ? selectedImages[index].webFile
                                    : selectedImages[index].localFile);
                          },
                          child: Stack(
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
                                            selectedImages[index].webFile!.path)
                                        : Image.file(
                                            selectedImages[index].localFile!),
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
                          ),
                        );
                        // If you are making the web app then you have to
                        // use image provider as network image or in
                        // android or iOS it will as file only
                      },
                    ),
                  ),
              ],
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
                  List<ImageFile> submittedImages = List.from(
                      selectedImages); // pass images list to the function
                  selectedImages =
                      []; // clear the selected Images from the current view
                  if (widget.onNewMessage != null) {
                    await widget.onNewMessage!(widget.conversation, text,
                        submittedImages); // pass back to main to update states
                  }
                },
                onLoadImage: () async {
                  if (kIsWeb) {
                    await getImageWeb();
                  } else {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(type: FileType.image, allowMultiple: true);

                    if (result != null) {
                      result.files.forEach((PlatformFile element) {
                        File file = File(element.path!);
                        selectedImages.add(ImageFile(
                            id: Tools().getRandomString(32),
                            bytes: file.readAsBytesSync(),
                            isWeb: false,
                            localFile: file));
                      });
                      setState(() {});
                    } else {
                      // User canceled the picker
                    }
                  }
                },
              ),
            ),
          ],
        ),
        // bottom padding
        const SizedBox(
          height: 9,
        )
      ],
    );
  }
}
