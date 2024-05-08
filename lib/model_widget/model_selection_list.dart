import 'package:chat/models/games_config.dart';
import 'package:flutter/material.dart';
import 'package:chat/model_widget/model_dropdown_listview_item.dart';
import 'package:chat/models/model_loaded_states.dart';

class ModelSelectionList extends StatefulWidget {
  int duration;
  ValueNotifier<List<GamesConfig>>? games;
  ValueNotifier<ModelLoadedState>? modelLoaded;
  bool isIphone;
  final onModelTap;
  ModelSelectionList(
      {required this.duration,
      required this.games,
      required this.modelLoaded,
      this.onModelTap,
      this.isIphone = false,
      super.key});

  @override
  State<ModelSelectionList> createState() => _ModelSelectionListState();
}

class _ModelSelectionListState extends State<ModelSelectionList> {
  var _controller = TextEditingController();

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder<List<GamesConfig>>(
            valueListenable: widget.games!,
            builder: (ctx, gamesList, _) {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: gamesList.length,
                  itemBuilder: (contextx, idx) {
                    GamesConfig game = gamesList[idx];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GameDropdownListViewItem(
                            gameConfig: game,
                            isLoaded: false,
                            // selects the model to use for chat
                            onTap: (modelConfig) async {
                              if (true) {
                                if (widget.modelLoaded!.value !=
                                    ModelLoadedState.isLoading) {}
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  });
            }),
      ],
    );
  }
}
