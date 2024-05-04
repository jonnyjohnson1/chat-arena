import 'dart:math';
import 'package:flutter/material.dart';

class DeletedMessageBubble extends StatefulWidget {
  final _isOurMessage;
  final _message;
  final _deviceWidth;
  final _eventID;

  DeletedMessageBubble(
      this._eventID, this._isOurMessage, this._message, this._deviceWidth,
      {Key? key})
      : super(key: key);

  @override
  _DeletedMessageBubbleState createState() => _DeletedMessageBubbleState();
}

class _DeletedMessageBubbleState extends State<DeletedMessageBubble> {
  Offset _tapPosition = const Offset(0.0, 0.0);
  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  // void changeIndex() {
  //   setState(() => index = random.nextInt(3));
  // }

  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // Change Text Color for Sender Name
    // List colors = [Colors.red, Colors.green, Colors.yellow];
    // Random random = Random();

    // int index = 0;

    // List<Color> _colorScheme = widget._isOurMessage
    //     ? [Colors.blue, Colors.blue]   //Color.fromRGBO(42, 117, 188, 1)
    //     : [const Color.fromRGBO(69, 69, 69, 1), const Color.fromRGBO(43, 43, 43, 1)];

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // _isPressed ? Container(height: 15, child: Row(
        //   children: [
        //     Icon(Icons.send),
        //     Icon(Icons.favorite),
        //   ],
        // ),) : Container(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                IconButton(
                    icon: const Icon(
                      Icons.undo,
                      color: Colors.black26,
                    ),
                    onPressed: () {
                      // UserEventDatabaseService().switchtoTextMessage(widget._eventID, widget._message.documentID);
                    }),
              ],
            ),
            Container(
              width: 15,
            ),
            GestureDetector(
              onTapDown: _storePosition,
              onLongPress: () {
                // _showPopupMenu();
                setState(() {
                  _isPressed = true;
                });
              },
              child: Column(
                children: [
                  Container(
                    // height: _deviceHeight * 0.10,
                    // width: _deviceWidth * 0.70,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    constraints: BoxConstraints(
                      maxWidth: widget._deviceWidth * 0.70,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      // gradient: LinearGradient(
                      //     colors: _colorScheme,
                      //     stops: [0.30, 0.70],
                      //     begin: Alignment.bottomLeft,
                      //     end: Alignment.topRight)
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Divider(endIndent: 25, thickness: 2.0),
                        // Text(this.widget._message.name ?? 'anon',
                        // style: TextStyle(color: Colors.black26,
                        // fontWeight: this.widget._isOurMessage ? FontWeight.bold : FontWeight.w200),),
                        Text(widget._message.name + "'s message was deleted",
                            style: const TextStyle(
                                color: Colors.black26,
                                decoration: TextDecoration.lineThrough)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // !this.widget._isOurMessage ? Row(
        //   crossAxisAlignment: CrossAxisAlignment.end,
        //   children: [
        //     Text("  "+ this.widget._message.name + "   " ?? 'anon',
        //             style: TextStyle(color: Colors.black)),
        //     Text(
        //         DateFormat('jm').format(this.widget._message.timestamp),
        //         style: TextStyle(color: Colors.black45, fontSize: 13),
        //       ),
        //   ],
        // ) : Container(),
      ],
    );
  }
}
