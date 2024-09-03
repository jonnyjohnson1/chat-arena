import 'package:chat/chat_panel/chat_panel.dart';
import 'package:chat/p2p_chat_panel/p2p_chat_panel.dart';
import 'package:chat/drawer/settings_drawer.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/pages/home_scaffold/games/chat/ChatGamePage.dart';
import 'package:chat/pages/home_scaffold/games/debate/DebateGamePage.dart';
import 'package:chat/pages/home_scaffold/games/p2pchat/P2PChatGamePage.dart';
import 'package:chat/pages/home_scaffold/web_drawer.dart';
import 'package:chat/pages/settings/settings_page.dart';
import 'package:chat/services/env_installer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../theming/theming_config.dart';

class PageViewDrawer extends StatefulWidget {
  final bool isMobile;
  final ValueNotifier<Widget> body;
  final ValueNotifier<String> title;
  final ValueNotifier<List<Conversation>> conversations;
  final Function? onSettingsDrawerTap;
  final Function? onOpenChat;

  const PageViewDrawer._internal(
      {required this.body,
      required this.title,
      required this.conversations,
      this.isMobile = false,
      this.onSettingsDrawerTap,
      this.onOpenChat,
      super.key});

  static Widget create({
    required ValueNotifier<Widget> body,
    required ValueNotifier<String> title,
    required ValueNotifier<List<Conversation>> conversations,
    bool isMobile = false,
    Function? onSettingsDrawerTap,
    Function? onOpenChat,
    Key? key,
  }) {
    if (kIsWeb) {
      return WebViewDrawer(
        body: body,
        title: title,
        conversations: conversations,
        isMobile: isMobile,
        onSettingsDrawerTap: onSettingsDrawerTap,
        key: key,
      );
    } else {
      return PageViewDrawer._internal(
        body: body,
        title: title,
        conversations: conversations,
        isMobile: isMobile,
        onSettingsDrawerTap: onSettingsDrawerTap,
        onOpenChat: onOpenChat,
        key: key,
      );
    }
  }

  @override
  State<PageViewDrawer> createState() => _PageViewDrawerState();
}

class _PageViewDrawerState extends State<PageViewDrawer> {
  int bottomSelectedIndex = 0;
  bool drawerIsOpen = true;

  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  late ValueNotifier<InstallerService> installerService;

  @override
  void initState() {
    print("\t[ init PageviewDrawer _internal :: ismobile:${widget.isMobile} ]");
    super.initState();
    installerService =
        Provider.of<ValueNotifier<InstallerService>>(context, listen: false);
  }

  // page changed sets the drawer screen and sets the title
  void pageChanged(int index) {
    setState(() {
      bottomSelectedIndex = index;
    });
    if (index == 0) {
      widget.title.value = "";
    }
    if (index == 0) {
      widget.title.value = "";
    }
    if (index == 1) {
      widget.title.value = "";
    }
    widget.title.notifyListeners();
  }

