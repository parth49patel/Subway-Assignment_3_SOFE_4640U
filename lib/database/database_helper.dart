import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/food_item.dart';
import '../models/order_plan.dart';

/// Singleton helper class managing SQLite database initialization, seeding, and queries.
class DatabaseHelper {
  /// Single shared instance of DatabaseHelper across the application.
  static final DatabaseHelper instance = DatabaseHelper._init();

  /// Cached SQLite database connection instance.
  static Database? _database;

  /// Private constructor to enforce the singleton pattern.
  DatabaseHelper._init();

  /// Returns the existing database connection or initializes it on first access.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('subway_planner.db');
    return _database!;
  }

  /// Opens the local SQLite database file and triggers schema creation on first install.
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Creates the food_items and order_plans tables and seeds the initial Subway menu.
  Future<void> _createDB(Database db, int version) async {
    // Table storing individual Subway food items and their prices
    await db.execute('''
      CREATE TABLE food_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        cost REAL NOT NULL
      )
    ''');

    // Table storing saved daily order plans linked to a target budget and date
    await db.execute('''
      CREATE TABLE order_plans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        target_cost REAL NOT NULL,
        total_cost REAL NOT NULL,
        items_json TEXT NOT NULL
      )
    ''');

    await _seedFoodItems(db);
  }

  /// Populates the food_items table with 22 Subway menu items using a batch insert.
  Future<void> _seedFoodItems(Database db) async {
    final List<FoodItem> initialMenu = [
      // 6-Inch Subs
      const FoodItem(name: '6" Italian B.M.T.', category: '6-Inch Subs', cost: 7.49),
      const FoodItem(name: '6" Sweet Onion Chicken Teriyaki', category: '6-Inch Subs', cost: 7.99),
      const FoodItem(name: '6" Meatball Marinara', category: '6-Inch Subs', cost: 6.99),
      const FoodItem(name: '6" Turkey Breast', category: '6-Inch Subs', cost: 7.29),
      const FoodItem(name: '6" Tuna', category: '6-Inch Subs', cost: 7.29),
      const FoodItem(name: '6" Veggie Delite', category: '6-Inch Subs', cost: 5.99),
      const FoodItem(name: '6" Steak & Cheese', category: '6-Inch Subs', cost: 8.49),
      const FoodItem(name: '6" Cold Cut Combo', category: '6-Inch Subs', cost: 6.79),

      // Footlong Subs
      const FoodItem(name: 'Footlong Italian B.M.T.', category: 'Footlong Subs', cost: 11.49),
      const FoodItem(name: 'Footlong Sweet Onion Teriyaki', category: 'Footlong Subs', cost: 12.29),
      const FoodItem(name: 'Footlong Meatball Marinara', category: 'Footlong Subs', cost: 10.49),
      const FoodItem(name: 'Footlong Steak & Cheese', category: 'Footlong Subs', cost: 12.99),
      const FoodItem(name: 'Footlong Spicy Italian', category: 'Footlong Subs', cost: 10.99),
      const FoodItem(name: 'Footlong Veggie Delite', category: 'Footlong Subs', cost: 9.49),

      // Wraps & Salads
      const FoodItem(name: 'Rotisserie Chicken Caesar Wrap', category: 'Wraps & Salads', cost: 8.79),
      const FoodItem(name: 'Southwest Steak & Avocado Wrap', category: 'Wraps & Salads', cost: 9.29),

      // Sides & Cookies
      const FoodItem(name: 'Chocolate Chip Cookie', category: 'Sides & Cookies', cost: 1.49),
      const FoodItem(name: 'White Chip Macadamia Cookie', category: 'Sides & Cookies', cost: 1.49),
      const FoodItem(name: 'Lay\'s Classic Chips', category: 'Sides & Cookies', cost: 2.19),
      const FoodItem(name: 'Doritos Nacho Cheese', category: 'Sides & Cookies', cost: 2.19),

      // Drinks
      const FoodItem(name: 'Fountain Drink (21 oz)', category: 'Drinks', cost: 2.49),
      const FoodItem(name: 'Bottled Dasani Water', category: 'Drinks', cost: 2.29),
    ];

    final Batch batch = db.batch();
    for (final item in initialMenu) {
      batch.insert('food_items', item.toMap());
    }
    await batch.commit(noResult: true);
  }

  /// Queries and returns all Subway menu items sorted alphabetically by category and name.
  Future<List<FoodItem>> getAllFoodItems() async {
    final db = await instance.database;
    final result = await db.query(
      'food_items',
      orderBy: 'category ASC, name ASC',
    );
    return result.map((map) => FoodItem.fromMap(map)).toList();
  }

  /// Inserts a new daily order plan into the order_plans table and returns its generated row ID.
  Future<int> insertOrderPlan(OrderPlan plan) async {
    final db = await instance.database;
    final data = plan.toMap()..remove('id');
    return await db.insert('order_plans', data);
  }

  /// Retrieves all saved order plans ordered by date descending (newest first).
  Future<List<OrderPlan>> getAllOrderPlans() async {
    final db = await instance.database;
    final result = await db.query(
      'order_plans',
      orderBy: 'date DESC, id DESC',
    );
    return result.map((map) => OrderPlan.fromMap(map)).toList();
  }

  /// Queries saved order plans matching an exact YYYY-MM-DD date string.
  Future<List<OrderPlan>> getOrderPlansByDate(String date) async {
    final db = await instance.database;
    final result = await db.query(
      'order_plans',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'id DESC',
    );
    return result.map((map) => OrderPlan.fromMap(map)).toList();
  }
}