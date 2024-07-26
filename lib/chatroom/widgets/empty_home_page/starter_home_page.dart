import 'dart:convert';
import 'dart:io';

import 'package:chat/chatroom/widgets/empty_home_page/get_started_button.dart';
import 'package:chat/chatroom/widgets/empty_home_page/install_screen.dart';
import 'package:chat/chatroom/widgets/empty_home_page/script_item.dart';
import 'package:chat/models/backend_connected.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/models/demo_controller.dart';
import 'package:chat/models/display_configs.dart';
import 'package:chat/services/env_installer.dart';
import 'package:chat/models/scripts.dart';
import 'package:chat/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:is_ios_app_on_mac/is_ios_app_on_mac.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class StarterHomePage extends StatefulWidget {
  const StarterHomePage({super.key});

  @override
  State<StarterHomePage> createState() => _StarterHomePageState();
}

class _StarterHomePageState extends State<StarterHomePage> {
  late ValueNotifier<User> userModel;
  late ValueNotifier<Scripts?> scriptsListenable;
  late ValueNotifier<Script?> selectedScript;
  late ValueNotifier<DisplayConfigData> displayConfigData;
  late ValueNotifier<Conversation?> currentSelectedConversation;
  late ValueNotifier<DemoController> demoController;
  late ValueNotifier<BackendService?> backendConnector;
  late ValueNotifier<double> opacityNotifier;
  late ValueNotifier<InstallerService> installerService;

  @override
  void initState() {
    super.initState();
    installerService =
        Provider.of<ValueNotifier<InstallerService>>(context, listen: false);
    currentSelectedConversation =
        Provider.of<ValueNotifier<Conversation?>>(context, listen: false);
    displayConfigData =
        Provider.of<ValueNotifier<DisplayConfigData>>(context, listen: false);
    demoController =
        Provider.of<ValueNotifier<DemoController>>(context, listen: false);
    userModel = Provider.of<ValueNotifier<User>>(context, listen: false);
    scriptsListenable =
        Provider.of<ValueNotifier<Scripts?>>(context, listen: false);
    selectedScript =
        Provider.of<ValueNotifier<Script?>>(context, listen: false);
    backendConnector =
        Provider.of<ValueNotifier<BackendService?>>(context, listen: false);
    opacityNotifier = ValueNotifier<double>(1.0);
    if (backendConnector.value?.connected == true) {
      opacityNotifier.value = 0.0;
    }
    backendConnector.addListener(_handleBackendConnectorChange);
  }

  @override
  void dispose() {
    backendConnector.removeListener(_handleBackendConnectorChange);
    super.dispose();
  }

  void _handleBackendConnectorChange() {
    if (backendConnector.value?.connected == true) {
      opacityNotifier.value = 0.0;
    }
  }

