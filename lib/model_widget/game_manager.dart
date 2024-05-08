import 'package:chat/models/games_config.dart';
import 'package:flutter/material.dart';
import 'package:chat/model_widget/game_listview_card.dart';
import 'package:chat/models/llm.dart';
import 'package:chat/models/model_loaded_states.dart';
import 'package:chat/models/sys_resources.dart';

class GameManagerPage extends StatefulWidget {
  int duration;
  ValueNotifier<List<GamesConfig>>? games;
  ValueNotifier<ModelLoadedState>? modelLoaded;
  ValueNotifier<MemoryConfig>? systemResources;
  ValueNotifier<Widget> homePage;
  bool isIphone;
  GameManagerPage(
      {required this.duration,
      required this.games,
      required this.modelLoaded,
      required this.systemResources,
      this.isIphone = false,
      required this.homePage,
      super.key});

  @override
  State<GameManagerPage> createState() => _GameManagerPageState();
}

class _GameManagerPageState extends State<GameManagerPage> {
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
                const SizedBox(
                  height: 18,
                ),
                Expanded(
                  child: ValueListenableBuilder<List<GamesConfig>>(
                      valueListenable: widget.games!,
                      builder: (ctx, gamesList, _) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Wrap(
                              spacing: 15,
                              runSpacing: 15,
                              children: [
                                for (int idx = 0; idx < gamesList.length; idx++)
                                  GameListViewCard(
                                      gamesConfig: gamesList[idx],
                                      isLoaded: true,
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
                // expand the column to fill the space
                Row(),
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
