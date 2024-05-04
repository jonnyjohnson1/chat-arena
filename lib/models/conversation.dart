const String tableConversations = 'conversations';

class ConversationFields {
  static const List<String> values = [
    id,
    title,
    lastMessage,
    image,
    primaryModel,
    time
  ];

  static const String id = '_id';
  static const String title = 'title';
  static const String lastMessage = 'lastMessage';
  static const String image = 'image';
  static const String primaryModel = 'primayModel';
  static const String time = 'time';
}

class Conversation {
  String? title;
  String? lastMessage;
  String? image;
  DateTime? time;
  String? primaryModel;
  String id;
  Conversation(
      {this.title,
      this.lastMessage,
      this.image,
      this.primaryModel,
      this.time,
      required this.id});

  // Convert the Conversation instance to a Map
  Map<String, dynamic> toMap() {
    return {
      ConversationFields.id: id,
      ConversationFields.title: title,
      ConversationFields.lastMessage: lastMessage,
      ConversationFields.image: image,
      ConversationFields.time: time?.toIso8601String(),
      ConversationFields.primaryModel: primaryModel,
    };
  }

  // Create a Conversation instance from a Map
  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      title: map['title'],
      lastMessage: map['lastMessage'],
      image: map['image'],
      time: map['time'] != null ? DateTime.parse(map['time']) : null,
      primaryModel: map['primaryModel'],
      id: map['_id'],
    );
  }

  static Conversation fromJson(Map<String, Object?> json) => Conversation(
      id: json[ConversationFields.id] as String,
      title: json[ConversationFields.title] as String?,
      lastMessage: json[ConversationFields.lastMessage] as String?,
      image: json[ConversationFields.image] as String?,
      time: json[ConversationFields.time] != null
          ? DateTime.parse(json[ConversationFields.time] as String)
          : null,
      primaryModel: json[ConversationFields.primaryModel] as String?);

  // String toJson() => json.encode(toMap());

  // factory Conversation.fromJson(String source) =>
  //     Conversation.fromMap(json.decode(source));

  @override
  String toString() =>
      'Conversation(id: $id, time: $time, title: $title, lastMessage: $lastMessage)';
}
