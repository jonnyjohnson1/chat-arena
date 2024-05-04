import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat/chat_panel/chat_panel.dart';
import 'package:chat/chatroom/chatroom.dart';
import 'package:chat/drawer/drawer.dart';
import 'package:chat/model_widget/model_manager.dart';
import 'package:chat/model_widget/model_selection_list.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/models/llm.dart';
import 'package:chat/models/models.dart';
import 'package:chat/services/conversation_database.dart';
import 'package:chat/services/json_loader.dart';
import 'package:provider/provider.dart';

import 'model_widget/model_listview_card.dart';
import 'models/model_loaded_states.dart';
import 'models/sys_resources.dart';
import 'services/ios_system_resources.dart';

void main() =>
    {WidgetsFlutterBinding.ensureInitialized(), runApp(const MyApp())};

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
  ValueNotifier<List<ModelConfig>> models = ValueNotifier([]);
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
      modelLoadedState: modelLoaded,
    );
    // isIphone = await SystemResources().isIphone();
    // print("here1");
    // deviceModel = await SystemResources().getModel();
    deviceModel = "macOS";
    print("here2");
    final jsonResult = await loadJson(); //latest Dart
    List<dynamic> modelList = jsonResult['model_list'];
    for (dynamic model in modelList) {
      models.value.add(ModelConfig.fromJson(model));
    }
    models.notifyListeners();
    // sync with models on iOS
    print("Sync initiated on load");
    // sync with models on iOS
    // Map<String, dynamic> result =
    //     await swiftInterface.syncModelsListWithDevice(models.value);
    // // Convert result into dict models w/ key = local_id
    // Map<String, Map<String, dynamic>> resultDict = unpackModels(result);
    // print(resultDict);
    // Loop through the list from the valuenotifier and update all their values.
    // List<ModelConfig> updatedConfigs = [];
    // for (ModelConfig modelConfig in models.value) {
    //   String modelID = modelConfig.localID!;
    //   Map<String, dynamic> modelDict = resultDict[modelID]!;
    //   resultDict.remove(modelID);
    //   updatedConfigs.add(ModelConfig().fromMap(modelDict));
    // }

    // add any remaining models stored on device
    // for (String key in resultDict.keys) {
    //   Map<String, dynamic> modelDict = resultDict[key]!;
    //   updatedConfigs.add(ModelConfig().fromMap(modelDict));
    // }

    // print(updatedConfigs);
    // models.value = updatedConfigs;
    models.notifyListeners();
    didInit = true;
    setState(() {});

    // init the downloadModelState stream
    // SwiftFunctionsInterface()
    //     .subscribeToModelDownloadStream(modelDownloadStateCallback);

    // // init system resources stream
    SystemResources()
        .subscribeToSystemResourcesStream(eventResourcesStreamCallback);
  }

  modelDownloadStateCallback(Object? event) async {
    if (event != null) {
      // Convert Object? event to JSON string
      String jsonString = jsonEncode(event);
      // Decode JSON string into Map<String, dynamic>
      Map<String, dynamic> eventMap = jsonDecode(jsonString);
      // Convert result into dict models w/ key = local_id
      Map<String, Map<String, dynamic>> resultDict = unpackModels(eventMap);
      // Loop through the list from the valuenotifier and update all their values.
      List<ModelConfig> updatedConfigs = [];
      for (ModelConfig modelConfig in models.value) {
        String modelID = modelConfig.localID!;
        Map<String, dynamic> modelDict = resultDict[modelID]!;
        resultDict.remove(modelID);
        updatedConfigs.add(ModelConfig().fromMap(modelDict));
      }

      // add any remaining models stored on device
      for (String key in resultDict.keys) {
        Map<String, dynamic> modelDict = resultDict[key]!;
        updatedConfigs.add(ModelConfig().fromMap(modelDict));
      }

      models.value = updatedConfigs;
      models.notifyListeners();
    } else {
      // return null event generation
      // return const EventGenerationResponse(generation: "", progress: 0.0);
    }
  }

  eventResourcesStreamCallback(Object? event) async {
    if (event != null) {
      String jsonString = jsonEncode(event);
      Map<String, dynamic> eventMap = jsonDecode(jsonString);
      // Parse JSON using MemoryConfig
      try {
        MemoryConfig memoryConfig = MemoryConfig.fromJson(eventMap);
        sysResources.value = memoryConfig;
        sysResources.notifyListeners();
      } catch (e) {
        print("Error parsing sys resource data: $e");
      }
    } else {}
  }

  bool isIphone = false;

  @override
  void initState() {
    super.initState();
    // sync the app config in flutter assets with the one on mobile device
    _loadModelListFromAppConfig;
    // load existing chats from device
    // refreshConversationDatabase();

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
                // Provider<SwiftFunctionsInterface>.value(
                //   value: swiftInterface,
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
                          models: models,
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
              if (page == "modelmanager") {
                title.value = "Model Manager";
                title.notifyListeners();
                homePage.value = ModelManagerPage(
                  duration: 90,
                  models: models,
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
              modelLoadedState: modelLoaded,
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
              modelLoadedState: modelLoaded,
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
    return MultiProvider(
      providers: [
        Provider.value(value: true)
        // Provider<SwiftFunctionsInterface>.value(
        //   value: swiftInterface,
        // ),
        // ValueListenableProvider<MemoryConfig>.value(value: sysResources),
        // ValueListenableProvider<List<ModelConfig>>.value(value: models),
        // ValueListenableProvider<ModelLoadedState>.value(value: modelLoaded),
        // ValueListenableProvider<LLM>.value(value: llm)
      ],
      child: SelectionArea(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: isIphone
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
                    if (!isIphone)
                      Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: ValueListenableBuilder(
                            valueListenable: sysResources,
                            builder: (ctx, mem, _) {
                              if (mem.totalMemory != null &&
                                  mem.usedMemory != null) {
                                String usedMem = "0.0";
                                try {
                                  usedMem = getFileSizeString(
                                      bytes: mem.usedMemory!.toInt(),
                                      decimals: 0);
                                } catch (e) {
                                  print("Error getting fileSize String: $e");
                                }
                                String totMem = getFileSizeString(
                                    bytes: mem.totalMemory!, decimals: 2);
                                String perc =
                                    (mem.usedMemory! / mem.totalMemory! * 100)
                                        .toStringAsFixed(2);
                                return Row(
                                  mainAxisAlignment: isIphone
                                      ? MainAxisAlignment.start
                                      : MainAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment: isIphone
                                          ? CrossAxisAlignment.start
                                          : CrossAxisAlignment.end,
                                      children: [
                                        // Text("$deviceModel ",
                                        //     style: const TextStyle(fontSize: 14)),
                                        Text(("$usedMem ($perc%)"),
                                            style:
                                                const TextStyle(fontSize: 14)),
                                        Text(("of $totMem "),
                                            style:
                                                const TextStyle(fontSize: 14)),
                                      ],
                                    ),
                                  ],
                                );
                              }
                              return Container();
                            }),
                      ),
                    if (isIphone)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
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
                                            child: ModelManagerPage(
                                                duration: 90,
                                                models: models,
                                                modelLoaded: modelLoaded,
                                                systemResources: sysResources,
                                                llm: llm,
                                                isIphone: isIphone,
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
                          if (!isIphone)
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