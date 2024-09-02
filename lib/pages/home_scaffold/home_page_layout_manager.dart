import 'dart:io';

import 'package:chat/drawer/settings_drawer.dart';
import 'package:chat/model_widget/game_manager.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/models/deployed_config.dart';
import 'package:chat/models/display_configs.dart';
import 'package:chat/models/games_config.dart';
import 'package:chat/models/model_loaded_states.dart';
import 'package:chat/models/scripts.dart';
import 'package:chat/models/sys_resources.dart';
import 'package:chat/pages/home_scaffold/analytics_drawer.dart';
import 'package:chat/pages/home_scaffold/app_bar.dart';
import 'package:chat/pages/home_scaffold/drawer.dart';
import 'package:chat/pages/home_scaffold/widgets/scripts_list.dart';
import 'package:chat/pages/settings/settings_dialog.dart';
// import 'package:chat/pages/settings/settings_alert_dialog.dart';
import 'package:chat/services/env_installer.dart';
import 'package:chat/services/platform_types.dart';
import 'package:chat/shared/slide_animation_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:is_ios_app_on_mac/is_ios_app_on_mac.dart';
import 'package:provider/provider.dart';

class HomePageLayoutManager extends StatefulWidget {
  final ValueNotifier<Widget> body;
  final ValueNotifier<String> title;
  final ValueNotifier<List<Conversation>> conversations;
  const HomePageLayoutManager(
      {required this.body,
      required this.title,
      required this.conversations,
      super.key});
  @override
  State<HomePageLayoutManager> createState() => _HomePageLayoutManagerState();
}

class _HomePageLayoutManagerState extends State<HomePageLayoutManager> {
  ValueNotifier<MemoryConfig> sysResources =
      ValueNotifier(MemoryConfig(totalMemory: 17, usedMemory: 0.0));
  late ValueNotifier<Conversation?> currentSelectedConversation;

  late ValueNotifier<DisplayConfigData> displayConfigData;
  late ValueNotifier<InstallerService> installerService;
  late ValueNotifier<DeployedConfig> deployedConfig;

