import 'package:flutter/material.dart';
import '../store/store.dart';
import '../models/task.dart';

class AddTaskScreen extends StatefulWidget {
  final Store store;
  final DateTime date;
  final Task? existingTask;

  const AddTaskScreen({
    super.key,
    required this.store,
    required this.date,
    this.existingTask,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  TimeOfDay? selectedTime;
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.existingTask != null) {
      textController.text = widget.existingTask!.text;

      if (widget.existingTask!.timeMinutes > 0) {
        final h = widget.existingTask!.timeMinutes ~/ 60;
        final m = widget.existingTask!.timeMinutes % 60;

        selectedTime = TimeOfDay(hour: h, minute: m);
      }
    }
  }

  void saveTask() {
    final minutes = selectedTime != null
        ? selectedTime!.hour * 60 + selectedTime!.minute
        : 0;

    if (widget.existingTask != null) {
      widget.existingTask!.text = textController.text;
      widget.existingTask!.timeMinutes = minutes;

      widget.store.save();
      widget.store.notifyListeners();
    } else {
      widget.store.addTask(
        date: widget.date,
        text: textController.text,
        timeMinutes: minutes,
      );
    }

    Navigator.pop(context);
  }

  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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

  String formatTime() {
    if (selectedTime == null) return "Bez času";

    final h = selectedTime!.hour.toString().padLeft(2, "0");
    final m = selectedTime!.minute.toString().padLeft(2, "0");

    return "$h:$m";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nový úkol")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(labelText: "Popis úkolu"),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                const Icon(Icons.access_time),

                const SizedBox(width: 10),

                Text(formatTime()),

                const Spacer(),

                TextButton(
                  onPressed: pickTime,
                  child: const Text("Vybrat čas"),
                ),
              ],
            ),

            const SizedBox(height: 30),

            ElevatedButton(onPressed: saveTask, child: const Text("Uložit")),
          ],
        ),
      ),
    );
  }
}
