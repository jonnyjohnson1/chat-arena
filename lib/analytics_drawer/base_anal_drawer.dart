import 'package:chat/analytics_drawer/graphs/custom_bar_chart.dart';
import 'package:chat/analytics_drawer/graphs/vertical_dialogue_chart.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/models/conversation_analytics.dart';
import 'package:chat/models/custom_file.dart';
import 'package:chat/models/display_configs.dart';
import 'package:chat/services/local_llm_interface.dart';
import 'package:chat/shared/emo27config.dart';
import 'package:chat/shared/images_list_widget.dart';
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
    if (currentSelectedConversation.value != null) {
      if (currentSelectedConversation.value!.gameType == GameType.p2pchat) {
        debugPrint(
            "\t[ Loading p2pchat analytics for conversation id :: ${currentSelectedConversation.value!.id} ]");
        // TODO load participant data from this game type
      }
    }
    Future.delayed(const Duration(milliseconds: 90), () {
      if (mounted) {
        if (!didInit) setState(() => didInit = true);
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
                                  valueListenable:
                                      conversation.convToImagesList,
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
                                          key:
                                              Key(imagesList.length.toString()),
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
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      12.0), // Rounded borders
                                            ),
                                            child: SizedBox(
                                              width: 290,
                                              child: VerticalDialogueChart(
                                                title: "Emotions",
                                                showTitle: true,
                                                botBarColor:
                                                    const Color.fromARGB(
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
                                              borderRadius:
                                                  BorderRadius.circular(
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
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      12.0), // Rounded borders
                                            ),
                                            child: SizedBox(
                                              width: 290,
                                              child: CustomBarChart(
                                                title: "Summoned",
                                                barColor: const Color.fromARGB(
                                                    255, 122, 11, 158),
                                                totalsData: convData
                                                    .entitySummonsTotals,
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
            ),
          );
  }
}
