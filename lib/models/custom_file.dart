import 'dart:io';

class ImageFile {
  final List<int>? bytes;
  final File? webFile;
  final File? localFile;

  ImageFile({this.bytes, this.webFile, this.localFile});

  factory ImageFile.fromJson(Map<String, dynamic> json) {
    return ImageFile(
        bytes: json['bytes'],
        webFile: File(json['webFile']),
        localFile: File(json['localFile']));
  }
}
