import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageField extends StatefulWidget {
  ValueNotifier<bool>? isGenerating;
  final onSubmit;
  final onPause;
  final onLoadImage;

  MessageField(
      {this.isGenerating,
      this.onPause,
      this.onSubmit,
      this.onLoadImage,
      Key? key})
      : super(key: key);

  @override
  _MessageFieldState createState() => _MessageFieldState();
}

class _MessageFieldState extends State<MessageField> {
  late GlobalKey<FormState> _formKey;

  _MessageFieldState() {
    _formKey = GlobalKey<FormState>();
  }

  final FocusNode _focusNode = FocusNode();
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _focusNode.requestFocus();
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 12),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: () async {
                await widget.onLoadImage();
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 2, 8, 2),
                child: CupertinoTextField(
                  controller: controller,
                  keyboardType: TextInputType.text,
                  minLines: 1,
                  maxLines: 5,
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (String text) {
                    if (text.trim() != "") {
                      widget.onSubmit(text);
                      controller.clear();
                      _focusNode.requestFocus();
                    }
                  },
                  cursorColor: Colors.black38,
                  style: const TextStyle(color: Colors.black87),
                  autocorrect: true,
                ),
              ),
            ),
            _sendMessageButton(context),
          ],
        ),
      ),
    );
  }

  Widget _sendMessageButton(BuildContext _context) {
    return FloatingActionButton(
      mini: true,
      tooltip: "Send",
      child: const Icon(Icons.arrow_upward,
          color: Color.fromARGB(255, 124, 124, 124)),
      onPressed: () {
        if (controller.text.trim() != "") {
          widget.onSubmit(controller.text);
          controller.clear();
          _focusNode.requestFocus();
        }
      },
    );
  }

  Widget _pauseGenerationButton(BuildContext _context) {
    return FloatingActionButton(
      tooltip: "Pause",
      child: const Icon(Icons.stop, color: Colors.black87),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          widget.onPause();
          // FocusScope.of(_context).unfocus();
        }
      },
    );
  }

  // Widget _startPollButton(BuildContext _context) {
  //   final _userData = Provider.of<UserData>(context);
  //   return SizedBox(
  //     height: 35,
  //     width: 35, //this.widget._height * 0.08,
  //     child: FloatingActionButton(
  //       backgroundColor: Colors.white,
  //       child: Icon(Icons.poll, color: Colors.black87),
  //       onPressed: () {
  //         if (_formKey.currentState.validate()) {
  //           UserEventDatabaseService(uid: _userData.uid).sendMessage(
  //             this.widget._eventID,
  //             Message(
  //               message: _messageText,
  //               timestamp: DateTime.now(),
  //               senderID: _userData.uid,
  //               type: MessageType.Text,
  //               status: null,
  //               name: _userData.name,
  //             ),
  //           );
  //           _formKey.currentState.reset();
  //           FocusScope.of(_context).unfocus();
  //         }
  //       },
  //     ),
  //   );
  // }
}
