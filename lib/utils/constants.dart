// ignore_for_file: constant_identifier_names

import 'dart:ui';

class AppConstants {
  // API Configuration
  static const String API_BASE_URL = 'http://10.0.2.2:8000'; // Android Emulator
  static const String WS_BASE_URL = 'ws://10.0.2.2:8000'; // Android Emulator

  // For physical device, replace with your computer's IP:
  // static const String API_BASE_URL = 'http://192.168.1.100:8000';
  // static const String WS_BASE_URL = 'ws://192.168.1.100:8000';

  // Shared Preferences Keys
  static const String USER_ID_KEY = 'user_id';
  static const String USERNAME_KEY = 'username';

  // UI Constants
  static const int MAX_MESSAGE_LENGTH = 500;
  static const int LOBBY_NAME_MAX_LENGTH = 50;
  static const int USERNAME_MAX_LENGTH = 20;

  // Colors
  static const primaryColor = Color(0xFF1976D2);
  static const secondaryColor = Color(0xFF42A5F5);
  static const errorColor = Color(0xFFD32F2F);
  static const successColor = Color(0xFF388E3C);
}
