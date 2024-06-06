import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketChatClient {
  final String url;
  WebSocketChannel? channel;

  WebSocketChatClient({required this.url});

  void connect(Map<String, dynamic> initData, Function listenerCallback,
      Function websocketDone, Function websocketError) {
    channel = WebSocketChannel.connect(Uri.parse(url));
    channel!.sink.add(json.encode(initData));

    channel!.stream.listen((message) {
      // TODO process any new message coming through the server
      listenerCallback(jsonDecode(message));
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
}
