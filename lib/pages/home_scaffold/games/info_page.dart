import 'package:chat/models/games_config.dart';
import 'package:flutter/material.dart';

class GamesInfoPage extends StatefulWidget {
  final GamesConfig game;
  const GamesInfoPage({required this.game, super.key});

  @override
  State<GamesInfoPage> createState() => _GamesInfoPageState();
}

class _GamesInfoPageState extends State<GamesInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.game.name!,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(
          height: 12,
        ),
        Text(
          widget.game.longDescription!,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
