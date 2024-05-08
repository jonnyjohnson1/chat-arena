import 'package:flutter/cupertino.dart';
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
  bool _isPressed = false;

  int index = 0;
  double maxMesageWidth = 800 * .92;
  double msgContainerBorderRadius = 12;

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
                              Row(
                                children: [
                                  // Text(
                                  //     DateFormat('jm').format(
                                  //         widget._message.timestamp!),
                                  //     style: const TextStyle(
                                  //         color: Colors.black45,
                                  //         fontSize: 13),
                                  //   ),
                                  if (widget._message.completionTime != null)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      child: Text(
                                          "${widget._message.completionTime!.toStringAsFixed(widget._message.isGenerating ? 2 : 2)}s"),
                                    ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Text(
                                        "@ ${widget._message.toksPerSec.toStringAsFixed(2)} toks/sec."),
                                  ),
                                ],
                              ),
                            ],
                          ));
              }),
        ),
      ],
    );
  }
}
