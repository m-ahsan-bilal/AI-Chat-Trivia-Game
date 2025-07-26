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
  final String inviteCode;
  final List<String> users;
  final List<String> bots;
  final String? createdAt;

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
    required this.inviteCode,
    required this.users,
    required this.bots,
    this.createdAt,
    required bool triviaActive,
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
      inviteCode: json['invite_code'] ?? '',
      users: List<String>.from(json['users'] ?? []),
      bots: List<String>.from(json['bots'] ?? []),
      createdAt: json['created_at'],
      triviaActive: json['trivia_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lobby_id': lobbyId,
      'name': name,
      'current_players': currentPlayers,
      'max_humans': maxHumans,
      'current_bots': currentBots,
      'max_bots': maxBots,
      'is_private': isPrivate,
      'has_trivia_active': hasTriviaActive,
      'message_count': messageCount,
      'invite_code': inviteCode,
      'users': users,
      'bots': bots,
      'created_at': createdAt,
    };
  }
}
