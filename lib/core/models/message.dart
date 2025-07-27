// lib/core/models/message.dart
class ChatMessage {
  final String messageId;
  final String username;
  final String message;
  final String type;
  final DateTime timestamp;
  final String? avatar;
  final String? replyTo;
  final ChatMessage? repliedMessage;
  final Map<String, dynamic>? triviaData;
  final Map<String, dynamic>? triviaResult;

  ChatMessage({
    required this.messageId,
    required this.username,
    required this.message,
    required this.type,
    DateTime? timestamp,
    this.avatar,
    this.replyTo,
    this.repliedMessage,
    this.triviaData,
    this.triviaResult,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    ChatMessage? repliedMessage;
    if (json['replied_message'] != null) {
      repliedMessage = ChatMessage.fromJson(json['replied_message']);
    }

    return ChatMessage(
      messageId: json['message_id'] ?? '',
      username: json['username'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'user',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      avatar: json['avatar'],
      replyTo: json['reply_to'],
      repliedMessage: repliedMessage,
      triviaData: json['trivia_data'],
      triviaResult: json['trivia_result'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'username': username,
      'message': message,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'avatar': avatar,
      'reply_to': replyTo,
      'replied_message': repliedMessage?.toJson(),
      'trivia_data': triviaData,
      'trivia_result': triviaResult,
    };
  }

  // Helper methods
  bool get isBot => type == 'bot';
  bool get isSystem => type == 'system';
  bool get isTrivia => type == 'trivia';
  bool get isTriviaResult => type == 'trivia_result';
  bool get isUser => type == 'user';
  bool get hasReply => replyTo != null;

  String get displayName => username;
  String get avatarEmoji => avatar ?? (isBot ? '🤖' : '👤');
}
