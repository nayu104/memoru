import 'mood.dart';

class Memo {
  final String id;
  final String title;
  final String body;
  final Mood mood;
  final DateTime createdAt;

  Memo({
    required this.id,
    required this.title,
    this.body = '',
    this.mood = Mood.calm,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
