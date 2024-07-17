import 'package:chat/chatroom/widgets/empty_home_page/script_item.dart';
import 'package:chat/models/conversation.dart';
import 'package:chat/models/demoController.dart';
import 'package:chat/models/display_configs.dart';
import 'package:chat/models/scripts.dart';
import 'package:chat/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StarterHomePage extends StatefulWidget {
  const StarterHomePage({super.key});

  @override
  State<StarterHomePage> createState() => _StarterHomePageState();
}

class _StarterHomePageState extends State<StarterHomePage> {
  late ValueNotifier<User> userModel;
  late ValueNotifier<Scripts?> scriptsListenable;
  late ValueNotifier<Script?> selectedScript;
  late ValueNotifier<DisplayConfigData> displayConfigData;
  late ValueNotifier<Conversation?> currentSelectedConversation;
  late ValueNotifier<DemoController> demoController;

  @override
  void initState() {
    super.initState();
    currentSelectedConversation =
        Provider.of<ValueNotifier<Conversation?>>(context, listen: false);
    displayConfigData =
        Provider.of<ValueNotifier<DisplayConfigData>>(context, listen: false);
    demoController =
        Provider.of<ValueNotifier<DemoController>>(context, listen: false);
    userModel = Provider.of<ValueNotifier<User>>(context, listen: false);
    scriptsListenable =
        Provider.of<ValueNotifier<Scripts?>>(context, listen: false);
    selectedScript =
        Provider.of<ValueNotifier<Script?>>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Scripts?>(
      valueListenable: scriptsListenable,
      builder: (context, scripts, _) {
        if (scripts == null) return const CupertinoActivityIndicator();
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Demos",
                style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color!
                        .withOpacity(.74)),
              ),
              Wrap(
                spacing: 8.0, // space between items horizontally
                runSpacing: 8.0, // space between items vertically
                children: scripts.demos.map((script) {
                  return ScriptItem(
                    script: script,
                    onScriptSelectionTap: () {
                      setState(() {
                        selectedScript.value = script;
                        selectedScript.notifyListeners();
                        debugPrint("\t[ selected script :: ${script.name} ]");
                        displayConfigData.value.demoMode = true;
                        displayConfigData.notifyListeners();
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(
                height: 14,
              ), // whitespace to center the demo options
            ],
          ),
        );
      },
    );
  }
}
