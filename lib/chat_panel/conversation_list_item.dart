import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chat/models/conversation.dart';

class ConversationListItem extends StatefulWidget {
  Conversation conversation;
  bool isMessageRead;
  final onSettingsTap;
  final onDeleteTap;
  final onSelected;
  ConversationListItem(
      {super.key,
      required this.conversation,
      required this.isMessageRead,
      this.onDeleteTap,
      this.onSelected,
      this.onSettingsTap});
  @override
  _ConversationListItemState createState() => _ConversationListItemState();
}

class _ConversationListItemState extends State<ConversationListItem> {
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
                    // CircleAvatar(
                    //   backgroundImage: NetworkImage(widget.imageUrl),
                    //   maxRadius: 18,
                    // ),
                    // const SizedBox(
                    //   width: 10,
                    // ),
                    Expanded(
                      child: Container(
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            if (widget.conversation.gameType == GameType.chat)
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: Icon(CupertinoIcons.chat_bubble_fill,
                                    color: Colors.blue[200], size: 26),
                              ),
                            if (widget.conversation.gameType == GameType.debate)
                              const Padding(
                                padding: EdgeInsets.only(right: 10.0),
                                child: Icon(CupertinoIcons.group_solid,
                                    color: Color.fromARGB(255, 188, 144, 249),
                                    size: 26),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                            widget.conversation.title ??
                                                "Llama 2",
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
                                  Text(
                                    widget.conversation.lastMessage ?? "",
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.normal),
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
