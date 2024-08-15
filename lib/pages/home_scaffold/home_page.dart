import 'dart:io';

import 'package:chat/models/backend_connected.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/models/demo_controller.dart';
import 'package:chat/models/deployed_config.dart';
import 'package:chat/models/display_configs.dart';
import 'package:chat/services/env_installer.dart';
import 'package:chat/models/scripts.dart';
import 'package:chat/models/sys_resources.dart';
import 'package:chat/pages/home_scaffold/games/chat/ChatGamePage.dart';
import 'package:chat/pages/home_scaffold/home_page_layout_manager.dart';
import 'package:chat/services/conversation_database.dart';
import 'package:chat/services/json_loader.dart';
import 'package:chat/services/message_processor.dart';
import 'package:chat/services/scripts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:is_ios_app_on_mac/is_ios_app_on_mac.dart';
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
  ValueNotifier<String> title = ValueNotifier("");
  late String directoryPath;
  ValueNotifier<MemoryConfig> sysResources =
      ValueNotifier(MemoryConfig(totalMemory: 17, usedMemory: 0.0));
  ValueNotifier<DisplayConfigData> displayConfigData =
      ValueNotifier(DisplayConfigData());
  ValueNotifier<DeployedConfig> deployedConfig =
      ValueNotifier(DeployedConfig.init());
  ValueNotifier<Conversation?> currentSelectedConversation =
      ValueNotifier(null);
  MessageProcessor messageProcessor = MessageProcessor();

  ValueNotifier<List<Conversation>> conversations = ValueNotifier([]);
  ValueNotifier<User> userId = ValueNotifier(User(uid: ""));
  ValueNotifier<Scripts?> scripts = ValueNotifier(null);
  ValueNotifier<Script?> selectedScript = ValueNotifier(null);
  ValueNotifier<BackendService?> backendConnector =
      ValueNotifier(BackendService());
  ValueNotifier<DemoController> demoController = ValueNotifier(DemoController(
      state: DemoState.pause,
      index: 0,
      durBetweenMessages: 2000,
      isTypeWritten: true,
      autoPlay: false));
  late GlobalKey<NavigatorState> navigatorKey;

  late ValueNotifier<InstallerService> installerService;
  @override
  void initState() {
    _loadModelListFromAppConfig;
    refreshConversationDatabase();
    getDeployedConfig();
    navigatorKey =
        Provider.of<GlobalKey<NavigatorState>>(context, listen: false);
    installerService = ValueNotifier(InstallerService(
        navigatorKey: navigatorKey,
        apiConfig: displayConfigData.value.apiConfig));
    getUserID();
    // load senderID from sharedPrefs if none: ,
    getScripts();
    super.initState();
  }

  Future<void> getDeployedConfig() async {
    DeployedConfig.loadFromJsonAsset().then((loadedConfig) {
      deployedConfig.value = loadedConfig;
      if (loadedConfig.usePreloadedUrls) {
        print("[ setting default urls ]");
        displayConfigData.value.apiConfig.customEndpoint =
            loadedConfig.defaultBackend;
        installerService.value.apiConfig.customEndpoint =
            loadedConfig.defaultBackend;
      }

      if (deployedConfig.value.cloudHosted) {
        // ensures the default https configuration is a https: or wss: address
        displayConfigData.value.apiConfig.setSecure();
        installerService.value.apiConfig.setSecure();
      }
      initEnvironment();
    });
  }

  Future<void> printPlatform() async {
    if (kIsWeb) {
      print("Running on the Web");
    } else if (Platform.isWindows) {
      print("Running on Windows");
    } else if (Platform.isLinux) {
      print("Running on Linux");
    } else if (Platform.isMacOS) {
      print("Running on macOS");
    } else if (Platform.isIOS) {
      if (await IsIosAppOnMac().isiOSAppOnMac()) {
        print("Running on iOS app on Mac");
      } else {
        print("Running on iOS");
      }
    } else if (Platform.isAndroid) {
      print("Running on Android");
    } else {
      print("Unknown platform");
    }
    print(
        "Default address :: ${displayConfigData.value.apiConfig.getDefault()}");
  }

  void initEnvironment() async {
    printPlatform();
    installerService.value.initEnvironment().then((_) async {
      installerService.notifyListeners();
      installerService.value.printEnvironment();
    });
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

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ValueNotifier<InstallerService>>.value(
            value: installerService),
        ChangeNotifierProvider<ValueNotifier<DeployedConfig>>.value(
            value: deployedConfig),
        ChangeNotifierProvider<ValueNotifier<BackendService?>>.value(
            value: backendConnector),
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
        Provider<MessageProcessor>.value(value: messageProcessor)
      ],
      child: HomePageLayoutManager(
        title: title,
        conversations: conversations,
        body: !didInit ? ValueNotifier(Container()) : homePage,
      ),
    );
  }
}
