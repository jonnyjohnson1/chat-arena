import 'dart:io';

import 'package:chat/models/custom_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const String tableMessages = 'messages';

enum MessageType {
  text,
  image,
  poll,
  deleted,
}

class MessageFields {
  static const List<String> values = [
    id,
    documentID,
    senderID,
    conversationID,
    message,
    timestamp,
    toksPerSec,
    completionTime,
    type,
    status,
    name,
    isGenerating,
    images
  ];

  static const String id = '_id';
  static const String documentID = 'documentID';
  static const String senderID = 'senderID';
  static const String conversationID = 'conversationID';
  static const String message = 'message';
  static const String timestamp = 'timestamp';
  static const String toksPerSec = 'toksPerSec';
  static const String completionTime = 'completionTime';
  static const String type = 'type';
  static const String status = 'status';
  static const String name = 'name';
  static const String isGenerating = 'isGenerating';
  static const String images = 'images';
}

class Message {
  String id;
  final String? documentID;
  final String? senderID;
  final String? conversationID;
  ValueNotifier<String>? message;
  final DateTime? timestamp;
  double toksPerSec;
  double? completionTime;
  final MessageType? type;
  final String? status;
  final String? name;
  bool isGenerating;
  List<ImageFile>? images;

  Message(
      {required this.id,
      this.documentID,
      this.senderID,
      required this.conversationID,
      this.message,
      this.timestamp,
      this.completionTime = 000,
      this.toksPerSec = 000,
      this.type,
      this.status,
      this.name,
      this.isGenerating = false,
      this.images});

  // Convert the Message instance to a Map
  Map<String, dynamic> toMap() {
    // convert img files to list
    String imgSep = "#&%*";
    List<String> imgStrings = [];
    if (images != null) {
      images!.forEach((element) {
        if (kIsWeb) {
          imgStrings.add(element.webFile!.path);
        } else {
          imgStrings.add(element.localFile!.path);
        }
      });
    }

    return {
      MessageFields.id: id,
      MessageFields.documentID: documentID,
      MessageFields.senderID: senderID,
      MessageFields.conversationID: conversationID,
      MessageFields.message: message!.value,
      MessageFields.timestamp: timestamp?.toIso8601String(),
      MessageFields.toksPerSec: toksPerSec,
      MessageFields.completionTime: completionTime,
      MessageFields.type: type?.index,
      MessageFields.status: status,
      MessageFields.name: name,
      MessageFields.isGenerating: isGenerating ? 1 : 0,
      MessageFields.images: imgStrings.join(imgSep)
    };
  }

  // Create a Message instance from a Map
  factory Message.fromMap(Map<String, dynamic> map) {
    String imgSep = "#&%*";
    List<ImageFile>? images = [];
    if (map.containsKey(MessageFields.images)) {
      map[MessageFields.images].split(imgSep).forEach((String filepath) {
        if (kIsWeb) {
          images.add(ImageFile(webFile: File(filepath)));
        } else {
          images.add(ImageFile(localFile: File(filepath)));
        }
      });
    }
    return Message(
      id: map[MessageFields.id],
      documentID: map[MessageFields.documentID],
      senderID: map[MessageFields.senderID],
      conversationID: map[MessageFields.conversationID],
      message: ValueNotifier(map[MessageFields.message]),
      timestamp: map[MessageFields.timestamp] != null
          ? DateTime.parse(map[MessageFields.timestamp])
          : null,
      toksPerSec: map[MessageFields.toksPerSec].toDouble(),
      completionTime: map[MessageFields.completionTime].toDouble(),
      type: MessageType.values[map[MessageFields.type]],
      status: map[MessageFields.status],
      name: map[MessageFields.name],
      isGenerating: map[MessageFields.isGenerating] == 1 ? true : false,
      images: images,
    );
  }

  @override
  String toString() =>
      'Message(id: $id, documentID: $documentID, senderID: $senderID, conversationID: $conversationID, message: $message, timestamp: $timestamp)';
}
