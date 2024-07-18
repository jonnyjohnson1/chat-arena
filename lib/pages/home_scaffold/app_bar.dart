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
                              ? const EdgeInsets.all(0)
                              : const EdgeInsets.only(right: 56.0),
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
        if (!isMobile)
          Row(
            children: [
              CircleAvatar(
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
                        Provider.of<ValueNotifier<DisplayConfigData>>(context,
                            listen: false);
                    showDialog(
                      context: context,
                      builder: (context) => MultiProvider(providers: [
                        ChangeNotifierProvider.value(value: displayConfigData)
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
        if (isMobile)
          Row(
            children: [
              CircleAvatar(
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
                    padding: const EdgeInsets.all(5),
                    constraints: null,
                    onPressed: () {
                      onAnalyticsTap();
                    },
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
