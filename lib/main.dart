import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/staff_orders_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock device orientation to portrait for a cleaner UI by default
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const StaffOrdersApp());
}

class StaffOrdersApp extends StatelessWidget {
  const StaffOrdersApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF1F6FEB));

    return MaterialApp(
      title: 'Staff Orders',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          centerTitle: true,
          elevation: 0,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const StaffOrdersListScreen(),
    );
  }
}

