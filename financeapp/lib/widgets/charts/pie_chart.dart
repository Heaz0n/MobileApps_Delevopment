import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildPieChart(List<Map<String, dynamic>> transactions) {
  if (transactions.isEmpty) {
    return Center(
      child: Text(
        'Нет данных для отображения',
        style: GoogleFonts.roboto(fontSize: 16),
      ),
    );
  }

  // Собираем данные по категориям
  Map<String, double> categoryAmounts = {};
  for (var transaction in transactions) {
    String type = transaction['type'];
    double amount = transaction['amount'];
    categoryAmounts[type] = (categoryAmounts[type] ?? 0) + amount;
  }

  // Сумма всех транзакций
  double total = categoryAmounts.values.reduce((a, b) => a + b);

  // Создаем секции для диаграммы
  List<PieChartSectionData> sections = [];
  int colorIndex = 0;
  categoryAmounts.forEach((type, amount) {
    double percentage = total > 0 ? (amount / total * 100) : 0;
    sections.add(
      PieChartSectionData(
        value: amount,
        title: '$type\n${percentage.toStringAsFixed(1)}%',
        color: _getCategoryColor(type, colorIndex),
        titleStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: 60,
        badgeWidget: buildBadge(type, _getCategoryColor(type, colorIndex)),
        badgePositionPercentageOffset: 1.2,
      ),
    );
    colorIndex++;
  });

  return PieChart(
    PieChartData(
      sections: sections,
      sectionsSpace: 4,
      centerSpaceRadius: 40,
      borderData: FlBorderData(show: false),
      startDegreeOffset: -90,
      pieTouchData: PieTouchData(
        touchCallback: (FlTouchEvent event, PieTouchResponse? touchResponse) {
          // Обработка нажатия на секцию
        },
      ),
    ),
  );
}

// Виджет для отображения бейджа
Widget buildBadge(String text, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.8),
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Text(
      text,
      style: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
  );
}

// Метод для получения цвета категории
Color _getCategoryColor(String type, int index) {
  List<Color> categoryColors = [
    Colors.green, // Доход
    Colors.orange, // Расход
    Colors.blue, // Сбережения
    Colors.purple, // Инвестиции
    Colors.red, // Новые категории
    Colors.pink,
    Colors.teal,
    Colors.indigo,
  ];

  switch (type) {
    case 'Доход':
      return categoryColors[0];
    case 'Расход':
      return categoryColors[1];
    case 'Сбережения':
      return categoryColors[2];
    case 'Инвестиции':
      return categoryColors[3];
    default:
      return categoryColors[4 + (index % 4)];
  }
}
