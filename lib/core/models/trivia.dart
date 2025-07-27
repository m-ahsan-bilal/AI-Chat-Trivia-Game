// lib/core/models/trivia.dart
class TriviaQuestion {
  final String question;
  final List<String> options;
  final int timeLimit;
  final String? triviaId;

  TriviaQuestion({
    required this.question,
    required this.options,
    required this.timeLimit,
    this.triviaId,
  });

  factory TriviaQuestion.fromJson(Map<String, dynamic> json) {
    return TriviaQuestion(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      timeLimit: json['time_limit'] ?? 30,
      triviaId: json['trivia_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'time_limit': timeLimit,
      'trivia_id': triviaId,
    };
  }
}

class TriviaResult {
  final int correctAnswerIndex;
  final String correctAnswerText;
  final List<String> winners;
  final int totalParticipants;
  final Map<String, int>? allAnswers;

  TriviaResult({
    required this.correctAnswerIndex,
    required this.correctAnswerText,
    required this.winners,
    required this.totalParticipants,
    this.allAnswers,
  });

  factory TriviaResult.fromJson(Map<String, dynamic> json) {
    Map<String, int>? answers;
    if (json['all_answers'] != null) {
      answers = Map<String, int>.from(json['all_answers']);
    }

    return TriviaResult(
      correctAnswerIndex: json['correct_answer_index'] ?? 0,
      correctAnswerText: json['correct_answer_text'] ?? '',
      winners: List<String>.from(json['winners'] ?? []),
      totalParticipants: json['total_participants'] ?? 0,
      allAnswers: answers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'correct_answer_index': correctAnswerIndex,
      'correct_answer_text': correctAnswerText,
      'winners': winners,
      'total_participants': totalParticipants,
      'all_answers': allAnswers,
    };
  }

  // Helper methods
  bool get hasWinners => winners.isNotEmpty;
  bool get hasMultipleWinners => winners.length > 1;

  String get resultSummary {
    if (hasWinners) {
      if (hasMultipleWinners) {
        return 'Multiple winners: ${winners.join(', ')}';
      } else {
        return 'Winner: ${winners.first}';
      }
    } else {
      return 'No winners this time!';
    }
  }
}

class TriviaAnswer {
  final String userId;
  final String username;
  final int answerIndex;
  final DateTime timestamp;

  TriviaAnswer({
    required this.userId,
    required this.username,
    required this.answerIndex,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory TriviaAnswer.fromJson(Map<String, dynamic> json) {
    return TriviaAnswer(
      userId: json['user_id'] ?? '',
      username: json['username'] ?? '',
      answerIndex: json['answer_index'] ?? 0,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'answer_index': answerIndex,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
