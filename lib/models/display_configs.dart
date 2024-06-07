class DisplayConfigData {
  bool showInMessageNER;
  bool calculateInMessageNER;
  bool showModerationTags;
  bool calculateModerationTags;
  bool showSidebarBaseAnalytics;
  bool calcImageGen;
  APIConfig apiConfig;

  DisplayConfigData({
    this.showInMessageNER = true,
    this.calculateInMessageNER = true,
    this.showModerationTags = true,
    this.calculateModerationTags = true,
    this.showSidebarBaseAnalytics = true,
    this.calcImageGen = false,
  }) : apiConfig = APIConfig();

  Map<String, bool> toMap() {
    return {
      'showInMessageNER': showInMessageNER,
      'calculateInMessageNER': calculateInMessageNER,
      'showModerationTags': showModerationTags,
      'calculateModerationTags': calculateModerationTags,
      'showSidebarBaseAnalytics': showSidebarBaseAnalytics,
      'calculateImageGen': calcImageGen,
    };
  }
}

class APIConfig {
  String defaultEndpoint;
  String customEndpoint;

  APIConfig({
    this.defaultEndpoint = "http://0.0.0.0:13341",
    this.customEndpoint = "",
  });
}
