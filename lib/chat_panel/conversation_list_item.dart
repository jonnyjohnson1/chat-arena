import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chat/models/conversation.dart';

class ConversationListItem extends StatefulWidget {
  Conversation conversation;
  bool isMessageRead;
  final onSettingsTap;
  final onSelected;
  ConversationListItem(
      {super.key,
      required this.conversation,
      required this.isMessageRead,
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

  bool isHoverAttributes = false;

  _updateLocation(_) {
    setState(() {
      isHoverAttributes = !isHoverAttributes;
    });
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
    return InkWell(
      onTap: () {
        widget.onSelected();
      },
      child: Container(
        padding: const EdgeInsets.only(left: 6, right: 6, top: 10, bottom: 10),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                    widget.conversation.title ?? "Llama 2",
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium),
                              ),
                              GestureDetector(
                                onTap: () {
                                  widget.onSettingsTap();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Icon(
                                    Icons.more_horiz,
                                    size: 24,
                                    color: Colors.grey.shade600,
                                  ),
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
                          // Row(
                          //   children: [
                          //     Text(
                          //       lastUsed,
                          //       style: TextStyle(
                          //           color: Colors.grey.shade600,
                          //           fontSize: 12,
                          //           fontWeight: FontWeight.normal),
                          //     ),
                          //     const SizedBox(
                          //       width: 4,
                          //     ),
                          //     Icon(
                          //       Icons.chevron_right,
                          //       size: 14,
                          //       color: Colors.grey.shade600,
                          //     )
                          //   ],
                          // )
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
    );
  }
}
