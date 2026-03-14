import 'package:flutter/material.dart';
import '../store/store.dart';

class FinanceOverviewScreen extends StatefulWidget {
  final Store store;

  const FinanceOverviewScreen({super.key, required this.store});

  @override
  State<FinanceOverviewScreen> createState() => _FinanceOverviewScreenState();
}

class _FinanceOverviewScreenState extends State<FinanceOverviewScreen> {
  late int selectedMonth;
  late int selectedYear;
  final months = [
    "Leden",
    "Únor",
    "Březen",
    "Duben",
    "Květen",
    "Červen",
    "Červenec",
    "Srpen",
    "Září",
    "Říjen",
    "Listopad",
    "Prosinec",
  ];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    selectedMonth = now.month;
    selectedYear = now.year;
  }

  @override
  Widget build(BuildContext context) {
    double income = 0;
    Map<String, double> expenses = {};

    final monthFinances = widget.store.finances.where((f) {
      return f.date.month == selectedMonth && f.date.year == selectedYear;
    });

    for (var f in monthFinances) {
      if (f.amount > 0) {
        income += f.amount;
      } else {
        final key = f.text;

        if (!expenses.containsKey(key)) {
          expenses[key] = 0;
        }

        expenses[key] = expenses[key]! + f.amount.abs();
      }
    }

    final balance = income - expenses.values.fold(0, (a, b) => a + b);

    return Scaffold(
      appBar: AppBar(title: const Text("Finance přehled")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// MĚSÍC
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      selectedMonth--;

                      if (selectedMonth == 0) {
                        selectedMonth = 12;
                        selectedYear--;
                      }
                    });
                  },
                ),

                Text(
                  "${months[selectedMonth - 1]}  $selectedYear",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      selectedMonth++;

                      if (selectedMonth == 13) {
                        selectedMonth = 1;
                        selectedYear++;
                      }
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),
            Text(
              "Souhrn měsíce",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text("Příjmy: ${income.toStringAsFixed(0)} Kč"),
            Text(
              "Výdaje: ${expenses.values.fold(0.0, (a, b) => a + b).toStringAsFixed(0)} Kč",
            ),
            Text("Zůstatek: ${balance.toStringAsFixed(0)} Kč"),

            const SizedBox(height: 20),

            /// PŘÍJMY
            Text(
              "Příjmy: ${income.toStringAsFixed(0)} Kč",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            const Text("Výdaje", style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: expenses.entries.map((e) {
                  return ListTile(
                    title: Text(e.key),
                    trailing: Text("${e.value.toStringAsFixed(0)} Kč"),
                  );
                }).toList(),
              ),
            ),

            const Divider(),

            /// ZŮSTATEK
            Text(
              "Zůstatek: ${balance.toStringAsFixed(0)} Kč",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
