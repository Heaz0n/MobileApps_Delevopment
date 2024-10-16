import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Калькулятор',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => CalculatorState();
}

class CalculatorState extends State<Calculator> {
  String displayText = '0';
  String selectedOperator = '';
  double firstOperand = 0.0;

  void onButtonClick(String label) {
    setState(() {
      switch (label) {
        case '=':
          performCalculation();
          break;
        case 'C':
          displayText = '0';
          resetOperator();
          break;
        case '<':
          removeLastCharacter();
          break;
        case '√':
        case '+':
        case '-':
        case '*':
        case '/':
        case '^':
          chooseOperator(label);
          break;
        case '.':
          addDecimalPoint();
          break;
        default:
          appendNumber(label);
          break;
      }
    });
  }

  void appendNumber(String number) {
    if (displayText == '0' || displayText == 'Нельзя делить на ноль') {
      displayText = number;
    } else {
      displayText += number;
    }
  }

  void addDecimalPoint() {
    if (!displayText.contains('.')) {
      displayText += '.';
    }
  }

  void chooseOperator(String newOperator) {
    if (selectedOperator.isNotEmpty) {
      performCalculation();
    }
    firstOperand = parseDisplayText(displayText);
    selectedOperator = newOperator;
    displayText += ' $newOperator ';
  }

  void performCalculation() {
    if (selectedOperator.isEmpty) return;

    List<String> components = displayText.split(' ');

    // Обработка корня
    if (selectedOperator == '√') {
      double result = sqrt(firstOperand);
      displayText = result.toString();
      resetOperator();
      return;
    }

    if (components.length < 3) return;

    double secondOperand = parseDisplayText(components[2]);

    switch (selectedOperator) {
      case '+':
        displayText = (firstOperand + secondOperand).toString();
        break;
      case '-':
        displayText = (firstOperand - secondOperand).toString();
        break;
      case '*':
        displayText = (firstOperand * secondOperand).toString();
        break;
      case '/':
        displayText = secondOperand == 0
            ? 'Нельзя делить на ноль'
            : (firstOperand / secondOperand).toString();
        break;
      case '^':
        if (components.length >= 3 && components[2].isNotEmpty) {
          displayText = pow(firstOperand, secondOperand).toString();
        }
        break;
    }
    resetOperator();
  }

  void removeLastCharacter() {
    if (displayText.length > 1) {
      displayText = displayText.substring(0, displayText.length - 1);
    } else {
      displayText = '0';
    }
  }

  double parseDisplayText(String text) {
    if (text.isEmpty) {
      return 0.0; // Возвращаем 0.0 для устранения ошибок
    }
    return double.parse(text);
  }

  void resetOperator() {
    selectedOperator = '';
    firstOperand = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Калькулятор'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          buildDisplay(),
          buildButtonRow(['C', '√', '^', '/'], Colors.deepOrange),
          buildButtonRow(['7', '8', '9', '*'], Colors.green),
          buildButtonRow(['4', '5', '6', '-'], Colors.blueAccent),
          buildButtonRow(['1', '2', '3', '+'], Colors.redAccent),
          buildButtonRow(['0', '.', '<', '='], Colors.deepPurpleAccent),
        ],
      ),
    );
  }

  Widget buildDisplay() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        alignment: Alignment.bottomRight,
        child: Text(
          displayText,
          style: const TextStyle(
            fontSize: 48.0,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget buildButtonRow(List<String> labels, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: labels.map((label) => buildButton(label, color)).toList(),
      ),
    );
  }

  Widget buildButton(String label, Color color) {
    return ElevatedButton(
      onPressed: () => onButtonClick(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(80, 80),
        shape: const CircleBorder(),
        textStyle: const TextStyle(fontSize: 24.0),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 24.0,
          color: Colors.white,
        ),
      ),
    );
  }
}
