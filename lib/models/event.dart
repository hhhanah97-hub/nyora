class Event {
  final DateTime date;
  final int timeMinutes;
  final String text;
  final String category;
  final String repeat;

  Event({
    required this.date,
    required this.timeMinutes,
    required this.text,
    this.category = "",
    this.repeat = "",
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'timeMinutes': timeMinutes,
      'text': text,
      'category': category,
      'repeat': repeat,
    };
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      date: DateTime.parse(json['date']),
      timeMinutes: json['timeMinutes'],
      text: json['text'],
      category: json['category'] ?? "",
      repeat: json['repeat'] ?? "",
    );
  }
}
