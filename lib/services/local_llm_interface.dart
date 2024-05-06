import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class LocalLLMInterface {
  String chat_message = "chat";

  bool get isLocal => true;
  String get wsPrefix => isLocal ? 'ws' : 'wss';
  WebSocketChannel? webSocket;

  void initChatWebsocket() {
    String httpAddress = "http://0.0.0.0:13341"; //15
    String extractedDiAPI = httpAddress.split('/').last;
    // Use ws for debugging, and wss for
    webSocket = WebSocketChannel.connect(
        Uri.parse('$wsPrefix://$extractedDiAPI/$chat_message'));
  }

  void newMessage(String message) {
    initChatWebsocket();

    if (webSocket == null) {
      print("You must init the class first to connect to the websocket.");
      return null;
    }

    Map<String, dynamic> submitPkg = {
      "model": 'llama3',
      "message": message,
      "message_history": [],
      "temperature": 0.06
    };

    webSocket!.sink.add(json.encode(submitPkg));
    print("submitted to sink");

    webSocket!.stream.listen(
      (data) {
        // print(data.runtimeType);
        // print(data);
        Map<String, dynamic> decoded = {};
        try {
          decoded = json.decode(data);
        } catch (e) {
          print("Error here");
          print(e);
        }

        print(decoded['status']);
        // decoded['status'] has 4 options
        // started, generating, completed, error
        switch (decoded['status']) {
          case 'started':
            break;
          case 'generating':
            // UPDATE MESSAGES
            print(decoded['response']);

          case 'completed':
            // UPDATE MESSAGES
            print(decoded['response']);
          // !decoded['completed'];
          // decoded['response'];

          case 'error':
            print(decoded['error']);
            print("handle error");
          default:
            break;
        }
      },
      onError: (error) => print(error),
      onDone: () {
        print("WebSocket closed.");
      },
    );
  }
}
