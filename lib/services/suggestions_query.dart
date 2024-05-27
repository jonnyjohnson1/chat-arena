import 'package:chat/models/suggestion_model.dart';
import 'package:chat/services/json_loader.dart';
import 'package:flutter/foundation.dart';

Future<Map<String, List<Suggestion>>?> getSuggestionsMap() async {
  dynamic steeringJsonData = await loadSteeringJson();
  try {
    Map<String, List<Suggestion>> suggestionsMap = {};
    // Iterate over the keys of the JSON
    steeringJsonData.forEach((key, value) {
      if (value != null && value['suggestions'] != null) {
        String topicEmoji = value['topic_emoji'];
        List<dynamic> rawSuggestions = value['suggestions'];
        List<Suggestion> suggestions = rawSuggestions
            .map((suggestion) => Suggestion.fromJson(suggestion, topicEmoji))
            .toList();
        suggestionsMap[key] = suggestions;
      }
    });

    return suggestionsMap;
  } catch (e) {
    debugPrint('Error: $e');
    return null;
  }
}
