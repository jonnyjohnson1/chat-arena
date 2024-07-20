import 'dart:async';
import 'dart:convert';
import 'package:chat/models/display_configs.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InstallerService {
  bool pythonInstalled; // python
  bool backendConnected; // frontend is connected to the backend Endpoint
  bool backendInstalled; // the topos-cli
  APIConfig apiConfig;
  InstallerService({
    required this.apiConfig,
    this.backendConnected = false,
    this.backendInstalled = false,
    this.pythonInstalled = false,
  });

  Future<void> initEnvironment() async {
    print("Checking backend connection...");
    backendConnected = await checkBackendConnected();
    print("Checking python installation...");
  }

  Future<bool> checkBackendConnected() async {
    try {
      final response =
          await http.get(Uri.parse('${apiConfig.getDefault()}/health'));
      return response.statusCode == 200;
    } catch (e) {
      print("Error checking backend connection: $e");
      return false;
    }
  }

  Future<bool> checkBackendInstalled() async {
    // Implement the actual check logic for backend installation
    // For demonstration, we assume the backend installation check is true
    return true;
  }

  bool isBackendFullyInstalled() {
    return backendInstalled && pythonInstalled;
  }
}
