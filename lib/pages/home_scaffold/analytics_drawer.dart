import 'package:chat/analytics_drawer/base_anal_drawer.dart';
import 'package:chat/analytics_drawer/conversation_steering_drawer.dart';
import 'package:chat/analytics_drawer/graph_analytics_drawer.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/models/display_configs.dart';
import 'package:chat/models/games_config.dart';
import 'package:chat/models/scripts.dart';
import 'package:chat/models/sys_resources.dart';
import 'package:chat/pages/home_scaffold/widgets/scripts_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:load_switch/load_switch.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class AnalyticsViewDrawer extends StatefulWidget {
  final bool isMobile;
  final ValueNotifier<Widget> body;
  final ValueNotifier<String> title;
  final ValueNotifier<List<Conversation>> conversations;
  final Function? onSettingsDrawerTap;

  const AnalyticsViewDrawer({
    this.isMobile = false,
    required this.body,
    required this.title,
    required this.conversations,
    this.onSettingsDrawerTap,
    Key? key
  }) : super(key: key);

  @override
  State<AnalyticsViewDrawer> createState() => _AnalyticsViewDrawerState();
}

class _AnalyticsViewDrawerState extends State<AnalyticsViewDrawer> with TickerProviderStateMixin {
  bool didInit = false;

  late ValueNotifier<DisplayConfigData> displayConfigData;
  late ValueNotifier<Conversation?> currentSelectedConversation;

  bool showSidebarBaseAnalytics = true;
  bool showInMsgNER = true;
  bool calcInMsgNER = true;
  bool showModerationTags = true;
  bool calcModerationTags = true;
  bool calcImageGen = false;

  late TabController _tabController;
  int pathIndex = 0;

  List<Widget> _tabs = [];
  List<Widget> _tabViews = [];

  @override
  void initState() {
    super.initState();
    currentSelectedConversation = Provider.of<ValueNotifier<Conversation?>>(context, listen: false);

    // This delay loads the items in the drawer after the animation has popped out a bit
    // It saves some jank
    if (currentSelectedConversation.value != null) {
      if (currentSelectedConversation.value!.gameType == GameType.p2pchat) {
        debugPrint("\t[ Loading p2pchat analytics for conversation id :: ${currentSelectedConversation.value!.id} ]");
        // TODO load participant data from this game type
      }
    }
    Future.delayed(const Duration(milliseconds: 90), () {
      if (mounted) {
        if (!didInit) setState(() => didInit = true);
      }
    });

    displayConfigData = Provider.of<ValueNotifier<DisplayConfigData>>(context, listen: false);

    final config = displayConfigData.value;
    showSidebarBaseAnalytics = config.showSidebarBaseAnalytics;
    showInMsgNER = config.showInMessageNER;
    calcInMsgNER = config.calculateInMessageNER;
    showModerationTags = config.showModerationTags;
    calcModerationTags = config.calculateModerationTags;
    calcImageGen = config.calcImageGen;

    _updateTabs();
    currentSelectedConversation.addListener(_updateTabs);
  }

  @override
  void dispose() {
    _tabController.dispose();
    currentSelectedConversation.removeListener(_updateTabs);
    super.dispose();
  }

