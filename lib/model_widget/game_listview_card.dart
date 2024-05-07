import 'dart:math';

import 'package:chat/models/games_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:chat/models/models.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';
import 'package:url_launcher/url_launcher.dart';

class GameListViewCard extends StatefulWidget {
  GamesConfig gamesConfig;
  final Function(ModelConfig)? onDownload;
  final onStop;
  final Function(ModelConfig)? onTap;
  final Function(ModelConfig)? onClear;
  bool isLoaded;
  GameListViewCard(
      {required this.gamesConfig,
      this.onDownload,
      this.onStop,
      this.onTap,
      this.onClear,
      this.isLoaded = false,
      super.key});

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
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: 214,
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
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 14,
              ),
              // const Text("Description:",
              //     style: const TextStyle(
              //         fontSize: 12, fontWeight: FontWeight.w400)),
              // const SizedBox(
              //   height: 8,
              // ),
              Text(widget.gamesConfig.description!,
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
