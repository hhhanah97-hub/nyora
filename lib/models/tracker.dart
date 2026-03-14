class Tracker {
  final String id;
  String name;
  DateTime date;
  bool done;

  Tracker({
    required this.id,
    required this.name,
    required this.date,
    required this.done,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "date": date.toIso8601String(),
      "done": done,
    };
  }

  factory Tracker.fromJson(Map<String, dynamic> json) {
    return Tracker(
      id: json["id"],
      name: json["name"],
      date: DateTime.parse(json["date"]),
      done: json["done"],
    );
  }
}
