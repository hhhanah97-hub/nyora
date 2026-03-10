import 'package:flutter/material.dart';
import '../store/store.dart';
import '../models/event_category.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CategorySettingsScreen extends StatefulWidget {
  final Store store;

  const CategorySettingsScreen({super.key, required this.store});

  @override
  State<CategorySettingsScreen> createState() => _CategorySettingsScreenState();
}

class _CategorySettingsScreenState extends State<CategorySettingsScreen> {
  void _categoryMenu(Category c) {
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
                  _editCategory(c);
                },
              ),

              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text("Smazat"),
                onTap: () {
                  setState(() {
                    widget.store.categories.remove(c);
                  });

                  widget.store.saveCategories();

                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void addCategory() {
    final controller = TextEditingController();
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Nová kategorie"),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: "Název kategorie",
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text("Vybraná barva"),
                    ],
                  ),
                  const SizedBox(height: 10),

                  ElevatedButton(
                    child: const Text("Vybrat barvu"),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Vyber barvu"),

                            content: SingleChildScrollView(
                              child: ColorPicker(
                                pickerColor: selectedColor,
                                onColorChanged: (color) {
                                  setStateDialog(() {
                                    selectedColor = color;
                                  });
                                },
                              ),
                            ),

                            actions: [
                              TextButton(
                                child: const Text("Hotovo"),
                                onPressed: () {
                                  Navigator.pop(context);
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

              actions: [
                TextButton(
                  child: const Text("Zrušit"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),

                TextButton(
                  child: const Text("Uložit"),
                  onPressed: () {
                    if (controller.text.isEmpty) return;

                    setState(() {
                      widget.store.categories.add(
                        Category(name: controller.text, color: selectedColor),
                      );
                    });

                    widget.store.saveCategories();

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

  void _editCategory(Category c) {
    final controller = TextEditingController(text: c.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Upravit kategorii"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: "Název"),
          ),
          actions: [
            TextButton(
              child: const Text("Zrušit"),
              onPressed: () => Navigator.pop(context),
            ),

            TextButton(
              child: const Text("Uložit"),
              onPressed: () {
                setState(() {
                  c.name = controller.text;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kategorie")),

      floatingActionButton: FloatingActionButton(
        onPressed: addCategory,
        child: const Icon(Icons.add),
      ),

      body: ListView(
        children: widget.store.categories.map((c) {
          return ListTile(
            leading: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(color: c.color, shape: BoxShape.circle),
            ),
            title: Text(c.name),
            onLongPress: () {
              _categoryMenu(c);
            },

            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _editCategory(c);
                  },
                ),

                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      widget.store.categories.remove(c);
                    });
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
