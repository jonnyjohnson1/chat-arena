import 'package:chat/theming/theming_config.dart';
import 'package:flutter/material.dart';

class GetStarted extends StatefulWidget {
  final Function onTap;
  // final ValueNotifier<Script?> selectedScript;

  GetStarted({required this.onTap});

  @override
  _GetStartedState createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> {
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
            widget.onTap();
          },
          child: Container(
            width: 162,
            height: 67,
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
              padding: const EdgeInsets.fromLTRB(10.0, 0, 0, 0),
              child: IgnorePointer(
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // this sized box is white space for another icon to appear
                        const SizedBox(
                          height: 13,
                        ),
                        Expanded(child: Container()),
                        Text(
                          "Setup",
                          style: TextStyle(
                              // fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .color!
                                  .withOpacity(.74)),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          "Start the installer",
                          style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .color!
                                  .withOpacity(.74),
                              fontSize: 11),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Expanded(child: Container()),
                        const SizedBox(
                          height: 13,
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 18,
                    ),
                    Icon(Icons.arrow_forward,
                        size: 22,
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .color!
                            .withOpacity(.74))
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
