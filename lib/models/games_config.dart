enum CardSize { small, medium, large }

class GamesConfig {
  final String? gameID;
  final String? name;
  final String? slogan;
  final String? longDescription;
  final CardSize? size;

  GamesConfig(
      {this.gameID, this.name, this.slogan, this.longDescription, this.size});

  factory GamesConfig.fromJson(Map<String, dynamic> json) {
    CardSize size = CardSize.small;
    if (json['size'] == "small") {
      size = CardSize.small;
    } else if (json['size'] == "medium") {
      size = CardSize.medium;
    } else if (json['size'] == "large") {
      size = CardSize.large;
    }
    return GamesConfig(
        gameID: json['game'] as String,
        name: json['name'] as String,
        size: size,
        slogan: json['slogan'] as String,
        longDescription: json['long-description'] as String);
  }

  GamesConfig fromMap(Map<String, dynamic> map) {
    CardSize size = CardSize.small;
    if (map['size'] == "small") {
      size = CardSize.small;
    } else if (map['size'] == "medium") {
      size = CardSize.medium;
    } else if (map['size'] == "large") {
      size = CardSize.large;
    }
    return GamesConfig(
      gameID: map['game'] ?? '',
      name: map['name'] ?? '',
      size: size,
      slogan: map['slogan'] as String,
      longDescription: map['long-description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'game': gameID,
      'name': name,
      'long-description': longDescription,
    };
  }
}
