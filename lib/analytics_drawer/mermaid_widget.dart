import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class MermaidWidget extends StatefulWidget {
  final String mermaidText;
  final double? width;
  final double? height;
  final bool alignTop;

  const MermaidWidget({
    required this.mermaidText,
    this.width,
    this.height,
    this.alignTop = true,
    super.key,
  });

  @override
  State<MermaidWidget> createState() => _MermaidWidgetState();
}

class _MermaidWidgetState extends State<MermaidWidget> {
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return WebViewMermaid(
        mermaidText: widget.mermaidText,
        width: widget.width,
        height: widget.height,
      );
    } else if (Platform.isMacOS || Platform.isWindows) {
      return Container();
    } else if (Platform.isIOS || Platform.isAndroid) {
      return WebViewMermaid(
        mermaidText: widget.mermaidText,
        width: widget.width,
        height: widget.height,
      );
    }
    return Container();
  }
}

class WebViewMermaid extends StatelessWidget {
  final String mermaidText;
  final double? width;
  final double? height;
  final bool alignTop;

  WebViewMermaid({
    required this.mermaidText,
    this.width,
    this.height,
    this.alignTop = true,
    super.key,
  });

  String getHtmlString(String mermaidChart) => """
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
            align-items: ${alignTop ? 'flex-start' : 'center'}center; /* flex-start; /* Align content to the top */
            height: 100vh;
            margin: 0;
            padding: 0;
        }
        .mermaid {
            width: 50vw; /* Adjust width as needed */
            height: auto; /* Maintain aspect ratio */
            margin-top: 20px; /* Add some space from the top if needed */
        }
    </style>
</head>
<body>
    <div class="mermaid">
        $mermaidChart
    </div>
</body>
</html>
""";

  late WebViewXController webviewController;

  String extractMermaidContent(String text) {
    // Define the start and end delimiters
    String startDelimiter = '```mermaid';
    String endDelimiter = '```';

    // Find the start and end indices
    int startIndex = text.indexOf(startDelimiter);
    int endIndex = text.lastIndexOf(endDelimiter);

    // Check if both delimiters exist
    if (startIndex != -1 && endIndex != -1 && startIndex < endIndex) {
      // Extract the content between the delimiters
      return text
          .substring(startIndex + startDelimiter.length, endIndex)
          .trim();
    }

    // Return an empty string if delimiters are not found or invalid
    return '';
  }

  String sampleMermaidText = """```mermaid
graph TD;
    Chess --> |is_a| Game;
    Checkers --> |is_a| Game;
    Chess --> |better_than| Checkers;
```""";

  @override
  Widget build(BuildContext context) {
    String simpleText = mermaidText.isEmpty
        ? extractMermaidContent(sampleMermaidText)
        : extractMermaidContent(mermaidText);

    return WebViewX(
      width: width ?? MediaQuery.of(context).size.width, // ?? double.infinity,
      height:
          height ?? MediaQuery.of(context).size.height, // ?? double.infinity,
      ignoreAllGestures: true,
      initialContent: getHtmlString(simpleText),
      initialSourceType: SourceType.html,
      onWebViewCreated: (controller) => webviewController = controller,
    );
  }
}
