import 'package:flutter/material.dart';
import '../models/event.dart';
import 'dart:convert';
import '../models/event_category.dart';
import '../models/finance.dart';
import '../models/task.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class Store extends ChangeNotifier {
  List<Event> events = [];
  List<Finance> finances = [];
  List<Task> tasks = [];
  List<Task> tasksForDay(DateTime day) {
    return tasks.where((t) {
      return t.date.year == day.year &&
          t.date.month == day.month &&
          t.date.day == day.day;
    }).toList();
  }

  void deleteTask(Task task) {
    tasks.remove(task);
    save();
    notifyListeners();
  }

  void addTask({
    required DateTime date,
    required String text,
    required int timeMinutes,
  }) {
    tasks.add(
      Task(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        date: date,
        text: text,
        done: false,
        repeatWeekday: 0,
        timeMinutes: timeMinutes,
      ),
    );
    save();
    notifyListeners();
  }

  List<Category> categories = [
    Category(name: "Osobní", color: Colors.green),
    Category(name: "Práce", color: Colors.blue),
  ];

  void saveCategories() {
    final jsonList = categories.map((c) => c.toJson()).toList();

    html.window.localStorage['categories'] = jsonEncode(jsonList);
  }

  Future<void> loadCategories() async {
    try {
      final text = html.window.localStorage['categories'];

      if (text == null) return;

      final decoded = jsonDecode(text);

      categories.clear();

      for (var item in decoded) {
        categories.add(Category.fromJson(Map<String, dynamic>.from(item)));
      }
    } catch (e) {
      print("CATEGORY LOAD ERROR: $e");
    }
  }

  Color getCategoryColor(String categoryName) {
    for (var c in categories) {
      if (c.name == categoryName) {
        return c.color;
      }
    }

    return Colors.grey;
  }

  void save() {
    final eventsJson = events.map((e) => e.toJson()).toList();
    final financesJson = finances.map((f) => f.toJson()).toList();
    final tasksJson = tasks.map((t) => t.toJson()).toList();

    html.window.localStorage['events'] = jsonEncode(eventsJson);
    html.window.localStorage['finances'] = jsonEncode(financesJson);
    html.window.localStorage['tasks'] = jsonEncode(tasksJson);

    notifyListeners();
  }

  Future<void> load() async {
    try {
      final eventsText = html.window.localStorage['events'];
      final financesText = html.window.localStorage['finances'];
      final tasksText = html.window.localStorage['tasks'];

      events.clear();
      finances.clear();
      tasks.clear();

      if (eventsText != null) {
        final decoded = jsonDecode(eventsText);

        for (var item in decoded) {
          events.add(Event.fromJson(Map<String, dynamic>.from(item)));
        }
      }

      if (financesText != null) {
        final decoded = jsonDecode(financesText);

        for (var item in decoded) {
          finances.add(Finance.fromJson(Map<String, dynamic>.from(item)));
        }
      }

      if (tasksText != null) {
        final decoded = jsonDecode(tasksText);

        for (var item in decoded) {
          tasks.add(Task.fromJson(Map<String, dynamic>.from(item)));
        }
      }

      notifyListeners();
    } catch (e) {
      print("LOAD ERROR: $e");

      events.clear();
      finances.clear();
      tasks.clear();
    }
  }

  void addEvent({
    required DateTime date,
    required int timeMinutes,
    required String text,
    String category = "",
    String repeat = "",
  }) {
    events.add(
      Event(
        date: date,
        timeMinutes: timeMinutes,
        text: text,
        category: category,
        repeat: repeat,
      ),
    );

    save();
  }

  void addFinance({
    required DateTime date,
    required String text,
    required double amount,
  }) {
    finances.add(Finance(date: date, text: text, amount: amount));

    save();
  }

  String exportToJson() {
    final jsonList = events.map((e) => e.toJson()).toList();

    return jsonEncode(jsonList);
  }

  void importFromJson(String jsonString) {
    final List decoded = jsonDecode(jsonString);

    events.clear();

    for (var item in decoded) {
      events.add(Event.fromJson(Map<String, dynamic>.from(item)));
    }

    save();
    notifyListeners();
  }

  double getBalance() {
    double total = 0;

    for (var f in finances) {
      total += f.amount;
    }

    return total;
  }

  List<Event> eventsForDay(DateTime day) {
    final result = <Event>[];

    for (var e in events) {
      if (e.repeat == "") {
        if (e.date.year == day.year &&
            e.date.month == day.month &&
            e.date.day == day.day) {
          result.add(e);
        }
      }

      if (e.repeat == "daily") {
        if (!day.isBefore(e.date)) {
          result.add(e);
        }
      }

      if (e.repeat == "weekly") {
        if (!day.isBefore(e.date) && day.weekday == e.date.weekday) {
          result.add(e);
        }
      }

      if (e.repeat == "monthly") {
        if (!day.isBefore(e.date) && day.day == e.date.day) {
          result.add(e);
        }
      }

      if (e.repeat == "yearly") {
        if (!day.isBefore(e.date) &&
            day.day == e.date.day &&
            day.month == e.date.month) {
          result.add(e);
        }
      }
    }

    result.sort((a, b) => a.timeMinutes.compareTo(b.timeMinutes));

    return result;
  }

  List<Finance> financesForDay(DateTime day) {
    return finances.where((f) {
      return f.date.year == day.year &&
          f.date.month == day.month &&
          f.date.day == day.day;
    }).toList();
  }
}
