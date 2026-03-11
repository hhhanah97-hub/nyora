import 'package:flutter/material.dart';
import '../store/store.dart';
import '../widgets/calendar_card.dart';
import '../widgets/day_preview_section.dart';
import 'agenda_screen.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:convert';
import '../screens/theme_screen.dart';
import '../theme/app_theme.dart';
import '../screens/category_settings_screen.dart';
import '../screens/finance_overview_screen.dart';

class HomeScreen extends StatefulWidget {
  final Store store;
  final dynamic paletteCtrl;
  final AppTheme theme;
  final Function(AppTheme) onThemeChanged;

  const HomeScreen({
    super.key,
    required this.store,
    required this.paletteCtrl,
    required this.theme,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Store store;
  late DateTime selectedDay;
  late DateTime visibleMonth;

  @override
  void initState() {
    super.initState();

    selectedDay = dateOnly(DateTime.now());
    visibleMonth = DateTime(selectedDay.year, selectedDay.month, 1);

    widget.store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _selectDay(DateTime day) {
    setState(() {
      selectedDay = dateOnly(day);
    });
  }

  void _openAgenda() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgendaScreen(store: widget.store, theme: widget.theme),
      ),
    );
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Nastavení",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                ListTile(
                  leading: const Icon(Icons.palette),
                  title: const Text("Upravit vzhled"),
                  onTap: () {
                    Navigator.pop(context);

                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (context) {
                        return ThemeScreen(
                          theme: widget.theme,
                          onThemeChanged: (newTheme) {
                            widget.onThemeChanged(newTheme);
                          },
                        );
                      },
                    );
                  },
                ),

                const Divider(),

                ListTile(
                  leading: const Icon(Icons.label),
                  title: const Text("Kategorie událostí"),
                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CategorySettingsScreen(store: widget.store),
                      ),
                    );
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: const Text("Exportovat data"),
                  onTap: () {
                    final json = widget.store.exportToJson();

                    Navigator.pop(context);

                    final bytes = utf8.encode(json);
                    final blob = html.Blob([bytes]);
                    final url = html.Url.createObjectUrlFromBlob(blob);

                    html.AnchorElement(href: url)
                      ..setAttribute("download", "nyora_backup.json")
                      ..click();

                    html.Url.revokeObjectUrl(url);
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text("Importovat data"),
                  onTap: () async {
                    Navigator.pop(context);

                    final uploadInput = html.FileUploadInputElement();
                    uploadInput.accept = ".json";
                    uploadInput.click();

                    uploadInput.onChange.listen((event) {
                      final file = uploadInput.files?.first;
                      if (file == null) return;

                      final reader = html.FileReader();
                      reader.readAsText(file);

                      reader.onLoadEnd.listen((event) {
                        final jsonString = reader.result as String;
                        widget.store.importFromJson(jsonString);
                      });
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.theme.background,
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(),
              child: Text(
                "Nyora",
                style: TextStyle(color: widget.theme.textOnBackground),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.event),
              title: const Text("Události"),
              onTap: () {
                Navigator.pop(context);
                _openAgenda();
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text("Finance"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FinanceOverviewScreen(store: widget.store),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text("Nyora"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            CalendarCard(
              theme: widget.theme,
              store: widget.store,
              month: visibleMonth,
              selectedDay: selectedDay,
              onDayTap: _selectDay,
              onMonthChange: (delta) {
                setState(() {
                  visibleMonth = DateTime(
                    visibleMonth.year,
                    visibleMonth.month + delta,
                    1,
                  );
                });
              },
            ),

            DayPreviewSection(store: widget.store, selectedDay: selectedDay),
          ],
        ),
      ),
    );
  }
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
