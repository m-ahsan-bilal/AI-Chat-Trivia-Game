class Lobby {
  final String lobbyId;
  final String name;
  final int currentPlayers;
  final int maxHumans;
  final int currentBots;
  final int maxBots;
  final bool isPrivate;
  final bool hasTriviaActive;
  final int messageCount;

  Lobby({
    required this.lobbyId,
    required this.name,
    required this.currentPlayers,
    required this.maxHumans,
    required this.currentBots,
    required this.maxBots,
    required this.isPrivate,
    required this.hasTriviaActive,
    required this.messageCount,
  });

  factory Lobby.fromJson(Map<String, dynamic> json) {
    return Lobby(
      lobbyId: json['lobby_id'] ?? '',
      name: json['name'] ?? '',
      currentPlayers: json['current_players'] ?? 0,
      maxHumans: json['max_humans'] ?? 0,
      currentBots: json['current_bots'] ?? 0,
      maxBots: json['max_bots'] ?? 0,
      isPrivate: json['is_private'] ?? false,
      hasTriviaActive: json['has_trivia_active'] ?? false,
      messageCount: json['message_count'] ?? 0,
    );
  }
}