  void _updateTabs() {
    setState(() {
      _tabs = [
        Tab(text: 'Base'),
        Tab(text: 'Steering'),
        Tab(text: 'Graph'),
      ];
      _tabViews = [
        BaseAnalyticsDrawer(onTap: widget.onSettingsDrawerTap),
        ConvSteeringDrawer(onTap: widget.onSettingsDrawerTap),
        GraphAnalyticsDrawer(onTap: widget.onSettingsDrawerTap),
      ];

      if (currentSelectedConversation.value?.gameType == GameType.debate) {
        _tabs.add(Tab(text: 'WEPCC'));
        _tabViews.add(WEPCCAnalysisComponent(conversation: currentSelectedConversation.value!));
      }

      _tabController = TabController(length: _tabs.length, vsync: this);
      _tabController.addListener(() {
        setState(() {
          pathIndex = _tabController.index;
        });
      });
    });
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
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(0, 2), // changes position of shadow
                    ),
                  ],
                ),
                spinColor: (isActive) => const Color.fromARGB(255, 125, 73, 182),
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

  @override
  Widget build(BuildContext context) {
    return !didInit
        ? Container()
        : GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              unselectedLabelStyle: TextStyle(fontSize: 14),
              tabs: _tabs,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabViews,
            ),
          ),
          _buildRow(
            icon: Icons.view_module_outlined,
            label: "Base Analytics",
            value: showSidebarBaseAnalytics,
            future: _toggleShowSidebarBaseAnalytics,
            notifier: displayConfigData.value.showSidebarBaseAnalytics,
          ),
        ],
      ),
    );
  }
}

class WEPCCAnalysisComponent extends StatelessWidget {
  final Conversation conversation;

  const WEPCCAnalysisComponent({Key? key, required this.conversation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (conversation.gameType != GameType.debate || conversation.debateData.wepccResults.isEmpty) {
      return Center(child: Text('No WEPCC data available'));
    }

    return ListView.builder(
      itemCount: conversation.debateData.wepccResults.length,
      itemBuilder: (context, index) {
        final clusterId = conversation.debateData.wepccResults.keys.elementAt(index);
        final wepccResult = conversation.debateData.wepccResults[clusterId];
        return WEPCCClusterCard(clusterId: clusterId, wepccResult: wepccResult);
      },
    );
  }
}



class WEPCCClusterCard extends StatelessWidget {
  final String clusterId;
  final Map<String, dynamic> wepccResult;

  const WEPCCClusterCard({Key? key, required this.clusterId, required this.wepccResult}) : super(key: key);

  dynamic _safeGetValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is String) {
      try {
        return jsonDecode(value);
      } catch (e) {
        return value;
      }
    }
    return value;
  }

  String _getContent(dynamic value) {
    value = _safeGetValue(value);
    if (value is Map) {
        value = value['content'];
    }

    return value.toString();
  }

  String _getPJContent(dynamic value, String role) {
    value = _safeGetValue(value);
    if (value is Map) {
      if (value.containsKey('role')) {
        if (value['role'] == 'persuasiveness') {
          value = _safeGetValue(value['content']); // Decode again for nested structures
        }
      }

      // Handle nested 'persuasiveness_justification' structure
      if (role == 'persuasiveness') {
        return value['persuasiveness_score'].toString();
      } else if (role == 'justification') {
        return value['justification'].toString();
      }
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building WEPCCClusterCard for cluster: $clusterId');
    debugPrint('WEPCC Result: ${jsonEncode(wepccResult)}');

    return Card(
      margin: EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Text('Cluster $clusterId', style: Theme.of(context).textTheme.titleMedium),
        children: [
          WEPCCElement(title: 'Warrant', content: _getContent(wepccResult['warrant'])),
          WEPCCElement(title: 'Evidence', content: _getContent(wepccResult['evidence'])),
          WEPCCElement(
            title: 'Persuasiveness',
            content: _getPJContent(wepccResult['persuasiveness_justification'], 'persuasiveness'),
          ),
          WEPCCElement(
            title: 'Justification',
            content: _getPJContent(wepccResult['persuasiveness_justification'], 'justification'),
          ),
          WEPCCElement(title: 'Claim', content: _getContent(wepccResult['claim'])),
          WEPCCElement(title: 'Counterclaim', content: _getContent(wepccResult['counterclaim'])),
        ],
      ),
    );
  }
}

class WEPCCElement extends StatelessWidget {
  final String title;
  final String content;

  const WEPCCElement({Key? key, required this.title, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(content),
          ),
        ],
      ),
    );
  }
}