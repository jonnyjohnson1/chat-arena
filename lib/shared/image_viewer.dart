import 'dart:io';

import 'package:chat/models/custom_file.dart';
import 'package:chat/shared/images_list_widget.dart';
import 'package:chat/shared/launch_hyperlink.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> launchImageViewer(BuildContext context, File? imageUrl) async {
  if (imageUrl != null) {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.8,
                child: kIsWeb
                    ? Image.network(
                        imageUrl.path,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(),
                      )
                    : Image.file(imageUrl,
                        errorBuilder: (context, error, stackTrace) =>
                            Container())));
      },
    );
  }
}

Future<void> launchImageViewerMemory(
    BuildContext context, List<ImageFile> imagesList, int currentIdx) async {
  if (imagesList.isNotEmpty) {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 25, top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Hyperlink(
                      'https://huggingface.co/spaces/Rmpmartinspro2/Comic-Diffusion',
                      'Visit Comic Diffusion',
                    ),
                  ],
                ),
              ),
              ImagesListWidget(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.8,
                  imagesList: imagesList,
                  initialIndex: currentIdx,
                  disableLaunchImage: true,
                  promptMaxLines: 2,
                  promptFontSize: 14,
                  showCopyButton: true),
            ],
          ),
        );
      },
    );
  }
}
