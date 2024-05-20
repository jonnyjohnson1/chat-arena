import 'package:flutter/material.dart';
import 'package:chat/chatroom/widgets/message_list_view_child.dart';
import 'package:chat/models/messages.dart';

class MessageListView extends StatefulWidget {
  final parent;
  final _listViewController;
  final List<Message> messages;

  MessageListView(this.parent, this._listViewController, this.messages,
      {Key? key})
      : super(key: key);

  @override
  State<MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  late ScrollController _listViewController;

  @override
  void initState() {
    _listViewController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Message> reversedList = widget.messages.reversed.toList();
    return Container(
        color: Colors.white,
        child: widget.messages.isNotEmpty
            ? Align(
                alignment: Alignment.topCenter,
                child: Scrollbar(
                  controller: _listViewController,
                  child: ListView.builder(
                    controller: _listViewController,
                    shrinkWrap: true,
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(1, 2, 1, 2),
                    itemCount:
                        widget.messages.length, //_conversationData.length,
                    itemBuilder: (BuildContext _context, int _index) {
                      var _message =
                          reversedList[_index]; //_conversationData[_index];
                      bool _isOurMessage = _message.senderID == ""; //_uid;
                      return MessageListViewChild(
                        _isOurMessage,
                        _message,
                        key: Key(_message.id),
                      );
                    },
                  ),
                ),
              )
            : const Center(
                child: Text("Write a message"),
              ));
  }
}
