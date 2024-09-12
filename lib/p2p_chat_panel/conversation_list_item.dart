import 'package:chat/models/game_models/debate.dart';
import 'package:chat/theming/theming_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chat/models/conversation.dart';

class P2pConversationListItem extends StatefulWidget {
  Conversation conversation;
  bool isMessageRead;
  final onSettingsTap;
  final onDeleteTap;
  final onSelected;
  P2pConversationListItem(
      {super.key,
      required this.conversation,
      required this.isMessageRead,
      this.onDeleteTap,
      this.onSelected,
      this.onSettingsTap});
  @override
  _P2pConversationListItemState createState() =>
      _P2pConversationListItemState();
}

class _P2pConversationListItemState extends State<P2pConversationListItem> {
  String lastUsed = "";

  final dateformat = DateFormat("M/d/yy");
  final timeformat = DateFormat("h:mm a");
  DateTime now = DateTime.now();
  DateTime? today;

  bool isHover = false;

  _updateLocation(_) {
    setState(() {
      isHover = !isHover;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget getGameIcon(GameType type) {
    switch (type) {
      case GameType.chat:
        return Icon(Icons.graphic_eq, color: aiChatBubbleColor, size: 26);
      case GameType.debate:
        return const Icon(CupertinoIcons.group_solid,
            color: Color.fromARGB(255, 188, 144, 249), size: 26);
      case GameType.p2pchat:
        return Icon(CupertinoIcons.chat_bubble_fill,
            color: chatIconColor, size: 26);
      default:
        return Icon(CupertinoIcons.chat_bubble_fill,
            color: Colors.blue[200], size: 26);
    }
  }

  String getTitle(GameType type) {
    switch (type) {
      case GameType.chat:
        return widget.conversation.title!;
      case GameType.debate:
        if (widget.conversation.gameModel != null) {
          DebateGame game = widget.conversation.gameModel;
          if (game.topic != null) {
            if (game.topic!.isNotEmpty) {
              return game.topic!;
            }
          }
          return "Chat";
        }
        return widget.conversation.title!;
      default:
        return "Chat";
    }
  }

  @override
  Widget build(BuildContext context) {
    today = DateTime(now.year, now.month, now.day);
    DateTime msgDate = widget.conversation.time ?? DateTime.now();
    if (DateTime(msgDate.year, msgDate.month, msgDate.day) == today) {
      lastUsed = timeformat.format(msgDate);
    } else {
      lastUsed = dateformat.format(msgDate);
    }
    return MouseRegion(
      onEnter: _updateLocation,
      onExit: _updateLocation,
      child: InkWell(
        onTap: () {
          widget.onSelected();
        },
        child: Container(
          height: 85,
          padding:
              const EdgeInsets.only(left: 6, right: 6, top: 10, bottom: 10),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 12,
                child: widget.isMessageRead
                    ? Container()
                    : Icon(
                        Icons.circle,
                        color: Colors.blue[600],
                        size: 12,
                      ),
              ),
              const SizedBox(
                width: 6,
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child:
                                    getGameIcon(widget.conversation.gameType!)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                            getTitle(
                                                widget.conversation.gameType!),
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium),
                                      ),
                                      isHover
                                          ? Tooltip(
                                              message: "Delete",
                                              waitDuration: const Duration(
                                                  milliseconds: 800),
                                              child: GestureDetector(
                                                onTap: () {
                                                  widget.onDeleteTap();
                                                },
                                                child: const Padding(
                                                  padding: EdgeInsets.all(3.0),
                                                  child: Icon(
                                                    Icons.close,
                                                    size: 18,
                                                    color: Color.fromARGB(
                                                        255, 149, 146, 146),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const Padding(
                                              padding: EdgeInsets.all(3.0),
                                              child: Icon(
                                                Icons.delete,
                                                size: 18,
                                                color: Color.fromARGB(
                                                    0, 235, 55, 55),
                                              ),
                                            ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 0,
                                  ),
                                  Expanded(
                                    child: Text(
                                      widget.conversation.lastMessage ?? "",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
