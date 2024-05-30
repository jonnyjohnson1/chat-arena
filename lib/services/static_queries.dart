import 'dart:io';

import 'package:chat/models/display_configs.dart';
import 'package:chat/models/llm.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

bool isLocal = true;
String get getUrlStart => isLocal ? "http://" : "https://";

Future<List<LanguageModel>?> getModels(APIConfig apiConfig) async {
  final urlPattern = r'^(http|https):\/\/[^\s/$.?#].[^\s]*$';
  final regExp = RegExp(urlPattern);
  String httpAddress = "";
  String baseUrl = apiConfig.customEndpoint.isEmpty
      ? apiConfig.defaultEndpoint
      : apiConfig.customEndpoint;

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
