import 'package:ai_chat_trivia/utils/constants.dart';

class Validators {
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }

    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (value.trim().length > AppConstants.USERNAME_MAX_LENGTH) {
      return 'Username must be less than ${AppConstants.USERNAME_MAX_LENGTH} characters';
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null;
  }

  static String? validateLobbyName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Lobby name is required';
    }

    if (value.trim().length < 3) {
      return 'Lobby name must be at least 3 characters';
    }

    if (value.trim().length > AppConstants.LOBBY_NAME_MAX_LENGTH) {
      return 'Lobby name must be less than ${AppConstants.LOBBY_NAME_MAX_LENGTH} characters';
    }

    return null;
  }

  static String? validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Message cannot be empty';
    }

    if (value.trim().length > AppConstants.MAX_MESSAGE_LENGTH) {
      return 'Message is too long';
    }

    return null;
  }

  static String? validateMaxPlayers(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Max players is required';
    }

    final number = int.tryParse(value.trim());
    if (number == null) {
      return 'Must be a valid number';
    }

    if (number < 2) {
      return 'Must have at least 2 players';
    }

    if (number > 20) {
      return 'Cannot have more than 20 players';
    }

    return null;
  }
}
