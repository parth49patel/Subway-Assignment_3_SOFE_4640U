import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/food_item.dart';
import '../models/order_plan.dart';
import '../theme/app_theme.dart';

/// Screen allowing users to query saved Subway order plans by date, view all plans
/// ordered by date descending, and edit or delete existing order plans.
class SavedPlansScreen extends StatefulWidget {
  const SavedPlansScreen({super.key});

  @override
  State<SavedPlansScreen> createState() => _SavedPlansScreenState();
}

/// State class managing date-based queries and CRUD actions for saved order plans.
class _SavedPlansScreenState extends State<SavedPlansScreen> {
  List<OrderPlan> _displayedPlans = [];
  DateTime _queryDate = DateTime.now();
  bool _isFilteredByDate = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllPlans();
  }

  /// Formats a DateTime object as YYYY-MM-DD to match the SQLite date column format.
  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Loads all saved order plans from SQLite ordered by date descending.
  Future<void> _loadAllPlans() async {
    setState(() => _isLoading = true);
    final plans = await DatabaseHelper.instance.getAllOrderPlans();
    if (!mounted) return;
    setState(() {
      _displayedPlans = plans;
      _isFilteredByDate = false;
      _isLoading = false;
    });
  }

  /// Opens a date picker and queries SQLite for any order plans saved on the chosen date.
  Future<void> _pickAndQueryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _queryDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked == null) return;

    setState(() {
      _queryDate = picked;
      _isLoading = true;
    });

    final formattedDate = _formatDate(picked);
    final matchingPlans =
    await DatabaseHelper.instance.getOrderPlansByDate(formattedDate);

    if (!mounted) return;
    setState(() {
      _displayedPlans = matchingPlans;
      _isFilteredByDate = true;
      _isLoading = false;
    });
  }

  /// Opens an edit dialog allowing the user to update an order plan's date, target cost, or items.
  Future<void> _editOrderPlan(OrderPlan plan) async {
    final allMenuItems = await DatabaseHelper.instance.getAllFoodItems();
    if (!mounted) return;

    final targetController =
    TextEditingController(text: plan.targetCost.toStringAsFixed(2));
    DateTime editDate = DateTime.tryParse(plan.date) ?? DateTime.now();
    final List<FoodItem> editedItems = List<FoodItem>.from(plan.items);
    String? dialogError;

    final bool? updated = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final currentTotal =
            editedItems.fold(0.0, (sum, item) => sum + item.cost);
            final target =
                double.tryParse(targetController.text.trim()) ?? 0.0;

            return AlertDialog(
              title: const Text(
                'Edit Order Plan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: targetController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Target (\$)',
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (_) => setDialogState(() {
                                dialogError = null;
                              }),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: editDate,
                                firstDate: DateTime(2024),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setDialogState(() => editDate = picked);
                              }
                            },
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(_formatDate(editDate)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Total: \$${currentTotal.toStringAsFixed(2)} / \$${target.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: currentTotal > target
                              ? AppTheme.errorRed
                              : AppTheme.subwayGreen,
                        ),
                      ),
                      if (dialogError != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          dialogError!,
                          style: const TextStyle(
                            color: AppTheme.errorRed,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const Divider(height: 16),
                      const Text(
                        'Selected Items (tap to remove):',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      if (editedItems.isEmpty)
                        const Text('No items selected.')
                      else
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: List.generate(editedItems.length, (idx) {
                            final item = editedItems[idx];
                            return InputChip(
                              label: Text(
                                '${item.name} (\$${item.cost.toStringAsFixed(2)})',
                                style: const TextStyle(fontSize: 12),
                              ),
                              onDeleted: () {
                                setDialogState(() {
                                  dialogError = null;
                                  editedItems.removeAt(idx);
                                });
                              },
                            );
                          }),
                        ),
                      const Divider(height: 16),
                      const Text(
                        'Add Item from Menu:',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 160,
                        child: ListView.builder(
                          itemCount: allMenuItems.length,
                          itemBuilder: (context, idx) {
                            final menuItem = allMenuItems[idx];
                            return ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(menuItem.name),
                              subtitle: Text('\$${menuItem.cost.toStringAsFixed(2)}'),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.add_circle,
                                  color: AppTheme.subwayGreen,
                                ),
                                onPressed: () {
                                  final projected = double.parse(
                                    (currentTotal + menuItem.cost)
                                        .toStringAsFixed(2),
                                  );
                                  if (projected > target) {
                                    setDialogState(() {
                                      dialogError =
                                      'Adding ${menuItem.name} exceeds target cost!';
                                    });
                                    return;
                                  }
                                  setDialogState(() {
                                    dialogError = null;
                                    editedItems.add(menuItem);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (editedItems.isEmpty || target <= 0 || currentTotal > target) {
                      setDialogState(() {
                        dialogError =
                        'Ensure at least 1 item is selected within target budget.';
                      });
                      return;
                    }

                    final updatedPlan = OrderPlan(
                      id: plan.id,
                      date: _formatDate(editDate),
                      targetCost: target,
                      totalCost: double.parse(currentTotal.toStringAsFixed(2)),
                      items: editedItems,
                    );

                    await DatabaseHelper.instance.updateOrderPlan(updatedPlan);
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext, true);
                    }
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );

    if (updated == true) {
      await _loadAllPlans();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order plan updated.'),
          backgroundColor: AppTheme.subwayGreen,
        ),
      );
    }
  }

  /// Prompts for confirmation and deletes a saved order plan from SQLite.
  Future<void> _deleteOrderPlan(OrderPlan plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Order Plan'),
        content: Text('Delete the order plan for ${plan.date}?'),
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

    if (confirmed == true && plan.id != null) {
      await DatabaseHelper.instance.deleteOrderPlan(plan.id!);
      await _loadAllPlans();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted order plan for ${plan.date}.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  /// Builds the date query card and the descending list of saved order plan cards with edit/delete controls.
  @override
  Widget build(BuildContext context) {
    final formattedQueryDate = _formatDate(_queryDate);

    return Column(
      children: [
        // Top date-query filter card
        Card(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Query Order Plan by Date',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickAndQueryDate,
                        icon: const Icon(Icons.search),
                        label: Text(
                          _isFilteredByDate
                              ? 'Date: $formattedQueryDate'
                              : 'Pick Date to Search',
                        ),
                      ),
                    ),
                    if (_isFilteredByDate) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _loadAllPlans,
                        child: const Text('Show All'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),

        // Results header label
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isFilteredByDate
                    ? 'Search Results for $formattedQueryDate'
                    : 'All Saved Plans (Newest First)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                '${_displayedPlans.length} found',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        // Main results list or explicit not-found state
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _displayedPlans.isEmpty
              ? Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 52,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _isFilteredByDate
                        ? 'No order plan found for $formattedQueryDate.'
                        : 'No saved order plans yet.',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: _displayedPlans.length,
            itemBuilder: (context, index) {
              final plan = _displayedPlans[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_month,
                                size: 18,
                                color: AppTheme.subwayGreen,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                plan.date,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.subwayYellow,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '\$${plan.totalCost.toStringAsFixed(2)} / \$${plan.targetCost.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: AppTheme.subwayGreen,
                                ),
                                tooltip: 'Edit Order Plan',
                                onPressed: () => _editOrderPlan(plan),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                  color: AppTheme.errorRed,
                                ),
                                tooltip: 'Delete Order Plan',
                                onPressed: () => _deleteOrderPlan(plan),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      ...plan.items.map(
                            (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text('• ${item.name}')),
                              Text(
                                '\$${item.cost.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}