import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/order_plan.dart';
import '../theme/app_theme.dart';

/// Screen allowing users to query saved Subway order plans by date and view all plans
/// ordered by date descending.
class SavedPlansScreen extends StatefulWidget {
  const SavedPlansScreen({super.key});

  @override
  State<SavedPlansScreen> createState() => _SavedPlansScreenState();
}

/// State class managing date-based SQLite queries and rendering the order plan list.
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

  /// Builds the date query card and the descending list of saved order plan cards.
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