class Tracker {
  final String id;
  String name;
  String type; // PŘIDÁNO: "habit" nebo "cycle"
  DateTime date;
  bool done;

  Tracker({
    required this.id,
    required this.name,
    required this.type, // PŘIDÁNO
    required this.date,
    required this.done,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "type": type, // PŘIDÁNO
      "date": date.toIso8601String(),
      "done": done,
    };
  }

  factory Tracker.fromJson(Map<String, dynamic> json) {
    return Tracker(
      id: json["id"],
      name: json["name"],
      type:
          json["type"] ?? "habit", // PŘIDÁNO (defaultně habit pro starší data)
      date: DateTime.parse(json["date"]),
      done: json["done"],
    );
  }
}
