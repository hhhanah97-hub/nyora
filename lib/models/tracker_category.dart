class TrackerCategory {
  final String id;
  final String name;
  final String type; // "habit" nebo "cycle"
  final List<int> weekdays;

  TrackerCategory({
    required this.id,
    required this.name,
    required this.type,
    required this.weekdays,
  });

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "type": type, "weekdays": weekdays};
  }

  factory TrackerCategory.fromJson(Map<String, dynamic> json) {
    return TrackerCategory(
      id: json["id"],
      name: json["name"],
      type: json["type"],
      weekdays: List<int>.from(json["weekdays"] ?? []),
    );
  }
}
