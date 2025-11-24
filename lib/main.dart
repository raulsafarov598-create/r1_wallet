import 'package:flutter/material.dart';
import 'start_screen.dart';
import 'pin_screen.dart';
import 'seed_phrase_screen.dart';
import 'main_tabs.dart';

void main() {
  runApp(const R1WalletApp());
}

class R1WalletApp extends StatelessWidget {
  const R1WalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Color seedColor = Colors.deepPurple;

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
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const StartScreen(),
        '/pin': (context) => const PinScreen(),
        '/seed': (context) => const SeedPhraseScreen(),
        '/main': (context) => const MainTabs(),
      },
    );
  }
}

