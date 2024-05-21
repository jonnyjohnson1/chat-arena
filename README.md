<p align="center">
  <img src="https://github.com/jonnyjohnson1/chat-arena/blob/main/ui_screenshot.png" height="350" alt="UI Chat Debates" />
</p>
<p align="center">
  <em>An App to Host Dialogues' Games</em>
</p>


# Dialogues Games

An application to host local games powered by local LLMs:

Current Games:
- Basic chat games.
- Debate (in development)

Multi-modal ability:
1. Vision
Ask questions on your images. Be sure to have a vision model installed. (We use llava:13b).

## Getting Started

1. Run locally
- Install Flutter
- Install ollama

2. For running web or iOS/macOS/android:
  1. follow the commenting instructions in this file: `lib/services/web_specific_queries.dart.`. We need a better way of doing this, but it's the way for now.
