// debate_data.dart
class DebateData {
  Map<String, dynamic> initialClusters = {};
  Map<String, dynamic> updatedClusters = {};
  Map<String, dynamic> wepccResults = {};
  Map<String, dynamic> aggregatedScores = {};
  Map<String, List<List<dynamic>>> addressedClusters = {};
  Map<String, List<List<dynamic>>> unaddressedClusters = {};
  List<dynamic> results = [];
  String mermaidChartData = "";

  void reset() {
    initialClusters = {};
    updatedClusters = {};
    wepccResults = {};
    aggregatedScores = {};
    addressedClusters = {};
    unaddressedClusters = {};
    results = [];
    mermaidChartData = "";
  }
}