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
    isGenerating
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
}

class Message {
  String id;
  final String? documentID;
  final String? senderID;
  final String? conversationID;
  String? message;
  final DateTime? timestamp;
  double toksPerSec;
  double? completionTime;
  final MessageType? type;
  final String? status;
  final String? name;
  bool isGenerating;

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
      this.isGenerating = false});

  // Convert the Message instance to a Map
  Map<String, dynamic> toMap() {
    return {
      MessageFields.id: id,
      MessageFields.documentID: documentID,
      MessageFields.senderID: senderID,
      MessageFields.conversationID: conversationID,
      MessageFields.message: message,
      MessageFields.timestamp: timestamp?.toIso8601String(),
      MessageFields.toksPerSec: toksPerSec,
      MessageFields.completionTime: completionTime,
      MessageFields.type: type?.index,
      MessageFields.status: status,
      MessageFields.name: name,
      MessageFields.isGenerating: isGenerating ? 1 : 0,
    };
  }

  // Create a Message instance from a Map
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map[MessageFields.id],
      documentID: map[MessageFields.documentID],
      senderID: map[MessageFields.senderID],
      conversationID: map[MessageFields.conversationID],
      message: map[MessageFields.message],
      timestamp: map[MessageFields.timestamp] != null
          ? DateTime.parse(map[MessageFields.timestamp])
          : null,
      toksPerSec: map[MessageFields.toksPerSec],
      completionTime: map[MessageFields.completionTime],
      type: MessageType.values[map[MessageFields.type]],
      status: map[MessageFields.status],
      name: map[MessageFields.name],
      isGenerating: map[MessageFields.isGenerating] == 1 ? true : false,
    );
  }

  @override
  String toString() =>
      'Message(id: $id, documentID: $documentID, senderID: $senderID, conversationID: $conversationID, message: $message, timestamp: $timestamp)';
}
