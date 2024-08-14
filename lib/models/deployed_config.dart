import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DeployedConfig {
  final bool cloudHosted;
  final String defaultProvider;

  DeployedConfig({
    required this.cloudHosted,
    required this.defaultProvider,
  });

  factory DeployedConfig.init() {
    return DeployedConfig(
      cloudHosted: false,
      defaultProvider: "ollama",
    );
  }

  factory DeployedConfig.fromJson(Map<String, dynamic> json) {
    return DeployedConfig(
      cloudHosted: json['cloud-hosted'] ?? false,
      defaultProvider: json['default-provider'] ?? "ollama",
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
