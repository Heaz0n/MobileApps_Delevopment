import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Справочник продуктов',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF3F9FF),
        appBarTheme: const AppBarTheme(
          color: Color(0xFF77C7D9),
          titleTextStyle: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => MainNavigationState();
}

class MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const HomePage(),
    const ProductListPage(),
    const JournalPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      appBar: AppBar(
        title: const Text('Справочник продуктов'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Справочник',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Дневник',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Главная')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Добро пожаловать в Справочник продуктов!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProductListPage(),
                  ),
                );
              },
              child: const Icon(
                Icons.local_dining,
                size: 80,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Изучайте продукты, ведите дневник и находите избранное!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductListPage extends HookWidget {
  const ProductListPage({super.key});

  // Загрузить продукты
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final response = await http.get(Uri.parse(
        'https://world.openfoodfacts.org/cgi/search.pl?search_terms=&search_simple=1&action=process&json=true&fields=product_name,ingredients_text,nutrition_grades,image_url,code,nutriments,warnings'));

    if (response.statusCode != 200) {
      throw Exception('Ошибка загрузки данных: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final products = data['products'] as List<dynamic>;

    return products.map<Map<String, dynamic>>((product) {
      final nutriments = product['nutriments'] ?? {};
      final warnings = product['warnings'] ?? 'Нет противопоказаний';
      final calories = nutriments['energy-kcal_100g'] ?? 'Не указано';

      return {
        'id': product['code'],
        'name': product['product_name'] ?? 'Неизвестно',
        'calories': calories,
        'ingredients': product['ingredients_text'] ?? 'Не указаны',
        'image_url': product['image_url'],
        'health_info': warnings,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final products = useState<List<Map<String, dynamic>>>([]);
    final filteredProducts = useState<List<Map<String, dynamic>>>([]);
    final favorites = useState<List<int>>([]);
    final isLoading = useState<bool>(true);
    final errorMessage = useState<String>('');
    final searchController = useTextEditingController();

    Future<void> loadFavorites() async {
      final prefs = await SharedPreferences.getInstance();
      final savedFavorites = prefs.getStringList('favorites') ?? [];
      favorites.value =
          savedFavorites.map((id) => int.tryParse(id) ?? 0).toList();
    }

    Future<void> saveFavorites() async {
      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList(
          'favorites', favorites.value.map((id) => id.toString()).toList());
    }

    Future<void> toggleFavorite(int productId) async {
      if (favorites.value.contains(productId)) {
        favorites.value.remove(productId);
      } else {
        favorites.value.add(productId);
      }
      await saveFavorites();
    }

    void filterProducts(String query) {
      final results = products.value
          .where((product) =>
              product['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
      filteredProducts.value = results;
    }

    useEffect(() {
      fetchProducts().then((loadedProducts) {
        products.value = loadedProducts;
        filteredProducts.value = loadedProducts;
        isLoading.value = false;
      }).catchError((e) {
        errorMessage.value = 'Ошибка загрузки продуктов: $e';
        isLoading.value = false;
      });

      loadFavorites();
      return null;
    }, []);

    // Добавление продукта в дневник
    Future<void> addProductToJournal(
        Map<String, dynamic> product, BuildContext context) async {
      final prefs = await SharedPreferences.getInstance();
      final currentProducts = prefs.getStringList('addedProducts') ?? [];
      final currentCalories = prefs.getInt('totalCalories') ?? 0;

      // Добавление калорий продукта
      final calories = int.tryParse(product['calories'].toString()) ?? 0;
      final newTotalCalories = currentCalories + calories;

      DateTime? selectedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2101),
      );

      if (selectedDate != null) {
        final productWithDate = {
          'product': product,
          'date': selectedDate.toIso8601String(),
        };

        // Обновляем список добавленных продуктов
        currentProducts.add(jsonEncode(productWithDate));
        await prefs.setStringList('addedProducts', currentProducts);

        // Обновляем общее количество калорий
        await prefs.setInt('totalCalories', newTotalCalories);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Продукт добавлен в дневник')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Продукты'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Поиск продуктов...',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                filterProducts(query);
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (isLoading.value)
            const Center(child: CircularProgressIndicator())
          else if (errorMessage.value.isNotEmpty)
            Center(child: Text(errorMessage.value))
          else
            Expanded(
              child: ListView.builder(
                itemCount: filteredProducts.value.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts.value[index];
                  final isFavorite = favorites.value.contains(product['id']);
                  return Card(
                    child: ListTile(
                      title: Row(
                        children: [
                          Text('${index + 1}. '),
                          Expanded(child: Text(product['name'])),
                        ],
                      ),
                      subtitle: Text('Калории: ${product['calories'] ?? '0'}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : null,
                            ),
                            onPressed: () => toggleFavorite(product['id']),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              addProductToJournal(product, context);
                            },
                            child: const Text('Употребить'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class ProductDetailsPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailsPage({super.key, required this.product});

  Future<void> addProductToJournal(
      Map<String, dynamic> product, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final currentProducts = prefs.getStringList('addedProducts') ?? [];
    final currentCalories = prefs.getInt('totalCalories') ?? 0;

    final calories = int.tryParse(product['calories'].toString()) ?? 0;
    final newTotalCalories = currentCalories + calories;

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      final productWithDate = {
        'product': product,
        'date': selectedDate.toIso8601String(),
      };

      currentProducts.add(jsonEncode(productWithDate));
      await prefs.setStringList('addedProducts', currentProducts);

      await prefs.setInt('totalCalories', newTotalCalories);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Продукт добавлен в дневник')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Детали продукта')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              product['name'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('Калории: ${product['calories']}'),
            const SizedBox(height: 16),
            Text('Ингредиенты: ${product['ingredients']}'),
            const SizedBox(height: 16),
            Text('Противопоказания: ${product['health_info']}'),
            const SizedBox(height: 16),
            if (product['image_url'] != null)
              Image.network(
                product['image_url'],
                height: 200,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => addProductToJournal(product, context),
              child: const Text('Добавить в дневник'),
            ),
          ],
        ),
      ),
    );
  }
}

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  JournalPageState createState() => JournalPageState();
}

class JournalPageState extends State<JournalPage> {
  int totalCalories = 0;
  List<Map<String, dynamic>> addedProducts = [];

  @override
  void initState() {
    super.initState();
    loadCalories();
    loadAddedProducts();
  }

  Future<void> loadCalories() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalCalories = prefs.getInt('totalCalories') ?? 0;
    });
  }

  Future<void> loadAddedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedProducts = prefs.getStringList('addedProducts') ?? [];

    setState(() {
      addedProducts = savedProducts
          .map((productJson) {
            try {
              final decoded = jsonDecode(productJson);
              return decoded != null ? decoded as Map<String, dynamic> : null;
            } catch (e) {
              print("Ошибка декодирования: $e");
              return null;
            }
          })
          .where((product) => product != null)
          .toList()
          .cast<Map<String, dynamic>>(); // Добавляем информацию о продуктах
    });
  }

  Future<void> resetCalories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalCalories', 0);
    await prefs.remove('addedProducts');

    setState(() {
      totalCalories = 0;
      addedProducts.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Все данные о калориях и продуктах сброшены')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Дневник')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ваш дневник калорий:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Общее количество потребленных калорий: $totalCalories',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: addedProducts.length,
                itemBuilder: (context, index) {
                  final productWithDate = addedProducts[index];
                  final product = productWithDate['product'];
                  final date = productWithDate['date'];

                  if (product == null || date == null) {
                    return const SizedBox.shrink();
                  }

                  final imageUrl = product['image_url'];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.image_not_supported),
                      title: Text(product['name'] ?? 'Неизвестный продукт'),
                      subtitle: Text(
                        'Дата: $date\nКалории: ${product['calories'] ?? 'Не указано'}',
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: resetCalories,
              child: const Text('Сбросить данные о калориях'),
            ),
          ],
        ),
      ),
    );
  }
}
