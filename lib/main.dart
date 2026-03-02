import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:universal_html/html.dart' as html;

void main() {
  runApp(const NyoraJournalApp());
}

///
/// NYORA JOURNAL — single-file demo (in-memory data)
/// - Real monthly calendar (correct weekday alignment)
/// - Tap month/year to pick month & year
/// - Tap a day -> Day screen (events, tasks, finance preview)
/// - Dots under days with any event/task (including repeating)
/// - Add Event/Task with +, pick date/time, repeat weekday
/// - Tasks have checklist toggle
/// - Finance: income/expense/overview per month + running balance
/// - Scrollable layouts (phone-friendly)
///

class NyoraJournalApp extends StatefulWidget {
  const NyoraJournalApp({super.key});

  @override
  State<NyoraJournalApp> createState() => _NyoraJournalAppState();
}

class NyoraPalette {
  final Color bg;
  final Color card;
  final Color accent;

  final Color periodRing;
  final Color fertileRing;
  final Color predictedPeriodRing;

  const NyoraPalette({
    required this.bg,
    required this.card,
    required this.accent,
    required this.periodRing,
    required this.fertileRing,
    required this.predictedPeriodRing,
  });

  NyoraPalette copyWith({
    Color? bg,
    Color? card,
    Color? accent,
    Color? periodRing,
    Color? fertileRing,
    Color? predictedPeriodRing,
  }) {
    return NyoraPalette(
      bg: bg ?? this.bg,
      card: card ?? this.card,
      accent: accent ?? this.accent,
      periodRing: periodRing ?? this.periodRing,
      fertileRing: fertileRing ?? this.fertileRing,
      predictedPeriodRing: predictedPeriodRing ?? this.predictedPeriodRing,
    );
  }
}

class PaletteController extends ChangeNotifier {
  NyoraPalette palette;

  PaletteController()
    : palette = const NyoraPalette(
        bg: Color(0xFFFFE4EE),
        card: Color(0xFFFFD1E2),
        accent: Color(0xFF7D0E2C),
        periodRing: Color(0xFFA40024),
        fertileRing: Color(0xFF69B7FF),
        predictedPeriodRing: Color(0xFF8E8E8E),
      );

  void update(NyoraPalette p) {
    palette = p;
    notifyListeners();
    _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('bg', palette.bg.value);
    await prefs.setInt('card', palette.card.value);
    await prefs.setInt('accent', palette.accent.value);
    await prefs.setInt('periodRing', palette.periodRing.value);
    await prefs.setInt('fertileRing', palette.fertileRing.value);
    await prefs.setInt(
      'predictedPeriodRing',
      palette.predictedPeriodRing.value,
    );
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    palette = NyoraPalette(
      bg: Color(prefs.getInt('bg') ?? palette.bg.value),
      card: Color(prefs.getInt('card') ?? palette.card.value),
      accent: Color(prefs.getInt('accent') ?? palette.accent.value),
      periodRing: Color(prefs.getInt('periodRing') ?? palette.periodRing.value),
      fertileRing: Color(
        prefs.getInt('fertileRing') ?? palette.fertileRing.value,
      ),
      predictedPeriodRing: Color(
        prefs.getInt('predictedPeriodRing') ??
            palette.predictedPeriodRing.value,
      ),
    );

    notifyListeners();
  }

  void setBg(Color c) => update(palette.copyWith(bg: c));
  void setCard(Color c) => update(palette.copyWith(card: c));
  void setAccent(Color c) => update(palette.copyWith(accent: c));
  void setPeriodRing(Color c) => update(palette.copyWith(periodRing: c));
  void setFertileRing(Color c) => update(palette.copyWith(fertileRing: c));
  void setPredictedPeriodRing(Color c) =>
      update(palette.copyWith(predictedPeriodRing: c));
}

bool isDark(Color c) => c.computeLuminance() < 0.35;
const List<Color> nyoraColorOptions = [
  Color.fromARGB(255, 99, 5, 43),
  Color.fromARGB(255, 164, 9, 71),
  Color.fromARGB(255, 247, 13, 106),
  Color.fromARGB(255, 64, 16, 35),
  Color.fromARGB(255, 146, 37, 81),
  Color.fromARGB(255, 238, 121, 168),
  Color.fromARGB(255, 3, 34, 47),
  Color.fromARGB(255, 8, 96, 134),
  Color.fromARGB(255, 117, 199, 234),
  Color.fromARGB(255, 73, 124, 146),
  Color.fromARGB(255, 55, 3, 3),
  Color.fromARGB(255, 249, 85, 85),
  Color.fromARGB(255, 245, 231, 231),
  Color.fromARGB(255, 145, 140, 140),
  Color.fromARGB(255, 36, 35, 35),
];

class _NyoraJournalAppState extends State<NyoraJournalApp> {
  final Store store = Store();
  final PaletteController paletteCtrl = PaletteController();

  ThemeMode mode = ThemeMode.light;
  @override
  void initState() {
    super.initState();
    paletteCtrl.addListener(_onPaletteChanged);
    _loadPalette();
    store.loadFromStorage();
  }

  Future<void> _loadPalette() async {
    await paletteCtrl.load();
  }

