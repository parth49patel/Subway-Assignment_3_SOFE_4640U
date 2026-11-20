import 'package:flutter/material.dart';
import 'screens/order_planner_screen.dart';
import 'theme/app_theme.dart';

/// Entry point of the Subway Planner application; ensures bindings are initialized for SQLite.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SubwayApp());
}

/// Root widget configuring the app title, Material 3 Subway theme, and main navigation shell.
class SubwayApp extends StatelessWidget {
  const SubwayApp({super.key});

  /// Builds the top-level MaterialApp using the custom Subway color palette.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Subway Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}

/// Main navigation shell hosting the Order Planner, Saved Plans, and Menu Management tabs.
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

/// State class tracking the active bottom navigation tab index.
class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  /// List of top-level screens corresponding to each bottom navigation destination.
  final List<Widget> _screens = const [
    OrderPlannerScreen(),
    Center(child: Text('Saved Order Plans (Coming Soon)')),
    Center(child: Text('Manage Menu Items (Coming Soon)')),
  ];

  /// Builds the scaffold with the Subway branded AppBar, active screen body, and NavigationBar.
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
              'Subway Planner',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        indicatorColor: AppTheme.subwayYellow,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'Plan Order',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Saved Plans',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}