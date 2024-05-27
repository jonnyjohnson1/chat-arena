import 'package:chat/models/llm.dart';
import 'package:chat/services/static_queries.dart';
import 'package:flutter/material.dart';

class ModelSelector extends StatefulWidget {
  final LanguageModel initModel;
  final Function(LanguageModel)? onSelectedModelChange;

  const ModelSelector({required this.initModel, this.onSelectedModelChange});

  @override
  _ModelSelectorState createState() => _ModelSelectorState();
}

class _ModelSelectorState extends State<ModelSelector> {
  late LanguageModel selectedModel;

  @override
  void initState() {
    super.initState();
    selectedModel = widget.initModel;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getModels(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? Material(
                color: Colors.white,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  width: 135,
                  height: 28,
                  child: DropdownButton<LanguageModel>(
                    hint: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(
                        selectedModel.name ?? 'make a selection',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    alignment: Alignment.center,
                    underline: Container(),
                    isDense: true,
                    elevation: 4,
                    padding: EdgeInsets.zero,
                    itemHeight: null,
                    isExpanded: true,
                    items: snapshot.data
                        .map<DropdownMenuItem<LanguageModel>>((item) {
                      return DropdownMenuItem<LanguageModel>(
                        value: item,
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 170,
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(
                                item.name,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              )),
                              if (item.size != null)
                                Text(
                                  " (${sizeToGB(item.size!)})",
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 11),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (LanguageModel? newValue) {
                      setState(() {
                        selectedModel = newValue!;
                      });
                      if (widget.onSelectedModelChange != null) {
                        widget.onSelectedModelChange!(newValue!);
                      }
                    },
                  ),
                ),
              )
            : const Center(
                child: Text('Loading...'),
              );
      },
    );
  }
}
