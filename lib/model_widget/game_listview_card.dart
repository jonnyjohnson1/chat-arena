import 'dart:math';

import 'package:chat/models/games_config.dart';
import 'package:flutter/material.dart';

class GameListViewCard extends StatefulWidget {
  final GamesConfig gamesConfig;
  final bool isLoaded;
  const GameListViewCard(
      {required this.gamesConfig, this.isLoaded = false, super.key});

  @override
  State<GameListViewCard> createState() => _GameListViewCardState();
}

String getFileSizeString({required int bytes, int decimals = 0}) {
  if (bytes == 0) return "0";
  const suffixes = ["b", "kb", " MB", " GB", "T"];
  var i = (log(bytes) / log(1024)).floor();
  return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
}

class _GameListViewCardState extends State<GameListViewCard> {
  late double width;
  late double height;

  setSize(CardSize size) {
    switch (size) {
      case CardSize.small:
        width = 135;
        height = 180;
        break;
      case CardSize.medium:
        width = 285;
        height = 150;
        break;
      case CardSize.large:
        width = 285;
        height = 360;
        break;
      default:
    }
  }

  @override
  void initState() {
    setSize(widget.gamesConfig.size!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(width: 1, color: Colors.grey[200]!),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.12),
            spreadRadius: 2,
            blurRadius: 3,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 19),
        child: Stack(
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(
                height: 8,
              ),
              Text(widget.gamesConfig.name!,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 14,
              ),
              Text(widget.gamesConfig.slogan!,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w400)),
              Expanded(
                child: Container(),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
