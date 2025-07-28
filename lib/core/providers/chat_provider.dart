// lib/core/providers/chat_provider.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/message.dart';
import '../models/trivia.dart';
import '../services/web_socket_service.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [];
  final WebSocketService _wsService = WebSocketService();
  final ApiService _apiService = ApiService();

  // State variables
  bool _isConnected = false;
  bool _isConnecting = false;
  bool _isDisposed = false;
  String? _currentLobbyId;
  String? _currentUserId;
  String? _currentUsername;

  // Trivia state
  TriviaQuestion? _activeTrivia;
  TriviaResult? _triviaResult;
  bool _hasAnsweredTrivia = false;
  Timer? _triviaTimer;
  int _triviaTimeRemaining = 0;

  // Typing indicators
  final Map<String, bool> _typingUsers = {};
  Timer? _typingTimer;

  // Reply functionality
  ChatMessage? _replyingTo;

  // Error handling
  String? _lastError;
  int _reconnectAttempts = 0;

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;

  // Trivia getters
  bool get hasActiveTrivia => _activeTrivia != null;
  TriviaQuestion? get activeTrivia => _activeTrivia;
  TriviaResult? get triviaResult => _triviaResult;
  bool get hasAnsweredTrivia => _hasAnsweredTrivia;
  int get triviaTimeRemaining => _triviaTimeRemaining;

  // Typing getters
  List<String> get typingUsers => _typingUsers.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key)
      .where((user) => user != _currentUsername)
      .toList();

  bool get someoneIsTyping => typingUsers.isNotEmpty;

  // Reply getters
  ChatMessage? get replyingTo => _replyingTo;
  bool get isReplying => _replyingTo != null;

  // Error getters
  String? get lastError => _lastError;
  bool get hasError => _lastError != null;

  ChatProvider() {
    _setupWebSocketListeners();
  }

  get selectedTriviaAnswer => null;

  void _setupWebSocketListeners() {
    // Message received
    _wsService.onMessageReceived = (message) {
      if (!_isDisposed) {
        _handleReceivedMessage(message);
      }
    };

    // Connection status changed
    _wsService.onConnectionChanged = (connected) {
      if (!_isDisposed) {
        _isConnected = connected;
        _isConnecting = false;
        if (connected) {
          _lastError = null;
          _reconnectAttempts = 0;
        }
        _safeNotifyListeners();
      }
    };

    // Error occurred
    _wsService.onError = (error) {
      if (!_isDisposed) {
        _lastError = error;
        _reconnectAttempts++;
        _safeNotifyListeners();
      }
    };

    // Typing indicators
    _wsService.onTypingReceived = (data) {
      if (!_isDisposed) {
        final username = data['username'] as String?;
        final isTyping = data['is_typing'] as bool? ?? false;

        if (username != null && username != _currentUsername) {
          _typingUsers[username] = isTyping;

          // Clear typing after 3 seconds if no update
          if (isTyping) {
            Timer(const Duration(seconds: 3), () {
              if (_typingUsers[username] == true) {
                _typingUsers[username] = false;
                _safeNotifyListeners();
              }
            });
          }

          _safeNotifyListeners();
        }
      }
    };
  }

  void _handleReceivedMessage(ChatMessage message) {
    // Handle trivia messages
    if (message.isTrivia && message.triviaData != null) {
      _activeTrivia = TriviaQuestion.fromJson(message.triviaData!);
      _triviaResult = null;
      _hasAnsweredTrivia = false;
      _startTriviaTimer();
    } else if (message.isTriviaResult && message.triviaResult != null) {
      _triviaResult = TriviaResult.fromJson(message.triviaResult!);
      _activeTrivia = null;
      _hasAnsweredTrivia = false;
      _stopTriviaTimer();
    }

    // Add message to list
    _messages.add(message);

    // Keep only last 500 messages to prevent memory issues
    if (_messages.length > 500) {
      _messages.removeRange(0, _messages.length - 500);
    }

    _safeNotifyListeners();
  }

  /// Connect to a lobby's chat
  Future<void> connectToLobby(
      String lobbyId, String userId, String username) async {
    if (_isDisposed) return;

    // Disconnect from previous lobby if connected
    if (_isConnected) {
      disconnect();
    }

    _currentLobbyId = lobbyId;
    _currentUserId = userId;
    _currentUsername = username;
    _isConnecting = true;
    _lastError = null;
    _messages.clear();

    _safeNotifyListeners();

    try {
      // Load recent messages first
      await _loadRecentMessages();

      // Then connect to WebSocket
      _wsService.connect(lobbyId, userId);
    } catch (e) {
      _lastError = 'Failed to connect: $e';
      _isConnecting = false;
      _safeNotifyListeners();
    }
  }

  /// Load recent messages from API
  Future<void> _loadRecentMessages() async {
    if (_currentLobbyId == null) return;

    try {
      final recentMessages =
          await _apiService.getLobbyMessages(_currentLobbyId!, limit: 50);

      _messages.clear();
      _messages.addAll(recentMessages);
      _safeNotifyListeners();
    } catch (e) {
      debugPrint('Error loading recent messages: $e');
    }
  }

  /// Send a chat message
  Future<bool> sendMessage(String message) async {
    if (_isDisposed || message.trim().isEmpty) return false;

    try {
      // Send via WebSocket for real-time delivery
      _wsService.sendMessage(message.trim(), replyTo: _replyingTo?.messageId);

      // Clear reply state
      clearReply();

      return true;
    } catch (e) {
      _lastError = 'Failed to send message: $e';
      _safeNotifyListeners();
      return false;
    }
  }

  /// Send typing indicator
  void sendTyping(bool isTyping) {
    if (!_isDisposed && _isConnected) {
      _wsService.sendTyping(isTyping);
    }
  }

  /// Submit trivia answer
  Future<bool> submitTriviaAnswer(int answerIndex) async {
    if (_isDisposed ||
        _currentLobbyId == null ||
        _currentUserId == null ||
        _activeTrivia == null ||
        _hasAnsweredTrivia) {
      return false;
    }

    try {
      final success = await _apiService.submitTriviaAnswer(
          _currentLobbyId!, _currentUserId!, answerIndex);

      if (success) {
        _hasAnsweredTrivia = true;
        _safeNotifyListeners();
      } else {
        _lastError = 'Failed to submit answer';
        _safeNotifyListeners();
      }

      return success;
    } catch (e) {
      _lastError = 'Error submitting answer: $e';
      _safeNotifyListeners();
      return false;
    }
  }

  /// Start trivia countdown timer
  void _startTriviaTimer() {
    _stopTriviaTimer();
    _triviaTimeRemaining = _activeTrivia?.timeLimit ?? 30;

    _triviaTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_triviaTimeRemaining > 0) {
        _triviaTimeRemaining--;
        _safeNotifyListeners();
      } else {
        _stopTriviaTimer();
      }
    });
  }

  /// Stop trivia countdown timer
  void _stopTriviaTimer() {
    _triviaTimer?.cancel();
    _triviaTimer = null;
    _triviaTimeRemaining = 0;
  }

  /// Set message to reply to
  void setReplyTo(ChatMessage message) {
    _replyingTo = message;
    _safeNotifyListeners();
  }

  /// Clear reply state
  void clearReply() {
    _replyingTo = null;
    _safeNotifyListeners();
  }

  /// Clear error state
  void clearError() {
    _lastError = null;
    _safeNotifyListeners();
  }

  /// Refresh messages
  Future<void> refreshMessages() async {
    if (_currentLobbyId != null) {
      await _loadRecentMessages();
    }
  }

  /// Force reconnect
  void forceReconnect() {
    if (!_isDisposed && _currentLobbyId != null && _currentUserId != null) {
      _wsService.forceReconnect();
    }
  }

  /// Get connection info for debugging
  Map<String, dynamic> getConnectionInfo() {
    return {
      ..._wsService.getConnectionInfo(),
      'currentLobbyId': _currentLobbyId,
      'currentUserId': _currentUserId,
      'currentUsername': _currentUsername,
      'messageCount': _messages.length,
      'hasActiveTrivia': hasActiveTrivia,
      'lastError': _lastError,
      'reconnectAttempts': _reconnectAttempts,
    };
  }

  /// Disconnect from current lobby
  void disconnect() {
    if (!_isDisposed) {
      _wsService.disconnect();
      _stopTriviaTimer();
      _typingTimer?.cancel();

      _isConnected = false;
      _isConnecting = false;
      _currentLobbyId = null;
      _currentUserId = null;
      _currentUsername = null;

      // Clear state
      _messages.clear();
      _activeTrivia = null;
      _triviaResult = null;
      _hasAnsweredTrivia = false;
      _typingUsers.clear();
      _replyingTo = null;
      _lastError = null;
      _reconnectAttempts = 0;

      _safeNotifyListeners();
    }
  }

  /// Safe notify listeners to prevent calling during build
  void _safeNotifyListeners() {
    if (!_isDisposed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed) {
          notifyListeners();
        }
      });
    }
  }

  /// Get messages filtered by type
  List<ChatMessage> getMessagesByType(String type) {
    return _messages.where((msg) => msg.type == type).toList();
  }

  /// Get bot messages only
  List<ChatMessage> getBotMessages() {
    return _messages.where((msg) => msg.isBot).toList();
  }

  /// Get user messages only
  List<ChatMessage> getUserMessages() {
    return _messages.where((msg) => msg.isUser).toList();
  }

  /// Get system messages only
  List<ChatMessage> getSystemMessages() {
    return _messages.where((msg) => msg.isSystem).toList();
  }

  /// Search messages
  List<ChatMessage> searchMessages(String query) {
    if (query.trim().isEmpty) return [];

    final lowercaseQuery = query.toLowerCase();
    return _messages
        .where((msg) =>
            msg.message.toLowerCase().contains(lowercaseQuery) ||
            msg.username.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  /// Get message by ID
  ChatMessage? getMessageById(String messageId) {
    try {
      return _messages.firstWhere((msg) => msg.messageId == messageId);
    } catch (e) {
      return null;
    }
  }

  /// Check if user has sent any messages
  bool hasUserSentMessages(String username) {
    return _messages.any((msg) => msg.username == username && msg.isUser);
  }

  /// Get message count by user
  int getMessageCountByUser(String username) {
    return _messages.where((msg) => msg.username == username).length;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _wsService.dispose();
    _apiService.dispose();
    _stopTriviaTimer();
    _typingTimer?.cancel();
    super.dispose();
  }
}
