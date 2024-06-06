import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketChatClient {
  final String url;
  WebSocketChannel? channel;

  WebSocketChatClient({required this.url});

  void connect(String username, Function listenerCallback,
      Function websocketDone, Function websocketError) {
    channel = WebSocketChannel.connect(Uri.parse(url));
    channel!.sink.add(username);

    channel!.stream.listen((message) {
      listenerCallback(message);
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

  void sendMessage(String message) {
    if (channel != null) {
      channel!.sink.add(message);
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
