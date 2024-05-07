class GamesConfig {
  final String? gameID;
  final String? name;
  final String? description;

  GamesConfig({this.gameID, this.name, this.description});

  factory GamesConfig.fromJson(Map<String, dynamic> json) {
    return GamesConfig(
        gameID: json['game'] as String,
        name: json['name'] as String,
        description: json['description'] as String);
  }

  GamesConfig fromMap(Map<String, dynamic> map) {
    return GamesConfig(
        gameID: map['game'] ?? '',
        name: map['name'] ?? '',
        description: map['description'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'game': gameID,
      'name': name,
      'description': description,
    };
  }
}
