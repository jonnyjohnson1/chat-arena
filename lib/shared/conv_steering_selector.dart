import 'package:chat/models/suggestion_model.dart';
import 'package:chat/theming/theming_config.dart';
import 'package:flutter/material.dart';

class ConversationSteeringSuggestor extends StatefulWidget {
  final Suggestion initModel;
  final List<Suggestion> list;
  final Function(Suggestion)? onSelectedModelChange;

  const ConversationSteeringSuggestor(
      {super.key,
      required this.initModel,
      required this.list,
      this.onSelectedModelChange});

  @override
  _ConversationSteeringSuggestorState createState() =>
      _ConversationSteeringSuggestorState();
}

class _ConversationSteeringSuggestorState
    extends State<ConversationSteeringSuggestor> {
  late Suggestion selectedModel;

  @override
  void initState() {
    super.initState();
    selectedModel = widget.initModel;
    debugPrint(
        "\t\t[ Loading conv steering :: ConversationSteeringSuggestions initState ${widget.key.toString()}]");
  }

  @override
  Widget build(BuildContext context) {
    return widget.list.isNotEmpty
        ? Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 0.0),
                  child: SizedBox(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: Text(
                              selectedModel.suggestion,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w400),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(30)),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 600),
                                    child:
                                        const Text("What this statement does")),
                                content: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 600),
                                  child: Text(selectedModel.purpose),
                                ),
                                actions: [
                                  InkWell(
                                    child: const Text("OK"),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Icon(
                            Icons.info_outline,
                            color: informationColor,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                width: 288,
                height: 55,
                child: DropdownButton<Suggestion>(
                  hint: Container(
                    height: 69,
                    width: 42,
                    color: Colors.transparent,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  alignment: Alignment.center,
                  underline: Container(),
                  icon: Container(),
                  isDense: true,
                  elevation: 4,
                  padding: EdgeInsets.zero,
                  itemHeight: 74,
                  isExpanded: true,
                  items: widget.list.map<DropdownMenuItem<Suggestion>>((item) {
                    return DropdownMenuItem<Suggestion>(
                      value: item,
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: SizedBox(
                          // width: 170,
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: Text(
                                    item.suggestion,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                  ),
                                ),
                              ),
                              InkWell(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(30)),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                              maxWidth: 600),
                                          child: const Text(
                                              "What this statement does")),
                                      content: ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(maxWidth: 600),
                                        child: Text(item.purpose),
                                      ),
                                      actions: [
                                        InkWell(
                                          child: const Text("OK"),
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: Icon(Icons.info_outline,
                                    color: informationColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (Suggestion? newValue) {
                    setState(() {
                      selectedModel = newValue!;
                    });
                    if (widget.onSelectedModelChange != null) {
                      widget.onSelectedModelChange!(newValue!);
                    }
                  },
                ),
              ),
            ],
          )
        : const Center(
            child: Text('Loading...'),
          );
  }
}
