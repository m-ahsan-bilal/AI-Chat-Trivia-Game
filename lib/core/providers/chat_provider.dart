// lib/providers/chat_provider.dart
import 'package:ai_chat_trivia/core/services/web_socket_service.dart';
import 'package:flutter/material.dart';
import '../models/message.dart';
import 'package:ai_chat_trivia/core/services/api_service.dart';
import 'package:ai_chat_trivia/core/models/trivia.dart';

class ChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isConnected = false;
  final WebSocketService _wsService = WebSocketService();
  bool _isDisposed = false;
  TriviaQuestion? _activeTrivia;
  TriviaResult? _triviaResult;
  bool get hasActiveTrivia => _activeTrivia != null;
  TriviaQuestion? get activeTrivia => _activeTrivia;
  TriviaResult? get triviaResult => _triviaResult;
  final ApiService _apiService = ApiService();

  List<ChatMessage> get messages => _messages;
  bool get isConnected => _isConnected;

  ChatProvider() {
    _wsService.onMessageReceived = (message) {
      if (!_isDisposed) {
        // Detect trivia question
        if (message.type == 'trivia') {
          _activeTrivia =
              TriviaQuestion.fromJson(message.toJson()['trivia_data']);
          _triviaResult = null;
        } else if (message.type == 'trivia_result') {
          _triviaResult = TriviaResult.fromJson(message.toJson());
          _activeTrivia = null;
        }
        _messages.add(message);
        // Use WidgetsBinding to ensure we're not in build phase
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed) {
            notifyListeners();
          }
        });
      }
    };

    _wsService.onConnectionChanged = (connected) {
      if (!_isDisposed) {
        _isConnected = connected;
        // Use WidgetsBinding to ensure we're not in build phase
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed) {
            notifyListeners();
          }
        });
      }
    };
  }

  void connectToLobby(String lobbyId, String userId) {
    _messages.clear();

    // Use WidgetsBinding to delay the connection until after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        _wsService.connect(lobbyId, userId);

        // Notify listeners that we've cleared messages and are connecting
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed) {
            notifyListeners();
          }
        });
      }
    });
  }

  void sendMessage(String message) {
    if (!_isDisposed) {
      _wsService.sendMessage(message);
    }
  }

  void disconnect() {
    if (!_isDisposed) {
      _wsService.disconnect();
      _messages.clear();
      _isConnected = false;

      // Safe notification
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed) {
          notifyListeners();
        }
      });
    }
  }

  Future<bool> submitTriviaAnswer(
      String lobbyId, String userId, int answer) async {
    final success =
        await _apiService.submitTriviaAnswer(lobbyId, userId, answer);
    return success;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _wsService.disconnect();
    super.dispose();
  }
}
