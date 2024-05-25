import 'dart:convert';

import 'package:chat/models/custom_file.dart';
import 'package:chat/shared/image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:image_downloader/image_downloader.dart';
import 'package:universal_html/html.dart' as html;

class ImagesListWidget extends StatefulWidget {
  final double width;
  final double height;
  final List<ImageFile> imagesList;
  final int initialIndex;
  final bool disableLaunchImage;
  final bool displayPromptText;
  final int promptMaxLines;
  final double promptFontSize;
  final bool showCopyButton;
  final Function? regenImage;

  ImagesListWidget(
      {required this.imagesList,
      this.height = 150,
      this.width = 150,
      this.initialIndex = 0,
      this.disableLaunchImage = false,
      this.displayPromptText = true,
      this.promptMaxLines = 2,
      this.promptFontSize = 12,
      this.showCopyButton = false,
      this.regenImage});

  @override
  _ImagesListWidgetState createState() => _ImagesListWidgetState();
}

class _ImagesListWidgetState extends State<ImagesListWidget> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  void _downloadImage() async {
    try {
      final imageBytes = widget.imagesList[currentIndex].bytes;
      String fileName =
          widget.imagesList[currentIndex].localFile!.path ?? 'image.png';
      if (imageBytes == null) return;

      if (Theme.of(context).platform == TargetPlatform.android ||
          Theme.of(context).platform == TargetPlatform.iOS) {
        final imageId = await ImageDownloader.downloadImage(
          'data:image/jpeg;base64,${base64Encode(imageBytes)}',
          destination: AndroidDestinationType.directoryDownloads
            ..subDirectory("image.png"),
        );

        if (imageId == null) {
          return;
        }

        final path = await ImageDownloader.findPath(imageId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image downloaded to $path')),
        );
      } else if (Theme.of(context).platform == TargetPlatform.fuchsia ||
          Theme.of(context).platform == TargetPlatform.macOS ||
          Theme.of(context).platform == TargetPlatform.windows ||
          Theme.of(context).platform == TargetPlatform.linux) {
        final base64data = base64Encode(imageBytes);
        final a = html.AnchorElement(href: 'data:image/jpeg;base64,$base64data')
          ..setAttribute('download', fileName)
          ..click();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Image downloaded to Downloads directory')));
      }
    } on PlatformException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading image: $error')),
      );
    }
  }

  void _copyPromptText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Prompt text copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Building images list");
    return widget.imagesList.isEmpty
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image,
                  size: widget.width,
                  color: const Color.fromARGB(255, 217, 217, 217)),
              ElevatedButton(
                onPressed: () {
                  if (widget.regenImage != null) {
                    widget.regenImage!();
                  }
                },
                child: const Text('Generate Image'),
              ),
            ],
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_left),
                    onPressed: () {
                      setState(() {
                        currentIndex =
                            (currentIndex - 1 + widget.imagesList.length) %
                                widget.imagesList.length;
                      });
                    },
                  ),
                  InkWell(
                    onTap: widget.disableLaunchImage
                        ? null
                        : () async {
                            await launchImageViewerMemory(
                                context, widget.imagesList, currentIndex);
                          },
                    child: SizedBox(
                      width: widget.width,
                      height: widget.height,
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.memory(Uint8List.fromList(
                              widget.imagesList[currentIndex].bytes!)),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_right),
                    onPressed: () {
                      setState(() {
                        currentIndex =
                            (currentIndex + 1) % widget.imagesList.length;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 2),
              if (widget.displayPromptText)
                if (widget.imagesList[currentIndex].description != null)
                  SelectionArea(
                    child: Container(
                        constraints:
                            BoxConstraints(maxWidth: widget.width + 26),
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.imagesList[currentIndex].description!,
                                overflow: TextOverflow.ellipsis,
                                maxLines: widget.promptMaxLines,
                                style:
                                    TextStyle(fontSize: widget.promptFontSize),
                              ),
                            ),
                            if (widget.showCopyButton)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 16),
                                    onPressed: () {
                                      _copyPromptText(widget
                                          .imagesList[currentIndex]
                                          .description!);
                                    },
                                  ),
                                ],
                              ),
                          ],
                        )),
                  ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${currentIndex + 1}/${widget.imagesList.length}'),
                  IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        size: 18,
                      ),
                      onPressed: () {
                        if (widget.regenImage != null) {
                          widget.regenImage!();
                        }
                      }),
                ],
              ),
            ],
          );
  }
}
