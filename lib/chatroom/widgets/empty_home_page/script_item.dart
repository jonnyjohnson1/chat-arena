import 'package:chat/models/conversation.dart';
import 'package:chat/models/scripts.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class ScriptItem extends StatefulWidget {
  final Script script;
  final Function onScriptSelectionTap;
  // final ValueNotifier<Script?> selectedScript;

  ScriptItem({required this.script, required this.onScriptSelectionTap});

  @override
  _ScriptItemState createState() => _ScriptItemState();
}

class _ScriptItemState extends State<ScriptItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (event) => setState(() => isHovered = true),
        onExit: (event) => setState(() => isHovered = false),
        child: GestureDetector(
          onTap: () {
            widget.onScriptSelectionTap();
          },
          child: Container(
            width: 170,
            height: 95,
            decoration: BoxDecoration(
                color: isHovered
                    ? const Color.fromARGB(255, 246, 246, 246)
                    : Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                border: Border.all(
                    width: 1, color: const Color.fromARGB(255, 201, 201, 201)),
                boxShadow: const [
                  BoxShadow(
                      color: Color.fromARGB(255, 234, 234, 234),
                      spreadRadius: 2,
                      blurRadius: 5)
                ]),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10.0, 4, 10, 4),
              child: IgnorePointer(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // this sized box is white space for another icon to appear
                    SizedBox(
                      height: 13,
                    ),
                    Expanded(child: Container()),
                    Text(
                      widget.script.name,
                      style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .color!
                              .withOpacity(.74),
                          fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Expanded(child: Container()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          " (${widget.script.author})",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .color!
                                  .withOpacity(.74),
                              fontSize: 11),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            for (GameType type in widget.script.type)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2.0),
                                child: Conversation(id: "unknown")
                                    .gameTypeToIcon(type, size: 11),
                              )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
