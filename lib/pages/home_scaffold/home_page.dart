import 'package:chat/models/conversation.dart';
import 'package:chat/models/demoController.dart';
import 'package:chat/models/display_configs.dart';
import 'package:chat/models/scripts.dart';
import 'package:chat/models/sys_resources.dart';
import 'package:chat/pages/home_scaffold/games/chat/ChatGamePage.dart';
import 'package:chat/pages/home_scaffold/home_page_layout_manager.dart';
import 'package:chat/services/conversation_database.dart';
import 'package:chat/services/scripts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chat/services/tools.dart';
import 'package:chat/models/user.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ValueNotifier<Widget> homePage = ValueNotifier(Container());
  ValueNotifier<String> title = ValueNotifier("Chat Arena");
  late String directoryPath;
  ValueNotifier<MemoryConfig> sysResources =
      ValueNotifier(MemoryConfig(totalMemory: 17, usedMemory: 0.0));

  ValueNotifier<List<Conversation>> conversations = ValueNotifier([]);
  ValueNotifier<User> userId = ValueNotifier(User(uid: ""));
  ValueNotifier<Scripts?> scripts = ValueNotifier(null);
  ValueNotifier<Script?> selectedScript = ValueNotifier(null);
  ValueNotifier<DemoController> demoController = ValueNotifier(DemoController(
      state: DemoState.pause,
      index: 0,
      durBetweenMessages: 2000,
      isTypeWritten: true,
      autoPlay: false));
  @override
  void initState() {
    _loadModelListFromAppConfig;
    refreshConversationDatabase();
    getUserID();
    // load senderID from sharedPrefs if none: ,
    getScripts();
    super.initState();
  }

  void getScripts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString('userId');
    scripts.value = await loadScriptsJson(uid);
    scripts.notifyListeners();
  }

  void getUserID() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? _uid = prefs.getString('userId');
    if (_uid == null) {
      _uid = Tools().getRandomString(12);
      await prefs.setString('userId', _uid);
    }
    userId.value.uid = _uid;
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

  bool didInit = false;
  Future<void> get _loadModelListFromAppConfig async {
    homePage.value = ChatGamePage(
      conversation: null,
      conversations: conversations,
    );

    didInit = true;
    setState(() {});
  }

  ValueNotifier<DisplayConfigData> displayConfigData =
      ValueNotifier(DisplayConfigData());
  ValueNotifier<Conversation?> currentSelectedConversation =
      ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ValueNotifier<Conversation?>>.value(
            value: currentSelectedConversation),
        ChangeNotifierProvider<ValueNotifier<DisplayConfigData>>.value(
            value: displayConfigData),
        ChangeNotifierProvider<ValueNotifier<Scripts?>>.value(value: scripts),
        ChangeNotifierProvider<ValueNotifier<Script?>>.value(
            value: selectedScript),
        ChangeNotifierProvider<ValueNotifier<DemoController>>.value(
            value: demoController),
        ChangeNotifierProvider<ValueNotifier<User>>.value(value: userId),
      ],
      child: HomePageLayoutManager(
        title: title,
        conversations: conversations,
        body: !didInit ? ValueNotifier(Container()) : homePage,
      ),
    );
  }
}
