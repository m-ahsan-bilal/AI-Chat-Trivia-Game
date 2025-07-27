// lib/core/models/lobby.dart
class Lobby {
  final String lobbyId;
  final String name;
  final int currentPlayers;
  final int activePlayerCount;
  final int maxHumans;
  final int currentBots;
  final int maxBots;
  final bool isPrivate;
  final bool hasTriviaActive;
  final int messageCount;
  final String inviteCode;
  final List<String> users;
  final List<String> activeUsers;
  final List<LobbyBot> bots;
  final String? createdAt;
  final String? lastActivity;
  final String status;
  final String? creator;
  final Map<String, dynamic>? aiAvailable;

  Lobby({
    required this.lobbyId,
    required this.name,
    required this.currentPlayers,
    required this.activePlayerCount,
    required this.maxHumans,
    required this.currentBots,
    required this.maxBots,
    required this.isPrivate,
    required this.hasTriviaActive,
    required this.messageCount,
    required this.inviteCode,
    required this.users,
    required this.activeUsers,
    required this.bots,
    this.createdAt,
    this.lastActivity,
    required this.status,
    this.creator,
    this.aiAvailable,
  });

  factory Lobby.fromJson(Map<String, dynamic> json) {
    List<LobbyBot> botList = [];
    if (json['bots'] != null) {
      if (json['bots'] is List<String>) {
        // Handle simple string list (old format)
        botList = (json['bots'] as List<String>)
            .map((name) => LobbyBot(name: name))
            .toList();
      } else if (json['bots'] is List) {
        // Handle detailed bot objects (new format)
        botList = (json['bots'] as List)
            .map((bot) => LobbyBot.fromJson(bot))
            .toList();
      }
    }

    return Lobby(
      lobbyId: json['lobby_id'] ?? '',
      name: json['name'] ?? '',
      currentPlayers: json['current_players'] ?? 0,
      activePlayerCount:
          json['active_players'] ?? json['active_user_count'] ?? 0,
      maxHumans: json['max_humans'] ?? 0,
      currentBots: json['current_bots'] ?? 0,
      maxBots: json['max_bots'] ?? 0,
      isPrivate: json['is_private'] ?? false,
      hasTriviaActive:
          json['has_trivia_active'] ?? json['trivia_active'] ?? false,
      messageCount: json['message_count'] ?? 0,
      inviteCode: json['invite_code'] ?? '',
      users: List<String>.from(json['users'] ?? []),
      activeUsers: List<String>.from(json['active_users'] ?? []),
      bots: botList,
      createdAt: json['created_at'],
      lastActivity: json['last_activity'],
      status: json['status'] ?? 'waiting',
      creator: json['creator'],
      aiAvailable: json['ai_available'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lobby_id': lobbyId,
      'name': name,
      'current_players': currentPlayers,
      'active_players': activePlayerCount,
      'max_humans': maxHumans,
      'current_bots': currentBots,
      'max_bots': maxBots,
      'is_private': isPrivate,
      'has_trivia_active': hasTriviaActive,
      'message_count': messageCount,
      'invite_code': inviteCode,
      'users': users,
      'active_users': activeUsers,
      'bots': bots.map((bot) => bot.toJson()).toList(),
      'created_at': createdAt,
      'last_activity': lastActivity,
      'status': status,
      'creator': creator,
      'ai_available': aiAvailable,
    };
  }

  // Helper methods
  bool get isActive => status == 'active';
  bool get isFull => currentPlayers >= maxHumans;
  bool get hasActiveBots => bots.isNotEmpty;
  double get fillPercentage => maxHumans > 0 ? currentPlayers / maxHumans : 0.0;

  String get statusDisplay {
    switch (status) {
      case 'active':
        return 'Active';
      case 'waiting':
        return 'Waiting for players';
      default:
        return status;
    }
  }
}

class LobbyBot {
  final String name;
  final String? avatar;
  final String? description;
  final String? personality;

  LobbyBot({
    required this.name,
    this.avatar,
    this.description,
    this.personality,
  });

  factory LobbyBot.fromJson(Map<String, dynamic> json) {
    return LobbyBot(
      name: json['name'] ?? '',
      avatar: json['avatar'],
      description: json['description'],
      personality: json['personality'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'avatar': avatar,
      'description': description,
      'personality': personality,
    };
  }

  String get displayAvatar => avatar ?? '🤖';
}
