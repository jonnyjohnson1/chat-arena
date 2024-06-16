import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class MermaidWidget extends StatefulWidget {
  const MermaidWidget({super.key});

  @override
  State<MermaidWidget> createState() => _MermaidWidgetState();
}

class _MermaidWidgetState extends State<MermaidWidget> {
  late WebViewXController webviewController;
  String mermaidText = """
graph TD
              A[Start] --> B[Step 1]
              B --> C{Decision}
              C -->|Yes| D[Step 2]
              C -->|No| E[End]
              D --> F[End]
""";
  String getHtmlString() => """
<!DOCTYPE html>
  <html lang="en">
  <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Mermaid Chart Example</title>
      <!-- Include Mermaid JS -->
      <script type="module">
          import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.esm.min.mjs';
          mermaid.initialize({ startOnLoad: true });
      </script>
      <style>
        body {
          display: flex;
          justify-content: center;
          align-items: center;
          height: 100vh;
          margin: 0;
          padding: 0;
        }
        .mermaid {
          width: 50vw; /* Adjust width as needed */
          height: auto; /* Maintain aspect ratio */
        }
      </style>
  </head>
  <body>
      <div class="mermaid">
          graph TD
              A[Start] --> B[Step 1]
              B --> C{Decision}
              C -->|Yes| D[Step 2]
              C -->|No| E[End]
              D --> F[End]
      </div>
  </body>
  </html>""";

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
          height: 600,
          child: WebViewX(
            width: 280,
            height: 600,
            initialContent: getHtmlString(),
            initialSourceType: SourceType.html,
            onWebViewCreated: (controller) => webviewController = controller,
          )),
    );
  }
}
