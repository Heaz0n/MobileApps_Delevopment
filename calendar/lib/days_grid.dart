import 'package:flutter/material.dart';

class DaysGrid extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const DaysGrid({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    int totalDays = DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    int firstDayOffset =
        DateTime(currentMonth.year, currentMonth.month, 1).weekday - 1;

    List<Widget> daysList =
        List.generate(firstDayOffset, (index) => const SizedBox.shrink());

    for (int day = 1; day <= totalDays; day++) {
      DateTime currentDay =
          DateTime(currentMonth.year, currentMonth.month, day);
      DateTime today = DateTime.now();
      bool isToday = currentDay.year == today.year &&
          currentDay.month == today.month &&
          currentDay.day == today.day;
      bool isSelected =
          selectedDate != null && selectedDate!.isAtSameMomentAs(currentDay);

      daysList.add(
        GestureDetector(
          onTap: () => onDateSelected(currentDay),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.cyanAccent
                  : isToday
                      ? Colors.blueAccent.withOpacity(0.3)
                      : Colors.indigo[900],
              borderRadius: BorderRadius.circular(6),
              border: isToday
                  ? Border.all(color: Colors.cyanAccent, width: 2)
                  : null,
              boxShadow: isSelected
                  ? [
                      const BoxShadow(
                        color: Colors.cyanAccent,
                        blurRadius: 6,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: isSelected || isToday
                      ? Colors.indigo[900]
                      : Colors.cyanAccent,
                  fontWeight: isSelected || isToday
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      physics: const NeverScrollableScrollPhysics(),
      children: daysList,
    );
  }
}
