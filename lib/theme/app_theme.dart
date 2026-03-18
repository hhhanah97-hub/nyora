import 'package:flutter/material.dart';

class AppTheme {
  final Color accent;
  final Color background;
  final Color card;
  final Color cyclePeriod;
  final Color cycleExpected;
  final Color cycleOvulation;

  AppTheme({
    required this.accent,
    required this.background,
    required this.card,
    this.cyclePeriod = const Color(0xFFFF5E5E),
    this.cycleExpected = const Color(0xFFFFB7B7),
    this.cycleOvulation = const Color(0xFFB088FF),
  });

  // Tato barva chyběla v home_screen.dart
  Color get textOnBackground =>
      background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  // Barva textu přímo na kartičce (aby zmizely chyby v calendar_card.dart)
  Color get textOnCard =>
      card.computeLuminance() > 0.5 ? Colors.black : Colors.white;

  // Výchozí téma pro store.dart
  static AppTheme defaultTheme() => customLight;

  // --- 12 PALET ---
  static AppTheme get customLight => AppTheme(
    accent: const Color.fromARGB(255, 94, 9, 34),
    background: const Color.fromARGB(255, 246, 236, 239),
    card: Colors.white,
  );
  static AppTheme get parchment => AppTheme(
    accent: const Color.fromARGB(255, 67, 7, 26),
    background: const Color.fromARGB(255, 237, 225, 193),
    card: const Color.fromARGB(255, 136, 126, 102),
  );
  static AppTheme get morningMist => AppTheme(
    accent: const Color.fromARGB(255, 10, 71, 54),
    background: const Color.fromARGB(255, 140, 168, 153),
    card: const Color(0xFFF7F9FA),
  );
  static AppTheme get classicDark => AppTheme(
    background: const Color.fromARGB(255, 134, 135, 136),
    accent: const Color.fromARGB(255, 50, 37, 37),
    card: const Color.fromARGB(255, 62, 54, 54),
  );
  static AppTheme get slateBlue => AppTheme(
    background: const Color.fromARGB(255, 104, 110, 181),
    accent: const Color.fromARGB(255, 32, 43, 51),
    card: const Color(0xFF2C3136),
  );
  static AppTheme get coffee => AppTheme(
    accent: const Color.fromARGB(255, 108, 83, 67),
    background: const Color.fromARGB(255, 64, 54, 51),
    card: const Color(0xFF382A25),
  );
  static AppTheme get midnight => AppTheme(
    background: const Color(0xFF64FFDA),
    accent: const Color(0xFF0A192F),
    card: const Color(0xFF112240),
  );
  static AppTheme get forest => AppTheme(
    background: const Color.fromARGB(255, 216, 235, 159),
    accent: const Color.fromARGB(255, 18, 68, 47),
    card: const Color(0xFF28362C),
  );
  static AppTheme get ocean => AppTheme(
    background: const Color(0xFF4DD0E1),
    accent: const Color(0xFF0F2C33),
    card: const Color(0xFF163E48),
  );
  static AppTheme get warmDark => AppTheme(
    accent: const Color.fromARGB(255, 90, 19, 42),
    background: const Color.fromARGB(255, 150, 120, 133),
    card: const Color.fromARGB(255, 145, 120, 127),
  );
  static AppTheme get terracotta => AppTheme(
    accent: const Color(0xFFE29578),
    background: const Color.fromARGB(255, 199, 174, 168),
    card: const Color.fromARGB(255, 93, 84, 82),
  );
  static AppTheme get synthwave => AppTheme(
    accent: const Color.fromARGB(255, 69, 32, 49),
    background: const Color.fromARGB(255, 235, 195, 210),
    card: const Color.fromARGB(255, 150, 113, 136),
  );

  static List<AppTheme> allThemes = [
    customLight,
    parchment,
    morningMist,
    classicDark,
    slateBlue,
    coffee,
    midnight,
    forest,
    ocean,
    warmDark,
    terracotta,
    synthwave,
  ];

  // --- LOGIKA PRO STORE.DART (JSON) ---

  Map<String, dynamic> toJson() => {
    'accent': accent.value,
    'background': background.value,
    'card': card.value,
    'cyclePeriod': cyclePeriod.value,
    'cycleExpected': cycleExpected.value,
    'cycleOvulation': cycleOvulation.value,
  };

  factory AppTheme.fromJson(Map<String, dynamic> json) {
    return AppTheme(
      accent: Color(json['accent']),
      background: Color(json['background']),
      card: Color(json['card']),
      cyclePeriod: Color(json['cyclePeriod'] ?? 0xFFFF5E5E),
      cycleExpected: Color(json['cycleExpected'] ?? 0xFFFFB7B7),
      cycleOvulation: Color(json['cycleOvulation'] ?? 0xFFB088FF),
    );
  }
}