  void _onPaletteChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    paletteCtrl.removeListener(_onPaletteChanged);
    super.dispose();
  }

  void toggleTheme() {
    setState(() {
      mode = (mode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void testChangePalette() {
    paletteCtrl.setAccent(const Color(0xFFB00020));
  }

  @override
  Widget build(BuildContext context) {
    final p = paletteCtrl.palette;
    // Palette (elegant): pale pink background + burgundy accent
    final Color pinkBg = p.bg;
    final Color pinkCard = p.card;
    final Color burgundy = p.accent;
    final Color burgundyDark = Color(0xFF4F061B);

    final ThemeData light = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: pinkBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: burgundy,
        brightness: Brightness.light,
      ).copyWith(primary: burgundy, secondary: burgundy, surface: pinkCard),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.75),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: burgundy.withValues(alpha: 0.25)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: burgundy.withValues(alpha: 0.18)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: burgundy.withValues(alpha: 0.55),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      cardTheme: CardThemeData(
        color: pinkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
    final ThemeData dark = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: burgundyDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: burgundy,
        brightness: Brightness.dark,
      ).copyWith(primary: pinkCard, secondary: pinkCard, surface: burgundy),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.35),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      cardTheme: CardThemeData(
        color: burgundy,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
    // TEST: jen pro ověření, pak smažeme
    // paletteCtrl.setAccent(const Color(0xFFB00020));
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nyora Journal',
      theme: light,
      darkTheme: dark,
      themeMode: mode,
      home: HomeScreen(
        store: store,
        paletteCtrl: paletteCtrl,
        onToggleTheme: toggleTheme,
      ),
    );
  }
}

// =======================
// Models + Store
// =======================

String _id() => DateTime.now().microsecondsSinceEpoch.toString();

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

int minutesOf(TimeOfDay t) => t.hour * 60 + t.minute;

String fmt2(int n) => n.toString().padLeft(2, '0');

String formatDateCs(DateTime d) => '${d.day}/${d.month}/${d.year}';

String formatMonthYearCs(DateTime d) => '${d.month}/${d.year}';

String formatTimeFromMinutes(int m) => '${fmt2(m ~/ 60)}:${fmt2(m % 60)}';

int weekdayCsMon1(DateTime d) {
  // DateTime.weekday: Mon=1..Sun=7 (perfect)
  return d.weekday;
}

String weekdayShortCs(int wMon1) {
  // 1..7
  return switch (wMon1) {
    1 => 'Po',
    2 => 'Út',
    3 => 'St',
    4 => 'Čt',
    5 => 'Pá',
    6 => 'So',
    7 => 'Ne',
    _ => '',
  };
}

String weekdayNameCs(int wMon1) {
  return switch (wMon1) {
    1 => 'Každé pondělí',
    2 => 'Každé úterý',
    3 => 'Každou středu',
    4 => 'Každý čtvrtek',
    5 => 'Každý pátek',
    6 => 'Každou sobotu',
    7 => 'Každou neděli',
    _ => 'Neopakovat',
  };
}

class EventItem {
  final String id;
  final DateTime date; // date-only for base date
  final int timeMinutes;
  final String text;
  final int repeatWeekday; // 0 none, 1..7 Mon..Sun

  EventItem({
    required this.id,
    required this.date,
    required this.timeMinutes,
    required this.text,
    required this.repeatWeekday,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'timeMinutes': timeMinutes,
      'text': text,
      'repeatWeekday': repeatWeekday,
    };
  }

  factory EventItem.fromMap(Map<String, dynamic> map) {
    return EventItem(
      id: map['id'],
      date: DateTime.parse(map['date']),
      timeMinutes: map['timeMinutes'],
      text: map['text'],
      repeatWeekday: map['repeatWeekday'],
    );
  }
}

class TaskItem {
  final String id;
  final DateTime date; // base date
  final int timeMinutes;
  final String text;
  bool done;
  final int repeatWeekday; // 0 none, 1..7

  TaskItem({
    required this.id,
    required this.date,
    required this.timeMinutes,
    required this.text,
    required this.repeatWeekday,
    this.done = false,
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

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      id: map['id'],
      date: DateTime.parse(map['date']),
      timeMinutes: map['timeMinutes'],
      text: map['text'],
      repeatWeekday: map['repeatWeekday'],
      done: map['done'] ?? false,
    );
  }
}

class MoneyItem {
  final String id;
  final DateTime date; // date-only
  final String text;
  final int amountCzk; // income positive, expense negative

  MoneyItem({
    required this.id,
    required this.date,
    required this.text,
    required this.amountCzk,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'text': text,
      'amountCzk': amountCzk,
    };
  }

  factory MoneyItem.fromMap(Map<String, dynamic> map) {
    return MoneyItem(
      id: map['id'],
      date: DateTime.parse(map['date']),
      text: map['text'],
      amountCzk: map['amountCzk'],
    );
  }
}

class PeriodEntry {
  final DateTime startDate; // dateOnly
  final int lengthDays; // 1..10 (nebo víc)

  PeriodEntry({required this.startDate, required this.lengthDays});
  Map<String, dynamic> toMap() {
    return {'startDate': startDate.toIso8601String(), 'lengthDays': lengthDays};
  }

  factory PeriodEntry.fromMap(Map<String, dynamic> map) {
    return PeriodEntry(
      startDate: DateTime.parse(map['startDate']),
      lengthDays: map['lengthDays'],
    );
  }
}

