class DebateGame {
  String? topic;

  DebateGame({
    this.topic,
  });
}

class P2PChatGame {
  String? username;
  String? serverHostAddress;
  int? maxParticipants;
  String? sessionID;
  P2PServerInitState? initState;

  P2PChatGame(
      {this.username,
      this.serverHostAddress,
      this.maxParticipants,
      this.sessionID,
      this.initState});

  @override
  String toString() {
    return 'P2PChatGame{username: $username, url: $serverHostAddress}';
  }
}

enum P2PServerInitState { create, join }
