import 'package:chat/models/conversation.dart';
import 'package:chat/models/display_configs.dart';
import 'package:chat/pages/home_scaffold/widgets/demo_mode_title.dart';
import 'package:chat/services/platform_types.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

buildAppBar(
    bool isMobile,
    ValueNotifier<String> titleListenable,
    ValueNotifier<DisplayConfigData> displayConfigListenable,
    ValueNotifier<Conversation?> currentSelectedConversation,
    int bottomSelectedIndex,
    bool overlayIsOpen,
    bool mobileChatPageIsShowing,
    BuildContext context,
    {required Function onMenuTap,
    required Function onAnalyticsTap,
    required Function onSettingsTap,
    required Function overlayPopupController}) {
  return FutureBuilder(
      future: isDesktopPlatform(includeIosAppOnMac: true),
      builder: (context, isDesktop) {
        if (!isDesktop.hasData) return Container();
        return Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                child: IconButton(
                  tooltip: "Chats",
                  icon: Icon(
                    (!isDesktop.data! && mobileChatPageIsShowing)
                        ? Icons.chevron_left
                        : Icons.menu,
                    color: const Color.fromARGB(255, 124, 124, 124),
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
                                padding: isDesktop.data!
                                    ? const EdgeInsets.only(left: 37)
                                    : const EdgeInsets.only(left: 37),
                                child: Center(
                                  child: Builder(builder: (ctx) {
                                    return InkWell(
                                      onLongPress: !isDesktop.data!
                                          ? () {
                                              final newValue =
                                                  !displayConfig.demoMode;
                                              displayConfig.demoMode = newValue;
                                              displayConfigListenable
                                                  .notifyListeners();
                                            }
                                          : null,
                                      child: DemoModeWidget(
                                        demoMode: displayConfig.demoMode,
                                        title: title,
                                        onClose: isDesktop.data!
                                            ? () {
                                                final newValue =
                                                    !displayConfig.demoMode;
                                                displayConfig.demoMode =
                                                    newValue;
                                                displayConfigListenable
                                                    .notifyListeners();
                                                print("tapped close");
                                              }
                                            : () {},
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
                                    isConnected
                                        ? Icons.check_circle
                                        : Icons.error,
                                    color:
                                        isConnected ? Colors.green : Colors.red,
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
                  !isDesktop.data!
                      ? CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                          child: IconButton(
                              tooltip: "Chats",
                              padding: const EdgeInsets.all(5),
                              constraints: null,
                              onPressed: () {
                                onSettingsTap();
                              },
                              icon: const Icon(
                                Icons.grid_goldenratio,
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
                            onPressed: () async {
                              onSettingsTap();
                            },
                          ),
                        ),
                  const SizedBox(
                    width: 3,
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
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
      });
}
