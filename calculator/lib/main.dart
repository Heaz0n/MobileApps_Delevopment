import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        brightness: Brightness.light,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String expression = "";
  String result = "";
  String errorMessage = "";
  String activeButton = "";
  bool justCalculated = false;

  void calculateResult() {
    try {
      String finalExpression = expression.replaceAll('X', '*');

      // Обработка квадратного корня
      if (finalExpression.contains('√')) {
        finalExpression = finalExpression.replaceAll('√', 'sqrt');
      }

      // Обработка факториала
      if (finalExpression.contains('!')) {
        finalExpression = handleFactorial(finalExpression);
      }

      Parser parser = Parser();
      Expression exp = parser.parse(finalExpression);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      result = eval.toString();
      justCalculated = true;

      if (result.length > 10) {
        result = result.substring(0, 10);
      }
    } catch (e) {
      errorMessage = "Ошибка!";
      setState(() {});
    }
  }

  // Функция для обработки факториала
  String handleFactorial(String expression) {
    RegExp regex = RegExp(r'(\d+)!'); // Поиск числа перед символом "!"
    return expression.replaceAllMapped(regex, (match) {
      int num = int.parse(match.group(1)!);
      return factorial(num).toString();
    });
  }

  // Вычисление факториала
  int factorial(int n) {
    if (n <= 1) {
      return 1;
    } else {
      return n * factorial(n - 1);
    }
  }

  void buttonPressed(String key) {
    setState(() {
      activeButton = key;

      if (justCalculated) {
        if ("0123456789".contains(key)) {
          expression = key;
          result = "";
        } else if ("+-X/^%√!".contains(key)) {
          expression = result + key;
        } else if (key == "=") {
          expression = result;
          calculateResult();
        }
        justCalculated = false;
      } else if (key == "=") {
        calculateResult();
      } else if (key == "AC") {
        resetCalculator();
      } else if (key == "C") {
        clearLastEntry();
      } else {
        expression += key;
      }

      Future.delayed(const Duration(milliseconds: 50), () {
        setState(() {
          activeButton = "";
        });
      });
    });
  }

  void resetCalculator() {
    expression = "";
    result = "";
    errorMessage = "";
    justCalculated = false;
  }

  void clearLastEntry() {
    if (expression.isNotEmpty) {
      expression = expression.substring(0, expression.length - 1);
    } else {
      resetCalculator();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculator"),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(20.0),
              child: Text(
                expression,
                style: const TextStyle(
                  fontSize: 30.0,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(20.0),
              child: Text(
                errorMessage.isEmpty ? result : errorMessage,
                style: const TextStyle(fontSize: 50.0, color: Colors.black),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: GridView.count(
              crossAxisCount: 4,
              padding: const EdgeInsets.all(10),
              children: <Widget>[
                buildButton("AC", color: Colors.redAccent),
                buildButton("C", color: Colors.redAccent),
                buildButton("%", color: Colors.deepOrangeAccent),
                buildButton("/", color: Colors.deepOrangeAccent),
                buildButton("7"),
                buildButton("8"),
                buildButton("9"),
                buildButton("X", color: Colors.deepOrangeAccent),
                buildButton("4"),
                buildButton("5"),
                buildButton("6"),
                buildButton("-", color: Colors.deepOrangeAccent),
                buildButton("1"),
                buildButton("2"),
                buildButton("3"),
                buildButton("+", color: Colors.deepOrangeAccent),
                buildButton("0"),
                buildButton("."),
                buildButton("√", color: Colors.deepOrangeAccent),
                buildButton("=", color: Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton(String label, {Color color = Colors.grey}) {
    return MaterialButton(
      height: 90.0,
      color: activeButton == label ? Colors.blueGrey : color,
      textColor: Colors.black,
      onPressed: () => buttonPressed(label),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(45.0), // Радиус закругления кнопок
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
      ),
    );
  }
}
