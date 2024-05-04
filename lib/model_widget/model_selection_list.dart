import 'package:flutter/material.dart';
import 'package:chat/model_widget/model_dropdown_listview_item.dart';
import 'package:chat/models/llm.dart';
import 'package:chat/models/model_loaded_states.dart';
import 'package:chat/models/models.dart';
import 'package:provider/provider.dart';

class ModelSelectionList extends StatefulWidget {
  int duration;
  ValueNotifier<List<ModelConfig>>? models;
  ValueNotifier<ModelLoadedState>? modelLoaded;
  ValueNotifier<LLM>? llm;
  bool isIphone;
  final onModelTap;
  ModelSelectionList(
      {required this.duration,
      required this.models,
      required this.modelLoaded,
      required this.llm,
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
        ValueListenableBuilder<List<ModelConfig>>(
            valueListenable: widget.models!,
            builder: (ctx, modelList, _) {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: modelList.length,
                  itemBuilder: (contextx, idx) {
                    ModelConfig model = modelList[idx];
                    bool isLoaded =
                        widget.llm!.value.modelName == model.displayName;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ModelDropdownListViewItem(
                            modelConfig: model,
                            isLoaded: isLoaded,
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
