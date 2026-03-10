import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../theme/app_theme.dart';

class ThemeScreen extends StatefulWidget {
  final AppTheme theme;
  final Function(AppTheme) onThemeChanged;

  const ThemeScreen({
    super.key,
    required this.theme,
    required this.onThemeChanged,
  });

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  late Color accent;
  late Color background;
  late Color card;

  @override
  void initState() {
    super.initState();
    accent = widget.theme.accent;
    background = widget.theme.background;
    card = widget.theme.card;
  }

  void openColorDialog(String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        Color current;

        if (type == "accent") {
          current = accent;
        } else if (type == "background") {
          current = background;
        } else {
          current = card;
        }

        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.palette),
                  const SizedBox(width: 10),
                  const Text(
                    "Vyber barvu",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Expanded(
                child: ColorPicker(
                  pickerColor: current,
                  onColorChanged: (color) {
                    setState(() {
                      if (type == "accent") accent = color;
                      if (type == "background") background = color;
                      if (type == "card") card = color;
                    });

                    widget.onThemeChanged(
                      AppTheme(
                        accent: accent,
                        background: background,
                        card: card,
                      ),
                    );
                  },
                  enableAlpha: false,
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Hotovo"),
              ),
            ],
          ),
        );
      },
    );
  }

  void updateTheme() {
    widget.onThemeChanged(
      AppTheme(accent: accent, background: background, card: card),
    );
  }

  Widget buildPicker(String title, Color color, Function(Color) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),
        ColorPicker(
          pickerColor: color,
          onColorChanged: (color) {
            setState(() {
              onChanged(color);
            });

            updateTheme();
          },
          enableAlpha: false,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text("Akcent aplikace"),
            onTap: () {
              openColorDialog("accent");
            },
          ),

          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text("Barva karet"),
            onTap: () {
              openColorDialog("card");
            },
          ),

          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text("Pozadí aplikace"),
            onTap: () {
              openColorDialog("background");
            },
          ),
        ],
      ),
    );
  }
}
