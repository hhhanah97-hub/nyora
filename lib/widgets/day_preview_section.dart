import 'package:flutter/material.dart';
import '../store/store.dart';
import '../screens/add_event_screen.dart';
import '../models/event.dart';
import '../screens/add_finance_screen.dart';

class DayPreviewSection extends StatelessWidget {
  final Store store;
  final DateTime selectedDay;

  const DayPreviewSection({
    super.key,
    required this.store,
    required this.selectedDay,
  });

  String fmt2(int n) => n.toString().padLeft(2, '0');

  String formatTimeFromMinutes(int m) {
    return '${fmt2(m ~/ 60)}:${fmt2(m % 60)}';
  }

  @override
  Widget build(BuildContext context) {
    final eventsForDay = store.eventsForDay(selectedDay);
    final finances = store.financesForDay(selectedDay);
    double expensesToday = 0;
    for (var f in finances) {
      if (f.amount < 0) {
        expensesToday += f.amount.abs();
      }
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Denní přehled (${selectedDay.day}.${selectedDay.month}.${selectedDay.year})",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(Icons.event),
                              title: Text("Událost"),
                              onTap: () {
                                Navigator.pop(context);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddEventScreen(
                                      store: store,
                                      initialDate: selectedDay,
                                    ),
                                  ),
                                );
                              },
                            ),

                            ListTile(
                              leading: Icon(Icons.task),
                              title: Text("Úkol"),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),

                            ListTile(
                              leading: Icon(Icons.attach_money),
                              title: Text("Finance"),
                              onTap: () {
                                Navigator.pop(context);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddFinanceScreen(
                                      store: store,
                                      date: selectedDay,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// CONTENT
            if (eventsForDay.isEmpty)
              const Text("Žádné záznamy")
            else
              Column(
                children: eventsForDay.map((e) {
                  return GestureDetector(
                    onLongPress: () {
                      _eventMenu(context, e);
                    },
                    child: ListTile(
                      leading: const Icon(Icons.event),

                      title: Row(
                        children: [
                          Text(
                            formatTimeFromMinutes(e.timeMinutes),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(width: 10),

                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: store.getCategoryColor(e.category),
                              shape: BoxShape.circle,
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(child: Text(e.text)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 20),

            const Divider(),

            const SizedBox(height: 10),

            const Text(
              "Finance",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text("Výdaje dnes: ${expensesToday.toStringAsFixed(0)} Kč"),

            Text("Zůstatek: ${store.getBalance().toStringAsFixed(0)} Kč"),
          ],
        ),
      ),
    );
  }

  void _eventMenu(BuildContext context, Event e) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Upravit"),
                onTap: () {
                  Navigator.pop(context);
                  _editEvent(context, e);
                },
              ),

              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text("Smazat"),
                onTap: () {
                  store.events.remove(e);
                  store.save();

                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _editEvent(BuildContext context, Event e) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEventScreen(store: store, initialDate: e.date),
      ),
    );
  }
}
