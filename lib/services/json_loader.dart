import 'dart:convert';
import 'package:flutter/services.dart';

Future<dynamic> loadJson() async {
  String data = await rootBundle.loadString('assets/app-config.json');
  dynamic jsonResult = json.decode(data);
  return jsonResult;
}

Map<String, Map<String, dynamic>> unpackModels(Map<String, dynamic> inputDict) {
  List<dynamic> modelsList = inputDict['models-list'];
  Map<String, Map<String, dynamic>> resultDict = {};

  for (var model in modelsList) {
    String localID = model['localID'];
    Map<String, dynamic> modelMap = Map.from(model);
    resultDict[localID] = modelMap;
  }
  return resultDict;
}

Future<dynamic> loadSteeringJson() async {
  String data = await rootBundle.loadString('assets/steering-suggestions.json');
  dynamic jsonResult = json.decode(data);
  return jsonResult;
}
