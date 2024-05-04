import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum MessageAction { pushToHost, markWinner }

class MessagePopupButton extends StatefulWidget {
  final widget;

  MessagePopupButton(this.widget);

  @override
  _MessagePopupButtonState createState() => _MessagePopupButtonState();
}

class _MessagePopupButtonState extends State<MessagePopupButton> {
  late MessageAction _selection;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MessageAction>(
      tooltip: null,
      offset: const Offset(0, -20),
      onSelected: (MessageAction result) {
        setState(() {
          _selection = result;
          if (kDebugMode) {
            print(_selection);
          }
        });
      },
      child: widget.widget,
      // icon: Icon(Icons.add),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<MessageAction>>[
        PopupMenuItem<MessageAction>(
            value: MessageAction.markWinner,
            child: Row(
              children: [
                Text("WIN!"),
                Divider(),
                Text("To Gus"),
              ],
            )),
        // const PopupMenuItem<MessageAction>(
        //   value: MessageAction.pushToHost,
        //   child: Text("To Gus")),
      ],
    );
  }
}
