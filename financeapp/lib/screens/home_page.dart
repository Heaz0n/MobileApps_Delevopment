import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../database/database_helper.dart';
import '../widgets/charts/pie_chart.dart' as pie_chart;
import '../widgets/charts/bar_chart.dart' as bar_chart;
import '../widgets/transaction_list_item.dart';
import 'add_transaction_page.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  DateTime? startDate;
  DateTime? endDate;
  bool isAscending = false;
  bool isPieChart = true;
  DateTime? filterStartDate;
  DateTime? filterEndDate;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      setState(() {
        setFilterDates();
      });
    });
    setFilterDates();
  }

  void setFilterDates() {
    final now = DateTime.now();
    switch (tabController.index) {
      case 0:
        startDate = DateTime(now.year, now.month, now.day);
        endDate = startDate!
            .add(const Duration(days: 1))
            .subtract(const Duration(seconds: 1));
        break;
      case 1:
        final weekday = now.weekday;
        startDate = now.subtract(Duration(days: weekday - 1));
        endDate = startDate!
            .add(const Duration(days: 7))
            .subtract(const Duration(seconds: 1));
        break;
      case 2:
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 1)
            .subtract(const Duration(seconds: 1));
        break;
    }
  }

  Future<List<Map<String, dynamic>>> fetchTransactions() async {
    return DatabaseHelper.instance.fetchTransactions(
      startDate: filterStartDate ?? startDate,
      endDate: filterEndDate ?? endDate,
      isAscending: isAscending,
    );
  }

  Future<void> selectDate(BuildContext context, bool isStartDate) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && mounted) {
      setState(() {
        if (isStartDate) {
          filterStartDate = pickedDate;
        } else {
          filterEndDate = pickedDate;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Финансовый журнал'),
        backgroundColor: Colors.blue,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.green],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        bottom: TabBar(
          controller: tabController,
          labelStyle: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          unselectedLabelStyle: GoogleFonts.roboto(
            fontSize: 14,
          ),
          indicatorColor: Colors.white,
          indicatorWeight: 3.0,
          tabs: const [
            Tab(text: 'День'),
            Tab(text: 'Неделя'),
            Tab(text: 'Месяц'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isAscending ? Icons.arrow_downward : Icons.arrow_upward,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isAscending = !isAscending;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () async {
              await selectDate(context, true);
              await selectDate(context, false);
            },
          ),
          IconButton(
            icon: Icon(
              isPieChart ? Icons.bar_chart : Icons.pie_chart,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isPieChart = !isPieChart;
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchTransactions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Ошибка загрузки данных'));
            }

            final transactions = snapshot.data ?? [];

            if (transactions.isEmpty) {
              return Center(
                child: Text(
                  'Транзакции отсутствуют',
                  style: GoogleFonts.roboto(fontSize: 18),
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: isPieChart
                        ? pie_chart
                            .buildPieChart(transactions) // Используем префикс
                        : bar_chart
                            .buildBarChart(transactions), // Используем префикс
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return TransactionListItem(transaction: transaction);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTransactionPage()),
          );
          if (result == true && mounted) {
            setState(() {}); // Обновляем данные
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.amber,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
