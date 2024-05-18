import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

const String tableImages = "images";

class ImageFields {
  static const List<String> values = [id, bytes, isWeb, webFile, localFile];

  static const String id = '_id';
  static const String bytes = 'bytes';
  static const String isWeb = 'isWeb';
  static const String webFile = 'webFile';
  static const String localFile = 'localFile';
}

class ImageFile {
  final String id;
  final List<int>? bytes;
  final bool isWeb;
  final File? webFile;
  final File? localFile;

  ImageFile(
      {required this.id,
      this.isWeb = false,
      this.bytes,
      this.webFile,
      this.localFile});

  factory ImageFile.fromJson(Map<String, dynamic> json) {
    List<int>? bytes;
    if (json[ImageFields.bytes] != null) {
      bytes = convertDynamicListToIntList(json[ImageFields.bytes]);
    }

    String? webFilePath = json[ImageFields.webFile];
    String? localFilePath = json[ImageFields.localFile];
    // debugPrint("Webfile path loaded: $webFilePath");
    // debugPrint("Localfile path loaded: $localFilePath");
    // debugPrint("isWeb: ${json[ImageFields.isWeb]}");

    return ImageFile(
        id: json[ImageFields.id],
        isWeb: json[ImageFields.isWeb] == 1 ? true : false,
        bytes: bytes,
        webFile: webFilePath != null ? File(webFilePath) : null,
        localFile: localFilePath != null ? File(localFilePath) : null);
  }

  // Convert the Message instance to a Map
  Map<String, dynamic> toMap() {
    return {
      ImageFields.id: id,
      ImageFields.isWeb: isWeb ? 1 : 0,
      ImageFields.bytes: bytes != null ? Uint8List.fromList(bytes!) : null,
      ImageFields.webFile: webFile?.path,
      ImageFields.localFile: localFile?.path
    };
  }
}

List<int> convertDynamicListToIntList(List<dynamic> dynamicList) {
  // Use map to convert each dynamic item to int
  return dynamicList.map((item) => int.parse(item.toString())).toList();
}
