import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionListItem extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionListItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Действие при нажатии на карточку
        },
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getCategoryColor(transaction['type'], 0),
            child: Icon(
              transaction['type'] == 'Доход'
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              color: Colors.white,
            ),
          ),
          title: Text(
            transaction['description'],
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            '${transaction['type']} - ${transaction['amount']} ₽',
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          trailing: Text(
            DateFormat('dd.MM.yyyy')
                .format(DateTime.parse(transaction['date'])),
            style: GoogleFonts.roboto(
              fontSize: 14,
            ),
          ),
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
}
