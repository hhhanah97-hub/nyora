import 'package:flutter/material.dart';
import 'store/store.dart';
import 'screens/home_screen.dart';
import 'theme/theme_controller.dart'; // Předpokládám, že máš soubor v této složce
import 'theme/app_theme.dart';

// Globální instance, ke kterým budeme přistupovat
final themeController = ThemeController();
final globalStore = Store();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Načtení uložených dat a tématu při startu
  await globalStore.load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder sleduje themeController.
    // Když změníš paletu, automaticky znovu sestaví celou appku s novými barvami.
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Nyora',
          // Tady propojujeme Flutter téma s naším vybraným tématem
          theme: themeController.themeData,
          home: HomeScreen(
            store: globalStore,
            paletteCtrl: themeController,
            theme: themeController
                .currentTheme, // Předáváme aktuální objekt AppTheme
            onThemeChanged: (newTheme) {
              themeController.setTheme(newTheme);
            },
          ),
        );
      },
    );
  }
}
