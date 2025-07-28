// lib/core/models/bot.dart
class Bot {
  final String name;
  final String personality;
  final String provider;
  final String avatar;
  final String description;

  Bot({
    required this.name,
    required this.personality,
    required this.provider,
    required this.avatar,
    required this.description,
  });

  factory Bot.fromJson(Map<String, dynamic> json) {
    return Bot(
      name: json['name'] ?? '',
      personality: json['personality'] ?? 'friendly AI assistant',
      provider: json['provider'] ?? 'enhanced_rules',
      avatar: json['avatar'] ?? '🤖',
      description: json['description'] ?? 'AI assistant',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'personality': personality,
      'provider': provider,
      'avatar': avatar,
      'description': description,
    };
  }

  // Helper methods
  String get providerLabel {
    switch (provider.toLowerCase()) {
      case 'huggingface':
        return 'HuggingFace AI';
      case 'ollama':
        return 'Local AI';
      case 'enhanced_rules':
        return 'Smart Rules';
      default:
        return provider.toUpperCase();
    }
  }

  BotType get botType {
    switch (name.toLowerCase()) {
      case 'chatbot':
        return BotType.chatbot;
      case 'quizmaster':
        return BotType.quizmaster;
      case 'cheerleader':
        return BotType.cheerleader;
      case 'philosopher':
        return BotType.philosopher;
      case 'comedian':
        return BotType.comedian;
      default:
        return BotType.chatbot;
    }
  }
}

enum BotType {
  chatbot,
  quizmaster,
  cheerleader,
  philosopher,
  comedian,
}

extension BotTypeExtension on BotType {
  String get displayName {
    switch (this) {
      case BotType.chatbot:
        return 'ChatBot';
      case BotType.quizmaster:
        return 'QuizMaster';
      case BotType.cheerleader:
        return 'Cheerleader';
      case BotType.philosopher:
        return 'Philosopher';
      case BotType.comedian:
        return 'Comedian';
    }
  }

  String get emoji {
    switch (this) {
      case BotType.chatbot:
        return '🤖';
      case BotType.quizmaster:
        return '🎯';
      case BotType.cheerleader:
        return '⭐';
      case BotType.philosopher:
        return '🧠';
      case BotType.comedian:
        return '😄';
    }
  }

  String get description {
    switch (this) {
      case BotType.chatbot:
        return 'friendly neighborhood';
      case BotType.quizmaster:
        return 'Trivia enthusiast';
      case BotType.cheerleader:
        return 'biggest motivator';
      case BotType.philosopher:
        return 'philosophical companion';
      case BotType.comedian:
        return 'joke teller';
    }
  }
}
