import 'dart:math';
import 'package:chat/models/game_models/debate.dart';
import 'package:flutter/material.dart';

Future<P2PChatGame?> joinP2PChat(BuildContext context) async {
  TextEditingController usernameController = TextEditingController();
  TextEditingController urlController = TextEditingController();
  TextEditingController sessionIDController = TextEditingController();
  String? errorMessage;

  P2PChatGame? p2pChatGameSettings;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Enter Chat Details"),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Username field
                  TextField(
                    maxLines: 1,
                    controller: usernameController,
                    decoration:
                        const InputDecoration(hintText: "Enter username"),
                  ),
                  const SizedBox(height: 20),
                  // URL field
                  TextField(
                    maxLines: 1,
                    controller: urlController,
                    decoration: const InputDecoration(hintText: "Enter URL"),
                  ),
                  const SizedBox(height: 20),
                  // Session ID field
                  TextField(
                    maxLines: 1,
                    controller: sessionIDController,
                    decoration:
                        const InputDecoration(hintText: "Enter Session ID"),
                  ),
                  const Divider(
                      height: 40, thickness: 1.5), // Divider between sections
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  if (usernameController.text.isNotEmpty &&
                      urlController.text.isNotEmpty &&
                      sessionIDController.text.isNotEmpty) {
                    Navigator.of(context).pop();
                  } else {
                    setState(() {
                      errorMessage = "All fields are required.";
                    });
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );

  if (usernameController.text.isEmpty ||
      urlController.text.isEmpty ||
      sessionIDController.text.isEmpty) {
    return null;
  }

  String username = usernameController.text.isEmpty
      ? "Anon${generateRandom4Digits()}"
      : usernameController.text;

  debugPrint("\t\t[ Username: $username ]");
  debugPrint("\t\t[ URL: ${urlController.text} ]");
  debugPrint("\t\t[ Session ID: ${sessionIDController.text} ]");

  return P2PChatGame(
    username: username,
    serverHostAddress: urlController.text,
    sessionID: sessionIDController.text,
  );
}

String generateRandom4Digits() {
  var random = Random();
  return (random.nextInt(9000) + 1000).toString(); // Ensures a 4-digit number
}

// class P2PChatGame {
//   final String username;
//   final String url;
//   final String sessionID;

//   P2PChatGame({
//     required this.username,
//     required this.url,
//     required this.sessionID,
//   });

//   @override
//   String toString() {
//     return 'P2PChatGame{username: $username, url: $url, sessionID: $sessionID}';
//   }
// }
