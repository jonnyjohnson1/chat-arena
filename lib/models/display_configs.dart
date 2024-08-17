import 'package:flutter/foundation.dart';

class DisplayConfigData {
  bool showInMessageNER;
  bool calculateInMessageNER;
  bool showModerationTags;
  bool calculateModerationTags;
  bool showSidebarBaseAnalytics;
  bool calcImageGen;
  bool calcMsgMermaidChart;
  bool calcConvMermaidChart;
  bool demoMode;
  APIConfig apiConfig;

  DisplayConfigData({
    this.showInMessageNER = true,
    this.calculateInMessageNER = true,
    this.showModerationTags = true,
    this.calculateModerationTags = true,
    this.showSidebarBaseAnalytics = true,
    this.calcImageGen = false,
    this.calcMsgMermaidChart = false,
    this.calcConvMermaidChart = false,
    this.demoMode = false,
  }) : apiConfig = APIConfig();

  Map<String, bool> toMap() {
    return {
      'showInMessageNER': showInMessageNER,
      'calculateInMessageNER': calculateInMessageNER,
      'showModerationTags': showModerationTags,
      'calculateModerationTags': calculateModerationTags,
      'showSidebarBaseAnalytics': showSidebarBaseAnalytics,
      'calculateImageGen': calcImageGen,
      'calcMsgMermaidChart': calcMsgMermaidChart,
      'calcConvMermaidChart': calcConvMermaidChart,
      'demoMode': demoMode
    };
  }
}

class APIConfig {
  String defaultBackendEndpoint;
  String customBackendEndpoint;
  String defaultP2PChatEndpoint;
  String customP2PChatEndpoint;

  APIConfig(
      {this.defaultBackendEndpoint = "http://0.0.0.0:13341",
      this.customBackendEndpoint = "",
      this.defaultP2PChatEndpoint = "http://127.0.0.1:13394",
      this.customP2PChatEndpoint = ""});

  void setSecure() {
    if (defaultBackendEndpoint.startsWith("http://")) {
      // set backend endpoint
      defaultBackendEndpoint =
          defaultBackendEndpoint.replaceFirst("http://", "https://");
      // set p2p chat endpoint
      defaultP2PChatEndpoint =
          defaultP2PChatEndpoint.replaceFirst("http://", "https://");
    } else if (defaultBackendEndpoint.startsWith("ws://")) {
      // set backend endpoint
      defaultBackendEndpoint =
          defaultBackendEndpoint.replaceFirst("ws://", "wss://");
      // set p2p chat endpoint
      defaultP2PChatEndpoint =
          defaultP2PChatEndpoint.replaceFirst("ws://", "wss://");
    }
  }

  String getDefaultLLMBackend() => customBackendEndpoint.isEmpty
      ? defaultBackendEndpoint
      : customBackendEndpoint;

  String getDefaultMessengerBackend() => customBackendEndpoint.isEmpty
      ? defaultP2PChatEndpoint
      : customP2PChatEndpoint;

  bool isLocalhost() {
    final endpoint = getDefaultLLMBackend();
    final uri = Uri.parse(endpoint);
    return uri.host == "0.0.0.0" ||
        uri.host == "localhost" ||
        uri.host.startsWith("127.") ||
        uri.host.endsWith(".local");
  }
}
