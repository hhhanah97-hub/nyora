class Task {
  final String id;
  final DateTime date;
  final int timeMinutes;
  final String text;
  final int repeatWeekday;
  final bool done;

  Task({
    required this.id,
    required this.date,
    required this.timeMinutes,
    required this.text,
    required this.repeatWeekday,
    required this.done,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'timeMinutes': timeMinutes,
      'text': text,
      'repeatWeekday': repeatWeekday,
      'done': done,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      date: DateTime.parse(map['date']),
      timeMinutes: map['timeMinutes'],
      text: map['text'],
      repeatWeekday: map['repeatWeekday'],
      done: map['done'],
    );
  }
}
