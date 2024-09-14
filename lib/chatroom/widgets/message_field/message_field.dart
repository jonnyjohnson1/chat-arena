import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MessageField extends StatefulWidget {
  ValueNotifier<bool>? isGenerating;
  bool isDesktop;
  final onSubmit;
  final onPause;
  final onLoadImage;

  MessageField(
      {this.isGenerating,
      this.isDesktop = true,
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
  final ScrollController scrollController = ScrollController();
  final lineHeight = 16.0; // Approximate line height in pixels
  final int maxLines = 5;

  KeyEventResult _handleKeyEvent(FocusNode focus, KeyEvent keyEvent) {
    if (HardwareKeyboard.instance.isShiftPressed &&
        keyEvent.logicalKey == LogicalKeyboardKey.enter &&
        keyEvent is KeyDownEvent) {
      // Insert a single newline character at the current cursor position
      final text = controller.text;
      final selection = controller.selection;
      final newText = text.replaceRange(selection.start, selection.end, '\n');
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + 1),
      );

      // Scroll down by 20 pixels to keep the cursor in view
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_getNumberOfLines() > maxLines) {
          _scrollDown();
        }
      });

      // Return handled to indicate that the event was processed
      return KeyEventResult.handled;
    } else if (keyEvent.logicalKey == LogicalKeyboardKey.enter &&
        keyEvent is KeyDownEvent) {
      // Trigger the submit logic
      if (controller.text != "") {
        widget.onSubmit(controller.text);
        controller.clear();
        // Explicitly request focus on the next frame to avoid losing focus
        Future.microtask(() => _focusNode.requestFocus());
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  int _getNumberOfLines() {
    final text = controller.text;

    final maxWidth = context.size?.width ?? 0;
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: const TextStyle(fontSize: 14.0)),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: maxWidth);
    return (textPainter.size.height / lineHeight).ceil();
  }

  void _scrollDown() {
    if (scrollController.hasClients) {
      // Scroll down by 20 pixels
      scrollController.jumpTo(scrollController.offset + 20);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _focusNode.requestFocus();
        });
      },
      child: Padding(
        padding: EdgeInsets.only(left: widget.isDesktop ? 5.0 : 0, right: 12),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.attach_file,
                color: Color.fromARGB(255, 124, 124, 124),
              ),
              onPressed: () async {
                await widget.onLoadImage();
              },
            ),
            Expanded(
              child: Padding(
                padding:
                    EdgeInsets.fromLTRB(widget.isDesktop ? 8.0 : 0, 2, 8, 2),
                child: Focus(
                  focusNode: _focusNode,
                  onKeyEvent: _handleKeyEvent,
                  child: CupertinoTextField(
                    controller: controller,
                    keyboardType: TextInputType.text,
                    minLines: 1,
                    maxLines: 5,
                    scrollController: scrollController,
                    // focusNode: _focusNode,
                    textInputAction: TextInputAction.send,
                    cursorColor: Colors.black38,
                    style: const TextStyle(color: Colors.black87),
                    autocorrect: true,
                  ),
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
      elevation: 1,
      hoverElevation: 3,
      highlightElevation: 3,
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
