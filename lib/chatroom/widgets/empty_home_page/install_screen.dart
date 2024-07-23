import 'package:chat/services/env_installer.dart';
import 'package:flutter/material.dart';

class InstallerScreen extends StatelessWidget {
  final VoidCallback onInstall;
  final VoidCallback onReturnHome;
  ValueNotifier<InstallerService> installerService;

  InstallerScreen(
      {required this.installerService,
      required this.onInstall,
      required this.onReturnHome});

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
              ElevatedButton(
                onPressed: onInstall,
                child: Text(
                  "Install",
                  style: textStyle,
                ),
              ),
              const SizedBox(height: 20),
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
                    const BoxConstraints(maxWidth: 620, maxHeight: 500),
                child: ValueListenableBuilder(
                    valueListenable: installerService.value.outputNotifier,
                    builder: (context, output, _) {
                      List<String> displayOutput = output.isNotEmpty
                          ? (output.length > 20
                              ? output.sublist(output.length - 5)
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
                          child: ListView.builder(
                            reverse: true,
                            shrinkWrap: true,
                            itemCount: displayOutput.length,
                            itemBuilder: (context, index) {
                              return SelectionArea(
                                child: Text(
                                  displayOutput[
                                      displayOutput.length - 1 - index],
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                  style: textStyle.copyWith(fontSize: 12),
                                ),
                              );
                            },
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
