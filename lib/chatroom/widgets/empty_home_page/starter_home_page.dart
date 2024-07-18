import 'dart:convert';
import 'dart:io';

import 'package:chat/chatroom/widgets/empty_home_page/script_item.dart';
import 'package:chat/models/backend_connected.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/models/demoController.dart';
import 'package:chat/models/display_configs.dart';
import 'package:chat/models/scripts.dart';
import 'package:chat/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

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

  @override
  void initState() {
    super.initState();
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
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(horizontal: 10),
    hintStyle: TextStyle(color: Colors.black38),
  );
  TextStyle style = const TextStyle(fontSize: 14);
  bool _isDesktopPlatform() {
    return Platform.isLinux || Platform.isMacOS || Platform.isWindows;
  }

  String responseMessageDefault = "";
  String responseMessageCustom = "";

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
        Future.delayed(const Duration(milliseconds: 1200), () {
          backendConnector.value!.connected = true;
          backendConnector.notifyListeners();
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<BackendService?>(
      valueListenable: backendConnector,
      builder: (context, backend, _) {
        return ValueListenableBuilder<Scripts?>(
          valueListenable: scriptsListenable,
          builder: (context, scripts, _) {
            if (scripts == null) return const CupertinoActivityIndicator();
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                        spacing: 8.0, // space between items horizontally
                        runSpacing: 8.0, // space between items vertically
                        children: scripts.demos.map((script) {
                          return ScriptItem(
                            script: script,
                            onScriptSelectionTap: () {
                              setState(() {
                                selectedScript.value = script;
                                selectedScript.notifyListeners();
                                debugPrint(
                                    "\t[ selected script :: ${script.name} ]");
                                displayConfigData.value.demoMode = true;
                                displayConfigData.notifyListeners();
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(
                        height: 20,
                      ), // whitespace to center the demo options
                      // if platform is not desktop/linux/macos display url option
                      if (!_isDesktopPlatform())
                        AnimatedOpacity(
                          opacity: opacityNotifier.value,
                          duration: const Duration(seconds: 1),
                          child: Column(
                            children: [
                              Text(
                                "API URL",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color!
                                        .withOpacity(.74)),
                              ),
                              SizedBox(
                                width: 200,
                                height: 38,
                                child: TextField(
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color!
                                          .withOpacity(.74)),
                                  textAlign: TextAlign.center,
                                  decoration: inputDecoration.copyWith(
                                      hintText: "Enter your endpoint"),
                                  onSubmitted: (value) {
                                    displayConfigData
                                        .value.apiConfig.customEndpoint = value;
                                    displayConfigData.notifyListeners();
                                    pingEndpoint(false);
                                  },
                                  onChanged: (value) {
                                    displayConfigData
                                        .value.apiConfig.customEndpoint = value;
                                    displayConfigData.notifyListeners();
                                    pingEndpoint(false);
                                  },
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                responseMessageCustom,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color!
                                        .withOpacity(.74)),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
