import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'models/food_item.dart';
import 'theme/app_theme.dart';

/// Entry point of the Subway Planner application; ensures bindings are initialized for SQLite.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SubwayApp());
}

/// Root widget configuring the app title, Material 3 Subway theme, and initial menu screen.
class SubwayApp extends StatelessWidget {
  const SubwayApp({super.key});

  /// Builds the top-level MaterialApp using the custom Subway color palette.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Subway Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MenuScreen(),
    );
  }
}

/// Home screen displaying the seeded Subway menu items and their prices from SQLite.
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

/// State class responsible for asynchronously loading and rendering the Subway menu list.
class _MenuScreenState extends State<MenuScreen> {
  /// Future holding the list of food items queried from the local SQLite database.
  late Future<List<FoodItem>> _menuFuture;

  /// Initializes state and triggers the initial database query on screen load.
  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  /// Fetches all seeded food items from DatabaseHelper and updates the UI state.
  void _loadMenu() {
    setState(() {
      _menuFuture = DatabaseHelper.instance.getAllFoodItems();
    });
  }

  /// Builds the scaffold with the branded AppBar and FutureBuilder list of food items.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // White badge ensures high contrast for the green-and-yellow Subway logo
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(
                'assets/images/logo.png',
                height: 24,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Subway Menu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<FoodItem>>(
        future: _menuFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading menu: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('No food items found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.12),
                    child: Icon(
                      Icons.fastfood,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  title: Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(item.category),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '\$${item.cost.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}