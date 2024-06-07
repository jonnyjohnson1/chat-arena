import 'package:flutter/material.dart';
import 'package:chat/chatroom/widgets/text_type_message/message_type.dart';
import '../../../../models/messages.dart';

class MessageListViewChild extends StatelessWidget {
  final _isOurMessage;
  final _message;

  const MessageListViewChild(this._isOurMessage, this._message, {super.key});

  @override
  Widget build(BuildContext context) {
    switch (_message.type) {
      case MessageType.text:
        return MessageTypeBubble(_isOurMessage, _message);

      case MessageType.deleted:
      // return DeletedMessageTypeBubble(
      //     _eventID, _isOurMessage, _message, _deviceWidth, _deviceHeight);

      case MessageType.poll:
        return Container();

      case MessageType.image:
        return Container();
      default:
        return Container(); //MessageTypeBubble();
    }
  }
}