class Store extends ChangeNotifier {
  final List<EventItem> events = [];
  final List<TaskItem> tasks = [];
  final List<MoneyItem> money = [];
  final List<PeriodEntry> periods = [];

  Future<void> _save() async {
    final json = exportToJson();
    html.window.localStorage['nyora_data'] = json;
  }

  void loadFromStorage() {
    final json = html.window.localStorage['nyora_data'];
    if (json != null) {
      importFromJson(json);
    }
  }

  void addEvent(EventItem e) {
    events.add(e);
    notifyListeners();
    _save();
  }

  void deleteEvent(String id) {
    events.removeWhere((e) => e.id == id);
    notifyListeners();
    _save();
  }

  void addTask(TaskItem t) {
    tasks.add(t);
    notifyListeners();
    _save();
  }

  void deleteTask(String id) {
    tasks.removeWhere((t) => t.id == id);
    notifyListeners();
    _save();
  }

  void toggleTaskDone(String id) {
    final idx = tasks.indexWhere((t) => t.id == id);
    if (idx >= 0) {
      tasks[idx].done = !tasks[idx].done;
      notifyListeners();
      _save();
    }
  }

  void addMoney(MoneyItem m) {
    money.add(m);
    notifyListeners();
    _save();
  }

  // =======================
  // PERIOD TRACKING
  // =======================

  void addPeriodStart(DateTime startDate, {int lengthDays = 5}) {
    final s = dateOnly(startDate);

    periods.removeWhere((p) => dateOnly(p.startDate) == s);

    periods.add(PeriodEntry(startDate: s, lengthDays: lengthDays.clamp(1, 31)));

    periods.sort((a, b) => a.startDate.compareTo(b.startDate));

    notifyListeners();
    _save();
  }

  void removePeriodStart(DateTime startDate) {
    final s = dateOnly(startDate);
    periods.removeWhere((p) => dateOnly(p.startDate) == s);
    notifyListeners();
    _save();
  }

  PeriodEntry? periodStartingOn(DateTime day) {
    final d = dateOnly(day);
    for (final p in periods) {
      if (dateOnly(p.startDate) == d) return p;
    }
    return null;
  }

  bool isPeriodDay(DateTime day) {
    final d = dateOnly(day);
    for (final p in periods) {
      final start = dateOnly(p.startDate);
      final endExclusive = start.add(Duration(days: p.lengthDays));
      if (!d.isBefore(start) && d.isBefore(endExclusive)) return true;
    }
    return false;
  }

  int? avgCycleLength({int takeLast = 6}) {
    if (periods.length < 2) return null;

    final starts = periods.map((p) => dateOnly(p.startDate)).toList()
      ..sort((a, b) => a.compareTo(b));

    final diffs = <int>[];
    for (int i = 1; i < starts.length; i++) {
      diffs.add(starts[i].difference(starts[i - 1]).inDays);
    }

    final tail = diffs.length <= takeLast
        ? diffs
        : diffs.sublist(diffs.length - takeLast);

    final filtered = tail.where((d) => d >= 15 && d <= 60).toList();
    if (filtered.isEmpty) return null;

    final sum = filtered.fold<int>(0, (s, v) => s + v);
    return (sum / filtered.length).round();
  }

  DateTime? predictedNextPeriodStart() {
    if (periods.isEmpty) return null;

    final last = periods
        .map((p) => dateOnly(p.startDate))
        .reduce((a, b) => a.isAfter(b) ? a : b);

    final avg = avgCycleLength();
    if (avg == null) return null;

    return last.add(Duration(days: avg));
  }

  ({DateTime start, DateTime end})? predictedFertileWindow() {
    final next = predictedNextPeriodStart();
    if (next == null) return null;

    final ovulation = next.subtract(const Duration(days: 14));
    final start = ovulation.subtract(const Duration(days: 5));
    final end = ovulation;

    return (start: dateOnly(start), end: dateOnly(end));
  }

  bool isPredictedFertileDay(DateTime day) {
    final win = predictedFertileWindow();
    if (win == null) return false;
    final d = dateOnly(day);
    return !d.isBefore(win.start) && !d.isAfter(win.end);
  }

  // =======================
  // EXISTING HELPERS
  // =======================

  int balanceAll() => money.fold(0, (sum, m) => sum + m.amountCzk);

  bool hasAnythingOn(DateTime day) {
    final d = dateOnly(day);
    return eventsForDay(d).isNotEmpty || tasksForDay(d).isNotEmpty;
  }

  List<EventItem> eventsForDay(DateTime day) {
    final d = dateOnly(day);
    final int w = weekdayCsMon1(d);

    final list = events.where((e) {
      final base = dateOnly(e.date);
      if (base == d) return true;
      if (e.repeatWeekday != 0 && e.repeatWeekday == w) return true;
      return false;
    }).toList();

    list.sort((a, b) => a.timeMinutes.compareTo(b.timeMinutes));
    return list;
  }

  List<TaskItem> tasksForDay(DateTime day) {
    final d = dateOnly(day);
    final int w = weekdayCsMon1(d);

    final list = tasks.where((t) {
      final base = dateOnly(t.date);
      if (base == d) return true;
      if (t.repeatWeekday != 0 && t.repeatWeekday == w) return true;
      return false;
    }).toList();

    list.sort((a, b) => a.timeMinutes.compareTo(b.timeMinutes));
    return list;
  }

