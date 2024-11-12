import 'package:flutter/material.dart';

class CalendarHeader extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onPreviousYear;
  final VoidCallback onNextYear;
  final VoidCallback onToday;

  const CalendarHeader({
    super.key,
    required this.currentMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onPreviousYear,
    required this.onNextYear,
    required this.onToday,
  });

  String getMonthName(int month) {
    const monthNames = [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь'
    ];
    return monthNames[month - 1];
  }

  Color getSeasonColor() {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.cyanAccent),
            onPressed: onPreviousMonth,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.cyanAccent),
            onPressed: onPreviousYear,
          ),
          Text(
            '${getMonthName(currentMonth.month)} ${currentMonth.year}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: getSeasonColor(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.cyanAccent),
            onPressed: onNextYear,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.cyanAccent),
            onPressed: onNextMonth,
          ),
        ],
      ),
    );
  }
}
