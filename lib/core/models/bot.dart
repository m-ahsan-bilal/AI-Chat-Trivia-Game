class Bot {
  final String name;
  final String? avatarUrl;

  Bot({required this.name, this.avatarUrl});

  factory Bot.fromJson(Map<String, dynamic> json) {
    return Bot(
      name: json['name'],
      avatarUrl: json['avatar_url'],
    );
  }
}
