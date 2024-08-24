import 'package:chat/services/platform_types.dart';
import 'package:chat/shared/backend_connected_service_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class APISettingsPage extends StatefulWidget {
  final ValueNotifier installerService;
  final ValueNotifier displayConfigData;
  final ValueNotifier deployedConfig;
  final TextEditingController openaiAPIKey;
  final TextEditingController groqAPIKey;
  final Function pingEndpoint;

  const APISettingsPage(
      {Key? key,
      required this.installerService,
      required this.displayConfigData,
      required this.openaiAPIKey,
      required this.groqAPIKey,
      required this.pingEndpoint,
      required this.deployedConfig})
      : super(key: key);

  @override
  _APISettingsPageState createState() => _APISettingsPageState();
}

class _APISettingsPageState extends State<APISettingsPage> {
  String responseMessageDefault = "";
  String responseMessageCustom = "";

  @override
  Widget build(BuildContext context) {
    debugPrint("\t[ building api settings page ]");
    InputDecoration inputDecoration = const InputDecoration(
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 10),
    );
    TextStyle style = const TextStyle(fontSize: 14);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  "Topos Backend",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                ValueListenableBuilder(
                    valueListenable: widget.installerService,
                    builder: (context, installService, _) {
                      return FutureBuilder(
                          future: isDesktopPlatform(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return Container(height: 22);
                            return ServiceToggle(
                                showLabel: false,
                                isConnected: installService.backendConnected,
                                // Only a desktop app with a local connection can
                                // attempt connect/disconnect
                                onTap: snapshot.data! &&
                                        widget.displayConfigData.value.apiConfig
                                            .isLocalhost()
                                    ? (isConnected) async {
                                        if (isConnected) {
                                          print("connect!");
                                          // connect
                                          var result = await widget
                                              .installerService.value
                                              .turnToposOn(widget
                                                  .displayConfigData
                                                  .value
                                                  .apiConfig
                                                  .getDefaultLLMBackend());
                                          print(
                                              'Topos is running at ${result['url']}');
                                          bool connected = result['isRunning'];
                                          widget.installerService.value
                                              .backendConnected = connected;
                                          widget.installerService
                                              .notifyListeners();
                                        } else {
                                          print("disconnect!");
                                          // // disconnect
                                          widget.installerService.value
                                              .stopToposService(widget
                                                  .displayConfigData
                                                  .value
                                                  .apiConfig
                                                  .getDefaultLLMBackend())
                                              .then(
                                            (disconnected) {
                                              if (disconnected) {
                                                widget.installerService.value
                                                    .backendConnected = false;
                                                widget.installerService
                                                    .notifyListeners();
                                              }
                                            },
                                          );
                                        }
                                      }
                                    : null);
                          });
                    }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Default API"),
                SizedBox(
                  width: 200,
                  height: 38,
                  child: TextField(
                    controller: TextEditingController(
                        text: kIsWeb && widget.deployedConfig.value.cloudHosted
                            ? widget.displayConfigData.value.apiConfig
                                .defaultBackendEndpoint
                            : "http://0.0.0.0:13341"),
                    readOnly: true,
                    decoration: inputDecoration,
                    style: style,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () => widget.pingEndpoint(true),
                  child: const Text("Test"),
                ),
                const SizedBox(width: 10),
                Text(responseMessageDefault),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Custom API"),
                SizedBox(
                  width: 200,
                  height: 38,
                  child: TextField(
                    style: style,
                    decoration: inputDecoration.copyWith(
                        hintText: "Enter your endpoint"),
                    onSubmitted: (value) {
                      widget.displayConfigData.value.apiConfig
                          .customBackendEndpoint = value.trim();
                      widget.displayConfigData.notifyListeners();
                    },
                    onChanged: (value) {
                      widget.displayConfigData.value.apiConfig
                          .customBackendEndpoint = value.trim();
                      widget.displayConfigData.notifyListeners();
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () => widget.pingEndpoint(false),
                  child: const Text("Test"),
                ),
                Text(responseMessageCustom),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const Row(
              children: [
                Text(
                  "Providers",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 56, child: const Text("OpenAI")),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 38,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          widget.openaiAPIKey.text.length < 4
                              ? ""
                              : "${widget.openaiAPIKey.text.substring(0, 3)}...${widget.openaiAPIKey.text.substring(widget.openaiAPIKey.text.length - 4, widget.openaiAPIKey.text.length)}",
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 190,
                      height: 38,
                      child: TextField(
                        controller: widget.openaiAPIKey,
                        style: style,
                        obscureText: true,
                        decoration: inputDecoration.copyWith(
                            hintText: "OpenAi API Key"),
                        onSubmitted: (value) {
                          widget.displayConfigData.value.apiConfig
                              .setOpenAiApiKey(value.trim());
                          widget.displayConfigData.notifyListeners();
                        },
                        onChanged: (value) {
                          widget.displayConfigData.value.apiConfig
                              .setOpenAiApiKey(value.trim());
                          widget.displayConfigData.notifyListeners();
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 56, child: const Text("Groq")),
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      height: 38,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          widget.groqAPIKey.text.isEmpty
                              ? ""
                              : widget.groqAPIKey.text.substring(0, 3) +
                                  "..." +
                                  widget.groqAPIKey.text.substring(
                                      widget.groqAPIKey.text.length - 4,
                                      widget.groqAPIKey.text.length),
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 190,
                      height: 38,
                      child: TextField(
                        controller: widget.groqAPIKey,
                        style: style,
                        obscureText: true,
                        decoration:
                            inputDecoration.copyWith(hintText: "Groq API Key"),
                        onSubmitted: (value) {
                          widget.displayConfigData.value.apiConfig
                              .setGroqApiKey(value.trim());
                          widget.displayConfigData.notifyListeners();
                        },
                        onChanged: (value) {
                          widget.displayConfigData.value.apiConfig
                              .setGroqApiKey(value.trim());
                          widget.displayConfigData.notifyListeners();
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
