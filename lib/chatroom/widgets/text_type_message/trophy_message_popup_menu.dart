import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum TrophyMessageAction { pushToHost, markWinner }

class TrophyMessagePopupButton extends StatefulWidget {
  final widget;

  TrophyMessagePopupButton(this.widget, {Key? key}) : super(key: key);

  @override
  _TrophyMessagePopupButtonState createState() =>
      _TrophyMessagePopupButtonState();
}

class _TrophyMessagePopupButtonState extends State<TrophyMessagePopupButton> {
  late TrophyMessageAction _selection;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TrophyMessageAction>(
      tooltip: null,
      offset: const Offset(0, -20),
      onSelected: (TrophyMessageAction result) {
        setState(() {
          _selection = result;
          if (kDebugMode) {
            print(_selection);
          }
        });
      },
      child: widget.widget,
      // icon: Icon(Icons.add),
      itemBuilder: (BuildContext context) =>
          <PopupMenuEntry<TrophyMessageAction>>[
        const PopupMenuItem<TrophyMessageAction>(
          value: TrophyMessageAction.markWinner,
          child: Text("Chat Ching!"),
        ),
        const PopupMenuItem<TrophyMessageAction>(
            value: TrophyMessageAction.pushToHost, child: Text("To Gus")),
      ],
    );
  }
}
