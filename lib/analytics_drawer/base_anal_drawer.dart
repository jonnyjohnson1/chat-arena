import 'package:chat/analytics_drawer/graphs/custom_bar_chart.dart';
import 'package:chat/analytics_drawer/graphs/vertical_dialogue_chart.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/models/conversation_analytics.dart';
import 'package:chat/models/custom_file.dart';
import 'package:chat/models/display_configs.dart';
import 'package:chat/services/local_llm_interface.dart';
import 'package:chat/shared/emo27config.dart';
import 'package:chat/shared/image_viewer.dart';
import 'package:chat/shared/images_list_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:load_switch/load_switch.dart';
import 'package:provider/provider.dart';

class BaseAnalyticsDrawer extends StatefulWidget {
  final onTap;
  const BaseAnalyticsDrawer({this.onTap, Key? key}) : super(key: key);

  @override
  State<BaseAnalyticsDrawer> createState() => _BaseAnalyticsDrawerState();
}

class _BaseAnalyticsDrawerState extends State<BaseAnalyticsDrawer> {
  bool didInit = false;

  late ValueNotifier<DisplayConfigData> displayConfigData;
  late ValueNotifier<Conversation?> currentSelectedConversation;

  bool showSidebarBaseAnalytics = true;
  bool showInMsgNER = true;
  bool calcInMsgNER = true;
  bool showModerationTags = true;
  bool calcModerationTags = true;
  bool calcImageGen = false;

