import 'package:chat/models/display_configs.dart';
import 'package:chat/models/llm.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

bool isLocal = true;
String get getUrlStart => isLocal ? "http://" : "https://";

Future<List<LanguageModel>?> getModels(
  APIConfig apiConfig,
  String? provider,
) async {
  String _provider = provider ?? "ollama";

  if (_provider == "openai") {
    // print(" returning openai Models :: len${apiConfig.openAIModels.length} ");
    return apiConfig.openAIModels;
  } else if (_provider == "groq") {
    // print(" returning openai Models :: len${apiConfig.openAIModels.length} ");
    return apiConfig.groqModels;
  }

  final urlPattern = r'^(http|https):\/\/[^\s/$.?#].[^\s]*$';
  final regExp = RegExp(urlPattern);
  String httpAddress = "";
  String baseUrl = apiConfig.customBackendEndpoint.isEmpty
      ? apiConfig.defaultBackendEndpoint
      : apiConfig.customBackendEndpoint;

  if (regExp.hasMatch(baseUrl)) {
    httpAddress = baseUrl;
  } else {
    print('Invalid URL format: ${baseUrl}');
    // throw ArgumentError('Invalid URL format: ${baseUrl}');
  }

  final uri = "$httpAddress/list_models";
  final url = Uri.parse(uri);
  final headers = {"accept": "application/json"};

  try {
    var request = await http.post(url, headers: headers);
    var data = json.decode(request.body)['result'];
    List<LanguageModel> models = [];
    if (data['models'] != null) {
      for (var option in data['models']) {
        LanguageModel model = LanguageModel.fromJson(option);
        models.add(model);
      }
    }
    return models;
  } catch (e) {
    debugPrint('Error: $e');
    return null;
  }
}

List<LanguageModel>? formatOpenAIModelsJson(Map<String, dynamic> jsonData) {
  try {
    List<LanguageModel> models = [];
    // Iterate over the list of models in the JSON data
    if (jsonData['data'] != null) {
      for (var modelData in jsonData['data']) {
        // Create a LanguageModel using the fromOpenAIJson factory method
        LanguageModel model = LanguageModel.fromOpenAIJson(modelData);
        // Add the model to the list
        models.add(model);
      }
    }
    // Return the list of LanguageModel objects
    return models;
  } catch (e) {
    debugPrint('Error parsing JSON: $e');
    return null;
  }
}

Future<List<LanguageModel>?> getOllamaModels(APIConfig apiConfig) async {
  final urlPattern = r'^(http|https):\/\/[^\s/$.?#].[^\s]*$';
  final regExp = RegExp(urlPattern);
  String httpAddress = "";
  String baseUrl = apiConfig.customBackendEndpoint.isEmpty
      ? apiConfig.defaultBackendEndpoint
      : apiConfig.customBackendEndpoint;

  if (regExp.hasMatch(baseUrl)) {
    httpAddress = baseUrl;
  } else {
    throw ArgumentError('Invalid URL format: ${baseUrl}');
  }

  final uri = "$httpAddress/list_models";
  final url = Uri.parse(uri);
  final headers = {"accept": "application/json"};

  try {
    var request = await http.post(url, headers: headers);
    var data = json.decode(request.body)['result'];
    List<LanguageModel> models = [];
    if (data['models'] != null) {
      for (var option in data['models']) {
        LanguageModel model = LanguageModel.fromJson(option);
        models.add(model);
      }
    }
    return models;
  } catch (e) {
    debugPrint('Error: $e');
    return null;
  }
}

Future<bool> getOpenAIModel(String apiKey) async {
  final url = Uri.parse('https://api.openai.com/v1/models');
  final headers = {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  };

  try {
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final models = data['data'] as List;

      // Extract and return the model IDs
      return true;
    } else {
      print('Failed to fetch models. Response code: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('An error occurred: $e');
    return false;
  }
}
