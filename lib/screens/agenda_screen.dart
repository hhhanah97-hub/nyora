import 'package:flutter/material.dart';
import '../store/store.dart';
import '../theme/app_theme.dart';
import '../models/event.dart';

class AgendaScreen extends StatefulWidget {
  final Store store;
  final AppTheme theme;

  const AgendaScreen({super.key, required this.store, required this.theme});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  String fmt2(int n) => n.toString().padLeft(2, '0');

  String formatTime(int m) {
    return "${fmt2(m ~/ 60)}:${fmt2(m % 60)}";
  }

  String selectedCategory = "Vše";

  String formatDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (date == today) return "Dnes";
    if (date == tomorrow) return "Zítra";

    return "${date.day}.${date.month}.${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final categories = ["Vše", ...widget.store.categories.map((c) => c.name)];
    final now = DateTime.now();
    final futureEvents = <Event>[];

    for (int i = 0; i < 365; i++) {
      final day = now.add(Duration(days: i));

      final events = widget.store.eventsForDay(day);

      for (var e in events) {
        if (selectedCategory != "Vše" && e.category != selectedCategory) {
          continue;
        }

        futureEvents.add(e);
      }
    }

    final pastEvents = <Event>[];

    for (int i = 1; i < 365; i++) {
      final day = now.subtract(Duration(days: i));

      final events = widget.store.eventsForDay(day);

      for (var e in events) {
        if (selectedCategory != "Vše" && e.category != selectedCategory) {
          continue;
        }

        pastEvents.add(e);
      }
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Agenda"),
          actions: [
            DropdownButton<String>(
              value: selectedCategory,
              underline: const SizedBox(),
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),

            const SizedBox(width: 12),
          ],
        ),
        body: TabBarView(
          children: [
            ListView(
              children: () {
                DateTime? lastDay;

                return futureEvents.expand((e) {
                  final eventDay = DateTime(
                    e.date.year,
                    e.date.month,
                    e.date.day,
                  );

                  final widgets = <Widget>[];

                  if (lastDay == null || lastDay != eventDay) {
                    widgets.add(
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                        child: Text(
                          formatDay(eventDay),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );

                    lastDay = eventDay;
                  }

                  widgets.add(
                    ListTile(
                      leading: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: widget.store.getCategoryColor(e.category),
                          shape: BoxShape.circle,
                        ),
                      ),

                      title: Row(
                        children: [
                          Text(
                            formatTime(e.timeMinutes),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(width: 10),

                          Expanded(child: Text(e.text)),
                        ],
                      ),
                    ),
                  );

                  return widgets;
                }).toList();
              }(),
            ),

            ListView(
              children: () {
                DateTime? lastDay;

                return pastEvents.expand((e) {
                  final eventDay = DateTime(
                    e.date.year,
                    e.date.month,
                    e.date.day,
                  );

                  final widgets = <Widget>[];

                  if (lastDay == null || lastDay != eventDay) {
                    widgets.add(
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                        child: Text(
                          formatDay(eventDay),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );

                    lastDay = eventDay;
                  }

                  widgets.add(
                    ListTile(
                      leading: const Icon(Icons.event),

                      title: Row(
                        children: [
                          Text(
                            formatTime(e.timeMinutes),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(width: 10),

                          Expanded(child: Text(e.text)),
                        ],
                      ),
                    ),
                  );

                  return widgets;
                }).toList();
              }(),
            ),
          ],
        ),
      ),
    );
  }
}

String fmt2(int n) => n.toString().padLeft(2, '0');

String formatTimeFromMinutes(int m) {
  return '${fmt2(m ~/ 60)}:${fmt2(m % 60)}';
}
