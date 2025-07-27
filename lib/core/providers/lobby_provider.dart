// lib/core/providers/lobby_provider.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/lobby.dart';
import '../models/bot.dart';
import '../services/api_service.dart';

class LobbyProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State variables
  List<Lobby> _lobbies = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _currentLobbyId;
  String? _lastError;

  // Current lobby details
  Lobby? _currentLobby;
  List<Bot> _availableBots = [];
  Map<String, dynamic>? _serverStats;

  // Auto-refresh timer
  Timer? _refreshTimer;
  static const Duration _refreshInterval = Duration(seconds: 30);

  // Getters
  List<Lobby> get lobbies => List.unmodifiable(_lobbies);
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get currentLobbyId => _currentLobbyId;
  String? get lastError => _lastError;
  Lobby? get currentLobby => _currentLobby;
  List<Bot> get availableBots => List.unmodifiable(_availableBots);
  Map<String, dynamic>? get serverStats => _serverStats;
  bool get hasError => _lastError != null;

  // Filtered lobbies
  List<Lobby> get activeLobbies =>
      _lobbies.where((lobby) => lobby.isActive).toList();
  List<Lobby> get waitingLobbies =>
      _lobbies.where((lobby) => !lobby.isActive).toList();
  List<Lobby> get publicLobbies =>
      _lobbies.where((lobby) => !lobby.isPrivate).toList();
  List<Lobby> get privateLobbies =>
      _lobbies.where((lobby) => lobby.isPrivate).toList();
  List<Lobby> get availableLobbies =>
      _lobbies.where((lobby) => !lobby.isFull).toList();

  LobbyProvider() {
    _startAutoRefresh();
    loadLobbies(); // Initial load
    loadAvailableBots(); // Load available bots
  }

  /// Start auto-refresh timer
  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      if (!_isLoading) {
        refreshLobbies();
      }
    });
  }

  /// Stop auto-refresh timer
  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Load lobbies from API
  Future<void> loadLobbies() async {
    if (_isLoading) return;

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final response = await _apiService.getLobbies();
      final List<dynamic> lobbiesData = response['lobbies'] ?? [];

      _lobbies = lobbiesData.map((json) => Lobby.fromJson(json)).toList();

      // Sort lobbies: active first, then by player count
      _lobbies.sort((a, b) {
        if (a.isActive && !b.isActive) return -1;
        if (!a.isActive && b.isActive) return 1;
        return b.activePlayerCount.compareTo(a.activePlayerCount);
      });
    } catch (e) {
      _lastError = 'Failed to load lobbies: $e';
      debugPrint('Error loading lobbies: $e');
      _lobbies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh lobbies (background update)
  Future<void> refreshLobbies() async {
    if (_isLoading || _isRefreshing) return;

    _isRefreshing = true;
    notifyListeners();

    try {
      final response = await _apiService.getLobbies();
      final List<dynamic> lobbiesData = response['lobbies'] ?? [];

      _lobbies = lobbiesData.map((json) => Lobby.fromJson(json)).toList();

      // Sort lobbies
      _lobbies.sort((a, b) {
        if (a.isActive && !b.isActive) return -1;
        if (!a.isActive && b.isActive) return 1;
        return b.activePlayerCount.compareTo(a.activePlayerCount);
      });

      _lastError = null;
    } catch (e) {
      // Don't show error for background refresh failures
      debugPrint('Background refresh error: $e');
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Create a new lobby
  Future<Lobby?> createLobby({
    required String name,
    required int maxHumans,
    int maxBots = 2,
    bool isPrivate = false,
  }) async {
    _lastError = null;

    try {
      final result = await _apiService.createLobby(
        name: name.trim(),
        maxHumans: maxHumans,
        maxBots: maxBots,
        isPrivate: isPrivate,
      );

      if (result != null) {
        _currentLobbyId = result['lobby_id'];

        // Refresh lobbies to include the new one
        await loadLobbies();

        // Return the created lobby
        final createdLobby = _lobbies.firstWhere(
          (lobby) => lobby.lobbyId == _currentLobbyId,
          orElse: () => Lobby(
            lobbyId: result['lobby_id'],
            name: result['name'],
            currentPlayers: 0,
            activePlayerCount: 0,
            maxHumans: maxHumans,
            currentBots: 0,
            maxBots: maxBots,
            isPrivate: isPrivate,
            hasTriviaActive: false,
            messageCount: 0,
            inviteCode: result['invite_code'] ?? '',
            users: [],
            activeUsers: [],
            bots: [],
            status: 'waiting',
          ),
        );

        return createdLobby;
      }

      return null;
    } catch (e) {
      _lastError = 'Failed to create lobby: $e';
      notifyListeners();
      return null;
    }
  }

  /// Join a lobby by invite code
  Future<bool> joinLobbyByInvite(String inviteCode, String userId) async {
    _lastError = null;

    try {
      final success = await _apiService.joinLobbyByInvite(
          inviteCode.trim().toUpperCase(), userId);

      if (success) {
        await loadLobbies(); // Refresh lobby list
      } else {
        _lastError = 'Failed to join lobby. Check your invite code.';
        notifyListeners();
      }

      return success;
    } catch (e) {
      _lastError = 'Error joining lobby: $e';
      notifyListeners();
      return false;
    }
  }

  /// Join a public lobby
  Future<bool> joinPublicLobby(String lobbyId, String userId) async {
    _lastError = null;

    try {
      final success = await _apiService.joinPublicLobby(lobbyId, userId);

      if (success) {
        _currentLobbyId = lobbyId;
        await loadLobbies(); // Refresh lobby list
      } else {
        _lastError = 'Failed to join lobby. It may be full or private.';
        notifyListeners();
      }

      return success;
    } catch (e) {
      _lastError = 'Error joining lobby: $e';
      notifyListeners();
      return false;
    }
  }

  /// Leave current lobby
  Future<bool> leaveLobby(String lobbyId, String userId) async {
    _lastError = null;

    try {
      final success = await _apiService.leaveLobby(lobbyId, userId);

      if (success) {
        if (_currentLobbyId == lobbyId) {
          _currentLobbyId = null;
          _currentLobby = null;
        }
        await loadLobbies(); // Refresh lobby list
      } else {
        _lastError = 'Failed to leave lobby';
        notifyListeners();
      }

      return success;
    } catch (e) {
      _lastError = 'Error leaving lobby: $e';
      notifyListeners();
      return false;
    }
  }

  /// Set current lobby and fetch detailed info
  Future<void> setCurrentLobby(String lobbyId) async {
    _currentLobbyId = lobbyId;
    await fetchLobbyInfo(lobbyId);
    notifyListeners();
  }

  /// Fetch detailed lobby information
  Future<void> fetchLobbyInfo(String lobbyId) async {
    try {
      final info = await _apiService.getLobbyInfo(lobbyId);
      if (info != null) {
        _currentLobby = Lobby.fromJson(info);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching lobby info: $e');
      _lastError = 'Failed to load lobby details';
      notifyListeners();
    }
  }

  /// Load available bots
  Future<void> loadAvailableBots() async {
    try {
      _availableBots = await _apiService.getAvailableBots();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading available bots: $e');
    }
  }

  /// Add bot to lobby
  Future<bool> addBot(String lobbyId, String botName) async {
    _lastError = null;

    try {
      final success = await _apiService.addBot(lobbyId, botName);

      if (success) {
        await fetchLobbyInfo(lobbyId); // Refresh lobby info
        await loadLobbies(); // Refresh lobby list
      } else {
        _lastError =
            'Failed to add bot. Lobby may be full or bot already exists.';
        notifyListeners();
      }

      return success;
    } catch (e) {
      _lastError = 'Error adding bot: $e';
      notifyListeners();
      return false;
    }
  }

  /// Remove bot from lobby
  Future<bool> removeBot(String lobbyId, String botName) async {
    _lastError = null;

    try {
      final success = await _apiService.removeBot(lobbyId, botName);

      if (success) {
        await fetchLobbyInfo(lobbyId); // Refresh lobby info
        await loadLobbies(); // Refresh lobby list
      } else {
        _lastError = 'Failed to remove bot. Bot may not exist in lobby.';
        notifyListeners();
      }

      return success;
    } catch (e) {
      _lastError = 'Error removing bot: $e';
      notifyListeners();
      return false;
    }
  }

  /// Check server health
  Future<bool> checkServerHealth() async {
    try {
      return await _apiService.checkHealth();
    } catch (e) {
      debugPrint('Error checking server health: $e');
      return false;
    }
  }

  /// Load server statistics
  Future<void> loadServerStats() async {
    try {
      _serverStats = await _apiService.getServerStats();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading server stats: $e');
    }
  }

  /// Search lobbies by name
  List<Lobby> searchLobbies(String query) {
    if (query.trim().isEmpty) return _lobbies;

    final lowercaseQuery = query.toLowerCase();
    return _lobbies
        .where((lobby) =>
            lobby.name.toLowerCase().contains(lowercaseQuery) ||
            lobby.inviteCode.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  /// Get lobby by ID
  Lobby? getLobbyById(String lobbyId) {
    try {
      return _lobbies.firstWhere((lobby) => lobby.lobbyId == lobbyId);
    } catch (e) {
      return null;
    }
  }

  /// Get lobby by invite code
  Lobby? getLobbyByInviteCode(String inviteCode) {
    try {
      return _lobbies.firstWhere((lobby) =>
          lobby.inviteCode.toUpperCase() == inviteCode.toUpperCase());
    } catch (e) {
      return null;
    }
  }

  /// Get bot by name
  Bot? getBotByName(String botName) {
    try {
      return _availableBots.firstWhere((bot) => bot.name == botName);
    } catch (e) {
      return null;
    }
  }

  /// Clear current lobby
  void clearCurrentLobby() {
    _currentLobbyId = null;
    _currentLobby = null;
    notifyListeners();
  }

  /// Clear error state
  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  /// Force refresh
  Future<void> forceRefresh() async {
    _stopAutoRefresh();
    await loadLobbies();
    await loadAvailableBots();
    if (_currentLobbyId != null) {
      await fetchLobbyInfo(_currentLobbyId!);
    }
    _startAutoRefresh();
  }

  /// Get statistics
  Map<String, int> getLobbyStatistics() {
    return {
      'total': _lobbies.length,
      'active': activeLobbies.length,
      'waiting': waitingLobbies.length,
      'public': publicLobbies.length,
      'private': privateLobbies.length,
      'available': availableLobbies.length,
      'full': _lobbies.where((lobby) => lobby.isFull).length,
    };
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    _apiService.dispose();
    super.dispose();
  }
}
