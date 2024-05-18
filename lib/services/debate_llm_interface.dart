// local_llm_interface.dart

import 'dart:convert';

import 'package:chat/models/llm.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';

import '../models/messages.dart';

class DebateLLMInterface {
  String chatEndpoint = "websocket_debate";

  bool get isLocal => true;
  String get wsPrefix => isLocal ? 'ws' : 'wss';
  WebSocketChannel? webSocket;

  void initChatWebsocket() {
    String httpAddress = "http://0.0.0.0:13341"; //15
    String extractedDiAPI = httpAddress.split('/').last;
    // Use ws for debugging, and wss for
    webSocket = WebSocketChannel.connect(
        Uri.parse('$wsPrefix://$extractedDiAPI/$chatEndpoint'));
  }

  void newDebateMessage(String message, String debateTopic,
      List<Message> messageHistory, ModelConfig model, callbackFunction) {
    initChatWebsocket();

    if (webSocket == null) {
      print("You must init the class first to connect to the websocket.");
      return;
    }

    // Format messageHistory for json
    List<Map<String, dynamic>> msgHist = [];
    for (Message msg in messageHistory) {
      if (msg.images != null) {
        if (msg.images!.isNotEmpty) {
          List<String> images = [];
          for (var file in msg.images!) {
            // if we have used the web, the local path should still exist
            // the web path is used to render the web image
            String path = file.localFile!.path;
            // if (file.path.startsWith("blob:")) {
            //   path = path.substring(5);
            // }
            images.add(path);
          }
          msgHist.add({
            'role': msg.senderID!.isEmpty ? "user" : msg.senderID!,
            'content': msg.message!.value,
            'images': images,
          });
        } else {
          msgHist.add({
            'role': msg.senderID!.isEmpty ? "user" : msg.senderID!,
            'content': msg.message!.value
          });
        }
      } else {
        msgHist.add({
          'role': msg.senderID!.isEmpty ? "user" : msg.senderID!,
          'content': msg.message!.value
        });
      }
    }

    Map<String, dynamic> chatInitializePackage = {
      "model": model.model.model,
      "topic": debateTopic,
      "message": message,
      "message_history": msgHist,
      "temperature": 0.06
    };

    webSocket!.sink.add(json.encode(chatInitializePackage));
    debugPrint("\t\t[ Submitted package to websocket sink ]");

    double toksPerSec = 0;
    List<String> toksStr = [];
    bool isStarted = false;
    DateTime? startTime;

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

        // print(decoded['status']);
        // decoded['status'] has 4 options
        // started, generating, completed, error
        switch (decoded['status']) {
          case 'started':
            break;
          case 'generating':
            if (!isStarted) {
              isStarted = true;
              startTime = DateTime.now();
            }

            // UPDATE MESSAGES
            toksStr.add(decoded['response']);
            int duration = DateTime.now().difference(startTime!).inMilliseconds;
            double durInSeconds = duration / 1000;

            if (duration != 0) {
              toksPerSec = toksStr.length / durInSeconds;
            }
            decoded['completionTime'] =
                durInSeconds; // completion time in seconds
            decoded['toksPerSec'] = toksPerSec;
            callbackFunction(decoded);

          case 'completed':
            // UPDATE MESSAGES
            // print(decoded['response']);
            toksStr.add(decoded['response']);
            int duration = DateTime.now().difference(startTime!).inMilliseconds;
            double durInSeconds = duration / 1000;

            toksPerSec = toksStr.length / durInSeconds;

            decoded['toksPerSec'] = toksPerSec;
            decoded['completionTime'] =
                durInSeconds; // completion time in seconds
            callbackFunction(decoded);

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
