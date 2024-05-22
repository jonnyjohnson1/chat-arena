import 'package:chat/models/custom_file.dart';

// UNCOMMENT THESE LINES FOR MACOS/IOS BUILDS
// Future<List<ImageFile>?> getLocalFilePaths() async {
//   return [];
// }

// UNCOMMENT THESE LINES FOR CHROME BUILDS

import 'dart:convert';
import 'dart:io';
import 'package:chat/services/static_queries.dart';
import 'package:chat/services/tools.dart';
import 'package:chat/shared/image_utils.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html if (dart.library.html) '';
import 'package:http/http.dart' as http if (dart.library.html) '';

Future<List<ImageFile>?> getLocalFilePaths() async {
  // Uses the backend flask api to get image name and bytes to render in web
  // but then pass the directory name back to the local machine to use the file
  // in the multi-modal image modelR
  if (kIsWeb){
  final uri = getUrlStart + "0.0.0.0:13341/get_files";
  final url = Uri.parse("$uri");
  final headers = {"accept": "application/json"};

  try {
    var request = await http.post(url, headers: headers);
    var data = json.decode(request.body);
    print(buildString(data['file_name']));
    // Create the File object
    File localFile = File(buildString(data['file_name']));
    List<int> bytes = convertDynamicListToIntList(data['bytes']);
    // Convert bytes to Uint8List
    Uint8List uint8List = Uint8List.fromList(bytes);

    // Create a Blob from the Uint8List
    var blob = html.Blob([uint8List]);
    // Create a link element
    var anchorElement =
        html.AnchorElement(href: html.Url.createObjectUrlFromBlob(blob));
    List<ImageFile> files = [
      ImageFile(
          id: Tools().getRandomString(32),
          bytes: bytes,
          isWeb: true,
          webFile: File(anchorElement.href!),
          localFile: localFile)
    ];

    return files;
  } catch (e) {
    debugPrint('Error: $e');
    return null;
  }}
  else {
    return [];
  }
}
