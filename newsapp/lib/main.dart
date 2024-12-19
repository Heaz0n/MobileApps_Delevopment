import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(NewsApp());
}

class NewsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Новости',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 14, color: Colors.white70),
          bodyMedium: TextStyle(fontSize: 12, color: Colors.white54),
          titleLarge: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color.fromARGB(255, 26, 26, 98),
          elevation: 4,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color.fromARGB(255, 75, 75, 137),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      home: NewsHome(),
    );
  }
}

class NewsHome extends StatefulWidget {
  @override
  NewsHomeState createState() => NewsHomeState();
}

class NewsHomeState extends State<NewsHome> {
  List<dynamic> newsList = [];
  List<dynamic> filteredNewsList = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;
  DateTime? startDate;
  DateTime? endDate;
  bool isDescending = false;

  final String apiKey = '4c04f69c9f5f502029ec79c49a07027b';
  final String apiUrl = 'http://api.mediastack.com/v1/news?access_key=';

  @override
  void initState() {
    super.initState();
    loadNews();
  }

  Future<void> loadNews() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('$apiUrl$apiKey&countries=ru'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          newsList = data['data'] ?? [];
          filteredNewsList = newsList;
        });

        saveNewsToLocal(newsList);
      } else {
        print('Ошибка загрузки новостей: ${response.statusCode}');
      }
    } catch (e) {
      print('Ошибка при запросе API: $e');
      loadNewsFromLocal();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveNewsToLocal(List<dynamic> news) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('newsData', jsonEncode(news));
  }

  Future<void> loadNewsFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final savedNews = prefs.getString('newsData');

    if (savedNews != null) {
      setState(() {
        newsList = jsonDecode(savedNews);
        filteredNewsList = newsList;
      });
    }
  }

  void searchNews(String query) {
    setState(() {
      List<String> keywords =
          query.split(' ').map((word) => word.toLowerCase()).toList();

      filteredNewsList = newsList.where((news) {
        final title = news['title']?.toLowerCase() ?? '';
        return keywords.every((keyword) => title.contains(keyword));
      }).toList();

      applyFilters();
    });
  }

  void filterByDate(DateTime? selectedDate) {
    setState(() {
      startDate = selectedDate;
      endDate = selectedDate;
      applyFilters();
    });
  }

  void applyFilters() {
    List<dynamic> filtered = newsList;

    if (startDate != null) {
      filtered = filtered.where((news) {
        final dateStr = news['published_at'] ?? '';
        final date = DateTime.tryParse(dateStr);
        return date != null &&
            date.year == startDate!.year &&
            date.month == startDate!.month &&
            date.day == startDate!.day;
      }).toList();
    }

    filtered.sort((a, b) {
      final dateA = DateTime.tryParse(a['published_at'] ?? '');
      final dateB = DateTime.tryParse(b['published_at'] ?? '');
      if (dateA == null || dateB == null) return 0;
      return isDescending ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
    });

    setState(() {
      filteredNewsList = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Новости'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                filterByDate(pickedDate);
              }
            },
          ),
          IconButton(
            icon:
                Icon(isDescending ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () {
              setState(() {
                isDescending = !isDescending;
                applyFilters();
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadNews,
          ),
        ],
      ),
      body: Column(
        children: [
          buildSearchBar(),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: loadNews,
                    child: ListView.builder(
                      itemCount: filteredNewsList.length,
                      itemBuilder: (context, index) {
                        final news = filteredNewsList[index];
                        return NewsItem(news: news);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: searchController,
        onChanged: searchNews,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.white),
          hintText: 'Поиск новостей...',
          hintStyle: TextStyle(color: Colors.white54),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white70),
          ),
          filled: true,
          fillColor: Color(0xFF2C2C3C),
        ),
      ),
    );
  }
}

class NewsItem extends StatelessWidget {
  final dynamic news;

  NewsItem({required this.news});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.blueAccent,
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailPage(news: news),
            ),
          );
        },
        child: Row(
          children: [
            if (news['image'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  news['image'],
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news['title'] ?? 'Без заголовка',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Text(
                      news['description'] ?? '',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.black54),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Дата: ${DateTime.parse(news['published_at']).toLocal().toString().split(' ')[0]}',
                      style: TextStyle(color: Colors.black38, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewsDetailPage extends StatelessWidget {
  final dynamic news;

  NewsDetailPage({required this.news});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(news['title'] ?? 'Детали новости'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            if (news['image'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  news['image'],
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 16),
            Text(
              news['title'] ?? 'Без заголовка',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 8),
            Text(news['description'] ?? ''),
            SizedBox(height: 16),
            Text(
              'Дата: ${DateTime.parse(news['published_at']).toLocal()}',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
