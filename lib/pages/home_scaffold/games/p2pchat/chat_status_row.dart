import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatStatusRow extends StatelessWidget {
  String sessionId;
  final bool isConnected;
  final int userCount;
  final VoidCallback onReconnect;
  final VoidCallback onStartChat;

  ChatStatusRow({
    super.key,
    this.sessionId = "",
    required this.isConnected,
    required this.userCount,
    required this.onReconnect,
    required this.onStartChat,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Start Chat Button
          if (isConnected)
            InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: sessionId));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Session ID copied to clipboard")),
                );
              },
              child: Row(
                children: [
                  const Text("Session ID: "),
                  Text(
                    sessionId,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          if (!isConnected) // start available if not connected
            ElevatedButton(
              onPressed: onStartChat,
              child: const Row(
                children: [
                  Icon(
                    Icons.chat,
                    size: 20,
                  ),
                  SizedBox(width: 4),
                  Text('Connect Chat'),
                ],
              ),
            ),
          Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(30))),
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Activity Indicator for Connection Status
                Tooltip(
                  message: isConnected ? "Connected" : "Disconnected",
                  preferBelow: false,
                  child: Icon(isConnected ? Icons.check_circle : Icons.error,
                      color: isConnected ? Colors.green : Colors.red, size: 16),
                ),
                const SizedBox(width: 2),
                // Reconnect Button
                if (!isConnected)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 14),
                        onPressed: onReconnect,
                      ),
                      const SizedBox(width: 2),
                    ],
                  ),
                const SizedBox(width: 8),
                // User Count
                Tooltip(
                  message: "Active Participants",
                  preferBelow: false,
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.group, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '$userCount',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(width: 6),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
