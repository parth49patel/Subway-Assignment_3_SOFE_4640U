# Subway Planner

A Flutter mobile application for planning daily Subway food orders within a target budget, built for **SOFE 4640U (Mobile Application Development)**.

## Completed Milestones

- [x] **Project Initialization & Theme Setup (Commit 1):**
    - Created the Flutter project structure and configured `.gitignore` to exclude build artifacts (`build/`, `.dart_tool/`).
    - Implemented the Subway brand color palette (`#008C15` green primary, `#FFC600` yellow secondary, and high-contrast light surfaces) in `lib/theme/app_theme.dart`.
    - Configured `SubwayApp` and the initial home screen layout in `lib/main.dart`.

## Upcoming Features

- [ ] **Local SQLite Database & Menu Seeding:** Store and automatically seed 20+ Subway menu items and prices on first launch.
- [ ] **Daily Order Planner & Budget Enforcement:** Select a date, set a daily target cost, and add menu items while preventing the total from exceeding the target budget.
- [ ] **Order Persistence & Date Queries:** Save daily order plans to SQLite, query saved plans by date, and view all order plans sorted by date descending.
- [ ] **Full CRUD Management:** Add, update, and delete both menu items and saved order plans[cite: 2].