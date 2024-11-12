import 'package:flutter/material.dart';
import 'calendar_header.dart';
import 'week_days_row.dart';
import 'days_grid.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  DateTime currentMonth = DateTime.now();
  DateTime? selectedDate;

  void switchToNextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    });
  }

  void switchToPreviousMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
    });
  }

  void switchToNextYear() {
    setState(() {
      currentMonth = DateTime(currentMonth.year + 1, currentMonth.month, 1);
    });
  }

  void switchToPreviousYear() {
    setState(() {
      currentMonth = DateTime(currentMonth.year - 1, currentMonth.month, 1);
    });
  }

  void goToCurrentMonth() {
    setState(() {
      currentMonth = DateTime.now();
      selectedDate = null;
    });
  }

  void onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Календарь',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.cyanAccent,
            shadows: [Shadow(blurRadius: 4, color: Colors.cyan)],
          ),
        ),
        backgroundColor: Colors.indigo[900],
        centerTitle: true,
      ),
      body: Column(
        children: [
          CalendarHeader(
            currentMonth: currentMonth,
            onPreviousMonth: switchToPreviousMonth,
            onNextMonth: switchToNextMonth,
            onPreviousYear: switchToPreviousYear,
            onNextYear: switchToNextYear,
            onToday: goToCurrentMonth,
          ),
          WeekDaysRow(),
          Expanded(
            child: DaysGrid(
              currentMonth: currentMonth,
              selectedDate: selectedDate,
              onDateSelected: onDateSelected,
            ),
          ),
        ],
      ),
      floatingActionButton: (currentMonth.month != DateTime.now().month ||
              currentMonth.year != DateTime.now().year)
          ? FloatingActionButton(
              onPressed: goToCurrentMonth,
              backgroundColor: Colors.cyanAccent,
              child: const Icon(Icons.today, color: Colors.indigo),
            )
          : null,
    );
  }
}
