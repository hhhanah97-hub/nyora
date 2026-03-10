import 'package:flutter/material.dart';

class AppTheme {
  Color accent;
  Color background;
  Color card;

  AppTheme({
    required this.accent,
    required this.background,
    required this.card,
  });
  Color get textOnBackground {
    return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  Color get textOnCard {
    return card.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
