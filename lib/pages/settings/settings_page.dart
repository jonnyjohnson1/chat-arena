import 'dart:convert';

import 'package:chat/models/deployed_config.dart';
import 'package:chat/models/display_configs.dart';
import 'package:chat/models/function_services.dart';
import 'package:chat/models/llm.dart';
import 'package:chat/pages/provider_model_selector/provider_model_selector.dart';
import 'package:chat/pages/settings/widgets/api_settings_page.dart';
import 'package:chat/services/env_installer.dart';
import 'package:chat/services/tools.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:load_switch/load_switch.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late ValueNotifier<DisplayConfigData> displayConfigData;
  late TabController _tabController;
  bool didInit = false;
  bool showSidebarBaseAnalytics = true;
  bool showInMsgNER = true;
  bool calcInMsgNER = true;
  bool showModerationTags = true;
  bool calcModerationTags = true;
  bool calcImageGen = false;
  bool calcMsgMermaidChart = true;
  bool calcConvMermaidChart = true;
  bool demoMode = false;

  String responseMessageDefault = "";
  String responseMessageCustom = "";

  late ValueNotifier<InstallerService> installerService;
  late ValueNotifier<DeployedConfig> deployedConfig;

  TextEditingController openaiAPIKey = TextEditingController();
  TextEditingController groqAPIKey = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    installerService =
        Provider.of<ValueNotifier<InstallerService>>(context, listen: false);
    deployedConfig =
        Provider.of<ValueNotifier<DeployedConfig>>(context, listen: false);
    displayConfigData =
        Provider.of<ValueNotifier<DisplayConfigData>>(context, listen: false);

    Future.delayed(const Duration(milliseconds: 90), () {
      if (mounted) {
        setState(() => didInit = true);
      }
    });

    openaiAPIKey.text = displayConfigData.value.apiConfig.openAiApiKey ?? "";
    groqAPIKey.text = displayConfigData.value.apiConfig.groqApiKey ?? "";

    final config = displayConfigData.value;
    showSidebarBaseAnalytics = config.showSidebarBaseAnalytics;
    showInMsgNER = config.showInMessageNER;
    calcInMsgNER = config.calculateInMessageNER;
    showModerationTags = config.showModerationTags;
    calcModerationTags = config.calculateModerationTags;
    calcImageGen = config.calcImageGen;
    calcMsgMermaidChart = config.calcMsgMermaidChart;
    calcConvMermaidChart = config.calcConvMermaidChart;
    demoMode = config.demoMode;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Future<bool> _toggleSetting(String settingKey) async {
  //   await Future.delayed(Duration(milliseconds: futureWaitDuration));
  //   final newValue = !displayConfigData.value.getSetting(settingKey);
  //   displayConfigData.value.setSetting(settingKey, newValue);
  //   displayConfigData.notifyListeners();
  //   setState(() {});
  //   return newValue;
  // }

  Future<bool> _toggleRerunNEROnConversation() async {
    // TODO implement this process in the backend
    return false;
  }

  Future<bool> _toggleRerunModerationOnConversation() async {
    // TODO implement this process in the backend
    return false;
  }

  Future<bool> _toggleShowSidebarBaseAnalytics() async {
    await Future.delayed(Duration(milliseconds: futureWaitDuration));
    final newValue = !displayConfigData.value.showSidebarBaseAnalytics;
    displayConfigData.value.showSidebarBaseAnalytics = newValue;
    displayConfigData.notifyListeners();
    setState(() {
      showSidebarBaseAnalytics = newValue;
    });
    return newValue;
  }

  Future<bool> _toggleShowInMsgNER() async {
    await Future.delayed(Duration(milliseconds: futureWaitDuration));
    final newValue = !displayConfigData.value.showInMessageNER;
    displayConfigData.value.showInMessageNER = newValue;
    displayConfigData.notifyListeners();
    setState(() {
      showInMsgNER = newValue;
    });
    return newValue;
  }

  Future<bool> _toggleNERCalculations() async {
    await Future.delayed(Duration(milliseconds: futureWaitDuration));
    final newValue = !displayConfigData.value.calculateInMessageNER;
    displayConfigData.value.calculateInMessageNER = newValue;
    displayConfigData.notifyListeners();
    setState(() {
      calcInMsgNER = newValue;
    });
    return newValue;
  }

  Future<bool> _toggleShowModerationTags() async {
    await Future.delayed(Duration(milliseconds: futureWaitDuration));
    final newValue = !displayConfigData.value.showModerationTags;
    displayConfigData.value.showModerationTags = newValue;
    displayConfigData.notifyListeners();
    setState(() {
      showModerationTags = newValue;
    });
    return newValue;
  }

  Future<bool> _toggleModerationCalculations() async {
    await Future.delayed(Duration(milliseconds: futureWaitDuration));
    final newValue = !displayConfigData.value.calculateModerationTags;
    displayConfigData.value.calculateModerationTags = newValue;
    displayConfigData.notifyListeners();
    setState(() {
      calcModerationTags = newValue;
    });
    return newValue;
  }

  Future<bool> _togglecalcImageGen() async {
    await Future.delayed(Duration(milliseconds: futureWaitDuration));
    final newValue = !displayConfigData.value.calcImageGen;
    displayConfigData.value.calcImageGen = newValue;
    displayConfigData.notifyListeners();
    setState(() {
      calcImageGen = newValue;
    });
    return newValue;
  }

  Future<bool> _toggleCalcMsgMermaidChart() async {
    await Future.delayed(Duration(milliseconds: futureWaitDuration));
    final newValue = !displayConfigData.value.calcMsgMermaidChart;
    displayConfigData.value.calcMsgMermaidChart = newValue;
    displayConfigData.notifyListeners();
    setState(() {
      calcMsgMermaidChart = newValue;
    });
    return newValue;
  }

  Future<bool> _toggleCalcConvMermaidChart() async {
    await Future.delayed(Duration(milliseconds: futureWaitDuration));
    final newValue = !displayConfigData.value.calcConvMermaidChart;
    displayConfigData.value.calcConvMermaidChart = newValue;
    displayConfigData.notifyListeners();
    setState(() {
      calcConvMermaidChart = newValue;
    });
    return newValue;
  }

  Future<bool> _toggleDemoMode() async {
    await Future.delayed(Duration(milliseconds: futureWaitDuration));
    final newValue = !displayConfigData.value.demoMode;
    displayConfigData.value.demoMode = newValue;
    displayConfigData.notifyListeners();
    setState(() {
      demoMode = newValue;
    });
    return newValue;
  }

  Future<void> pingEndpoint(bool isDefault) async {
    String endpoint = isDefault
        ? displayConfigData.value.apiConfig.defaultBackendEndpoint
        : displayConfigData.value.apiConfig.customBackendEndpoint;
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
            responseMessageDefault = body;
          } else {
            responseMessageCustom = body;
          }
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

  final int futureWaitDuration = 230;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.memory_sharp), text: 'Topos'),
              Tab(icon: Icon(Icons.private_connectivity), text: 'Chat'),
              Tab(icon: Icon(Icons.display_settings), text: 'Configure'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAPISettingsPage(),
                _buildChatAPISettingsPage(),
                _buildDisplaySettingsPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFunctionServiceRows() {
    return displayConfigData.value.apiConfig.functions.functions.entries
        .map((entry) {
      final functionName = entry.key;
      final functionConfig = entry.value;
      // print("Provider: ${functionConfig.provider}");
      // print("Model: ${functionConfig.model}");
      if (!functionConfig.name.contains("mermaid") &
          !functionConfig.name.contains("image")) {
        return Column(
          children: [
            _buildBasicFunctionsRow(
                icon: Icons.play_lesson,
                key: functionName,
                label: Tools().capitalizeFirstLetters(functionConfig.name),
                value: functionConfig,
                showModelSelector: true),
            const Divider(),
          ],
        );
      } else {
        return Container();
      }
    }).toList();
  }

  Widget _buildBasicFunctionsRow(
      {required IconData icon,
      required String key,
      required String label,
      required FunctionConfig value,
      bool showModelSelector = false}) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 18.0),
          child: SizedBox(
            height: 45,
            child: Row(
              children: [
                Icon(icon),
                const SizedBox(width: 5),
                Text(label, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ),
        // Expanded(child: Container()),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (showModelSelector) ...[
                ProviderModelSelectorButton(
                  initialModel: value.model,
                  initialProvider: value.provider,
                  onModelChange: (LanguageModel model) {
                    // print("model: $model");
                    value.model = model;
                    displayConfigData.value.apiConfig.functions.functions[key] =
                        value;
                    displayConfigData.value.apiConfig.functions
                        .saveToSharedPrefs();
                    displayConfigData.notifyListeners();
                  },
                  onProviderChange: (String provider) {
                    // print("provider: $provider");
                    value.provider = provider;
                    displayConfigData.value.apiConfig.functions.functions[key] =
                        value;
                    displayConfigData.value.apiConfig.functions
                        .saveToSharedPrefs();
                    displayConfigData.notifyListeners();
                  },
                ),
                const SizedBox(
                  width: 8,
                )
              ],
              const SizedBox(width: 8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDisplaySettingsPage() {
    TextStyle headingStyle = const TextStyle(
        fontSize: 12,
        fontWeight:
            FontWeight.bold); //color: Color.fromARGB(255, 122, 11, 158),
    return ValueListenableBuilder<DisplayConfigData>(
        valueListenable: displayConfigData,
        builder: (context, snapshot, __) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        Text("Primary Services", style: headingStyle),
                      ],
                    ),
                  ),
                  // New dynamic rows based on the functions in FunctionServices
                  ..._buildFunctionServiceRows(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        Text("Classification Services", style: headingStyle),
                      ],
                    ),
                  ),
                  _buildRow(
                    icon: Icons.abc_outlined,
                    label: "In-Message (NER)",
                    value: showInMsgNER,
                    future: _toggleShowInMsgNER,
                    notifier: displayConfigData.value.showInMessageNER,
                    functionValue: null,
                  ),
                  _buildAnalysisRow(
                    icon: Icons.abc_outlined,
                    label1: "Calc:",
                    value1: calcInMsgNER,
                    future1: _toggleNERCalculations,
                    notifier1: displayConfigData.value.calculateInMessageNER,
                    label2: "Rerun:",
                    value2: false,
                    future2: _toggleRerunNEROnConversation,
                    notifier2: false,
                  ),
                  const Divider(),
                  _buildRow(
                    icon: Icons.block,
                    label: "Moderation Tags",
                    value: showModerationTags,
                    future: _toggleShowModerationTags,
                    notifier: displayConfigData.value.showModerationTags,
                  ),
                  _buildAnalysisRow(
                    icon: Icons.abc_outlined,
                    label1: "Calc:",
                    value1: calcModerationTags,
                    future1: _toggleModerationCalculations,
                    notifier1: displayConfigData.value.calculateModerationTags,
                    label2: "Rerun:",
                    value2: false,
                    future2: _toggleRerunNEROnConversation,
                    notifier2: false,
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Row(
                      children: [
                        Text("Advanced Services", style: headingStyle),
                      ],
                    ),
                  ),
                  _buildRow(
                      icon: Icons.schema_outlined,
                      label: "Mermaid (msg)",
                      value: calcMsgMermaidChart,
                      future: _toggleCalcMsgMermaidChart,
                      notifier: displayConfigData.value.calcMsgMermaidChart,
                      functionValue: displayConfigData.value.apiConfig.functions
                          .functions['generate_mermaid_chart'],
                      key: 'generate_mermaid_chart',
                      showModelSelector: true),
                  const Divider(),
                  _buildRow(
                      icon: Icons.schema_outlined,
                      label: "Mermaid (conv)",
                      value: calcConvMermaidChart,
                      future: _toggleCalcConvMermaidChart,
                      notifier: displayConfigData.value.calcConvMermaidChart,
                      showModelSelector: false),
                  const Divider(),
                  _buildRow(
                      icon: Icons.image,
                      label: "ImageGen",
                      value: calcImageGen,
                      future: _togglecalcImageGen,
                      notifier: displayConfigData.value.calcImageGen,
                      functionValue: displayConfigData.value.apiConfig.functions
                          .functions['chat/conv_to_image'],
                      key: 'chat/conv_to_image',
                      showModelSelector: true),
                  const Divider(),
                  _buildRow(
                    icon: Icons.play_lesson,
                    label: "Demo Mode",
                    value: demoMode,
                    future: _toggleDemoMode,
                    notifier: displayConfigData.value.demoMode,
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _buildChatAPISettingsPage() {
    InputDecoration inputDecoration = const InputDecoration(
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 10),
    );
    TextStyle style = const TextStyle(fontSize: 14);
    TextStyle headingStyle = const TextStyle(
        fontSize: 12,
        fontWeight:
            FontWeight.bold); //color: Color.fromARGB(255, 122, 11, 158),
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "Chat Server",
                  style: headingStyle,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Default API"),
                SizedBox(
                  width: 200,
                  height: 38,
                  child: TextField(
                    controller: TextEditingController(
                        text: kIsWeb && deployedConfig.value.cloudHosted
                            ? deployedConfig.value.defaultChatClient
                            : "http://127.0.0.1:13394"),
                    readOnly: true,
                    decoration: inputDecoration,
                    style: style,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () => pingEndpoint(true),
                  child: Text("Test"),
                ),
                const SizedBox(width: 10),
                Text(responseMessageDefault),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Custom API"),
                SizedBox(
                  width: 200,
                  height: 38,
                  child: TextField(
                    style: style,
                    decoration: inputDecoration.copyWith(
                        hintText: "Enter your endpoint"),
                    onSubmitted: (value) {
                      displayConfigData.value.apiConfig.customP2PChatEndpoint =
                          value.trim();
                      displayConfigData.notifyListeners();
                    },
                    onChanged: (value) {
                      displayConfigData.value.apiConfig.customP2PChatEndpoint =
                          value.trim();
                      displayConfigData.notifyListeners();
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () => pingEndpoint(false),
                  child: const Text("Test"),
                ),
                Text(responseMessageCustom),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildAPISettingsPage() {
    return APISettingsPage(
        installerService: installerService,
        displayConfigData: displayConfigData,
        deployedConfig: deployedConfig,
        openaiAPIKey: openaiAPIKey,
        groqAPIKey: groqAPIKey,
        pingEndpoint: (bool isDefault) => pingEndpoint(isDefault));
  }

  Widget _buildRow(
      {required IconData icon,
      required String label,
      required bool value,
      required Future<bool> Function() future,
      required bool notifier,
      // These 3 are required for the provider/model selection
      FunctionConfig? functionValue,
      String? key,
      bool showModelSelector = false}) {
    if (showModelSelector && (functionValue == null || key == null)) {
      throw Error();
    }
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 18.0),
          child: SizedBox(
            height: 45,
            child: Row(
              children: [
                Icon(icon),
                const SizedBox(width: 5),
                Text(label, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ),
        Expanded(child: Container()),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (showModelSelector) ...[
              ProviderModelSelectorButton(
                initialModel: functionValue!.model,
                initialProvider: functionValue.provider,
                onModelChange: (LanguageModel model) {
                  // print("model: $model");
                  functionValue.model = model;
                  displayConfigData.value.apiConfig.functions.functions[key!] =
                      functionValue;
                  displayConfigData.value.apiConfig.functions
                      .saveToSharedPrefs();
                  displayConfigData.notifyListeners();
                },
                onProviderChange: (String provider) {
                  // print("provider: $provider");
                  functionValue.provider = provider;
                  displayConfigData.value.apiConfig.functions.functions[key!] =
                      functionValue;
                  displayConfigData.value.apiConfig.functions
                      .saveToSharedPrefs();
                  displayConfigData.notifyListeners();
                },
              ),
              const SizedBox(
                width: 8,
              )
            ],
            Text(value ? "On" : "Off"),
            const SizedBox(width: 15),
            SizedBox(
              width: 42,
              child: LoadSwitch(
                height: 23,
                width: 38,
                value: value,
                future: future,
                style: SpinStyle.material,
                switchDecoration: (isActive, isPressed) => BoxDecoration(
                  color: isActive
                      ? const Color.fromARGB(255, 122, 11, 158)
                      : const Color.fromARGB(255, 193, 193, 193),
                  borderRadius: BorderRadius.circular(30),
                  shape: BoxShape.rectangle,
                  boxShadow: [
                    BoxShadow(
                      color: isActive
                          ? const Color.fromARGB(255, 222, 222, 222)
                          : const Color.fromARGB(255, 213, 213, 213),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                spinColor: (isActive) =>
                    const Color.fromARGB(255, 125, 73, 182),
                onChange: (v) {
                  setState(() {
                    notifier = v;
                  });
                },
                onTap: (v) {
                  // print('Tapping while value is $v');
                },
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalysisRow({
    required IconData icon,
    required String label1,
    required String label2,
    required bool value1,
    required bool value2,
    required Future<bool> Function() future1,
    required Future<bool> Function() future2,
    required bool notifier1,
    required bool notifier2,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(),
        Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 18.0),
              child: SizedBox(
                height: 45,
                child: Row(
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(label1),
            const SizedBox(width: 10),
            SizedBox(
              width: 36,
              child: LoadSwitch(
                height: 20,
                width: 28,
                value: value1,
                future: future1,
                style: SpinStyle.material,
                switchDecoration: (isActive, isPressed) => BoxDecoration(
                  color: isActive
                      ? const Color.fromARGB(255, 122, 11, 158)
                      : const Color.fromARGB(255, 193, 193, 193),
                  borderRadius: BorderRadius.circular(30),
                  shape: BoxShape.rectangle,
                  boxShadow: [
                    BoxShadow(
                      color: isActive
                          ? const Color.fromARGB(255, 222, 222, 222)
                          : const Color.fromARGB(255, 213, 213, 213),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                spinColor: (isActive) =>
                    const Color.fromARGB(255, 125, 73, 182),
                onChange: (v) {
                  setState(() {
                    notifier1 = v;
                  });
                },
                onTap: (v) {
                  // print('Tapping while value is $v');
                },
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label2,
              style: const TextStyle(
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 36,
              height: 20,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.pressed)) {
                        return const Color.fromARGB(255, 122, 11, 158);
                      }
                      return value2
                          ? const Color.fromARGB(255, 122, 11, 158)
                          : const Color.fromARGB(255, 193, 193, 193);
                    },
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  elevation: MaterialStateProperty.all<double>(5),
                  shadowColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      return value2
                          ? const Color.fromARGB(255, 222, 222, 222)
                          : const Color.fromARGB(255, 213, 213, 213);
                    },
                  ),
                ),
                onPressed: () {
                  setState(() {
                    notifier2 = !value2;
                  });
                },
                child: Text(
                  label2,
                  style: const TextStyle(
                    color: Colors.black,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ],
    );
  }
}
