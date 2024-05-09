import 'package:chat/model_widget/game_manager.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/models/games_config.dart';
import 'package:chat/models/model_loaded_states.dart';
import 'package:chat/models/sys_resources.dart';
import 'package:chat/pages/home_scaffold/analytics_drawer.dart';
import 'package:chat/pages/home_scaffold/app_bar.dart';
import 'package:chat/pages/home_scaffold/drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePageLayoutManager extends StatefulWidget {
  final ValueNotifier<Widget> body;
  final ValueNotifier<String> title;
  final ValueNotifier<List<Conversation>> conversations;
  final ValueNotifier<List<GamesConfig>> games;
  const HomePageLayoutManager(
      {required this.body,
      required this.title,
      required this.conversations,
      required this.games,
      super.key});
  @override
  State<HomePageLayoutManager> createState() => _HomePageLayoutManagerState();
}

class _HomePageLayoutManagerState extends State<HomePageLayoutManager> {
  ValueNotifier<MemoryConfig> sysResources =
      ValueNotifier(MemoryConfig(totalMemory: 17, usedMemory: 0.0));

  @override
  void dispose() {
    super.dispose();
  }

  ValueNotifier<ModelLoadedState> modelLoaded =
      ValueNotifier(ModelLoadedState.isEmpty);

  bool drawerIsOpen = true;
  int bottomSelectedIndex = 1;

  bool analyticsDrawerIsOpen = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool isMobile = width < 550;
    return MultiProvider(
      providers: [
        Provider.value(value: true)
        // ValueListenableProvider<MemoryConfig>.value(value: sysResources),
      ],
      child: SelectionArea(
        child: Scaffold(
          appBar: buildAppBar(isMobile, widget.title, bottomSelectedIndex,
              onMenuTap: () {
            !isMobile
                ? setState(() {
                    drawerIsOpen = !drawerIsOpen;
                  })
                : showModalBottomSheet<void>(
                    context: context,
                    enableDrag: true,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10))),
                    builder: (BuildContext context) {
                      return MultiProvider(
                        providers: [
                          Provider.value(value: true)
                          // Provider<
                          //     SwiftFunctionsInterface>.value(
                          //   value: swiftInterface,
                          // ),
                        ],
                        child: Container(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            constraints: const BoxConstraints(maxHeight: 700),
                            height: MediaQuery.of(context).size.height - 85,
                            child: GameManagerPage(
                                duration: 90,
                                games: widget.games,
                                modelLoaded: modelLoaded,
                                systemResources: sysResources,
                                isIphone: isMobile,
                                homePage: widget.body)),
                      );
                    });
          }, onAnalyticsTap: () {
            debugPrint("Tapped");
            !isMobile
                ? setState(() {
                    analyticsDrawerIsOpen = !analyticsDrawerIsOpen;
                  })
                : null;
          }, onChatsTap: () {
            debugPrint("Chats");
            showModalBottomSheet<void>(
                context: context,
                enableDrag: true,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10))),
                builder: (BuildContext context) {
                  return MultiProvider(
                    providers: [
                      Provider.value(value: true)
                      // Provider<
                      //     SwiftFunctionsInterface>.value(
                      //   value: swiftInterface,
                      // ),
                    ],
                    child: Container(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        constraints: const BoxConstraints(maxHeight: 700),
                        height: MediaQuery.of(context).size.height * .5,
                        child: PageViewDrawer(
                          onSettingsDrawerTap: (String page) {
                            if (page == "gamemanager") {
                              widget.title.value = "Game Manager";
                              widget.title.notifyListeners();
                              widget.body.value = GameManagerPage(
                                duration: 90,
                                games: widget.games,
                                modelLoaded: modelLoaded,
                                systemResources: sysResources,
                                homePage: widget.body,
                              );
                              widget.body.notifyListeners();
                            }
                          },
                          body: widget.body,
                          conversations: widget.conversations,
                          title: widget.title,
                        )),
                  );
                });
          }),
          body: SafeArea(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) {
                // add any close menu items here
              },
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Center(
                child: Row(
                  children: [
                    if (!isMobile)
                      Row(
                        children: [
                          AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              curve: Curves.fastOutSlowIn,
                              width: drawerIsOpen ? 320 : 0,
                              child: drawerIsOpen
                                  ? PageViewDrawer(
                                      onSettingsDrawerTap: (String page) {
                                        if (page == "gamemanager") {
                                          widget.title.value = "Game Manager";
                                          widget.title.notifyListeners();
                                          widget.body.value = GameManagerPage(
                                            duration: 90,
                                            games: widget.games,
                                            modelLoaded: modelLoaded,
                                            systemResources: sysResources,
                                            homePage: widget.body,
                                          );
                                          widget.body.notifyListeners();
                                        }
                                      },
                                      body: widget.body,
                                      conversations: widget.conversations,
                                      title: widget.title,
                                    )
                                  : Container()),
                          if (drawerIsOpen)
                            Container(
                              width: 1,
                              color: Colors.grey,
                            ),
                        ],
                      ),
                    Expanded(
                      child: Container(
                        color: Colors.white,
                        child: ValueListenableBuilder(
                          valueListenable: widget.body,
                          builder: (context, home, _) {
                            return home;
                          },
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (analyticsDrawerIsOpen)
                          Container(
                            width: 1,
                            color: Colors.grey,
                          ),
                        AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.fastOutSlowIn,
                            width: analyticsDrawerIsOpen ? 320 : 0,
                            child: analyticsDrawerIsOpen
                                ? AnalyticsViewDrawer(
                                    onSettingsDrawerTap: (String page) {
                                      if (page == "gamemanager") {
                                        widget.title.value = "Game Manager";
                                        widget.title.notifyListeners();
                                        widget.body.value = GameManagerPage(
                                          duration: 90,
                                          games: widget.games,
                                          modelLoaded: modelLoaded,
                                          systemResources: sysResources,
                                          homePage: widget.body,
                                        );
                                        widget.body.notifyListeners();
                                      }
                                    },
                                    body: widget.body,
                                    conversations: widget.conversations,
                                    title: widget.title,
                                  )
                                : Container()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
