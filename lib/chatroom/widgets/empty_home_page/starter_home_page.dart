import 'package:flutter/material.dart';

class StarterHomePage extends StatelessWidget {
  final String profileImageUrl;

  StarterHomePage({
    required this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Profile Picture at the Top Center
            CircleAvatar(
              radius: MediaQuery.of(context).size.height / 10, // Adjust size for mobile
              backgroundImage: NetworkImage(profileImageUrl),
            ),
            const SizedBox(height: 20),
            // Safety Message with specific parts in bold and line breaks
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.grey[700], // Dark grey color
                    fontSize: 12.8, // Reduced font size (16 * 0.8)
                  ),
                  children: [
                    // First Line
                    TextSpan(
                      text: "We value",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: " your time."),
                    TextSpan(text: "\n\n"), // Line Break

                    // Second Line
                    TextSpan(
                      text: "We read",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: " the logs of your interactions here with "),
                    TextSpan(
                      text: "care and respect",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ","),
                    TextSpan(text: "\n\n"), // Line Break

                    // Third Line
                    TextSpan(
                      text: "We do not train",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: " on this data or pass your data to any providers that train on your conversation here."),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
