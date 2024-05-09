import 'package:chat/models/games_config.dart';
import 'package:chat/services/json_loader.dart';
import 'package:flutter/material.dart';
import 'package:chat/model_widget/game_listview_card.dart';

class GamesListPage extends StatefulWidget {
  int duration;
  bool isIphone;
  Function selectedGame;
  GamesListPage(
      {required this.duration,
      required this.selectedGame,
      this.isIphone = false,
      super.key});

  @override
  State<GamesListPage> createState() => _GamesListPageState();
}

class _GamesListPageState extends State<GamesListPage> {
  TextEditingController newModelURLController = TextEditingController();
  List<GamesConfig> games = [];
  bool didInit = false;

  Future<void> get _loadModelListFromAppConfig async {
    final jsonResult = await loadJson();
    Future.delayed(Duration(milliseconds: widget.duration),
        () => setState((() => didInit = true)));
    List<dynamic> gamesList = jsonResult['games_list'];
    for (dynamic game in gamesList) {
      games.add(GamesConfig.fromJson(game));
    }
  }

  @override
  void initState() {
    _loadModelListFromAppConfig;

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
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      children: [
                        for (int idx = 0; idx < games.length; idx++)
                          InkWell(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            onTap: () {
                              widget.selectedGame(games[idx]);
                            },
                            child: GameListViewCard(
                              gamesConfig: games[idx],
                              isLoaded: true,
                              // selects the model to use for chat
                            ),
                          ),
                      ],
                    ),
                  ),
                )),
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
