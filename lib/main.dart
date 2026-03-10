import 'package:flutter/material.dart';
import 'store/store.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final store = Store();
  await store.load();
  await store.loadCategories();

  runApp(MyApp(store: store));
}

class MyApp extends StatefulWidget {
  final Store store;

  const MyApp({super.key, required this.store});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AppTheme theme = AppTheme(
    accent: Colors.blue,
    background: Colors.grey.shade100,
    card: Colors.white,
  );

  void toggleTheme(Color color) {
    setState(() {
      theme.accent = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nyora',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: theme.accent),
        scaffoldBackgroundColor: theme.background,
        cardColor: theme.card,
      ),
      home: HomeScreen(
        store: widget.store,
        paletteCtrl: null,
        theme: theme,
        onThemeChanged: (newTheme) {
          setState(() {
            theme = newTheme;
          });
        },
      ),
    );
  }
}