  List<MoneyItem> moneyForMonth(int year, int month) {
    return money
        .where((m) => m.date.year == year && m.date.month == month)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  String exportToJson() {
    final data = {
      'events': events.map((e) => e.toMap()).toList(),
      'tasks': tasks.map((t) => t.toMap()).toList(),
      'money': money.map((p) => p.toMap()).toList(),
      'periods': periods.map((p) => p.toMap()).toList(),
    };
    return jsonEncode(data);
  }

  void importFromJson(String jsonString) {
    final data = jsonDecode(jsonString);

    events
      ..clear()
      ..addAll(
        (data['events'] as List).map((e) => EventItem.fromMap(e)).toList(),
      );

    tasks
      ..clear()
      ..addAll(
        (data['tasks'] as List).map((t) => TaskItem.fromMap(t)).toList(),
      );

    money
      ..clear()
      ..addAll(
        (data['money'] as List).map((m) => MoneyItem.fromMap(m)).toList(),
      );

    periods
      ..clear()
      ..addAll(
        (data['periods'] as List).map((p) => PeriodEntry.fromMap(p)).toList(),
      );

    notifyListeners();
    _save();
  }
}
// =======================
// Home Screen (Calendar)
// =======================

class HomeScreen extends StatefulWidget {
  final Store store;
  final PaletteController paletteCtrl;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.store,
    required this.paletteCtrl,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime selectedDay;
  late DateTime visibleMonth; // any day within that month

