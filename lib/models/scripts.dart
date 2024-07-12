// import 'dart:convert';
// import 'package:flutter/services.dart' show rootBundle;

import 'package:chat/models/conversation.dart';

class Scripts {
  final List<Script> demos;

  Scripts({required this.demos});

  factory Scripts.fromJson(Map<String, dynamic> json, String? uid) {
    var demosList = json['demos'] as List;
    List<Script> demos =
        demosList.map((demo) => Script.fromJson(demo, uid)).toList();

    return Scripts(demos: demos);
  }
}

enum ScriptType { demo, play, therapy }

class Script {
  final String author;
  final String name;
  final int numPlayers;
  final List<GameType> type;
  final List<ScriptContent> script;
  final ScriptType scriptType;
  final String startingRole;

  Script(
      {required this.author,
      required this.name,
      required this.numPlayers,
      required this.type,
      required this.script,
      required this.scriptType,
      required this.startingRole});

  factory Script.fromJson(Map<String, dynamic> json, String? uid) {
    var typeList = json['type'] as List;
    List<GameType> gameTypes = typeList
        .map((type) => GameType.values
            .firstWhere((e) => e.toString() == 'GameType.' + type))
        .toList();

    var scriptList = json['script'] as List;
    String startingRole = json['starting_role'] as String;
    List<ScriptContent> scriptContents =
        scriptList.map((script) => ScriptContent.fromJson(script)).toList();

    scriptContents.forEach((element) {
      print(element.data.userId == startingRole);
      if (element.data.userId == startingRole && uid != null) {
        element.data.userId = uid;
      }
      print(element.data.content);
      print(element.data.userId);
      print(element.role);
    });

    return Script(
        author: json['author'],
        name: json['name'],
        numPlayers: json['num_players'],
        type: gameTypes,
        script: scriptContents,
        scriptType: ScriptType.demo,
        startingRole: json['starting_role']);
  }
}

class ScriptContent {
  final String role;
  final ScriptData data;

  ScriptContent({required this.role, required this.data});

  factory ScriptContent.fromJson(Map<String, dynamic> json) {
    return ScriptContent(
      role: json['role'],
      data: ScriptData.fromJson(json['data']),
    );
  }
}

class ScriptData {
  String userId;
  final String content;

  ScriptData({required this.userId, required this.content});

  factory ScriptData.fromJson(Map<String, dynamic> json) {
    return ScriptData(
      userId: json['user_id'],
      content: json['content'],
    );
  }
}
