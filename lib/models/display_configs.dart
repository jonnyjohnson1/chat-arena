class DisplayConfigData {
  bool showInMessageNER;
  bool calculateInMessageNER;
  bool showModerationTags;
  bool calculateModerationTags;
  bool showSidebarBaseAnalytics;

  DisplayConfigData({
    this.showInMessageNER = true,
    this.calculateInMessageNER = true,
    this.showModerationTags = true,
    this.calculateModerationTags = true,
    this.showSidebarBaseAnalytics = true,
  });
}
