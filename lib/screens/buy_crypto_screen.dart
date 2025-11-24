import 'package:flutter/material.dart';

class BuyCryptoScreen extends StatelessWidget {
  const BuyCryptoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      appBar: AppBar(
        title: const Text('Купить через карту'),
      ),
      body: const Center(
        child: Text(
          'Покупка через карту будет добавлена позже',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }
}

