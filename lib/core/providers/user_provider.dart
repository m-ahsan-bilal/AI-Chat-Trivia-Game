// lib/core/providers/user_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Current user state
  User? _currentUser;
  final bool _isLoading = false;
  String? _lastError;

  // User preferences
  bool _isDarkMode = false;
  String _selectedLanguage = 'en';
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;

  // Authentication state
  bool _isRegistering = false;
  bool _isLoggingIn = false;

  // Storage keys
  static const String _userKey = 'current_user';
  static const String _registeredUsersKey = 'registered_users';
  static const String _darkModeKey = 'dark_mode';
  static const String _languageKey = 'language';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _soundKey = 'sound_enabled';

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isRegistering => _isRegistering;
  bool get isLoggingIn => _isLoggingIn;
  String? get lastError => _lastError;
  bool get hasError => _lastError != null;

  // Preferences getters
  bool get isDarkMode => _isDarkMode;
  String get selectedLanguage => _selectedLanguage;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;

  String get currentUsername => _currentUser?.username ?? 'Guest';
  String get currentUserId => _currentUser?.userId ?? '';

  UserProvider() {
    _initializeUser();
  }

  /// Initialize user from stored preferences
  Future<void> _initializeUser() async {
    await _loadUserPreferences();
    await loadUserFromPrefs();
  }

  /// Load user preferences
  Future<void> _loadUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
      _selectedLanguage = prefs.getString(_languageKey) ?? 'en';
      _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
      _soundEnabled = prefs.getBool(_soundKey) ?? true;

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user preferences: $e');
    }
  }

  /// Register a new user
  Future<bool> registerUser(String username) async {
    if (_isRegistering || username.trim().isEmpty) return false;

    _isRegistering = true;
    _lastError = null;
    notifyListeners();

    try {
      // Check if username already exists locally
      if (await usernameExists(username.trim())) {
        _lastError = 'Username already exists. Try logging in instead.';
        return false;
      }

      // Register with API
      final user = await _apiService.registerUser(username.trim());

      if (user != null) {
        _currentUser = user;
        await _saveUserToPrefs(user);
        await _addToRegisteredUsers(user.username, user.userId);

        debugPrint('User registered successfully: ${user.username}');
        return true;
      } else {
        _lastError = 'Registration failed. Username may be taken on server.';
        return false;
      }
    } catch (e) {
      _lastError = 'Registration error: $e';
      debugPrint('Registration error: $e');
      return false;
    } finally {
      _isRegistering = false;
      notifyListeners();
    }
  }

  /// Login existing user
  Future<bool> loginUser(String username) async {
    if (_isLoggingIn || username.trim().isEmpty) return false;

    _isLoggingIn = true;
    _lastError = null;
    notifyListeners();

    try {
      // Check if user exists in local storage
      final registeredUsers = await _getRegisteredUsers();
      final userId = registeredUsers[username.trim()];

      if (userId != null) {
        // User found locally, log them in
        final user = User(userId: userId, username: username.trim());

        // Verify user still exists on server (optional)
        final userInfo = await _apiService.getUserInfo(userId);
        if (userInfo != null) {
          _currentUser = user;
          await _saveUserToPrefs(user);

          debugPrint('User logged in successfully: ${user.username}');
          return true;
        } else {
          // User doesn't exist on server anymore, remove from local storage
          await _removeFromRegisteredUsers(username.trim());
          _lastError = 'User account no longer exists. Please register again.';
          return false;
        }
      } else {
        _lastError = 'Username not found. Please register first.';
        return false;
      }
    } catch (e) {
      _lastError = 'Login error: $e';
      debugPrint('Login error: $e');
      return false;
    } finally {
      _isLoggingIn = false;
      notifyListeners();
    }
  }

  /// Load user from preferences
  Future<void> loadUserFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        final userData = jsonDecode(userJson);
        _currentUser = User.fromJson(userData);

        debugPrint('Loaded user from preferences: ${_currentUser?.username}');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user from preferences: $e');
    }
  }

  /// Save user to preferences
  Future<void> _saveUserToPrefs(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('Error saving user to preferences: $e');
    }
  }

  /// Get registered users map
  Future<Map<String, String>> _getRegisteredUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_registeredUsersKey);

      if (usersJson != null) {
        final Map<String, dynamic> usersData = jsonDecode(usersJson);
        return usersData.cast<String, String>();
      }
    } catch (e) {
      debugPrint('Error getting registered users: $e');
    }

    return {};
  }

  /// Add user to registered users
  Future<void> _addToRegisteredUsers(String username, String userId) async {
    try {
      final registeredUsers = await _getRegisteredUsers();
      registeredUsers[username] = userId;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_registeredUsersKey, jsonEncode(registeredUsers));
    } catch (e) {
      debugPrint('Error adding to registered users: $e');
    }
  }

  /// Remove user from registered users
  Future<void> _removeFromRegisteredUsers(String username) async {
    try {
      final registeredUsers = await _getRegisteredUsers();
      registeredUsers.remove(username);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_registeredUsersKey, jsonEncode(registeredUsers));
    } catch (e) {
      debugPrint('Error removing from registered users: $e');
    }
  }

  /// Check if username exists locally
  Future<bool> usernameExists(String username) async {
    final registeredUsers = await _getRegisteredUsers();
    return registeredUsers.containsKey(username.trim());
  }

  /// Get all registered usernames
  Future<List<String>> getRegisteredUsernames() async {
    final registeredUsers = await _getRegisteredUsers();
    return registeredUsers.keys.toList()..sort();
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);

      _currentUser = null;
      _lastError = null;

      debugPrint('User logged out successfully');
      notifyListeners();
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  /// Update user preferences
  Future<void> setDarkMode(bool isDark) async {
    try {
      _isDarkMode = isDark;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkModeKey, isDark);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting dark mode: $e');
    }
  }

  Future<void> setLanguage(String language) async {
    try {
      _selectedLanguage = language;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting language: $e');
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      _notificationsEnabled = enabled;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsKey, enabled);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting notifications: $e');
    }
  }

  Future<void> setSoundEnabled(bool enabled) async {
    try {
      _soundEnabled = enabled;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_soundKey, enabled);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting sound: $e');
    }
  }

  /// Clear error state
  void clearError() {
    _lastError = null;
    notifyListeners();
  }

  /// Get user info from server
  Future<Map<String, dynamic>?> getUserInfo() async {
    if (_currentUser == null) return null;

    try {
      return await _apiService.getUserInfo(_currentUser!.userId);
    } catch (e) {
      debugPrint('Error getting user info: $e');
      return null;
    }
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    if (_currentUser == null) return;

    try {
      final userInfo = await _apiService.getUserInfo(_currentUser!.userId);
      if (userInfo != null) {
        // User still exists on server
        debugPrint('User data refreshed successfully');
      } else {
        // User doesn't exist on server, log them out
        await logout();
        _lastError = 'Your account no longer exists. Please register again.';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing user data: $e');
    }
  }

  /// Validate username format
  static String? validateUsername(String? username) {
    if (username == null || username.trim().isEmpty) {
      return 'Username is required';
    }

    final trimmed = username.trim();

    if (trimmed.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (trimmed.length > 20) {
      return 'Username must be less than 20 characters';
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(trimmed)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null;
  }

  /// Check if user is in a lobby
  bool isUserInLobby(String lobbyId) {
    // This would need to be implemented based on your lobby tracking logic
    // For now, returning false as a placeholder
    return false;
  }

  /// Get user statistics
  Map<String, dynamic> getUserStats() {
    return {
      'isLoggedIn': isLoggedIn,
      'username': currentUsername,
      'userId': currentUserId,
      'preferences': {
        'darkMode': _isDarkMode,
        'language': _selectedLanguage,
        'notifications': _notificationsEnabled,
        'sound': _soundEnabled,
      },
      'hasError': hasError,
      'lastError': _lastError,
    };
  }

  /// Clear all user data (for debugging/testing)
  Future<void> clearAllUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_registeredUsersKey);

      _currentUser = null;
      _lastError = null;

      debugPrint('All user data cleared');
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing user data: $e');
    }
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
