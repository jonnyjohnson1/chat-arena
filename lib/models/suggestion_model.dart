class Suggestion {
  final String suggestion;
  final String purpose;
  final String? emoji;

  const Suggestion({
    required this.suggestion,
    required this.purpose,
    this.emoji,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json, String topicEmoji) {
    return Suggestion(
      suggestion: json['suggestion'] ?? "<insert suggestion>",
      purpose: json['purpose'] ?? "<insert purpose>",
      emoji: topicEmoji,
    );
  }

  Map<String, dynamic> toJson() {
    return {'suggestion': suggestion, 'purpose': purpose, 'topic_emoji': emoji};
  }
}
