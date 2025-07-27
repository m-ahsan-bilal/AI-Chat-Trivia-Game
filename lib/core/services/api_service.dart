// lib/core/services/api_service.dart
// ignore_for_file: constant_identifier_names, provide_deprecation_message

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/lobby.dart';
import '../models/bot.dart';
import '../models/message.dart';

class ApiService {
  static const String API_BASE = 'https://aichatapi-production.up.railway.app';

  // Timeout duration for requests
  static const Duration _timeout = Duration(seconds: 30);

  // HTTP client with timeout
  final http.Client _client = http.Client();

  // Headers for requests
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // --- USER MANAGEMENT ---

  Future<User?> registerUser(String username) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$API_BASE/register'),
            headers: _headers,
            body: jsonEncode({'username': username}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User(userId: data['user_id'], username: username);
      } else {
        final error = jsonDecode(response.body);
        debugPrint('Registration failed: ${error['detail'] ?? response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$API_BASE/users/$userId'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Failed to get user info: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Get user info error: $e');
      return null;
    }
  }

  // --- LOBBY MANAGEMENT ---

  Future<Map<String, dynamic>?> createLobby({
    required String name,
    required int maxHumans,
    int maxBots = 2,
    bool isPrivate = false,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$API_BASE/lobbies'),
            headers: _headers,
            body: jsonEncode({
              'name': name,
              'max_humans': maxHumans,
              'max_bots': maxBots,
              'is_private': isPrivate,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        debugPrint(
            'Lobby creation failed: ${error['detail'] ?? response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Lobby creation error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getLobbies() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$API_BASE/lobbies'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      } else {
        debugPrint('Failed to get lobbies: ${response.body}');
        return {
          'lobbies': <Lobby>[],
          'total_count': 0,
          'active_count': 0,
          'message': 'Failed to load lobbies'
        };
      }
    } catch (e) {
      debugPrint('Get lobbies error: $e');
      return {
        'lobbies': <Lobby>[],
        'total_count': 0,
        'active_count': 0,
        'message': 'Connection error'
      };
    }
  }

  Future<List<Lobby>> getLobbyList() async {
    final data = await getLobbies();
    final List<dynamic> lobbiesData = data['lobbies'] ?? [];
    return lobbiesData.map((json) => Lobby.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>?> getLobbyInfo(String lobbyId) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$API_BASE/lobbies/$lobbyId/info'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Failed to get lobby info: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Get lobby info error: $e');
      return null;
    }
  }

  Future<bool> joinLobbyByInvite(String inviteCode, String userId) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$API_BASE/lobbies/join-invite'),
            headers: _headers,
            body: jsonEncode({
              'invite_code': inviteCode.toUpperCase(),
              'user_id': userId,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = jsonDecode(response.body);
        debugPrint(
            'Join lobby by invite failed: ${error['detail'] ?? response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Join lobby by invite error: $e');
      return false;
    }
  }

  Future<bool> joinPublicLobby(String lobbyId, String userId) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$API_BASE/lobbies/join-public'),
            headers: _headers,
            body: jsonEncode({
              'lobby_id': lobbyId,
              'user_id': userId,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = jsonDecode(response.body);
        debugPrint(
            'Join public lobby failed: ${error['detail'] ?? response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Join public lobby error: $e');
      return false;
    }
  }

  Future<bool> leaveLobby(String lobbyId, String userId) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$API_BASE/lobbies/leave'),
            headers: _headers,
            body: jsonEncode({
              'lobby_id': lobbyId,
              'user_id': userId,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Leave lobby failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Leave lobby error: $e');
      return false;
    }
  }

  // --- BOT MANAGEMENT ---

  Future<List<Bot>> getAvailableBots() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$API_BASE/bots'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bots = data['available_bots'] as List<dynamic>;
        return bots.map((bot) => Bot.fromJson(bot)).toList();
      } else {
        debugPrint('Failed to get available bots: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Get available bots error: $e');
      return [];
    }
  }

  Future<bool> addBot(String lobbyId, String botName) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$API_BASE/lobbies/$lobbyId/add-bot'),
            headers: _headers,
            body: jsonEncode({'bot_name': botName}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = jsonDecode(response.body);
        debugPrint('Add bot failed: ${error['detail'] ?? response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Add bot error: $e');
      return false;
    }
  }

  Future<bool> removeBot(String lobbyId, String botName) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$API_BASE/lobbies/$lobbyId/remove-bot'),
            headers: _headers,
            body: jsonEncode({'bot_name': botName}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Remove bot failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Remove bot error: $e');
      return false;
    }
  }

  // --- MESSAGING ---

  Future<bool> sendMessage({
    required String lobbyId,
    required String userId,
    required String message,
    String? replyTo,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$API_BASE/lobbies/$lobbyId/send-message'),
            headers: _headers,
            body: jsonEncode({
              'user_id': userId,
              'message': message,
              'reply_to': replyTo,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Send message failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Send message error: $e');
      return false;
    }
  }

  Future<List<ChatMessage>> getLobbyMessages(String lobbyId,
      {int limit = 50, int offset = 0}) async {
    try {
      final response = await _client
          .get(
            Uri.parse(
                '$API_BASE/lobbies/$lobbyId/messages?limit=$limit&offset=$offset'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final messages = data['messages'] as List<dynamic>;
        return messages.map((msg) => ChatMessage.fromJson(msg)).toList();
      } else {
        debugPrint('Failed to get lobby messages: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Get lobby messages error: $e');
      return [];
    }
  }

  // --- TRIVIA ---

  Future<bool> submitTriviaAnswer(
      String lobbyId, String userId, int answer) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$API_BASE/lobbies/$lobbyId/trivia-answer'),
            headers: _headers,
            body: jsonEncode({
              'user_id': userId,
              'answer': answer,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Submit trivia answer failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Submit trivia answer error: $e');
      return false;
    }
  }

  // --- SERVER STATUS ---

  Future<bool> checkHealth() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$API_BASE/health'),
            headers: _headers,
          )
          .timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Health check error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getServerStats() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$API_BASE/stats'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Failed to get server stats: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Get server stats error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getDetailedHealth() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$API_BASE/healthz'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Failed to get detailed health: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Get detailed health error: $e');
      return null;
    }
  }

  // --- DEPRECATED METHODS (for backward compatibility) ---

  @deprecated
  Future<bool> joinLobby(String inviteCode, String userId) async {
    return await joinLobbyByInvite(inviteCode, userId);
  }

  @deprecated
  Future<List<Map<String, dynamic>>> getAvailableBotsOld() async {
    final bots = await getAvailableBots();
    return bots.map((bot) => bot.toJson()).toList();
  }

  // Cleanup method
  void dispose() {
    _client.close();
  }
}