  Widget buildPageView() {
    return PageView(
      physics: widget.isMobile
          ? const NeverScrollableScrollPhysics()
          : const ScrollPhysics(),
      controller: pageController,
      onPageChanged: (index) {
        pageChanged(index);
      },
      children: <Widget>[
        // if (!widget.isMobile)
        //   GamesListDrawer(onGameCardTap: (GamesConfig selectedGame) {
        //     widget.body.value = GamesInfoPage(game: selectedGame);
        //   }, onTap: (String page) {
        //     if (widget.onSettingsDrawerTap != null) {
        //       widget.onSettingsDrawerTap!(page);
        //     }
        //   }),

        P2pConversationsList(
          conversations: widget.conversations,
          isMobileLayout: widget.isMobile,
          onSettingsTap: () {
            if (widget.onSettingsDrawerTap != null) {
              debugPrint("\t[ tapped settings from mobile chat list ]");
              widget.onSettingsDrawerTap!();
            }
          },
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
            // trigger transition
            if (true) {
              // isMobileLayout
              print(widget.onOpenChat);
              if (widget.onOpenChat != null) {
                debugPrint("\t[ Transition page to conversation ]");
                widget.onOpenChat!();
              }
            }
          },
        ),
        AIChatList(
          conversations: widget.conversations,
          isMobileLayout: widget.isMobile,
          onSettingsTap: () {
            if (widget.onSettingsDrawerTap != null) {
              debugPrint("\t[ tapped settings from mobile chat list ]");
              widget.onSettingsDrawerTap!();
            }
          },
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

            // trigger transition
            if (true) {
              // isMobileLayout
              print(widget.onOpenChat);
              if (widget.onOpenChat != null) {
                debugPrint("\t[ Transition page to conversation ]");
                widget.onOpenChat!();
              }
            }
          },
        ),
        if (widget.isMobile) SettingsPage()
      ],
    );
  }

  // used to set the title, but we did away with the title at the top
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
      pageController.animateToPage(index,
          duration: Duration(milliseconds: widget.isMobile ? 1 : 420),
          curve: Curves.ease);
    });
  }

  Widget bottomNavigationBarItems(bool isMobile) {
    final unselectedColor = Colors.grey[350];
    final double iconSize = widget.isMobile ? 30 : 19;
    final double spacing = widget.isMobile ? 20 : 7;
    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
            mainAxisAlignment: isMobile
                ? MainAxisAlignment.spaceEvenly
                : MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(11)),
                    color: 0 == bottomSelectedIndex
                        ? chatIconColor.withOpacity(.18)
                        : const Color.fromARGB(0, 255, 255, 255),
                  ),
                  child: AnimatedScale(
                      duration:
                          Duration(milliseconds: widget.isMobile ? 1 : 160),
                      scale: 0 == bottomSelectedIndex ? 1.15 : 1,
                      child: InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          onTap: () => bottomTapped(0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(CupertinoIcons.chat_bubble_text_fill,
                                color: 0 == bottomSelectedIndex
                                    ? chatIconColor
                                    : unselectedColor,
                                size: iconSize),
                          ))),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(11)),
                    color: 1 == bottomSelectedIndex
                        ? aiChatBubbleColor.withOpacity(.12)
                        : const Color.fromARGB(0, 255, 255, 255),
                  ),
                  child: AnimatedScale(
                      duration:
                          Duration(milliseconds: widget.isMobile ? 1 : 160),
                      scale: 1 == bottomSelectedIndex ? 1.15 : 1,
                      child: InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5)),
                          onTap: () => bottomTapped(1),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.graphic_eq,
                                color: 1 == bottomSelectedIndex
                                    ? aiChatBubbleColor
                                    : unselectedColor,
                                size: iconSize),
                          ))),
                ),
              ),
              if (widget.isMobile)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(11)),
                      color: 2 == bottomSelectedIndex
                          ? Colors.black87.withOpacity(.09)
                          : const Color.fromARGB(0, 255, 255, 255),
                    ),
                    child: AnimatedScale(
                        duration:
                            Duration(milliseconds: widget.isMobile ? 1 : 160),
                        scale: 2 == bottomSelectedIndex ? 1.15 : 1,
                        child: InkWell(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5)),
                            onTap: () => bottomTapped(2),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(CupertinoIcons.settings,
                                  color: 2 == bottomSelectedIndex
                                      ? Colors.black87
                                      : unselectedColor,
                                  size: iconSize),
                            ))),
                  ),
                ),
            ]),
      );
    } else {
      return Material(
        color: Colors.transparent,
        child: Row(
            mainAxisAlignment: isMobile
                ? MainAxisAlignment.spaceEvenly
                : MainAxisAlignment.center,
            children: [
              AnimatedScale(
                  duration: const Duration(milliseconds: 160),
                  scale: 0 == bottomSelectedIndex ? 1.15 : 1,
                  child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      onTap: () => bottomTapped(0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(CupertinoIcons.chat_bubble_text_fill,
                            color: 0 == bottomSelectedIndex
                                ? chatIconColor
                                : unselectedColor,
                            size: iconSize),
                      ))),
              if (!isMobile)
                SizedBox(
                  width: spacing,
                ),
              AnimatedScale(
                  duration: const Duration(milliseconds: 160),
                  scale: 1 == bottomSelectedIndex ? 1.15 : 1,
                  child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      onTap: () => bottomTapped(1),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.graphic_eq,
                            color: 1 == bottomSelectedIndex
                                ? aiChatBubbleColor
                                : unselectedColor,
                            size: iconSize),
                      ))),
              if (isMobile)
                SizedBox(
                  width: spacing,
                ),
              if (isMobile)
                AnimatedScale(
                    duration: const Duration(milliseconds: 160),
                    scale: 2 == bottomSelectedIndex ? 1.15 : 1,
                    child: InkWell(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                        onTap: () => bottomTapped(2),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(CupertinoIcons.settings,
                              color: 2 == bottomSelectedIndex
                                  ? Colors.black87
                                  : unselectedColor,
                              size: iconSize),
                        ))),
            ]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Color(0xFFF7F2FA),
      child: Column(
        children: [
          Expanded(child: buildPageView()),
          // if (widget.isMobile)
          //   Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 8.0),
          //     child: Container(
          //       height: 1,
          //       color: Colors.black12,
          //     ),
          //   ),
          bottomNavigationBarItems(widget.isMobile),
          const SizedBox(
            height: 12,
          ),
        ],
      ),
    );
  }
}
