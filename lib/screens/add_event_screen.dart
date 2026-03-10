import 'package:flutter/material.dart';
import '../store/store.dart';
import '../models/event.dart';

class AddEventScreen extends StatefulWidget {
  final Store store;
  final DateTime initialDate;
  final Event? existingEvent;

  const AddEventScreen({
    super.key,
    required this.store,
    required this.initialDate,
    this.existingEvent,
  });

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  late DateTime selectedDate;
  late int selectedTimeMinutes;
  String selectedCategory = "";
  TimeOfDay selectedTime = const TimeOfDay(hour: 12, minute: 0);

  String text = "";
  String repeat = "";

  final textController = TextEditingController();

  final categories = ["Práce", "Osobní"];

  final repeats = ["Nikdy", "Denně", "Týdně", "Měsíčně", "Ročně"];

  @override
  void initState() {
    super.initState();

    if (widget.existingEvent != null) {
      final e = widget.existingEvent!;

      textController.text = e.text;
      selectedDate = e.date;
      selectedTimeMinutes = e.timeMinutes;
      selectedCategory = e.category;
    } else {
      selectedDate = widget.initialDate;
      selectedTimeMinutes = 12 * 60;
      selectedCategory = widget.store.categories.first.name;
    }
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  void saveEvent() {
    if (widget.existingEvent != null) {
      final index = widget.store.events.indexOf(widget.existingEvent!);
      widget.store.events[index] = Event(
        text: textController.text,
        date: selectedDate,
        timeMinutes: selectedTimeMinutes,
        category: selectedCategory,
        repeat: repeat,
      );
    } else {
      widget.store.addEvent(
        date: selectedDate,
        timeMinutes: selectedTimeMinutes,
        text: textController.text,
        category: selectedCategory,
        repeat: repeat,
      );
    }

    widget.store.save();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nová událost")),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// TEXT
            TextField(
              controller: textController,
              decoration: const InputDecoration(labelText: "Název události"),
            ),

            const SizedBox(height: 20),

            /// DATE
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                "${selectedDate.day}.${selectedDate.month}.${selectedDate.year}",
              ),
              onTap: pickDate,
            ),

            /// TIME
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(
                "${selectedTime.hour.toString().padLeft(2, "0")}:${selectedTime.minute.toString().padLeft(2, "0")}",
              ),
              onTap: pickTime,
            ),

            /// CATEGORY
            DropdownButtonFormField(
              value: selectedCategory,
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                setState(() {
                  selectedCategory = v!;
                });
              },
              decoration: const InputDecoration(labelText: "Kategorie"),
            ),

            const SizedBox(height: 20),

            /// REPEAT
            DropdownButtonFormField(
              value: repeat,
              items: const [
                DropdownMenuItem(value: "", child: Text("Nikdy")),
                DropdownMenuItem(value: "daily", child: Text("Denně")),
                DropdownMenuItem(value: "weekly", child: Text("Týdně")),
                DropdownMenuItem(value: "monthly", child: Text("Měsíčně")),
                DropdownMenuItem(value: "yearly", child: Text("Ročně")),
              ],
              onChanged: (v) {
                setState(() {
                  repeat = v!;
                });
              },
              decoration: const InputDecoration(labelText: "Opakování"),
            ),

            const Spacer(),

            /// SAVE
            ElevatedButton(onPressed: saveEvent, child: const Text("Uložit")),
          ],
        ),
      ),
    );
  }
}
