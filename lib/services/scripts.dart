import 'dart:convert';

import 'package:chat/models/scripts.dart';
import 'package:flutter/services.dart';

Future<Scripts> loadScriptsJson(String? uid) async {
  final String response = await rootBundle.loadString('assets/scripts.json');
  final jsonResult = json.decode(response);
  print(jsonResult);
  return Scripts.fromJson(jsonResult, uid);
}

// Future<Scripts> getScripts(Scripts scripts, {String type = "demo"}) async {
//   scripts.demos
//   return List<>;
// }
