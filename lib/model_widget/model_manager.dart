import 'package:flutter/material.dart';
import 'package:chat/model_widget/model_listview_card.dart';
import 'package:chat/models/llm.dart';
import 'package:chat/models/model_loaded_states.dart';
import 'package:chat/models/models.dart';
import 'package:chat/models/sys_resources.dart';
import 'package:chat/services/ios_platform_interface.dart';
import 'package:provider/provider.dart';

class ModelManagerPage extends StatefulWidget {
  int duration;
  ValueNotifier<List<ModelConfig>>? models;
  ValueNotifier<ModelLoadedState>? modelLoaded;
  ValueNotifier<LLM>? llm;
  ValueNotifier<MemoryConfig>? systemResources;
  ValueNotifier<Widget> homePage;
  bool isIphone;
  ModelManagerPage(
      {required this.duration,
      required this.models,
      required this.modelLoaded,
      required this.llm,
      required this.systemResources,
      this.isIphone = false,
      required this.homePage,
      super.key});

  @override
  State<ModelManagerPage> createState() => _ModelManagerPageState();
}

class _ModelManagerPageState extends State<ModelManagerPage> {
  TextEditingController newModelURLController = TextEditingController();

  bool didInit = false;

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: widget.duration),
        () => setState((() => didInit = true)));

    super.initState();
  }

  int? selectedModelIdx;

  @override
  Widget build(BuildContext context) {
    return !didInit
        ? Container()
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 3,
                ),
                if (widget.isIphone)
                  Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: ValueListenableBuilder(
                        valueListenable: widget.systemResources!,
                        builder: (ctx, mem, _) {
                          if (mem.totalMemory != null &&
                              mem.usedMemory != null) {
                            String usedMem = "0.0";
                            try {
                              usedMem = getFileSizeString(
                                  bytes: mem.usedMemory!.toInt(), decimals: 0);
                            } catch (e) {
                              print("Error getting fileSize String: $e");
                            }
                            String totMem = getFileSizeString(
                                bytes: mem.totalMemory!, decimals: 2);
                            String perc =
                                (mem.usedMemory! / mem.totalMemory! * 100)
                                    .toStringAsFixed(2);
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(("$usedMem ($perc%) "),
                                    style: const TextStyle(fontSize: 14)),
                                Text(("of $totMem "),
                                    style: const TextStyle(fontSize: 14)),
                              ],
                            );
                          }
                          return Container();
                        }),
                  ),
                const SizedBox(
                  height: 18,
                ),
                Expanded(
                  child: ValueListenableBuilder<List<ModelConfig>>(
                      valueListenable: widget.models!,
                      builder: (ctx, modelList, _) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Wrap(
                              spacing: 15,
                              runSpacing: 15,
                              children: [
                                for (int idx = 0; idx < modelList.length; idx++)
                                  ModelListViewCard(
                                      modelConfig: modelList[idx],
                                      isLoaded: widget.llm!.value.modelName ==
                                          modelList[idx].displayName,
                                      // selects the model to use for chat
                                      onTap: (modelConfig) async {
                                        print("Tapped");
                                      },
                                      onDownload: (modelConfig) async {},
                                      onStop: (modelConfig) async {},
                                      onClear: (modelConfig) async {}),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
                const SizedBox(
                  height: 5,
                ),
              ],
            ),
          );
  }
}

Future<String?> showAlertDialog(BuildContext context) {
  // set up the button
  Widget clearButton = TextButton(
    child: const Text("Clear"),
    onPressed: () {
      Navigator.of(context).pop("clear");
      // Navigator.pop(context, "clear");
    },
  );

  // Widget deleteButton = TextButton(
  //   child: Text(
  //     "Delete",
  //     style: TextStyle(color: Colors.red[700]),
  //   ),
  //   onPressed: () {
  //     Navigator.pop(context, "delete");
  //   },
  // );

  Widget cancelButton = TextButton(
    child: const Text("Cancel"),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0))),
    elevation: 4,
    content: SelectionArea(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540),
        child: const Text(
          'Delete model will delete all the files with model config, and delete the entry in list.\nClear model will keep the model config only, and keep the entry in list for future re-downloading.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    ),
    // content: Text("This is my message."),
    actions: [clearButton, cancelButton],
  );

  // show the dialog
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