  ValueNotifier<bool> startDrawerOpen = ValueNotifier(true);
  @override
  void initState() {
    super.initState();
    installerService =
        Provider.of<ValueNotifier<InstallerService>>(context, listen: false);

    displayConfigData =
        Provider.of<ValueNotifier<DisplayConfigData>>(context, listen: false);
    currentSelectedConversation =
        Provider.of<ValueNotifier<Conversation?>>(context, listen: false);
    deployedConfig =
        Provider.of<ValueNotifier<DeployedConfig>>(context, listen: false);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (MediaQuery.of(context).size.width < 1000) {
    //     setState(() {
    //       startDrawerOpen.value = false;
    //     });
    //   }
    // });
  }

  bool initSize = false;

  Future<Size> _fetchSize(BuildContext context) async {
    // Wait for the first frame to be built
    await Future.delayed(Duration.zero);
    return MediaQuery.of(context).size;
  }

  @override
  void dispose() {
    super.dispose();
  }

  ValueNotifier<ModelLoadedState> modelLoaded =
      ValueNotifier(ModelLoadedState.isEmpty);

  bool drawerIsOpen = true;
  bool endDrawerIsOpen = false;
  int bottomSelectedIndex = 1;

  bool analyticsDrawerIsOpen = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // This code puts a drop down menu on the app bar title click
  bool overlayIsOpen = false;

  OverlayEntry? suggestionStartTimeTagoverlayEntry;
  late double height, width, xPosition, yPosition;

  void _overlayPopupController(BuildContext ctx) {
    if (overlayIsOpen) {
      removeHoverInfoTag();
      setState(() {
        overlayIsOpen = false;
      });
    } else {
      setState(() {
        overlayIsOpen = true;
        showHoverInfoTag(
          ctx,
        );
      });
    }
  }

  showHoverInfoTag(
    BuildContext context,
  ) async {
    OverlayState overlayState = Overlay.of(context);
    RenderBox renderBox = context.findRenderObject() as RenderBox;

    //get location in box
    Offset offset = renderBox.localToGlobal(Offset.zero);
    width = renderBox.size.width;
    xPosition = offset.dx;
    yPosition = offset.dy;
    double fullWidth = MediaQuery.of(context).size.width;
    double childWidgetWidth = 310;

    ValueNotifier<Scripts?> scripts =
        Provider.of<ValueNotifier<Scripts?>>(context, listen: false);
    ValueNotifier<Script?> selectedScript =
        Provider.of<ValueNotifier<Script?>>(context, listen: false);

    suggestionStartTimeTagoverlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
          // Decides where to place the tag on the screen.
          top: yPosition + 57,
          left: (.5 * fullWidth) - (.5 * childWidgetWidth),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 490),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    border: Border.all(width: 1, color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset:
                            const Offset(0, 2), // changes position of shadow
                      ),
                    ],
                  ),
                  width: childWidgetWidth,
                  child: MultiProvider(
                      providers: [
                        ChangeNotifierProvider.value(value: scripts),
                        ChangeNotifierProvider.value(value: selectedScript)
                      ],
                      child: ScriptsSelectionDropdown(
                        width: childWidgetWidth,
                        onScriptSelectionTap: () {
                          // close the popup when an item has been selected
                          _overlayPopupController(context);
                        },
                      )),
                ),
              )
            ],
          ));
    });
    overlayState.insert(suggestionStartTimeTagoverlayEntry!);
  }

  removeHoverInfoTag(
      // BuildContext context,
      ) async {
    suggestionStartTimeTagoverlayEntry!.remove();
  }

  ValueNotifier<bool> mobileHomePageShowChat = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Size>(
        future: _fetchSize(context),
        builder: (BuildContext context, AsyncSnapshot<Size> snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          if (!initSize) {
            final size = snapshot.data!;
            startDrawerOpen.value = size.width >= 1000;
            initSize = true;
          }
          return FutureBuilder<bool>(
              future: isDesktopPlatform(includeIosAppOnMac: true),
              builder: (context, isDesktop) {
                if (!isDesktop.hasData) {
                  return Container(
                    color: Colors.white,
                  );
                }
                double width = MediaQuery.of(context).size.width;
                bool isMobileLayout = !isDesktop.data!;

                if (isMobileLayout && analyticsDrawerIsOpen) {
                  Future.delayed(const Duration(milliseconds: 599), () {
                    setState(() {
                      analyticsDrawerIsOpen = false;
                    });
                  });
                }
                if (!isMobileLayout && endDrawerIsOpen) {
                  // close enddrawer if it is open on mobile -> tablet view switch
                  Future.delayed(const Duration(milliseconds: 599), () {
                    setState(() {
                      endDrawerIsOpen = false;
                      _scaffoldKey.currentState?.closeEndDrawer();
                    });
                  });
                }
                return MultiProvider(
                  providers: [
                    Provider.value(value: true)
                    // ValueListenableProvider<MemoryConfig>.value(value: sysResources),
                  ],
                  child: SelectionArea(
                    child: Scaffold(
                      drawerScrimColor: const Color.fromARGB(57, 61, 61, 61),
                      key: _scaffoldKey,
                      endDrawer: Drawer(
                          child: Container(
                        color: Colors.white,
                        child: SafeArea(
                          bottom: false,
                          child: AnalyticsViewDrawer.create(
                            isMobile: isMobileLayout,
                            onSettingsDrawerTap: (String page) {
                              if (page == "gamemanager") {
                                widget.title.value = "Game Manager";
                                widget.title.notifyListeners();
                                widget.body.value = GamesListPage(
                                  duration: 90,
                                  selectedGame: (GamesConfig selected) {
                                    // TODO Update home page to game viewer page
                                  },
                                );
                                widget.body.notifyListeners();
                              }
                            },
                            body: widget.body,
                            conversations: widget.conversations,
                            title: widget.title,
                          ),
                        ),
                      )),
                      // appBar: ,
                      body: Container(
                        color: Colors.white,
                        child: Stack(
                          children: [
                            SafeArea(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTapDown: (_) {
                                  // add any close menu items here
                                  if (overlayIsOpen) {
                                    _overlayPopupController(context);
                                  }
                                },
                                onTap: () {
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                },
                                child: Center(
                                  child: Row(
                                    children: [
                                      if (!isMobileLayout)
                                        Row(
                                          children: [
                                            ValueListenableBuilder<bool>(
                                                valueListenable:
                                                    startDrawerOpen,
                                                builder: (context,
                                                    _startDrawerOpen, _) {
                                                  return AnimatedContainer(
                                                      duration: const Duration(
                                                          milliseconds: 150),
                                                      curve:
                                                          Curves.fastOutSlowIn,
                                                      width: _startDrawerOpen
                                                          ? drawerIsOpen
                                                              ? 320
                                                              : 0
                                                          : 0,
                                                      child: drawerIsOpen
                                                          ? Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      top:
                                                                          45.0),
                                                              child:
                                                                  PageViewDrawer
                                                                      .create(
                                                                onSettingsDrawerTap:
                                                                    (String
                                                                        page) {
                                                                  print(
                                                                      "clicked");
                                                                  if (page ==
                                                                      "gamemanager") {
                                                                    if (!startDrawerOpen
                                                                        .value) {
                                                                      startDrawerOpen
                                                                              .value =
                                                                          true;
                                                                      startDrawerOpen
                                                                          .notifyListeners();
                                                                    }
                                                                    widget.title
                                                                            .value =
                                                                        "Game Manager";
                                                                    widget.title
                                                                        .notifyListeners();
                                                                    widget.body
                                                                            .value =
                                                                        GamesListPage(
                                                                      duration:
                                                                          90,
                                                                      selectedGame:
                                                                          (GamesConfig
                                                                              selected) {
                                                                        // TODO Update home page to game viewer page
                                                                      },
                                                                      // homePage: widget.body,
                                                                    );
                                                                    widget.body
                                                                        .notifyListeners();
                                                                  }
                                                                },
                                                                body:
                                                                    widget.body,
                                                                conversations:
                                                                    widget
                                                                        .conversations,
                                                                title: widget
                                                                    .title,
                                                              ),
                                                            )
                                                          : Container());
                                                }),
                                            if (drawerIsOpen)
                                              Container(
                                                width: 1,
                                                color: const Color.fromARGB(
                                                    255, 238, 238, 238),
                                              ),
                                          ],
                                        ),
                                      if (!isMobileLayout)
                                        Expanded(
                                          child: ValueListenableBuilder(
                                            valueListenable: widget.body,
                                            builder: (context, home, _) {
                                              return home;
                                            },
                                          ),
                                        ),
                                      if (isMobileLayout)
                                        Expanded(
                                          child: Expanded(
                                            child: SlideAnimationWidget(
                                              isShowingChatPage:
                                                  mobileHomePageShowChat,
                                              onReturnToMenuCompleted: () => {
                                                mobileHomePageShowChat.value =
                                                    false,
                                              },
                                              chatPage: Container(
                                                key: ValueKey('showChatPage'),
                                                color: Colors.white,
                                                child: ValueListenableBuilder(
                                                  valueListenable: widget.body,
                                                  builder: (context, home, _) {
                                                    return home;
                                                  },
                                                ),
                                              ),
                                              nonChatPage: Padding(
                                                key: ValueKey(
                                                    'showPageViewDrawer'),
                                                padding: EdgeInsets.only(
                                                    top: isMobileLayout
                                                        ? 0
                                                        : 45.0),
                                                child: PageViewDrawer.create(
                                                  isMobile: isMobileLayout,
                                                  onOpenChat: () {
                                                    mobileHomePageShowChat
                                                            .value =
                                                        !mobileHomePageShowChat
                                                            .value;
                                                  },
                                                  onSettingsDrawerTap: () {
                                                    showModalBottomSheet<void>(
                                                        context: context,
                                                        enableDrag: true,
                                                        barrierColor:
                                                            const Color.fromARGB(
                                                                57, 61, 61, 61),
                                                        isScrollControlled:
                                                            true,
                                                        shape: const RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10))),
                                                        builder: (BuildContext
                                                            context) {
                                                          return MultiProvider(
                                                            providers: [
                                                              ChangeNotifierProvider
                                                                  .value(
                                                                      value:
                                                                          displayConfigData),
                                                              ChangeNotifierProvider
                                                                  .value(
                                                                      value:
                                                                          installerService),
                                                              ChangeNotifierProvider
                                                                  .value(
                                                                      value:
                                                                          deployedConfig),
                                                            ],
                                                            child: Container(
                                                                padding: EdgeInsets.only(
                                                                    bottom: MediaQuery.of(
                                                                            context)
                                                                        .viewInsets
                                                                        .bottom),
                                                                constraints:
                                                                    const BoxConstraints(
                                                                        maxHeight:
                                                                            700),
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.85,
                                                                child: MultiProvider(
                                                                    providers: [
                                                                      ChangeNotifierProvider.value(
                                                                          value:
                                                                              installerService)
                                                                    ],
                                                                    child:
                                                                        const SettingsDrawer())),
                                                          );
                                                        });
                                                  },
                                                  body: widget.body,
                                                  conversations:
                                                      widget.conversations,
                                                  title: widget.title,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      Row(
                                        children: [
                                          if (analyticsDrawerIsOpen)
                                            Container(
                                              width: 1,
                                              color: const Color.fromARGB(
                                                  255, 238, 238, 238),
                                            ),
                                          AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 150),
                                              curve: Curves.fastOutSlowIn,
                                              width: analyticsDrawerIsOpen
                                                  ? 320
                                                  : 0,
                                              child: analyticsDrawerIsOpen
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 45.0),
                                                      child: AnalyticsViewDrawer
                                                          .create(
                                                        onSettingsDrawerTap:
                                                            (String page) {
                                                          if (page ==
                                                              "gamemanager") {
                                                            widget.title.value =
                                                                "Game Manager";
                                                            widget.title
                                                                .notifyListeners();
                                                            widget.body.value =
                                                                GamesListPage(
                                                              duration: 90,
                                                              selectedGame:
                                                                  (GamesConfig
                                                                      selected) {
                                                                // TODO Update home page to game viewer page
                                                              },
                                                            );
                                                            widget.body
                                                                .notifyListeners();
                                                          }
                                                        },
                                                        body: widget.body,
                                                        conversations: widget
                                                            .conversations,
                                                        title: widget.title,
                                                      ),
                                                    )
                                                  : Container()),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SafeArea(
                              child: ValueListenableBuilder<bool>(
                                  valueListenable: mobileHomePageShowChat,
                                  builder:
                                      (context, mobileChatPageIsShowing, _) {
                                    if (!mobileChatPageIsShowing) {
                                      return Container();
                                      // Container(
                                      //     height: 45,
                                      //     decoration: const BoxDecoration(
                                      //       gradient: LinearGradient(
                                      //         begin: Alignment.topCenter,
                                      //         end: Alignment.bottomCenter,
                                      //         stops: [
                                      //           0,
                                      //           0.08,
                                      //           .21,
                                      //           .40,
                                      //           .45,
                                      //           .6
                                      //         ],
                                      //         colors: [
                                      //           Colors.white,
                                      //           Color.fromARGB(
                                      //               245, 255, 255, 255),
                                      //           Color.fromARGB(
                                      //               235, 255, 255, 255),
                                      //           Color.fromARGB(
                                      //               183, 255, 255, 255),
                                      //           Color.fromARGB(
                                      //               155, 255, 255, 255),
                                      //           Color.fromARGB(0, 255, 255, 255)
                                      //         ],
                                      //       ),
                                      //     ),
                                      //     child:
                                      //         Container() // create a mobile app bar menu here
                                      //     );
                                    }
                                    return Container(
                                      height: 45,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          stops: [0, 0.08, .21, .40, .45, .6],
                                          colors: [
                                            Colors.white,
                                            Color.fromARGB(245, 255, 255, 255),
                                            Color.fromARGB(235, 255, 255, 255),
                                            Color.fromARGB(183, 255, 255, 255),
                                            Color.fromARGB(155, 255, 255, 255),
                                            Color.fromARGB(0, 255, 255, 255)
                                          ],
                                        ),
                                      ),
                                      child: buildAppBar(
                                          isMobileLayout,
                                          widget.title,
                                          displayConfigData,
                                          currentSelectedConversation,
                                          bottomSelectedIndex,
                                          overlayIsOpen,
                                          mobileChatPageIsShowing,
                                          context, onMenuTap: () async {
                                        if (await isDesktopPlatform(
                                            includeIosAppOnMac: true)) {
                                          setState(() {
                                            if (!startDrawerOpen.value) {
                                              startDrawerOpen.value = true;
                                              startDrawerOpen.notifyListeners();
                                            } else {
                                              drawerIsOpen = !drawerIsOpen;
                                            }
                                          });
                                        } else {
                                          mobileHomePageShowChat.value =
                                              !mobileHomePageShowChat.value;
                                        }
                                      }, onAnalyticsTap: () async {
                                        await isDesktopPlatform(
                                                includeIosAppOnMac: true)
                                            ? setState(() {
                                                analyticsDrawerIsOpen =
                                                    !analyticsDrawerIsOpen;
                                              })
                                            : endDrawerIsOpen
                                                ? _scaffoldKey.currentState
                                                    ?.closeEndDrawer()
                                                : _scaffoldKey.currentState
                                                    ?.openEndDrawer();
                                      }, onSettingsTap: () async {
                                        double width =
                                            MediaQuery.of(context).size.width;

                                        print(
                                            "Eval: ${kIsWeb && (width > 600)}");
                                        print(
                                            "isMobileLayout: ${isMobileLayout}");

                                        if (!isMobileLayout && (width > 600)) {
                                          ValueNotifier<DisplayConfigData>
                                              displayConfigData = Provider.of<
                                                      ValueNotifier<
                                                          DisplayConfigData>>(
                                                  context,
                                                  listen: false);
                                          ValueNotifier<InstallerService>
                                              installer = Provider.of<
                                                      ValueNotifier<
                                                          InstallerService>>(
                                                  context,
                                                  listen: false);
                                          ValueNotifier<DeployedConfig>
                                              deployedConfig = Provider.of<
                                                      ValueNotifier<
                                                          DeployedConfig>>(
                                                  context,
                                                  listen: false);
                                          // Future.delayed(
                                          //     const Duration(seconds: 1), () {
                                          //   displayConfigData.notifyListeners();
                                          // });
                                          await showDialog(
                                            context: context,
                                            builder: (context) =>
                                                MultiProvider(providers: [
                                              ChangeNotifierProvider.value(
                                                  value: displayConfigData),
                                              ChangeNotifierProvider.value(
                                                  value: deployedConfig),
                                              ChangeNotifierProvider.value(
                                                  value: installer)
                                            ], child: SettingsDialog()),
                                          );
                                        } else {
                                          showModalBottomSheet<void>(
                                              context: context,
                                              enableDrag: true,
                                              barrierColor:
                                                  const Color.fromARGB(
                                                      57, 61, 61, 61),
                                              isScrollControlled: true,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(10),
                                                              topRight: Radius
                                                                  .circular(
                                                                      10))),
                                              builder: (BuildContext context) {
                                                return MultiProvider(
                                                  providers: [
                                                    ChangeNotifierProvider.value(
                                                        value:
                                                            displayConfigData),
                                                    ChangeNotifierProvider.value(
                                                        value:
                                                            installerService),
                                                    ChangeNotifierProvider
                                                        .value(
                                                            value:
                                                                deployedConfig),
                                                  ],
                                                  child: Container(
                                                      padding: EdgeInsets.only(
                                                          bottom: MediaQuery.of(
                                                                  context)
                                                              .viewInsets
                                                              .bottom),
                                                      constraints:
                                                          const BoxConstraints(
                                                              maxHeight: 700),
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.85,
                                                      child: MultiProvider(
                                                          providers: [
                                                            ChangeNotifierProvider
                                                                .value(
                                                                    value:
                                                                        installerService)
                                                          ],
                                                          child:
                                                              const SettingsDrawer())),
                                                );
                                              });
                                        }
                                      }, overlayPopupController: () {
                                        _overlayPopupController(context);
                                      }),
                                    );
                                  }),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
        });
  }
}
