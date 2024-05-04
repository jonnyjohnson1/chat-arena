import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ImgSource { photos, camera }

String _stringImageSource(ImgSource imageSource) {
  switch (imageSource) {
    case ImgSource.photos:
      return 'photos';
    case ImgSource.camera:
      return 'camera';
  }
}

class ImagePickerChannel {
  static const platform = MethodChannel('com.dialogues.flutter/imagePicker');

  Future<File?> pickImage({required ImgSource imageSource}) async {
    var stringImageSource = _stringImageSource(imageSource);
    var result = await platform.invokeMethod('pickImage', stringImageSource);
    if (result is String) {
      return File(result);
    } else if (result is FlutterError) {
      throw result;
    }
    return null;
  }
}
