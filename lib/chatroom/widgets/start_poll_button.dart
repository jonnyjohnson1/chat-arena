import 'package:flutter/material.dart';

class StartPollButton extends StatelessWidget {
  final _deviceHeight;

  StartPollButton(this._deviceHeight);

  @override
  Widget build(BuildContext context) {
    void _showcontent(_context) {
      showDialog(
        context: context, barrierDismissible: false, // user must tap button!

        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('You clicked on'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: [
                  Text('Now add the poll form here.'),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return SizedBox(
      height: _deviceHeight * 0.05,
      width: _deviceHeight * 0.05,
      child: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(Icons.poll, color: Colors.black87),
        onPressed: () {
          _showcontent(context);
          // if (_formKey.currentState.validate()) {
          //   UserEventDatabaseService(uid: this.widget._userData.uid).sendMessage(
          //     this.widget._eventID,
          //     Message(
          //       message: _messageText,
          //       timestamp: DateTime.now(),
          //       senderID: this.widget._userData.uid,
          //       type: MessageType.Text,
          //       status: null,
          //       name: this.widget._userData.name,
          //     ),
          //   );
          //   _formKey.currentState.reset();
          //   FocusScope.of(_context).unfocus();
          // }
        },
      ),
    );
  }
}
