import 'package:flutter/material.dart';
import '../store/store.dart';
import '../models/finance.dart';

class AddFinanceScreen extends StatefulWidget {
  final Store store;
  final DateTime date;
  final Finance? existingFinance;

  const AddFinanceScreen({
    super.key,
    required this.store,
    required this.date,
    this.existingFinance,
  });

  @override
  State<AddFinanceScreen> createState() => _AddFinanceScreenState();
}

class _AddFinanceScreenState extends State<AddFinanceScreen> {
  final textController = TextEditingController();
  final valueController = TextEditingController();

  List<String> suggestions = [];

  @override
  void initState() {
    super.initState();

    suggestions = widget.store.finances.map((f) => f.text).toSet().toList();

    /// pokud editujeme existující záznam
    if (widget.existingFinance != null) {
      textController.text = widget.existingFinance!.text;
      valueController.text = widget.existingFinance!.amount.abs().toString();
    }
  }

  void saveFinance(bool isExpense) {
    final text = textController.text;
    final value = double.tryParse(valueController.text) ?? 0;

    /// EDITACE
    if (widget.existingFinance != null) {
      final index = widget.store.finances.indexOf(widget.existingFinance!);

      widget.store.finances[index] = Finance(
        date: widget.date,
        text: text,
        amount: isExpense ? -value : value,
      );
    }
    /// NOVÝ ZÁZNAM
    else {
      widget.store.addFinance(
        date: widget.date,
        text: text,
        amount: isExpense ? -value : value,
      );
    }

    widget.store.save();
    textController.clear();
    valueController.clear();
    setState(() {});
  }

  Widget buildForm(bool isExpense) {
    final todaysFinances = widget.store.financesForDay(widget.date);

    final incomes = todaysFinances.where((f) => f.amount > 0).toList();
    final expenses = todaysFinances.where((f) => f.amount < 0).toList();

    final totalIncome = incomes.fold<double>(0, (sum, f) => sum + f.amount);

    final totalExpenses = expenses.fold<double>(
      0,
      (sum, f) => sum + f.amount.abs(),
    );

    final list = isExpense ? expenses : incomes;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// POPIS
          TextField(
            controller: textController,
            decoration: const InputDecoration(labelText: "Popis"),
          ),

          const SizedBox(height: 20),

          /// ČÁSTKA
          TextField(
            controller: valueController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Částka"),
          ),

          const SizedBox(height: 20),

          /// ULOŽIT
          ElevatedButton(
            onPressed: () => saveFinance(isExpense),
            child: const Text("Uložit"),
          ),

          const SizedBox(height: 20),
          const Divider(),

          /// TITULEK
          Text(
            isExpense ? "Dnešní výdaje" : "Dnešní příjmy",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          /// SEZNAM
          Expanded(
            child: ListView(
              children: list.map((f) {
                return ListTile(
                  title: Text(f.text),

                  trailing: Text(
                    "${f.amount.abs().toStringAsFixed(0)} Kč",
                    style: TextStyle(
                      color: f.amount < 0 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  onLongPress: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.edit),
                            title: const Text("Upravit"),
                            onTap: () {
                              Navigator.pop(context);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddFinanceScreen(
                                    store: widget.store,
                                    date: widget.date,
                                    existingFinance: f,
                                  ),
                                ),
                              );
                            },
                          ),

                          ListTile(
                            leading: const Icon(Icons.delete),
                            title: const Text("Smazat"),
                            onTap: () {
                              widget.store.finances.remove(f);
                              widget.store.save();
                              Navigator.pop(context);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),

          const Divider(),

          /// SOUČET
          Text(
            isExpense
                ? "Celkem výdaje: ${totalExpenses.toStringAsFixed(0)} Kč"
                : "Celkem příjmy: ${totalIncome.toStringAsFixed(0)} Kč",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Finance"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Příjem"),
              Tab(text: "Výdaj"),
            ],
          ),
        ),
        body: TabBarView(children: [buildForm(false), buildForm(true)]),
      ),
    );
  }
}