  @override
  void initState() {
    super.initState();
    currentSelectedConversation =
        Provider.of<ValueNotifier<Conversation?>>(context, listen: false);

    // This delay loads the items in the drawer after the animation has popped out a bit
    // It saves some jank
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
                      offset: const Offset(0, 3), // changes position of shadow
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

  Widget _buildAnalysisRow(
      {required IconData icon,
      required String label1,
      required String label2,
      required bool value1,
      required bool value2,
      required Future<bool> Function() future1,
      required Future<bool> Function() future2,
      required bool notifier1,
      required bool notifier2}) {
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
                      offset: const Offset(0, 3), // changes position of shadow
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
                        return const Color.fromARGB(
                            255, 122, 11, 158); // Color when pressed
                      }
                      return value2
                          ? const Color.fromARGB(
                              255, 122, 11, 158) // Active color
                          : const Color.fromARGB(
                              255, 193, 193, 193); // Inactive color
                    },
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  elevation: MaterialStateProperty.all<double>(
                      5), // Elevation for shadow
                  shadowColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      return value2
                          ? const Color.fromARGB(
                              255, 222, 222, 222) // Active shadow color
                          : const Color.fromARGB(
                              255, 213, 213, 213); // Inactive shadow color
                    },
                  ),
                ),
                onPressed: () {
                  setState(() {
                    notifier2 = !value2; // Toggle value2
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

  @override
  Widget build(BuildContext context) {
    return !didInit
        ? Container()
        : Column(
            children: [
              Expanded(
                child: ValueListenableBuilder<Conversation?>(
                    valueListenable: currentSelectedConversation,
                    builder: (context, Conversation? conversation, _) {
                      if (conversation == null) return Container();
                      debugPrint(
                          "\t[ Loading analytics for conversation id :: ${conversation.id} ]");
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            ValueListenableBuilder<List<ImageFile>>(
                                valueListenable: conversation.convToImagesList,
                                builder:
                                    (context, List<ImageFile> imagesList, _) {
                                  debugPrint(
                                      "\t\t[ Building images list :: listlength ${imagesList.length} ]");
                                  return Column(
                                    children: [
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      ImagesListWidget(
                                        width: 150,
                                        height: 150,
                                        key: Key(imagesList.length.toString()),
                                        imagesList: imagesList,
                                        regenImage: () async {
                                          ImageFile? imageFile =
                                              await LocalLLMInterface(
                                                      displayConfigData
                                                          .value.apiConfig)
                                                  .getConvToImage(
                                                      currentSelectedConversation
                                                          .value!.id);
                                          if (imageFile != null) {
                                            // append to the conversation list of images conv_to_image parameter (the display will only show the last one)
                                            currentSelectedConversation
                                                .value!.convToImagesList.value
                                                .add(imageFile);
                                            currentSelectedConversation
                                                .value!.convToImagesList
                                                .notifyListeners();
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                }),
                            ValueListenableBuilder<ConversationData?>(
                                valueListenable:
                                    conversation.conversationAnalytics,
                                builder:
                                    (context, ConversationData? convData, _) {
                                  if (convData == null) return Container();
                                  return Column(
                                    children: [
                                      if (convData.emotionsTotals.isNotEmpty)
                                        Container(
                                          constraints: const BoxConstraints(
                                              minHeight: 180),
                                          margin: const EdgeInsets.all(
                                              8.0), // Add some margin to separate it from other widgets
                                          padding: const EdgeInsets.all(
                                              8.0), // Add some padding inside the container
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1,
                                                color: Colors.grey
                                                    .withOpacity(.5)),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface, // Background color for the container
                                            borderRadius: BorderRadius.circular(
                                                12.0), // Rounded borders
                                          ),
                                          child: SizedBox(
                                            width: 290,
                                            child: VerticalDialogueChart(
                                              title: "Emotions",
                                              showTitle: true,
                                              botBarColor: const Color.fromARGB(
                                                  255, 122, 11, 158),
                                              userBarColor:
                                                  const Color.fromARGB(
                                                      255, 122, 11, 158),
                                              data: convData.emotionsPerRole,
                                              labelConfig: emotionLabelConfig,
                                            ),
                                          ),
                                        ),
                                      const SizedBox(
                                        height: 1,
                                      ),
                                      if (convData
                                          .entityEvocationsTotals.isNotEmpty)
                                        Container(
                                          // constraints: BoxConstraints(minHeight: 180),
                                          margin: const EdgeInsets.all(
                                              8.0), // Add some margin to separate it from other widgets
                                          padding: const EdgeInsets.all(
                                              8.0), // Add some padding inside the container
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1,
                                                color: Colors.grey
                                                    .withOpacity(.5)),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface, // Background color for the container
                                            borderRadius: BorderRadius.circular(
                                                12.0), // Rounded borders
                                          ),
                                          child: SizedBox(
                                            width: 290,
                                            child: CustomBarChart(
                                              title: "Evocations",
                                              barColor: const Color.fromARGB(
                                                  255, 122, 11, 158),
                                              totalsData: convData
                                                  .entityEvocationsTotals,
                                            ),
                                          ),
                                        ),
                                      if (convData
                                          .entitySummonsTotals.isNotEmpty)
                                        Container(
                                          // constraints: BoxConstraints(minHeight: 180),
                                          margin: const EdgeInsets.all(
                                              8.0), // Add some margin to separate it from other widgets
                                          padding: const EdgeInsets.all(
                                              8.0), // Add some padding inside the container
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1,
                                                color: Colors.grey
                                                    .withOpacity(.5)),
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surface, // Background color for the container
                                            borderRadius: BorderRadius.circular(
                                                12.0), // Rounded borders
                                          ),
                                          child: SizedBox(
                                            width: 290,
                                            child: CustomBarChart(
                                              title: "Summoned",
                                              barColor: const Color.fromARGB(
                                                  255, 122, 11, 158),
                                              totalsData:
                                                  convData.entitySummonsTotals,
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                }),
                          ],
                        ),
                      );
                    }),
              ),
              _buildRow(
                icon: Icons.view_module_outlined,
                label: "Base Analytics",
                value: showSidebarBaseAnalytics,
                future: _toggleShowSidebarBaseAnalytics,
                notifier: displayConfigData.value.showSidebarBaseAnalytics,
              ),
            ],
          );
  }
}
