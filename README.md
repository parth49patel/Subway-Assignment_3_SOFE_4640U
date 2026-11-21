# Subway Planner

A Flutter mobile application for planning daily Subway food orders within a target budget, built for **SOFE 4640U (Mobile Application Development)**.

## Completed Milestones

- [x] **Project Initialization & Theme Setup (Commit 1):**
  - Created the Flutter project structure and configured `.gitignore` to exclude build artifacts (`build/`, `.dart_tool/`).
  - Implemented the Subway brand color palette (`#008C15` green primary, `#FFC600` yellow secondary, and high-contrast light surfaces) in `lib/theme/app_theme.dart`.
  - Configured `SubwayApp`, the custom Subway logo assets/launcher icon, and the initial home screen layout in `lib/main.dart`.
- [x] **Local SQLite Database & Menu Seeding (Commit 2):**
  - Added `sqflite` and `path` dependencies and defined data models in `lib/models/food_item.dart` and `lib/models/order_plan.dart`.
  - Implemented `DatabaseHelper` in `lib/database/database_helper.dart` to create the `food_items` and `order_plans` tables on first launch.
  - Seeded 22 Subway menu items across categories (6-Inch Subs, Footlong Subs, Wraps & Salads, Sides & Cookies, and Drinks).
- [x] **Daily Order Planner & Budget Enforcement (Commit 3):**
  - Built `OrderPlannerScreen` in `lib/screens/order_planner_screen.dart` with daily target cost input, date selection, and quantity controls for Subway menu items.
  - Enforced target budget validation to prevent adding food items that would exceed the daily target cost, displaying immediate inline and SnackBar alerts.
  - Added `insertOrderPlan` in `DatabaseHelper` to save valid daily order plans into SQLite and wired up the bottom `NavigationBar` in `lib/main.dart`.
- [x] **Order Persistence & Date Queries (Commit 4):**
  - Added `getAllOrderPlans` (sorted by `date DESC`) and `getOrderPlansByDate` queries to `DatabaseHelper`.
  - Built `SavedPlansScreen` in `lib/screens/saved_plans_screen.dart` to display all saved order plans in descending date order and filter plans by a chosen date with explicit found and not-found states.
## Upcoming Features

- [ ] **Full CRUD Management:** Add, update, and delete both menu items and saved order plans.