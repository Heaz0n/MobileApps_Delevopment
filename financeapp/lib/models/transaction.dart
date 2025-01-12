class Transaction {
  final int? id;
  final String description;
  final double amount;
  final String type;
  final DateTime date;

  Transaction({
    this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
    };
  }
}
