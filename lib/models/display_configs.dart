class DisplayConfigData {
  bool showInMessageNER;
  bool calculateInMessageNER;
  bool showModerationTags;
  bool calculateModerationTags;
  bool showSidebarBaseAnalytics;
  bool calcImageGen;

  DisplayConfigData(
      {this.showInMessageNER = true,
      this.calculateInMessageNER = true,
      this.showModerationTags = true,
      this.calculateModerationTags = true,
      this.showSidebarBaseAnalytics = true,
      this.calcImageGen = false});

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
