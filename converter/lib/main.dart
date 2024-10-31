import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Конвертер единиц',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          headlineLarge: TextStyle(
              fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
          bodyLarge: TextStyle(fontSize: 22, color: Colors.black),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<Tile> tiles = [
    Tile('Масса', 'lib/images/mass.png'),
    Tile('Валюта', 'lib/images/currency.png'),
    Tile('Температура', 'lib/images/temperature.png'),
    Tile('Длина', 'lib/images/length.png'),
    Tile('Площадь', 'lib/images/area.png'),
    Tile('Время', 'lib/images/time.png'),
    Tile('Скорость', 'lib/images/speed.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Конвертер единиц', style: TextStyle(fontSize: 26)),
          centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 180,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 1.0,
          ),
          itemCount: tiles.length,
          itemBuilder: (context, index) => buildTile(context, tiles[index]),
        ),
      ),
    );
  }

  Widget buildTile(BuildContext context, Tile tile) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ConverterPage(title: tile.title)),
      ),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipOval(
              child: Image.asset(tile.imagePath,
                  width: 70, height: 70, fit: BoxFit.cover),
            ),
            Positioned(
              bottom: 10,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10)),
                child: Text(
                  tile.title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Tile {
  final String title;
  final String imagePath;

  Tile(this.title, this.imagePath);
}

class ConverterPage extends StatefulWidget {
  final String title;

  ConverterPage({required this.title});

  @override
  ConverterPageState createState() => ConverterPageState();
}

class ConverterPageState extends State<ConverterPage> {
  double inputValue = 0.0;
  String selectedUnit = '';
  Map<String, double> conversionResults = {};

  void performConversion() {
    conversionResults.clear();
    if (selectedUnit.isNotEmpty && inputValue != 0) {
      switch (widget.title) {
        case 'Масса':
          conversionResults = convertMass();
          break;
        case 'Валюта':
          conversionResults = convertCurrency();
          break;
        case 'Температура':
          conversionResults = convertTemperature();
          break;
        case 'Длина':
          conversionResults = convertLength();
          break;
        case 'Площадь':
          conversionResults = convertArea();
          break;
        case 'Время':
          conversionResults = convertTime();
          break;
        case 'Скорость':
          conversionResults = convertSpeed();
          break;
      }
    }
    setState(() {});
  }

  Map<String, double> convertMass() {
    switch (selectedUnit) {
      case 'Килограмм':
        return {
          'Грамм': inputValue * 1000,
          'Миллион тонн': inputValue / 1000,
        };
      case 'Грамм':
        return {
          'Килограмм': inputValue / 1000,
          'Миллион тонн': inputValue / 1e6,
        };
      case 'Миллион тонн':
        return {
          'Килограмм': inputValue * 1e6,
          'Грамм': inputValue * 1e9,
        };
      default:
        return {};
    }
  }

  Map<String, double> convertCurrency() {
    switch (selectedUnit) {
      case 'Рубль':
        return {
          'Доллар': inputValue * 0.013,
          'Евро': inputValue * 0.011,
        };
      case 'Доллар':
        return {
          'Рубль': inputValue / 0.013,
          'Евро': inputValue * 0.85,
        };
      case 'Евро':
        return {
          'Рубль': inputValue / 0.011,
          'Доллар': inputValue / 0.85,
        };
      default:
        return {};
    }
  }

  Map<String, double> convertTemperature() {
    switch (selectedUnit) {
      case 'Цельсий':
        return {
          'Фаренгейт': (inputValue * 9 / 5) + 32,
          'Кельвин': inputValue + 273.15,
        };
      case 'Фаренгейт':
        return {
          'Цельсий': (inputValue - 32) * 5 / 9,
          'Кельвин': (inputValue - 32) * 5 / 9 + 273.15,
        };
      case 'Кельвин':
        return {
          'Цельсий': inputValue - 273.15,
          'Фаренгейт': (inputValue - 273.15) * 9 / 5 + 32,
        };
      default:
        return {};
    }
  }

  Map<String, double> convertLength() {
    switch (selectedUnit) {
      case 'Метр':
        return {
          'Километр': inputValue / 1000,
          'Миля': inputValue / 1609.34,
        };
      case 'Километр':
        return {
          'Метр': inputValue * 1000,
          'Миля': inputValue / 0.621371,
        };
      case 'Миля':
        return {
          'Метр': inputValue * 1609.34,
          'Километр': inputValue * 1.60934,
        };
      default:
        return {};
    }
  }

  Map<String, double> convertArea() {
    switch (selectedUnit) {
      case 'Квадратный метр':
        return {
          'Гектар': inputValue / 10000,
          'Акр': inputValue / 4046.86,
        };
      case 'Гектар':
        return {
          'Квадратный метр': inputValue * 10000,
          'Акр': inputValue * 2.47105,
        };
      case 'Акр':
        return {
          'Квадратный метр': inputValue * 4046.86,
          'Гектар': inputValue / 2.47105,
        };
      default:
        return {};
    }
  }

  Map<String, double> convertTime() {
    switch (selectedUnit) {
      case 'Час':
        return {
          'Минута': inputValue * 60,
          'Секунда': inputValue * 3600,
        };
      case 'Минута':
        return {
          'Час': inputValue / 60,
          'Секунда': inputValue * 60,
        };
      case 'Секунда':
        return {
          'Час': inputValue / 3600,
          'Минута': inputValue / 60,
        };
      default:
        return {};
    }
  }

  Map<String, double> convertSpeed() {
    switch (selectedUnit) {
      case 'Метры в секунду':
        return {
          'Километры в час': inputValue * 3.6,
          'Мили в час': inputValue * 2.23694,
        };
      case 'Километры в час':
        return {
          'Метры в секунду': inputValue / 3.6,
          'Мили в час': inputValue / 1.60934,
        };
      case 'Мили в час':
        return {
          'Метры в секунду': inputValue / 2.23694,
          'Километры в час': inputValue * 1.60934,
        };
      default:
        return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                inputValue = double.tryParse(value) ?? 0;
                performConversion();
              },
              decoration: InputDecoration(labelText: 'Введите значение'),
            ),
            DropdownButton<String>(
              hint: Text('Выберите единицу'),
              value: selectedUnit.isNotEmpty ? selectedUnit : null,
              onChanged: (String? newValue) {
                setState(() {
                  selectedUnit = newValue ?? '';
                  performConversion();
                });
              },
              items: getUnits().map<DropdownMenuItem<String>>((String unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text('Результаты:', style: TextStyle(fontSize: 22)),
            ...conversionResults.entries.map((entry) {
              return Text('${entry.key}: ${entry.value}');
            }).toList(),
          ],
        ),
      ),
    );
  }

  List<String> getUnits() {
    switch (widget.title) {
      case 'Масса':
        return ['Килограмм', 'Грамм', 'Миллион тонн'];
      case 'Валюта':
        return ['Рубль', 'Доллар', 'Евро'];
      case 'Температура':
        return ['Цельсий', 'Фаренгейт', 'Кельвин'];
      case 'Длина':
        return ['Метр', 'Километр', 'Миля'];
      case 'Площадь':
        return ['Квадратный метр', 'Гектар', 'Акр'];
      case 'Время':
        return ['Час', 'Минута', 'Секунда'];
      case 'Скорость':
        return ['Метры в секунду', 'Километры в час', 'Мили в час'];
      default:
        return [];
    }
  }
}
