import 'package:flutter/material.dart';
import 'screens/customer_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple CRM',
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFF1B263B), // azul oscuro principal
          onPrimary: Colors.white,
          secondary: Color(0xFF415A77), // azul secundario
          onSecondary: Colors.white,
          error: Colors.redAccent,
          onError: Colors.white,
          background: Color(0xFF0D1B2A), // fondo general
          onBackground: Colors.white,
          surface: Color(0xFF1B263B),
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B263B),
          foregroundColor: Colors.white,
          elevation: 1,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1.1,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF24304A),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF415A77),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1B263B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF415A77), width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF778DA9), width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFF778DA9), fontWeight: FontWeight.w600),
        ),
        listTileTheme: const ListTileThemeData(
          iconColor: Color(0xFF778DA9),
          textColor: Colors.white,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF415A77),
          contentTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
          bodyMedium: TextStyle(color: Colors.white, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF778DA9), size: 26),
      ),
      home: const CustomerListScreen(),
    );
  }
}
