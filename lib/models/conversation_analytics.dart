import 'package:flutter/material.dart';

class ConversationData {
  Map<String, int> entityEvocationsTotals;
  Map<String, Map<String, int>> entityEvocationsPerRole;
  Map<String, int> entitySummonsTotals;
  Map<String, Map<String, int>> entitySummonsPerRole;
  Map<String, int> emotionsTotals;
  Map<String, Map<String, int>> emotionsPerRole;

  ConversationData({
    required this.entityEvocationsTotals,
    required this.entityEvocationsPerRole,
    required this.entitySummonsTotals,
    required this.entitySummonsPerRole,
    required this.emotionsTotals,
    required this.emotionsPerRole,
  });

  factory ConversationData.fromMap(Map<String, dynamic> data) {
    Map<String, int> castStringIntMap(Map<dynamic, dynamic> map) {
      try {
        return map.map((key, value) => MapEntry(key as String, value as int));
      } catch (e) {
        debugPrint("ERROR CONVERTING:");
        debugPrint(data.toString());
        debugPrint(e.toString());
      }
      return {};
    }

    Map<String, Map<String, int>> castStringMapStringInt(
        Map<dynamic, dynamic> map) {
      try {
        return map.map((key, value) =>
            MapEntry(key as String, castStringIntMap(value as Map)));
      } catch (e) {
        debugPrint("ERROR CONVERTING:");
        debugPrint(data.toString());
        debugPrint(e.toString());
      }
      return {};
    }

    return ConversationData(
      entityEvocationsTotals: data.containsKey('entity_evocations')
          ? castStringIntMap(data['entity_evocations']['totals'])
          : {},
      entityEvocationsPerRole: data.containsKey('entity_evocations')
          ? castStringMapStringInt(data['entity_evocations']['per_role'])
          : {},
      entitySummonsTotals: data['entity_summons']?['totals'] != null
          ? castStringIntMap(data['entity_summons']['totals'])
          : {},
      entitySummonsPerRole: data['entity_summons']?['per_role'] != null
          ? castStringMapStringInt(data['entity_summons']['per_role'])
          : {},
      emotionsTotals: data['emotions27']?['totals'] != null
          ? castStringIntMap(data['emotions27']['totals'])
          : {},
      emotionsPerRole: data['emotions27']?['per_role'] != null
          ? castStringMapStringInt(data['emotions27']['per_role'])
          : {},
    );
  }

  Map<String, int> getTotalEntityEvocations() {
    return entityEvocationsTotals;
  }

  Map<String, int> getUserEntityEvocations(String role) {
    return entityEvocationsPerRole[role] ?? {};
  }

  Map<String, int> getTotalEntitySummons() {
    return entitySummonsTotals;
  }

  Map<String, int> getUserEntitySummons(String role) {
    return entitySummonsPerRole[role] ?? {};
  }

  Map<String, int> getTotalEmotions() {
    return emotionsTotals;
  }

  Map<String, Map<String, int>> getUserEmotions(String role) {
    return emotionsPerRole;
  }
}