  InputDecoration inputDecoration = const InputDecoration(
    border: OutlineInputBorder(
      borderSide: BorderSide(),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 10),
    hintStyle: TextStyle(color: Colors.black38),
  );
  TextStyle style = const TextStyle(fontSize: 14);
  Future<bool> _isDesktopPlatform() async {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  String responseMessageDefault = "";
  String responseMessageCustom = "";
  bool showInstallerScreen = false;

  Future<void> pingEndpoint(bool isDefault) async {
    // TODO because this is only used on mobile devices
    // inherently the defaultEndpoint path is unnecessary and can
    // be removed
    String endpoint = isDefault
        ? displayConfigData.value.apiConfig.defaultEndpoint
        : displayConfigData.value.apiConfig.customEndpoint;
    if (endpoint.isEmpty) {
      setState(() {
        if (isDefault) {
          responseMessageDefault = "Error: Endpoint is incomplete";
        } else {
          responseMessageCustom = "Error: Endpoint is incomplete";
        }
      });
      return;
    }

    try {
      final response = await http.post(Uri.parse('$endpoint/test'));
      final body = jsonDecode(response.body);
      if (response.statusCode == 200 && body == "hello world") {
        setState(() {
          if (isDefault) {
            responseMessageDefault = "You are connected!";
          } else {
            responseMessageCustom = "You are connected!";
          }
        });
        Future.delayed(const Duration(milliseconds: 1200), () async {
          backendConnector.value!.connected = true;
          backendConnector.notifyListeners();
          installerService.value.backendConnected =
              await installerService.value.checkBackendConnected();
          installerService.notifyListeners();
        });
      } else {
        setState(() {
          if (isDefault) {
            responseMessageDefault = "Error: Invalid response";
          } else {
            responseMessageCustom = "Error: Invalid response";
          }
        });
      }
    } catch (e) {
      setState(() {
        if (isDefault) {
          responseMessageDefault = "Error: Unable to reach endpoint";
        } else {
          responseMessageCustom = "Error: Unable to reach endpoint";
        }
      });
    }
  }

  Future<void> onToposInstallationComplete() async {
    // set value of installer to installed
    bool backendConnected =
        await installerService.value.checkBackendConnected();
    installerService.value.backendConnected = backendConnected;
    installerService.value.backendInstalled = true;
    debugPrint("backendConnected :: $backendConnected");
    // try to turn on the server
    if (!backendConnected) {
      debugPrint("checking topos is installed ");
      bool isRunning =
          await installerService.value.checkToposCLIInstalled(autoTurnOn: true);
      installerService.value.backendConnected = isRunning;
    }
    installerService.notifyListeners();
    installerService.value.printEnvironment();

    // set state back to home
    Future.delayed(const Duration(milliseconds: 960), () {
      setState(() {
        showInstallerScreen = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<InstallerService>(
        valueListenable: installerService,
        builder: (context, installer, _) {
          return ValueListenableBuilder<BackendService?>(
            valueListenable: backendConnector,
            builder: (context, backend, _) {
              return ValueListenableBuilder<Scripts?>(
                valueListenable: scriptsListenable,
                builder: (context, scripts, _) {
                  if (scripts == null) {
                    return const CupertinoActivityIndicator();
                  }
                  return FutureBuilder(
                      future: IsIosAppOnMac().isiOSAppOnMac(),
                      builder: (context, isIosAppOnMac) {
                        return FutureBuilder(
                            future: _isDesktopPlatform(),
                            builder: (context, isDesktop) {
                              if (!isDesktop.hasData || !isIosAppOnMac.hasData)
                                return Container();
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (showInstallerScreen)
                                      InstallerScreen(
                                        installerService: installerService,
                                        displayConfigData: displayConfigData,
                                        onInstall: () async {
                                          // Handle the install button tap
                                          bool isInstalled =
                                              await installerService.value
                                                  .checkToposCLIInstalled();
                                          debugPrint(
                                              "\t[ topos backend installed :: $isInstalled ]");
                                          await installerService.value
                                              .runInstallScript(); // run installer
                                          // check if topos backend is now installed
                                          isInstalled = await installerService
                                              .value
                                              .checkToposCLIInstalled(
                                                  autoTurnOn: false);
                                          debugPrint(
                                              "\t[ topos backend installed :: $isInstalled ]");
                                          if (isInstalled) {
                                            debugPrint(
                                                "\t[ topos successfully installed ]");
                                            // completion commands
                                            onToposInstallationComplete();
                                          } else {
                                            debugPrint(
                                                "\t[ topos was not successfully installed ]");
                                          }
                                        },
                                        onUninstall: () {},
                                        onReturnHome: () {
                                          setState(() {
                                            showInstallerScreen = false;
                                          });
                                        },
                                      )
                                    else
                                      Column(
                                        children: [
                                          Text(
                                            "Demos",
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .color!
                                                    .withOpacity(.74)),
                                          ),
                                          Wrap(
                                            spacing:
                                                8.0, // space between items horizontally
                                            runSpacing:
                                                8.0, // space between items vertically
                                            children:
                                                scripts.demos.map((script) {
                                              return ScriptItem(
                                                script: script,
                                                onScriptSelectionTap: () {
                                                  setState(() {
                                                    selectedScript.value =
                                                        script;
                                                    selectedScript
                                                        .notifyListeners();
                                                    debugPrint(
                                                        "\t[ selected script :: ${script.name} ]");
                                                    displayConfigData
                                                        .value.demoMode = true;
                                                    displayConfigData
                                                        .notifyListeners();
                                                  });
                                                },
                                              );
                                            }).toList(),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ), // whitespace to center the demo options
                                          if (isDesktop.data! &&
                                              !installerService
                                                  .value.backendInstalled &&
                                              !installerService
                                                  .value.isConnecting.value)
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                GetStarted(
                                                  onTap: () {
                                                    setState(() {
                                                      showInstallerScreen =
                                                          true;
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                          // if platform is not desktop/linux/macos display url option
                                          if (!isDesktop.data! ||
                                              !installerService
                                                  .value.backendConnected)
                                            // isIosAppOnMac.data! ||
                                            if (installerService
                                                .value.isConnecting.value)
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Connecting...",
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge!
                                                            .color!
                                                            .withOpacity(.74)),
                                                  ),
                                                  const SizedBox(
                                                    width: 8,
                                                  ),
                                                  const CupertinoActivityIndicator(
                                                    radius: 8,
                                                  ),
                                                ],
                                              )
                                            else
                                              AnimatedOpacity(
                                                opacity: opacityNotifier.value,
                                                duration:
                                                    const Duration(seconds: 1),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      "API URL",
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge!
                                                                  .color!
                                                                  .withOpacity(
                                                                      .74)),
                                                    ),
                                                    SizedBox(
                                                      width: 200,
                                                      height: 38,
                                                      child: TextField(
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyLarge!
                                                                .color!
                                                                .withOpacity(
                                                                    .74)),
                                                        textAlign:
                                                            TextAlign.center,
                                                        decoration: inputDecoration
                                                            .copyWith(
                                                                enabledBorder:
                                                                    const OutlineInputBorder(
                                                                  borderSide:
                                                                      BorderSide(
                                                                    color: Color
                                                                        .fromARGB(
                                                                            255,
                                                                            201,
                                                                            201,
                                                                            201), // Default border color
                                                                  ),
                                                                ),
                                                                hintText:
                                                                    "Enter your endpoint"),
                                                        onSubmitted:
                                                            (value) async {
                                                          displayConfigData
                                                                  .value
                                                                  .apiConfig
                                                                  .customEndpoint =
                                                              value;
                                                          displayConfigData
                                                              .notifyListeners();
                                                          await pingEndpoint(
                                                              false);
                                                        },
                                                        onChanged:
                                                            (value) async {
                                                          displayConfigData
                                                                  .value
                                                                  .apiConfig
                                                                  .customEndpoint =
                                                              value;
                                                          displayConfigData
                                                              .notifyListeners();
                                                          await pingEndpoint(
                                                              false);
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(height: 3),
                                                    Text(
                                                      responseMessageCustom,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge!
                                                                  .color!
                                                                  .withOpacity(
                                                                      .74)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                        ],
                                      ),
                                  ],
                                ),
                              );
                            });
                      });
                },
              );
            },
          );
        });
  }
}
