import 'package:flutter/material.dart';
import '../store/store.dart';

class TrackingScreen extends StatelessWidget {
  final Store store;

  const TrackingScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tracking")),
      body: ListView(
        children: [
          ...store.trackerCategories.map((t) {
            return ListTile(
              title: Text(t.name),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // později otevřeme detail trackeru
              },
            );
          }).toList(),
          const SizedBox(height: 20),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addTrackerDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addTrackerDialog(BuildContext context) {
    final nameController = TextEditingController();
    String selectedType = store.trackerTypes.first;
    List<int> selectedDays = [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nový tracker"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// název trackeru
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Název trackeru"),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: "Typ trackeru"),
                items: const [
                  DropdownMenuItem(value: "habit", child: Text("Habit")),
                  DropdownMenuItem(
                    value: "cycle",
                    child: Text("Menstruační cyklus"),
                  ),
                ],
                onChanged: (value) {
                  selectedType = value!;
                },
              ),

              const SizedBox(height: 16),

              /// typ trackeru
              const SizedBox(height: 16),

              if (selectedType == "habit")
                Wrap(
                  spacing: 6,
                  children: [
                    _dayButton(1, "Po", selectedDays),
                    _dayButton(2, "Út", selectedDays),
                    _dayButton(3, "St", selectedDays),
                    _dayButton(4, "Čt", selectedDays),
                    _dayButton(5, "Pá", selectedDays),
                    _dayButton(6, "So", selectedDays),
                    _dayButton(7, "Ne", selectedDays),
                  ],
                ),
            ],
          ),

          actions: [
            TextButton(
              child: const Text("Zrušit"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),

            TextButton(
              child: const Text("Přidat"),
              onPressed: () {
                if (nameController.text.isEmpty) return;

                store.addTrackerCategory(
                  nameController.text,
                  selectedType,
                  selectedDays,
                );

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _dayButton(int day, String label, List<int> selectedDays) {
    return FilterChip(
      label: Text(label),
      selected: selectedDays.contains(day),
      onSelected: (value) {
        if (value) {
          selectedDays.add(day);
        } else {
          selectedDays.remove(day);
        }
      },
    );
  }
}
