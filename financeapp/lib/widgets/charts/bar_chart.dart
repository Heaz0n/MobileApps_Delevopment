import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

Widget buildBarChart(List<Map<String, dynamic>> transactions) {
  Map<String, double> categoryAmounts = {};
  for (var transaction in transactions) {
    String type = transaction['type'];
    double amount = transaction['amount'];
    categoryAmounts[type] = (categoryAmounts[type] ?? 0) + amount;
  }

  List<BarChartGroupData> barGroups = [];
  int colorIndex = 0;
  categoryAmounts.forEach((type, amount) {
    barGroups.add(
      BarChartGroupData(
        x: colorIndex,
        barRods: [
          BarChartRodData(
            toY: amount,
            color: _getCategoryColor(type, colorIndex),
            width: 20,
          ),
        ],
      ),
    );
    colorIndex++;
  });

  return BarChart(
    BarChartData(
      barGroups: barGroups,
      borderData: FlBorderData(show: true),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(
                categoryAmounts.keys.elementAt(value.toInt()),
                style: GoogleFonts.roboto(fontSize: 12),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(
                '${value.toInt()} ₽',
                style: GoogleFonts.roboto(fontSize: 12),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.3),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.3),
            strokeWidth: 1,
          );
        },
      ),
    ),
  );
}

Color _getCategoryColor(String type, int index) {
  List<Color> categoryColors = [
    Colors.green,
    Colors.orange,
    Colors.blue,
    Colors.purple,
    Colors.red,
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
