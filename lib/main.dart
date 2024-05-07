import 'package:chat/models/games_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat/chat_panel/chat_panel.dart';
import 'package:chat/chatroom/chatroom.dart';
import 'package:chat/drawer/drawer.dart';
import 'package:chat/model_widget/game_manager.dart';
import 'package:chat/model_widget/model_selection_list.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/models/llm.dart';
import 'package:chat/models/models.dart';
import 'package:chat/services/conversation_database.dart';
import 'package:chat/services/json_loader.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'models/model_loaded_states.dart';
import 'models/sys_resources.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize FFI
  sqfliteFfiInit();
  if (kIsWeb) {
    // Change default factory on the web
    databaseFactory = databaseFactoryFfiWeb;
  }

  return runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ML Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // final SwiftFunctionsInterface swiftInterface = SwiftFunctionsInterface();
  late ValueNotifier<LLM> llm;
  ValueNotifier<String> title = ValueNotifier("Chat Arena");
  late String directoryPath;
  ValueNotifier<List<GamesConfig>> games = ValueNotifier([]);
  ValueNotifier<MemoryConfig> sysResources =
      ValueNotifier(MemoryConfig(totalMemory: 17, usedMemory: 0.0));
  ValueNotifier<Widget> homePage = ValueNotifier(Container());
  ValueNotifier<List<Conversation>> conversations = ValueNotifier([]);

  // load model options
  // 1. load from the app-config.json
  // 2. read/write user's local file
  bool didInit = false;
  String deviceModel = "";
  Future<void> get _loadModelListFromAppConfig async {
    homePage.value = ChatRoomPage(
      conversation: null,
      onCreateNewConversation: (Conversation conv) async {
        await ConversationDatabase.instance.create(conv);
        conversations.value.insert(0, conv);
        conversations.notifyListeners();
      },
      onNewText: (Conversation lastMessageUpdate) async {
        // update the lastMessage sent
        await ConversationDatabase.instance.update(lastMessageUpdate);
        int idx = conversations.value
            .indexWhere((element) => element.id == lastMessageUpdate.id);
        conversations.value[idx] = lastMessageUpdate;
        conversations.notifyListeners();
      },
    );
    final jsonResult = await loadJson(); //latest Dart
    List<dynamic> gamesList = jsonResult['games_list'];
    for (dynamic game in gamesList) {
      games.value.add(GamesConfig.fromJson(game));
    }
    games.notifyListeners();

    didInit = true;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // sync the app config in flutter assets with the one on mobile device
    _loadModelListFromAppConfig;
    // load existing chats from device
    refreshConversationDatabase();

    // Future.delayed(const Duration(milliseconds: 0), () async => _localPath);
    llm = ValueNotifier(LLM(modelLoaded: modelLoaded.value));
  }

  @override
  void dispose() {
    ConversationDatabase.instance.close();
    super.dispose();
  }

  bool isLoadingConversations = false;
  Future refreshConversationDatabase() async {
    setState(() {
      isLoadingConversations = true;
    });
    conversations.value =
        await ConversationDatabase.instance.readAllConversations();
    setState(() {
      isLoadingConversations = false;
    });
  }

  final ImagePicker _picker = ImagePicker();

  ValueNotifier<ModelLoadedState> modelLoaded =
      ValueNotifier(ModelLoadedState.isEmpty);

  int chatroomState = 0;
  bool drawerIsOpen = true;
  int bottomSelectedIndex = 1;

  PageController pageController = PageController(
    initialPage: 1,
    keepPage: true,
  );

  void pageChanged(int index) {
    setState(() {
      bottomSelectedIndex = index;
    });
    if (index == 0) {
      title.value = "Settings";
    }
    if (index == 1) {
      title.value = "Chat Arena";
    }
    title.notifyListeners();
  }

  bool overlayIsOpen = false;

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

  OverlayEntry? suggestionStartTimeTagoverlayEntry;
  late double height, width, xPosition, yPosition;

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

    double childWidgetWidth = 310;

    suggestionStartTimeTagoverlayEntry = OverlayEntry(builder: (context) {
      return Positioned(
          // Decides where to place the tag on the screen.
          top: yPosition + 57,
          left: xPosition - (.5 * childWidgetWidth) + (.5 * width),
          child: MultiProvider(
            providers: [
              Provider.value(
                value: true,
              ),
            ],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  color: Colors.transparent,
                  child: Container(
                      constraints: const BoxConstraints(maxHeight: 490),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(4)),
                        border: Border.all(width: 1, color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 3,
                            offset: const Offset(
                                0, 2), // changes position of shadow
                          ),
                        ],
                      ),
                      width: childWidgetWidth,
                      child: ModelSelectionList(
                          duration: 90,
                          games: games,
                          modelLoaded: modelLoaded,
                          llm: llm,
                          onModelTap: (ModelConfig modelConfig) {
                            title.value = modelConfig.displayName;
                            title.notifyListeners();
                          })),
                ),
              ],
            ),
          ));
    });
    overlayState.insert(suggestionStartTimeTagoverlayEntry!);
  }

  removeHoverInfoTag(
      // BuildContext context,
      ) async {
    suggestionStartTimeTagoverlayEntry!.remove();
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
              if (page == "gamemanager") {
                title.value = "Game Manager";
                title.notifyListeners();
                homePage.value = GameManagerPage(
                  duration: 90,
                  games: games,
                  modelLoaded: modelLoaded,
                  systemResources: sysResources,
                  llm: llm,
                  homePage: homePage,
                );
                homePage.notifyListeners();
              }
            })
          ],
        ),
        ConversationsList(
          conversations: conversations,
          onDelete: (bool deleted) {
            homePage.value = ChatRoomPage(
              key: UniqueKey(),
              conversation: null,
              onCreateNewConversation: (Conversation conv) async {
                await ConversationDatabase.instance.create(conv);
                conversations.value.insert(0, conv);
                conversations.notifyListeners();
              },
              onNewText: (Conversation lastMessageUpdate) async {
                // update the lastMessage sent
                await ConversationDatabase.instance.update(lastMessageUpdate);
                int idx = conversations.value.indexWhere(
                    (element) => element.id == lastMessageUpdate.id);
                conversations.value[idx] = lastMessageUpdate;
                conversations.notifyListeners();
              },
            );
            homePage.notifyListeners();
          },
          onTap: (Conversation chatSelected) {
            print("Conv: " + chatSelected.id);
            // set title
            title.value = chatSelected.primaryModel ?? "Llama 2";

            title.notifyListeners();
            // set homepage
            homePage.value = ChatRoomPage(
              key: Key(chatSelected.id),
              conversation: chatSelected,
              onNewText: (Conversation lastMessageUpdate) async {
                // update the lastMessage sent
                await ConversationDatabase.instance.update(lastMessageUpdate);
                int idx = conversations.value.indexWhere(
                    (element) => element.id == lastMessageUpdate.id);
                conversations.value[idx] = lastMessageUpdate;
                conversations.value.sort((a, b) {
                  return b.time!.compareTo(a.time!);
                });
                conversations.notifyListeners();
              },
            );
            homePage.notifyListeners();
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
    double width = MediaQuery.of(context).size.width;
    bool isMobile = width < 550;
    return MultiProvider(
      providers: [
        Provider.value(value: true)
        // ValueListenableProvider<MemoryConfig>.value(value: sysResources),
      ],
      child: SelectionArea(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: isMobile
                ? null
                : IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      setState(() {
                        drawerIsOpen = !drawerIsOpen;
                      });
                    },
                  ),
            title: ValueListenableBuilder(
              valueListenable: title,
              builder: (ctx, tit, _) {
                return Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Center(
                      child: Builder(builder: (ctx) {
                        return InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          onTap: bottomSelectedIndex == 1
                              ? () {
                                  print("tapped");
                                  _overlayPopupController(ctx);
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
                                  Text(
                                    tit,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (bottomSelectedIndex == 1)
                                    Row(
                                      children: [
                                        const SizedBox(width: 3),
                                        Icon(
                                          Icons.keyboard_arrow_down_sharp,
                                          color: Colors.grey.shade600,
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
                    if (isMobile)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                              tooltip: "Games",
                              onPressed: () {
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
                                                bottom: MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom),
                                            constraints: const BoxConstraints(
                                                maxHeight: 700),
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height -
                                                85,
                                            child: GameManagerPage(
                                                duration: 90,
                                                games: games,
                                                modelLoaded: modelLoaded,
                                                systemResources: sysResources,
                                                llm: llm,
                                                isIphone: isMobile,
                                                homePage: homePage)),
                                      );
                                    });
                              },
                              icon: const Icon(Icons.menu))
                        ],
                      )
                  ],
                );
              },
            ),
          ),
          body: !didInit
              ? Container()
              : SafeArea(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (_) {
                      if (overlayIsOpen) {
                        _overlayPopupController(context);
                      }
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
                                    curve: Curves.bounceOut,
                                    width: drawerIsOpen ? 320 : 0,
                                    child: drawerIsOpen
                                        ? Column(
                                            children: [
                                              Expanded(child: buildPageView()),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children:
                                                    bottomNavigationBarItems(),
                                              ),
                                              const SizedBox(
                                                height: 12,
                                              ),
                                            ],
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
                                valueListenable: homePage,
                                builder: (context, home, _) {
                                  return home;
                                },
                              ),
                            ),
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
