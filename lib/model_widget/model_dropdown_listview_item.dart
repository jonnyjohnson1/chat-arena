import 'dart:math';
import 'package:flutter/material.dart';
import 'package:chat/models/models.dart';

class ModelDropdownListViewItem extends StatefulWidget {
  ModelConfig modelConfig;
  final Function(ModelConfig)? onTap;
  bool isLoaded;
  ModelDropdownListViewItem(
      {required this.modelConfig,
      this.onTap,
      this.isLoaded = false,
      super.key});

  @override
  State<ModelDropdownListViewItem> createState() =>
      _ModelDropdownListViewItemState();
}

String getFileSizeString({required int bytes, int decimals = 0}) {
  const suffixes = ["b", "kb", " MB", " GB", "T"];
  var i = (log(bytes) / log(1024)).floor();
  return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
}

class _ModelDropdownListViewItemState extends State<ModelDropdownListViewItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: widget.modelConfig.modelDownloadState !=
                ModelDownloadState.finished
            ? () => null
            : () =>
                widget.onTap != null ? widget.onTap!(widget.modelConfig) : null,
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
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(
                          Icons.circle_outlined,
                          size: 20,
                          color: widget.modelConfig.modelDownloadState ==
                                  ModelDownloadState.finished
                              ? Colors.black87
                              : Colors.grey.shade600,
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
                            widget.modelConfig.displayName == ""
                                ? widget.modelConfig.localID!.split('-').first
                                : widget.modelConfig.displayName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 18,
                                color: widget.modelConfig.modelDownloadState ==
                                        ModelDownloadState.finished
                                    ? Colors.black87
                                    : Colors.grey.shade600,
                                fontWeight:
                                    widget.modelConfig.modelDownloadState ==
                                            ModelDownloadState.finished
                                        ? FontWeight.bold
                                        : FontWeight.normal),
                          ),
                        ),
                        Text(
                            widget.modelConfig.internalEstimatedVRAMReq != null
                                ? " (${getFileSizeString(bytes: widget.modelConfig.internalEstimatedVRAMReq!, decimals: 2)})"
                                : "(?)",
                            style: TextStyle(
                              fontSize: 14,
                              color: widget.modelConfig.modelDownloadState ==
                                      ModelDownloadState.finished
                                  ? Colors.black87
                                  : Colors.grey.shade600,
                            )),
                      ],
                    ),
                    Text(
                      widget.modelConfig.localID!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: widget.modelConfig.modelDownloadState ==
                                  ModelDownloadState.finished
                              ? Colors.black87
                              : Colors.grey.shade600,
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
