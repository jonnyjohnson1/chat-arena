import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DeployedConfig {
  final bool cloudHosted;
  final bool usePreloadedLlmBackend;
  final bool usePreloadedMessengerBackend;
  final String defaultProvider;
  final String defaultBackend;
  final String defaultChatClient;

  DeployedConfig({
    required this.cloudHosted,
    required this.usePreloadedLlmBackend,
    required this.usePreloadedMessengerBackend,
    required this.defaultProvider,
    required this.defaultBackend,
    required this.defaultChatClient,
  });

  factory DeployedConfig.init() {
    return DeployedConfig(
      cloudHosted: false,
      usePreloadedLlmBackend: false,
      usePreloadedMessengerBackend: false,
      defaultProvider: "ollama",
      defaultBackend: "https://topos.hypernym.ai",
      defaultChatClient: "https://chat.hypernym.ai",
    );
  }

  factory DeployedConfig.fromJson(Map<String, dynamic> json) {
    return DeployedConfig(
      cloudHosted: json['cloud-hosted'] ?? false,
      usePreloadedLlmBackend: json['use_preloaded_llm_backend'] ?? false,
      usePreloadedMessengerBackend:
          json['use_preloaded_messenger_backend'] ?? false,
      defaultProvider: json['default-provider'] ?? "ollama",
      defaultBackend: json['default-backend'] ?? "https://topos.hypernym.ai",
      defaultChatClient:
          json['default-chat-client'] ?? "https://chat.hypernym.ai",
    );
  }

  static Future<DeployedConfig> loadFromJsonAsset() async {
    final String data =
        await rootBundle.loadString('assets/deploy-config.json');
    print(data);
    final Map<String, dynamic> jsonResult = json.decode(data);
    return DeployedConfig.fromJson(jsonResult);
  }
}
