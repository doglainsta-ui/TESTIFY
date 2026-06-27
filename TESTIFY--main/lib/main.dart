import 'package:flutter/material.dart';
import 'database/db_helper.dart';
import 'screens/home_screen.dart';

void main() async {
  // Ensure Flutter engine bindings are ready before interacting with the database
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the database and pre-seed the sample questions automatically
  final db = DBHelper();
  await db.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Testify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          primary: Colors.green,
        ),
        useMaterialDesign3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
