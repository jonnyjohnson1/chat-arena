import 'package:chat/chatroom/widgets/text_type_message/emotion_icon.dart';
import 'package:chat/chatroom/widgets/text_type_message/mod_icon_widget.dart';
import 'package:chat/chatroom/widgets/text_type_message/sentiment_widget.dart';
import 'package:chat/custom_pkgs/custom_dynamic_text_highlighting.dart';
import 'package:chat/models/custom_file.dart';
import 'package:chat/shared/image_viewer.dart';
import 'package:chat/shared/pos_service_config_dicts.dart';
import 'package:chat/shared/string_extension.dart';
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

  Map<String, WordHighlight> highlights = {};

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

  //labels dict
  buildHighlights(Map<String, dynamic> posData) {
    List<String> allEnts = posData['base_analysis'].keys.toList();
    for (String entity in allEnts) {
      List<dynamic> labels = posData['base_analysis'][entity];
      for (dynamic lbl in labels) {
        String highlightString = lbl['text'];
        highlights.putIfAbsent(
            highlightString,
            () => WordHighlight(
                label: entity.toLowerCase().capitalize(),
                color: ServicePOSLabelsDict().entitiesLabelsDict[entity] ??
                    Colors.yellow));
      }
    }
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

  Widget buildCommentsRow(Map<String, dynamic> baseAnalytics) {
    String modName =
        baseAnalytics['commenter']['base_analysis']['mod_level'].first['name'];
    String modLabel =
        baseAnalytics['commenter']['base_analysis']['mod_level'].first['label'];
    String ternSent =
        baseAnalytics['commenter']['base_analysis']['tern_sent'].first['label'];
    double ternSentScore =
        baseAnalytics['commenter']['base_analysis']['tern_sent'].first['score'];
    String emo_27 =
        baseAnalytics['commenter']['base_analysis']['emo_27'].first['label'];
    double emo_27Score =
        baseAnalytics['commenter']['base_analysis']['emo_27'].first['score'];
    return Row(
      children: [
        Text(emo_27.capitalize()),
        const SizedBox(
          width: 3,
        ),
        EmotionIcon(
          emotion: emo_27,
          score: emo_27Score,
          size: 16,
        ),
        const SizedBox(
          width: 6,
        ),
        ModeratorIcon(
          label: modLabel,
          name: modName,
          size: 16,
        ),
        SentimentIcon(
          sentiment: ternSent,
          score: ternSentScore,
          size: 16,
        )
      ],
    );
  }

  TextStyle secondary =
      const TextStyle(fontSize: 12, fontWeight: FontWeight.w300);

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
          child: Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<String>(
                    valueListenable: widget._message.message!,
                    builder: (context, message, _) {
                      // build highlights dict if there is pos data
                      if (widget._message.baseAnalytics.value.isNotEmpty) {
                        buildHighlights(
                            widget._message.baseAnalytics.value['in_line']);
                      }
                      return Container(
                          constraints: BoxConstraints(maxWidth: maxMesageWidth),
                          padding: const EdgeInsets.only(
                              left: 5, right: 1, top: 2, bottom: 2),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(msgContainerBorderRadius),
                          ),
                          child: widget._isOurMessage
                              ? IntrinsicWidth(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Row(children: [
                                        Expanded(child: Container()),
                                        ValueListenableBuilder<
                                                Map<String, dynamic>>(
                                            valueListenable:
                                                widget._message.baseAnalytics,
                                            builder:
                                                (context, base_analytics, _) {
                                              if (base_analytics.isEmpty)
                                                return Container();
                                              return buildCommentsRow(
                                                  base_analytics);
                                            })
                                      ]),
                                      Container(height: 2),
                                      Container(
                                        decoration: BoxDecoration(
                                          color:
                                              themeColorContainer, //Color(0xFF1B97F3),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                msgContainerBorderRadius),
                                          ),
                                        ),
                                        constraints: BoxConstraints(
                                            maxWidth: maxMesageWidth),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: DynamicTextHighlighting(
                                            key: UniqueKey(),
                                            text: message,
                                            softWrap: true,
                                            highlights: highlights,
                                            caseSensitive: false,
                                            style: TextStyle(
                                              color: ThemeData.estimateBrightnessForColor(
                                                          themeColorContainer) ==
                                                      Brightness.light
                                                  ? Colors.black87
                                                  : Colors.white,
                                            ),
                                            textAlign: TextAlign.left,
                                            textWidthBasis:
                                                TextWidthBasis.parent,
                                          ),
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
                                            color: Colors.black45,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      constraints: BoxConstraints(
                                          maxWidth: maxMesageWidth),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                widget._message.name ?? 'anon',
                                                style: TextStyle(
                                                    // color: getColor(widget._message.nameColor!),
                                                    fontWeight:
                                                        widget._isOurMessage
                                                            ? FontWeight.bold
                                                            : FontWeight.w500),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 6.0),
                                                child: widget
                                                        ._message.isGenerating
                                                    ? const CupertinoActivityIndicator()
                                                    : Container(),
                                              ),
                                              // Text(
                                              //     DateFormat('jm').format(
                                              //         widget._message.timestamp!),
                                              //     style: const TextStyle(
                                              //         color: Colors.black45,
                                              //         fontSize: 13),
                                              //   ),
                                              if (widget._message
                                                      .completionTime !=
                                                  null)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5.0),
                                                  child: Text(
                                                      "${widget._message.completionTime!.toStringAsFixed(2)}s",
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w300)),
                                                ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5.0),
                                                child: Text(
                                                    "@ ${widget._message.toksPerSec.toStringAsFixed(2)} toks/sec.",
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w300)),
                                              ),
                                            ],
                                          ),
                                          Expanded(child: Container()),
                                          ValueListenableBuilder<
                                                  Map<String, dynamic>>(
                                              valueListenable:
                                                  widget._message.baseAnalytics,
                                              builder:
                                                  (context, base_analytics, _) {
                                                if (base_analytics.isEmpty)
                                                  return Container();
                                                return buildCommentsRow(
                                                    base_analytics);
                                              })
                                        ],
                                      ),
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
                                      constraints: BoxConstraints(
                                          maxWidth: maxMesageWidth),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: DynamicTextHighlighting(
                                          key: UniqueKey(),
                                          text: message,
                                          highlights: highlights,
                                          caseSensitive: false,
                                          style: TextStyle(
                                            color: ThemeData
                                                        .estimateBrightnessForColor(
                                                            themeColorContainer) ==
                                                    Brightness.light
                                                ? Colors.black87
                                                : Colors.white,
                                          ),
                                          textAlign: TextAlign.left,
                                          textWidthBasis: TextWidthBasis.parent,
                                        ),
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
              // Add the per message game level analytics here
              // ValueListenableBuilder<Map<String, dynamic>>(
              //     valueListenable: widget._message.baseAnalytics,
              //     builder: (context, base_analytics, _) {
              //       // if (base_analytics.isEmpty) return Container();
              //       return Container(
              //           constraints: const BoxConstraints(maxWidth: 200),
              //           child: Column(
              //             children: [
              //               Row(
              //                 mainAxisSize: MainAxisSize.min,
              //                 children: [
              //                   Text("Topic\nDist:", style: secondary),
              //                   Text(" +1", style: secondary),
              //                 ],
              //               ),
              //             ],
              //           ));
              //     }),
            ],
          ),
        ),
      ],
    );
  }
}
