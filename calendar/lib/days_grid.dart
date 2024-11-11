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

    List<Widget> daysList = [];

    for (int i = 0; i < firstDayOffset; i++) {
      daysList.add(const SizedBox.shrink());
    }

    for (int day = 1; day <= totalDays; day++) {
      DateTime currentDay =
          DateTime(currentMonth.year, currentMonth.month, day);
      bool isToday = currentDay.day == DateTime.now().day &&
          currentDay.month == DateTime.now().month &&
          currentDay.year == DateTime.now().year;
      bool isSelected = selectedDate != null &&
          selectedDate!.year == currentDay.year &&
          selectedDate!.month == currentDay.month &&
          selectedDate!.day == currentDay.day;

      daysList.add(
        GestureDetector(
          onTap: () => onDateSelected(currentDay),
          child: Container(
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blueAccent
                  : isToday
                      ? Colors.blueAccent
                      : Colors.blueGrey,
              borderRadius: BorderRadius.circular(6.0),
              boxShadow: isSelected || isToday
                  ? [
                      BoxShadow(
                        color: Colors.tealAccent.withOpacity(0.5),
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
                  color: isSelected || isToday ? Colors.blueGrey : Colors.white,
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
      padding: const EdgeInsets.all(8.0),
      physics: const NeverScrollableScrollPhysics(),
      children: daysList,
    );
  }
}
