import 'dart:io';

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
