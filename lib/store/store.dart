import 'package:flutter/material.dart';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import '../models/event.dart';
import '../models/event_category.dart';
import '../models/finance.dart';
import '../models/task.dart';
import '../models/tracker.dart';
import '../models/tracker_category.dart';
import '../theme/app_theme.dart'; // TADY JE TEN NOVÝ IMPORT PRO TÉMA

class Store extends ChangeNotifier {
  List<Event> events = [];
  List<Finance> finances = [];
  List<Task> tasks = [];
  List<Tracker> trackers = [];
  List<TrackerCategory> trackerCategories = [];

  // --- TÉMA APLIKACE A BARVY ---
  AppTheme appTheme = AppTheme.defaultTheme();

  void updateTheme(AppTheme newTheme) {
    appTheme = newTheme;
    save();
    notifyListeners();
  }

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
    final trackersJson = trackers.map((t) => t.toJson()).toList();
    final trackerCategoriesJson = trackerCategories
        .map((c) => c.toJson())
        .toList();

    html.window.localStorage['events'] = jsonEncode(eventsJson);
    html.window.localStorage['finances'] = jsonEncode(financesJson);
    html.window.localStorage['tasks'] = jsonEncode(tasksJson);
    html.window.localStorage['trackers'] = jsonEncode(trackersJson);
    html.window.localStorage['trackerCategories'] = jsonEncode(
      trackerCategoriesJson,
    );

    // ULOŽENÍ TÉMATU A BAREV
    html.window.localStorage['theme'] = jsonEncode(appTheme.toJson());

    notifyListeners();
  }

  /// LOAD
  Future<void> load() async {
    try {
      final eventsText = html.window.localStorage['events'];
      final financesText = html.window.localStorage['finances'];
      final tasksText = html.window.localStorage['tasks'];
      final trackersText = html.window.localStorage['trackers'];
      final trackerCategoriesText =
          html.window.localStorage['trackerCategories'];

      // NAČTENÍ TÉMATU A BAREV
      final themeText = html.window.localStorage['theme'];

      events.clear();
      finances.clear();
      tasks.clear();
      trackers.clear();
      trackerCategories.clear();

      if (themeText != null) {
        appTheme = AppTheme.fromJson(jsonDecode(themeText));
      }

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

      if (trackersText != null) {
        final decoded = jsonDecode(trackersText);
        for (var item in decoded) {
          trackers.add(Tracker.fromJson(Map<String, dynamic>.from(item)));
        }
      }

      if (trackerCategoriesText != null) {
        final decoded = jsonDecode(trackerCategoriesText);
        for (var item in decoded) {
          trackerCategories.add(
            TrackerCategory.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }

      notifyListeners();
    } catch (e) {
      print("LOAD ERROR: $e");
      events.clear();
      finances.clear();
      tasks.clear();
      trackers.clear();
      trackerCategories.clear();
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

  /// TRACKERS (HABITS)
  void addTracker({required DateTime date, required String name}) {
    trackers.add(
      Tracker(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        type: "habit",
        date: date,
        done: false,
      ),
    );
    save();
    notifyListeners();
  }

  List<Tracker> trackersForDay(DateTime day) {
    final result = <Tracker>[];

    for (var t in trackers) {
      if (t.type == "habit" &&
          t.date.year == day.year &&
          t.date.month == day.month &&
          t.date.day == day.day) {
        result.add(t);
      }
    }

    for (var category in trackerCategories) {
      if (category.type != "habit") continue;
      if (!category.weekdays.contains(day.weekday)) continue;

      final exists = result.any((t) => t.name == category.name);

      if (!exists) {
        result.add(
          Tracker(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: category.name,
            type: "habit",
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
          t.type == "habit" &&
          t.date.year == date.year &&
          t.date.month == date.month &&
          t.date.day == date.day,
    );

    if (done) {
      trackers.add(
        Tracker(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          type: "habit",
          date: date,
          done: true,
        ),
      );
    }
    save();
    notifyListeners();
  }

  int getHabitStreak(String habitName) {
    final habitTrackers = trackers
        .where((t) => t.name == habitName && t.type == "habit" && t.done)
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

  /// MENSTRUATION CYCLE LOGIC

  // Pomocná metoda pro porovnání pouze data (bez času)
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void addPeriodDay(DateTime date) {
    // Automaticky přidá zvolený den a další 3 dny (celkem 4 dny)
    for (int i = 0; i < 4; i++) {
      final currentDay = date.add(Duration(days: i));
      final exists = trackers.any(
        (t) => t.type == "cycle" && _isSameDay(t.date, currentDay),
      );

      if (!exists) {
        trackers.add(
          Tracker(
            id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
            name: "Menstruace",
            type: "cycle",
            date: currentDay,
            done: true,
          ),
        );
      }
    }

    if (!trackerCategories.any((c) => c.name == "Menstruace")) {
      trackerCategories.add(
        TrackerCategory(
          id: "cycle",
          name: "Menstruace",
          type: "cycle",
          weekdays: [],
        ),
      );
    }

    save();
    notifyListeners();
  }

  List<DateTime> getActualPeriodDays() {
    return trackers
        .where((t) => t.type == "cycle")
        .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
        .toList();
  }

  // Najde všechny "začátky" cyklů z historie
  List<DateTime> getCycleStarts() {
    final days = getActualPeriodDays();
    if (days.isEmpty) return [];

    days.sort((a, b) => a.compareTo(b)); // Vzestupně od nejstaršího
    List<DateTime> starts = [days.first];

    for (int i = 1; i < days.length; i++) {
      if (days[i].difference(days[i - 1]).inDays > 1) {
        // Mezera > 1 den znamená nový cyklus
        starts.add(days[i]);
      }
    }
    return starts.reversed.toList(); // Sestupně (od nejnovějšího)
  }

  // Najde správný začátek cyklu pro jakékoliv konkrétní datum (kvůli historii)
  DateTime? getCycleStartForDate(DateTime day) {
    final starts = getCycleStarts();
    for (var start in starts) {
      // Najde první minulý (nebo aktuální) začátek cyklu k danému dni
      if (!start.isAfter(day)) {
        return start;
      }
    }
    return null;
  }

  DateTime? getExpectedNextPeriodStart(DateTime day) {
    final start = getCycleStartForDate(day);
    if (start == null) return null;
    return start.add(
      const Duration(days: 28),
    ); // Výpočet relativně k hledanému dni
  }

  DateTime? getOvulationDay(DateTime day) {
    final start = getCycleStartForDate(day);
    if (start == null) return null;
    return start.add(const Duration(days: 14));
  }

  bool isFertileDay(DateTime day) {
    final ovulation = getOvulationDay(day);
    if (ovulation == null) return false;

    final fertileStart = ovulation.subtract(const Duration(days: 3));
    final fertileEnd = ovulation.add(const Duration(days: 1));

    return !day.isBefore(fertileStart) && !day.isAfter(fertileEnd);
  }

  bool isPeriodDay(DateTime day) {
    final actualDays = getActualPeriodDays();
    return actualDays.any((d) => _isSameDay(d, day));
  }
}
