import 'package:chat/models/games_config.dart';
import 'package:flutter/material.dart';

class GameDropdownListViewItem extends StatefulWidget {
  GamesConfig gameConfig;
  final Function(GamesConfig)? onTap;
  bool isLoaded;
  GameDropdownListViewItem(
      {required this.gameConfig, this.onTap, this.isLoaded = false, super.key});

  @override
  State<GameDropdownListViewItem> createState() =>
      _GameDropdownListViewItemState();
}

class _GameDropdownListViewItemState extends State<GameDropdownListViewItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () =>
            widget.onTap != null ? widget.onTap!(widget.gameConfig) : null,
        child: Column(children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.isLoaded
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(
                          Icons.check,
                          size: 20,
                          color: Colors.green,
                        ),
                      ],
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(
                          Icons.circle_outlined,
                          size: 20,
                          color: Colors.black87,
                        ),
                      ],
                    ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.gameConfig.name!,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      widget.gameConfig.description!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
