import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DeployedConfig {
  final bool cloudHosted;
  final String defaultProvider;
  final String defaultBackend;
  final String defaultChatClient;
  final bool usePreloadedUrls;

  DeployedConfig({
    required this.cloudHosted,
    required this.defaultProvider,
    required this.defaultBackend,
    required this.defaultChatClient,
    required this.usePreloadedUrls,
  });

  factory DeployedConfig.init() {
    return DeployedConfig(
      cloudHosted: false,
      defaultProvider: "ollama",
      defaultBackend: "https://topos.hypernym.ai",
      defaultChatClient: "https://chat.hypernym.ai",
      usePreloadedUrls: false,
    );
  }

  factory DeployedConfig.fromJson(Map<String, dynamic> json) {
    return DeployedConfig(
      cloudHosted: json['cloud-hosted'] ?? false,
      defaultProvider: json['default-provider'] ?? "ollama",
      defaultBackend: json['default-backend'] ?? "https://topos.hypernym.ai",
      defaultChatClient:
          json['default-chat-client'] ?? "https://chat.hypernym.ai",
      usePreloadedUrls: json['use_preloaded_urls'] ?? false,
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
