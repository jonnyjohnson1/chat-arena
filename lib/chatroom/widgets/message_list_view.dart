import 'package:flutter/material.dart';
import 'package:chat/chatroom/widgets/message_list_view_child.dart';
import 'package:chat/models/messages.dart';
import 'package:provider/provider.dart';
import 'package:chat/models/user.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
  late ValueNotifier<User> userModel;

  @override
  void initState() {
    _listViewController = ScrollController();
    userModel = Provider.of<ValueNotifier<User>>(context, listen: false);
    super.initState();
  }

  void _handleVisibilityChanged(VisibilityInfo visibilityInfo, int index) {
    var visiblePercentage = visibilityInfo.visibleFraction * 100;
    if (visiblePercentage == 0) {
      // Detect when server message loses visibility to control topic and title display
      Message message = reversedList[index];
      if (message.type == MessageType.server) {
        String? senderID = reversedList[index].senderID;
        String? name = reversedList[index].name;
        debugPrint("$name-$senderID :: ${visibilityInfo.key} lost visibility");
      }
    }
  }

  List<Message> reversedList = [];

  @override
  Widget build(BuildContext context) {
    reversedList = widget.messages.reversed.toList();
    return Container(
        color: Colors.white,
        child: Align(
          alignment: Alignment.topCenter,
          child: Scrollbar(
            controller: _listViewController,
            child: ListView.builder(
              controller: _listViewController,
              shrinkWrap: true,
              reverse: true,
              padding: const EdgeInsets.fromLTRB(1, 2, 7, 2),
              itemCount: widget.messages.length, //_conversationData.length,
              itemBuilder: (BuildContext context, int index) {
                var message = reversedList[index]; //_conversationData[_index];
                bool isOurMessage =
                    message.senderID == userModel.value.uid; //_uid;
                return VisibilityDetector(
                  key: Key("$index"),
                  onVisibilityChanged: (
                    VisibilityInfo visibilityInfo,
                  ) {
                    _handleVisibilityChanged(visibilityInfo, index);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: index == widget.messages.length - 1 ? 45 : 0),
                    child: MessageListViewChild(
                      isOurMessage,
                      message,
                      key: Key(message.id),
                    ),
                  ),
                );
              },
            ),
          ),
        ));
  }
}
