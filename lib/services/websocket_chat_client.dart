import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:http/http.dart' as http;

class WebSocketChatClient {
  String url;
  WebSocketChannel? channel;

  WebSocketChatClient({required this.url});

  void connect(Map<String, dynamic> initData, Function listenerCallback,
      Function websocketDone, Function websocketError) {
    String path = "/ws/chat";
    channel = WebSocketChannel.connect(Uri.parse(url + path));
    channel!.sink.add(json.encode(initData));

    channel!.stream.listen((message) {
      dynamic decoded = jsonDecode(message);
      listenerCallback(decoded);
    }, onDone: () {
      String message = 'WebSocket connection closed.';
      print(message);
      websocketDone(message);
    }, onError: (error) {
      String message = 'Error: $error';
      print(message);
      websocketError(message);
    });
  }

  void sendMessage(Map<String, dynamic> message) {
    if (channel != null) {
      channel!.sink.add(json.encode(message));
    } else {
      print('WebSocket is not connected.');
    }
  }

  void disconnect() {
    if (channel != null) {
      channel!.sink.close(status.goingAway);
      channel = null;
    }
  }

  Future<bool> testEndpoint() async {
    // local endpoint: http://127.0.0.1:13349
    try {
      final url =
          Uri.parse("${this.url}/test"); // Replace with your server address
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['response'] == true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
