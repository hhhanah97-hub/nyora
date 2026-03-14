import 'package:flutter/material.dart';
import '../store/store.dart';
import '../screens/add_event_screen.dart';
import '../models/event.dart';
import '../screens/add_finance_screen.dart';
import '../screens/add_task_screen.dart';
import '../models/task.dart';
import '../models/tracker.dart';

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
    final tasks = store.tasksForDay(selectedDay);
    final habits = store.habitsForDay(selectedDay);

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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                              leading: const Icon(Icons.event),
                              title: const Text("Událost"),
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
                              leading: const Icon(Icons.task),
                              title: const Text("Úkol"),
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddTaskScreen(
                                      store: store,
                                      date: selectedDay,
                                    ),
                                  ),
                                );
                              },
                            ),

                            ListTile(
                              leading: const Icon(Icons.attach_money),
                              title: const Text("Finance"),
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
                            ListTile(
                              leading: const Icon(Icons.track_changes),
                              title: const Text("Tracker"),
                              onTap: () {
                                Navigator.pop(context);
                                store.addTracker(
                                  date: selectedDay,
                                  name: "Nový tracker",
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
            const Divider(),
            const SizedBox(height: 10),

            /// UDÁLOSTI
            Row(
              children: const [
                Icon(Icons.event, size: 18),
                SizedBox(width: 6),
                Text("Události", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 6),

            if (eventsForDay.isEmpty)
              const Text("Žádné události")
            else
              Column(
                children: eventsForDay.map((e) {
                  return GestureDetector(
                    onLongPress: () {
                      _eventMenu(context, e);
                    },
                    child: ListTile(
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

            /// ÚKOLY
            Row(
              children: const [
                Icon(Icons.check_circle_outline, size: 18),
                SizedBox(width: 6),
                Text("Úkoly", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 6),

            if (tasks.isEmpty)
              const Text("Žádné úkoly")
            else
              Column(
                children: tasks.map((task) {
                  final hour = task.timeMinutes ~/ 60;
                  final minute = task.timeMinutes % 60;

                  final timeText = task.timeMinutes > 0
                      ? "${fmt2(hour)}:${fmt2(minute)} "
                      : "";

                  return GestureDetector(
                    onLongPress: () {
                      _taskMenu(context, task);
                    },
                    child: CheckboxListTile(
                      value: task.done,
                      title: Text("$timeText${task.text}"),
                      onChanged: (value) {
                        task.done = value ?? false;
                        store.save();
                      },
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            /// FINANCE
            Row(
              children: const [
                Icon(Icons.attach_money, size: 18),
                SizedBox(width: 6),
                Text("Finance", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 6),

            Text("Výdaje dnes: ${expensesToday.toStringAsFixed(0)} Kč"),
            Text("Zůstatek: ${store.getBalance().toStringAsFixed(0)} Kč"),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            /// TRACKER
            Row(
              children: const [
                Icon(Icons.track_changes, size: 18),
                SizedBox(width: 6),
                Text("Tracker", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 6),

            if (habits.isEmpty)
              const Text("Žádné trackery")
            else
              Column(
                children: habits.map((habit) {
                  final done = store.trackers.any(
                    (x) =>
                        x.name == habit.name &&
                        x.date.year == selectedDay.year &&
                        x.date.month == selectedDay.month &&
                        x.date.day == selectedDay.day,
                  );

                  final streak = store.getHabitStreak(habit.name);

                  return CheckboxListTile(
                    value: done,
                    title: Text(habit.name),
                    secondary: Text("🔥 $streak"),
                    onChanged: (value) {
                      store.toggleHabit(
                        habit.name,
                        selectedDay,
                        value ?? false,
                      );
                    },
                  );
                }).toList(),
              ),

            /// cycle tracker informace
            Builder(
              builder: (_) {
                final ovulation = store.getOvulationDay();
                final nextPeriod = store.getNextPeriod();

                final widgets = <Widget>[];

                if (store.isFertileDay(selectedDay)) {
                  widgets.add(const Text("🌸 Plodné dny"));
                }

                if (ovulation != null &&
                    ovulation.year == selectedDay.year &&
                    ovulation.month == selectedDay.month &&
                    ovulation.day == selectedDay.day) {
                  widgets.add(const Text("🥚 Ovulace"));
                }

                if (nextPeriod != null &&
                    nextPeriod.year == selectedDay.year &&
                    nextPeriod.month == selectedDay.month &&
                    nextPeriod.day == selectedDay.day) {
                  widgets.add(const Text("🩸 Očekávaná menstruace"));
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widgets,
                );
              },
            ),
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

  void _taskMenu(BuildContext context, Task task) {
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
                  _editTask(context, task);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text("Smazat"),
                onTap: () {
                  store.tasks.remove(task);
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

  void _editTask(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddTaskScreen(store: store, date: task.date, existingTask: task),
      ),
    );
  }
}
