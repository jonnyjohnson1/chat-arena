// local_llm_interface.dart

import 'dart:convert';
import 'dart:io';
import 'package:chat/models/conversation_analytics.dart';
import 'package:chat/models/custom_file.dart';
import 'package:chat/models/display_configs.dart';
import 'package:chat/models/llm.dart';
import 'package:chat/services/tools.dart';
import 'package:chat/shared/image_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

import '../models/messages.dart';

class LocalLLMInterface {
  String chatEndpoint = "websocket_chat";

  bool get isLocal => true;
  String get wsPrefix => isLocal ? 'ws' : 'wss';
  String get getUrlStart => isLocal ? "http://" : "https://";
  WebSocketChannel? webSocket;

  void initChatWebsocket() {
    String httpAddress = "http://0.0.0.0:13341"; //15
    String extractedDiAPI = httpAddress.split('/').last;
    // Use ws for debugging, and wss for
    webSocket = WebSocketChannel.connect(
        Uri.parse('$wsPrefix://$extractedDiAPI/$chatEndpoint'));
  }

  void newChatMessage(
      String message,
      List<Message> messageHistory,
      String conversationId,
      String chatBotMsgId,
      ModelConfig model,
      DisplayConfigData displayConfigData,
      chatCallbackFunction,
      analysisCallBackFunction) {
    initChatWebsocket();

    if (webSocket == null) {
      print("You must init the class first to connect to the websocket.");
      return null;
    }

    // Format messageHistory for json
    List<Map<String, dynamic>> msgHist = [];

    for (Message msg in messageHistory) {
      if (msg.images != null) {
        if (msg.images!.isNotEmpty) {
          try {
            List<String> images = [];
            for (var file in msg.images!) {
              // if we have used the web, the local path should still exist
              // the web path is used to render the web images

              String path = file.localFile!.path;

              // if (file.path.startsWith("blob:")) {
              //   path = path.substring(5);
              // }
              // the local ollama must take the name of the local file path
              images.add(path);
            }
            msgHist.add({
              'role': msg.senderID!.isEmpty ? "user" : msg.senderID!,
              'content': msg.message!.value,
              'images': images,
            });
          } catch (e) {
            debugPrint("[ error parsing image ]");
          }
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

    Map<String, dynamic> submitPkg = {
      "conversation_id": conversationId,
      "message_id": messageHistory.last.id,
      "chatbot_msg_id": chatBotMsgId,
      "model": model.model.model,
      "message": message,
      "message_history": msgHist,
      "temperature": 0.06,
      "processing_config": displayConfigData.toMap()
    };

    webSocket!.sink.add(json.encode(submitPkg));
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
          case 'fetched_user_analysis':
            // First reception of user analytics
            if (decoded.containsKey('user_message')) {
              if (decoded['user_message'].isNotEmpty) {
                analysisCallBackFunction(decoded['user_message'], {});
              }
            }
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
            chatCallbackFunction(decoded);

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
            chatCallbackFunction(decoded);

            // check for bot message analytics
            if (decoded.containsKey('bot_data')) {
              if (decoded['bot_data'].isNotEmpty) {
                // send back to chatroom to handle what to do with the information
                analysisCallBackFunction({}, decoded['bot_data']);
              }
            }

          case 'error':
            print(decoded['error']);
            print("handle error");
          default:
            print("CASE!!!!");
            print(decoded['status']);
            break;
        }
      },
      onError: (error) => print(error),
      onDone: () {
        print("WebSocket closed.");
      },
    );
  }

  Future<ConversationData?> getChatAnalysis(String conversationID) async {
    final uri = getUrlStart + "0.0.0.0:13341/chat_conversation_analysis";
    final url = Uri.parse(uri);
    final headers = {
      "accept": "application/json; charset=utf-8",
      "Content-Type": "application/json; charset=utf-8"
    };
    final body = json.encode({"conversation_id": conversationID});

    try {
      var request = await http.post(url, headers: headers, body: body);
      if (request.statusCode == 200) {
        var data = json.decode(request.body);
        print("CONVERSATION ANALYSIS RETURNS");
        print("_" * 42);
        print(data);
        if (data.containsKey('conversation')) {
          return ConversationData.fromMap(data['conversation']);
        } else {
          return null;
        }
      } else {
        debugPrint(
            'Error: Server responded with status code ${request.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }

  Future<ImageFile?> getConvToImage(String conversationID) async {
    final uri = getUrlStart + "0.0.0.0:13341/chat/conv_to_image";
    final url = Uri.parse(uri);
    final headers = {
      "accept": "application/json; charset=utf-8",
      "Content-Type": "application/json; charset=utf-8"
    };
    final body = json.encode({"conversation_id": conversationID});

    try {
      var request = await http.post(url, headers: headers, body: body);
      if (request.statusCode == 200) {
        var data = json.decode(request.body);
        print("CONV_TO_IMAGE");
        print("_" * 42);
        print(data['file_name']);
        // Create the File object
        File localFile = File(data['file_name']);
        List<int> bytes = convertDynamicListToIntList(data['bytes']);
        // Convert bytes to Uint8List
        Uint8List uint8List = Uint8List.fromList(bytes);
        ImageFile image = ImageFile(
            id: Tools().getRandomString(32),
            description: data['prompt'],
            bytes: bytes,
            isWeb: true,
            webFile: null,
            localFile: localFile);
        return image;
      } else {
        debugPrint(
            'Error: Server responded with status code ${request.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }
}
