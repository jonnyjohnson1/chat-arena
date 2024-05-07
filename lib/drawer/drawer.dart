import 'package:flutter/material.dart';

class SettingsDrawer extends StatefulWidget {
  final onTap;
  SettingsDrawer({this.onTap, super.key});

  @override
  State<SettingsDrawer> createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  bool didInit = false;

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 90),
        () => mounted ? setState((() => didInit = true)) : null);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return !didInit
        ? Container()
        : Column(children: [
            const SizedBox(
              height: 3,
            ),
            InkWell(
                onTap: () {
                  widget.onTap("modelmanager");
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: SizedBox(
                    height: 45,
                    child: Row(
                      children: [
                        const Icon(Icons.view_module_outlined),
                        const SizedBox(
                          width: 5,
                        ),
                        Text("Model Manager",
                            style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                  ),
                ))
          ]);
  }
}
