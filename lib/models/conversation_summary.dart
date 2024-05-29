import 'package:chat/models/messages.dart';

class ConversationSummary {
  final String id;
  Message? summary;
  List<String> conversationMessageIds;
  final String? focalPoint;

  ConversationSummary({
    required this.id,
    this.summary,
    required this.focalPoint,
  }) : conversationMessageIds = [];
}
