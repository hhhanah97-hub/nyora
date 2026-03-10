import 'package:flutter/material.dart';
import '../store/store.dart';
import '../theme/app_theme.dart';

const List<String> monthName = [
  "Leden",
  "Únor",
  "Březen",
  "Duben",
  "Květen",
  "Červen",
  "Červenec",
  "Srpen",
  "Září",
  "Říjen",
  "Listopad",
  "Prosinec",
];

class CalendarCard extends StatelessWidget {
  final Store store;
  final DateTime month;
  final DateTime selectedDay;
  final void Function(DateTime) onDayTap;
  final void Function(int)? onMonthChange;
  final AppTheme theme;

  const CalendarCard({
    super.key,
    required this.store,
    required this.month,
    required this.selectedDay,
    required this.onDayTap,
    required this.onMonthChange,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final cs = Theme.of(context).colorScheme;

    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    final firstWeekday = first.weekday;
    final leadingEmpty = firstWeekday - 1;

    final totalCells = leadingEmpty + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final cellCount = rows * 7;

    return Card(
      color: theme.card,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => onMonthChange?.call(-1),
                ),

                Text(
                  "${monthName[month.month - 1]} ${month.year}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => onMonthChange?.call(1),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// WEEKDAY HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Po", style: TextStyle(color: theme.textOnCard)),
                Text("Út", style: TextStyle(color: theme.textOnCard)),
                Text("St", style: TextStyle(color: theme.textOnCard)),
                Text("Čt", style: TextStyle(color: theme.textOnCard)),
                Text("Pá", style: TextStyle(color: theme.textOnCard)),
                Text("So", style: TextStyle(color: theme.textOnCard)),
                Text("Ne", style: TextStyle(color: theme.textOnCard)),
              ],
            ),

            const SizedBox(height: 8),

            /// GRID
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cellCount,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisExtent: 50,
              ),
              itemBuilder: (context, index) {
                if (index < leadingEmpty) {
                  return const SizedBox();
                }

                final day = index - leadingEmpty + 1;

                if (day > daysInMonth) {
                  return const SizedBox();
                }

                final date = DateTime(month.year, month.month, day);
                final today = DateTime.now();

                final isToday =
                    date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;

                final isSelected =
                    date.year == selectedDay.year &&
                    date.month == selectedDay.month &&
                    date.day == selectedDay.day;

                return GestureDetector(
                  onTap: () => onDayTap(date),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: isSelected
                        ? BoxDecoration(
                            color: theme.accent,
                            borderRadius: BorderRadius.circular(8),
                          )
                        : isToday
                        ? BoxDecoration(
                            // ignore: deprecated_member_use
                            color: Colors.blue.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          )
                        : null,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${date.day}",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white : null,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: store
                              .eventsForDay(date)
                              .take(3)
                              .map(
                                (e) => Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 1,
                                  ),
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: store.getCategoryColor(e.category),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
