import 'dart:convert';
import 'package:chat/models/llm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FunctionServices {
  Map<String, FunctionConfig> functions;
  Map<String, FunctionConfig> defaultFunctions;

  FunctionServices._internal({
    required this.functions,
    required this.defaultFunctions,
  });

  static FunctionServices initEmpty() {
    return FunctionServices._internal(
      functions: {},
      defaultFunctions: {},
    );
  }

  static Future<FunctionServices> initialize() async {
    // Load default functions first
    final defaultFunctions = await _loadDefaultFunctionsFromJsonAsset();
    // Try to load from SharedPreferences
    final functions = await _loadFunctionsFromSharedPrefs() ?? defaultFunctions;
    return FunctionServices._internal(
      functions: functions,
      defaultFunctions: defaultFunctions,
    );
  }

  static Future<Map<String, FunctionConfig>>
      _loadDefaultFunctionsFromJsonAsset() async {
    final String jsonString =
        await rootBundle.loadString('assets/functions-config.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    final functions = <String, FunctionConfig>{};

    jsonMap.forEach((key, value) {
      final config = FunctionConfig(
        name: value['name'],
        model: LanguageModel(
          name: value['model'],
          model: value['model'],
        ),
        provider: value['provider'],
      );
      functions[key] = config;
    });

    return functions;
  }

  static Future<Map<String, FunctionConfig>?>
      _loadFunctionsFromSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('functions');
    if (jsonString == null) {
      return null;
    }

    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    print("[ loaded functions config from shared prefs ]");
    // print(jsonMap);
    final functions = jsonMap
        .map((key, value) => MapEntry(key, FunctionConfig.fromJson(value)));

    return functions;
  }

  Future<void> saveToSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final functionsMap =
        functions.map((key, value) => MapEntry(key, value.toJson()));
    // print(functionsMap);
    final jsonString = jsonEncode(functionsMap);
    await prefs.setString('functions', jsonString);
    debugPrint("saved to shared prefs");
  }

  void resetToDefaults() {
    functions = Map<String, FunctionConfig>.from(defaultFunctions);
  }
}

class FunctionConfig {
  String name;
  LanguageModel model;
  String provider;

  FunctionConfig({
    this.name = "dolphin-llama3",
    LanguageModel? model,
    this.provider = "ollama",
  }) : model = model ??
            const LanguageModel(
                name: "dolphin-llama3", model: "dolphin-llama3");

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'model': model.toJson(),
      'provider': provider,
    };
  }

  factory FunctionConfig.fromJson(Map<String, dynamic> json) {
    return FunctionConfig(
      name: json['name'],
      model: LanguageModel.fromJson(json['model']),
      provider: json['provider'],
    );
  }
}
