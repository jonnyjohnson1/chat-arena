import 'package:chat/analytics_drawer/eval_bar.dart';
import 'package:chat/analytics_drawer/mermaid_widget.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/models/display_configs.dart';
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

  @override
  void initState() {
    currentSelectedConversation =
        Provider.of<ValueNotifier<Conversation?>>(context, listen: false);

    Future.delayed(const Duration(milliseconds: 90),
        () => mounted ? setState((() => didInit = true)) : null);
    debugPrint(
        "\t[ Loading topic analytics for conversation id :: ${currentSelectedConversation.value!.id} ]");

    displayConfigData =
        Provider.of<ValueNotifier<DisplayConfigData>>(context, listen: false);

    super.initState();
  }

  Map<String, Map<String, int>> dummyData = {
    "jonny": {"present_score": 240},
    "ChatBot": {"present_score": 180},
    "tony": {"present_score": 195},
  };

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
              height: 5,
            ),
            TopicEvalBar(data: dummyData),
            const Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: 3,
                  ),
                  Expanded(
                    child: SingleChildScrollView(child: MermaidWidget()),
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
                            ? Color.fromARGB(255, 122, 11, 158)
                            : Color.fromARGB(255, 193, 193, 193),
                        borderRadius: BorderRadius.circular(30),
                        shape: BoxShape.rectangle,
                        boxShadow: [
                          BoxShadow(
                            color: value
                                ? const Color.fromARGB(255, 222, 222, 222)
                                : const Color.fromARGB(255, 213, 213, 213),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(
                                0, 3), // changes position of shadow
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