  @override
  void initState() {
    super.initState();
    selectedDay = dateOnly(DateTime.now());
    visibleMonth = DateTime(selectedDay.year, selectedDay.month, 1);
    widget.store.addListener(_onStoreChanged);
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Nastavení",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                ListTile(
                  leading: const Icon(Icons.palette),
                  title: const Text("Vzhled aplikace"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(context); // zavře první panel
                    _openAppearanceSettings(); // otevře druhý
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: const Text("Exportovat data"),
                  onTap: () {
                    final json = widget.store.exportToJson();
                    Navigator.pop(context);

                    final bytes = utf8.encode(json);
                    final blob = html.Blob([bytes]);
                    final url = html.Url.createObjectUrlFromBlob(blob);

                    html.AnchorElement(href: url)
                      ..setAttribute("download", "nyora_backup.json")
                      ..click();

                    html.Url.revokeObjectUrl(url);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text("Importovat data"),
                  onTap: () async {
                    Navigator.pop(context);

                    final uploadInput = html.FileUploadInputElement();
                    uploadInput.accept = ".json";
                    uploadInput.click();

                    uploadInput.onChange.listen((event) {
                      final file = uploadInput.files?.first;
                      if (file == null) return;

                      final reader = html.FileReader();
                      reader.readAsText(file);

                      reader.onLoadEnd.listen((event) {
                        final jsonString = reader.result as String;
                        widget.store.importFromJson(jsonString);
                      });
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openAppearanceSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vzhled aplikace',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                ListTile(
                  title: const Text("Pozadí aplikace"),
                  trailing: const Icon(Icons.color_lens),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => _ColorPickerDialog(
                        title: "Vyber barvu pozadí",
                        initialColor: widget.paletteCtrl.palette.bg,
                        onColorSelected: widget.paletteCtrl.setBg,
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text("Dlaždice"),
                  trailing: const Icon(Icons.color_lens),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => _ColorPickerDialog(
                        title: "Vyber barvu dlaždic",
                        initialColor: widget.paletteCtrl.palette.card,
                        onColorSelected: widget.paletteCtrl.setCard,
                      ),
                    );
                  },
                ),

                ListTile(
                  title: const Text("Hlavní akcent"),
                  trailing: const Icon(Icons.color_lens),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => _ColorPickerDialog(
                        title: "Vyber barvu akcentu",
                        initialColor: widget.paletteCtrl.palette.accent,
                        onColorSelected: widget.paletteCtrl.setAccent,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _pickMonthYear() async {
    int tempYear = visibleMonth.year;
    int tempMonth = visibleMonth.month;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Vybrat měsíc / rok'),
          content: StatefulBuilder(
            builder: (ctx2, setInner) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Expanded(child: Text('Rok')),
                      DropdownButton<int>(
                        value: tempYear,
                        items: List.generate(21, (i) {
                          final y = DateTime.now().year - 10 + i;
                          return DropdownMenuItem(value: y, child: Text('$y'));
                        }),
                        onChanged: (v) =>
                            setInner(() => tempYear = v ?? tempYear),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Expanded(child: Text('Měsíc')),
                      DropdownButton<int>(
                        value: tempMonth,
                        items: List.generate(12, (i) {
                          final m = i + 1;
                          return DropdownMenuItem(value: m, child: Text('$m'));
                        }),
                        onChanged: (v) =>
                            setInner(() => tempMonth = v ?? tempMonth),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Zrušit'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  visibleMonth = DateTime(tempYear, tempMonth, 1);
                  // keep selected day inside visible month if possible
                  selectedDay = DateTime(tempYear, tempMonth, 1);
                });
                Navigator.pop(ctx);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _openDay(DateTime day) {
    final d = dateOnly(day);
    setState(() => selectedDay = d);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DayScreen(store: widget.store, day: d),
      ),
    );
  }

  void _openFinanceForVisibleMonth() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FinanceScreen(store: widget.store, month: visibleMonth),
      ),
    );
  }

  void _shiftMonth(int delta) {
    setState(() {
      visibleMonth = DateTime(visibleMonth.year, visibleMonth.month + delta, 1);
      selectedDay = DateTime(visibleMonth.year, visibleMonth.month, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              // Top header bar (month/year button + gear)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: _pickMonthYear,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Text(
                          formatMonthYearCs(visibleMonth),
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: _openSettings,
                      icon: const Icon(Icons.settings),
                      tooltip: 'Nastavení',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragEnd: (details) {
                  final v = details.primaryVelocity ?? 0;
                  if (v > 250) {
                    _shiftMonth(-1);
                  } else if (v < -250) {
                    _shiftMonth(1);
                  }
                },
                child: _CalendarCard(
                  store: widget.store,
                  month: visibleMonth,
                  selectedDay: selectedDay,
                  onDayTap: _openDay,
                ),
              ),

              const SizedBox(height: 14),
              _DayPreviewSection(store: widget.store, day: selectedDay),
            ],
          ),
        ),
      ),
    );
  }
}

class _BigNavButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _BigNavButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Center(
          child: Text(
            text,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  final Store store;
  final DateTime month; // first day inside month
  final DateTime selectedDay;
  final void Function(DateTime) onDayTap;

  const _CalendarCard({
    required this.store,
    required this.month,
    required this.selectedDay,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    // weekday: Mon=1..Sun=7
    final firstWeekday = first.weekday;

    // grid needs offset: Mon column=0
    final leadingEmpty = firstWeekday - 1;
    final totalCells = leadingEmpty + daysInMonth;
    final rows = ((totalCells) / 7).ceil();
    final cellCount = rows * 7;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) {
                final w = i + 1;
                return Expanded(
                  child: Center(
                    child: Text(
                      weekdayShortCs(w),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cellCount,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (ctx, index) {
                final dayNum = index - leadingEmpty + 1;
                if (dayNum < 1 || dayNum > daysInMonth) {
                  return const SizedBox.shrink();
                }
                final day = DateTime(month.year, month.month, dayNum);
                final isSelected = dateOnly(day) == dateOnly(selectedDay);
                final hasDot = store.hasAnythingOn(day);
                final hasPeriodStart = store.periodStartingOn(day) != null;
                final isFertile = store.isPredictedFertileDay(day);
                final nextPeriod = store.predictedNextPeriodStart();
                final isPredictedPeriodStart =
                    nextPeriod != null && dateOnly(day) == dateOnly(nextPeriod);
                final showPredictedPeriodRing =
                    isPredictedPeriodStart && !hasPeriodStart;
                final periodRing = Colors.red.withValues(alpha: 0.65);
                final fertileRing = Colors.lightBlue.withValues(alpha: 0.55);
                final predictedPeriodRing = Colors.grey.withValues(alpha: 0.45);
                Color? ringColor;
                double ringWidth = 1.8;
                if (hasPeriodStart) {
                  ringColor = periodRing;
                } else if (showPredictedPeriodRing) {
                  ringColor = predictedPeriodRing;
                } else if (isFertile) {
                  ringColor = fertileRing;
                }
                final selectionColor = cs.primary.withValues(
                  alpha: isSelected ? 0.40 : 0.10,
                );
                final selectionWidth = isSelected ? 1.6 : 1.0;
                return InkWell(
                  onTap: () => onDayTap(day),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cs.primary.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: ringColor ?? selectionColor,
                        width: ringColor != null ? ringWidth : selectionWidth,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            '$dayNum',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        if (hasPeriodStart)
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 6, top: 6),
                              child: Icon(
                                Icons.water_drop,
                                size: 10,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        if (hasDot)
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: cs.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// =======================
// Day Screen (Today/Selected date)
// =======================
class _DayPreviewSection extends StatelessWidget {
  final Store store;
  final DateTime day;

  const _DayPreviewSection({required this.store, required this.day});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final events = store.eventsForDay(day);
    final tasks = store.tasksForDay(day);

    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatDateCs(day),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              if (events.isEmpty && tasks.isEmpty)
                Text(
                  "Žádné události ani úkoly.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.primary.withValues(alpha: 0.6),
                  ),
                ),

              ...events.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "${formatTimeFromMinutes(e.timeMinutes)}  ${e.text}",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: cs.primary),
                  ),
                ),
              ),

              ...tasks.map(
                (t) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    "${formatTimeFromMinutes(t.timeMinutes)}  ${t.text}",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.primary,
                      decoration: t.done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DayScreen extends StatefulWidget {
  final Store store;
  final DateTime day;

  const DayScreen({super.key, required this.store, required this.day});

  @override
  State<DayScreen> createState() => _DayScreenState();
}

class _DayScreenState extends State<DayScreen> {
  bool expandEvents = true;
  bool expandTasks = true;
  bool expandMoney = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final events = widget.store.eventsForDay(widget.day);
    final tasks = widget.store.tasksForDay(widget.day);
    final periodStart = widget.store.periodStartingOn(widget.day);
    final nextPeriod = widget.store.predictedNextPeriodStart();
    final fertile = widget.store.predictedFertileWindow();

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    tooltip: 'Zavřít',
                  ),
                ],
              ),
              const SizedBox(height: 14),

              _SectionCard(
                title: 'události',
                expanded: expandEvents,
                onToggle: () => setState(() => expandEvents = !expandEvents),
                onAdd: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddItemScreen(
                        store: widget.store,
                        initialDate: widget.day,
                        initialTab: AddTab.planovani,
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    if (events.isEmpty)
                      const _EmptyLine(text: 'Žádné události'),
                    ...events.map(
                      (e) => Dismissible(
                        key: ValueKey('event_${e.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.only(right: 16),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(Icons.delete_outline),
                        ),
                        confirmDismiss: (_) async {
                          return (await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Smazat událost?'),
                                  content: Text('„${e.text}“'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Ne'),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Smazat'),
                                    ),
                                  ],
                                ),
                              )) ??
                              false;
                        },
                        onDismissed: (_) => widget.store.deleteEvent(e.id),
                        child: _LineRow(
                          left: formatTimeFromMinutes(e.timeMinutes),
                          mid: e.text,
                          right: e.repeatWeekday == 0 ? '' : '⟲',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              _SectionCard(
                title: 'úkoly',
                expanded: expandTasks,
                onToggle: () => setState(() => expandTasks = !expandTasks),
                onAdd: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddItemScreen(
                        store: widget.store,
                        initialDate: widget.day,
                        initialTab: AddTab.ukoly,
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    if (tasks.isEmpty) const _EmptyLine(text: 'Žádné úkoly'),
                    ...tasks.map(
                      (t) => Dismissible(
                        key: ValueKey('task_${t.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: const Icon(Icons.delete),
                        ),
                        confirmDismiss: (_) async {
                          return (await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Smazat úkol?'),
                                  content: Text('„${t.text}“'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Ne'),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Smazat'),
                                    ),
                                  ],
                                ),
                              )) ??
                              false;
                        },
                        onDismissed: (_) => widget.store.deleteTask(t.id),
                        child: _TaskRow(
                          time: formatTimeFromMinutes(t.timeMinutes),
                          text: t.text,
                          done: t.done,
                          onToggle: () => widget.store.toggleTaskDone(t.id),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'cyklus',
                expanded: true, // klidně později uděláme collapsible
                onToggle: () {},
                onAdd: () async {
                  // dialog na délku
                  int len = periodStart?.lengthDays ?? 5;

                  final res = await showDialog<int>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Začátek menstruace'),
                      content: StatefulBuilder(
                        builder: (ctx, setInner) {
                          return Row(
                            children: [
                              const Expanded(child: Text('Délka (dny):')),
                              IconButton(
                                onPressed: () => setInner(
                                  () => len = (len - 1).clamp(1, 31),
                                ),
                                icon: const Icon(Icons.remove),
                              ),
                              Text('$len'),
                              IconButton(
                                onPressed: () => setInner(
                                  () => len = (len + 1).clamp(1, 31),
                                ),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          );
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Zrušit'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, len),
                          child: const Text('Uložit'),
                        ),
                      ],
                    ),
                  );

                  if (res != null) {
                    widget.store.addPeriodStart(widget.day, lengthDays: res);
                    setState(() {});
                  }
                },
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            periodStart != null
                                ? 'Menstruace začíná dnes (délka ${periodStart.lengthDays} dní)'
                                : 'Dnes není start menstruace',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: cs.primary),
                          ),
                        ),
                        if (periodStart != null)
                          TextButton(
                            onPressed: () {
                              widget.store.removePeriodStart(widget.day);
                              setState(() {});
                            },
                            child: const Text('Smazat start'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (nextPeriod != null)
                      _SmallHint(
                        text:
                            'Odhad další menstruace: ${formatDateCs(nextPeriod)}',
                      ),
                    if (fertile != null)
                      _SmallHint(
                        text:
                            'Odhad plodných dnů: ${formatDateCs(fertile.start)} – ${formatDateCs(fertile.end)}',
                      ),
                    if (nextPeriod == null)
                      _SmallHint(
                        text:
                            'Pro odhad další menstruace potřebuješ aspoň 2 starty.',
                      ),
                    const SizedBox(height: 6),
                    _SmallHint(
                      text: 'Pozn.: plodné dny jsou jen orientační odhad.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'výdaje',
                expanded: expandMoney,
                onToggle: () => setState(() => expandMoney = !expandMoney),
                onAdd: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FinanceScreen(
                        store: widget.store,
                        month: DateTime(widget.day.year, widget.day.month, 1),
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Spacer(),
                        Text(
                          'zůstatek: ${widget.store.balanceAll()} Kč',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const _SmallHint(
                      text: 'Přidání příjmů/výdajů je ve stránce „finance“',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onAdd;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.onAdd,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // header row like your mock: [+] title [v]
            Container(
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add),
                    tooltip: 'Přidat',
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onToggle,
                    icon: Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                    ),
                    tooltip: expanded ? 'Sbalit' : 'Rozbalit',
                  ),
                ],
              ),
            ),
            if (expanded) ...[const SizedBox(height: 12), child],
          ],
        ),
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  final String left;
  final String mid;
  final String right;

  const _LineRow({required this.left, required this.mid, required this.right});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              left,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              mid,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: cs.primary),
            ),
          ),
          SizedBox(
            width: 26,
            child: Center(
              child: Text(
                right,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: cs.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final String time;
  final String text;
  final bool done;
  final VoidCallback onToggle;

  const _TaskRow({
    required this.time,
    required this.text,
    required this.done,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              time,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: cs.primary,
                decoration: done ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          IconButton(
            onPressed: onToggle,
            icon: Icon(
              done ? Icons.check_circle : Icons.radio_button_unchecked,
            ),
            color: done ? cs.primary : cs.primary.withValues(alpha: 0.55),
            tooltip: done ? 'Hotovo' : 'Označit hotovo',
          ),
        ],
      ),
    );
  }
}

