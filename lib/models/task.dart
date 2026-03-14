class Task {
  final String id;
  DateTime date;
  int timeMinutes;
  String text;
  int repeatWeekday;
  bool done;
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "date": date.toIso8601String(),
      "text": text,
      "done": done,
      "repeatWeekday": repeatWeekday,
      "timeMinutes": timeMinutes,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json["id"],
      date: DateTime.parse(json["date"]),
      text: json["text"],
      done: json["done"],
      repeatWeekday: json["repeatWeekday"],
      timeMinutes: json["timeMinutes"],
    );
  }

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
