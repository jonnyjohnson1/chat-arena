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

  P2PChatGame({this.username, this.serverHostAddress, this.maxParticipants});
}

enum P2PMessage { user, ai, server }
