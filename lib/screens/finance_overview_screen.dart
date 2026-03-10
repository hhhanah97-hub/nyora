import 'package:flutter/material.dart';
import '../store/store.dart';

class FinanceOverviewScreen extends StatelessWidget {
  final Store store;

  const FinanceOverviewScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    double income = 0;
    Map<String, double> expenses = {};

    for (var f in store.finances) {
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

    return Scaffold(
      appBar: AppBar(title: Text("Finance přehled")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Příjmy: ${income.toStringAsFixed(0)} Kč",
              style: TextStyle(fontSize: 18),
            ),

            SizedBox(height: 20),

            Text("Výdaje", style: TextStyle(fontWeight: FontWeight.bold)),

            ...expenses.entries.map((e) {
              return ListTile(
                title: Text(e.key),
                trailing: Text("${e.value.toStringAsFixed(0)} Kč"),
              );
            }),

            Spacer(),

            Text(
              "Zůstatek: ${store.getBalance().toStringAsFixed(0)} Kč",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
