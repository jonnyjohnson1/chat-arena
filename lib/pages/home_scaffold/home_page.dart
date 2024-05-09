import 'package:chat/chatroom/chatroom.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/models/games_config.dart';
import 'package:chat/models/sys_resources.dart';
import 'package:chat/pages/home_scaffold/games/chat/ChatGamePage.dart';
import 'package:chat/pages/home_scaffold/home_page_layout_manager.dart';
import 'package:chat/services/conversation_database.dart';
import 'package:chat/services/json_loader.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ValueNotifier<Widget> homePage = ValueNotifier(Container());
  ValueNotifier<String> title = ValueNotifier("Chat Arena");
  late String directoryPath;
  ValueNotifier<List<GamesConfig>> games = ValueNotifier([]);
  ValueNotifier<MemoryConfig> sysResources =
      ValueNotifier(MemoryConfig(totalMemory: 17, usedMemory: 0.0));

  ValueNotifier<List<Conversation>> conversations = ValueNotifier([]);

  @override
  void initState() {
    _loadModelListFromAppConfig;

    refreshConversationDatabase();
    super.initState();
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

  // load model options
  // 1. load from the app-config.json
  bool didInit = false;
  Future<void> get _loadModelListFromAppConfig async {
    homePage.value = ChatGamePage(
      conversation: null,
      conversations: conversations,
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
  Widget build(BuildContext context) {
    return HomePageLayoutManager(
      title: title,
      conversations: conversations,
      games: games,
      body: !didInit ? ValueNotifier(Container()) : homePage,
    );
  }
}
