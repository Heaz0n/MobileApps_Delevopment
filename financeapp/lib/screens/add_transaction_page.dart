import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  AddTransactionPageState createState() => AddTransactionPageState();
}

class AddTransactionPageState extends State<AddTransactionPage> {
  final formKey = GlobalKey<FormState>();
  final descriptionController = TextEditingController();
  final amountController = TextEditingController();
  String? transactionType;
  bool isSaving = false;
  DateTime? transactionDate;

  final List<String> transactionTypes = [
    'Доход',
    'Расход',
    'Сбережения',
    'Инвестиции',
  ];

  Future<void> addTransaction(
      String description, double amount, String type, DateTime date) async {
    final transactionData = {
      'description': description,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
    };

    await DatabaseHelper.instance.insertTransaction(transactionData);
  }

  Future<void> _showAddTypeDialog(BuildContext context) async {
    final newTypeController = TextEditingController();
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Добавить новый тип'),
          content: TextField(
            controller: newTypeController,
            decoration: const InputDecoration(
              labelText: 'Новый тип',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                if (newTypeController.text.isNotEmpty) {
                  setState(() {
                    transactionTypes.add(newTypeController.text);
                    transactionType = newTypeController.text;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить транзакцию'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Введите описание' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Сумма',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Введите сумму' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: transactionType,
                decoration: const InputDecoration(
                  labelText: 'Тип',
                  border: OutlineInputBorder(),
                ),
                items: [
                  ...transactionTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  const DropdownMenuItem(
                    value: 'Добавить новый тип',
                    child: Text(
                      'Добавить новый тип',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value == 'Добавить новый тип') {
                    _showAddTypeDialog(context);
                  } else {
                    setState(() {
                      transactionType = value;
                    });
                  }
                },
                validator: (value) =>
                    value == null ? 'Выберите тип транзакции' : null,
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('Дата транзакции'),
                subtitle: Text(transactionDate != null
                    ? DateFormat('dd.MM.yyyy').format(transactionDate!)
                    : 'Не выбрана'),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: transactionDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      transactionDate = pickedDate;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        if (formKey.currentState?.validate() == true) {
                          setState(() {
                            isSaving = true;
                          });

                          await addTransaction(
                            descriptionController.text,
                            double.parse(amountController.text),
                            transactionType!,
                            transactionDate ?? DateTime.now(),
                          );

                          setState(() {
                            isSaving = false;
                          });

                          Navigator.pop(context, true);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
