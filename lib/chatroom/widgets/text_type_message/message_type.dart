import 'package:chat/models/messages.dart';
import 'package:flutter/material.dart';
import 'package:chat/chatroom/widgets/text_type_message/text_message_bubble.dart';

class MessageTypeBubble extends StatelessWidget {
  final _isOurMessage;
  final Message _message;
  final bool alignMessagesCenter;

  const MessageTypeBubble(
      this._isOurMessage, this._message, this.alignMessagesCenter,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // !_isOurMessage ? UserImageWidget("winner", _deviceHeight) : Container(),
          const SizedBox(
            width: 9,
          ),
          Expanded(
              child: TextMessageBubble(
                  _isOurMessage, _message, alignMessagesCenter)),
          const SizedBox(
            width: 9,
          ),
        ],
      ),
    );
  }
}
