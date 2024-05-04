import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:chat/models/models.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';
import 'package:url_launcher/url_launcher.dart';

class ModelListViewCard extends StatefulWidget {
  ModelConfig modelConfig;
  final Function(ModelConfig)? onDownload;
  final onStop;
  final Function(ModelConfig)? onTap;
  final Function(ModelConfig)? onClear;
  bool isLoaded;
  ModelListViewCard(
      {required this.modelConfig,
      this.onDownload,
      this.onStop,
      this.onTap,
      this.onClear,
      this.isLoaded = false,
      super.key});

  @override
  State<ModelListViewCard> createState() => _ModelListViewCardState();
}

String getFileSizeString({required int bytes, int decimals = 0}) {
  if (bytes == 0) return "0";
  const suffixes = ["b", "kb", " MB", " GB", "T"];
  var i = (log(bytes) / log(1024)).floor();
  return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
}

class _ModelListViewCardState extends State<ModelListViewCard> {
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
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 7),
        child: Stack(
          children: [
            Column(children: [
              const SizedBox(
                height: 8,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              width: 4,
                            ),
                            Expanded(
                              child: Text(
                                  widget.modelConfig.displayName == ""
                                      ? widget.modelConfig.localID!
                                          .split("-")
                                          .first
                                      : widget.modelConfig.displayName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.modelConfig.localID!,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'URL',
                                    style: const TextStyle(color: Colors.blue),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        String url =
                                            widget.modelConfig.modelLib!;
                                        print(url);
                                        if (await canLaunchUrl(
                                            Uri.parse(url))) {
                                          await launchUrl(Uri.parse(url));
                                        } else {
                                          // can't launch url, there is some error
                                          throw "Could not launch $url";
                                        }
                                      },
                                  ),
                                ],
                              ),
                            ),
                            Expanded(child: Container()),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 1,
              ),
              Expanded(
                child: Container(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                      widget.modelConfig.internalEstimatedVRAMReq != null
                          ? " (${getFileSizeString(bytes: widget.modelConfig.internalEstimatedVRAMReq!, decimals: 2)})"
                          : "(?)",
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
