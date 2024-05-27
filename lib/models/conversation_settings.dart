class ConversationOptionsResponse {
  String text;
  ConversationVoiceSettings settings;
  ConversationOptionsResponse({required this.text, required this.settings});
}

class ConversationVoiceSettings {
  String tone;
  String distance;
  String pace;
  String depth;
  String engagement;
  String messageLength;
  String attention;

  ConversationVoiceSettings(
      {required this.tone,
      required this.distance,
      required this.pace,
      required this.depth,
      required this.engagement,
      required this.messageLength,
      required this.attention});

  // Factory constructor to create an instance from a JSON map
  factory ConversationVoiceSettings.fromJson(Map<String, dynamic> json) {
    return ConversationVoiceSettings(
      tone: json['tone'],
      distance: json['distance'],
      pace: json['pace'],
      depth: json['depth'],
      engagement: json['engagement'],
      messageLength: json['message_length'],
      attention: json['attention'],
    );
  }

  // Method to convert an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'tone': tone,
      'distance': distance,
      'pace': pace,
      'depth': depth,
      'engagement': engagement,
      'message_length': messageLength,
      'attention': attention
    };
  }

  @override
  String toString() {
    return 'Attention: $attention\nTone: $tone\nDistance: $distance\nPace: $pace\nDepth: $depth\nEngagement: $engagement\nMessage Length: $messageLength';
  }
}
