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
  Map<String, String>?
      participants; // random string id (eventually use as userID, but keep anon for now), and the Username

  P2PChatGame(
      {this.username,
      this.serverHostAddress,
      this.maxParticipants,
      this.sessionID,
      this.participants,
      this.initState});

  @override
  String toString() {
    return 'P2PChatGame{username: $username, url: $serverHostAddress}';
  }
}

enum P2PServerInitState { create, join }
