import 'package:flutter/material.dart';
import 'package:chat/chatroom/widgets/deleted_type_message/deleted_message_bubble.dart';

class DeletedMessageTypeBubble extends StatelessWidget {
  final _isOurMessage;
  final _message;
  final _deviceWidth;
  final _deviceHeight;
  final _eventID;

  DeletedMessageTypeBubble(this._eventID, this._isOurMessage, this._message,
      this._deviceWidth, this._deviceHeight,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // !_isOurMessage ? UserImageWidget("winner", _deviceHeight) : Container(),
          const SizedBox(
            width: 10,
          ),
          DeletedMessageBubble(_eventID, _isOurMessage, _message, _deviceWidth),
        ],
      ),
    );
  }
}
