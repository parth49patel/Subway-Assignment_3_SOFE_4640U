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
  - Seeded 22 Subway menu items across categories (6-Inch Subs, Footlong Subs, Wraps & Salads, Sides & Cookies, and Drinks) and rendered them on `MenuScreen` in `lib/main.dart`.

## Upcoming Features

- [ ] **Daily Order Planner & Budget Enforcement:** Select a date, set a daily target cost, and add menu items while preventing the total from exceeding the target budget[.
- [ ] **Order Persistence & Date Queries:** Save daily order plans to SQLite, query saved plans by date, and view all order plans sorted by date descending.
- [ ] **Full CRUD Management:** Add, update, and deletes both menu items and saved order plans.