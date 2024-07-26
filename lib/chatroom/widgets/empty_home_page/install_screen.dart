import 'package:chat/models/display_configs.dart';
import 'package:chat/services/env_installer.dart';
import 'package:chat/services/platform_types.dart';
import 'package:chat/shared/backend_connected_service_button.dart';
import 'package:flutter/material.dart';

class InstallerScreen extends StatelessWidget {
  final VoidCallback onInstall;
  final VoidCallback onUninstall;
  final VoidCallback onReturnHome;
  final bool showReturnButton;
  ValueNotifier<InstallerService> installerService;
  ValueNotifier<DisplayConfigData> displayConfigData;

  InstallerScreen(
      {required this.installerService,
      required this.displayConfigData,
      required this.onInstall,
      required this.onUninstall,
      required this.onReturnHome,
      this.showReturnButton = true});

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = TextStyle(
        color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(.74));
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(
            spacing: 4,
            children: [
              ValueListenableBuilder(
                  valueListenable: installerService,
                  builder: (context, installService, _) {
                    return FutureBuilder(
                        future: isDesktopPlatform(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return Container(height: 22);
                          return ServiceToggle(
                              isConnected: installService.backendConnected,
                              // Only a desktop app with a local connection can
                              // attempt connect/disconnect
                              onTap: snapshot.data! &&
                                      displayConfigData.value.apiConfig
                                          .isLocalhost()
                                  ? (isConnected) async {
                                      if (isConnected) {
                                        print("connect!");
                                        // connect
                                        var result = await installerService
                                            .value
                                            .turnToposOn(displayConfigData
                                                .value.apiConfig
                                                .getDefault());
                                        print(
                                            'Topos is running at ${result['url']}');
                                        bool connected = result['isRunning'];
                                        installerService
                                            .value.backendConnected = connected;
                                        installerService.notifyListeners();
                                      } else {
                                        print("disconnect!");
                                        // // disconnect
                                        installerService.value
                                            .stopToposService(displayConfigData
                                                .value.apiConfig
                                                .getDefault())
                                            .then(
                                          (disconnected) {
                                            if (disconnected) {
                                              installerService.value
                                                  .backendConnected = false;
                                              installerService
                                                  .notifyListeners();
                                            }
                                          },
                                        );
                                      }
                                    }
                                  : null);
                        });
                  }),
              ElevatedButton(
                onPressed: onInstall,
                child: Text(
                  "Install",
                  style: textStyle,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onUninstall,
                child: Text(
                  "Uninstall Backend",
                  style: textStyle,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onInstall,
                child: Text(
                  "Update",
                  style: textStyle,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onInstall,
                child: Text(
                  "Check for Updates",
                  style: textStyle,
                ),
              ),
              if (showReturnButton)
                ElevatedButton(
                  onPressed: onReturnHome,
                  child: Text(
                    "Go Back",
                    style: textStyle,
                  ),
                ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
                constraints:
                    const BoxConstraints(maxWidth: 890, maxHeight: 700),
                child: ValueListenableBuilder(
                    valueListenable: installerService.value.outputNotifier,
                    builder: (context, output, _) {
                      int maxLines = 100;
                      List<String> displayOutput = output.isNotEmpty
                          ? (output.length > maxLines
                              ? output.sublist(output.length - maxLines)
                              : output)
                          : [];
                      return Container(
                        height: 150, // Adjust height as needed
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: SelectionArea(
                            child: ListView.builder(
                              reverse: true,
                              shrinkWrap: true,
                              itemCount: displayOutput.length,
                              itemBuilder: (context, index) {
                                String text = displayOutput[
                                    displayOutput.length - 1 - index];
                                print("empty: ${text.isEmpty}, $text");
                                return Text(
                                  displayOutput[
                                      displayOutput.length - 1 - index],
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                  style: textStyle.copyWith(fontSize: 12),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    })),
          ),
        ],
      ),
    );
  }
}
