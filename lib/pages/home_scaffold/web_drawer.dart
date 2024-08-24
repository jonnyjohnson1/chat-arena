import 'package:chat/chat_panel/chat_panel.dart';
import 'package:chat/p2p_chat_panel/p2p_chat_panel.dart';
import 'package:chat/drawer/settings_drawer.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/pages/home_scaffold/games/chat/ChatGamePage.dart';
import 'package:chat/pages/home_scaffold/games/debate/DebateGamePage.dart';
import 'package:chat/pages/home_scaffold/games/p2pchat/P2PChatGamePage.dart';
import 'package:chat/services/env_installer.dart';
import 'package:chat/shared/custom_scroll_behavior.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../theming/theming_config.dart';

class WebViewDrawer extends StatefulWidget {
  final bool isMobile;
  final ValueNotifier<Widget> body;
  final ValueNotifier<String> title;
  final ValueNotifier<List<Conversation>> conversations;
  final Function? onSettingsDrawerTap;

  const WebViewDrawer({
    required this.body,
    required this.title,
    required this.conversations,
    this.isMobile = false,
    this.onSettingsDrawerTap,
    super.key,
  });

  @override
  State<WebViewDrawer> createState() => _WebViewDrawerState();
}

class _WebViewDrawerState extends State<WebViewDrawer> {
  int bottomSelectedIndex = 0;
  late ValueNotifier<InstallerService> installerService;
  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    installerService =
        Provider.of<ValueNotifier<InstallerService>>(context, listen: false);

    // Define the pages that will be shown on swipes
    pages = [
      // if (!widget.isMobile)
      //   GamesListDrawer(onGameCardTap: (GamesConfig selectedGame) {
      //     widget.body.value = GamesInfoPage(game: selectedGame);
      //   }, onTap: (String page) {
      //     if (widget.onSettingsDrawerTap != null) {
      //       widget.onSettingsDrawerTap!(page);
      //     }
      //   }),
      if (widget.isMobile)
        MultiProvider(
            providers: [ChangeNotifierProvider.value(value: installerService)],
            child: const SettingsDrawer()),
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
      ),
      P2pConversationsList(
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
              "\t[ Switching to p2p conversation id :: ${chatSelected.id} ]");
          // set title
          String title = setTitle(chatSelected);
          widget.title.value = title;
          widget.title.notifyListeners();

          // set homepage
          widget.body.value = buildGamePage(chatSelected);
          widget.body.notifyListeners();
        },
      )
    ];
  }

  void onSwipeLeft() {
    if (bottomSelectedIndex < pages.length - 1) {
      setState(() {
        bottomSelectedIndex++;
      });
      Future.delayed(Duration(milliseconds: transitionDur + 300), () {
        isTransition = false;
      });
    }
  }

  void onSwipeRight() {
    if (bottomSelectedIndex > 0) {
      setState(() {
        bottomSelectedIndex--;
      });
      Future.delayed(Duration(milliseconds: transitionDur + 300), () {
        isTransition = false;
      });
    }
  }

  bool isTransition = false;
  int transitionDur = 160;

  void _onPointerSignal(PointerSignalEvent event) {
    const double scrollThreshold =
        20.0; // Adjust this value based on the sensitivity you want
    if (!isTransition) {
      if (event is PointerScrollEvent) {
        if (event.scrollDelta.dx.abs() > scrollThreshold) {
          isTransition = true;
          if (event.scrollDelta.dx > 0) {
            onSwipeLeft();
          } else if (event.scrollDelta.dx < 0) {
            onSwipeRight();
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ScrollConfiguration(
            behavior: CustomScrollBehavior(),
            child: Listener(
              onPointerSignal: _onPointerSignal,
              child: GestureDetector(
                trackpadScrollCausesScale: true,
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! < 0) {
                    onSwipeLeft(); // Swipe left to go to the next page
                  } else if (details.primaryVelocity! > 0) {
                    onSwipeRight(); // Swipe right to go to the previous page
                  }
                },
                child: pages[bottomSelectedIndex],
              ),
            ),
          ),
        ),
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

  String setTitle(Conversation? conversation) {
    if (conversation != null) {
      switch (conversation.gameType) {
        case GameType.chat:
          return ""; //conversation.title! ??
        case GameType.debate:
          return "";
        case GameType.p2pchat:
          return "";
        default:
          return "";
      }
    } else {
      return "Chat";
    }
  }

  Widget buildGamePage(Conversation? conversation) {
    if (conversation != null) {
      switch (conversation.gameType) {
        case GameType.p2pchat:
          print("buildGamePage P2PChat");
          return P2PChatGamePage(
            key: Key("${conversation.id}-home"),
            conversation: conversation,
            conversations: widget.conversations,
          );
        case GameType.chat:
          print("buildGamePage Chat");
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
    });
    Future.delayed(Duration(milliseconds: transitionDur + 300), () {
      isTransition = false;
    });
  }

  List<Widget> bottomNavigationBarItems() {
    final unselectedColor = Colors.grey[350];
    return [
      // AnimatedScale(
      //   duration: const Duration(milliseconds: 160),
      //   scale: 0 == bottomSelectedIndex ? 1.15 : 1,
      //   child: InkWell(
      //     borderRadius: const BorderRadius.all(Radius.circular(5)),
      //     onTap: () => bottomTapped(0),
      //     child: Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: Icon(
      //         Icons.settings,
      //         color:
      //             0 == bottomSelectedIndex ? Colors.grey[800] : unselectedColor,
      //         size: 21,
      //       ),
      //     ),
      //   ),
      // ),
      // const SizedBox(width: 7),
      AnimatedScale(
        duration: const Duration(milliseconds: 160),
        scale: 0 == bottomSelectedIndex ? 1.15 : 1,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          onTap: () => bottomTapped(0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              CupertinoIcons.chat_bubble_text_fill,
              color:
                  0 == bottomSelectedIndex ? chatBubbleColor : unselectedColor,
              size: 19,
            ),
          ),
        ),
      ),
      const SizedBox(width: 7),
      AnimatedScale(
        duration: const Duration(milliseconds: 160),
        scale: 1 == bottomSelectedIndex ? 1.15 : 1,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          onTap: () => bottomTapped(1),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              CupertinoIcons.person_2_fill,
              color:
                  1 == bottomSelectedIndex ? personIconColor : unselectedColor,
              size: 19,
            ),
          ),
        ),
      ),
    ];
  }
}
