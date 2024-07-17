import 'package:chat/models/scripts.dart';
import 'package:chat/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ScriptsSelectionDropdown extends StatefulWidget {
  int duration;
  bool isMobile;
  final onScriptSelectionTap;
  double width;
  ScriptsSelectionDropdown(
      {this.duration = 200,
      this.onScriptSelectionTap,
      required this.width,
      this.isMobile = false,
      super.key});

  @override
  State<ScriptsSelectionDropdown> createState() =>
      _ScriptsSelectionDropdownState();
}

class _ScriptsSelectionDropdownState extends State<ScriptsSelectionDropdown> {
  bool didInit = false;
  late ValueNotifier<Scripts?> scripts;
  late ValueNotifier<Script?> selectedScript;
  late ValueNotifier<User> userModel;
  @override
  void initState() {
    selectedScript =
        Provider.of<ValueNotifier<Script?>>(context, listen: false);
    scripts = Provider.of<ValueNotifier<Scripts?>>(context, listen: false);
    userModel = Provider.of<ValueNotifier<User>>(context, listen: false);
    Future.delayed(Duration(milliseconds: widget.duration),
        () => setState((() => didInit = true)));
    super.initState();
  }

  int? selectedModelIdx;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListView.builder(
              shrinkWrap: true,
              itemCount: scripts.value!.demos.length,
              itemBuilder: (contextx, idx) {
                // let's pull the demo options
                Script script = scripts.value!.demos[idx];
                return Container(
                  decoration: BoxDecoration(
                    color: selectedScript.value == script
                        ? Theme.of(context).colorScheme.surface
                        : Colors.transparent,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          // assign role to userid
                          selectedScript.value = script;
                          selectedScript.notifyListeners();
                          debugPrint("\t[ selected script :: ${script.name} ]");
                          widget.onScriptSelectionTap();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 15),
                        child: SizedBox(
                          width: 170,
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(
                                script.name,
                                style: const TextStyle(fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                                // style: TextStyle(
                                //     fontSize:
                                //         16)),
                              )),
                              Text(" (${script.author})",
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }
}
