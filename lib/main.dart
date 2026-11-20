import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

/// Entry point of the Subway Planner application.
void main() {
  runApp(const SubwayApp());
}

/// Root widget configuring the app title, Material 3 theme, and initial route.
class SubwayApp extends StatelessWidget {
  const SubwayApp({super.key});

  /// Builds the top-level MaterialApp using the custom Subway color palette.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Subway Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomePlaceholderScreen(),
    );
  }
}

/// Initial landing screen displaying the Subway branding, logo, and theme.
class HomePlaceholderScreen extends StatelessWidget {
  const HomePlaceholderScreen({super.key});

  /// Builds the scaffold with a branded AppBar and centered welcome card.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 90,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome to Subway Planner',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Plan your daily sub order within your target budget.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}