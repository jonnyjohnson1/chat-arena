import 'package:chat/models/messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SendStateIcon extends StatefulWidget {
  final ValueNotifier<SendState?> initialSendState;

  SendStateIcon({Key? key, required this.initialSendState}) : super(key: key);

  @override
  _SendStateIconState createState() => _SendStateIconState();
}

class _SendStateIconState extends State<SendStateIcon> {
  late ValueNotifier<SendState?> valueListenable;
  SendState? _currentSendState;

  @override
  void initState() {
    super.initState();
    valueListenable = widget.initialSendState;
    _currentSendState = valueListenable.value;

    valueListenable.addListener(_onSendStateChanged);
  }

  @override
  void dispose() {
    valueListenable.removeListener(_onSendStateChanged);
    super.dispose();
  }

  void _onSendStateChanged() {
    if (_currentSendState != valueListenable.value) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _currentSendState = valueListenable.value;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SendState?>(
      valueListenable: valueListenable,
      builder: (context, sendState, child) {
        if (_currentSendState == null) {
          return Container();
        } else if (_currentSendState == SendState.sending) {
          return const Icon(Icons.circle_outlined, size: 11);
        } else if (_currentSendState == SendState.sent) {
          return const Icon(Icons.check, size: 11);
        }
        return Container();
      },
    );
  }
}
