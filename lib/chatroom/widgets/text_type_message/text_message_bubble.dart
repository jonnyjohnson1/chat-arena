import 'package:chat/analytics_drawer/mermaid_widget.dart';
import 'package:chat/chatroom/widgets/text_type_message/emotion_icon.dart';
import 'package:chat/chatroom/widgets/text_type_message/mod_icon_widget.dart';
import 'package:chat/chatroom/widgets/text_type_message/sentiment_widget.dart';
import 'package:chat/custom_pkgs/custom_dynamic_text_highlighting.dart';
import 'package:chat/models/custom_file.dart';
import 'package:chat/models/display_configs.dart';
import 'package:chat/shared/image_viewer.dart';
import 'package:chat/shared/pos_service_config_dicts.dart';
import 'package:chat/shared/string_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:chat/models/messages.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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

  late ValueNotifier<DisplayConfigData> displayConfigData;
  bool showGeneratingText = true;

  @override
  void initState() {
    super.initState();
    images = widget._message.images ?? [];
    displayConfigData =
        Provider.of<ValueNotifier<DisplayConfigData>>(context, listen: false);
    showGeneratingText = Provider.of<bool>(context, listen: false);
  }

  // Function to build message content with clickable URLs
  Widget _buildMessageContent(String message) {
    final RegExp linkRegEx = RegExp(r'\[(.*?)\]\((.*?)\)');

    final List<TextSpan> spans = [];
    int start = 0;

    linkRegEx.allMatches(message).forEach((match) {
      if (match.start > start) {
        spans.add(TextSpan(
          text: message.substring(start, match.start),
          style: TextStyle(
            color: widget._isOurMessage ? Colors.white : Colors.white,
          ),
        ));
      }

      final String displayText = match.group(1)!;
      final String url = match.group(2)!;

      spans.add(
        TextSpan(
          text: displayText,
          style: TextStyle(
            color: Colors.blueAccent,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              if (await canLaunch(url)) {
                await launch(url);
              }
            },
        ),
      );

      start = match.end;
    });

    if (start < message.length) {
      spans.add(TextSpan(
        text: message.substring(start),
        style: TextStyle(
          color: widget._isOurMessage ? Colors.white : Colors.white,
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
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
                for (int index = 0; index < images!.length; index++)
                  Builder(builder: (context) {
                    Widget? image;
                    String resourcePath =
                    kIsWeb ? images![index].localFile!.path : images![index].localFile!.path;
                    try {
                      if (kIsWeb) {
                        image = Image.network(
                          images![index].webFile!.path,
                          key: Key(images![index].id),
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.attachment_outlined);
                          },
                        );
                      } else {
                        image = Image.file(
                          images![index].localFile!,
                          key: Key(images![index].id),
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.attachment_outlined);
                          },
                        );
                      }
                    } catch (e) {
                      image = const SizedBox();
                    }

                    if (image != null) {
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
                              child: image,
                            ),
                          ),
                        ),
                      );
                    }
                    return Container();
                  }),
              ],
            ),
          ),
        ),
      );
    }
    return Container();
  }

  Widget buildCommentsRow(Map<String, dynamic> baseAnalytics) {
    if (baseAnalytics.isNotEmpty) {
      if (baseAnalytics.containsKey('commenter')) {
        String modName =
        baseAnalytics['commenter']['base_analysis']['mod_level'] != null &&
            baseAnalytics['commenter']['base_analysis']['mod_level']
                .isNotEmpty
            ? baseAnalytics['commenter']['base_analysis']['mod_level']
            .first['name']
            : '';
        String modLabel =
        baseAnalytics['commenter']['base_analysis']['mod_level'] != null &&
            baseAnalytics['commenter']['base_analysis']['mod_level']
                .isNotEmpty
            ? baseAnalytics['commenter']['base_analysis']['mod_level']
            .first['label']
            : '';
        String ternSent =
        baseAnalytics['commenter']['base_analysis']['tern_sent'] != null &&
            baseAnalytics['commenter']['base_analysis']['tern_sent']
                .isNotEmpty
            ? baseAnalytics['commenter']['base_analysis']['tern_sent']
            .first['label']
            : '';
        double ternSentScore =
        baseAnalytics['commenter']['base_analysis']['tern_sent'] != null &&
            baseAnalytics['commenter']['base_analysis']['tern_sent']
                .isNotEmpty
            ? baseAnalytics['commenter']['base_analysis']['tern_sent']
            .first['score']
            : 0.0;
        String emo_27 = baseAnalytics['commenter']['base_analysis']['emo_27'] !=
            null &&
            baseAnalytics['commenter']['base_analysis']['emo_27'].isNotEmpty
            ? baseAnalytics['commenter']['base_analysis']['emo_27']
            .first['label']
            : '';
        double emo_27Score = baseAnalytics['commenter']['base_analysis']
        ['emo_27'] !=
            null &&
            baseAnalytics['commenter']['base_analysis']['emo_27'].isNotEmpty
            ? baseAnalytics['commenter']['base_analysis']['emo_27']
            .first['score']
            : 0.0;

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
            ),
          ],
        );
      } else {
        return Container();
      }
    } else {
      return Container();
    }
  }

  TextStyle secondary =
  const TextStyle(fontSize: 12, fontWeight: FontWeight.w300);

  ValueNotifier<double?> textWidth = ValueNotifier(null);

  //labels dict
  buildHighlights(Map<String, dynamic> posData) {
    if (posData.isNotEmpty) {
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
          child: Row(
            children: [
              Expanded(
                child: ValueListenableBuilder<DisplayConfigData>(
                    valueListenable: displayConfigData,
                    builder: (context, displayConfig, _) {
                      return ValueListenableBuilder<String>(
                          valueListenable: widget._message.message!,
                          builder: (context, message, _) {
                            return ValueListenableBuilder<Map<String, dynamic>>(
                                valueListenable: widget._message.baseAnalytics,
                                builder: (context, baseAnalytics, _) {
                                  if (displayConfigData
                                      .value.showInMessageNER) {
                                    if (widget._message.baseAnalytics.value
                                        .isNotEmpty) {
                                      buildHighlights(widget._message
                                          .baseAnalytics.value['in_line'] ??
                                          {});
                                    }
                                  }
                                  return Container(
                                      constraints: BoxConstraints(
                                          maxWidth: maxMesageWidth),
                                      padding: const EdgeInsets.only(
                                          left: 5, right: 1, top: 2, bottom: 2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            msgContainerBorderRadius),
                                      ),
                                      child: widget._isOurMessage
                                          ? IntrinsicWidth(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceAround,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Container(
                                              constraints: BoxConstraints(
                                                  maxWidth:
                                                  maxMesageWidth),
                                              child: Row(children: [
                                                Expanded(
                                                    child: Container()),
                                                baseAnalytics.isEmpty ||
                                                    !displayConfig
                                                        .showModerationTags
                                                    ? Container()
                                                    : buildCommentsRow(
                                                    baseAnalytics),
                                                ValueListenableBuilder<
                                                    String>(
                                                    valueListenable:
                                                    widget._message
                                                        .mermaidChart,
                                                    builder: (context,
                                                        mermaidString,
                                                        _) {
                                                      if (mermaidString
                                                          .isNotEmpty) {
                                                        return IconButton(
                                                          icon: const Icon(
                                                              Icons
                                                                  .schema,
                                                              size: 16),
                                                          onPressed: () {
                                                            showDialog(
                                                              context:
                                                              context,
                                                              builder:
                                                                  (BuildContext
                                                              context) {
                                                                return Dialog(
                                                                  child:
                                                                  Container(
                                                                    constraints: const BoxConstraints(
                                                                        maxWidth: 1000,
                                                                        maxHeight: 700),
                                                                    child: Center(
                                                                        child: MermaidWidget(
                                                                          mermaidText:
                                                                          mermaidString,
                                                                          alignTop:
                                                                          false,
                                                                        )),
                                                                  ),
                                                                );
                                                              },
                                                            );
                                                          },
                                                        );
                                                      } else {
                                                        Icon(Icons.schema,
                                                            color: Colors
                                                                .grey[
                                                            350]);
                                                      }
                                                      return Container();
                                                    })
                                              ]),
                                            ),
                                            Container(height: 2),
                                            Container(
                                              decoration: BoxDecoration(
                                                color:
                                                themeColorContainer,
                                                borderRadius:
                                                BorderRadius.all(
                                                  Radius.circular(
                                                      msgContainerBorderRadius),
                                                ),
                                              ),
                                              constraints: BoxConstraints(
                                                  maxWidth:
                                                  maxMesageWidth),
                                              child: Padding(
                                                padding:
                                                const EdgeInsets.all(
                                                    8.0),
                                                child:
                                                _buildMessageContent(
                                                    message),
                                              ),
                                            ),
                                            Container(
                                              height: 2,
                                            ),
                                            if (images != null)
                                              buildImagesRow(),
                                            Text(
                                              DateFormat('jm').format(
                                                  widget._message
                                                      .timestamp!),
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
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: <Widget>[
                                          ValueListenableBuilder<double?>(
                                              valueListenable: textWidth,
                                              builder:
                                                  (context, width, _) {
                                                return Container(
                                                  width: width,
                                                  constraints: BoxConstraints(
                                                      minWidth: 350,
                                                      maxWidth:
                                                      maxMesageWidth),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .end,
                                                        children: [
                                                          Text(
                                                            widget._message
                                                                .name ??
                                                                'anon',
                                                            style:
                                                            TextStyle(
                                                                fontWeight: widget._isOurMessage
                                                                    ? FontWeight.bold
                                                                    : FontWeight.w500),
                                                          ),
                                                          if (showGeneratingText)
                                                            Padding(
                                                              padding: const EdgeInsets
                                                                  .only(
                                                                  left:
                                                                  6.0),
                                                              child: widget
                                                                  ._message
                                                                  .isGenerating
                                                                  ? const CupertinoActivityIndicator()
                                                                  : Container(),
                                                            ),
                                                          if (widget._message
                                                              .completionTime !=
                                                              null &&
                                                              showGeneratingText)
                                                            Padding(
                                                              padding: const EdgeInsets
                                                                  .only(
                                                                  left:
                                                                  5.0),
                                                              child: Text(
                                                                  "${widget._message.completionTime!.toStringAsFixed(2)}s",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                      12,
                                                                      fontWeight:
                                                                      FontWeight.w300)),
                                                            ),
                                                          if (showGeneratingText)
                                                            Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                              children: [
                                                                if (width !=
                                                                    null)
                                                                  if (width <
                                                                      400)
                                                                    ValueListenableBuilder<Map<String, dynamic>>(
                                                                        valueListenable: widget._message.baseAnalytics,
                                                                        builder: (context, baseAnalytics, _) {
                                                                          if (baseAnalytics.isEmpty || !displayConfig.showModerationTags) {
                                                                            return Container();
                                                                          }
                                                                          return buildCommentsRow(baseAnalytics);
                                                                        }),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                      5.0),
                                                                  child: Text(
                                                                      "@ ${widget._message.toksPerSec.toStringAsFixed(2)} toks/sec.",
                                                                      style:
                                                                      const TextStyle(fontSize: 12, fontWeight: FontWeight.w300)),
                                                                ),
                                                              ],
                                                            ),
                                                        ],
                                                      ),
                                                      if (!showGeneratingText)
                                                        ValueListenableBuilder<
                                                            Map<String,
                                                                dynamic>>(
                                                            valueListenable: widget
                                                                ._message
                                                                .baseAnalytics,
                                                            builder: (context,
                                                                baseAnalytics,
                                                                _) {
                                                              if (baseAnalytics
                                                                  .isEmpty ||
                                                                  !displayConfig
                                                                      .showModerationTags) {
                                                                return Container();
                                                              }
                                                              return buildCommentsRow(
                                                                  baseAnalytics);
                                                            }),
                                                      if (width != null &&
                                                          showGeneratingText)
                                                        if (width >= 400)
                                                          ValueListenableBuilder<
                                                              Map<String,
                                                                  dynamic>>(
                                                              valueListenable: widget
                                                                  ._message
                                                                  .baseAnalytics,
                                                              builder:
                                                                  (context,
                                                                  baseAnalytics,
                                                                  _) {
                                                                if (baseAnalytics
                                                                    .isEmpty ||
                                                                    !displayConfig
                                                                        .showModerationTags) {
                                                                  return Container();
                                                                }
                                                                return buildCommentsRow(
                                                                    baseAnalytics);
                                                              })
                                                    ],
                                                  ),
                                                );
                                              }),
                                          Container(
                                            height: 2,
                                          ),
                                          LayoutBuilder(builder:
                                              (context, constraints) {
                                            WidgetsBinding.instance
                                                .addPostFrameCallback(
                                                    (_) {
                                                  if (mounted) {
                                                    setState(() {
                                                      if (context
                                                          .size!.width >
                                                          300) {}
                                                      textWidth.value =
                                                          context.size!.width;
                                                      textWidth
                                                          .notifyListeners();
                                                    });
                                                  }
                                                });
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(.73),
                                                borderRadius:
                                                const BorderRadius
                                                    .all(
                                                  Radius.circular(15.0),
                                                ),
                                              ),
                                              constraints: BoxConstraints(
                                                  maxWidth:
                                                  maxMesageWidth),
                                              child: Padding(
                                                padding:
                                                const EdgeInsets.all(
                                                    8.0),
                                                child:
                                                _buildMessageContent(
                                                    message),
                                              ),
                                            );
                                          }),
                                          Container(
                                            height: 2,
                                          ),
                                          if (images != null)
                                            buildImagesRow(),
                                        ],
                                      ));
                                });
                          });
                    }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
