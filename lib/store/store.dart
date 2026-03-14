import 'package:flutter/material.dart';
import '../models/event.dart';
import 'dart:convert';
import '../models/event_category.dart';
import '../models/finance.dart';
import '../models/task.dart';
import '../models/tracker.dart';
import '../models/tracker_category.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class Store extends ChangeNotifier {
  List<Event> events = [];
  List<Finance> finances = [];
  List<Task> tasks = [];

  List<Tracker> trackers = [];
  List<TrackerCategory> trackerCategories = [];

  /// TASKS

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

  /// EVENT CATEGORIES

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

  /// SAVE

  void save() {
    final eventsJson = events.map((e) => e.toJson()).toList();
    final financesJson = finances.map((f) => f.toJson()).toList();
    final tasksJson = tasks.map((t) => t.toJson()).toList();

    html.window.localStorage['events'] = jsonEncode(eventsJson);
    html.window.localStorage['finances'] = jsonEncode(financesJson);
    html.window.localStorage['tasks'] = jsonEncode(tasksJson);

    notifyListeners();
  }

  /// LOAD

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

  /// EVENTS

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

  /// FINANCE

  void addFinance({
    required DateTime date,
    required String text,
    required double amount,
  }) {
    finances.add(Finance(date: date, text: text, amount: amount));

    save();
  }

  /// EXPORT

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

  /// BALANCE

  double getBalance() {
    double total = 0;

    for (var f in finances) {
      total += f.amount;
    }

    return total;
  }

  /// EVENTS FOR DAY

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

  /// FINANCE FOR DAY

  List<Finance> financesForDay(DateTime day) {
    return finances.where((f) {
      return f.date.year == day.year &&
          f.date.month == day.month &&
          f.date.day == day.day;
    }).toList();
  }

  /// TRACKERS

  void addTracker({required DateTime date, required String name}) {
    trackers.add(
      Tracker(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        date: date,
        done: false,
      ),
    );

    save();
    notifyListeners();
  }

  List<Tracker> trackersForDay(DateTime day) {
    final result = <Tracker>[];

    /// existující trackery (už odškrtnuté / uložené)
    for (var t in trackers) {
      if (t.date.year == day.year &&
          t.date.month == day.month &&
          t.date.day == day.day) {
        result.add(t);
      }
    }

    /// habit trackery podle kategorií
    for (var category in trackerCategories) {
      if (category.type != "habit") continue;

      if (!category.weekdays.contains(day.weekday)) continue;

      final exists = result.any((t) => t.name == category.name);

      if (!exists) {
        result.add(
          Tracker(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: category.name,
            date: day,
            done: false,
          ),
        );
      }
    }

    return result;
  }

  List<TrackerCategory> habitsForDay(DateTime day) {
    return trackerCategories.where((c) {
      if (c.type != "habit") return false;

      // pokud nejsou nastaveny dny -> každý den
      if (c.weekdays.isEmpty) return true;

      return c.weekdays.contains(day.weekday);
    }).toList();
  }

  /// TRACKER CATEGORIES

  void addTrackerCategory(String name, String type, List<int> weekdays) {
    trackerCategories.add(
      TrackerCategory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        type: type,
        weekdays: weekdays,
      ),
    );

    notifyListeners();
  }

  List<String> trackerTypes = ["habit", "cycle"];
  void addTrackerType(String type) {
    trackerTypes.add(type);
    notifyListeners();
  }

  void removeTrackerType(String type) {
    trackerTypes.remove(type);
    notifyListeners();
  }

  void toggleHabit(String name, DateTime date, bool done) {
    trackers.removeWhere(
      (t) =>
          t.name == name &&
          t.date.year == date.year &&
          t.date.month == date.month &&
          t.date.day == date.day,
    );

    if (done) {
      trackers.add(
        Tracker(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          date: date,
          done: true,
        ),
      );
    }

    save();
  }

  void addPeriodDay(DateTime date) {
    trackers.add(
      Tracker(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: "Menstruace",
        date: date,
        done: true,
      ),
    );

    save();
    notifyListeners();
  }

  DateTime? getLastPeriodStart() {
    final periodDays = trackers.where((t) => t.name == "Menstruace").toList();

    if (periodDays.isEmpty) return null;

    periodDays.sort((a, b) => b.date.compareTo(a.date));

    return periodDays.first.date;
  }

  DateTime? getOvulationDay() {
    final start = getLastPeriodStart();

    if (start == null) return null;

    return start.add(const Duration(days: 14));
  }

  bool isFertileDay(DateTime day) {
    final ovulation = getOvulationDay();

    if (ovulation == null) return false;

    final fertileStart = ovulation.subtract(const Duration(days: 3));
    final fertileEnd = ovulation.add(const Duration(days: 1));

    return !day.isBefore(fertileStart) && !day.isAfter(fertileEnd);
  }

  DateTime? getNextPeriod() {
    final start = getLastPeriodStart();

    if (start == null) return null;

    return start.add(const Duration(days: 28));
  }

  bool isPeriodDay(DateTime day) {
    final start = getLastPeriodStart();

    if (start == null) return false;

    final diff = day.difference(start).inDays;

    if (diff < 0) return false;

    final cycleDay = diff % 28;

    return cycleDay >= 0 && cycleDay <= 4;
  }

  int getHabitStreak(String habitName) {
    final habitTrackers = trackers
        .where((t) => t.name == habitName && t.done)
        .toList();

    habitTrackers.sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime day = DateTime.now();

    for (var t in habitTrackers) {
      if (t.date.year == day.year &&
          t.date.month == day.month &&
          t.date.day == day.day) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }
}
