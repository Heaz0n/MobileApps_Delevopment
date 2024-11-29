import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => WeatherScreenState();
}

class WeatherScreenState extends State<WeatherScreen> {
  final String apiKey = '1e2ec7ea29464c4591a134603242911';
  final List<String> cities = [
    'Moscow',
    'Sochi',
    'Yekaterinburg',
    'Surgut',
    'Khanty-Mansiysk',
    'Seversk'
  ];

  String? selectedCity;
  Map<String, dynamic>? currentWeatherData;
  List<dynamic>? dailyForecastData;
  String? errorMessage;

  Future<void> loadWeatherData(String city) async {
    setState(() {
      errorMessage = null;
      currentWeatherData = null;
      dailyForecastData = null;
    });

    try {
      await fetchWeatherData(city);
    } catch (e) {
      setState(() {
        errorMessage =
            "Ой, кажется, мы потеряли связь с погодой. Может, она просто пошла пить кофе?";
      });
    }
  }

  Future<void> fetchWeatherData(String city) async {
    final url = Uri.parse(
        'https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$city&days=7');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          currentWeatherData = data;
          dailyForecastData = data['forecast']['forecastday'];
        });
      } else {
        print('Ошибка API: ${response.body}');
        setState(() {
          errorMessage =
              "Ошибка ${response.statusCode}: ${response.reasonPhrase}";
        });
      }
    } catch (e) {
      print('Сетевая ошибка: $e');
      setState(() {
        errorMessage = "Ошибка подключения: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Прогноз погоды'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 12,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: const Text(
                "Выберите город",
                style: TextStyle(color: Colors.white),
              ),
              value: selectedCity,
              isExpanded: true,
              items: cities
                  .map((city) => DropdownMenuItem(
                        value: city,
                        child: Text(
                          city,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCity = value;
                  });
                  loadWeatherData(value);
                }
              },
            ),
            const SizedBox(height: 20),
            if (errorMessage != null)
              Center(
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              )
            else if (selectedCity == null)
              const Text(
                "Пожалуйста, выберите город. Иначе, как мы узнаем, где дождик?",
                style: TextStyle(fontSize: 16, color: Colors.white70),
              )
            else if (currentWeatherData == null)
              const Center(child: CircularProgressIndicator())
            else
              WeatherInfo(currentWeatherData!),
            const SizedBox(height: 20),
            if (dailyForecastData != null)
              Expanded(
                child: DailyForecast(
                  dailyForecastData!,
                  onDaySelected: (index) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HourlyWeatherScreen(
                          hourlyData: dailyForecastData![index]['hour'],
                          dayIndex: index,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class WeatherInfo extends StatelessWidget {
  final Map<String, dynamic> data;

  const WeatherInfo(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    final currentData = data['current'];

    String conditionText = currentData['condition']['text'];
    String emoji = '';

    if (conditionText == "Sunny") {
      conditionText = "Яркое солнце! 😎 Не забудьте крем от загара!";
      emoji = "☀️";
    } else if (conditionText.contains("Rain")) {
      conditionText = "Дождик! 🌧 Надевайте резиновые сапоги!";
      emoji = "🌂";
    } else if (conditionText.contains("Snow")) {
      conditionText = "Снег идет! ❄️ Лепите снеговика!";
      emoji = "⛄";
    } else if (conditionText.contains("Cloudy")) {
      conditionText = "Облачно, но надежда на солнце есть! ☁️";
      emoji = "🌥️";
    } else {
      conditionText = "Погода такая, что даже прогноз растерялся! 🤔";
      emoji = "❓";
    }

    String additionalMessage = '';
    if (currentData['temp_c'] < -20) {
      additionalMessage =
          "🥶 Холодно! Время для горячего чая и объятий с друзьями!";
    }

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(seconds: 2),
      child: Card(
        elevation: 10,
        color: Colors.lightBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${data['location']['name']}, ${data['location']['country']}',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                '$emoji ${currentData['temp_c']}°C',
                style: const TextStyle(
                    fontSize: 55,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              const SizedBox(height: 5),
              Text(
                conditionText,
                style: const TextStyle(fontSize: 20, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              if (additionalMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    additionalMessage,
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.yellowAccent,
                        fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  WeatherDetail(
                    icon: Icons.water_drop,
                    label: 'Влажность',
                    value: '${currentData['humidity']}%',
                  ),
                  WeatherDetail(
                    icon: Icons.wind_power,
                    label: 'Ветер',
                    value: '${currentData['wind_kph']} км/ч',
                  ),
                  WeatherDetail(
                    icon: Icons.speed,
                    label: 'Давление',
                    value: '${currentData['pressure_mb']} мбар',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Циклы времен года: весна — солнце, лето — жара, осень — дожди, зима — ожидание следующего отпуска! 🌍",
                style: TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DailyForecast extends StatelessWidget {
  final List<dynamic> forecast;
  final ValueChanged<int> onDaySelected;

  const DailyForecast(this.forecast, {required this.onDaySelected, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: forecast.length,
      itemBuilder: (context, index) {
        final day = forecast[index];
        return GestureDetector(
          onTap: () => onDaySelected(index),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.blueAccent,
            child: ListTile(
              title: Text(
                day['date'],
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                'Температура: ${day['day']['avgtemp_c']}°C',
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

class HourlyWeatherScreen extends StatelessWidget {
  final List<dynamic> hourlyData;
  final int dayIndex;

  const HourlyWeatherScreen({
    required this.hourlyData,
    required this.dayIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Часовой прогноз'),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView.builder(
        itemCount: hourlyData.length,
        itemBuilder: (context, index) {
          final hourData = hourlyData[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.deepOrange,
            child: ListTile(
              leading: const Icon(Icons.access_time, color: Colors.white),
              title: Text(
                hourData['time'].substring(11, 16),
                style: const TextStyle(color: Colors.white),
              ),
              trailing: Text(
                '${hourData['temp_c']}°C',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}

class WeatherDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const WeatherDetail({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 30,
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
