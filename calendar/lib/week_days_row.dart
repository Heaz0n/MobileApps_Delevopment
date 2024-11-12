import 'package:flutter/material.dart';

class WeekDaysRow extends StatelessWidget {
  const WeekDaysRow({super.key});

  Color getSeasonColor(DateTime currentMonth) {
    int month = currentMonth.month;
    if (month == 12 || month == 1 || month == 2) {
      return Colors.blueAccent; // Зима
    } else if (month == 3 || month == 4 || month == 5) {
      return Colors.greenAccent; // Весна
    } else if (month == 6 || month == 7 || month == 8) {
      return Colors.yellowAccent; // Лето
    } else {
      return Colors.orangeAccent; // Осень
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime currentMonth = DateTime.now(); // текущий месяц

    List<String> weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        return Text(
          day,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: getSeasonColor(currentMonth),
          ),
        );
      }).toList(),
    );
  }
}
