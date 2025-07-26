class TriviaQuestion {
  final String question;
  final List<String> options;
  final int timeLimit;

  TriviaQuestion(
      {required this.question, required this.options, required this.timeLimit});

  factory TriviaQuestion.fromJson(Map<String, dynamic> json) {
    return TriviaQuestion(
      question: json['question'],
      options: List<String>.from(json['options']),
      timeLimit: json['time_limit'] ?? 30,
    );
  }
}

class TriviaResult {
  final int correctAnswer;
  final List<String> winners;

  TriviaResult({required this.correctAnswer, required this.winners});

  factory TriviaResult.fromJson(Map<String, dynamic> json) {
    return TriviaResult(
      correctAnswer: json['correct_answer'],
      winners: List<String>.from(json['winners'] ?? []),
    );
  }
}
