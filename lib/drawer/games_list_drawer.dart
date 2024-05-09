import 'package:chat/model_widget/game_manager.dart';
import 'package:chat/models/games_config.dart';
import 'package:flutter/material.dart';

class GamesListDrawer extends StatefulWidget {
  final onTap;
  final onGameCardTap;
  GamesListDrawer({this.onTap, this.onGameCardTap, super.key});

  @override
  State<GamesListDrawer> createState() => _GamesListDrawerState();
}

class _GamesListDrawerState extends State<GamesListDrawer> {
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
                // onTap: () {
                //   widget.onTap("gamemanager");
                // },
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
                    Text("Games",
                        style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
              ),
            )),
            Expanded(
              child: GamesListPage(
                duration: 90,
                selectedGame: (GamesConfig selected) {
                  // TODO Update hoem page to game viewer page
                  if (widget.onGameCardTap != null) {
                    widget.onGameCardTap(selected);
                  }
                },
              ),
            )
          ]);
  }
}
