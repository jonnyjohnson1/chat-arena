import 'package:chat/models/conversation.dart';
import 'package:chat/models/display_configs.dart';
import 'package:chat/pages/settings/settings_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

buildAppBar(
    bool isMobile,
    ValueNotifier<String> titleListenable,
    ValueNotifier<DisplayConfigData> displayConfigListenable,
    ValueNotifier<Conversation?> currentSelectedConversation,
    int bottomSelectedIndex,
    bool overlayIsOpen,
    BuildContext context,
    {required Function onMenuTap,
    required Function onAnalyticsTap,
    required Function onChatsTap,
    required Function overlayPopupController}) {
  return Container(
    color: Colors.transparent,
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: IconButton(
            tooltip: "Games",
            icon: const Icon(
              Icons.menu,
              color: Color.fromARGB(255, 124, 124, 124),
              size: 24,
            ),
            padding: const EdgeInsets.all(5),
            constraints: null,
            onPressed: () {
              onMenuTap();
            },
          ),
        ),
        ValueListenableBuilder(
            valueListenable: currentSelectedConversation,
            builder: (ctx, Conversation? conversation, _) {
              bool isConnected = false;
              int numActiveUsers = 1;
              if (conversation == null) {
                return Container();
              }
              if (conversation.gameType == GameType.p2pchat) {
                return ElevatedButton(
                  onPressed: () {
                    // TODO function to start chat if disconnected
                  },
                  child: const Row(
                    children: [
                      Icon(
                        Icons.chat,
                        size: 20,
                      ),
                      SizedBox(width: 4),
                      Text('Connect Chat'),
                    ],
                  ),
                );
              }
              return Container();
            }),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: displayConfigListenable,
            builder: (ctx, displayConfig, _) {
              return ValueListenableBuilder(
                valueListenable: titleListenable,
                builder: (ctx, title, _) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (_) {
                      if (overlayIsOpen) {
                        overlayPopupController();
                      }
                    },
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Padding(
                          padding: isMobile
                              ? const EdgeInsets.only(left: 37)
                              : const EdgeInsets.only(left: 37),
                          child: Center(
                            child: Builder(builder: (ctx) {
                              return InkWell(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(12)),
                                onTap: null,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: !displayConfig.demoMode
                                        ? const Color.fromARGB(0, 255, 255, 255)
                                        : Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18.0, vertical: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (displayConfig.demoMode)
                                          const Row(
                                            children: [
                                              Icon(
                                                Icons.play_lesson_outlined,
                                                size: 20,
                                                color: Colors.black87,
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                            ],
                                          ),
                                        Text(
                                          displayConfig.demoMode
                                              ? "Chat Demo"
                                              : title,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
        Row(
          children: [
            ValueListenableBuilder(
                valueListenable: currentSelectedConversation,
                builder: (ctx, Conversation? conversation, _) {
                  bool isConnected = false;
                  int numActiveUsers = 1;
                  if (conversation == null) {
                    return Container();
                  }
                  if (conversation.gameType == GameType.p2pchat) {
                    return Row(mainAxisSize: MainAxisSize.min, children: [
                      Tooltip(
                        message: true ? "Connected" : "Disconnected",
                        preferBelow: false,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.white,
                          child: Icon(
                              isConnected ? Icons.check_circle : Icons.error,
                              color: isConnected ? Colors.green : Colors.red,
                              size: 16),
                        ),
                      ),
                      const SizedBox(width: 2),
                      // User Count
                      Tooltip(
                        message: "Active Participants",
                        preferBelow: false,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(13))),
                          child: Row(
                            children: [
                              const Icon(CupertinoIcons.group, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                '$numActiveUsers',
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(width: 6),
                            ],
                          ),
                        ),
                      )
                    ]);
                  }
                  return Container();
                }),
            isMobile
                ? CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    child: IconButton(
                        tooltip: "Chats",
                        padding: const EdgeInsets.all(5),
                        constraints: null,
                        onPressed: () {
                          onChatsTap();
                        },
                        icon: const Icon(
                          CupertinoIcons.chat_bubble_2,
                          color: Color.fromARGB(255, 124, 124, 124),
                          size: 24,
                        )),
                  )
                : CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                    child: IconButton(
                      tooltip: "Settings",
                      icon: const Icon(
                        Icons.settings,
                        color: Color.fromARGB(255, 124, 124, 124),
                        size: 24,
                      ),
                      padding: const EdgeInsets.all(5),
                      constraints: null,
                      onPressed: () {
                        ValueNotifier<DisplayConfigData> displayConfigData =
                            Provider.of<ValueNotifier<DisplayConfigData>>(
                                context,
                                listen: false);
                        showDialog(
                          context: context,
                          builder: (context) => MultiProvider(providers: [
                            ChangeNotifierProvider.value(
                                value: displayConfigData)
                          ], child: SettingsDialog(isMobile: isMobile)),
                        );
                      },
                    ),
                  ),
            const SizedBox(
              width: 3,
            ),
            CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: IconButton(
                  tooltip: "Chat Analytics",
                  onPressed: () {
                    onAnalyticsTap();
                  },
                  padding: const EdgeInsets.all(5),
                  constraints: null,
                  icon: const Icon(
                    Icons.show_chart,
                    color: Color.fromARGB(255, 124, 124, 124),
                    size: 24,
                  )),
            )
          ],
        ),
      ],
    ),
  );
}
