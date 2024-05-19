import 'package:flutter/material.dart';
import 'package:load_switch/load_switch.dart';

class BaseAnalyticsDrawer extends StatefulWidget {
  final onTap;
  BaseAnalyticsDrawer({this.onTap, super.key});

  @override
  State<BaseAnalyticsDrawer> createState() => _BaseAnalyticsDrawerState();
}

class _BaseAnalyticsDrawerState extends State<BaseAnalyticsDrawer> {
  bool didInit = false;

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 90),
        () => mounted ? setState((() => didInit = true)) : null);

    super.initState();
  }

  bool value = true;
  bool showInMsgNER = true;
  bool showModerationTags = true;

  Future<bool> _getFuture() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return !value;
  }

  Future<bool> _changeModeration() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return !showModerationTags;
  }

  Future<bool> _changeMsgNER() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return !showInMsgNER;
  }

  @override
  Widget build(BuildContext context) {
    return !didInit
        ? Container()
        : Column(children: [
            const SizedBox(
              height: 3,
            ),
            Row(
              children: [
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
                            const Icon(Icons.abc_outlined),
                            const SizedBox(
                              width: 5,
                            ),
                            Text("In-Message (NER)",
                                style: Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
                      ),
                    )),
                Expanded(
                  child: Container(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(showInMsgNER ? "On" : "Off"),
                    const SizedBox(
                      width: 15,
                    ),
                    SizedBox(
                      width: 42,
                      child: LoadSwitch(
                        height: 23,
                        width: 38,
                        value: showInMsgNER,
                        future: _changeMsgNER,
                        style: SpinStyle.material,
                        switchDecoration: (showInMsgNER, isActive) =>
                            BoxDecoration(
                          color: showInMsgNER
                              ? Color.fromARGB(255, 122, 11, 158)
                              : Color.fromARGB(255, 193, 193, 193),
                          borderRadius: BorderRadius.circular(30),
                          shape: BoxShape.rectangle,
                          boxShadow: [
                            BoxShadow(
                              color: showInMsgNER
                                  ? const Color.fromARGB(255, 222, 222, 222)
                                  : const Color.fromARGB(255, 213, 213, 213),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        spinColor: (showInMsgNER) => showInMsgNER
                            ? const Color.fromARGB(255, 125, 73, 182)
                            : const Color.fromARGB(255, 125, 73, 182),
                        onChange: (v) {
                          showInMsgNER = v;
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
                ),
              ],
            ),
            Row(
              children: [
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
                            const Icon(
                              Icons.block,
                              color: Colors.red,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text("Moderation Tags",
                                style: Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
                      ),
                    )),
                Expanded(
                  child: Container(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(showModerationTags ? "On" : "Off"),
                    const SizedBox(
                      width: 15,
                    ),
                    SizedBox(
                      width: 42,
                      child: LoadSwitch(
                        height: 23,
                        width: 38,
                        value: showModerationTags,
                        future: _changeModeration,
                        style: SpinStyle.material,
                        switchDecoration: (showModerationTags, isActive) =>
                            BoxDecoration(
                          color: showModerationTags
                              ? Color.fromARGB(255, 122, 11, 158)
                              : Color.fromARGB(255, 193, 193, 193),
                          borderRadius: BorderRadius.circular(30),
                          shape: BoxShape.rectangle,
                          boxShadow: [
                            BoxShadow(
                              color: showModerationTags
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
                          showModerationTags = v;
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
                ),
              ],
            ),
            Row(
              children: [
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
                            Text("Base Analytics",
                                style: Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
                      ),
                    )),
                Expanded(
                  child: Container(),
                ),
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
                ),
              ],
            )
          ]);
  }
}
