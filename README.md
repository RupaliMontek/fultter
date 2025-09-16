# Staff Orders Flutter App

This Flutter app lets you view, add, edit, and delete Staff Orders stored locally using SQLite.

## Features

- View all staff orders (newest first)
- Add a new staff order
- Edit an existing staff order
- Delete an order with confirmation

## Tech

- Flutter (Material 3)
- SQLite via `sqflite`

## Run

1. Ensure you have Flutter installed and set up.
2. From the project root, run:

```bash
flutter pub get
flutter run
```

## Structure

- `lib/main.dart`: App entry point and theme
- `lib/models/staff_order.dart`: Data model
- `lib/data/database_helper.dart`: SQLite helper (CRUD)
- `lib/screens/staff_orders_list_screen.dart`: List UI (view/delete + navigate)
- `lib/screens/staff_orders_upsert_screen.dart`: Add/Edit form

