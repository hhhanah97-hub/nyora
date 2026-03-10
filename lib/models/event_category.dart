import 'package:flutter/material.dart';

class Category {
  String name;
  Color color;

  Category({required this.name, required this.color});

  Map<String, dynamic> toJson() {
    return {"name": name, "color": color.value};
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(name: json["name"], color: Color(json["color"]));
  }
}
