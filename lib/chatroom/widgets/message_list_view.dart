import 'dart:async';
import 'package:chat/chatroom/widgets/message_list_view_child.dart';
import 'package:chat/models/messages.dart';
import 'package:chat/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MessageListView extends StatefulWidget {
  final parent;
  final _listViewController;
  final List<Message> messages;
  final bool alignMessagesCenter;

  MessageListView(this.parent, this._listViewController, this.messages,
      {this.alignMessagesCenter = false, Key? key})
      : super(key: key);

  @override
  State<MessageListView> createState() => _MessageListViewState();
}

class _MessageListViewState extends State<MessageListView> {
  late ScrollController _listViewController;
  late ValueNotifier<User> userModel;
  Timer? _scrollTimer;
  double _scrollSpeed = 30.0; // Adjust this value for faster scrolling
  double _scrollDirection = 0;

  @override
  void initState() {
    _listViewController = ScrollController();
    userModel = Provider.of<ValueNotifier<User>>(context, listen: false);
    super.initState();
  }

  void _startScrolling() {
    _scrollTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      final maxScrollExtent = _listViewController.position.maxScrollExtent;
      final minScrollExtent = _listViewController.position.minScrollExtent;
      final currentScrollPosition = _listViewController.position.pixels;

      // Ensure the scroll does not exceed boundaries
      if (_scrollDirection > 0 && currentScrollPosition < maxScrollExtent) {
        _listViewController.jumpTo(
          (_listViewController.position.pixels +
                  _scrollSpeed * _scrollDirection)
              .clamp(minScrollExtent, maxScrollExtent),
        );
      } else if (_scrollDirection < 0 &&
          currentScrollPosition > minScrollExtent) {
        _listViewController.jumpTo(
          (_listViewController.position.pixels +
                  _scrollSpeed * _scrollDirection)
              .clamp(minScrollExtent, maxScrollExtent),
        );
      } else {
        _stopScrolling(); // Stop scrolling if we hit the boundary
      }
    });
  }

  void _stopScrolling() {
    _scrollTimer?.cancel();
    _scrollTimer = null;
  }

  void _handleVisibilityChanged(VisibilityInfo visibilityInfo, int index) {
    var visiblePercentage = visibilityInfo.visibleFraction * 100;
    if (visiblePercentage == 0) {
      index = index - 1; // subtract one because of the leading white space
      // Detect when server message loses visibility to control topic and title display
      Message message = reversedList[index];
      if (message.type == MessageType.server) {
        String? senderID = reversedList[index].senderID;
        String? name = reversedList[index].name;
        debugPrint("$name-$senderID :: ${visibilityInfo.key} lost visibility");
      }
    }
  }

  List<Message> reversedList = [];

  @override
  Widget build(BuildContext context) {
    reversedList = widget.messages.reversed.toList();
    return Container(
      color: Colors.white,
      child: Align(
        alignment: Alignment.topCenter,
        child: Listener(
          onPointerMove: (event) {
            if (_listViewController.hasClients) {
              final maxScrollExtent =
                  _listViewController.position.maxScrollExtent;
              final minScrollExtent =
                  _listViewController.position.minScrollExtent;
              final currentScrollPosition = _listViewController.position.pixels;

              if (event.position.dy >
                      MediaQuery.of(context).size.height * 0.9 &&
                  currentScrollPosition < maxScrollExtent) {
                // Dragging near the bottom
                _scrollDirection = -1.0;
                if (_scrollTimer == null) _startScrolling();
              } else if (event.position.dy <
                      MediaQuery.of(context).size.height * 0.1 &&
                  currentScrollPosition > minScrollExtent) {
                // Dragging near the top
                _scrollDirection = 1.0;
                if (_scrollTimer == null) _startScrolling();
              } else {
                _stopScrolling();
              }
            }
          },
          onPointerUp: (_) {
            _stopScrolling();
          },
          child: Scrollbar(
            controller: _listViewController,
            child: ListView.builder(
              controller: _listViewController,
              shrinkWrap: true,
              // physics: FastScrollPhysics(),
              reverse: true,
              padding: const EdgeInsets.fromLTRB(1, 2, 7, 2),
              itemCount: widget.messages.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return const SizedBox(
                    height: 95,
                  );
                }
                var message = reversedList[index - 1];
                bool isOurMessage = message.senderID == userModel.value.uid;
                return VisibilityDetector(
                  key: Key("$index"),
                  onVisibilityChanged: (VisibilityInfo visibilityInfo) {
                    _handleVisibilityChanged(visibilityInfo, index);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: (index - 1) == (widget.messages.length - 1)
                            ? 45
                            : 0),
                    child: MessageListViewChild(
                      isOurMessage,
                      message,
                      widget.alignMessagesCenter,
                      key: Key(message.id),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _listViewController.dispose();
    super.dispose();
  }
}

class FastScrollPhysics extends ClampingScrollPhysics {
  const FastScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  FastScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return FastScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return super.applyPhysicsToUserOffset(position, offset * 2.0);
  }
}
