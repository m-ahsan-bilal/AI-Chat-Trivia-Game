class ChatMessage {
  final String username;
  final String message;
  final String type;
  final DateTime timestamp;

  ChatMessage({
    required this.username,
    required this.message,
    required this.type,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      username: json['username'],
      message: json['message'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'message': message,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
