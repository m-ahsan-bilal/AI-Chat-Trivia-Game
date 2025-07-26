import 'package:flutter/foundation.dart';
import '../models/lobby.dart';
import '../services/api_service.dart';

class LobbyProvider with ChangeNotifier {
  List<Lobby> _lobbies = [];
  bool _isLoading = false;
  String? _currentLobbyId;
  final ApiService _apiService = ApiService();

  List<Lobby> get lobbies => _lobbies;
  bool get isLoading => _isLoading;
  String? get currentLobbyId => _currentLobbyId;

  List<String> _bots = [];
  List<String> get bots => _bots;
  bool _triviaActive = false;
  bool get triviaActive => _triviaActive;
  int _messageCount = 0;
  int get messageCount => _messageCount;
  List<String> _users = [];
  List<String> get users => _users;

  ApiService get apiService => _apiService;

  Future<void> loadLobbies() async {
    _isLoading = true;
    notifyListeners();

    _lobbies = await _apiService.getLobbies();
    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> createLobby({
    required String name,
    required int maxHumans,
    int maxBots = 1,
    bool isPrivate = false,
  }) async {
    final result = await _apiService.createLobby(
      name: name,
      maxHumans: maxHumans,
      maxBots: maxBots,
      isPrivate: isPrivate,
    );

    if (result != null) {
      _currentLobbyId = result['lobby_id'];
      await loadLobbies(); // Refresh lobby list
    }

    return result;
  }

  Future<bool> joinLobby(String inviteCode, String userId) async {
    final success = await _apiService.joinLobby(inviteCode, userId);

    if (success) {
      await loadLobbies(); // Refresh lobby list
    }

    return success;
  }

  void setCurrentLobby(String lobbyId) {
    _currentLobbyId = lobbyId;
    notifyListeners();
  }

  Future<void> fetchLobbyInfo(String lobbyId) async {
    final info = await _apiService.getLobbyInfo(lobbyId);
    if (info != null) {
      _bots = List<String>.from(info['bots'] ?? []);
      _triviaActive = info['trivia_active'] ?? false;
      _messageCount = info['message_count'] ?? 0;
      _users = List<String>.from(info['users'] ?? []);
      notifyListeners();
    }
  }

  Future<bool> addBot(String lobbyId, String botName) async {
    final success = await _apiService.addBot(lobbyId, botName);
    if (success) {
      await fetchLobbyInfo(lobbyId);
    }
    return success;
  }

  Future<bool> removeBot(String lobbyId, String botName) async {
    final success = await _apiService.removeBot(lobbyId, botName);
    if (success) {
      await fetchLobbyInfo(lobbyId);
    }
    return success;
  }
}
