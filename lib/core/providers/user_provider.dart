import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  User? _currentUser;
  final ApiService _apiService = ApiService();

  // Store registered users locally for login simulation
  static const String _registeredUsersKey = 'registered_users';

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<bool> registerUser(String username) async {
    final user = await _apiService.registerUser(username);
    if (user != null) {
      _currentUser = user;
      await _saveUserToPrefs(user);
      await _addToRegisteredUsers(username, user.userId);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> loginUser(String username) async {
    // Check if user exists in registered users
    final registeredUsers = await _getRegisteredUsers();
    final userId = registeredUsers[username];

    if (userId != null) {
      // User found, create user object and log them in
      final user = User(userId: userId, username: username);
      _currentUser = user;
      await _saveUserToPrefs(user);
      notifyListeners();
      return true;
    }

    return false; // User not found
  }

  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final username = prefs.getString('username');

    if (userId != null && username != null) {
      _currentUser = User(userId: userId, username: username);
      notifyListeners();
    }
  }

  Future<void> _saveUserToPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.userId);
    await prefs.setString('username', user.username);
  }

  Future<void> _addToRegisteredUsers(String username, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final registeredUsers = await _getRegisteredUsers();
    registeredUsers[username] = userId;

    // Convert map to string format for storage
    final List<String> usersList = registeredUsers.entries
        .map((entry) => '${entry.key}:${entry.value}')
        .toList();

    await prefs.setStringList(_registeredUsersKey, usersList);
  }

  Future<Map<String, String>> _getRegisteredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersList = prefs.getStringList(_registeredUsersKey) ?? [];

    final Map<String, String> registeredUsers = {};
    for (final userString in usersList) {
      final parts = userString.split(':');
      if (parts.length == 2) {
        registeredUsers[parts[0]] = parts[1];
      }
    }

    return registeredUsers;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('username');
    // Don't clear registered users - keep them for future logins
    _currentUser = null;
    notifyListeners();
  }

  // Helper method to check if a username exists
  Future<bool> usernameExists(String username) async {
    final registeredUsers = await _getRegisteredUsers();
    return registeredUsers.containsKey(username);
  }

  // Helper method to get all registered usernames (for debugging)
  Future<List<String>> getRegisteredUsernames() async {
    final registeredUsers = await _getRegisteredUsers();
    return registeredUsers.keys.toList();
  }
}
