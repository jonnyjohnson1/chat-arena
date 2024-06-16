import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:load_switch/load_switch.dart';

Future<Map<String, dynamic>> getGameSettings(BuildContext context) async {
  TextEditingController topicController = TextEditingController();
  debugPrint("\t[ Debate :: Get Game Settings ]");

  bool? freeplayMode; // Variable to hold the freeplay mode value

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Say Something Contentious 😏"),
        content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: DebateGameSettings(
              topicController: topicController,
              onFreeplayModeChanged: (mode) {
                freeplayMode = mode;
              },
            )),
        actions: <Widget>[
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );

  // Now you can use topicController.text to get the entered topic
  debugPrint("\t\t[ Debate Topic: ${topicController.text} ]");
  debugPrint("\t\t[ Freeplay Mode: $freeplayMode ]");

  return {
    'topic': topicController.text,
    'freeplayMode': freeplayMode ?? true, // Default to true if not set
  };
}

class DebateGameSettings extends StatefulWidget {
  final TextEditingController topicController;
  final ValueChanged<bool> onFreeplayModeChanged;

  const DebateGameSettings(
      {required this.topicController,
      required this.onFreeplayModeChanged,
      super.key});

  @override
  State<DebateGameSettings> createState() => _DebateGameSettingsState();
}

class _DebateGameSettingsState extends State<DebateGameSettings> {
  bool freeplayMode = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          maxLines: 6,
          minLines: 1,
          controller: widget.topicController,
          decoration: const InputDecoration(hintText: "Enter topic"),
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text("Mode"),
            Expanded(
              child: Container(),
            ),
            const SizedBox(width: 15),
            Text(
              freeplayMode ? "Freeplay" : "Turn-taking",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 15),
            SizedBox(
              width: 42,
              child: LoadSwitch(
                height: 23,
                width: 38,
                value: freeplayMode,
                future: () async {
                  await Future.delayed(const Duration(milliseconds: 400));
                  return !freeplayMode;
                },
                style: SpinStyle.material,
                switchDecoration: (isActive, isPressed) => BoxDecoration(
                  color: isActive
                      ? const Color.fromARGB(255, 122, 11, 158)
                      : const Color.fromARGB(255, 193, 193, 193),
                  borderRadius: BorderRadius.circular(30),
                  shape: BoxShape.rectangle,
                  boxShadow: [
                    BoxShadow(
                      color: isActive
                          ? const Color.fromARGB(255, 222, 222, 222)
                          : const Color.fromARGB(255, 213, 213, 213),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                spinColor: (isActive) =>
                    const Color.fromARGB(255, 125, 73, 182),
                onChange: (v) {
                  setState(() {
                    freeplayMode = v;
                  });
                  widget.onFreeplayModeChanged(
                      freeplayMode); // Notify parent of change
                },
                onTap: (v) {
                  // print('Tapping while value is $v');
                },
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ],
    );
  }
}
