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
  String defaultEndpoint;
  String customEndpoint;

  //@note:@hypercard:@setup:
  APIConfig({
    this.defaultEndpoint =
        kIsWeb ? "https://nicktopos.hypernym.ai:8000" : "http://nicktopos.hypernym.ai:8000",
    // this.defaultEndpoint =
    //   kIsWeb ? "http://0.0.0.0:13341" : "http://0.0.0.0:13341",
    this.customEndpoint = "",
  });

  String getDefault() =>
      customEndpoint.isEmpty ? defaultEndpoint : customEndpoint;

  bool isLocalhost() {
    final endpoint = getDefault();
    final uri = Uri.parse(endpoint);
    return uri.host == "0.0.0.0" ||
        uri.host == "localhost" ||
        uri.host.startsWith("127.") ||
        uri.host.endsWith(".local");
  }
}
