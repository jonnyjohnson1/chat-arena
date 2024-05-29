import 'dart:convert';

import 'package:chat/models/display_configs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:load_switch/load_switch.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class SettingsDialog extends StatefulWidget {
  @override
  _SettingsDialogState createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool didInit = false;
  late ValueNotifier<DisplayConfigData> displayConfigData;
  bool showSidebarBaseAnalytics = true;
  bool showInMsgNER = true;
  bool calcInMsgNER = true;
  bool showModerationTags = true;
  bool calcModerationTags = true;
  bool calcImageGen = false;

  late TabController _tabController;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.delayed(const Duration(milliseconds: 90), () {
      if (mounted) {
        setState(() => didInit = true);
      }
    });

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

  Future<bool> _toggleRerunNEROnConversation() async {
    // TODO implement this process in the backend
    return false;
  }

  Future<bool> _toggleRerunModerationOnConversation() async {
    // TODO implement this process in the backend
    return false;
  }

  final int futureWaitDuration = 900;

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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          // Mobile layout
          return AlertDialog(
            content: SizedBox(
              width: constraints.maxWidth * 0.9,
              height: constraints.maxHeight * 0.8,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Settings',
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        _buildVerticalTab(
                            Icons.display_settings, 'Display Settings', 0),
                        _buildVerticalTab(
                            Icons.memory_sharp, 'Api Endpoints', 1),
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(18))),
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildDisplaySettingsPage(),
                                _buildAPISettingsPage()
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Desktop/iPad layout
          return AlertDialog(
            content: SizedBox(
              width: constraints.maxWidth * 0.8,
              height: constraints.maxHeight * 0.6,
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Settings',
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        SizedBox(
                          width: 250,
                          child: Column(
                            children: [
                              _buildVerticalTab(Icons.display_settings,
                                  'Display Settings', 0),
                              _buildVerticalTab(
                                  Icons.memory_sharp, 'Api Endpoints', 1),
                            ],
                          ),
                        ),
                        const VerticalDivider(),
                        Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(18))),
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildDisplaySettingsPage(),
                                _buildAPISettingsPage()
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildVerticalTab(IconData icon, String title, int index) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        bool isSelected = _tabController.index == index;
        return InkWell(
          onTap: () {
            _tabController.animateTo(index);
          },
          child: Container(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 23,
                  color: isSelected
                      ? const Color.fromARGB(255, 122, 11, 158)
                      : Colors.black,
                ),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isSelected
                            ? const Color.fromARGB(255, 122, 11, 158)
                            : Colors.black,
                      ),
                ),
                Expanded(
                  child: Container(),
                ),
                Container(
                  color: isSelected
                      ? const Color.fromARGB(255, 122, 11, 158)
                      : Colors.transparent,
                  width: 6,
                  height: 45,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget _buildDisplaySettingsPage() {
  //   return Center(child: Text('Display Settings Page'));
  // }

  // Widget _buildEmptyPage(String title) {
  //   return Center(child: Text(title));
  // }

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

  String responseMessageDefault = "";
  String responseMessageCustom = "";

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

  Widget _buildAPISettingsPage() {
    InputDecoration inputDecoration = const InputDecoration(
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 10),
    );
    TextStyle style = TextStyle(fontSize: 14);
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
                Text(responseMessageCustom),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPage(String pageTitle) {
    return Center(child: Text('$pageTitle content goes here.'));
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
