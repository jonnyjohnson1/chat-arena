import 'dart:io';

import 'package:chat/models/custom_file.dart';
import 'package:chat/shared/image_viewer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:chat/models/messages.dart';
import 'package:intl/intl.dart';

class TextMessageBubble extends StatefulWidget {
  final _isOurMessage;
  final Message _message;

  const TextMessageBubble(this._isOurMessage, this._message, {Key? key})
      : super(key: key);

  @override
  _TextMessageBubbleState createState() => _TextMessageBubbleState();
}

class _TextMessageBubbleState extends State<TextMessageBubble> {
  int index = 0;
  double maxMesageWidth = 800 * .92;
  double msgContainerBorderRadius = 12;
  late List<ImageFile>? images;

  @override
  void initState() {
    // load images from database on build
    images = widget._message.images ?? [];
    // for (var i in images!) {
    //   print("LOADING IMAGES IN MSG BUBBLE");
    //   print(i.id);
    //   print(i.localFile);
    //   print(i.webFile);
    // }
    super.initState();
  }

  Widget buildImagesRow() {
    if (images!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 36),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // if (widget._isOurMessage)
                //   Expanded(
                //     child: Container(),
                //   ),
                for (int index = 0; index < images!.length; index++)
                  Builder(builder: (context) {
                    Widget? image;
                    String resourcePath =
                        kIsWeb // the path should be displayed from local file system
                            ? images![index].localFile!.path
                            : images![index].localFile!.path;
                    try {
                      if (kIsWeb) {
                        image = Image.network(
                          images![index].webFile!.path,
                          key: Key(images![index].id),
                          errorBuilder: (context, error, stackTrace) {
                            print("Error loading image from network: $error");
                            print(
                                "Sometimes the http blob needs to be recreated from the filename and bytes.");
                            return const Icon(Icons
                                .attachment_outlined); // Return an empty container in case of error
                          },
                        );
                      } else {
                        print(
                            "File exists: ${images![index].localFile!.existsSync()}");
                        image = Image.file(
                          images![index].localFile!,
                          key: Key(images![index].id),
                          errorBuilder: (context, error, stackTrace) {
                            print("Error loading image from file: $error");
                            return const Icon(Icons
                                .attachment_outlined); // Return an empty container in case of error
                          },
                        );
                      }
                    } catch (e) {
                      print("Error loading image: $e");
                      image =
                          const SizedBox(); // Return an empty container in case of error
                    }

                    if (image != null) {
                      // Your code for using the image
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Tooltip(
                          message: resourcePath,
                          preferBelow: false,
                          child: InkWell(
                              onTap: () {
                                launchImageViewer(
                                    context,
                                    kIsWeb
                                        ? images![index].webFile!
                                        : images![index].localFile!);
                              },
                              child: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5)),
                                  child: image)),
                        ),
                      );
                    }
                    return Container();
                  }),
                // if (widget._isOurMessage)
                //   Expanded(
                //     child: Container(),
                //   ),
              ],
            ),
          ),
        ),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    Color themeColorContainer = Theme.of(context).primaryColor;

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: widget._isOurMessage
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        Expanded(
          // We listen to the generations of the chat message
          child: ValueListenableBuilder<String>(
              valueListenable: widget._message.message!,
              builder: (context, message, _) {
                return Container(
                    padding: const EdgeInsets.only(
                        left: 5, right: 1, top: 2, bottom: 2),
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(msgContainerBorderRadius),
                    ),
                    child: widget._isOurMessage
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Container(height: 2),
                              Container(
                                decoration: BoxDecoration(
                                  color:
                                      themeColorContainer, //Color(0xFF1B97F3),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(msgContainerBorderRadius),
                                  ),
                                ),
                                constraints:
                                    BoxConstraints(maxWidth: maxMesageWidth),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(message,
                                      style: TextStyle(
                                        color: ThemeData
                                                    .estimateBrightnessForColor(
                                                        themeColorContainer) ==
                                                Brightness.light
                                            ? Colors.black87
                                            : Colors.white,
                                      )),
                                ),
                              ),
                              Container(
                                height: 2,
                              ),
                              if (images != null) buildImagesRow(),
                              Text(
                                DateFormat('jm')
                                    .format(widget._message.timestamp!),
                                style: const TextStyle(
                                    color: Colors.black45, fontSize: 13),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: [
                                  Text(
                                    widget._message.name ?? 'anon',
                                    style: TextStyle(
                                        // color: getColor(widget._message.nameColor!),
                                        fontWeight: widget._isOurMessage
                                            ? FontWeight.bold
                                            : FontWeight.w500),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6.0),
                                    child: widget._message.isGenerating
                                        ? const CupertinoActivityIndicator()
                                        : Container(),
                                  ),
                                  Row(
                                    children: [
                                      // Text(
                                      //     DateFormat('jm').format(
                                      //         widget._message.timestamp!),
                                      //     style: const TextStyle(
                                      //         color: Colors.black45,
                                      //         fontSize: 13),
                                      //   ),
                                      if (widget._message.completionTime !=
                                          null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5.0),
                                          child: Text(
                                              "${widget._message.completionTime!.toStringAsFixed(2)}s",
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w300)),
                                        ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 5.0),
                                        child: Text(
                                            "@ ${widget._message.toksPerSec.toStringAsFixed(2)} toks/sec.",
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w300)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                height: 2,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(.73),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(15.0),
                                  ),
                                ),
                                constraints:
                                    BoxConstraints(maxWidth: maxMesageWidth),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(message,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ),
                              ),
                              Container(
                                height: 2,
                              ),
                              if (images != null) buildImagesRow(),
                            ],
                          ));
              }),
        ),
      ],
    );
  }
}
