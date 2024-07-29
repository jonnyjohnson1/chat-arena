import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class LobbyPage extends StatefulWidget {
  @override
  _LobbyPageState createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  WebSocketChannel? _channel;
  String _serverAddress = "ws://0.0.0.0:8000/ws";
  bool _connected = false;
  List<String> _availableSessions = [];

  @override
  void initState() {
    super.initState();
    _connectToLobbyServer();
  }

  void _connectToLobbyServer() {
    _channel = WebSocketChannel.connect(Uri.parse(_serverAddress));
    _channel!.stream.listen((message) {
      _handleServerMessage(jsonDecode(message));
    });
    setState(() {
      _connected = true;
    });
    print("\t[ LobbyPage :: initState ]");
  }

  void _handleServerMessage(Map<String, dynamic> message) {
    print("\t[ Received message: ${message['type']} ]");
    if (message['type'] == "AvailableSessions") {
      setState(() {
        _availableSessions = List<String>.from(message['data']['sessions'].map((session) => session['name']));
      });
      print("\t\t[ Available Sessions: ${message['data']['sessions']} ]");
    } else if (message['type'] == "SessionJoined") {
      print("\t\t[ Session Joined: ${message['data']['session_id']} ]");
    } else if (message['type'] == "SessionHosted") {
      print("\t\t[ Session Hosted ]");
    }
  }

  void _hostSession(String gameType) {
    _sendMessage("HostSession", {"game_type": gameType});
  }

  void _joinSession(String sessionId) {
    _sendMessage("JoinSession", {"session_id": sessionId});
  }

  void _sendMessage(String type, Map<String, dynamic> data) {
    final message = jsonEncode({"type": type, "data": data});
    _channel!.sink.add(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Game Lobby"),
      ),
      body: _connected
          ? Column(
        children: [
          ElevatedButton(
            onPressed: () => _hostSession("chess"),
            child: Text("Host Chess Game"),
          ),
          ElevatedButton(
            onPressed: () => _hostSession("debate"),
            child: Text("Host Debate Game"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _availableSessions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_availableSessions[index]),
                  onTap: () => _joinSession(_availableSessions[index]),
                );
              },
            ),
          ),
        ],
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  void dispose() {
    _channel?.sink.close(status.goingAway);
    super.dispose();
  }
}
