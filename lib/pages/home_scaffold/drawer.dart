import 'package:chat/chat_panel/chat_panel.dart';
import 'package:chat/chatroom/chatroom.dart';
import 'package:chat/drawer/drawer.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/services/conversation_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PageViewDrawer extends StatefulWidget {
  final ValueNotifier<Widget> body;
  final ValueNotifier<String> title;
  final ValueNotifier<List<Conversation>> conversations;
  final Function? onSettingsDrawerTap;

  const PageViewDrawer(
      {required this.body,
      required this.title,
      required this.conversations,
      this.onSettingsDrawerTap,
      super.key});

  @override
  State<PageViewDrawer> createState() => _PageViewDrawerState();
}

class _PageViewDrawerState extends State<PageViewDrawer> {
  int bottomSelectedIndex = 1;
  bool drawerIsOpen = true;

  PageController pageController = PageController(
    initialPage: 1,
    keepPage: true,
  );

  void pageChanged(int index) {
    setState(() {
      bottomSelectedIndex = index;
    });
    if (index == 0) {
      widget.title.value = "Settings";
    }
    if (index == 1) {
      widget.title.value = "Chat Arena";
    }
    widget.title.notifyListeners();
  }

  Widget buildPageView() {
    return PageView(
      physics: const ScrollPhysics(),
      controller: pageController,
      onPageChanged: (index) {
        pageChanged(index);
        // FirebaseAnalytics.instance.logEvent(name: getScreenName(index));
      },
      children: <Widget>[
        Column(
          children: [
            SettingsDrawer(onTap: (String page) {
              if (widget.onSettingsDrawerTap != null) {
                widget.onSettingsDrawerTap!(page);
              }
            })
          ],
        ),
        ConversationsList(
          conversations: widget.conversations,
          onDelete: (bool deleted) {
            widget.body.value = ChatRoomPage(
              key: UniqueKey(),
              conversation: null,
              onCreateNewConversation: (Conversation conv) async {
                await ConversationDatabase.instance.create(conv);
                widget.conversations.value.insert(0, conv);
                widget.conversations.notifyListeners();
              },
              onNewText: (Conversation lastMessageUpdate) async {
                // update the lastMessage sent
                await ConversationDatabase.instance.update(lastMessageUpdate);
                int idx = widget.conversations.value.indexWhere(
                    (element) => element.id == lastMessageUpdate.id);
                widget.conversations.value[idx] = lastMessageUpdate;
                widget.conversations.notifyListeners();
              },
            );
            widget.body.notifyListeners();
          },
          onTap: (Conversation chatSelected) {
            print("Conv: " + chatSelected.id);
            // set title
            widget.title.value = chatSelected.primaryModel ?? "Llama 2";

            widget.title.notifyListeners();
            // set homepage
            widget.body.value = ChatRoomPage(
              key: Key(chatSelected.id),
              conversation: chatSelected,
              onNewText: (Conversation lastMessageUpdate) async {
                // update the lastMessage sent
                await ConversationDatabase.instance.update(lastMessageUpdate);
                int idx = widget.conversations.value.indexWhere(
                    (element) => element.id == lastMessageUpdate.id);
                widget.conversations.value[idx] = lastMessageUpdate;
                widget.conversations.value.sort((a, b) {
                  return b.time!.compareTo(a.time!);
                });
                widget.conversations.notifyListeners();
              },
            );
            widget.body.notifyListeners();
          },
        )
      ],
    );
  }

  void bottomTapped(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      bottomSelectedIndex = index;
      pageController.animateToPage(index,
          duration: const Duration(milliseconds: 420), curve: Curves.ease);
    });
  }

  List<Widget> bottomNavigationBarItems() {
    final unselectedColor = Colors.grey[350];
    return [
      AnimatedScale(
          duration: const Duration(milliseconds: 160),
          scale: 0 == bottomSelectedIndex ? 1.15 : 1,
          child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              onTap: () => bottomTapped(0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.settings,
                  color: 1 == bottomSelectedIndex
                      ? unselectedColor
                      : Colors.grey[800],
                  size: 21,
                ),
              ))),
      const SizedBox(
        width: 7,
      ),
      AnimatedScale(
          duration: const Duration(milliseconds: 160),
          scale: 1 == bottomSelectedIndex ? 1.15 : 1,
          child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              onTap: () => bottomTapped(1),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(CupertinoIcons.chat_bubble_text_fill,
                    color: 0 == bottomSelectedIndex
                        ? unselectedColor
                        : Colors.blue[200],
                    size: 19),
              ))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: buildPageView()),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: bottomNavigationBarItems(),
        ),
        const SizedBox(
          height: 12,
        ),
      ],
    );
  }
}
