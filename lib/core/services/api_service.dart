// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/lobby.dart';

class ApiService {
  static const String API_BASE = 'https://aichatapi-production.up.railway.app';

  Future<User?> registerUser(String username) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User(userId: data['user_id'], username: username);
      } else {
        debugPrint('Registration failed: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> createLobby({
    required String name,
    required int maxHumans,
    int maxBots = 0,
    bool isPrivate = false,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE/lobbies'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'max_humans': maxHumans,
          'max_bots': maxBots,
          'is_private': isPrivate,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Lobby creation failed: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Lobby creation error: $e');
      return null;
    }
  }

  Future<List<Lobby>> getLobbies() async {
    try {
      final response = await http.get(Uri.parse('$API_BASE/lobbies'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> lobbiesData = responseData['lobbies'] ?? [];
        return lobbiesData.map((json) => Lobby.fromJson(json)).toList();
      } else {
        debugPrint('Failed to get lobbies: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Get lobbies error: $e');
      return [];
    }
  }

  Future<bool> joinLobbyByInvite(String inviteCode, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE/lobbies/join-invite'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'invite_code': inviteCode,
          'user_id': userId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Join lobby by invite error: $e');
      return false;
    }
  }

  Future<bool> joinPublicLobby(String lobbyId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE/lobbies/join-public'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'lobby_id': lobbyId,
          'user_id': userId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Join public lobby error: $e');
      return false;
    }
  }

  // Deprecated - use joinLobbyByInvite instead
  Future<bool> joinLobby(String inviteCode, String userId) async {
    return await joinLobbyByInvite(inviteCode, userId);
  }

  Future<Map<String, dynamic>?> getLobbyInfo(String lobbyId) async {
    try {
      final response =
          await http.get(Uri.parse('$API_BASE/lobbies/$lobbyId/info'));
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

  Future<bool> addBot(String lobbyId, String botName) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE/lobbies/$lobbyId/add-bot'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'bot_name': botName}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Add bot error: $e');
      return false;
    }
  }

  Future<bool> removeBot(String lobbyId, String botName) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE/lobbies/$lobbyId/remove-bot'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'bot_name': botName}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Remove bot error: $e');
      return false;
    }
  }

  Future<bool> submitTriviaAnswer(
      String lobbyId, String userId, int answer) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE/lobbies/$lobbyId/trivia-answer'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId, 'answer': answer}),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Submit trivia answer error: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableBots() async {
    try {
      final response = await http.get(Uri.parse('$API_BASE/bots'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bots = data['available_bots'] as List<dynamic>;
        return bots.cast<Map<String, dynamic>>();
      } else {
        debugPrint('Failed to get available bots: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Get available bots error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getServerStats() async {
    try {
      final response = await http.get(Uri.parse('$API_BASE/stats'));
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

  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$API_BASE/health'));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Health check error: $e');
      return false;
    }
  }

  Future<bool> leaveLobby(String lobbyId, String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$API_BASE/lobbies/leave'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'lobby_id': lobbyId,
          'user_id': userId,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Leave lobby error: $e');
      return false;
    }
  }
}
