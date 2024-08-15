import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
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
            Expanded(
              child: Padding(
                padding:
                EdgeInsets.fromLTRB(widget.isDesktop ? 8.0 : 0, 2, 8, 2),
                child: CupertinoTextField(
                  controller: controller,
                  focusNode: _focusNode,
                  placeholder: "What's the best way to contact you?",
                  keyboardType: TextInputType.text,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (String text) {
                    if (text.trim().isEmpty) {
                      text = "What's the best way to contact you?";
                    }
                    widget.onSubmit(text);
                    controller.clear();
                    _focusNode.requestFocus();
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
      elevation: 1,
      hoverElevation: 3,
      highlightElevation: 3,
      child: const Icon(Icons.arrow_upward,
          color: Color.fromARGB(255, 124, 124, 124)),
      onPressed: () {
        if (controller.text.trim().isEmpty) {
          widget.onSubmit("What's the best way to contact you?");
        } else {
          widget.onSubmit(controller.text);
        }
        controller.clear();
        _focusNode.requestFocus();
      },
    );
  }
}
