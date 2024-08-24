import 'package:chat/models/display_configs.dart';
import 'package:chat/models/llm.dart';
import 'package:chat/services/static_queries.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ModelSelector extends StatefulWidget {
  final LanguageModel initModel;
  final String? provider;
  final Function(LanguageModel)? onSelectedModelChange;

  const ModelSelector(
      {super.key,
      required this.initModel,
      this.provider,
      this.onSelectedModelChange});

  @override
  _ModelSelectorState createState() => _ModelSelectorState();
}

class _ModelSelectorState extends State<ModelSelector> {
  late LanguageModel selectedModel;
  late ValueNotifier<DisplayConfigData> displayConfigData;
  late String provider;

  @override
  void initState() {
    super.initState();
    provider = widget.provider ?? "ollama";
    displayConfigData =
        Provider.of<ValueNotifier<DisplayConfigData>>(context, listen: false);
    selectedModel = widget.initModel;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getModels(displayConfigData.value.apiConfig, provider),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? Material(
                color: const Color.fromARGB(0, 255, 255, 255),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(0, 255, 255, 255),
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
            : Center(
                child: Container(),
              );
      },
    );
  }
}
