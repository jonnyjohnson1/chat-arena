import 'dart:convert';

import 'package:chat/models/display_configs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

  bool showSidebarBaseAnalytics = true;
  bool showInMsgNER = true;
  bool calcInMsgNER = true;
  bool showModerationTags = true;
  bool calcModerationTags = true;
  bool calcImageGen = false;

  String responseMessageDefault = "";
  String responseMessageCustom = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    displayConfigData =
        Provider.of<ValueNotifier<DisplayConfigData>>(context, listen: false);

    final config = displayConfigData.value;
    showSidebarBaseAnalytics = config.showSidebarBaseAnalytics;
    showInMsgNER = config.showInMessageNER;
    calcInMsgNER = config.calculateInMessageNER;
    showModerationTags = config.showModerationTags;
    calcModerationTags = config.calculateModerationTags;
    calcImageGen = config.calcImageGen;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Future<bool> _toggleSetting(String settingKey) async {
  //   await Future.delayed(Duration(milliseconds: 900));
  //   final newValue = !displayConfigData.value.getSetting(settingKey);
  //   displayConfigData.value.setSetting(settingKey, newValue);
  //   displayConfigData.notifyListeners();
  //   setState(() {});
  //   return newValue;
  // }

  Future<bool> _toggleShowSidebarBaseAnalytics() async {
    await Future.delayed(Duration(milliseconds: 900));
    final newValue = !displayConfigData.value.showSidebarBaseAnalytics;
    displayConfigData.value.showSidebarBaseAnalytics = newValue;
    displayConfigData.notifyListeners();
    setState(() {
      showSidebarBaseAnalytics = newValue;
    });
    return newValue;
  }

  Future<bool> _toggleShowInMsgNER() async {
    await Future.delayed(Duration(milliseconds: 900));
    final newValue = !displayConfigData.value.showInMessageNER;
    displayConfigData.value.showInMessageNER = newValue;
    displayConfigData.notifyListeners();
    setState(() {
      showInMsgNER = newValue;
    });
    return newValue;
  }

  Future<bool> _toggleNERCalculations() async {
    await Future.delayed(Duration(milliseconds: 900));
    final newValue = !displayConfigData.value.calculateInMessageNER;
    displayConfigData.value.calculateInMessageNER = newValue;
    displayConfigData.notifyListeners();
    setState(() {
      calcInMsgNER = newValue;
    });
    return newValue;
  }

  Future<bool> _toggleShowModerationTags() async {
    await Future.delayed(Duration(milliseconds: 900));
    final newValue = !displayConfigData.value.showModerationTags;
    displayConfigData.value.showModerationTags = newValue;
    displayConfigData.notifyListeners();
    setState(() {
      showModerationTags = newValue;
    });
    return newValue;
  }

  Future<bool> _toggleModerationCalculations() async {
    await Future.delayed(Duration(milliseconds: 900));
    final newValue = !displayConfigData.value.calculateModerationTags;
    displayConfigData.value.calculateModerationTags = newValue;
    displayConfigData.notifyListeners();
    setState(() {
      calcModerationTags = newValue;
    });
    return newValue;
  }

  Future<bool> _togglecalcImageGen() async {
    await Future.delayed(Duration(milliseconds: 900));
    final newValue = !displayConfigData.value.calcImageGen;
    displayConfigData.value.calcImageGen = newValue;
    displayConfigData.notifyListeners();
    setState(() {
      calcImageGen = newValue;
    });
    return newValue;
  }

  Future<void> pingEndpoint(bool isDefault) async {
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
              Tab(icon: Icon(Icons.display_settings), text: 'Display Settings'),
              Tab(icon: Icon(Icons.memory_sharp), text: 'API Endpoints'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDisplaySettingsPage(),
                _buildAPISettingsPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplaySettingsPage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildRow(
            icon: Icons.abc_outlined,
            label: "In-Message (NER)",
            value: showInMsgNER,
            future: _toggleShowInMsgNER,
            notifier: displayConfigData.value.showInMessageNER,
          ),
          _buildAnalysisRow(
            icon: Icons.abc_outlined,
            label1: "Calc:",
            value1: calcInMsgNER,
            future1: _toggleNERCalculations,
            notifier1: displayConfigData.value.calculateInMessageNER,
            label2: "Rerun:",
            value2: false,
            future2: () async => false,
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
            future2: () async => false,
            notifier2: false,
          ),
          const Divider(),
          _buildRow(
            icon: Icons.image,
            label: "ImageGen",
            value: calcImageGen,
            future: _togglecalcImageGen,
            notifier: displayConfigData.value.calcImageGen,
          ),
        ],
      ),
    );
  }

  TextEditingController _customEndpointController = TextEditingController();
  Widget _buildAPISettingsPage() {
    InputDecoration inputDecoration = const InputDecoration(
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 10),
    );
    TextStyle style = const TextStyle(fontSize: 14);
    _customEndpointController.text =
        displayConfigData.value.apiConfig.customEndpoint;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Default API"),
                SizedBox(
                  width: 200,
                  height: 38,
                  child: TextField(
                    controller:
                        TextEditingController(text: "http://0.0.0.0:13341"),
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
            Divider(),
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
                    controller: _customEndpointController,
                    decoration: inputDecoration.copyWith(
                        hintText: "Enter your endpoint"),
                    onSubmitted: (value) {
                      displayConfigData.value.apiConfig.customEndpoint = value;
                      displayConfigData.notifyListeners();
                    },
                    onChanged: (value) {
                      displayConfigData.value.apiConfig.customEndpoint = value;
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
                  child: Text("Test"),
                ),
                const SizedBox(width: 10),
                Text(responseMessageCustom),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRow({
    required IconData icon,
    required String label,
    required bool value,
    required Future<bool> Function() future,
    required bool notifier,
  }) {
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
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
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
                      offset: const Offset(0, 3),
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
                  backgroundColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.pressed)) {
                        return const Color.fromARGB(255, 122, 11, 158);
                      }
                      return value2
                          ? const Color.fromARGB(255, 122, 11, 158)
                          : const Color.fromARGB(255, 193, 193, 193);
                    },
                  ),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  elevation: WidgetStateProperty.all<double>(5),
                  shadowColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
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
