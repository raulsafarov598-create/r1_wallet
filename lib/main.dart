import 'package:flutter/material.dart';
import 'main_tabs.dart';
import 'pin_screen.dart';
import 'start_screen.dart';

void main() {
  runApp(const R1WalletApp());
}

class R1WalletApp extends StatelessWidget {
  const R1WalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color seedColor = Colors.deepPurple;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'R1 Wallet',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF050816),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF050816),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardColor: const Color(0xFF111827),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF050816),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF111827),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF374151)),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF374151)),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF6366F1)),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          labelStyle: TextStyle(color: Colors.white70),
          hintStyle: TextStyle(color: Colors.white38),
        ),
      ),
      initialRoute: '/pin',
      routes: {
        '/': (context) => const StartScreen(),
        '/pin': (context) => const PinScreen(),
        '/main': (context) => const MainTabs(),
      },
    );
  }
}
