import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ThemeScreen extends StatelessWidget {
  final AppTheme theme;
  final Function(AppTheme) onThemeChanged;

  const ThemeScreen({
    super.key,
    required this.theme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    // List všech dostupných palet z naší třídy AppTheme
    final allThemes = AppTheme.allThemes;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(
          "Výběr vzhledu",
          style: TextStyle(color: theme.textOnBackground),
        ),
        backgroundColor: theme.background,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.textOnBackground),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Vyberte si barevnou paletu",
              style: TextStyle(
                color: theme.textOnBackground,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Dva sloupce vedle sebe
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                itemCount: allThemes.length,
                itemBuilder: (context, index) {
                  final t = allThemes[index];
                  // Zjistíme, jestli je tato paleta právě vybraná
                  bool isSelected =
                      theme.background.value == t.background.value;

                  return GestureDetector(
                    onTap: () => onThemeChanged(t),
                    child: Container(
                      decoration: BoxDecoration(
                        color: t.background,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? t.accent
                              : Colors.grey.withOpacity(0.3),
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: t.accent.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Ukázka akcentní barvy (kolečko)
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: t.accent,
                            ),
                          ),
                          // Název palety (volitelné, zatím indexy)
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              _getThemeName(index),
                              style: TextStyle(
                                color: t.textOnBackground,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Positioned(
                              top: 8,
                              right: 8,
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pomocná funkce pro názvy palet
  String _getThemeName(int index) {
    List<String> names = [
      "Světlý",
      "Starý papír",
      "Ranní mlha",
      "Klasický tmavý",
      "Ocelová modř",
      "Kávové zrno",
      "Půlnoční obloha",
      "Hluboký les",
      "Oceánská hlubina",
      "Hřejivý večer",
      "Terakota",
      "Synthwave",
    ];
    return names[index];
  }
}
