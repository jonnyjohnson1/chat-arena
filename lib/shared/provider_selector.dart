import 'package:chat/models/display_configs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProviderSelector extends StatefulWidget {
  final String initProvider;
  final Function(String)? onProviderChange;

  const ProviderSelector({required this.initProvider, this.onProviderChange});

  @override
  _ProviderSelectorState createState() => _ProviderSelectorState();
}

class _ProviderSelectorState extends State<ProviderSelector> {
  late String selectedProvider;
  late ValueNotifier<DisplayConfigData> displayConfigData;

  @override
  void initState() {
    super.initState();
    displayConfigData =
        Provider.of<ValueNotifier<DisplayConfigData>>(context, listen: false);
    selectedProvider = widget.initProvider;
  }

  Future<Map<String, Map<String, String>>> getProviders(
      APIConfig apiConfig) async {
    // determine which have been set up with the api_config
    Map<String, Map<String, String>> provider = {
      "openai": {"status": ""},
      "ollama": {"status": ""},
      "groq": {"status": ""},
    };
    if (apiConfig.openAiApiKey.isEmpty) {
      provider['openai']!['status'] = "not_set_up";
    } else {
      provider['openai']!['status'] =
          apiConfig.openAiKeyWorks ? "connected" : "key_error";
    }
    if (apiConfig.groqApiKey.isEmpty) {
      provider['groq']!['status'] = "not_set_up";
    } else {
      provider['groq']!['status'] =
          apiConfig.groqKeyWorks ? "connected" : "key_error";
    }
    return provider;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DisplayConfigData>(
        valueListenable: displayConfigData,
        builder: (context, snapshot, _) {
          return FutureBuilder(
            future: getProviders(displayConfigData.value.apiConfig),
            builder: (BuildContext context,
                AsyncSnapshot<Map<String, Map<String, String>>> snapshot) {
              if (!snapshot.hasData) return Container();
              return snapshot.hasData
                  ? Material(
                      color: const Color.fromARGB(0, 255, 255, 255),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(0, 255, 255, 255),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        width: 85,
                        height: 28,
                        child: DropdownButton<String>(
                          hint: Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              selectedProvider,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          alignment: Alignment.center,
                          underline: Container(),
                          isDense: true,
                          elevation: 4,
                          padding: EdgeInsets.zero,
                          itemHeight: null,
                          isExpanded: true,
                          items: snapshot.data!.entries.expand((outerEntry) {
                            // 'outerEntry.key' is the key of the outer Map (type String)
                            // 'outerEntry.value' is the inner Map<String, String>
                            return outerEntry.value.keys.map((innerKey) {
                              String status = outerEntry.value[innerKey] ?? "";
                              return DropdownMenuItem<String>(
                                value: outerEntry
                                    .key, // Use the inner key or value depending on what you want as the selection
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  width: 170,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          outerEntry
                                              .key, // Display the inner key or value depending on your UI requirement
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: status == "not_set_up" ||
                                                      status == "key_error"
                                                  ? Colors.grey
                                                  : Colors.black,
                                              decoration: status ==
                                                          "not_set_up" ||
                                                      status == "key_error"
                                                  ? TextDecoration.lineThrough
                                                  : TextDecoration.none),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedProvider = newValue!;
                            });
                            if (widget.onProviderChange != null) {
                              widget.onProviderChange!(newValue!);
                            }
                            print("CHANGED: $selectedProvider");
                          },
                        ),
                      ),
                    )
                  : const Center(
                      child: Text('Loading...'),
                    );
            },
          );
        });
  }
}
