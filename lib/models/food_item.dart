/// Represents a Subway menu item with its name, category, and cost.
class FoodItem {
  final int? id;
  final String name;
  final String category;
  final double cost;

  const FoodItem({
    this.id,
    required this.name,
    required this.category,
    required this.cost,
  });

  /// Converts a FoodItem instance into a Map for SQLite storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'cost': cost,
    };
  }

  /// Creates a FoodItem instance from a SQLite query result Map.
  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      cost: (map['cost'] as num).toDouble(),
    );
  }
}