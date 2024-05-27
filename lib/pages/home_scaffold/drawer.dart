import 'package:chat/chat_panel/chat_panel.dart';
import 'package:chat/drawer/games_list_drawer.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/models/games_config.dart';
import 'package:chat/pages/home_scaffold/games/chat/ChatGamePage.dart';
import 'package:chat/pages/home_scaffold/games/debate/DebateGamePage.dart';
import 'package:chat/pages/home_scaffold/games/info_page.dart';
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

  // page changed sets the drawer screen and sets the title
  void pageChanged(int index) {
    setState(() {
      bottomSelectedIndex = index;
    });
    if (index == 0) {
      widget.title.value = "Chat Arena";
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
      },
      children: <Widget>[
        GamesListDrawer(onGameCardTap: (GamesConfig selectedGame) {
          widget.body.value = GamesInfoPage(game: selectedGame);
        }, onTap: (String page) {
          if (widget.onSettingsDrawerTap != null) {
            widget.onSettingsDrawerTap!(page);
          }
        }),
        ConversationsList(
          conversations: widget.conversations,
          onDelete: (bool deleted) {
            widget.body.value = ChatGamePage(
              key: UniqueKey(),
              conversation: null,
              conversations: widget.conversations,
            );
            widget.body.notifyListeners();
          },
          onTap: (Conversation chatSelected) {
            debugPrint(
                "\t[ Switching to conversation id :: ${chatSelected.id} ]");
            // set title
            String title = setTitle(chatSelected);
            widget.title.value = title;
            widget.title.notifyListeners();

            // set homepage
            widget.body.value = buildGamePage(chatSelected);
            widget.body.notifyListeners();
          },
        )
      ],
    );
  }

  String setTitle(Conversation? conversation) {
    if (conversation != null) {
      switch (conversation.gameType) {
        case GameType.chat:
          return "Chat"; //conversation.title! ??
        case GameType.debate:
          return "Debate";
        default:
          return "Chat";
      }
    } else {
      return "Chat";
    }
  }

  Widget buildGamePage(Conversation? conversation) {
    if (conversation != null) {
      switch (conversation.gameType) {
        case GameType.chat:
          return ChatGamePage(
            key: Key("${conversation.id}-home"),
            conversation: conversation,
            conversations: widget.conversations,
          );
        case GameType.debate:
          return DebateGamePage(
            key: Key("${conversation.id}-home"),
            conversation: conversation,
            conversations: widget.conversations,
          );
        default:
          return ChatGamePage(
            key: Key("${conversation.id}-home"),
            conversation: conversation,
            conversations: widget.conversations,
          );
      }
    } else {
      return ChatGamePage(
        key: UniqueKey(),
        conversation: conversation,
        conversations: widget.conversations,
      );
    }
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
                        : Color.fromARGB(255, 67, 230, 255),
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
