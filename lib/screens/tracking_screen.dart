import 'package:flutter/material.dart';
import '../store/store.dart';
import '../models/tracker_category.dart'; // Potřebujeme pro typizaci

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
              subtitle: Text(
                t.type == "cycle" ? "Ženský cyklus" : "Zvyk",
              ), // Malá nápověda
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Rozlišení, kam uživatele pošleme
                if (t.type == "cycle") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CycleDetailScreen(store: store, category: t),
                    ),
                  );
                } else {
                  // Zde bude v budoucnu detail pro klasické zvyky (Habits)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Detail pro zvyk "${t.name}" se připravuje.',
                      ),
                    ),
                  );
                }
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
    // ... tvůj stávající kód pro přidání trackeru (zůstává beze změny)
    final nameController = TextEditingController();
    String selectedType = store.trackerTypes.first;
    List<int> selectedDays = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // PŘIDÁNO: StatefulBuilder, aby se Dropdown a Checkboxy aktualizovaly
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Nový tracker"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Název trackeru",
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: "Typ trackeru",
                    ),
                    items: const [
                      DropdownMenuItem(value: "habit", child: Text("Habit")),
                      DropdownMenuItem(
                        value: "cycle",
                        child: Text("Menstruační cyklus"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (selectedType == "habit")
                    Wrap(
                      spacing: 6,
                      children: [
                        _dayButton(1, "Po", selectedDays, setState),
                        _dayButton(2, "Út", selectedDays, setState),
                        _dayButton(3, "St", selectedDays, setState),
                        _dayButton(4, "Čt", selectedDays, setState),
                        _dayButton(5, "Pá", selectedDays, setState),
                        _dayButton(6, "So", selectedDays, setState),
                        _dayButton(7, "Ne", selectedDays, setState),
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
      },
    );
  }

  Widget _dayButton(
    int day,
    String label,
    List<int> selectedDays,
    StateSetter setState,
  ) {
    return FilterChip(
      label: Text(label),
      selected: selectedDays.contains(day),
      onSelected: (value) {
        setState(() {
          // Musí být zabaleno v setState předaném ze StatefulBuilderu
          if (value) {
            selectedDays.add(day);
          } else {
            selectedDays.remove(day);
          }
        });
      },
    );
  }
}

/// NOVÁ OBRAZOVKA: DETAIL CYKLU A STATISTIKY
class CycleDetailScreen extends StatelessWidget {
  final Store store;
  final TrackerCategory category;

  const CycleDetailScreen({
    super.key,
    required this.store,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Výpočet průměrné délky cyklu
    final starts = store.getCycleStarts();
    int averageCycleLength = 28; // Výchozí hodnota
    if (starts.length >= 2) {
      int totalDays = 0;
      // Počítáme rozdíly mezi začátky cyklů
      for (int i = 0; i < starts.length - 1; i++) {
        totalDays += starts[i].difference(starts[i + 1]).inDays;
      }
      averageCycleLength = (totalDays / (starts.length - 1)).round();
    }

    // 2. Výpočet průměrné délky krvácení
    int averageBleedingLength = 4; // Výchozí hodnota
    if (starts.isNotEmpty) {
      final actualDays = store.getActualPeriodDays();
      int totalBleedingDays = actualDays.length;
      averageBleedingLength = (totalBleedingDays / starts.length).round();
      // Ošetření extrémů
      if (averageBleedingLength < 1) averageBleedingLength = 1;
      if (averageBleedingLength > 10) averageBleedingLength = 10;
    }

    return Scaffold(
      appBar: AppBar(title: Text(category.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Statistiky cyklu",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Karta se statistikami
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Průměrná délka cyklu:",
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          "$averageCycleLength dní",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Průměrná délka krvácení:",
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          "$averageBleedingLength dny/dní",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Zaznamenaných cyklů:",
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          "${starts.length}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              "Přizpůsobení vzhledu",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Změna barvy rámečků v kalendáři bude přidána v dalším kroku po úpravě tématu aplikace.",
              style: TextStyle(color: Colors.grey),
            ),

            // TODO: Zde přidáme výběr barvy
          ],
        ),
      ),
    );
  }
}
