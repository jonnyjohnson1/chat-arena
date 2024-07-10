import 'dart:io';

import 'package:chat/analytics_drawer/eval_bar.dart';
import 'package:chat/analytics_drawer/mermaid_widget.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/models/display_configs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:load_switch/load_switch.dart';
import 'package:provider/provider.dart';

class GraphAnalyticsDrawer extends StatefulWidget {
  final onTap;
  GraphAnalyticsDrawer({this.onTap, super.key});

  @override
  State<GraphAnalyticsDrawer> createState() => _GraphAnalyticsDrawerState();
}

class _GraphAnalyticsDrawerState extends State<GraphAnalyticsDrawer> {
  bool didInit = false;
  late ValueNotifier<Conversation?> currentSelectedConversation;
  late ValueNotifier<DisplayConfigData> displayConfigData;

  late List<String> participants;

  @override
  void initState() {
    currentSelectedConversation =
        Provider.of<ValueNotifier<Conversation?>>(context, listen: false);

    Future.delayed(const Duration(milliseconds: 90),
        () => mounted ? setState((() => didInit = true)) : null);
    _getParticipants();
    if (currentSelectedConversation.value != null) {
      debugPrint(
          "\t[ Loading topic analytics for conversation id :: ${currentSelectedConversation.value!.id} ]");
    }
    displayConfigData =
        Provider.of<ValueNotifier<DisplayConfigData>>(context, listen: false);
    super.initState();
  }

  Map<String, Map<String, int>> dummyData = {
    "jonny": {"present_score": 240},
    "ChatBot": {"present_score": 180},
    "tony": {"present_score": 195},
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getParticipants();
  }

  void _getParticipants() {
    participants = dummyData.keys.toList();
  }

  bool value = false;

  Future<bool> _getFuture() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return !value;
  }

  @override
  Widget build(BuildContext context) {
    return !didInit
        ? Container()
        : Column(children: [
            const SizedBox(
              height: 12,
            ),
            TopicEvalBar(data: dummyData),
            Expanded(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 280,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 2.0),
                          child: InkWell(
                            onTap: () {},
                            child: const Text(
                              "All",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        if (participants.isNotEmpty) const Text("|"),
                        if (participants.isNotEmpty)
                          Expanded(
                            child: SizedBox(
                              height: 25,
                              child: ListView.builder(
                                itemCount: participants.length,
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemBuilder: (ctx, idx) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () {},
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6.0, vertical: 2.0),
                                          child: Text(participants[idx]),
                                        ),
                                      ),
                                      if (participants[idx] !=
                                          participants.last)
                                        const Text("|")
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                      margin: const EdgeInsets.symmetric(horizontal: 26),
                      height: 1,
                      color: Theme.of(context).colorScheme.primary),
                  Expanded(
                    child: SingleChildScrollView(
                        child: Builder(builder: (context) {
                      if (kIsWeb) {
                        return const MermaidWidget();
                      } else if (Platform.isMacOS || Platform.isWindows) {
                        return Container();
                      } else if (Platform.isIOS || Platform.isAndroid) {
                        return const MermaidWidget();
                      }
                      return Container();
                    })),
                  )
                ],
              ),
            ),
            Row(children: [
              InkWell(
                  onTap: null,
                  // () {
                  //   widget.onTap();
                  // },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 18.0),
                    child: SizedBox(
                      height: 45,
                      child: Row(
                        children: [
                          const Icon(Icons.view_module_outlined),
                          const SizedBox(
                            width: 5,
                          ),
                          Text("Topics Generator",
                              style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    ),
                  )),
              Expanded(child: Container()),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(value ? "On" : "Off"),
                  const SizedBox(
                    width: 15,
                  ),
                  SizedBox(
                    width: 42,
                    child: LoadSwitch(
                      height: 23,
                      width: 38,
                      value: value,
                      future: _getFuture,
                      style: SpinStyle.material,
                      switchDecoration: (value, isActive) => BoxDecoration(
                        color: value
                            ? const Color.fromARGB(255, 122, 11, 158)
                            : const Color.fromARGB(255, 193, 193, 193),
                        borderRadius: BorderRadius.circular(30),
                        shape: BoxShape.rectangle,
                        boxShadow: [
                          BoxShadow(
                            color: value
                                ? const Color.fromARGB(255, 222, 222, 222)
                                : const Color.fromARGB(255, 213, 213, 213),
                            spreadRadius: 3,
                            blurRadius: 5,
                            offset: const Offset(
                                0, 2), // changes position of shadow
                          ),
                        ],
                      ),
                      spinColor: (value) => value
                          ? const Color.fromARGB(255, 125, 73, 182)
                          : const Color.fromARGB(255, 125, 73, 182),
                      onChange: (v) {
                        value = v;
                        print('Value changed to $v');
                        setState(() {});
                      },
                      onTap: (v) {
                        print('Tapping while value is $v');
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  )
                ],
              )
            ])
          ]);
  }
}
