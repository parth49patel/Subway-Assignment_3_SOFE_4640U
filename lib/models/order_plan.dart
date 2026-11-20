import 'dart:convert';
import 'food_item.dart';

/// Represents a saved daily Subway order plan tied to a specific date and target cost.
class OrderPlan {
  final int? id;
  final String date; // Stored in YYYY-MM-DD format for clean sorting and querying
  final double targetCost;
  final double totalCost;
  final List<FoodItem> items;

  const OrderPlan({
    this.id,
    required this.date,
    required this.targetCost,
    required this.totalCost,
    required this.items,
  });

  /// Converts an OrderPlan instance into a Map for SQLite storage, serializing items as JSON.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'target_cost': targetCost,
      'total_cost': totalCost,
      'items_json': jsonEncode(items.map((item) => item.toMap()).toList()),
    };
  }

  /// Creates an OrderPlan instance from a SQLite query result Map.
  factory OrderPlan.fromMap(Map<String, dynamic> map) {
    final List<dynamic> decodedItems =
    jsonDecode(map['items_json'] as String) as List<dynamic>;

    return OrderPlan(
      id: map['id'] as int?,
      date: map['date'] as String,
      targetCost: (map['target_cost'] as num).toDouble(),
      totalCost: (map['total_cost'] as num).toDouble(),
      items: decodedItems
          .map((item) => FoodItem.fromMap(item as Map<String, dynamic>))
          .toList(),
    );
  }
}