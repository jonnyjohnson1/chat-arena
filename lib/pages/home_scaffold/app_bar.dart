import 'package:chat/models/display_configs.dart';
import 'package:chat/pages/settings/settings_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

buildAppBar(
    bool isMobile,
    ValueNotifier<String> titleListenable,
    ValueNotifier<DisplayConfigData> displayConfigListenable,
    int bottomSelectedIndex,
    bool overlayIsOpen,
    {required Function onMenuTap,
    required Function onAnalyticsTap,
    required Function onChatsTap,
    required Function overlayPopupController}) {
  return AppBar(
    automaticallyImplyLeading: false,
    leading: isMobile
        ? null
        : IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              onMenuTap();
            },
          ),
    actions: [Container()],
    title: ValueListenableBuilder(
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
                          ? const EdgeInsets.all(0)
                          : const EdgeInsets.only(right: 56.0),
                      child: Center(
                        child: Builder(builder: (ctx) {
                          return InkWell(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12)),
                            onTap: displayConfig.demoMode
                                ? () {
                                    overlayPopupController();
                                  }
                                : null,
                            child: Container(
                              decoration: BoxDecoration(
                                color: overlayIsOpen
                                    ? Colors.grey[200]
                                    : Colors.transparent,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(12)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18.0, vertical: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                      displayConfig.demoMode ? "Demo" : title,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (displayConfig.demoMode)
                                      Row(
                                        children: [
                                          const SizedBox(width: 3),
                                          Icon(Icons.keyboard_arrow_down_sharp,
                                              color: Color.fromARGB(
                                                  255, 41, 32, 32) //600,
                                              )
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    if (!isMobile)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.settings),
                            onPressed: () {
                              ValueNotifier<DisplayConfigData>
                                  displayConfigData =
                                  Provider.of<ValueNotifier<DisplayConfigData>>(
                                      ctx,
                                      listen: false);
                              showDialog(
                                context: ctx,
                                builder: (ctx) => MultiProvider(providers: [
                                  ChangeNotifierProvider.value(
                                      value: displayConfigData)
                                ], child: SettingsDialog(isMobile: isMobile)),
                              );
                            },
                          ),
                          IconButton(
                              tooltip: "Chat Analytics",
                              onPressed: () {
                                onAnalyticsTap();
                              },
                              icon: const Icon(Icons.show_chart))
                        ],
                      ),
                    if (isMobile)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              tooltip: "Games",
                              onPressed: () {
                                onMenuTap();
                              },
                              icon: const Icon(Icons.menu)),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  tooltip: "Chats",
                                  padding: const EdgeInsets.all(6),
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    onChatsTap();
                                  },
                                  icon:
                                      const Icon(CupertinoIcons.chat_bubble_2)),
                              IconButton(
                                  tooltip: "Chat Analytics",
                                  padding: const EdgeInsets.all(6),
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    onAnalyticsTap();
                                  },
                                  icon: const Icon(Icons.show_chart))
                            ],
                          ),
                        ],
                      )
                  ],
                ),
              );
            },
          );
        }),
  );
}
