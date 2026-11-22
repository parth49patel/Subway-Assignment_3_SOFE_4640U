import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/food_item.dart';
import '../theme/app_theme.dart';

/// Screen enabling full CRUD management (add, edit, delete) for Subway menu items.
class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

/// State class managing food item list loading and modal dialogs for adding/editing items.
class _MenuManagementScreenState extends State<MenuManagementScreen> {
  List<FoodItem> _items = [];
  bool _isLoading = true;

  static const List<String> _categories = [
    '6-Inch Subs',
    'Footlong Subs',
    'Wraps & Salads',
    'Sides & Cookies',
    'Drinks',
  ];

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  /// Fetches the latest Subway menu items from SQLite.
  Future<void> _loadMenu() async {
    setState(() => _isLoading = true);
    final items = await DatabaseHelper.instance.getAllFoodItems();
    if (!mounted) return;
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  /// Opens a dialog to add a new food item or edit an existing food item.
  Future<void> _showFoodItemDialog({FoodItem? existingItem}) async {
    final nameController =
    TextEditingController(text: existingItem?.name ?? '');
    final costController = TextEditingController(
      text: existingItem != null ? existingItem.cost.toStringAsFixed(2) : '',
    );
    String selectedCategory = existingItem != null &&
        _categories.contains(existingItem.category)
        ? existingItem.category
        : _categories.first;

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                existingItem == null ? 'Add Subway Menu Item' : 'Edit Menu Item',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Item Name',
                        hintText: 'e.g., 6" Buffalo Chicken',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories
                          .map(
                            (cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ),
                      )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedCategory = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: costController,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Cost (\$)',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final cost = double.tryParse(costController.text.trim());
                    if (name.isEmpty || cost == null || cost <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enter a valid item name and positive cost.'),
                          backgroundColor: AppTheme.errorRed,
                        ),
                      );
                      return;
                    }

                    if (existingItem == null) {
                      await DatabaseHelper.instance.insertFoodItem(
                        FoodItem(
                          name: name,
                          category: selectedCategory,
                          cost: double.parse(cost.toStringAsFixed(2)),
                        ),
                      );
                    } else {
                      await DatabaseHelper.instance.updateFoodItem(
                        FoodItem(
                          id: existingItem.id,
                          name: name,
                          category: selectedCategory,
                          cost: double.parse(cost.toStringAsFixed(2)),
                        ),
                      );
                    }

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext, true);
                    }
                  },
                  child: Text(existingItem == null ? 'Add' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved == true) {
      await _loadMenu();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existingItem == null
                ? 'Added new menu item.'
                : 'Updated menu item.',
          ),
          backgroundColor: AppTheme.subwayGreen,
        ),
      );
    }
  }

  /// Prompts for confirmation and deletes a Subway food item from SQLite.
  Future<void> _deleteFoodItem(FoodItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Menu Item'),
        content: Text('Delete "${item.name}" from the Subway menu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && item.id != null) {
      await DatabaseHelper.instance.deleteFoodItem(item.id!);
      await _loadMenu();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "${item.name}".'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  /// Builds the menu list with edit/delete actions and a floating button to add new items.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final item = _items[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${item.category} • \$${item.cost.toStringAsFixed(2)}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppTheme.subwayGreen),
                    tooltip: 'Edit Item',
                    onPressed: () => _showFoodItemDialog(existingItem: item),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
                    tooltip: 'Delete Item',
                    onPressed: () => _deleteFoodItem(item),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFoodItemDialog(),
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Food Item',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}