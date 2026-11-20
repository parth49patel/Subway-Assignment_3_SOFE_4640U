import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/food_item.dart';
import '../models/order_plan.dart';
import '../theme/app_theme.dart';

/// Screen allowing the user to set a daily target cost, pick a date, select Subway items
/// within budget, and save the resulting order plan to SQLite.
class OrderPlannerScreen extends StatefulWidget {
  const OrderPlannerScreen({super.key});

  @override
  State<OrderPlannerScreen> createState() => _OrderPlannerScreenState();
}

/// State class managing target budget validation, selected items, date selection, and saving.
class _OrderPlannerScreenState extends State<OrderPlannerScreen> {
  final TextEditingController _targetCostController =
  TextEditingController(text: '15.00');

  DateTime _selectedDate = DateTime.now();
  List<FoodItem> _menuItems = [];
  final List<FoodItem> _selectedItems = [];
  bool _isLoading = true;
  String? _budgetWarning;

  @override
  void initState() {
    super.initState();
    _loadMenuItems();
  }

  @override
  void dispose() {
    _targetCostController.dispose();
    super.dispose();
  }

  /// Loads all available Subway food items from SQLite.
  Future<void> _loadMenuItems() async {
    final items = await DatabaseHelper.instance.getAllFoodItems();
    if (!mounted) return;
    setState(() {
      _menuItems = items;
      _isLoading = false;
    });
  }

  /// Parses the user-entered daily target cost, defaulting to 0.0 if invalid.
  double get _targetCost {
    return double.tryParse(_targetCostController.text.trim()) ?? 0.0;
  }

  /// Calculates the cumulative price of all currently selected food items.
  double get _currentTotal {
    return _selectedItems.fold(0.0, (sum, item) => sum + item.cost);
  }

  /// Formats a DateTime object as YYYY-MM-DD for consistent database storage and querying.
  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Opens a date picker dialog so the user can choose the target date for the order plan.
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Adds an item to the order if it does not exceed the target cost; otherwise shows an alert.
  void _addItemToOrder(FoodItem item) {
    final target = _targetCost;
    if (target <= 0) {
      setState(() {
        _budgetWarning = 'Please enter a valid target cost greater than \$0.00.';
      });
      return;
    }

    final projectedTotal = double.parse((_currentTotal + item.cost).toStringAsFixed(2));
    if (projectedTotal > target) {
      final warningMsg =
          'Cannot add ${item.name} (\$${item.cost.toStringAsFixed(2)}): total (\$${projectedTotal.toStringAsFixed(2)}) would exceed your \$${target.toStringAsFixed(2)} target!';
      setState(() {
        _budgetWarning = warningMsg;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(warningMsg),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      return;
    }

    setState(() {
      _budgetWarning = null;
      _selectedItems.add(item);
    });
  }

  /// Removes one instance of the given food item from the current order selection.
  void _removeItemFromOrder(FoodItem item) {
    final index = _selectedItems.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      setState(() {
        _budgetWarning = null;
        _selectedItems.removeAt(index);
      });
    }
  }

  /// Counts how many times a specific menu item is currently selected in the order.
  int _getItemQuantity(FoodItem item) {
    return _selectedItems.where((element) => element.id == item.id).length;
  }

  /// Validates and saves the selected food items and date as an OrderPlan in SQLite.
  Future<void> _saveOrderPlan() async {
    final target = _targetCost;
    if (_selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one Subway item before saving.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (_currentTotal > target) {
      setState(() {
        _budgetWarning =
        'Total cost (\$${_currentTotal.toStringAsFixed(2)}) exceeds your target budget (\$${target.toStringAsFixed(2)}).';
      });
      return;
    }

    final plan = OrderPlan(
      date: _formatDate(_selectedDate),
      targetCost: target,
      totalCost: double.parse(_currentTotal.toStringAsFixed(2)),
      items: List<FoodItem>.from(_selectedItems),
    );

    await DatabaseHelper.instance.insertOrderPlan(plan);

    if (!mounted) return;
    setState(() {
      _selectedItems.clear();
      _budgetWarning = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Saved Subway order plan for ${plan.date} (\$${plan.totalCost.toStringAsFixed(2)})!',
        ),
        backgroundColor: AppTheme.subwayGreen,
      ),
    );
  }

  /// Builds the budget & date header card, warning banner, menu selection list, and save bar.
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final target = _targetCost;
    final total = _currentTotal;
    final remaining = (target - total).clamp(0.0, double.infinity);
    final isOverBudget = total > target;

    return Column(
      children: [
        // Top configuration card: Target Cost input, Date Picker, and Running Budget Summary
        Card(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _targetCostController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Target Cost (\$)',
                          prefixIcon: Icon(Icons.attach_money),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (_) => setState(() {
                          _budgetWarning = null;
                        }),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(_formatDate(_selectedDate)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Selected (${_selectedItems.length}): \$${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isOverBudget ? AppTheme.errorRed : AppTheme.subwayGreen,
                      ),
                    ),
                    Text(
                      'Remaining: \$${remaining.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Inline error banner shown immediately when adding an item would exceed target cost
        if (_budgetWarning != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.errorRed.withValues(alpha: 0.1),
              border: Border.all(color: AppTheme.errorRed),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppTheme.errorRed),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _budgetWarning!,
                    style: const TextStyle(
                      color: AppTheme.errorRed,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Scrollable list of seeded Subway items with quantity controls
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: _menuItems.length,
            itemBuilder: (context, index) {
              final item = _menuItems[index];
              final quantity = _getItemQuantity(item);

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
                      if (quantity > 0) ...[
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          color: AppTheme.errorRed,
                          onPressed: () => _removeItemFromOrder(item),
                        ),
                        Text(
                          '$quantity',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                      IconButton(
                        icon: const Icon(Icons.add_circle),
                        color: AppTheme.subwayGreen,
                        onPressed: () => _addItemToOrder(item),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Bottom Save Order Plan button bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: AppTheme.surfaceWhite,
            border: Border(top: BorderSide(color: AppTheme.borderGray)),
          ),
          child: ElevatedButton.icon(
            onPressed: _saveOrderPlan,
            icon: const Icon(Icons.save),
            label: Text(
              'Save Order Plan (\$${total.toStringAsFixed(2)})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}