class _EmptyLine extends StatelessWidget {
  final String text;
  const _EmptyLine({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: cs.primary.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}

class _SmallHint extends StatelessWidget {
  final String text;
  const _SmallHint({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: cs.primary.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}

// =======================
// Add Event/Task Screen
// =======================

enum AddTab { planovani, ukoly }

class AddItemScreen extends StatefulWidget {
  final Store store;
  final DateTime initialDate;
  final AddTab initialTab;

  const AddItemScreen({
    super.key,
    required this.store,
    required this.initialDate,
    required this.initialTab,
  });

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  late AddTab tab;
  late DateTime pickedDate;
  TimeOfDay pickedTime = const TimeOfDay(hour: 12, minute: 0);
  int repeatWeekday = 0; // 0 none, 1..7

  final TextEditingController textCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    tab = widget.initialTab;
    pickedDate = dateOnly(widget.initialDate);
  }

  @override
  void dispose() {
    textCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final res = await showDatePicker(
      context: context,
      initialDate: pickedDate,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2035, 12, 31),
    );
    if (res != null) setState(() => pickedDate = dateOnly(res));
  }

  Future<void> _pickTime() async {
    final res = await showTimePicker(context: context, initialTime: pickedTime);
    if (res != null) setState(() => pickedTime = res);
  }

  void _save() {
    final text = textCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Něco napiš do pole 🙂')));
      return;
    }

    final mins = minutesOf(pickedTime);

    if (tab == AddTab.planovani) {
      widget.store.addEvent(
        EventItem(
          id: _id(),
          date: pickedDate,
          timeMinutes: mins,
          text: text,
          repeatWeekday: repeatWeekday,
        ),
      );
    } else {
      widget.store.addTask(
        TaskItem(
          id: _id(),
          date: pickedDate,
          timeMinutes: mins,
          text: text,
          repeatWeekday: repeatWeekday,
        ),
      );
    }

    // back to day
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DayScreen(store: widget.store, day: pickedDate),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  child: Text(
                    formatDateCs(pickedDate),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      _TopTabs(
                        left: 'události',
                        right: 'úkoly',
                        leftSelected: tab == AddTab.planovani,
                        onLeft: () => setState(() => tab = AddTab.planovani),
                        onRight: () => setState(() => tab = AddTab.ukoly),
                      ),
                      const SizedBox(height: 14),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            tab == AddTab.planovani ? 'události' : 'úkoly',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: _LabeledPickerField(
                              label: 'datum:',
                              value: formatDateCs(pickedDate),
                              onTap: _pickDate,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _LabeledPickerField(
                              label: 'čas:',
                              value:
                                  '${fmt2(pickedTime.hour)}:${fmt2(pickedTime.minute)}',
                              onTap: _pickTime,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          tab == AddTab.planovani ? 'událost:' : 'úkol:',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: textCtrl,
                        maxLines: 6,
                        textInputAction: TextInputAction.newline,
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Text(
                            'opakovat:',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              initialValue: repeatWeekday,
                              items: [
                                const DropdownMenuItem(
                                  value: 0,
                                  child: Text('Neopakovat'),
                                ),
                                ...List.generate(7, (i) {
                                  final w = i + 1;
                                  return DropdownMenuItem(
                                    value: w,
                                    child: Text(weekdayNameCs(w)),
                                  );
                                }),
                              ],
                              onChanged: (v) =>
                                  setState(() => repeatWeekday = v ?? 0),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _BottomBar(
                        left: 'zpět',
                        right: 'uložit',
                        onLeft: () => Navigator.pop(context),
                        onRight: _save,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopTabs extends StatelessWidget {
  final String left;
  final String right;
  final bool leftSelected;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  const _TopTabs({
    required this.left,
    required this.right,
    required this.leftSelected,
    required this.onLeft,
    required this.onRight,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget tabBtn(String text, bool selected, VoidCallback onTap) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? cs.primary.withValues(alpha: 0.20)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
            ),
            child: Center(
              child: Text(
                text,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        tabBtn(left, leftSelected, onLeft),
        const SizedBox(width: 12),
        tabBtn(right, !leftSelected, onRight),
      ],
    );
  }
}

class _LabeledPickerField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _LabeledPickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.primary.withValues(alpha: 0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: cs.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final String left;
  final String right;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  const _BottomBar({
    required this.left,
    required this.right,
    required this.onLeft,
    required this.onRight,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget btn(String text, VoidCallback onTap, {bool filled = false}) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: filled
                  ? cs.primary.withValues(alpha: 0.18)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cs.primary.withValues(alpha: 0.30)),
            ),
            child: Center(
              child: Text(
                text,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        btn(left, onLeft),
        const SizedBox(width: 12),
        btn(right, onRight, filled: true),
      ],
    );
  }
}

// =======================
// Finance Screen
// =======================

class FinanceScreen extends StatefulWidget {
  final Store store;
  final DateTime month; // first day in month

  const FinanceScreen({super.key, required this.store, required this.month});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

enum FinanceTab { prijem, vydaj, prehled }

class _FinanceScreenState extends State<FinanceScreen> {
  FinanceTab tab = FinanceTab.prehled;

  final TextEditingController textCtrl = TextEditingController();
  final TextEditingController amountCtrl = TextEditingController();

  @override
  void dispose() {
    textCtrl.dispose();
    amountCtrl.dispose();
    super.dispose();
  }

  void _addMoney({required bool isIncome}) {
    final text = textCtrl.text.trim();
    final amountText = amountCtrl.text.trim();

    if (text.isEmpty || amountText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vyplň popis i částku 🙂')));
      return;
    }

    final parsed = int.tryParse(
      amountText.replaceAll(' ', '').replaceAll(',', ''),
    );
    if (parsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Částka musí být celé číslo (např. 35900)'),
        ),
      );
      return;
    }

    final amount = isIncome ? parsed : -parsed;

    widget.store.addMoney(
      MoneyItem(
        id: _id(),
        date: dateOnly(DateTime.now()),
        text: text,
        amountCzk: amount,
      ),
    );

    textCtrl.clear();
    amountCtrl.clear();

    setState(() => tab = FinanceTab.prehled);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final list = widget.store.moneyForMonth(
      widget.month.year,
      widget.month.month,
    );
    final balance = widget.store.balanceAll();

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    Text(
                      'finance',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Spacer(),
                    Text(
                      'zůstatek: $balance Kč',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _FinanceTabBtn(
                            text: 'příjem',
                            selected: tab == FinanceTab.prijem,
                            onTap: () =>
                                setState(() => tab = FinanceTab.prijem),
                          ),
                          const SizedBox(width: 10),
                          _FinanceTabBtn(
                            text: 'výdaj',
                            selected: tab == FinanceTab.vydaj,
                            onTap: () => setState(() => tab = FinanceTab.vydaj),
                          ),
                          const SizedBox(width: 10),
                          _FinanceTabBtn(
                            text: 'přehled',
                            selected: tab == FinanceTab.prehled,
                            onTap: () =>
                                setState(() => tab = FinanceTab.prehled),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      if (tab == FinanceTab.prijem) ...[
                        _MoneyForm(
                          title: 'příjem',
                          textCtrl: textCtrl,
                          amountCtrl: amountCtrl,
                          onSave: () => _addMoney(isIncome: true),
                        ),
                      ],
                      if (tab == FinanceTab.vydaj) ...[
                        _MoneyForm(
                          title: 'výdaj',
                          textCtrl: textCtrl,
                          amountCtrl: amountCtrl,
                          onSave: () => _addMoney(isIncome: false),
                        ),
                      ],
                      if (tab == FinanceTab.prehled) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Přehled za ${formatMonthYearCs(widget.month)}',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (list.isEmpty)
                          _EmptyLine(text: 'Zatím žádné položky'),
                        ...list.map((m) {
                          final amountStr = '${m.amountCzk} Kč';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    m.text,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(color: cs.primary),
                                  ),
                                ),
                                Text(
                                  amountStr,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: m.amountCzk >= 0
                                            ? cs.primary
                                            : cs.primary.withValues(alpha: 0.8),
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 10),
                        Divider(color: cs.primary.withValues(alpha: 0.25)),
                        Row(
                          children: [
                            Text(
                              'zůstatek:',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: cs.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const Spacer(),
                            Text(
                              '$balance Kč',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: cs.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinanceTabBtn extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _FinanceTabBtn({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? cs.primary.withValues(alpha: 0.20)
                : cs.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
          ),
          child: Center(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MoneyForm extends StatelessWidget {
  final String title;
  final TextEditingController textCtrl;
  final TextEditingController amountCtrl;
  final VoidCallback onSave;

  const _MoneyForm({
    required this.title,
    required this.textCtrl,
    required this.amountCtrl,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: cs.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: textCtrl,
          decoration: const InputDecoration(
            labelText: 'popis (např. Výplata / benzín)',
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: amountCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'částka (např. 35900)'),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onSave,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('uložit'),
            ),
          ),
        ),
      ],
    );
  }
}

class _ColorPickerDialog extends StatefulWidget {
  final String title;
  final Color initialColor;
  final ValueChanged<Color> onColorSelected;

  const _ColorPickerDialog({
    required this.title,
    required this.initialColor,
    required this.onColorSelected,
  });

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color selectedColor;
  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: selectedColor,
          onColorChanged: (color) {
            setState(() {
              selectedColor = color;
            });
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Zrušit"),
        ),
        FilledButton(
          onPressed: () {
            widget.onColorSelected(selectedColor);
            Navigator.pop(context);
          },
          child: const Text("Vybrat"),
        ),
      ],
    );
  }
}
