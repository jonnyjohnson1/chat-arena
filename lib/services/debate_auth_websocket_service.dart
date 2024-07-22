// debate_auth_websocket_service.dart

import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DebateAuthWebSocketService {
  WebSocketChannel? _channel;
  String? _token;
  String? _sessionId;
  String? postBaseUrl;
  String? wsBaseUrl;

  DebateAuthWebSocketService(String _baseUrl) {
      postBaseUrl = "http://$_baseUrl";
      wsBaseUrl = "ws://$_baseUrl";
  }

  Future<bool> adminAddAccounts(Map<String, String> newAccounts) async {
    debugPrint('Adding new accounts');
    if (_token == null) {
      _token = await _getSavedToken();
      if (_token == null) {
        debugPrint('No token found');
        return false;
      }
    }

    final response = await http.post(
      Uri.parse('$postBaseUrl/admin_add_accounts'),
      headers: {'Authorization': 'Bearer $_token'},
      body: newAccounts,
    );

    debugPrint('Add accounts response status code: ${response.statusCode}');
    if (response.statusCode == 200) {
      debugPrint('Accounts added successfully');
      return true;
    }
    debugPrint('Failed to add accounts');
    return false;
  }

  Future<bool> login(String username, String password) async {
    debugPrint('Attempting to log in with username: $username');
    final response = await http.post(
      Uri.parse('$postBaseUrl/token'),
      body: {'username': username, 'password': password},
    );

    debugPrint('Login response status code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _token = data['access_token'];
      debugPrint('Login successful, token: $_token');
      await _saveToken(_token!);
      return true;
    } else if (response.statusCode == 401) {
      // If login fails, try to add the account
      debugPrint('Login failed, attempting to add account');
      bool accountAdded = await tempForceAccount(username, password);
      if (accountAdded) {
        // If account was added successfully, try logging in again
        return await login(username, password);
      }
    }
    debugPrint('Login failed');
    return false;
  }

  Future<bool> tempForceAccount(String username, String password) async {
    debugPrint('Force adding new account');
    final response = await http.post(
      Uri.parse('$postBaseUrl/admin_add_accounts'),
      body: {username: password},
    );

    debugPrint('Add account response status code: ${response.statusCode}');
    if (response.statusCode == 200) {
      debugPrint('Account added successfully');
      return true;
    }
    debugPrint('Failed to add account');
    return false;
  }

  Future<void> _saveToken(String token) async {
    debugPrint('Saving token to shared preferences');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('debate_token', token);
  }

  Future<String?> _getSavedToken() async {
    debugPrint('Retrieving token from shared preferences');
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('debate_token');
  }

  Future<bool> createOrJoinSession() async {
    debugPrint('Creating or joining session');
    if (_token == null) {
      _token = await _getSavedToken();
      if (_token == null) {
        debugPrint('No token found');
        return false;
      }
    }

    final response = await http.post(
      Uri.parse('$postBaseUrl/create_session'),
      headers: {'Authorization': 'Bearer $_token'},
    );

    debugPrint('Create session response status code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _sessionId = data['session_id'];
      debugPrint('Session created/joined successfully, session ID: $_sessionId');
      return true;
    }
    debugPrint('Failed to create/join session');
    return false;
  }

  Future<bool> connectWebSocket() async {
    debugPrint('Connecting to WebSocket');
    if (_token == null || _sessionId == null) {
      debugPrint('Token or session ID is null');
      return false;
    }

    final wsUrl = Uri.parse('$wsBaseUrl/ws?token=$_token&session_id=$_sessionId');
    try {
      _channel = WebSocketChannel.connect(wsUrl);
      debugPrint('WebSocket connected');
      return true;
    } catch (e) {
      debugPrint('WebSocket connection failed: $e');
      return false;
    }
  }

  void sendMessage(String message, String userId) {
    debugPrint('Sending message: $message');
    if (_channel != null) {
      _channel!.sink.add(json.encode({
        'message': message,
        'user_id': userId,
        'generation_nonce': DateTime.now().millisecondsSinceEpoch.toString(),
      }));
      debugPrint('Message sent');
    } else {
      debugPrint('WebSocket channel is null, message not sent');
    }
  }

  Stream get messages => _channel!.stream;

  void close() {
    debugPrint('Closing WebSocket connection');
    _channel?.sink.close();
  }
}
